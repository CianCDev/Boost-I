import 'package:isar/isar.dart';

part 'recepcion_entity.g.dart';

@Collection()
class RecepcionEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId; // UUID de Supabase
  int pedidoId = 0;
  DateTime fechaRecepcion = DateTime.now();
  int usuarioId = 0;
  String? observaciones;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;
}