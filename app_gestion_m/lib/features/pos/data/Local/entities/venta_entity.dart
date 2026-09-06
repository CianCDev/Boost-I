import 'package:isar/isar.dart';

part 'venta_entity.g.dart';

@Collection()
class VentaEntity {
  Id id = Isar.autoIncrement; // ✅ Mantén int

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
  bool tieneDescuentoEspecial = false;
  double montoDescuentoTotal = 0.0;

  List<VentaItemEntity> items = [];
}

@Embedded()
class VentaItemEntity {
  int? productoId;
  late String nombreProducto;
  late double precioUnidad;
  late double cantidad;
  late double subtotal;
  double? precioOriginal;
  bool esDescuentoEspecial = false;
}