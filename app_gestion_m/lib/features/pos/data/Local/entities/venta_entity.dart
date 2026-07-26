import 'package:isar/isar.dart';

part 'venta_entity.g.dart';

@Collection()
class VentaEntity {
  Id id = Isar.autoIncrement;

  late String ventaIdString;
  late DateTime fecha;
  late double total;
  late double subtotal;
  late double impuesto;

  // ⚠️ Agrega estas dos líneas que le faltan a la clase:
  late double tasaBcv;
  late double totalBolivares;

  late String metodoPago;
  late String cedulaCliente;
  late String empleado;
  late bool sincronizado;

  List<VentaItemEntity> items = [];
}

@Embedded()
class VentaItemEntity {
  late String nombreProducto;
  late double precioUnidad;
  late double cantidad;
  late double subtotal;
}