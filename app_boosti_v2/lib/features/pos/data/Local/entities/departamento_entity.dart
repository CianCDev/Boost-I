import 'package:isar/isar.dart';

part 'departamento_entity.g.dart';

@Collection()
class DepartamentoEntity {
  Id id = Isar.autoIncrement;

  // UUID de Supabase (para sincronización)
  String? supabaseId;

  // Datos básicos
  late String nombre;
  String? descripcion;

  // Relación con Local (opcional, si quieres que los departamentos pertenezcan a un local)
  int? localId;

  // Estado y sincronización
  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // Auditoría
  DateTime? createdAt;
  DateTime? updatedAt;

  // Constructor vacío necesario para Isar
  DepartamentoEntity();
}