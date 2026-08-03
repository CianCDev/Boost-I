import 'package:isar/isar.dart';

part 'gasto_entity.g.dart';

@Collection()
class GastoEntity {
  Id id = Isar.autoIncrement;

  late String concepto;                // Ej: "Pago a Proveedor de Frutas"
  late String categoria;               // Ej: "Proveedores", "Servicios", "Mantenimiento"
  late double monto;                   // Monto del gasto (en USD)
  late String metodoPago;              // Ej: "Efectivo", "Pago Móvil", "Transferencia"
  late DateTime fecha;                 // Fecha y hora en que se registró el gasto
  late String empleado;                // Quién registró el gasto (Admin)

  String? comprobanteOReferencia;      // Opcional: Número de factura, referencia de transferencia
  String? notas;                       // Opcional: Notas adicionales
  bool sincronizado = false;           // Para la sincronización offline/online
}