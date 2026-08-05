// venta_entity.dart
import 'package:isar/isar.dart';

import 'detalle_venta_entity.dart';
part 'venta_entity.g.dart';

@Collection()
class VentaEntity {
  Id id = Isar.autoIncrement;

  late String ventaIdString;
  late DateTime fecha;
  late double subtotal;
  late double impuesto;
  late double total;
  late double tasaBcv;
  late double totalBolivares;
  late String metodoPago;
  late String documento;
  late String empleado;
  // ... campos existentes ...
  String? referencia; // para pago móvil
  String? nombreCliente; // para pago móvil o punto
  bool sincronizado = false;
  int? turnoId;
  

  @Ignore()
  List<DetalleVentaEntity> items = [];

  // ✅ Campo syncStatus
  String syncStatus = 'pending';


}