import 'package:isar/isar.dart';

part 'recepcion_entity.g.dart';

@Collection()
class RecepcionEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId; // UUID de Supabase
  late int pedidoId;
  late DateTime fechaRecepcion;
  late int usuarioId;
  String? observaciones;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;
}