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
  late int localOrigenId;
  
  @Index() // ← Para consultas por localDestinoId
  late int localDestinoId;
  
  @Index() // ← Para consultas por usuarioId
  late int usuarioId;
  
  late DateTime fechaPedido;
  
  @Enumerated(EnumType.name)
  @Index() // ← Para filtrar por estado
  late EstadoPedido estado;

  late String proveedorNombre;
  String? proveedorCedula;
  String? proveedorTelefono;
  String? proveedorEmpresa;
  String? observaciones;
  late double total;
  
  @Index() // ← Para obtener pendientes de sincronización
  bool sincronizado = false;
  
  DateTime? fechaSincronizacion;

  @Ignore()
  List<DetallePedidoEntity>? detalles;

  @Ignore()
  RecepcionEntity? recepcion;
}