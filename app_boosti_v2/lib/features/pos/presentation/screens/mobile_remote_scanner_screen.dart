// lib/features/pos/presentation/screens/mobile_remote_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../providers/remote_scanner_provider.dart';

/// Escáner del móvil: lee un código y lo manda a la PC por Supabase
/// Realtime. La PC lo recibe en `InventoryCatalogScreen` y lo agrega al
/// carrito.
///
/// Esta pantalla es SOLO para el dispositivo que envía. La PC no la abre:
/// ella escucha desde el POS (ver `inventory_catalog_screen.dart`).
class MobileRemoteScannerScreen extends ConsumerStatefulWidget {
  const MobileRemoteScannerScreen({super.key});

  @override
  ConsumerState<MobileRemoteScannerScreen> createState() =>
      _MobileRemoteScannerScreenState();
}

class _MobileRemoteScannerScreenState
    extends ConsumerState<MobileRemoteScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    // El primer código puede venir sin `rawValue`; se busca el primero
    // legible, igual que `BarcodeScannerDialog`.
    String? code;
    for (final barcode in barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        code = raw.trim();
        break;
      }
    }
    if (code == null) return;

    setState(() => _isProcessing = true);

    final enviado =
        await ref.read(remoteScannerProvider.notifier).sendCode(code);

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          enviado ? '✅ Enviado: $code' : '⚠️ No se pudo enviar',
        ),
        backgroundColor: enviado ? Colors.green.shade700 : Colors.red.shade700,
        duration: const Duration(seconds: 1),
      ),
    );

    // Espera antes de aceptar otro escaneo: la cámara dispara muchas
    // lecturas por segundo y sin esto se enviaría el mismo código en
    // ráfaga.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner Remoto'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Marco de escaneo
          Center(
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Ayuda: qué hace y qué esperar en la PC.
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Apuntá al código de barras. La PC lo recibe y lo agrega '
                'al carrito al instante.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),

          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
        ],
      ),
    );
  }
}
