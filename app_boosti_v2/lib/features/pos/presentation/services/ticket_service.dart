import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/printer_models.dart';
import '../../domain/enums/printer_error.dart';
import '../../data/Local/entities/local_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import 'printer_service.dart';
import 'ticket_generator.dart';

class TicketService {
  /// Método principal: intenta impresión directa ESC/POS, si falla usa PDF.
  static Future<void> imprimirTicketVenta({
    required BuildContext context,
    required List<TicketItem> items,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double cambio,
    double impuesto = 0.0,
    double subtotal = 0.0,
    DateTime? fechaVenta,
    PrinterDevice? impresoraSeleccionada,
    LocalEntity? local,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    local ??= await IsarService().obtenerLocalActivo();

    final subtotalCalculado = subtotal > 0
        ? subtotal
        : items.fold(0.0, (sum, item) => sum + item.total);

    if (impresoraSeleccionada != null) {
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
          local: local,
        );

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

    // Fallback: PDF
    final pdf = await _generarDocumentoFallback(
      items: items,
      subtotal: subtotalCalculado,
      impuesto: impuesto,
      total: total,
      metodoPago: metodoPago,
      montoRecibido: montoRecibido,
      vuelto: cambio,
      fechaVenta: fechaVenta,
      local: local,
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
  static String _getErrorMessage(PrinterError? error) {
    if (error == null) return 'Error desconocido';
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
  // GENERAR PDF FALLBACK
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
    LocalEntity? local,
  }) async {
    final pdf = pw.Document();
    await PdfGoogleFonts.robotoRegular(); // Forzamos carga para tener la fuente

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          marginLeft: 10,
          marginRight: 10,
          marginTop: 10,
          marginBottom: 10,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (local != null) ...[
                pw.Center(
                  child: pw.Text(
                    local.nombre,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                if (local.direccion != null && local.direccion!.isNotEmpty)
                  pw.Center(child: pw.Text(local.direccion!)),
                if (local.telefono != null && local.telefono!.isNotEmpty)
                  pw.Center(child: pw.Text('Tel: ${local.telefono}')),
                if (local.email != null && local.email!.isNotEmpty)
                  pw.Center(child: pw.Text('Email: ${local.email}')),
                if (local.rif != null && local.rif!.isNotEmpty)
                  pw.Center(child: pw.Text('RIF: ${local.rif}')),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
              ],
              pw.Text('Fecha: ${fechaVenta?.toLocal().toString() ?? DateTime.now().toLocal().toString()}'),
              pw.Text('Método: $metodoPago'),
              pw.SizedBox(height: 8),
              ...items.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text('${item.cantidad.toStringAsFixed(item.esPesado ? 3 : 0)}x ${item.nombre}'),
                    ),
                    pw.Text('\$${item.total.toStringAsFixed(2)}'),
                  ],
                );
              }).toList(),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:'),
                  pw.Text('\$${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Impuesto:'),
                  pw.Text('\$${impuesto.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Recibido:'),
                  pw.Text('\$${montoRecibido.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Vuelto:'),
                  pw.Text('\$${vuelto.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text('¡Gracias por su compra!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  // ============================================================
  // GUARDAR PDF EN DISCO (FALLBACK)
  // ============================================================
  static Future<void> _guardarEnDiscoSilencioso(List<int> bytes) async {
    try {
      if (bytes.isEmpty) {
        developer.log('⚠️ Bytes vacíos, no se guardará el PDF.');
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/Tickets_POS';
      final folder = Directory(folderPath);
      if (!await folder.exists()) await folder.create(recursive: true);
      final fileName = 'Ticket_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('$folderPath/$fileName');
      await file.writeAsBytes(bytes);
    } catch (e) {
      developer.log('❌ Error guardando PDF: $e');
    }
  }

  // ============================================================
  // 🆕 IMPRIMIR CÓDIGO DE BARRAS (como método estático)
  // ============================================================
  static Future<void> imprimirCodigoBarras({
    required String codigo,
    required Uint8List imageBytes,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('📄 Generando PDF para código: $codigo');

    try {
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
          build: (context) {
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

      // Guardar copia en disco
      await _guardarEnDiscoSilencioso(bytes);

      // Mostrar diálogo de impresión del sistema
      debugPrint('📤 Abriendo diálogo de impresión del sistema...');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Codigo_Barras_$codigo',
      );
      debugPrint('✅ Diálogo de impresión cerrado');
    } catch (e) {
      debugPrint('❌ Error en imprimirCodigoBarras: $e');
      rethrow;
    }
  }
}