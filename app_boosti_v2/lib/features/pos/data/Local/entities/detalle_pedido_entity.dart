import 'package:isar/isar.dart';

part 'detalle_pedido_entity.g.dart';

@Collection()
class DetallePedidoEntity {
  Id id = Isar.autoIncrement;

  int? supabaseId;

  @Index()
  int pedidoId = 0;

  @Index()
  int productoId = 0;

  String nombreProducto = '';

  double cantidad = 0.0;

  double precioUnidad = 0.0;

  double subtotal = 0.0;
}