import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plan.dart';
import '../models/suscripcion.dart';
import '../models/tenant.dart';

/// Repositorio de suscripciones del Control Center.
///
/// Mapea la tabla `suscripciones` y escribe en `suscripcion_historial`
/// para dejar trazabilidad de cada cambio de plan, trial o estado.
///
/// Las foreign keys `tenant_id → tenants.id` y `plan_id → planes.id` están
/// declaradas en Supabase, así que los listados usan embeds con
/// `!inner(*)` para traer tenant + plan en un solo viaje.
class SubscriptionsRepository {
  /// Se resuelve en cada llamada para no capturar el cliente antes de
  /// que `Supabase.initialize()` se haya ejecutado.
  SupabaseClient get _client => Supabase.instance.client;

  /// Columnas base + embeds inner de tenant y plan.
  static const String _selectConJoin = '*, tenants!inner(*), planes!inner(*)';

  // ═══════════════════════════════════════════════════════════════
  // LISTADOS CON INFORMACIÓN CRUZADA
  // ═══════════════════════════════════════════════════════════════

  /// Trials que vencen dentro de los próximos [dias] días.
  ///
  /// Cada item trae: 'tenant', 'suscripcion', 'plan' y
  /// 'diasHastaVencimiento' (días hasta `trial_vence_en`).
  Future<List<Map<String, dynamic>>> trialsPorVencer({int dias = 3}) async {
    try {
      final ahora = DateTime.now();
      final limite = ahora.add(Duration(days: dias));

      final response = await _client
          .from('suscripciones')
          .select(_selectConJoin)
          .eq('estado', 'trial')
          .gte('trial_vence_en', ahora.toIso8601String())
          .lte('trial_vence_en', limite.toIso8601String())
          .order('trial_vence_en', ascending: true);

      return response
          .map(
            (row) => _armarTrial(
              row,
              _diasHasta(_fechaDe(row['trial_vence_en'])),
            ),
          )
          .toList();
    } catch (e, stack) {
      debugPrint('[SubscriptionsRepository] Error en trialsPorVencer: $e');
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      return [];
    }
  }

  /// Suscripciones `activo` cuyo tenant no registra login reciente.
  ///
  /// Se considera en riesgo cuando la actividad más reciente de
  /// **cualquier** usuario del tenant es anterior a [diasInactivo] días.
  /// Un tenant sin usuarios (o sin `ultima_actividad`) también cuenta.
  ///
  /// Cada item trae: 'tenant', 'suscripcion', 'plan' y 'diasInactivo'
  /// (días **transcurridos sin login**, no días hasta vencer).
  Future<List<Map<String, dynamic>>> clientesEnRiesgo({
    int diasInactivo = 15,
  }) async {
    try {
      // 1) Suscripciones activas con su tenant y plan.
      final suscripciones = await _client
          .from('suscripciones')
          .select(_selectConJoin)
          .eq('estado', 'activo');

      if (suscripciones.isEmpty) return [];

      // 2) Última actividad por tenant, para no contar de más cuando un
      //    tenant tiene varios usuarios.
      final tenantIds =
          suscripciones.map((r) => r['tenant_id'] as String).toSet().toList();

      final usuarios = await _client
          .from('usuarios')
          .select('tenant_id, ultima_actividad')
          .inFilter('tenant_id', tenantIds);

      final ultimaActividad = <String, DateTime>{};
      for (final u in usuarios) {
        final tenantId = u['tenant_id'] as String?;
        final fecha = _fechaDe(u['ultima_actividad']);
        if (tenantId == null || fecha == null) continue;
        final previa = ultimaActividad[tenantId];
        if (previa == null || fecha.isAfter(previa)) {
          ultimaActividad[tenantId] = fecha;
        }
      }

      // 3) Filtrar en Dart: sin actividad reciente → en riesgo.
      final ahora = DateTime.now();
      final items = <Map<String, dynamic>>[];

      for (final row in suscripciones) {
        final tenantId = row['tenant_id'] as String;
        final ultima = ultimaActividad[tenantId];
        final dias = ultima == null
            ? diasInactivo
            : ahora.difference(ultima).inDays;

        if (dias >= diasInactivo) {
          items.add(_armarRiesgo(row, dias));
        }
      }

      // Mayor inactividad primero.
      items.sort(
        (a, b) =>
            (b['diasInactivo'] as int).compareTo(a['diasInactivo'] as int),
      );

      return items;
    } catch (e, stack) {
      debugPrint('[SubscriptionsRepository] Error en clientesEnRiesgo: $e');
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      return [];
    }
  }

  /// Suscripciones canceladas en los últimos [dias] días.
  ///
  /// Cada item trae: 'tenant', 'suscripcion', 'plan' y
  /// 'diasDesdeCancelacion' (días transcurridos desde `cancelado_en`).
  Future<List<Map<String, dynamic>>> cancelacionesRecientes({
    int dias = 30,
  }) async {
    try {
      final desde = DateTime.now().subtract(Duration(days: dias));

      final response = await _client
          .from('suscripciones')
          .select(_selectConJoin)
          .eq('estado', 'cancelado')
          .gte('cancelado_en', desde.toIso8601String())
          .order('cancelado_en', ascending: false);

      return response
          .map(
            (row) => _armarCancelacion(
              row,
              _diasDesde(_fechaDe(row['cancelado_en'])),
            ),
          )
          .toList();
    } catch (e, stack) {
      debugPrint(
        '[SubscriptionsRepository] Error en cancelacionesRecientes: $e',
      );
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LECTURA
  // ═══════════════════════════════════════════════════════════════

  /// Obtiene la suscripción de un tenant. `null` si no tiene ninguna.
  Future<Suscripcion?> obtenerPorTenant(String tenantId) async {
    try {
      final response = await _client
          .from('suscripciones')
          .select('*')
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('[SubscriptionsRepository] Sin suscripción para $tenantId');
        return null;
      }

      return Suscripcion.fromMap(response);
    } catch (e, stack) {
      debugPrint(
        '[SubscriptionsRepository] Error obteniendo suscripción '
        'de $tenantId: $e',
      );
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ESCRITURA
  // ═══════════════════════════════════════════════════════════════

  /// Inserta un registro en `suscripcion_historial`.
  ///
  /// Lanza [Exception] si falla.
  Future<void> registrarEnHistorial({
    required String suscripcionId,
    required String tipoCambio,
    String? planOrigenId,
    String? planDestinoId,
    String? estadoOrigen,
    String? estadoDestino,
    required String? cambiadoPor,
    String? notas,
  }) async {
    try {
      await _client.from('suscripcion_historial').insert({
        'suscripcion_id': suscripcionId,
        'tipo_cambio': tipoCambio,
        'plan_origen_id': planOrigenId,
        'plan_destino_id': planDestinoId,
        'estado_origen': estadoOrigen,
        'estado_destino': estadoDestino,
        'cambiado_por': cambiadoPor,
        'notas': notas,
      });

      debugPrint('[SubscriptionsRepository] Historial: $tipoCambio');
    } catch (e, stack) {
      debugPrint('[SubscriptionsRepository] Error registrando historial: $e');
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo registrar el historial: $e'),
        stack,
      );
    }
  }

  /// Cambia el plan de un tenant y deja traza en el historial.
  ///
  /// Lanza [Exception] si el tenant no tiene suscripción, si el update
  /// falla, o si falla la escritura del historial.
  Future<void> actualizarPlan({
    required String tenantId,
    required String nuevoPlanId,
    required String? cambiadoPor,
    String? notas,
  }) async {
    final actual = await obtenerPorTenant(tenantId);
    if (actual == null) {
      debugPrint(
        '[SubscriptionsRepository] No se puede actualizar plan: '
        '$tenantId sin suscripción',
      );
      throw Exception('El tenant $tenantId no tiene suscripción');
    }

    try {
      final response = await _client
          .from('suscripciones')
          .update({'plan_id': nuevoPlanId, 'updated_at': _ahoraIso()})
          .eq('id', actual.id)
          .select('id');

      if (response.isEmpty) {
        debugPrint(
          '[SubscriptionsRepository] actualizarPlan: 0 filas afectadas',
        );
        throw Exception('La suscripción ${actual.id} no se pudo actualizar');
      }

      await registrarEnHistorial(
        suscripcionId: actual.id,
        tipoCambio: 'plan_actualizado',
        planOrigenId: actual.planId,
        planDestinoId: nuevoPlanId,
        estadoOrigen: actual.estado.name,
        estadoDestino: actual.estado.name,
        cambiadoPor: cambiadoPor,
        notas: notas,
      );

      debugPrint(
        '[SubscriptionsRepository] Plan de $tenantId: '
        '${actual.planId} → $nuevoPlanId',
      );
    } catch (e, stack) {
      debugPrint('[SubscriptionsRepository] Error actualizando plan: $e');
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo actualizar el plan: $e'),
        stack,
      );
    }
  }

  /// Extiende el trial [dias] días, sumando a `trial_vence_en` actual o,
  /// si es `null`, a la fecha de hoy.
  ///
  /// No es idempotente: si falla el historial **después** del update, el
  /// trial ya quedó extendido y un reintento sumaría los días dos veces.
  ///
  /// Lanza [Exception] si falla.
  Future<void> extenderTrial({
    required String tenantId,
    required int dias,
    required String? cambiadoPor,
  }) async {
    final actual = await obtenerPorTenant(tenantId);
    if (actual == null) {
      debugPrint(
        '[SubscriptionsRepository] No se puede extender trial: '
        '$tenantId sin suscripción',
      );
      throw Exception('El tenant $tenantId no tiene suscripción');
    }

    try {
      final base = actual.trialVenceEn ?? DateTime.now();
      final nuevaFecha = base.add(Duration(days: dias));

      final response = await _client
          .from('suscripciones')
          .update({
            'trial_vence_en': nuevaFecha.toIso8601String(),
            'updated_at': _ahoraIso(),
          })
          .eq('id', actual.id)
          .select('id');

      if (response.isEmpty) {
        debugPrint(
          '[SubscriptionsRepository] extenderTrial: 0 filas afectadas',
        );
        throw Exception('La suscripción ${actual.id} no se pudo actualizar');
      }

      await registrarEnHistorial(
        suscripcionId: actual.id,
        tipoCambio: 'trial_extendido',
        planOrigenId: actual.planId,
        planDestinoId: actual.planId,
        estadoOrigen: actual.estado.name,
        estadoDestino: actual.estado.name,
        cambiadoPor: cambiadoPor,
        notas: 'Trial extendido $dias días',
      );

      debugPrint(
        '[SubscriptionsRepository] Trial de $tenantId extendido $dias días',
      );
    } catch (e, stack) {
      debugPrint('[SubscriptionsRepository] Error extendiendo trial: $e');
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo extender el trial: $e'),
        stack,
      );
    }
  }

  /// Marca la suscripción como `cancelado` y deja traza en el historial.
  ///
  /// Lanza [Exception] si falla.
  Future<void> cancelar({
    required String tenantId,
    required String motivo,
    required String? canceladoPor,
  }) async {
    final actual = await obtenerPorTenant(tenantId);
    if (actual == null) {
      debugPrint(
        '[SubscriptionsRepository] No se puede cancelar: '
        '$tenantId sin suscripción',
      );
      throw Exception('El tenant $tenantId no tiene suscripción');
    }

    try {
      final ahoraIso = _ahoraIso();
      final response = await _client
          .from('suscripciones')
          .update({
            'estado': 'cancelado',
            'cancelado_en': ahoraIso,
            'motivo_cancelacion': motivo,
            'cancelado_por': canceladoPor,
            'auto_renovar': false,
            'updated_at': ahoraIso,
          })
          .eq('id', actual.id)
          .select('id');

      if (response.isEmpty) {
        debugPrint('[SubscriptionsRepository] cancelar: 0 filas afectadas');
        throw Exception('La suscripción ${actual.id} no se pudo actualizar');
      }

      await registrarEnHistorial(
        suscripcionId: actual.id,
        tipoCambio: 'suscripcion_cancelada',
        planOrigenId: actual.planId,
        planDestinoId: actual.planId,
        estadoOrigen: actual.estado.name,
        estadoDestino: 'cancelado',
        cambiadoPor: canceladoPor,
        notas: motivo,
      );

      debugPrint(
        '[SubscriptionsRepository] Suscripción de $tenantId cancelada',
      );
    } catch (e, stack) {
      debugPrint('[SubscriptionsRepository] Error cancelando: $e');
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo cancelar la suscripción: $e'),
        stack,
      );
    }
  }

  /// Reactiva una suscripción `cancelado`/`expirado`/`vencido`: pasa a
  /// `activo`, limpia los campos de cancelación y abre un período de
  /// 30 días desde hoy.
  ///
  /// Lanza [Exception] si falla.
  Future<void> reactivar({
    required String tenantId,
    required String? cambiadoPor,
  }) async {
    final actual = await obtenerPorTenant(tenantId);
    if (actual == null) {
      debugPrint(
        '[SubscriptionsRepository] No se puede reactivar: '
        '$tenantId sin suscripción',
      );
      throw Exception('El tenant $tenantId no tiene suscripción');
    }

    try {
      final ahora = DateTime.now();
      final response = await _client
          .from('suscripciones')
          .update({
            'estado': 'activo',
            'cancelado_en': null,
            'motivo_cancelacion': null,
            'cancelado_por': null,
            'auto_renovar': true,
            'periodo_actual_inicio': ahora.toIso8601String(),
            'periodo_actual_fin':
                ahora.add(const Duration(days: 30)).toIso8601String(),
            'updated_at': _ahoraIso(),
          })
          .eq('id', actual.id)
          .select('id');

      if (response.isEmpty) {
        debugPrint('[SubscriptionsRepository] reactivar: 0 filas afectadas');
        throw Exception('La suscripción ${actual.id} no se pudo actualizar');
      }

      await registrarEnHistorial(
        suscripcionId: actual.id,
        tipoCambio: 'suscripcion_reactivada',
        planOrigenId: actual.planId,
        planDestinoId: actual.planId,
        estadoOrigen: actual.estado.name,
        estadoDestino: 'activo',
        cambiadoPor: cambiadoPor,
        // Nota explícita: reactivar siempre reactiva **directo a activo
        // con 30 días**, nunca como trial de gracia. Así no se puede
        // obtener un trial nuevo repetidas veces cancelando y
        // reactivando.
        notas: 'Reactivación directa a activo (30 días)',
      );

      debugPrint(
        '[SubscriptionsRepository] Suscripción de $tenantId reactivada',
      );
    } catch (e, stack) {
      debugPrint('[SubscriptionsRepository] Error reactivando: $e');
      debugPrint('[SubscriptionsRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo reactivar la suscripción: $e'),
        stack,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════
  // HELPERS PRIVADOS
  // ═══════════════════════════════════════════════════════════════

  /// Item de trial por vencer.
  ///
  /// Usa `!inner(*)`, por lo que 'tenants' y 'planes' nunca llegan null.
  Map<String, dynamic> _armarTrial(
    Map<String, dynamic> row,
    int diasHastaVencimiento,
  ) {
    return {
      'tenant': Tenant.fromMap(row['tenants'] as Map<String, dynamic>),
      'suscripcion': Suscripcion.fromMap(row),
      'plan': Plan.fromMap(row['planes'] as Map<String, dynamic>),
      'diasHastaVencimiento': diasHastaVencimiento,
    };
  }

  /// Item de cliente en riesgo.
  ///
  /// Usa `!inner(*)`, por lo que 'tenants' y 'planes' nunca llegan null.
  Map<String, dynamic> _armarRiesgo(
    Map<String, dynamic> row,
    int diasInactivo,
  ) {
    return {
      'tenant': Tenant.fromMap(row['tenants'] as Map<String, dynamic>),
      'suscripcion': Suscripcion.fromMap(row),
      'plan': Plan.fromMap(row['planes'] as Map<String, dynamic>),
      'diasInactivo': diasInactivo,
    };
  }

  /// Item de cancelación reciente.
  ///
  /// Usa `!inner(*)`, por lo que 'tenants' y 'planes' nunca llegan null.
  Map<String, dynamic> _armarCancelacion(
    Map<String, dynamic> row,
    int diasDesdeCancelacion,
  ) {
    return {
      'tenant': Tenant.fromMap(row['tenants'] as Map<String, dynamic>),
      'suscripcion': Suscripcion.fromMap(row),
      'plan': Plan.fromMap(row['planes'] as Map<String, dynamic>),
      'diasDesdeCancelacion': diasDesdeCancelacion,
    };
  }

  /// Días restantes hasta [fin] (negativo si ya pasó).
  int _diasHasta(DateTime? fin) {
    if (fin == null) return 0;
    return fin.difference(DateTime.now()).inDays;
  }

  /// Días transcurridos desde [momento].
  int _diasDesde(DateTime? momento) {
    if (momento == null) return 0;
    return DateTime.now().difference(momento).inDays;
  }

  /// Parseo tolerante de TIMESTAMPTZ.
  DateTime? _fechaDe(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }

  String _ahoraIso() => DateTime.now().toIso8601String();
}
