import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'usuario_entity.g.dart';

@Collection()
class UsuarioEntity {
  // 1. ID interno de Isar (autoincremental, obligatorio pero Isar lo maneja solo)
  Id id = Isar.autoIncrement;

  // 2. Tu ID dinámico, único y automático que usarás en tu app
  @Index(unique: true)
  String dynamicId = Uuid().v4();
  
   String nombre = '';
  String pin = '';
  String rol = 'cajero';
  bool activo = true;
  String estado = 'inactivo';
  String cajaAsignada = 'Caja Principal';
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
  // No es necesario un constructor. 
  // Al hacer "UsuarioEntity()", la variable 'dynamicId' ya nace con su UUID asignado..
   UsuarioEntity();

}