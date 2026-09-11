import 'dart:typed_data';
import 'label_generator.dart';

class LabelPdfGenerator {
  static Future<Uint8List> generateLabelPdf({
    required List<LabelItem> labels,
    String title = 'Etiquetas de Productos',
  }) async {
    return Uint8List(0); // Byte array vacío para web
  }

  static Future<void> sharePdf({
    required List<LabelItem> labels,
    String title = 'Etiquetas',
  }) async {
    // No hacer nada en web
  }
}