import 'package:isar/isar.dart';

part 'detalle_pedido_entity.g.dart';

@Collection()
class DetallePedidoEntity {
  Id id = Isar.autoIncrement;

  int? supabaseId; // UUID de Supabase (opcional)
  late int pedidoId;
  late int productoId;
  late String nombreProducto;
  late double cantidad;
  late double precioUnidad;
  late double subtotal;
}