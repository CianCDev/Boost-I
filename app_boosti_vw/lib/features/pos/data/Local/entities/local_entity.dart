// lib/features/pos/data/Local/entities/local_entity.dart

class LocalEntity {
  int id = 0; // 0 = nuevo
  String? supabaseId;
  String nombre = '';
  String? direccion;
  String? telefono;
  String? email;
  String? rif;

  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  DateTime? createdAt;
  DateTime? updatedAt;

  LocalEntity();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'rif': rif,
      'activo': activo,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory LocalEntity.fromMap(Map<String, dynamic> map) {
    return LocalEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..nombre = (map['nombre'] as String?) ?? ''
      ..direccion = map['direccion'] as String?
      ..telefono = map['telefono'] as String?
      ..email = map['email'] as String?
      ..rif = map['rif'] as String?
      ..activo = (map['activo'] as bool?) ?? true
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null
      ..createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null
      ..updatedAt = map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null;
  }
}