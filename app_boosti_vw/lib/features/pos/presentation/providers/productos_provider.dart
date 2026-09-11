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
    if (!mounted) return; 
    state = state.copyWith(isLoading: true);
    
    try {
      final productos = await _isar.obtenerProductos();
      if (!mounted) return; 
      
      final currentItems = state.items;
      
      if (!_listasSonIguales(currentItems, productos)) {
        state = state.copyWith(items: productos, isLoading: false);
        debugPrint('🔄 [ProductosNotifier] Productos actualizados (${productos.length} items)');
      } else {
        state = state.copyWith(isLoading: false);
        debugPrint('ℹ️ [ProductosNotifier] Sin cambios en productos');
      }
    } catch (e) {
      if (!mounted) return; 
      state = state.copyWith(isLoading: false);
      debugPrint('❌ [ProductosNotifier] Error: $e');
      rethrow;
    }
  }

  bool _listasSonIguales(List<ProductoEntity> a, List<ProductoEntity> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      // Comparar por código de barras (único en Sembast)
      if (a[i].codigoBarras != b[i].codigoBarras) return false;
      if (a[i].stock != b[i].stock) return false;
      if (a[i].precioUnidad != b[i].precioUnidad) return false;
      if (a[i].nombre != b[i].nombre) return false;
      if (a[i].imagenUrl != b[i].imagenUrl) return false;
      if (a[i].stockMinimo != b[i].stockMinimo) return false;
      if (a[i].categoria != b[i].categoria) return false;
      if (a[i].esPesado != b[i].esPesado) return false;
      if (a[i].proveedorNombre != b[i].proveedorNombre) return false;
      if (a[i].proveedorTelefono != b[i].proveedorTelefono) return false;
    }
    return true;
  }

  Future<void> recargarDesdeSupabase() async {
    debugPrint('🔄 [ProductosNotifier] Recargando desde Supabase...');
    await _sync.descargarProductosDesdeSupabase();
    await cargarProductos();
  }

  // 🔥 CORREGIDO: Método para actualizar stock por código de barras
  Future<void> actualizarStockPorCodigo(
    String codigoBarras,
    double nuevoStock,
    UsuarioEntity usuario, {
    String? motivo,
  }) async {
    final producto = await _isar.obtenerProductoPorCodigoBarrasExacto(codigoBarras);
    if (producto == null) return;

    final stockAnterior = producto.stock;
    final diferencia = nuevoStock - stockAnterior;

    if (diferencia != 0) {
      producto.stock = nuevoStock;
      await _isar.guardarProducto(producto);

      final movimiento = MovimientoInventarioEntity()
        ..productoId = 0 // Sin ID numérico
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

  // 🔥 CORREGIDO: Eliminar producto por código de barras
  Future<void> eliminarProductoPorCodigo(String codigoBarras, UsuarioEntity usuario) async {
    final producto = await _isar.obtenerProductoPorCodigoBarrasExacto(codigoBarras);
    if (producto == null) return;

    final movimiento = MovimientoInventarioEntity()
      ..productoId = 0
      ..nombreProducto = producto.nombre
      ..tipoMovimiento = 'Eliminación'
      ..cantidad = -producto.stock
      ..stockResultante = 0
      ..fecha = DateTime.now()
      ..usuarioId = usuario.id
      ..syncStatus = 'pending';
    await _isar.guardarMovimientoInventario(movimiento);

    await _isar.eliminarProductoPorCodigo(codigoBarras);
    await _sync.sincronizarMovimientosInventario();
    await cargarProductos();
  }

  // 🔥 CORREGIDO: Guardar producto SIN DUPLICADOS (usa código de barras)
  Future<void> guardarProducto(ProductoEntity producto, UsuarioEntity usuario, {bool esNuevo = false}) async {
    final productoExistente = await _isar.obtenerProductoPorCodigoBarrasExacto(producto.codigoBarras);

    if (productoExistente != null) {
      // Editar existente
      productoExistente.nombre = producto.nombre;
      productoExistente.precioUnidad = producto.precioUnidad;
      productoExistente.stock = producto.stock;
      productoExistente.categoria = producto.categoria;
      productoExistente.esPesado = producto.esPesado;
      productoExistente.activo = producto.activo;
      productoExistente.imagenUrl = producto.imagenUrl;
      productoExistente.marca = producto.marca;
      productoExistente.marcaSupabaseId = producto.marcaSupabaseId;
      productoExistente.proveedorNombre = producto.proveedorNombre;
      productoExistente.updatedAt = DateTime.now();

      await _isar.guardarProducto(productoExistente);
    } else {
      // Insertar nuevo
      await _isar.guardarProducto(producto);
    }

    await _sync.sincronizarMovimientosInventario();
    await _sync.sincronizarProductosASupabase();
    await cargarProductos();
  }

  // Métodos legacy con ID (para no romper llamadas existentes)
  Future<void> actualizarStock(int productoId, double nuevoStock, UsuarioEntity usuario, {String? motivo}) async {
    final producto = await _isar.obtenerProductoPorId(productoId);
    if (producto != null) {
      await actualizarStockPorCodigo(producto.codigoBarras, nuevoStock, usuario, motivo: motivo);
    }
  }

  Future<void> eliminarProducto(int productoId, UsuarioEntity usuario) async {
    final producto = await _isar.obtenerProductoPorId(productoId);
    if (producto != null) {
      await eliminarProductoPorCodigo(producto.codigoBarras, usuario);
    }
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
      ..productoId = 0
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