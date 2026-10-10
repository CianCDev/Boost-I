/// Modelo de datos para un pago del Control Center.
///
/// Mapea la tabla `pagos` de Supabase.
library;

/// Estados posibles de un pago según el CHECK constraint de Supabase.
enum EstadoPago {
  pendiente,
  pagado,
  fallido,
  reembolsado,
  desconocido;

  /// Convierte el valor TEXT de la BD en el enum correspondiente.
  /// Cualquier valor no reconocido cae en [desconocido].
  static EstadoPago fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'pendiente' => EstadoPago.pendiente,
      'pagado' => EstadoPago.pagado,
      'fallido' => EstadoPago.fallido,
      'reembolsado' => EstadoPago.reembolsado,
      _ => EstadoPago.desconocido,
    };
  }

  /// Etiqueta legible para la UI.
  String get label {
    return switch (this) {
      EstadoPago.pendiente => 'Pendiente',
      EstadoPago.pagado => 'Pagado',
      EstadoPago.fallido => 'Fallido',
      EstadoPago.reembolsado => 'Reembolsado',
      EstadoPago.desconocido => 'Desconocido',
    };
  }
}

class Payment {
  // ═══════════════════════════════════════════════════════════════
  // CAMPOS
  // ═══════════════════════════════════════════════════════════════
  final String id;
  final String tenantId;
  final String? suscripcionId;
  final double monto;
  final String moneda;
  final EstadoPago estado;
  final String? metodo;
  final String? referencia;
  final DateTime? pagadoEn;
  final DateTime? periodoInicio;
  final DateTime? periodoFin;
  final String? notas;
  final String? registradoPor;

  /// Factor multiplicativo de [monedaOriginal] a USD al momento del pago.
  ///
  /// Invariante: `monto == montoOriginal * tasaConversion`.
  ///
  /// `1.0` para USD, `1 / tasaBs` para la moneda local y
  /// `tasaEuro / tasaBs` para EUR. Es `null` en los pagos anteriores a
  /// la Subfase 5.3.
  final double? tasaConversion;

  /// Monto tal como lo ingresó el usuario, expresado en
  /// [monedaOriginal].
  final double? montoOriginal;

  /// Moneda tal como la eligió el usuario (USD / EUR / VES...).
  final String? monedaOriginal;

  final DateTime createdAt;

  // ═══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════
  const Payment({
    required this.id,
    required this.tenantId,
    this.suscripcionId,
    required this.monto,
    required this.moneda,
    required this.estado,
    this.metodo,
    this.referencia,
    this.pagadoEn,
    this.periodoInicio,
    this.periodoFin,
    this.notas,
    this.registradoPor,
    this.tasaConversion,
    this.montoOriginal,
    this.monedaOriginal,
    required this.createdAt,
  });

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  String get montoFormateado => '\$${monto.toStringAsFixed(2)}';

  bool get estaPagado => estado == EstadoPago.pagado;

  /// Pago anterior a la Subfase 5.3: no guarda tasa de conversión y su
  /// [moneda] no es la moneda normalizada.
  bool get esLegacy => tasaConversion == null && moneda != 'USD';

  /// `true` si el pago se ingresó en una moneda distinta a la
  /// normalizada, así que hay que mostrar también el monto original.
  bool get tieneConversion =>
      monedaOriginal != null && monedaOriginal != moneda;

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      suscripcionId: map['suscripcion_id'] as String?,
      monto: (map['monto'] as num?)?.toDouble() ?? 0,
      moneda: map['moneda'] as String? ?? 'USD',
      estado: EstadoPago.fromString(map['estado'] as String?),
      metodo: map['metodo'] as String?,
      referencia: map['referencia'] as String?,
      pagadoEn: _fecha(map['pagado_en']),
      periodoInicio: _fecha(map['periodo_inicio']),
      periodoFin: _fecha(map['periodo_fin']),
      notas: map['notas'] as String?,
      registradoPor: map['registrado_por'] as String?,
      tasaConversion: _doble(map['tasa_conversion']),
      montoOriginal: _doble(map['monto_original']),
      monedaOriginal: map['moneda_original'] as String?,
      // Fallback defensivo: epoch si la fila viniera sin `created_at`.
      createdAt:
          _fecha(map['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'suscripcion_id': suscripcionId,
      'monto': monto,
      'moneda': moneda,
      'estado': estado.name,
      'metodo': metodo,
      'referencia': referencia,
      'pagado_en': pagadoEn?.toIso8601String(),
      'periodo_inicio': periodoInicio?.toIso8601String(),
      'periodo_fin': periodoFin?.toIso8601String(),
      'notas': notas,
      'registrado_por': registradoPor,
      'tasa_conversion': tasaConversion,
      'monto_original': montoOriginal,
      'moneda_original': monedaOriginal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Payment copyWith({
    String? id,
    String? tenantId,
    String? suscripcionId,
    double? monto,
    String? moneda,
    EstadoPago? estado,
    String? metodo,
    String? referencia,
    DateTime? pagadoEn,
    DateTime? periodoInicio,
    DateTime? periodoFin,
    String? notas,
    String? registradoPor,
    double? tasaConversion,
    double? montoOriginal,
    String? monedaOriginal,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      suscripcionId: suscripcionId ?? this.suscripcionId,
      monto: monto ?? this.monto,
      moneda: moneda ?? this.moneda,
      estado: estado ?? this.estado,
      metodo: metodo ?? this.metodo,
      referencia: referencia ?? this.referencia,
      pagadoEn: pagadoEn ?? this.pagadoEn,
      periodoInicio: periodoInicio ?? this.periodoInicio,
      periodoFin: periodoFin ?? this.periodoFin,
      notas: notas ?? this.notas,
      registradoPor: registradoPor ?? this.registradoPor,
      tasaConversion: tasaConversion ?? this.tasaConversion,
      montoOriginal: montoOriginal ?? this.montoOriginal,
      monedaOriginal: monedaOriginal ?? this.monedaOriginal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════
  static DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }

  /// NUMERIC puede llegar como `num` o como `String` según cómo lo
  /// serialice la capa de JSON, así que se aceptan ambas formas.
  static double? _doble(dynamic valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString());
  }
}
