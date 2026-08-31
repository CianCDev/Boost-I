import 'package:isar/isar.dart';

part 'local_entity.g.dart';

@Collection()
class LocalEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;

  late String nombre;
  String? direccion;
  String? telefono;
  String? email;
  String? rif; // NUEVO: RIF del local

  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  DateTime? createdAt;
  DateTime? updatedAt;

  LocalEntity();
}