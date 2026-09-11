// lib/features/pos/data/Local/entities/codigo_barra_alia_entity.dart

class CodigoBarrasAliasEntity {
  int id = 0; // 0 = nuevo
  String codigo = '';
  int productoId = 0;
  double factor = 1.0;

  bool activo = true;
  DateTime fechaAsignacion = DateTime.now();
  String? observaciones;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  CodigoBarrasAliasEntity();

  // ✅ Convertir a Mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'productoId': productoId,
      'factor': factor,
      'activo': activo,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'observaciones': observaciones,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  // ✅ Crear desde Mapa
  factory CodigoBarrasAliasEntity.fromMap(Map<String, dynamic> map) {
    return CodigoBarrasAliasEntity()
      ..id = (map['id'] as int?) ?? 0
      ..codigo = (map['codigo'] as String?) ?? ''
      ..productoId = (map['productoId'] as int?) ?? 0
      ..factor = (map['factor'] as num?)?.toDouble() ?? 1.0
      ..activo = (map['activo'] as bool?) ?? true
      ..fechaAsignacion = DateTime.tryParse(map['fechaAsignacion'] as String? ?? '') ?? DateTime.now()
      ..observaciones = map['observaciones'] as String?
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null;
  }
}