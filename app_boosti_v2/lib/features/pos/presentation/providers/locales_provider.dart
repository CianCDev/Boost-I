import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import '../services/sync_service.dart';


final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// Provider para obtener todos los locales
final localesProvider = FutureProvider<List<LocalEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerLocales(soloActivos: true);
});

// Provider para obtener un local por ID
final localPorIdProvider = FutureProvider.family<LocalEntity?, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerLocalPorId(id);
});

// Provider para guardar un local
final guardarLocalProvider = FutureProvider.family<void, LocalEntity>((ref, local) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.guardarLocal(local);
  ref.invalidate(localesProvider);
});

// Provider para eliminar un local
final eliminarLocalProvider = FutureProvider.family<void, int>((ref, id) async {
  final isar = ref.watch(isarServiceProvider);
  final local = await isar.obtenerLocalPorId(id);
  if (local == null) throw Exception('Local no encontrado');
  
  // 1. Eliminar de Supabase si tiene supabaseId
  if (local.supabaseId != null && local.supabaseId!.isNotEmpty) {
    final syncService = SyncService();
    await syncService.eliminarLocalEnSupabase(local.supabaseId!);
  }
  
  // 2. Eliminar de Isar (ya existe)
  final exito = await isar.eliminarLocal(id);
  if (!exito) {
    throw Exception('No se puede eliminar: tiene pedidos asociados');
  }
  
  ref.invalidate(localesProvider);
});