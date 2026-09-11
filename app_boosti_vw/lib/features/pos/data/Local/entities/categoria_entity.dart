// lib/features/pos/data/Local/entities/categoria_entity.dart
// Sin Isar, sin part, sin anotaciones

class CategoriaEntity {
  int id; // Ahora es int (0 para nuevos)
  String? supabaseId;
  String nombre;
  String? descripcion;
  bool activo;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? syncStatus;

  CategoriaEntity({
    this.id = 0, // 0 = nuevo, se asignará automáticamente
    this.supabaseId,
    required this.nombre,
    this.descripcion,
    this.activo = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = 'pending',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ✅ Método para convertir a un mapa JSON (para Sembast)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  // ✅ Factory desde un mapa (para Sembast)
  factory CategoriaEntity.fromMap(Map<String, dynamic> map) {
    return CategoriaEntity(
      id: map['id'] as int? ?? 0,
      supabaseId: map['supabaseId'] as String?,
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String?,
      activo: map['activo'] as bool? ?? true,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      syncStatus: map['syncStatus'] as String? ?? 'pending',
    );
  }

  // ✅ Mantén tu método original de Supabase (no interfiere)
  factory CategoriaEntity.fromSupabase(Map<String, dynamic> json) {
    final supabaseId = json['id']?.toString();
    return CategoriaEntity(
      supabaseId: supabaseId,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      syncStatus: 'synced',
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}