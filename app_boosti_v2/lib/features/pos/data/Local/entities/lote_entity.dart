import 'package:isar/isar.dart';

part 'lote_entity.g.dart';

@Collection()
class LoteEntity {
  Id id = Isar.autoIncrement;

  late int productoId;
  String? codigoLoteProveedor; // número de lote del proveedor

  double cantidadInicial = 0.0;
  double cantidadRestante = 0.0;

  DateTime fechaIngreso = DateTime.now();
  DateTime? fechaVencimiento; // null si no aplica

  String estado = 'activo'; // 'activo', 'agotado', 'bloqueado', 'devuelto'

  // Opcional: costo unitario para reportes financieros
  double? costoUnitario;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
}