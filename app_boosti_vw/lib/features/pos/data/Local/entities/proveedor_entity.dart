// lib/features/pos/data/Local/entities/proveedor_entity.dart

import 'producto_entity.dart';

class ProveedorEntity {
  int id = 0; // 0 = nuevo, Sembast asigna el ID

  String? supabaseId;
  String nombre = '';
  String? cedula;
  String? telefono;
  String? empresa;
  String? rif;
  String? direccion;
  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;
  String? email;
  
  // Para comparar fechas de actualización
  DateTime? updatedAt; 

  // 🔥 NO se guarda en Sembast (es una relación de Isar), se usa en memoria
  List<ProductoEntity>? productos;

  ProveedorEntity();

  // ✅ Convertir a Mapa (para Sembast)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'nombre': nombre,
      'cedula': cedula,
      'telefono': telefono,
      'empresa': empresa,
      'rif': rif,
      'direccion': direccion,
      'activo': activo,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
      'email': email,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ✅ Crear desde Mapa (Sembast)
  factory ProveedorEntity.fromMap(Map<String, dynamic> map) {
    return ProveedorEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..nombre = (map['nombre'] as String?) ?? ''
      ..cedula = map['cedula'] as String?
      ..telefono = map['telefono'] as String?
      ..empresa = map['empresa'] as String?
      ..rif = map['rif'] as String?
      ..direccion = map['direccion'] as String?
      ..activo = (map['activo'] as bool?) ?? true
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null
      ..email = map['email'] as String?
      ..updatedAt = map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null;
  }
}