import 'dart:convert';
import 'package:isar/isar.dart';

part 'suscripcion_entity.g.dart';

/// Caché local de la suscripción del tenant activo.
///
/// Solo hay UNA suscripción por tenant. Se consulta al inicio y se
/// mantiene sincronizada con Supabase (Realtime + refresh periódico).
@collection
class SuscripcionEntity {
  // 🎯 Constructor por defecto requerido por Dart e Isar al usar factories
  SuscripcionEntity();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String tenantId;                  // UUID del local

  late String planId;                    // 'basico' | 'pro' | 'corporativo'
  late String estado;                    // 'trial' | 'activa' | 'suspendida' | ...

  DateTime? trialHasta;
  DateTime? periodoInicio;
  DateTime? periodoFin;

  /// Addons contratados (jsonb → string JSON).
  String addonsActivosJson = '{}';

  DateTime? verificadoEn;                // última consulta a Supabase
  DateTime? updatedAt;

  // ── Helpers ──

  /// ¿La suscripción está vigente hoy?
  ///
  /// 🔴 COMPARACIÓN NORMALIZADA (2026-10-15)
  ///
  /// Este getter comparaba solo contra `'activa'` (femenino), pero el
  /// valor que hay en `suscripciones.estado` es **`'activo'`**
  /// (masculino). No es una fila mal puesta: es lo que escriben la
  /// Edge Function (`create-tenant/index.ts:370` → `"trial"`), lo que
  /// documenta la migración `20261015000002` y lo que se insertó a mano
  /// para dar de alta a JAHTLABS y al tenant del centro.
  ///
  /// El síntoma era invisible y total: `estado = 'activo'` caía en el
  /// `return false` de la última línea, `planActivo` quedaba `false` y
  /// `FeatureFlags._plan()` cortaba en el primer `&&`, así que el menú
  /// perdía los ~8 módulos con gate (dashboard, historial, gastos,
  /// proveedores, locales, departamentos, pedidos) con un tenant
  /// perfectamente pagado.
  ///
  /// Se aceptan ambas grafías y se normaliza el case: el enum no tiene
  /// CHECK en la BD, así que nada garantiza que no llegue `Activa`.
  bool get activa {
    final estadoNormalizado = estado.trim().toLowerCase();
    if (estadoNormalizado == 'activa' || estadoNormalizado == 'activo') {
      return periodoFin == null || periodoFin!.isAfter(DateTime.now());
    }
    if (estadoNormalizado == 'trial') {
      return trialHasta == null || trialHasta!.isAfter(DateTime.now());
    }
    return false;
  }
  
@ignore
  Map<String, dynamic> get addonsMap {
    try {
      return jsonDecode(addonsActivosJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  factory SuscripcionEntity.fromSupabase(Map<String, dynamic> json) {
    return SuscripcionEntity()
      ..tenantId = json['tenant_id'] as String
      ..planId = json['plan_id'] as String
      ..estado = json['estado'] as String? ?? 'trial'
      ..trialHasta = json['trial_hasta'] != null
          ? DateTime.tryParse(json['trial_hasta'].toString())
          : null
      ..periodoInicio = json['periodo_inicio'] != null
          ? DateTime.tryParse(json['periodo_inicio'].toString())
          : null
      ..periodoFin = json['periodo_fin'] != null
          ? DateTime.tryParse(json['periodo_fin'].toString())
          : null
      ..addonsActivosJson = jsonEncode(json['addons_activos'] ?? {})
      ..updatedAt = json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null;
  }
}