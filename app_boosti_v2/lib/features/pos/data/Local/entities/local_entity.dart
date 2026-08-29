// local_entity.dart (ampliado)
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

  // Nuevos campos
  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // Auditoría
  DateTime? createdAt;
  DateTime? updatedAt;

  LocalEntity();
}