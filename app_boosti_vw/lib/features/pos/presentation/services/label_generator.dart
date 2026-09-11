/// Modelo de una etiqueta de producto
class LabelItem {
  final String nombre;
  final double precio;
  final String? codigoBarras;
  final int cantidad;

  LabelItem({
    required this.nombre,
    required this.precio,
    this.codigoBarras,
    this.cantidad = 1,
  });
}

/// Generador de comandos ESC/POS para etiquetas (VACIADO PARA WEB)
class LabelGenerator {
  static Future<List<int>> generateLabelBytes({
    required LabelItem item,
  }) async {
    return [];
  }
}