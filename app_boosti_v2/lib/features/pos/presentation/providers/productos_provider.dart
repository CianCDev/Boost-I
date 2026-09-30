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
    state = state.copyWith(isLoading: true);
    
    try {
      final productos = await _isar.obtenerProductos();
      
      // 🔥 Validación crucial: Evita actualizar el estado si el widget/provider ya se cerró
      if (!mounted) return; 
      
      final currentItems = state.items;
      
      // 🔥 Comparar antes de actualizar
      if (!_listasSonIguales(currentItems, productos)) {
        state = state.copyWith(items: productos, isLoading: false);
        debugPrint('🔄 [ProductosNotifier] Productos actualizados (${productos.length} items)');
      } else {
        state = state.copyWith(isLoading: false);
        debugPrint('ℹ️ [ProductosNotifier] Sin cambios en productos');
      }
    } catch (e) {
      // 🔥 Verificar también en caso de error asíncrono
      if (!mounted) return; 
      state = state.copyWith(isLoading: false);
      debugPrint('❌ [ProductosNotifier] Error: $e');
      rethrow;
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
/// 🎯 FIX CRÍTICO: el stock NUNCA queda negativo.
///
///   Aunque el caller pase un valor negativo por error (bug de cálculo,
///   desincronización de la BD, condición de carrera), aquí se aplica
///   `clamp(0, double.infinity)` antes de persistir.
///
///   Si el valor fue "corregido", se registra un `debugPrint` para
///   auditoría y el movimiento de inventario refleja la diferencia
///   REAL aplicada (no la solicitada).
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

  await _sync.sincronizarMovimientosInventario();
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

  Future<void> registrarMovimientoManual(
    int productoId,
    double cantidad,
    String tipo,
    UsuarioEntity usuario,
  ) async {
    final producto = await _isar.obtenerProductoPorId(productoId);
    if (producto == null) return;

    final nuevoStock = producto.stock + cantidad;
    producto.stock = nuevoStock;
    await _isar.guardarProducto(producto);

    final movimiento = MovimientoInventarioEntity()
      ..productoId = producto.id
      ..nombreProducto = producto.nombre
      ..tipoMovimiento = tipo
      ..cantidad = cantidad
      ..stockResultante = nuevoStock
      ..fecha = DateTime.now()
      ..usuarioId = usuario.id
      ..syncStatus = 'pending';
    await _isar.guardarMovimientoInventario(movimiento);

    await _sync.sincronizarMovimientosInventario();
    await cargarProductos();
  }
}

final productosProvider = StateNotifierProvider<ProductosNotifier, ProductosState>((ref) {
  return ProductosNotifier();
});