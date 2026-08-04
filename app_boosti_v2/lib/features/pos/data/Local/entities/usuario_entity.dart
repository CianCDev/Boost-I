// usuario_entity.dart
import 'package:isar/isar.dart';
part 'usuario_entity.g.dart';

@Collection()
class UsuarioEntity {
  Id id = Isar.autoIncrement;

  late String nombre;
  late String pin;
  late String rol;
  late bool activo;
  late String estado;
  late String cajaAsignada;
  String? email;          // Correo electrónico (para login por email)
  String? supabaseUid;    // ID de Supabase
  String? deviceId; 
}