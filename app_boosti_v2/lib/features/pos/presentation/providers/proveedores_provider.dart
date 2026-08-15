import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// Provider con filtros
final proveedoresConFiltroProvider = FutureProvider.family<List<ProveedorEntity>, ({
  String query,
  bool mostrarInactivos,
  int? productoId,
})>((ref, params) async {
  final isar = ref.watch(isarServiceProvider);
  
  final todos = await isar.obtenerProveedores(soloActivos: false);
  
  var resultado = todos.where((p) {
    if (params.mostrarInactivos) {
      return !p.activo;
    } else {
      return p.activo;
    }
  }).toList();
  
  if (params.query.isNotEmpty) {
    final q = params.query.toLowerCase();
    resultado = resultado.where((p) {
      final coincideNombre = p.nombre.toLowerCase().contains(q);
      final coincideEmpresa = (p.empresa ?? '').toLowerCase().contains(q);
      return coincideNombre || coincideEmpresa;
    }).toList();
  }
  
  if (params.productoId != null) {
    final productos = await isar.obtenerProductos();
    final proveedoresIdsConProducto = productos
        .where((p) => p.proveedorId == params.productoId)
        .map((p) => p.proveedorId!)
        .toSet();
    resultado = resultado.where((p) => proveedoresIdsConProducto.contains(p.id)).toList();
  }
  
  return resultado;
});

// ✅ Provider único para guardar (crea o actualiza según el ID)
final guardarProveedorProvider = FutureProvider.family<void, ProveedorEntity>((ref, proveedor) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.guardarProveedor(proveedor);
});

final desactivarProveedorProvider = FutureProvider.family<void, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.desactivarProveedor(id);
});

final productosPorProveedorProvider = FutureProvider.family<List<ProductoEntity>, int>((ref, proveedorId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerProductosPorProveedor(proveedorId);
});