import 'package:isar/isar.dart';

part 'gasto_entity.g.dart';

@Collection()
class GastoEntity {
  Id id = Isar.autoIncrement;

  String descripcion = '';
  double monto = 0.0;
  String moneda = 'USD'; // 'USD' o 'Bs'
  double? tasaBcv;
  String categoria = 'General';
  int usuarioId = 0;
  String usuarioNombre = '';
  DateTime fecha = DateTime.now();
  String syncStatus = 'pending';
  String? supabaseId;

  GastoEntity();
}