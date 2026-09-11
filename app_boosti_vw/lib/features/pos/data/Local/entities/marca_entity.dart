// lib/features/pos/data/Local/entities/marca_entity.dart

class MarcaEntity {
  int id = 0; // 0 = nuevo

  String? supabaseId;
  String nombre = '';
  String? descripcion;
  String? logoUrl;
  String? proveedorId;
  bool activo = true;
  String syncStatus = 'synced';
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  MarcaEntity();

  // ✅ Para Sembast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'nombre': nombre,
      'descripcion': descripcion,
      'logoUrl': logoUrl,
      'proveedorId': proveedorId,
      'activo': activo,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ✅ Desde Sembast
  factory MarcaEntity.fromMap(Map<String, dynamic> map) {
    return MarcaEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..nombre = (map['nombre'] as String?) ?? ''
      ..descripcion = map['descripcion'] as String?
      ..logoUrl = map['logoUrl'] as String?
      ..proveedorId = map['proveedorId'] as String?
      ..activo = (map['activo'] as bool?) ?? true
      ..syncStatus = (map['syncStatus'] as String?) ?? 'synced'
      ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now()
      ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now();
  }

  // ✅ Mantenemos los métodos originales
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': supabaseId,
      'nombre': nombre,
      'descripcion': descripcion,
      'logo_url': logoUrl,
      'proveedor_id': proveedorId,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MarcaEntity.fromSupabase(Map<String, dynamic> data) {
    return MarcaEntity()
      ..supabaseId = data['id'] as String?
      ..nombre = data['nombre'] as String? ?? ''
      ..descripcion = data['descripcion'] as String?
      ..logoUrl = data['logo_url'] as String?
      ..proveedorId = data['proveedor_id'] as String?
      ..activo = data['activo'] ?? true
      ..createdAt = DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now()
      ..updatedAt = DateTime.tryParse(data['updated_at'] as String? ?? '') ?? DateTime.now()
      ..syncStatus = 'synced';
  }
}