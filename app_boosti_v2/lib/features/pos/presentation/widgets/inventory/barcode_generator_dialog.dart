import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart' as barcode;
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/esc_pos_provider.dart';
import '../../services/ticket_service.dart';
import '../../utils/responsive_helper.dart';

class BarcodeGeneratorDialog extends ConsumerStatefulWidget {
  const BarcodeGeneratorDialog({super.key});

  @override
  ConsumerState<BarcodeGeneratorDialog> createState() => _BarcodeGeneratorDialogState();
}

class _BarcodeGeneratorDialogState extends ConsumerState<BarcodeGeneratorDialog> {
  String _codigo = '';
  bool _cargando = true;
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _generarCodigo();
  }

  Future<void> _generarCodigo() async {
    setState(() => _cargando = true);
    final codigo = await IsarService().generarCodigoBarrasUnico();
    setState(() {
      _codigo = codigo;
      _cargando = false;
    });
  }

  Future<void> _compartirCodigo() async {
    try {
      final boundary = _previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/codigo_barras.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Código de barras: $_codigo');
    } catch (e) {
      // ignore
    }
  }

  Future<void> _imprimirCodigo() async {
    try {
      final boundary = _previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final impresora = ref.read(printerProvider);
      await TicketService.imprimirCodigoBarras(
        codigo: _codigo,
        imageBytes: bytes,
        impresoraSeleccionada: impresora,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Código enviado a imprimir'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().substring(0, 100)}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    final double barcodeWidth = isMobile ? 200.0 : (isTablet ? 280.0 : 350.0);
    final double barcodeHeight = isMobile ? 80.0 : (isTablet ? 100.0 : 120.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
      child: Container(
        width: isMobile ? double.infinity : 500,
        constraints: BoxConstraints(maxWidth: 550),
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code, color: Color(0xFF10B981), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Generar Código de Barras',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preview del código
            if (_cargando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              )
            else
              RepaintBoundary(
                key: _previewKey,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      barcode.BarcodeWidget(
                        barcode: barcode.Barcode.code128(),
                        data: _codigo,
                        width: barcodeWidth,
                        height: barcodeHeight,
                        drawText: false,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          _codigo,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ✅ SECCIÓN DE BOTONES CORREGIDA CON WRAP (Responsive)
            Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 8,   // Espacio horizontal entre botones
              runSpacing: 8, // Espacio vertical si bajan a la siguiente línea
              children: [
                OutlinedButton.icon(
                  onPressed: _generarCodigo,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Regenerar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _codigo.isEmpty ? null : _compartirCodigo,
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text('Compartir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _codigo.isEmpty ? null : _imprimirCodigo,
                  icon: const Icon(Icons.print_rounded, size: 20),
                  label: const Text('Imprimir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}