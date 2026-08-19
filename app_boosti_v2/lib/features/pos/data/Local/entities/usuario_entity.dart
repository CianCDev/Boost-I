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
  
  late String nombre;
  late String pin;
  late String rol;
  late bool activo;
  late String estado;
  late String cajaAsignada;
  String? email;
  String? supabaseId;
  String? supabaseUid;
  String? deviceId;
  String? departamento;
  DateTime? updatedAt;

  // No es necesario un constructor. 
  // Al hacer "UsuarioEntity()", la variable 'dynamicId' ya nace con su UUID asignado.
}