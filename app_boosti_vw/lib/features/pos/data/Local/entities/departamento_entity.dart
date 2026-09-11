// lib/features/pos/data/Local/entities/departamento_entity.dart

class DepartamentoEntity {
  int id = 0; // 0 = nuevo
  String? supabaseId;

  String nombre = '';
  String? descripcion;
  int? localId; // ID del local asociado (opcional)

  // ✅ NUEVO: ID del usuario encargado (opcional)
  int? usuarioId;

  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  DateTime? createdAt;
  DateTime? updatedAt;

  DepartamentoEntity();

  // ✅ Convertir a Mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'nombre': nombre,
      'descripcion': descripcion,
      'localId': localId,
      'usuarioId': usuarioId,
      'activo': activo,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ✅ Crear desde Mapa
  factory DepartamentoEntity.fromMap(Map<String, dynamic> map) {
    return DepartamentoEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..nombre = (map['nombre'] as String?) ?? ''
      ..descripcion = map['descripcion'] as String?
      ..localId = map['localId'] as int?
      ..usuarioId = map['usuarioId'] as int?
      ..activo = (map['activo'] as bool?) ?? true
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null
      ..createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null
      ..updatedAt = map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null;
  }
}