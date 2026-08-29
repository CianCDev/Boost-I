// lib/features/pos/data/local/entities/marca_entity.dart
import 'package:isar/isar.dart';

part 'marca_entity.g.dart';

@collection // <-- Corregido: sin paréntesis
class MarcaEntity {
  MarcaEntity(); // constructor vacío

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? supabaseId;

  String nombre = '';

  String? descripcion;

  String? logoUrl;

  String? proveedorId;

  bool activo = true;

  String syncStatus = 'synced';

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

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
      ..nombre = data['nombre'] as String
      ..descripcion = data['descripcion'] as String?
      ..logoUrl = data['logo_url'] as String?
      ..proveedorId = data['proveedor_id'] as String?
      ..activo = data['activo'] ?? true
      ..createdAt = DateTime.parse(data['created_at'] as String)
      ..updatedAt = DateTime.parse(data['updated_at'] as String)
      ..syncStatus = 'synced';
  }
}