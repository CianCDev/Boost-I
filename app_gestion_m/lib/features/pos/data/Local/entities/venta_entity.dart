import 'package:isar/isar.dart';

part 'venta_entity.g.dart';


@collection
class VentaEntity {
  Id id = Isar.autoIncrement; // ID autoincremental

  @Index(unique: true, replace: true)
  late String ventaIdString; // ID de la venta, único y reemplazable

  late DateTime fecha;
  late double total;
  late double subtotal;
  late double impuesto;
  late String metodoPago;
  late String cedulaCliente;
  late String empleado;
  
  late List<VentaItemEntity> items;
  late bool sincronizado;
}

@embedded
class VentaItemEntity {
  late String nombreProducto;
  late double precioUnidad;
  late double cantidad;
  late double subtotal;
}
