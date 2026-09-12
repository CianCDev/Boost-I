import 'package:isar/isar.dart';

part 'codigo_barra_alia_entity.g.dart';

@Collection()
class CodigoBarrasAliasEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String codigo = '';
  int productoId = 0;
  double factor = 1.0;

  bool activo = true;
  DateTime fechaAsignacion = DateTime.now();
  String? observaciones;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
}