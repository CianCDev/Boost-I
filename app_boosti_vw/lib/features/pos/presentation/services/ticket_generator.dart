import '../../data/Local/entities/local_entity.dart';

/// Modelo de un ítem del ticket
class TicketItem {
  final String nombre;
  final double precio;
  final double cantidad;
  final bool esPesado;

  TicketItem({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.esPesado = false,
  });

  double get total => precio * cantidad;
}

/// Generador de comandos ESC/POS para tickets (VACIADO PARA WEB)
class TicketGenerator {
  static Future<List<int>> generateTicketBytes({
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
    LocalEntity? local,
    bool esCierre = false,
    Map<String, double>? totalesPorMetodo,
  }) async {
    return [];
  }
}