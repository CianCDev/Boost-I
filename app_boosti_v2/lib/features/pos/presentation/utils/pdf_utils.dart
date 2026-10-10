// lib/features/pos/presentation/utils/pdf_utils.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class PdfUtils {
  /// Guarda el PDF en la carpeta [subcarpeta] con el nombre
  /// [nombreBase].pdf y devuelve su ruta.
  ///
  /// Crea la carpeta si no existe. Devuelve `null` si falla, sin lanzar:
  /// llamar a esto nunca debe tumbar el flujo que lo invoca (una venta, un
  /// envío a cocina).
  ///
  /// R.3.3: se separó de [guardarYAbrirPDF] porque el ticket de cocina
  /// necesita la RUTA para compartirla por el share sheet, y abrirla de
  /// golpe mientras se genera sería molestar: el cocinero quiere enviarla
  /// por WhatsApp, no ver un visor abriéndose encima.
  static Future<String?> guardarPdf({
    required List<int> bytes,
    required String nombreBase,
    String subcarpeta = 'PDFs',
  }) async {
    if (bytes.isEmpty) {
      debugPrint('⚠️ Bytes vacíos, no se guardará el PDF.');
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/$subcarpeta';
      final folder = Directory(folderPath);
      if (!await folder.exists()) await folder.create(recursive: true);

      final file = File('$folderPath/$nombreBase.pdf');
      await file.writeAsBytes(bytes);
      debugPrint('✅ PDF guardado: ${file.path}');

      return file.path;
    } catch (e) {
      debugPrint('❌ Error guardando PDF: $e');
      return null;
    }
  }

  /// Guarda el PDF en la carpeta [subcarpeta] con el nombre [nombreBase].pdf
  /// y lo abre con el visor predeterminado.
  static Future<void> guardarYAbrirPDF({
    required List<int> bytes,
    required String nombreBase,
    String subcarpeta = 'PDFs',
  }) async {
    try {
      final ruta = await guardarPdf(
        bytes: bytes,
        nombreBase: nombreBase,
        subcarpeta: subcarpeta,
      );
      if (ruta == null) return;

      // Abrir con visor predeterminado
      final result = await OpenFilex.open(ruta);
      if (result.type != ResultType.done) {
        debugPrint('⚠️ No se pudo abrir el PDF: ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ Error guardando/abriendo PDF: $e');
    }
  }
}
