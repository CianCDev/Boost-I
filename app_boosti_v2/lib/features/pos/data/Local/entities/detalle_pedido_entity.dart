import 'package:isar/isar.dart';

part 'detalle_pedido_entity.g.dart';

@Collection()
class DetallePedidoEntity {
  Id id = Isar.autoIncrement;

  // ✅ CORREGIDO: supabaseId debe ser String? (UUID)
  String? supabaseId; // <-- CAMBIADO de int? a String?

  late int pedidoId;
  late int productoId;
  late String nombreProducto;
  late double cantidad;
  late double precioUnidad;
  late double subtotal;
}