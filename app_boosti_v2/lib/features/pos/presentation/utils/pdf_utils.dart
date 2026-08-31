import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';

class PdfUtils {
  /// Guarda el PDF en la carpeta [subcarpeta] con el nombre [nombreBase].pdf
  /// y lo abre con el visor predeterminado.
  static Future<void> guardarYAbirPDF({
    required List<int> bytes,
    required String nombreBase,
    String subcarpeta = 'PDFs',
  }) async {
    try {
      if (bytes.isEmpty) {
        debugPrint('⚠️ Bytes vacíos, no se guardará el PDF.');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/$subcarpeta';
      final folder = Directory(folderPath);
      if (!await folder.exists()) await folder.create(recursive: true);

      final fileName = '$nombreBase.pdf';
      final file = File('$folderPath/$fileName');
      await file.writeAsBytes(bytes);
      debugPrint('✅ PDF guardado: ${file.path}');

      // Abrir con visor predeterminado
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        debugPrint('⚠️ No se pudo abrir el PDF: ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ Error guardando/abriendo PDF: $e');
    }
  }
}