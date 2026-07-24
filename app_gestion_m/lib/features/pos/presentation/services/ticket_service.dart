import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

// Modelo simple para definir los artículos del ticket
class TicketItem {
  final String nombre;
  final int cantidad;
  final double precio;

  TicketItem({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  double get total => cantidad * precio;
}

class TicketService {
  /// Diseña el PDF con formato de ticket térmico (80mm)
  static Future<pw.Document> generarDocumento({
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
  }) async {
    final pdf = pw.Document();

    // Formato estándar para impresoras térmicas de 80mm
    final pageFormat = PdfPageFormat.roll80.copyWith(
      marginBottom: 10,
      marginTop: 10,
      marginLeft: 10,
      marginRight: 10,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PUNTO DE VENTA',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Text('Comprobante de Pago', style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '------------------------------------------',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),

              // Datos de la transacción
              pw.SizedBox(height: 4),
              pw.Text('Fecha: ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Método de pago: ${metodoPago.toUpperCase()}', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),
              pw.Text('------------------------------------------', style: const pw.TextStyle(fontSize: 8)),

              // Lista de Productos
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Cant x Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
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
                      child: pw.Text('${item.cantidad}x ${item.nombre}', style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('\$${item.total.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8)),
                    ),
                  ],
                ),
              )),

              pw.SizedBox(height: 4),
              pw.Text('------------------------------------------', style: const pw.TextStyle(fontSize: 8)),

              // Totales
              pw.SizedBox(height: 4),
              _filaTotal('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
              if (impuesto > 0) _filaTotal('Impuesto:', '\$${impuesto.toStringAsFixed(2)}'),
              pw.SizedBox(height: 2),
              _filaTotal('TOTAL:', '\$${total.toStringAsFixed(2)}', esBold: true),

              if (metodoPago == 'efectivo') ...[
                pw.SizedBox(height: 2),
                _filaTotal('Recibido:', '\$${montoRecibido.toStringAsFixed(2)}'),
                _filaTotal('Vuelto:', '\$${vuelto.toStringAsFixed(2)}'),
              ],

              // Mensaje final
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('¡Gracias por su compra!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
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

  /// Procesa la impresión directamente y guarda copia en background sin bloquear
  static Future<void> generarYProcesarPdf({
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
  }) async {
    final pdf = await generarDocumento(
      items: items,
      subtotal: subtotal,
      impuesto: impuesto,
      total: total,
      metodoPago: metodoPago,
      montoRecibido: montoRecibido,
      vuelto: vuelto,
    );

    final bytes = await pdf.save();

    // 1. Tarea secundaria: guardar en disco sin bloquear la interfaz
    _guardarEnDiscoSilencioso(bytes);

    // 2. Invocar la ventana nativa de impresión
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Ticket_${DateTime.now().millisecondsSinceEpoch}',
    );
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
      // Evita interrupciones en la pantalla si el SO niega permisos de archivo
      print('Aviso: No se pudo respaldar el PDF en disco: $e');
    }
  }
}