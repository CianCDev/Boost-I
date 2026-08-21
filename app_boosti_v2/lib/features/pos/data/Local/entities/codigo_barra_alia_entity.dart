import 'package:isar/isar.dart';

part 'codigo_barra_alia_entity.g.dart';

@Collection()
class CodigoBarrasAliasEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String codigo;

  late int productoId;
  late double factor;

  bool activo = true;
  DateTime fechaAsignacion = DateTime.now();
  String? observaciones;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
}