import 'package:isar/isar.dart';
import 'detalle_pedido_entity.dart';
import 'recepcion_entity.dart';

part 'pedido_entity.g.dart';

enum EstadoPedido {
  pendiente,
  recibido,
  cancelado,
}

@Collection()
class PedidoEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId;

  @Index() // ← Para consultas por localOrigenId
  int localOrigenId = 0;

  @Index() // ← Para consultas por localDestinoId
  int localDestinoId = 0;

  @Index() // ← Para consultas por usuarioId
  int usuarioId = 0;

  DateTime fechaPedido = DateTime.now();

  @Enumerated(EnumType.name)
  @Index() // ← Para filtrar por estado
  EstadoPedido estado = EstadoPedido.pendiente;

  String proveedorNombre = '';
  String? proveedorCedula;
  String? proveedorTelefono;
  String? proveedorEmpresa;
  String? observaciones;

  double total = 0.0;

  @Index() // ← Para obtener pendientes de sincronización
  bool sincronizado = false;

  DateTime? fechaSincronizacion;

  @Ignore()
  List<DetallePedidoEntity>? detalles;

  @Ignore()
  RecepcionEntity? recepcion;
}