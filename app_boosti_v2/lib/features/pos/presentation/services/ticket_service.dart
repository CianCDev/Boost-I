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

/// Tipo de ticket para organizar archivos y formato
enum TicketType { venta, cierre, codigo }

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
    TicketType tipo = TicketType.venta,
    Map<String, double>? totalesPorMetodo, // Para cierre
    double? totalGeneral, // Para cierre
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    local ??= await IsarService().obtenerLocalActivo();

    final subtotalCalculado = subtotal > 0
        ? subtotal
        : items.fold(0.0, (sum, item) => sum + item.total);

    // Si es cierre y no se pasaron totales, los extraemos de los items (fallback)
    if (tipo == TicketType.cierre && totalesPorMetodo == null) {
      // Los items tienen formato: nombre: "CIERRE DE CAJA - ..." y luego "  Método:"
      // Extraer los métodos
      final Map<String, double> extraidos = {};
      for (var item in items) {
        final nombre = item.nombre.trim();
        if (nombre.startsWith('  ') && nombre.endsWith(':')) {
          final metodo = nombre.substring(2, nombre.length - 1).trim();
          extraidos[metodo] = item.precio;
        }
      }
      totalesPorMetodo = extraidos;
      totalGeneral = total;
    }

    // Intentar impresión ESC/POS si hay impresora seleccionada
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
          esCierre: tipo == TicketType.cierre,
          totalesPorMetodo: totalesPorMetodo,
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
      tipo: tipo,
      totalesPorMetodo: totalesPorMetodo,
      totalGeneral: totalGeneral ?? total,
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: _generarNombreArchivo(tipo),
    );

    _guardarEnDiscoSilencioso(bytes, tipo: tipo);
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
    TicketType tipo = TicketType.venta,
    Map<String, double>? totalesPorMetodo,
    double? totalGeneral,
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
          if (tipo == TicketType.cierre) {
            return _buildCierrePdf(
              context,
              local: local,
              totalesPorMetodo: totalesPorMetodo ?? {},
              totalGeneral: totalGeneral ?? total,
              fecha: fechaVenta ?? DateTime.now(),
            );
          } else {
            return _buildVentaPdf(
              context,
              local: local,
              items: items,
              subtotal: subtotal,
              impuesto: impuesto,
              total: total,
              metodoPago: metodoPago,
              montoRecibido: montoRecibido,
              vuelto: vuelto,
              fecha: fechaVenta ?? DateTime.now(),
            );
          }
        },
      ),
    );
    return pdf;
  }

  // ============================================================
  // PDF PARA VENTA (formato original mejorado)
  // ============================================================
  static pw.Widget _buildVentaPdf(
    pw.Context context, {
    required LocalEntity? local,
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    required DateTime fecha,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Encabezado del local
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
        // Fecha y método
        pw.Text('Fecha: ${fecha.toLocal().toString().substring(0, 16)}'),
        pw.Text('Método: $metodoPago'),
        pw.SizedBox(height: 8),
        // Items
        ...items.map((item) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                    '${item.cantidad.toStringAsFixed(item.esPesado ? 3 : 0)}x ${item.nombre}'),
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
            pw.Text('\$${total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
          child: pw.Text('¡Gracias por su compra!',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  // ============================================================
  // PDF PARA CIERRE DE CAJA (NUEVO FORMATO PROFESIONAL)
  // ============================================================
  static pw.Widget _buildCierrePdf(
    pw.Context context, {
    required LocalEntity? local,
    required Map<String, double> totalesPorMetodo,
    required double totalGeneral,
    required DateTime fecha,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Encabezado del local
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
        // Título
        pw.Center(
          child: pw.Text(
            'CIERRE DE CAJA',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            fecha.toLocal().toString().substring(0, 16),
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(),
        pw.SizedBox(height: 8),
        // Desglose por método
        pw.Text('Resumen de ventas:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...totalesPorMetodo.entries.map((entry) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(entry.key),
              pw.Text('\$${entry.value.toStringAsFixed(2)}'),
            ],
          );
        }).toList(),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TOTAL GENERAL',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '\$${totalGeneral.toStringAsFixed(2)}',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Text(
            'Cierre realizado correctamente.',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            '¡Gracias por su trabajo!',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GUARDAR PDF EN DISCO CON ORGANIZACIÓN POR TIPO
  // ============================================================
  static Future<void> _guardarEnDiscoSilencioso(
    List<int> bytes, {
    TicketType tipo = TicketType.venta,
  }) async {
    try {
      if (bytes.isEmpty) {
        developer.log('⚠️ Bytes vacíos, no se guardará el PDF.');
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      String subfolder;
      String prefix;
      switch (tipo) {
        case TicketType.venta:
          subfolder = 'Ventas';
          prefix = 'Venta';
          break;
        case TicketType.cierre:
          subfolder = 'Cierres';
          prefix = 'Cierre';
          break;
        case TicketType.codigo:
          subfolder = 'Codigos';
          prefix = 'Codigo';
          break;
      }
      final folderPath = '${directory.path}/Tickets_POS/$subfolder';
      final folder = Directory(folderPath);
      if (!await folder.exists()) await folder.create(recursive: true);

      final now = DateTime.now();
      final fechaStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = '${prefix}_$fechaStr.pdf';
      final file = File('$folderPath/$fileName');
      await file.writeAsBytes(bytes);
      developer.log('✅ PDF guardado en: $folderPath/$fileName');
    } catch (e) {
      developer.log('❌ Error guardando PDF: $e');
    }
  }

  // ============================================================
  // GENERAR NOMBRE DE ARCHIVO PARA IMPRESIÓN
  // ============================================================
  static String _generarNombreArchivo(TicketType tipo) {
    final now = DateTime.now();
    final fechaStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final prefix = tipo == TicketType.venta
        ? 'Venta'
        : tipo == TicketType.cierre
            ? 'Cierre'
            : 'Codigo';
    return '${prefix}_$fechaStr';
  }

  // ============================================================
  // 🆕 IMPRIMIR CÓDIGO DE BARRAS (actualizado)
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

      // Guardar copia en disco (tipo codigo)
      await _guardarEnDiscoSilencioso(bytes, tipo: TicketType.codigo);

      // Mostrar diálogo de impresión del sistema
      debugPrint('📤 Abriendo diálogo de impresión del sistema...');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: _generarNombreArchivo(TicketType.codigo),
      );
      debugPrint('✅ Diálogo de impresión cerrado');
    } catch (e) {
      debugPrint('❌ Error en imprimirCodigoBarras: $e');
      rethrow;
    }
  }
}