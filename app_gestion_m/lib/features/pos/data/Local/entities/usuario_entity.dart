import 'package:isar/isar.dart';

part 'usuario_entity.g.dart';

@Collection()
class UsuarioEntity {
  Id id = Isar.autoIncrement; // ✅ Mantén int

  @Index(unique: true, replace: true)
  late String nombre;

  late String pin;
  late String rol;
  bool activo = true;
  String? estado;
  String? cajaAsignada;
  String? email;
  String? supabaseUid;
}