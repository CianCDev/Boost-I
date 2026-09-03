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
    state = state.copyWith(isLoading: true);
    try {
      final productos = await _isar.obtenerProductos();
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
      state = state.copyWith(isLoading: false);
      debugPrint('❌ [ProductosNotifier] Error: $e');
      rethrow;
    }
  }

  /// 🔥 Comparación mejorada (todos los campos relevantes)
  bool _listasSonIguales(List<ProductoEntity> a, List<ProductoEntity> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      // Comparar campos que afectan la UI
      if (a[i].id != b[i].id) return false;
      if (a[i].stock != b[i].stock) return false;
      if (a[i].ventasAcumuladas != b[i].ventasAcumuladas) return false;
      if (a[i].precioUnidad != b[i].precioUnidad) return false;
      if (a[i].nombre != b[i].nombre) return false;
      if (a[i].imagenUrl != b[i].imagenUrl) return false;
      if (a[i].stockMinimo != b[i].stockMinimo) return false;
      if (a[i].categoria != b[i].categoria) return false;
      if (a[i].esPesado != b[i].esPesado) return false;
      if (a[i].proveedorNombre != b[i].proveedorNombre) return false;
      if (a[i].proveedorTelefono != b[i].proveedorTelefono) return false;
      // Comparar supabaseId (aunque no afecta la UI, pero evita falsos cambios)
      if (a[i].supabaseId != b[i].supabaseId) return false;
    }
    return true;
  }

  Future<void> recargarDesdeSupabase() async {
    debugPrint('🔄 [ProductosNotifier] Recargando desde Supabase...');
    await _sync.descargarProductosDesdeSupabase();
    await cargarProductos();
  }

  Future<void> actualizarStock(
    int productoId,
    double nuevoStock,
    UsuarioEntity usuario, {
    String? motivo,
  }) async {
    final producto = await _isar.obtenerProductoPorId(productoId);
    if (producto == null) return;

    final stockAnterior = producto.stock;
    final diferencia = nuevoStock - stockAnterior;

    if (diferencia != 0) {
      producto.stock = nuevoStock;
      await _isar.guardarProducto(producto);

      final movimiento = MovimientoInventarioEntity()
        ..productoId = producto.id
        ..nombreProducto = producto.nombre
        ..tipoMovimiento = motivo ?? 'Ajuste manual'
        ..cantidad = diferencia
        ..stockResultante = nuevoStock
        ..fecha = DateTime.now()
        ..usuarioId = usuario.id
        ..syncStatus = 'pending';
      await _isar.guardarMovimientoInventario(movimiento);

      await _sync.sincronizarMovimientosInventario();
      await cargarProductos();
    }
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