import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'local_actual_provider.dart';
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

/// UUID (`supabaseId`) del local actual, o `null` si todavía no se resolvió.
///
/// Traduce el `int?` de `localActualProvider` al UUID que exigen los
/// providers indexados por local, como `pedidosListProvider`.
///
/// ## Por qué vive acá y no en `local_actual_provider.dart`
/// `local_actual_provider.dart` YA importa `pedidos_provider.dart` (en su
/// paso 4 del hot-switch invalida `pedidosListProvider`). Agregarle
/// providers que lo consulten desde `pedidos_provider` cerraría un
/// criss-cross de imports. Este archivo no participa de ese ciclo.
///
/// `null` es un estado válido de carga: el `id` puede estar resuelto y el
/// `supabaseId` del local todavía no. Los callers deben tratarlo como
/// "aún no sé", no como "no hay local".
final localActualUuidProvider = FutureProvider<String?>((ref) async {
  final localId = ref.watch(localActualProvider);
  if (localId == null) return null;
  final local = await ref.watch(localPorIdProvider(localId).future);
  return local?.supabaseId;
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