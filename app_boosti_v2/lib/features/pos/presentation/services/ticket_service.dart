import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data'; 
import '../../presentation/providers/esc_pos_provider.dart';
import '../../domain/models/printer_models.dart';


import 'package:app_boosti_v2/features/pos/domain/enums/printer_error.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'printer_service.dart';
import 'ticket_generator.dart' show TicketItem;

class TicketService {
  /// Método principal: intenta impresión directa ESC/POS, si falla usa PDF.
  static Future<void> imprimirTicketVenta({
    required BuildContext context, // ← PARA MOSTRAR SNACKBARS
    required List<TicketItem> items,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double cambio,
    double impuesto = 0.0,
    double subtotal = 0.0,
    DateTime? fechaVenta,
    PrinterDevice? impresoraSeleccionada,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    final subtotalCalculado = subtotal > 0
        ? subtotal
        : items.fold(0.0, (sum, item) => sum + item.total);

    // 1. Intentar impresión directa ESC/POS
    if (impresoraSeleccionada != null) {
      // Mostrar indicador de carga
      final snackBar = SnackBar(
        content: Row(
          children: const [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Imprimiendo ticket...'),
          ],
        ),
        duration: const Duration(seconds: 10),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      try {
        final printerService = PrinterService();
        final result = await printerService.printTicket(
          printer: impresoraSeleccionada,
          items: items,
          subtotal: subtotalCalculado,
          impuesto: impuesto,
          total: total,
          metodoPago: metodoPago,
          montoRecibido: montoRecibido,
          vuelto: cambio,
          fechaVenta: fechaVenta,
        );

        // Cerrar el SnackBar de carga
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).clearSnackBars();

        if (result.success) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ticket impreso correctamente'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        } else {
          // Error específico
          String errorMessage = _getErrorMessage(result.error);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al imprimir: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          developer.log('Fallo en impresión ESC/POS: ${result.message}');
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).clearSnackBars();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        developer.log('Error en impresión ESC/POS: $e');
      }
    }

    // 2. Fallback: PDF
    final pdf = await _generarDocumentoFallback(
      items: items,
      subtotal: subtotalCalculado,
      impuesto: impuesto,
      total: total,
      metodoPago: metodoPago,
      montoRecibido: montoRecibido,
      vuelto: cambio,
      fechaVenta: fechaVenta,
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Ticket_${DateTime.now().millisecondsSinceEpoch}',
    );

    _guardarEnDiscoSilencioso(bytes);
  }

  // ============================================================
  // MENSAJES DE ERROR AMIGABLES
  // ============================================================
  static String _getErrorMessage(PrinterError error) {
    switch (error) {
      case PrinterError.none:
        return 'Sin errores';
      case PrinterError.notConnected:
        return 'No se pudo conectar a la impresora. ¿Está encendida y en la misma red?';
      case PrinterError.outOfPaper:
        return 'La impresora no tiene papel. Por favor, recárgala.';
      case PrinterError.offline:
        return 'La impresora está fuera de línea. Verifica la conexión.';
      case PrinterError.timeout:
        return 'Tiempo de espera agotado. La impresora no responde.';
      case PrinterError.unknown:
        return 'Error desconocido. Intenta de nuevo.';
    }
  }

  // ============================================================
  // GENERAR PDF (COPIA TU CÓDIGO AQUÍ)
  // ============================================================
  static Future<pw.Document> _generarDocumentoFallback({
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
  }) async {
    // 📌 COPIA AQUÍ TU MÉTODO DE PDF COMPLETO
    // (No lo pongo completo para no alargar, pero tú ya lo tienes)
    final pdf = pw.Document();
    // ... tu lógica de PDF ...
    return pdf;
  }

  static Future<void> _guardarEnDiscoSilencioso(List<int> bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/Tickets_POS';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      final fileName = 'Ticket_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('$folderPath/$fileName');
      await file.writeAsBytes(bytes);
    } catch (e) {
      developer.log('Aviso: No se pudo respaldar el PDF en disco', error: e);
    }
  }

  /// Imprime una etiqueta con un código de barras
/// Imprime una etiqueta con un código de barras (SIEMPRE CON DIÁLOGO DEL SISTEMA)
static Future<void> imprimirCodigoBarras({
  required String codigo,
  required Uint8List imageBytes,
  SelectedPrinter? impresoraSeleccionada,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('📄 Generando PDF para código: $codigo');

  try {
    // 1. Generar documento PDF con el código y la imagen
    final pdf = pw.Document();
    pw.Font fontRegular;
    try {
      fontRegular = await PdfGoogleFonts.robotoRegular();
    } catch (_) {
      fontRegular = pw.Font.helvetica();
    }

    final pageFormat = PdfPageFormat.roll80.copyWith(
      marginLeft: 10,
      marginRight: 10,
      marginTop: 10,
      marginBottom: 10,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        theme: pw.ThemeData.withFont(base: fontRegular),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Código de Barras',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Image(pw.MemoryImage(imageBytes), width: 200, height: 80),
                pw.SizedBox(height: 10),
                pw.Text(
                  codigo,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    debugPrint('✅ PDF generado, tamaño: ${bytes.length} bytes');

    // 2. Guardar copia en disco (opcional)
    _guardarEnDiscoSilencioso(bytes);

    // 3. Siempre usar el diálogo del sistema (más fiable)
    debugPrint('📤 Abriendo diálogo de impresión del sistema...');
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Codigo_Barras_$codigo',
    );
    debugPrint('✅ Diálogo de impresión cerrado');
    
  } catch (e) {
    debugPrint('❌ Error en imprimirCodigoBarras: $e');
    rethrow; // Para que el llamador maneje el error
  }
}
}