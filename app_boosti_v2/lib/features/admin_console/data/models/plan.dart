/// Modelo de datos para un plan comercial del Control Center.
///
/// Mapea la tabla `planes` de Supabase. El `id` es TEXT (no UUID):
/// 'trial' | 'basico' | 'pro' | 'corporativo'.
class Plan {
  // ═══════════════════════════════════════════════════════════════
  // CAMPOS
  // ═══════════════════════════════════════════════════════════════
  final String id;
  final String nombre;
  final String? descripcion;
  final double precioMensual;
  final double precioAnual;
  final String moneda;
  final int maxLocales;
  final int maxUsuarios;
  final List<String> modosHabilitados;
  final Map<String, dynamic> features;
  final bool activo;
  final int orden;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Umbral que Supabase usa para representar "ilimitado".
  static const int _ilimitado = 999999;

  // ═══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════
  const Plan({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precioMensual,
    required this.precioAnual,
    required this.moneda,
    required this.maxLocales,
    required this.maxUsuarios,
    required this.modosHabilitados,
    required this.features,
    required this.activo,
    required this.orden,
    this.createdAt,
    this.updatedAt,
  });

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  bool get esIlimitadoEnLocales => maxLocales >= _ilimitado;

  bool get esIlimitadoEnUsuarios => maxUsuarios >= _ilimitado;

  String get precioMensualFormateado => '\$${precioMensual.toStringAsFixed(0)}';

  String get precioAnualFormateado => '\$${precioAnual.toStringAsFixed(0)}';

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════
  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      precioMensual: (map['precio_mensual'] as num?)?.toDouble() ?? 0,
      precioAnual: (map['precio_anual'] as num?)?.toDouble() ?? 0,
      moneda: map['moneda'] as String? ?? 'USD',
      maxLocales: (map['max_locales'] as num?)?.toInt() ?? 0,
      maxUsuarios: (map['max_usuarios'] as num?)?.toInt() ?? 0,
      modosHabilitados:
          (map['modos_habilitados'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const <String>[],
      features: Map<String, dynamic>.from(map['features'] ?? const {}),
      activo: map['activo'] as bool? ?? true,
      orden: (map['orden'] as num?)?.toInt() ?? 0,
      createdAt: _fecha(map['created_at']),
      updatedAt: _fecha(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_mensual': precioMensual,
      'precio_anual': precioAnual,
      'moneda': moneda,
      'max_locales': maxLocales,
      'max_usuarios': maxUsuarios,
      'modos_habilitados': modosHabilitados,
      'features': features,
      'activo': activo,
      'orden': orden,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Plan copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precioMensual,
    double? precioAnual,
    String? moneda,
    int? maxLocales,
    int? maxUsuarios,
    List<String>? modosHabilitados,
    Map<String, dynamic>? features,
    bool? activo,
    int? orden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plan(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioMensual: precioMensual ?? this.precioMensual,
      precioAnual: precioAnual ?? this.precioAnual,
      moneda: moneda ?? this.moneda,
      maxLocales: maxLocales ?? this.maxLocales,
      maxUsuarios: maxUsuarios ?? this.maxUsuarios,
      modosHabilitados: modosHabilitados ?? this.modosHabilitados,
      features: features ?? this.features,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
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
