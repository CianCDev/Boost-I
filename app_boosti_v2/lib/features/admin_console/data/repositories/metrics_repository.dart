import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/saas_metrics.dart';

/// Repositorio de métricas SaaS del Control Center.
///
/// Única capa que habla con Supabase para leer y refrescar la vista
/// materializada `saas_metrics`, que expone los agregados del negocio
/// (MRR, ARR, trials activos, clientes activos, cancelaciones).
class MetricsRepository {
  /// Se resuelve en cada llamada (y no como campo final) para no capturar
  /// el cliente antes de que `Supabase.initialize()` se haya ejecutado.
  SupabaseClient get _client => Supabase.instance.client;

  // ═══════════════════════════════════════════════════════════════
  // LECTURA
  // ═══════════════════════════════════════════════════════════════

  /// Obtiene la fila única de la vista materializada `saas_metrics`.
  ///
  /// Si la vista está vacía (nunca se refrescó) devuelve [SaasMetrics.empty].
  Future<SaasMetrics> obtenerMetricas() async {
    try {
      final response =
          await _client.from('saas_metrics').select().maybeSingle();

      if (response == null) {
        debugPrint(
          '[MetricsRepository] saas_metrics sin datos: '
          'la vista nunca fue refrescada',
        );
        return SaasMetrics.empty();
      }

      return SaasMetrics.fromMap(response);
    } catch (e, stack) {
      debugPrint('[MetricsRepository] Error obteniendo métricas: $e');
      debugPrint('[MetricsRepository] Stack: $stack');
      return SaasMetrics.empty();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ESCRITURA
  // ═══════════════════════════════════════════════════════════════

  /// Llama a la función RPC `refresh_saas_metrics()` para recalcular la vista.
  ///
  /// Lanza [Exception] si falla, para que el provider decida cómo manejarlo.
  Future<void> refrescarMetricas() async {
    try {
      await _client.rpc<void>('refresh_saas_metrics');
      debugPrint('[MetricsRepository] Métricas refrescadas correctamente');
    } catch (e, stack) {
      debugPrint('[MetricsRepository] Error refrescando métricas: $e');
      Error.throwWithStackTrace(
        Exception('No se pudieron refrescar las métricas: $e'),
        stack,
      );
    }
  }
}
