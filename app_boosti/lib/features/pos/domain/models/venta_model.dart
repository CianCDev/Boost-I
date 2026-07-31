class VentaModel {
  final String id;
  final DateTime fecha;
  final List<Map<String, dynamic>> items;
  final double total;
  final String metodoPago;
  final double montoRecibido;
  final double cambio;

  VentaModel({
    required this.id,
    required this.fecha,
    required this.items,
    required this.total,
    required this.metodoPago,
    required this.montoRecibido,
    required this.cambio,
  });

 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'items': items,
      'total': total,
      'metodoPago': metodoPago,
      'montoRecibido': montoRecibido,
      'cambio': cambio,
    };
  }
}