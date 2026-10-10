/// Modelo de datos para las métricas SaaS del Control Center.
///
/// Mapea la vista materializada `saas_metrics` de Supabase, que
/// siempre devuelve una única fila con los agregados calculados.
class SaasMetrics {
  // ═══════════════════════════════════════════════════════════════
  // CAMPOS
  // ═══════════════════════════════════════════════════════════════
  final int trialsActivos;
  final int clientesActivos;
  final int cancelaciones30d;
  final int trialsPorVencer3d;
  final int trialsPorVencer7d;
  final double mrr;
  final double arr;
  final DateTime calculatedAt;

  // ═══════════════════════════════════════════════════════════════
  // CONSTRUCTORES
  // ═══════════════════════════════════════════════════════════════
  const SaasMetrics({
    required this.trialsActivos,
    required this.clientesActivos,
    required this.cancelaciones30d,
    required this.trialsPorVencer3d,
    required this.trialsPorVencer7d,
    required this.mrr,
    required this.arr,
    required this.calculatedAt,
  });

  /// Estado inicial "en blanco" para cuando aún no se han cargado datos.
  ///
  /// Es un `factory` (no `const`) porque `DateTime.now()` no es una
  /// constante válida en tiempo de compilación.
  factory SaasMetrics.empty() {
    return SaasMetrics(
      trialsActivos: 0,
      clientesActivos: 0,
      cancelaciones30d: 0,
      trialsPorVencer3d: 0,
      trialsPorVencer7d: 0,
      mrr: 0,
      arr: 0,
      calculatedAt: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  String get mrrFormateado => '\$${mrr.toStringAsFixed(0)}';

  String get arrFormateado => '\$${arr.toStringAsFixed(0)}';

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════
  factory SaasMetrics.fromMap(Map<String, dynamic> map) {
    return SaasMetrics(
      trialsActivos: (map['trials_activos'] as num?)?.toInt() ?? 0,
      clientesActivos: (map['clientes_activos'] as num?)?.toInt() ?? 0,
      cancelaciones30d: (map['cancelaciones_30d'] as num?)?.toInt() ?? 0,
      trialsPorVencer3d: (map['trials_por_vencer_3d'] as num?)?.toInt() ?? 0,
      trialsPorVencer7d: (map['trials_por_vencer_7d'] as num?)?.toInt() ?? 0,
      mrr: (map['mrr'] as num?)?.toDouble() ?? 0,
      arr: (map['arr'] as num?)?.toDouble() ?? 0,
      calculatedAt: _fecha(map['calculated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trials_activos': trialsActivos,
      'clientes_activos': clientesActivos,
      'cancelaciones_30d': cancelaciones30d,
      'trials_por_vencer_3d': trialsPorVencer3d,
      'trials_por_vencer_7d': trialsPorVencer7d,
      'mrr': mrr,
      'arr': arr,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  SaasMetrics copyWith({
    int? trialsActivos,
    int? clientesActivos,
    int? cancelaciones30d,
    int? trialsPorVencer3d,
    int? trialsPorVencer7d,
    double? mrr,
    double? arr,
    DateTime? calculatedAt,
  }) {
    return SaasMetrics(
      trialsActivos: trialsActivos ?? this.trialsActivos,
      clientesActivos: clientesActivos ?? this.clientesActivos,
      cancelaciones30d: cancelaciones30d ?? this.cancelaciones30d,
      trialsPorVencer3d: trialsPorVencer3d ?? this.trialsPorVencer3d,
      trialsPorVencer7d: trialsPorVencer7d ?? this.trialsPorVencer7d,
      mrr: mrr ?? this.mrr,
      arr: arr ?? this.arr,
      calculatedAt: calculatedAt ?? this.calculatedAt,
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
