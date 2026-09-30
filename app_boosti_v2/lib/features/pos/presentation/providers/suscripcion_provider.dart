// lib/features/pos/presentation/providers/suscripcion_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/plan_entity.dart';
import '../../data/Local/entities/suscripcion_entity.dart';
import '../../data/remote/suscripciones_repository.dart';
import 'tenant_provider.dart';

// ══════════════════════════════════════════════════════════════════
// REPOSITORIO
// ══════════════════════════════════════════════════════════════════

final suscripcionesRepositoryProvider = Provider<SuscripcionesRepository>(
  (ref) => SuscripcionesRepository(),
);

// ══════════════════════════════════════════════════════════════════
// PLANES DISPONIBLES (catálogo global)
// ══════════════════════════════════════════════════════════════════

/// Lista de planes disponibles (`basico`, `pro`, `corporativo`).
/// Se cachea en Isar. Cambia poco.
final planesProvider = FutureProvider<List<PlanEntity>>((ref) async {
  final repo = ref.watch(suscripcionesRepositoryProvider);
  return repo.obtenerPlanes();
});

/// Helper: obtener un plan específico por id.
final planPorIdProvider =
    FutureProvider.family<PlanEntity?, String>((ref, planId) async {
  final planes = await ref.watch(planesProvider.future);
  try {
    return planes.firstWhere((p) => p.planId == planId);
  } catch (_) {
    return null;
  }
});

// ══════════════════════════════════════════════════════════════════
// SUSCRIPCIÓN DEL TENANT ACTIVO
// ══════════════════════════════════════════════════════════════════

/// Suscripción vigente del tenant activo.
///
/// Devuelve `null` si no hay tenant o no hay suscripción.
final suscripcionProvider = FutureProvider<SuscripcionEntity?>((ref) async {
  final tenantId = ref.watch(tenantActualProvider).tenantId;
  if (tenantId == null || tenantId.isEmpty) return null;

  final repo = ref.watch(suscripcionesRepositoryProvider);
  return repo.obtenerSuscripcion(tenantId);
});

/// Notifier para forzar un refresh manual de la suscripción.
///
/// Uso desde la UI: `ref.read(suscripcionRefreshProvider.notifier).refrescar()`
final suscripcionRefreshProvider = Provider<SuscripcionRefreshNotifier>(
  (ref) => SuscripcionRefreshNotifier(ref),
);

class SuscripcionRefreshNotifier {
  final Ref ref;

  SuscripcionRefreshNotifier(this.ref);

  Future<void> refrescar() async {
    final tenantId = ref.read(tenantActualProvider).tenantId;
    if (tenantId == null || tenantId.isEmpty) {
      debugPrint('⚠️ [SuscripcionRefresh] Sin tenant activo.');
      return;
    }

    final repo = ref.read(suscripcionesRepositoryProvider);
    await repo.descargarSuscripcionDesdeSupabase(tenantId);
    ref.invalidate(suscripcionProvider);
  }
}