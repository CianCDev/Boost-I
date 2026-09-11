// lib/features/pos/data/Local/entities/movimiento_lote_entity.dart

class MovimientoLoteEntity {
  int id = 0;
  int loteId = 0;
  String tipo = '';
  double cantidad = 0.0;
  DateTime fecha = DateTime.now();
  int usuarioId = 0;
  String? observaciones;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  MovimientoLoteEntity();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteId': loteId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'usuarioId': usuarioId,
      'observaciones': observaciones,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  factory MovimientoLoteEntity.fromMap(Map<String, dynamic> map) {
    return MovimientoLoteEntity()
      ..id = (map['id'] as int?) ?? 0
      ..loteId = (map['loteId'] as int?) ?? 0
      ..tipo = (map['tipo'] as String?) ?? ''
      ..cantidad = (map['cantidad'] as num?)?.toDouble() ?? 0.0
      ..fecha = DateTime.tryParse(map['fecha'] as String? ?? '') ?? DateTime.now()
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..observaciones = map['observaciones'] as String?
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null;
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id_isar': id,
      'lote_id': loteId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'usuario_id': usuarioId,
      'observaciones': observaciones,
      'sincronizado': sincronizado,
      'fecha_sincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  factory MovimientoLoteEntity.fromSupabase(Map<String, dynamic> json) {
    return MovimientoLoteEntity()
      ..id = (json['id_isar'] as int?) ?? 0
      ..loteId = (json['lote_id'] as int?) ?? 0
      ..tipo = json['tipo'] as String? ?? ''
      ..cantidad = (json['cantidad'] as num?)?.toDouble() ?? 0.0
      ..fecha = DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now()
      ..usuarioId = (json['usuario_id'] as int?) ?? 0
      ..observaciones = json['observaciones'] as String?
      ..sincronizado = json['sincronizado'] as bool? ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null ? DateTime.tryParse(json['fecha_sincronizacion'] as String) : null;
  }
}