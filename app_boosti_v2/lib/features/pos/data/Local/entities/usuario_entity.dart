// usuario_entity.dart
import 'package:isar/isar.dart';
part 'usuario_entity.g.dart';

@Collection()
class UsuarioEntity {
  Id id = Isar.autoIncrement; // este es el id local, pero usaremos idIsar como el id real común

  @Index(unique: true)
  late int idIsar; // ID único que se comparte con Supabase (antes era id, pero ahora lo separamos)
  
  late String nombre;
  late String pin;
  late String rol;
  late bool activo;
  late String estado; // 'activo', 'descanso', 'inactivo'
  late String cajaAsignada;
  String? email;
  String? supabaseUid;
  String? deviceId;
  String? departamento; // Nuevo campo
  DateTime? updatedAt; // Para saber última actualización
}