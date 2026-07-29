import 'package:isar/isar.dart';


part 'usuario_entity.g.dart';

@Collection()
class UsuarioEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String nombre;

  late String pin; // PIN de acceso (ej. "1234")

  late String rol; // 'admin' o 'cajero'

  bool activo = true;

  // Campos para el control de cajeros y turnos
  String? estado; // ej. 'activo', 'inactivo', 'descanso'
  String? cajaAsignada; // ej. 'Caja Principal', 'Caja 01'

  // Email opcional y supabase UID si la cuenta existe en la nube
  String? email;
  String? supabaseUid;
}