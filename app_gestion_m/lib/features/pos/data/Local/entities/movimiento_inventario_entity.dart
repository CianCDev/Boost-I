import 'package:isar/isar.dart';

part 'movimiento_inventario_entity.g.dart';

@Collection()
class MovimientoInventarioEntity {
  Id id = Isar.autoIncrement; // ✅ Mantén int

  String productoId = '';
  late String nombreProducto;
  late String tipoMovimiento;
  late double cantidad;
  late double stockResultante;
  late DateTime fecha;
  String usuarioId = '';
  bool sincronizado = false;
}