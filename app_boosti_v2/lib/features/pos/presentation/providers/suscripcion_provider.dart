// lib/features/pos/presentation/providers/suscripcion_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  try {
    return await repo.obtenerPlanes().timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        debugPrint('⚠️ [planesProvider] Timeout esperando Supabase.');
        return <PlanEntity>[];
      },
    );
  } catch (e) {
    debugPrint('⚠️ [planesProvider] Error: $e');
    return <PlanEntity>[];
  }
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

// ══════════════════════════════════════════════════════════════════
// CACHÉ DE `planActivo` (fallback ante fallo de red)
// ══════════════════════════════════════════════════════════════════

/// Clave de prefs del último `planActivo` conocido con éxito.
const kPlanActivoCacheKey = 'plan_activo_cache';

/// Valor hidratado en memoria.
///
/// Es un `bool?`: `null` = "nunca se pudo determinar". Distinguir esto de
/// `false` importa, porque `false` significa "el tenant no tiene plan".
/// Ante un fallo de red no podemos afirmar ninguna de las dos cosas.
bool? _planActivoEnMemoria;

/// Espejo SÍNCRONO de la variable anterior, para que
/// `featureFlagsProvider` (que es un `Provider`, no `FutureProvider`)
/// pueda leerlo sin volverse async.
///
/// Se hidrata dentro de `suscripcionProvider`, que ya es async: así no
/// hace falta tocar `core/bootstrap.dart` ni crear una dependencia
/// `core -> presentation`.
final planActivoCacheProvider = Provider<bool?>(
  (ref) => _planActivoEnMemoria,
);

final suscripcionProvider = FutureProvider<SuscripcionEntity?>((ref) async {
  final tenantId = ref.watch(tenantActualProvider).tenantId;
  if (tenantId == null || tenantId.isEmpty) {
    debugPrint('⚠️ [suscripcionProvider] Sin tenantId → null');
    return null;
  }

  final repo = ref.watch(suscripcionesRepositoryProvider);
  try {
    final suscripcion = await repo.obtenerSuscripcion(tenantId).timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        debugPrint('⚠️ [suscripcionProvider] Timeout esperando Supabase.');
        return null;
      },
    );

    // ✅ Éxito: persistimos el valor para los próximos arranques.
    //
    // Ojo: si `suscripcion == null` el tenant NO tiene suscripcion, que
    // es un dato real (no un fallo). Se persiste `false` y no se usa el
    // fallback.
    if (suscripcion != null) {
      _planActivoEnMemoria = suscripcion.activa;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kPlanActivoCacheKey, suscripcion.activa);
    } else {
      _planActivoEnMemoria ??= false;
    }
    return suscripcion;
  } catch (e) {
    debugPrint('⚠️ [suscripcionProvider] Error: $e');
    await _cargarCacheDesdePrefs();
    return null;
  }
});

/// Lee el cache persistido si todavía no está en memoria.
Future<void> _cargarCacheDesdePrefs() async {
  if (_planActivoEnMemoria != null) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    _planActivoEnMemoria = prefs.getBool(kPlanActivoCacheKey);
    debugPrint(
      '⚠️ [suscripcionProvider] Fetch falló. Cache de planActivo: '
      '$_planActivoEnMemoria',
    );
  } catch (e) {
    debugPrint('⚠️ [suscripcionProvider] No se pudo leer el cache: $e');
  }
}

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