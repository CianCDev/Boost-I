// lib/features/pos/data/Local/entities/pedido_entity.dart

import 'detalle_pedido_entity.dart';
import 'recepcion_entity.dart';

enum EstadoPedido {
  pendiente,
  recibido,
  cancelado,
}

class PedidoEntity {
  int id = 0;
  String? supabaseId;
  int localOrigenId = 0;
  int localDestinoId = 0;
  int usuarioId = 0;
  DateTime fechaPedido = DateTime.now();
  EstadoPedido estado = EstadoPedido.pendiente;
  String proveedorNombre = '';
  String? proveedorCedula;
  String? proveedorTelefono;
  String? proveedorEmpresa;
  String? observaciones;
  double total = 0.0;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // Relaciones en memoria (no se guardan en Sembast)
  List<DetallePedidoEntity>? detalles;
  RecepcionEntity? recepcion;

  PedidoEntity();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'localOrigenId': localOrigenId,
      'localDestinoId': localDestinoId,
      'usuarioId': usuarioId,
      'fechaPedido': fechaPedido.toIso8601String(),
      'estado': estado.name, // Guardamos el nombre del enum
      'proveedorNombre': proveedorNombre,
      'proveedorCedula': proveedorCedula,
      'proveedorTelefono': proveedorTelefono,
      'proveedorEmpresa': proveedorEmpresa,
      'observaciones': observaciones,
      'total': total,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  factory PedidoEntity.fromMap(Map<String, dynamic> map) {
    return PedidoEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..localOrigenId = (map['localOrigenId'] as int?) ?? 0
      ..localDestinoId = (map['localDestinoId'] as int?) ?? 0
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..fechaPedido = DateTime.tryParse(map['fechaPedido'] as String? ?? '') ?? DateTime.now()
      ..estado = EstadoPedido.values.firstWhere(
            (e) => e.name == (map['estado'] as String? ?? 'pendiente'),
            orElse: () => EstadoPedido.pendiente,
          )
      ..proveedorNombre = (map['proveedorNombre'] as String?) ?? ''
      ..proveedorCedula = map['proveedorCedula'] as String?
      ..proveedorTelefono = map['proveedorTelefono'] as String?
      ..proveedorEmpresa = map['proveedorEmpresa'] as String?
      ..observaciones = map['observaciones'] as String?
      ..total = (map['total'] as num?)?.toDouble() ?? 0.0
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null;
  }
}