import 'package:isar/isar.dart';

part 'turno_entity.g.dart';

@Collection()
class TurnoEntity {
  Id id = Isar.autoIncrement;

  int usuarioId = 0;
  String usuarioNombre = '';
  DateTime fechaApertura = DateTime.now();
  DateTime? fechaCierre;
  double montoInicial = 0.0;
  double? montoFinal;
  String estado = 'abierto'; // 'abierto', 'cerrado'
  int? ventasCount;
  double? totalVentas;
  String syncStatus = 'pending';

  TurnoEntity();
}