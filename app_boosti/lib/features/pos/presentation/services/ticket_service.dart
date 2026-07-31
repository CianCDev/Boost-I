import 'dart:io';
import 'dart:developer' as developer;
import 'package:app_gestion_m/features/pos/presentation/providers/esc_pos_printer_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TicketItem {
  final String nombre;
  final double cantidad;
  final double precio;
  final bool esPesado;

  TicketItem({
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.esPesado,
  });

  double get total => cantidad * precio;
}

class TicketService {
  /// Método Adapter: Traduce los datos de la UI al formato que consume la generación de PDF
  static Future<void> imprimirTicketVenta({
    required List<Map<String, dynamic>> items,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double cambio,
    double impuesto = 0.0,
    double subtotal = 0.0,
    DateTime? fechaVenta,
    SelectedPrinter? impresoraSeleccionada,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    final listItems = items.map((item) {
      return TicketItem(
        nombre: item['nombre']?.toString() ?? 'Producto',
        cantidad: (item['cantidad'] as num?)?.toDouble() ?? 1.0,
        precio: (item['precio'] as num?)?.toDouble() ?? 0.0,
        esPesado: item['esPesado'] as bool? ?? false,
      );
    }).toList();

    final subtotalCalculado = subtotal > 0
        ? subtotal
        : listItems.fold(0.0, (sum, item) => sum + item.total);

    await generarYProcesarPdf(
      items: listItems,
      subtotal: subtotalCalculado,
      impuesto: impuesto,
      total: total,
      metodoPago: metodoPago,
      montoRecibido: montoRecibido,
      vuelto: cambio,
      fechaVenta: fechaVenta,
      impresoraSeleccionada: impresoraSeleccionada,
    );
  }

  /// Diseña el PDF con formato de ticket térmico (80mm)
  static Future<pw.Document> generarDocumento({
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    final pdf = pw.Document();

    pw.Font fontRegular;
    pw.Font fontBold;

    try {
      fontRegular = await PdfGoogleFonts.robotoRegular();
      fontBold = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    final pageFormat = PdfPageFormat.roll80.copyWith(
      marginBottom: 10,
      marginTop: 10,
      marginLeft: 10,
      marginRight: 10,
    );

    final fechaLocal = (fechaVenta ?? DateTime.now()).toLocal();
    final String dia = fechaLocal.day.toString().padLeft(2, '0');
    final String mes = fechaLocal.month.toString().padLeft(2, '0');
    final String anio = fechaLocal.year.toString();
    final String hora = fechaLocal.hour.toString().padLeft(2, '0');
    final String min = fechaLocal.minute.toString().padLeft(2, '0');
    final String fechaFormateada = '$dia/$mes/$anio $hora:$min';

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Mi Negocio / Tienda',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      'Comprobante de Pago',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '------------------------------------------',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Fecha: $fechaFormateada', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Método de pago: ${metodoPago.toUpperCase()}', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),
              pw.Text('------------------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Cant x Producto',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Total',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              ...items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            '${item.cantidad % 1 == 0 ? item.cantidad.toInt() : item.cantidad.toStringAsFixed(3)}x ${item.nombre}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 4),
              pw.Text('------------------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),
              _filaTotal('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
              if (impuesto > 0) _filaTotal('Impuesto:', '\$${impuesto.toStringAsFixed(2)}'),
              pw.SizedBox(height: 2),
              _filaTotal('TOTAL:', '\$${total.toStringAsFixed(2)}', esBold: true),
              if (metodoPago.toLowerCase() == 'efectivo') ...[
                pw.SizedBox(height: 2),
                _filaTotal('Recibido:', '\$${montoRecibido.toStringAsFixed(2)}'),
                _filaTotal('Vuelto:', '\$${vuelto.toStringAsFixed(2)}'),
              ],
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  '¡Gracias por su compra!',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _filaTotal(String titulo, String valor, {bool esBold = false}) {
    final style = pw.TextStyle(
      fontSize: 8,
      fontWeight: esBold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(titulo, style: style),
        pw.Text(valor, style: style),
      ],
    );
  }

  /// Procesa la impresión silenciosa si hay hardware conectado; de lo contrario abre el diálogo de sistema
  static Future<void> generarYProcesarPdf({
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
    SelectedPrinter? impresoraSeleccionada,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    final pdf = await generarDocumento(
      items: items,
      subtotal: subtotal,
      impuesto: impuesto,
      total: total,
      metodoPago: metodoPago,
      montoRecibido: montoRecibido,
      vuelto: vuelto,
      fechaVenta: fechaVenta,
    );

    final bytes = await pdf.save();

    // 1. Respaldar PDF en disco en segundo plano
    _guardarEnDiscoSilencioso(bytes);

    // 2. Impresión Silenciosa Directa vs. Diálogo del Sistema
    if (impresoraSeleccionada != null) {
      try {
        final BasePrinterInput printerInput;

        if (impresoraSeleccionada.type == PrinterType.bluetooth) {
          printerInput = BluetoothPrinterInput(
            address: impresoraSeleccionada.device.address ?? '',
            name: impresoraSeleccionada.device.name,
          );
        } else if (impresoraSeleccionada.type == PrinterType.network) {
          printerInput = TcpPrinterInput(
            ipAddress: impresoraSeleccionada.device.address ?? '',
          );
        } else {
          printerInput = UsbPrinterInput(
            name: impresoraSeleccionada.device.name,
            vendorId: impresoraSeleccionada.device.vendorId,
            productId: impresoraSeleccionada.device.productId,
          );
        }

        await PrinterManager.instance.connect(
          type: impresoraSeleccionada.type,
          model: printerInput,
        );

        // Rasterizar el PDF a imágenes para garantizar máxima compatibilidad térmica
        await for (final page in Printing.raster(bytes, dpi: 203)) {
          final pngBytes = await page.toPng();
          final decodedImage = img.decodeImage(pngBytes);
          if (decodedImage != null) {
            await PrinterManager.instance.send(
              type: impresoraSeleccionada.type,
              bytes: img.encodePng(decodedImage),
            );
          }
        }
      } catch (e) {
        developer.log('Error en impresión silenciosa directa. Se abre diálogo de respaldo.', error: e);
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => bytes,
          name: 'Ticket_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } else {
      // Respaldo habitual mediante diálogo nativo
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Ticket_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
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
      developer.log(
        'Aviso: No se pudo respaldar el PDF en disco',
        name: 'PDF_BACKUP',
        error: e,
      );
    }
  }
}