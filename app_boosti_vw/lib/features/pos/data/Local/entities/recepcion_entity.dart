// lib/features/pos/data/Local/entities/recepcion_entity.dart

class RecepcionEntity {
  int id = 0;
  String? supabaseId;
  int pedidoId = 0;
  DateTime fechaRecepcion = DateTime.now();
  int usuarioId = 0;
  String? observaciones;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  RecepcionEntity();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'pedidoId': pedidoId,
      'fechaRecepcion': fechaRecepcion.toIso8601String(),
      'usuarioId': usuarioId,
      'observaciones': observaciones,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  factory RecepcionEntity.fromMap(Map<String, dynamic> map) {
    return RecepcionEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..pedidoId = (map['pedidoId'] as int?) ?? 0
      ..fechaRecepcion = DateTime.tryParse(map['fechaRecepcion'] as String? ?? '') ?? DateTime.now()
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..observaciones = map['observaciones'] as String?
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null;
  }
}