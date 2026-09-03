// lib/features/pos/presentation/providers/departamentos_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// ============================================================
// 1. PROVIDERS BÁSICOS
// ============================================================

final departamentosProvider = FutureProvider.family<List<DepartamentoEntity>, int?>((ref, localId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerDepartamentos(soloActivos: null, localId: localId);
});

final departamentosActivosProvider = FutureProvider.family<List<DepartamentoEntity>, int?>((ref, localId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerDepartamentos(soloActivos: true, localId: localId);
});

final departamentoPorIdProvider = FutureProvider.family<DepartamentoEntity?, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerDepartamentoPorId(id);
});

final todosDepartamentosProvider = FutureProvider<List<DepartamentoEntity>>((ref) async {
  final isar = IsarService();
  return await isar.obtenerDepartamentos(soloActivos: null);
});

// ============================================================
// 2. PROVIDER CON FILTROS AVANZADOS
// ============================================================

final departamentosConFiltroProvider = FutureProvider.family<List<DepartamentoEntity>, ({
  String query,
  String estado, // 'activos', 'inactivos', 'todos'
  int? localId,
})>((ref, params) async {
  final isar = ref.watch(isarServiceProvider);
  final todos = await isar.obtenerDepartamentos(soloActivos: null, localId: params.localId);
  List<DepartamentoEntity> filtrados = [];
  if (params.estado == 'activos') {
    filtrados = todos.where((d) => d.activo == true).toList();
  } else if (params.estado == 'inactivos') {
    filtrados = todos.where((d) => d.activo == false).toList();
  } else {
    filtrados = todos;
  }
  if (params.query.isNotEmpty) {
    final q = params.query.toLowerCase();
    filtrados = filtrados.where((d) => d.nombre.toLowerCase().contains(q)).toList();
  }
  return filtrados;
});

// ============================================================
// 3. PROVIDERS DE ACCIÓN (CON VALIDACIÓN DE DUPLICADOS Y CONTADOR)
// ============================================================

/// Guardar departamento con validación de nombre duplicado
final guardarDepartamentoProvider = FutureProvider.family<void, DepartamentoEntity>((ref, departamento) async {
  final isar = ref.watch(isarServiceProvider);
  
  // Verificar duplicado (ignorando mayúsculas)
  final todos = await isar.obtenerDepartamentos(soloActivos: null, localId: null);
  final nombreNormalizado = departamento.nombre.trim().toLowerCase();
  
  final duplicado = todos.any((d) =>
      d.id != departamento.id &&
      d.nombre.trim().toLowerCase() == nombreNormalizado
  );
  
  if (duplicado) {
    throw Exception('Ya existe un departamento con el nombre "${departamento.nombre}".');
  }
  
  await isar.guardarDepartamento(departamento);
  ref.invalidate(departamentosProvider);
  ref.invalidate(departamentosActivosProvider);
  ref.invalidate(departamentosConFiltroProvider);
  ref.invalidate(productosPorDepartamentoProvider);
});

/// Eliminar departamento (valida dependencias e invalida contador)
final eliminarDepartamentoProvider = FutureProvider.family<void, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  final exito = await isar.eliminarDepartamento(id);
  if (!exito) {
    throw Exception('No se puede eliminar el departamento: tiene usuarios asociados');
  }
  ref.invalidate(departamentosProvider);
  ref.invalidate(departamentosActivosProvider);
  ref.invalidate(departamentosConFiltroProvider);
  ref.invalidate(productosPorDepartamentoProvider);
});

// ============================================================
// 4. PROVIDER PARA CONTAR PRODUCTOS POR DEPARTAMENTO
// ============================================================

final productosPorDepartamentoProvider = FutureProvider.family<int, int>((ref, departamentoId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.contarProductosPorDepartamento(departamentoId);
});