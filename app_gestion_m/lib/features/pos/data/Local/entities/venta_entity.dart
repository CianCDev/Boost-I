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

  late double tasaBcv;
  late double totalBolivares;

  late String metodoPago;
  late String documento;
  late String empleado;
  late bool sincronizado;

  List<VentaItemEntity> items = [];
}

@Embedded()
class VentaItemEntity {
  // ⚠️ Este es el campo clave para evitar entidades fantasma y errores de stock
  int? productoId;

  late String nombreProducto;
  late double precioUnidad;
  late double cantidad;
  late double subtotal;
}