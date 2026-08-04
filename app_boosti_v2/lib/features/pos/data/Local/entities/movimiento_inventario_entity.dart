// movimiento_inventario_entity.dart
import 'package:isar/isar.dart';
part 'movimiento_inventario_entity.g.dart';

@Collection()
class MovimientoInventarioEntity {
  Id id = Isar.autoIncrement;

  late int productoId;
  late String nombreProducto;
  late String tipoMovimiento;
  late double cantidad;
  late double stockResultante;
  late DateTime fecha;
  late int usuarioId;

  // ✅ Campo syncStatus con valor por defecto 'pending'

  String syncStatus = 'pending';
}