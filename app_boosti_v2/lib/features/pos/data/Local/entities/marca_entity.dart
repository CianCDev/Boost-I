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

  /// Path del logo en el bucket `marcas` de Supabase Storage.
  ///
  /// Relativo, ej: `logo_123.png`. **NO** es una URL.
  ///
  /// Antes guardaba `createSignedUrl(path, 3600)`, que devuelve una URL
  /// valida por 1 hora. Como esa URL se persistia en Isar y se subia a
  /// Supabase, todos los logos moria una hora despues de subirse y no
  /// habia forma de recuperarlos. Ahora se guarda el path y la URL firmada
  /// se genera en el momento de renderizar.
  ///
  /// La columna remota se sigue llamando `logo_url`: migrarla seria un
  /// costo sin beneficio, y el valor ya no es una URL.
  String? logoPath;

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
      'logo_url': logoPath,
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
      ..logoPath = data['logo_url'] as String?
      ..proveedorId = data['proveedor_id'] as String?
      ..activo = data['activo'] ?? true
      ..createdAt = DateTime.parse(data['created_at'] as String)
      ..updatedAt = DateTime.parse(data['updated_at'] as String)
      ..syncStatus = 'synced';
  }
}