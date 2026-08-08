// lib/features/pos/presentation/services/label_generator.dart
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';


/// Modelo de una etiqueta de producto
class LabelItem {
  final String nombre;
  final double precio;
  final String? codigoBarras;
  final int cantidad; // Número de copias de esta etiqueta

  LabelItem({
    required this.nombre,
    required this.precio,
    this.codigoBarras,
    this.cantidad = 1,
  });
}

/// Generador de comandos ESC/POS para etiquetas (formato compacto)
class LabelGenerator {
  static Future<List<int>> generateLabelBytes({
    required LabelItem item,
  }) async {
    final profile = await CapabilityProfile.load();
    // Usamos papel de 58mm (más común para etiquetas), pero puedes cambiarlo a mm80 si tu impresora usa ese tamaño
    final generator = Generator(PaperSize.mm58, profile);

    // Si se requiere más de una copia, repetimos los comandos N veces
    List<int> bytes = [];
    for (int i = 0; i < item.cantidad; i++) {
      bytes += _generateSingleLabel(generator, item);
      // Si no es la última etiqueta, añadimos un corte parcial para separar
      if (i < item.cantidad - 1) {
        bytes += generator.feed(2);
        bytes += generator.cut();
      }
    }
    // Al final, cortamos el papel completamente
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  static List<int> _generateSingleLabel(Generator generator, LabelItem item) {
    List<int> bytes = [];

    // Nombre del producto (centrado, negrita)
    bytes += generator.text(
      item.nombre,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // Precio (centrado, grande)
    bytes += generator.text(
      '\$${item.precio.toStringAsFixed(2)}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
      ),
    );

    // Código de barras (si existe)
    if (item.codigoBarras != null && item.codigoBarras!.isNotEmpty) {
      bytes += generator.feed(1);
      bytes += generator.barcode(
      Barcode.code128(item.codigoBarras!.codeUnits), 
      width: 2,
      height: 60,
      // 2. Se usa textPos con la constante del enum BarcodeText
      textPos: BarcodeText.below,
      );
    }

    // Línea separadora opcional
    bytes += generator.text(
      '----------------',
      styles: const PosStyles(align: PosAlign.center),
    );

    // Avance de papel para separar etiquetas
    bytes += generator.feed(2);

    return bytes;
  }
}