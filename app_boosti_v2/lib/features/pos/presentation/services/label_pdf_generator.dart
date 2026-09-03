// lib/features/pos/presentation/services/label_pdf_generator.dart
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'label_generator.dart';

class LabelPdfGenerator {
  /// Genera un PDF con etiquetas en formato A4 (2 columnas, diseño mejorado)
  static Future<Uint8List> generateLabelPdf({
    required List<LabelItem> labels,
    String title = 'Etiquetas de Productos',
  }) async {
    final pdf = pw.Document();

    // Configuración de página A4 con márgenes reducidos para más espacio
    final pageFormat = PdfPageFormat.a4.copyWith(
      marginTop: 15,
      marginBottom: 15,
      marginLeft: 15,
      marginRight: 15,
    );

    // Etiquetas por página (2 columnas x 3 filas = 6 etiquetas más grandes)
    final labelsPerPage = 6;

    for (var i = 0; i < labels.length; i += labelsPerPage) {
      final pageLabels = labels.skip(i).take(labelsPerPage).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          build: (context) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Título centrado
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  // Grid de etiquetas (2 columnas)
                  pw.GridView(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75, // Más ancho que alto
                    children: pageLabels.map((label) {
                      return _buildLabelCard(label);
                    }).toList(),
                  ),
                ],
              ),
            ];
          },
        ),
      );
    }

    return pdf.save();
  }

  /// Construye una tarjeta de etiqueta mejorada
  static pw.Widget _buildLabelCard(LabelItem label) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 0.8,
        ),
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.white,
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey300,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Nombre del producto (más grande)
          pw.Text(
            label.nombre,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
            textAlign: pw.TextAlign.center,
            maxLines: 2,
          ),
          pw.SizedBox(height: 6),
          // Precio (más grande)
          pw.Text(
            '\$${label.precio.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 8),
          // Código de barras (más grande)
          if (label.codigoBarras != null && label.codigoBarras!.isNotEmpty)
            pw.Container(
              height: 50,
              child: _buildBarcodeWidget(label.codigoBarras!),
            ),
          pw.SizedBox(height: 6),
          // Código en texto (más visible)
          if (label.codigoBarras != null && label.codigoBarras!.isNotEmpty)
            pw.Text(
              label.codigoBarras!,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  /// Genera el código de barras para el PDF (con tamaño aumentado)
  static pw.Widget _buildBarcodeWidget(String code) {
    try {
      return pw.BarcodeWidget(
        barcode: pw.Barcode.code128(),
        data: code,
        width: 140, // Más ancho
        height: 50, // Más alto
        drawText: false,
      );
    } catch (e) {
      // Fallback: mostrar solo texto
      return pw.Text(
        code,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      );
    }
  }

  /// Genera y comparte el PDF usando printing
  static Future<void> sharePdf({
    required List<LabelItem> labels,
    String title = 'Etiquetas',
  }) async {
    try {
      final pdfBytes = await generateLabelPdf(labels: labels, title: title);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'etiquetas_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      debugPrint('❌ Error al generar/compartir PDF: $e');
      rethrow;
    }
  }
}