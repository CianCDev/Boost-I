// lib/features/pos/data/Local/entities/categoria_entity.dart
import 'package:isar/isar.dart';

part 'categoria_entity.g.dart';

@Collection()
class CategoriaEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;
  late String nombre;
  String? descripcion;
  late bool activo;
  DateTime? createdAt;
  DateTime? updatedAt;
  late String? syncStatus;

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