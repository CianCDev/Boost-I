// lib/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart
import 'package:flutter/material.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});
  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escáner de código de barras'),
      content: const Text('El escáner no está disponible en la versión web.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}