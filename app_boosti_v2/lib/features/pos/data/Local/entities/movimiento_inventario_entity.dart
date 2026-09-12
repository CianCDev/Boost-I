// movimiento_inventario_entity.dart
import 'package:isar/isar.dart';
part 'movimiento_inventario_entity.g.dart';

@Collection()
class MovimientoInventarioEntity {
  Id id = Isar.autoIncrement;

 int productoId = 0;
  String nombreProducto = '';
  String tipoMovimiento = '';
  double cantidad = 0.0;
  double stockResultante = 0.0;
  DateTime fecha = DateTime.now();
  int usuarioId = 0;
  // ✅ Campo syncStatus con valor por defecto 'pending'

  String syncStatus = 'pending';
}