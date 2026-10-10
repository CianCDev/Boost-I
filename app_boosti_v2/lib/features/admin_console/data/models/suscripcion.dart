/// Modelo de datos para una suscripción del Control Center.
///
/// Mapea la tabla `suscripciones` de Supabase. El `plan_id` es TEXT
/// (FK a `planes.id`) y el `tenant_id` es UUID (FK a `tenants.id`).
library;

/// Estados posibles de una suscripción según el CHECK constraint de Supabase.
enum EstadoSuscripcion {
  trial,
  activo,
  vencido,
  cancelado,
  expirado,
  desconocido;

  /// Convierte el valor TEXT de la BD en el enum correspondiente.
  /// Cualquier valor no reconocido cae en [desconocido].
  static EstadoSuscripcion fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'trial' => EstadoSuscripcion.trial,
      'activo' => EstadoSuscripcion.activo,
      'vencido' => EstadoSuscripcion.vencido,
      'cancelado' => EstadoSuscripcion.cancelado,
      'expirado' => EstadoSuscripcion.expirado,
      _ => EstadoSuscripcion.desconocido,
    };
  }

  /// Etiqueta legible para la UI.
  String get label {
    return switch (this) {
      EstadoSuscripcion.trial => 'Trial',
      EstadoSuscripcion.activo => 'Activo',
      EstadoSuscripcion.vencido => 'Vencido',
      EstadoSuscripcion.cancelado => 'Cancelado',
      EstadoSuscripcion.expirado => 'Expirado',
      EstadoSuscripcion.desconocido => 'Desconocido',
    };
  }
}

class Suscripcion {
  // ═══════════════════════════════════════════════════════════════
  // CAMPOS
  // ═══════════════════════════════════════════════════════════════
  final String id;
  final String tenantId;
  final String planId;
  final EstadoSuscripcion estado;
  final DateTime? iniciadoEn;
  final DateTime? trialVenceEn;
  final DateTime? periodoActualInicio;
  final DateTime? periodoActualFin;
  final DateTime? canceladoEn;
  final String? motivoCancelacion;
  final bool autoRenovar;
  final String? notas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ═══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════
  const Suscripcion({
    required this.id,
    required this.tenantId,
    required this.planId,
    required this.estado,
    this.iniciadoEn,
    this.trialVenceEn,
    this.periodoActualInicio,
    this.periodoActualFin,
    this.canceladoEn,
    this.motivoCancelacion,
    required this.autoRenovar,
    this.notas,
    this.createdAt,
    this.updatedAt,
  });

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  /// Días restantes hasta el vencimiento del trial.
  /// Negativo si ya venció, `null` si no hay trial.
  int? get diasRestantesTrial {
    if (trialVenceEn == null) return null;
    return trialVenceEn!.difference(DateTime.now()).inDays;
  }

  /// `true` si el trial vence dentro de los próximos 3 días.
  bool get trialPorVencer {
    final dias = diasRestantesTrial;
    return dias != null && dias >= 0 && dias <= 3;
  }

  /// `true` si la suscripción está en un estado que impide operar.
  bool get estaBloqueado =>
      estado == EstadoSuscripcion.cancelado ||
      estado == EstadoSuscripcion.expirado ||
      estado == EstadoSuscripcion.vencido;

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════
  factory Suscripcion.fromMap(Map<String, dynamic> map) {
    return Suscripcion(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      planId: map['plan_id'] as String,
      estado: EstadoSuscripcion.fromString(map['estado'] as String?),
      iniciadoEn: _fecha(map['iniciado_en']),
      trialVenceEn: _fecha(map['trial_vence_en']),
      periodoActualInicio: _fecha(map['periodo_actual_inicio']),
      periodoActualFin: _fecha(map['periodo_actual_fin']),
      canceladoEn: _fecha(map['cancelado_en']),
      motivoCancelacion: map['motivo_cancelacion'] as String?,
      autoRenovar: map['auto_renovar'] as bool? ?? true,
      notas: map['notas'] as String?,
      createdAt: _fecha(map['created_at']),
      updatedAt: _fecha(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'plan_id': planId,
      'estado': estado.name,
      'iniciado_en': iniciadoEn?.toIso8601String(),
      'trial_vence_en': trialVenceEn?.toIso8601String(),
      'periodo_actual_inicio': periodoActualInicio?.toIso8601String(),
      'periodo_actual_fin': periodoActualFin?.toIso8601String(),
      'cancelado_en': canceladoEn?.toIso8601String(),
      'motivo_cancelacion': motivoCancelacion,
      'auto_renovar': autoRenovar,
      'notas': notas,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Suscripcion copyWith({
    String? id,
    String? tenantId,
    String? planId,
    EstadoSuscripcion? estado,
    DateTime? iniciadoEn,
    DateTime? trialVenceEn,
    DateTime? periodoActualInicio,
    DateTime? periodoActualFin,
    DateTime? canceladoEn,
    String? motivoCancelacion,
    bool? autoRenovar,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Suscripcion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      planId: planId ?? this.planId,
      estado: estado ?? this.estado,
      iniciadoEn: iniciadoEn ?? this.iniciadoEn,
      trialVenceEn: trialVenceEn ?? this.trialVenceEn,
      periodoActualInicio: periodoActualInicio ?? this.periodoActualInicio,
      periodoActualFin: periodoActualFin ?? this.periodoActualFin,
      canceladoEn: canceladoEn ?? this.canceladoEn,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      autoRenovar: autoRenovar ?? this.autoRenovar,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════
  static DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }
}
