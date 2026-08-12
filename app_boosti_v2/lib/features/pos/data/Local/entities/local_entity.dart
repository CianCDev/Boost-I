import 'package:isar/isar.dart';

part 'local_entity.g.dart';

@Collection()
class LocalEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;
  String nombre = '';
  String? direccion;
  String? telefono;
  DateTime? createdAt;
  DateTime? updatedAt;
}