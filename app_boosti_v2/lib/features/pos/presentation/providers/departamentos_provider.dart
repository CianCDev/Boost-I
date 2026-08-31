// lib/features/pos/presentation/providers/departamentos_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// ============================================================
// 1. PROVIDERS BÁSICOS (SIN FILTROS)
// ============================================================

/// Obtiene todos los departamentos (activos o inactivos, opcionalmente filtrados por local)
final departamentosProvider = FutureProvider.family<List<DepartamentoEntity>, int?>((ref, localId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerDepartamentos(soloActivos: false, localId: localId);
});

/// Obtiene solo departamentos activos
final departamentosActivosProvider = FutureProvider.family<List<DepartamentoEntity>, int?>((ref, localId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerDepartamentos(soloActivos: true, localId: localId);
});

/// Obtiene un departamento por su ID
final departamentoPorIdProvider = FutureProvider.family<DepartamentoEntity?, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerDepartamentoPorId(id);
});

final todosDepartamentosProvider = FutureProvider<List<DepartamentoEntity>>((ref) async {
  final isar = IsarService();
  return await isar.obtenerDepartamentos(soloActivos: false);
});

// ============================================================
// 2. PROVIDER CON FILTROS AVANZADOS (PARA LA UI)
// ============================================================

/// Provider con filtros: búsqueda por nombre, activos/inactivos, filtro por local
final departamentosConFiltroProvider = FutureProvider.family<List<DepartamentoEntity>, ({
  String query,
  bool soloActivos,
  int? localId,
})>((ref, params) async {
  final isar = ref.watch(isarServiceProvider);
  final departamentos = await isar.obtenerDepartamentos(
    soloActivos: params.soloActivos,
    localId: params.localId,
  );
  if (params.query.isNotEmpty) {
    final q = params.query.toLowerCase();
    return departamentos.where((d) => d.nombre.toLowerCase().contains(q)).toList();
  }
  return departamentos;
});

// ============================================================
// 3. PROVIDERS DE ACCIÓN (GUARDAR, ELIMINAR)
// ============================================================

/// Guardar departamento (crear o actualizar) con invalidación automática
final guardarDepartamentoProvider = FutureProvider.family<void, DepartamentoEntity>((ref, departamento) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.guardarDepartamento(departamento);
  // Invalidar todos los providers que dependen de la lista de departamentos
  ref.invalidate(departamentosProvider);
  ref.invalidate(departamentosActivosProvider);
  ref.invalidate(departamentosConFiltroProvider);
});

/// Eliminar departamento con validación de dependencias (usuarios asociados)
final eliminarDepartamentoProvider = FutureProvider.family<void, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  final exito = await isar.eliminarDepartamento(id);
  if (!exito) {
    throw Exception('No se puede eliminar el departamento: tiene usuarios asociados');
  }
  // Invalidar todos los providers que dependen de la lista
  ref.invalidate(departamentosProvider);
  ref.invalidate(departamentosActivosProvider);
  ref.invalidate(departamentosConFiltroProvider);
});