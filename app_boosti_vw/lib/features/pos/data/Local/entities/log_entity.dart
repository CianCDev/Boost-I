// lib/features/pos/data/Local/entities/log_entity.dart

class LogEntity {
  int id = 0; // 0 = nuevo
  String usuarioNombre = '';
  String usuarioRol = '';
  String accion = '';
  String? detalles;
  DateTime fecha = DateTime.now();
  bool sincronizado = false;

  LogEntity();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioNombre': usuarioNombre,
      'usuarioRol': usuarioRol,
      'accion': accion,
      'detalles': detalles,
      'fecha': fecha.toIso8601String(),
      'sincronizado': sincronizado,
    };
  }

  factory LogEntity.fromMap(Map<String, dynamic> map) {
    return LogEntity()
      ..id = (map['id'] as int?) ?? 0
      ..usuarioNombre = (map['usuarioNombre'] as String?) ?? ''
      ..usuarioRol = (map['usuarioRol'] as String?) ?? ''
      ..accion = (map['accion'] as String?) ?? ''
      ..detalles = map['detalles'] as String?
      ..fecha = DateTime.tryParse(map['fecha'] as String? ?? '') ?? DateTime.now()
      ..sincronizado = (map['sincronizado'] as bool?) ?? false;
  }
}