import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// ==========================================
// PROVIDERS PARA LISTAR
// ==========================================

final proveedoresProvider = FutureProvider<List<ProveedorEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerProveedores();
});

final proveedoresActivosProvider = FutureProvider<List<ProveedorEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerProveedores(soloActivos: true);
});

final proveedorPorIdProvider = FutureProvider.family<ProveedorEntity?, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerProveedorPorId(id);
});

// ==========================================
// PROVIDERS PARA ACCIONES
// ==========================================

final crearProveedorProvider = FutureProvider.family<void, ProveedorEntity>((ref, proveedor) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.guardarProveedor(proveedor);
});

final actualizarProveedorProvider = FutureProvider.family<void, ProveedorEntity>((ref, proveedor) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.guardarProveedor(proveedor);
});

final desactivarProveedorProvider = FutureProvider.family<void, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.desactivarProveedor(id);
});

final eliminarProveedorProvider = FutureProvider.family<bool, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.eliminarProveedor(id);
});

final buscarProveedoresProvider = FutureProvider.family<List<ProveedorEntity>, String>((ref, query) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.buscarProveedores(query);
});