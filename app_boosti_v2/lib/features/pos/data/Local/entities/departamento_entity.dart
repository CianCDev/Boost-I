import 'package:isar/isar.dart';

part 'departamento_entity.g.dart';

@Collection()
class DepartamentoEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;

  late String nombre;
  String? descripcion;
  int? localId; // ID del local asociado (opcional)

  // ✅ NUEVO: ID del usuario encargado (opcional)
  int? usuarioId;

  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  DateTime? createdAt;
  DateTime? updatedAt;

  DepartamentoEntity();
}