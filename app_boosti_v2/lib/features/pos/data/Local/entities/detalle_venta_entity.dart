import 'package:isar/isar.dart';
part 'detalle_venta_entity.g.dart';

@Collection()
class DetalleVentaEntity {
  Id id = Isar.autoIncrement;

  // ✅ Referencia al ID de la venta padre (relación manual)
  late int ventaId; // ← Este campo vincula con VentaEntity.id

  int? productoId;
  late String nombreProducto;
  late double precioUnidad;
  late double cantidad;
  late double subtotal;
}