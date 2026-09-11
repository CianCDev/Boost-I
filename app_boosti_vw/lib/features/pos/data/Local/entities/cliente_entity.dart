// lib/features/pos/data/Local/entities/cliente_entity.dart

class ClienteEntity {
  int id = 0; // 0 = nuevo, Sembast asigna el ID

  String? supabaseId; // UUID de Supabase

  // Relación con el local
  int? localId;
  String? localSupabaseId;

  String nombre = '';
  String? documento;
  String? telefono;
  String? email;
  String? direccion;

  DateTime fechaRegistro = DateTime.now();

  // Fidelización
  bool frecuente = false;
  double totalCompras = 0.0;
  DateTime? ultimaCompra;
  int cantidadCompras = 0;

  // Estado y preferencias
  bool activo = true;
  bool preferenciasMarketing = true;

  // Extras
  DateTime? fechaNacimiento;
  String? notas;

  // Sincronización
  String syncStatus = 'pending';
  DateTime? createdAt;
  DateTime? updatedAt;

  ClienteEntity();

  // ✅ Convertir a Mapa (para Sembast)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'localId': localId,
      'localSupabaseId': localSupabaseId,
      'nombre': nombre,
      'documento': documento,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'frecuente': frecuente,
      'totalCompras': totalCompras,
      'ultimaCompra': ultimaCompra?.toIso8601String(),
      'cantidadCompras': cantidadCompras,
      'activo': activo,
      'preferenciasMarketing': preferenciasMarketing,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'notas': notas,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ✅ Crear desde Mapa (Sembast)
  factory ClienteEntity.fromMap(Map<String, dynamic> map) {
    return ClienteEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..localId = map['localId'] as int?
      ..localSupabaseId = map['localSupabaseId'] as String?
      ..nombre = (map['nombre'] as String?) ?? ''
      ..documento = map['documento'] as String?
      ..telefono = map['telefono'] as String?
      ..email = map['email'] as String?
      ..direccion = map['direccion'] as String?
      ..fechaRegistro = DateTime.tryParse(map['fechaRegistro'] as String? ?? '') ?? DateTime.now()
      ..frecuente = (map['frecuente'] as bool?) ?? false
      ..totalCompras = (map['totalCompras'] as num?)?.toDouble() ?? 0.0
      ..ultimaCompra = map['ultimaCompra'] != null ? DateTime.tryParse(map['ultimaCompra'] as String) : null
      ..cantidadCompras = (map['cantidadCompras'] as int?) ?? 0
      ..activo = (map['activo'] as bool?) ?? true
      ..preferenciasMarketing = (map['preferenciasMarketing'] as bool?) ?? true
      ..fechaNacimiento = map['fechaNacimiento'] != null ? DateTime.tryParse(map['fechaNacimiento'] as String) : null
      ..notas = map['notas'] as String?
      ..syncStatus = (map['syncStatus'] as String?) ?? 'pending'
      ..createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null
      ..updatedAt = map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null;
  }
}