import 'package:isar/isar.dart';

part 'categoria_entity.g.dart';

@Collection()
class CategoriaEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;
  String nombre = '';
  String? descripcion;
  bool activo = true;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? syncStatus;

  CategoriaEntity({
    this.id = Isar.autoIncrement,
    this.supabaseId,
    required this.nombre,
    this.descripcion,
    this.activo = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = 'pending',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ✅ Factory con manejo de null seguro
  factory CategoriaEntity.fromSupabase(Map<String, dynamic> json) {
    final supabaseId = json['id']?.toString();
    return CategoriaEntity(
      supabaseId: supabaseId,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      activo: json['activo'] as bool? ?? true,
      // ✅ Columna real en Supabase: 'created_at' (NO 'creado_en')
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      syncStatus: 'synced',
    );
  }

  /// Mapea la entidad al esquema REAL de Supabase.
  ///
  /// ⚠️ NO enviamos:
  ///   - `created_at`  → tiene `default now()` en la DB.
  ///   - `tenant_id`   → tiene `default current_tenant_id()` en la DB.
  ///
  /// Enviar `created_at` manualmente hace que los UPDATE fallen
  /// (intenta sobreescribir un campo de auditoría) y puede causar
  /// conflictos con el trigger `audit_categorias`.
  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}