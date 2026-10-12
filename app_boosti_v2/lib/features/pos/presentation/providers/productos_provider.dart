import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../services/sync_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import 'package:flutter/foundation.dart';

class ProductosState {
  final List<ProductoEntity> items;
  final bool isLoading;

  const ProductosState({this.items = const [], this.isLoading = true});

  ProductosState copyWith({List<ProductoEntity>? items, bool? isLoading}) {
    return ProductosState(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
  }

  /// Igualdad ESTRUCTURAL, no por identidad.
  ///
  /// ## Por qué importa
  /// `catalogProvider` e `inventoryProvider` hacen
  /// `ref.listen(productosProvider, ...)` y en cada disparo corren un
  /// filtrado O(n) sobre TODOS los productos
  /// (`catalog_provider.dart:139`, `inventory_provider.dart:113`).
  ///
  /// `items` es una lista freshly-allocated por `obtenerProductos()` en
  /// cada llamada, así que comparar por identidad nunca daba igual. Sin
  /// este `==`, cada `cargarProductos()` emitía DOS veces (loading true y
  /// loading false) y las dos causaban los dos passes completos, aunque no
  /// hubiera cambiado un solo producto.
  ///
  /// `InventoryState` y `CatalogState` ya tenían `==`; este faltaba y era
  /// la pieza que hacía repetir el filtrado.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProductosState) return false;
    if (other.isLoading != isLoading) return false;
    if (other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      final a = items[i];
      final b = other.items[i];
      if (a.id != b.id) return false;
      if (a.stock != b.stock) return false;
      if (a.nombre != b.nombre) return false;
      if (a.precioUnidad != b.precioUnidad) return false;
      if (a.categoria != b.categoria) return false;
      if (a.imagenUrl != b.imagenUrl) return false;
      if (a.stockMinimo != b.stockMinimo) return false;
      if (a.esPesado != b.esPesado) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        items.length,
        Object.hashAll(items.map((p) => p.id)),
      );
}

class ProductosNotifier extends StateNotifier<ProductosState> {
  final IsarService _isar = IsarService();
  final SyncService _sync = SyncService();

  ProductosNotifier() : super(const ProductosState()) {
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    // Si el provider fue destruido antes de empezar, abortamos
    if (!mounted) return;
    // Solo emitir `isLoading: true` si veníamos de un estado estable.
    // Repetirlo cuando ya estábamos cargando genera una emisión
    // identica que igual dispara los `ref.listen` de catalog e inventory.
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true);
    }

    try {
      final productos = await _isar.obtenerProductos();

      // 🔥 Validación crucial: Evita actualizar el estado si el widget/provider ya se cerró
      if (!mounted) return;

      final currentItems = state.items;

      // 🔥 Comparar antes de actualizar
      if (!_listasSonIguales(currentItems, productos)) {
        state = state.copyWith(items: productos, isLoading: false);
        debugPrint('🔄 [ProductosNotifier] Productos actualizados (${productos.length} items)');
      } else if (state.isLoading) {
        // ⚠️ La lista no cambió, pero el notifier estaba en `isLoading`.
        //
        // Sin esta emisión, `isLoading` queda en `true` PARA SIEMPRE
        // cuando Isar devuelve vacío: `_listasSonIguales([], [])` da
        // true, se entraba por la rama "sin cambios" y nunca se bajaba
        // el flag. La UI que gatea por `isLoading` se quedaba en spinner
        // eterno hasta que un cambio de local hiciera invalidate.
        //
        // Emitir acá NO reintroduce el costo que la optimización evita:
        // el estado pasa de `(items: [], isLoading: true)` a
        // `(items: [], isLoading: false)`, que son DISTINTOS. La
        // comparación estructural da false, así que los listeners corren
        // una sola vez, no dos.
        debugPrint('ℹ️ [ProductosNotifier] Sin cambios, pero se cierra la carga');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // 🔥 Verificar también en caso de error asíncrono
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
      debugPrint('❌ [ProductosNotifier] Error: $e');
      // Sin `rethrow`: el unico caller en el constructor
      // (`ProductosNotifier()`) no captura nada, asi que relanzar
      // producia una excepcion no manejada. Ademas el estado ya quedo
      // en `isLoading: false` con los items previos, que es el mejor
      // resultado posible: la UI sigue mostrando el ultimo catalogo
      // conocido en vez de quedar en blanco.
    }
  }

  /// 🔥 Comparación mejorada (todos los campos relevantes)
 bool _listasSonIguales(List<ProductoEntity> a, List<ProductoEntity> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i].id != b[i].id) return false;
    if (a[i].stock != b[i].stock) return false;
    if (a[i].precioUnidad != b[i].precioUnidad) return false;
    if (a[i].nombre != b[i].nombre) return false;
    if (a[i].imagenUrl != b[i].imagenUrl) return false;
    if (a[i].stockMinimo != b[i].stockMinimo) return false;
    if (a[i].categoria != b[i].categoria) return false;
    if (a[i].esPesado != b[i].esPesado) return false;
    if (a[i].proveedorNombre != b[i].proveedorNombre) return false;
    if (a[i].proveedorTelefono != b[i].proveedorTelefono) return false;
    if (a[i].supabaseId != b[i].supabaseId) return false;
    // ✅ NUEVO: Ventas al mayor
    if (a[i].permiteVentaMayor != b[i].permiteVentaMayor) return false;
    if (a[i].precioMayor != b[i].precioMayor) return false;
    if (a[i].cantidadMinimaMayor != b[i].cantidadMinimaMayor) return false;
    if (a[i].precioMedioMayor != b[i].precioMedioMayor) return false;
    if (a[i].cantidadMinimaMedioMayor !=
        b[i].cantidadMinimaMedioMayor) {
      return false;
    }
    if (a[i].unidadesPorBulto != b[i].unidadesPorBulto) return false;
    if (a[i].costoUnitarioPromedio != b[i].costoUnitarioPromedio) return false;
  }
  return true;
}

  Future<void> recargarDesdeSupabase() async {
    debugPrint('🔄 [ProductosNotifier] Recargando desde Supabase...');
    await _sync.descargarProductosDesdeSupabase();
    await cargarProductos();
  }

  /// Actualiza el stock de un producto.
///
/// ⚠️ **DEPRECADADA.** No la uses.
///
/// Acepta un `nuevoStock` a ciegas: escribe `producto.stock` sin mirar
/// los lotes, que es exactamente el patrón que produjo la duplicación
/// `producto.stock` ↔ `SUM(lotes.cantidad_restante)` y el salto de
/// stock 165 → 175. No tiene ningún caller interno.
///
/// En su lugar, según la operación:
///
///  * Ajuste manual de inventario → mover `lotes.cantidadRestante` y
///    llamar `IsarService.recalcularStockDe([productoId])`.
///  * Cambio desde el editor de producto →
///    `IsarService.ajustarStockDesdeEditor(productoId, stockObjetivo)`.
///  * Tras una venta → nada: `VentaService.procesarVenta` ya recalcula
///    al final.
///
/// Esta marca existe para que un refactor futuro no la reintroduzca.
@Deprecated(
  'Usar IsarService.recalcularStockDe(productoIds) tras mover los lotes, '
  'o IsarService.ajustarStockDesdeEditor(productoId, stockObjetivo). '
  'Esta API acepta stock ciego y puede reintroducir el bug de duplicación '
  'producto.stock ↔ SUM(lotes).',
)
Future<void> actualizarStock(
  int productoId,
  double nuevoStock,
  UsuarioEntity usuario, {
  String? motivo,
}) async {
  final producto = await _isar.obtenerProductoPorId(productoId);
  if (producto == null) return;

  final stockAnterior = producto.stock;

  // ═══════════════════════════════════════════════════════════════════
  // 🎯 Clamp: nunca permitir stock negativo.
  //
  //   El stock físico de un producto es >= 0 por definición. Si el
  //   caller pasa un negativo, lo forzamos a 0 y loggeamos el ajuste.
  // ═══════════════════════════════════════════════════════════════════
  final stockLimitado = nuevoStock.clamp(0.0, double.infinity);

  if (stockLimitado != nuevoStock) {
    debugPrint(
      '⚠️ [ProductosNotifier] Stock de "${producto.nombre}" corregido '
      'de $nuevoStock → $stockLimitado (se aplicó clamp a 0)',
    );
  }

  // ── Diferencia real (post-clamp) ──
  final diferencia = stockLimitado - stockAnterior;

  if (diferencia == 0) {
    // Nada que actualizar. Evita escribir en disco innecesariamente.
    return;
  }

  producto.stock = stockLimitado;
  await _isar.guardarProducto(producto);

  // ── Movimiento de inventario con la diferencia REAL ──
  final movimiento = MovimientoInventarioEntity()
    ..productoId = producto.id
    ..nombreProducto = producto.nombre
    ..tipoMovimiento = motivo ?? 'Ajuste manual'
    ..cantidad = diferencia // ← refleja el cambio real aplicado
    ..stockResultante = stockLimitado
    ..fecha = DateTime.now()
    ..usuarioId = usuario.id
    ..syncStatus = 'pending';
  await _isar.guardarMovimientoInventario(movimiento);

  // ⚠️ Fase 1: NO sincronizar a la nube desde aquí.
  //
  //   Este ajuste de stock es local. La subida de movimientos (y el
  //   RPC `ajustar_stock`) se dispara en Fase 2, al confirmar el
  //   cobro, dentro de la transacción de `procesarVenta`.
  //
  //   Antes se llamaba `_sync.sincronizarMovimientosInventario()` aquí,
  //   lo que hacía 2 cosas malas:
  //     1. Introducía un `await` de red ANTES de `cargarProductos()`.
  //        Si la red fallaba, el provider no refrescaba y la UI
  //        mostraba stock viejo aunque Isar ya tuviera el valor
  //        correcto.
  //     2. Restaba stock en Supabase por ajustes que podían
  //        revertirse (agregar/quitar del carrito).
  await cargarProductos();
}

  Future<void> eliminarProducto(int productoId, UsuarioEntity usuario) async {
    final producto = await _isar.obtenerProductoPorId(productoId);
    if (producto == null) return;

    final movimiento = MovimientoInventarioEntity()
      ..productoId = producto.id
      ..nombreProducto = producto.nombre
      ..tipoMovimiento = 'Eliminación'
      ..cantidad = -producto.stock
      ..stockResultante = 0
      ..fecha = DateTime.now()
      ..usuarioId = usuario.id
      ..syncStatus = 'pending';
    await _isar.guardarMovimientoInventario(movimiento);

    await _isar.eliminarProducto(productoId);
    await _sync.sincronizarMovimientosInventario();
    await cargarProductos();
  }

  Future<void> guardarProducto(ProductoEntity producto, UsuarioEntity usuario, {bool esNuevo = false}) async {
    if (esNuevo) {
      await _isar.guardarProducto(producto);
      if (producto.stock > 0) {
        final movimiento = MovimientoInventarioEntity()
          ..productoId = producto.id
          ..nombreProducto = producto.nombre
          ..tipoMovimiento = 'Creación producto'
          ..cantidad = producto.stock
          ..stockResultante = producto.stock
          ..fecha = DateTime.now()
          ..usuarioId = usuario.id
          ..syncStatus = 'pending';
        await _isar.guardarMovimientoInventario(movimiento);
      }
    } else {
      final oldProducto = await _isar.obtenerProductoPorId(producto.id);
      if (oldProducto != null) {
        final stockAnterior = oldProducto.stock;
        if (stockAnterior != producto.stock) {
          final movimiento = MovimientoInventarioEntity()
            ..productoId = producto.id
            ..nombreProducto = producto.nombre
            ..tipoMovimiento = 'Edición de stock'
            ..cantidad = producto.stock - stockAnterior
            ..stockResultante = producto.stock
            ..fecha = DateTime.now()
            ..usuarioId = usuario.id
            ..syncStatus = 'pending';
          await _isar.guardarMovimientoInventario(movimiento);
        }
        await _isar.guardarProducto(producto);
      } else {
        await _isar.guardarProducto(producto);
      }
    }

    await _sync.sincronizarMovimientosInventario();
    await _sync.sincronizarProductosASupabase();
    await cargarProductos();
  }

  // ⚠️ `registrarMovimientoManual` fue eliminado (Lote C).
  //
  //   No tenía NINGÚN caller (verificado por grep en lib/: 0
  //   referencias fuera de su propia definición) y escribía
  //   `producto.stock = producto.stock + cantidad`, es decir una
  //   aritmética ciega a los lotes. Con el modelo "lotes = fuente única
  //   de verdad" ese patrón es exactamente lo que había que eliminar.
  //
  //   Si alguna vez hace falta un ajuste manual de stock, el camino
  //   correcto es mover la cantidad en `lotes.cantidad_restante` y
  //   llamar a `IsarService.recalcularStockDe([productoId])`.
}

final productosProvider = StateNotifierProvider<ProductosNotifier, ProductosState>((ref) {
  return ProductosNotifier();
});