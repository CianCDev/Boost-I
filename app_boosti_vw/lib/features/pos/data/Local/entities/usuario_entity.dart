// lib/features/pos/data/Local/entities/usuario_entity.dart
import 'package:uuid/uuid.dart';

class UsuarioEntity {
  // 1. ID interno (0 significa nuevo, se asignará automáticamente en Sembast)
  int id = 0;

  // 2. Tu ID dinámico, único y automático (sigue siendo UUID)
  String dynamicId = Uuid().v4();
  
  // Sin anotaciones @Index ni @Collection
  String nombre = '';
  String pin = '';
  String rol = '';
  bool activo = true;
  String estado = 'inactivo';
  String cajaAsignada = '';
  
  // Opcionales
  String? email;
  String? password;
  String? supabaseId;
  String? supabaseUid;
  String? deviceId;
  String? departamento;
  int? departamentoId;
  int? localId;

  // Auditoría
  DateTime? createdAt;
  DateTime? updatedAt;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // Constructor simple (sin isar, el UUID se genera automáticamente)
  UsuarioEntity();

  // ✅ Convertir a Mapa para Sembast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dynamicId': dynamicId,
      'nombre': nombre,
      'pin': pin,
      'rol': rol,
      'activo': activo,
      'estado': estado,
      'cajaAsignada': cajaAsignada,
      'email': email,
      'password': password,
      'supabaseId': supabaseId,
      'supabaseUid': supabaseUid,
      'deviceId': deviceId,
      'departamento': departamento,
      'departamentoId': departamentoId,
      'localId': localId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  // ✅ Crear desde Mapa (Sembast)
  factory UsuarioEntity.fromMap(Map<String, dynamic> map) {
    return UsuarioEntity()
      ..id = (map['id'] as int?) ?? 0
      ..dynamicId = (map['dynamicId'] as String?) ?? Uuid().v4()
      ..nombre = (map['nombre'] as String?) ?? ''
      ..pin = (map['pin'] as String?) ?? ''
      ..rol = (map['rol'] as String?) ?? 'cajero'
      ..activo = (map['activo'] as bool?) ?? true
      ..estado = (map['estado'] as String?) ?? 'inactivo'
      ..cajaAsignada = (map['cajaAsignada'] as String?) ?? ''
      ..email = map['email'] as String?
      ..password = map['password'] as String?
      ..supabaseId = map['supabaseId'] as String?
      ..supabaseUid = map['supabaseUid'] as String?
      ..deviceId = map['deviceId'] as String?
      ..departamento = map['departamento'] as String?
      ..departamentoId = map['departamentoId'] as int?
      ..localId = map['localId'] as int?
      ..createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null
      ..updatedAt = map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null;
  }
}