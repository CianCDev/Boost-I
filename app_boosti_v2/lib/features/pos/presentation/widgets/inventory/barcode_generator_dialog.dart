// lib/features/pos/presentation/widgets/productos/barcode_generator_dialog.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart' as barcode;
import '../../../data/Local/entities/isar_service.dart';
import '../../services/ticket_service.dart';
import '../../utils/responsive_helper.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class BarcodeGeneratorDialog extends ConsumerStatefulWidget {
  const BarcodeGeneratorDialog({super.key});

  @override
  ConsumerState<BarcodeGeneratorDialog> createState() =>
      _BarcodeGeneratorDialogState();
}

class _BarcodeGeneratorDialogState
    extends ConsumerState<BarcodeGeneratorDialog> {
  String _codigo = '';
  bool _cargando = true;
  final GlobalKey _previewKey = GlobalKey();

  static const _colorPrimary = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorInfo = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _generarCodigo();
  }

  Future<void> _generarCodigo() async {
    setState(() => _cargando = true);
    final codigo = await IsarService().generarCodigoBarrasUnico();
    if (!mounted) return;
    setState(() {
      _codigo = codigo;
      _cargando = false;
    });
  }

  Future<void> _compartirCodigo() async {
    try {
      final boundary = _previewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/codigo_barras.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Código de barras: $_codigo',
      );
    } catch (_) {}
  }

  Future<void> _imprimirCodigo() async {
    try {
      final boundary = _previewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      await TicketService.imprimirCodigoBarras(
        codigo: _codigo,
        imageBytes: imageBytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Código enviado a imprimir'),
          backgroundColor: _colorPrimary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Error: ${msg.length > 100 ? msg.substring(0, 100) : msg}'),
          backgroundColor: _colorDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final barcodeWidth = isMobile ? 200.0 : (isTablet ? 280.0 : 350.0);
    final barcodeHeight = isMobile ? 80.0 : (isTablet ? 100.0 : 120.0);

    return GlassDialog(
      maxWidth: 550,
      maxHeightFactor: 0.9,
      accentColor: _colorPrimary,
      scrollable: true,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.qr_code,
              title: 'Generar Código de Barras',
              subtitle: 'Comparte o imprime para etiquetas',
              color: _colorPrimary,
            ),
            const SizedBox(height: 20),

            // ===== PREVIEW =====
            if (_cargando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: _colorPrimary),
                ),
              )
            else
              RepaintBoundary(
                key: _previewKey,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHigh
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _codigo,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ===== BOTONES =====
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: OutlinedButton.icon(
                      onPressed: _generarCodigo,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Regenerar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MouseRegion(
                    cursor: _codigo.isEmpty
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: OutlinedButton.icon(
                      onPressed: _codigo.isEmpty ? null : _compartirCodigo,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Compartir'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _colorInfo,
                        side: BorderSide(
                          color: _colorInfo.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        backgroundColor: _colorInfo.withValues(alpha: 0.06),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MouseRegion(
                    cursor: _codigo.isEmpty
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: ElevatedButton.icon(
                      onPressed: _codigo.isEmpty ? null : _imprimirCodigo,
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Imprimir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}