import 'dart:io';
import 'dart:developer' as developer;
import 'package:app_boosti_v2/features/pos/domain/enums/printer_error.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/printer_models.dart';
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
        ScaffoldMessenger.of(context).clearSnackBars();

        if (result.success) {
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
        ScaffoldMessenger.of(context).clearSnackBars();
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
}