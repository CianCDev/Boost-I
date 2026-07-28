import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class PrinterSelectorDialog extends StatefulWidget {
  const PrinterSelectorDialog({super.key});

  @override
  State<PrinterSelectorDialog> createState() => _PrinterSelectorDialogState();
}

class _PrinterSelectorDialogState extends State<PrinterSelectorDialog> {
  final PrinterManager _printerManager = PrinterManager.instance;
  PrinterType _selectedType = PrinterType.usb;
  final List<PrinterDevice> _devices = [];
  StreamSubscription? _subscription;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _devices.clear();
      _isScanning = true;
    });

    _subscription?.cancel();
    _subscription = _printerManager.discovery(type: _selectedType).listen((device) {
      if (!_devices.any((element) => element.address == device.address)) {
        setState(() {
          _devices.add(device);
        });
      }
    }, onDone: () {
      setState(() => _isScanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.print, color: Color(0xFF10B981)),
          SizedBox(width: 8),
          Text('Conectar Impresora'),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<PrinterType>(
              segments: const [
                ButtonSegment(value: PrinterType.usb, label: Text('USB'), icon: Icon(Icons.usb)),
                ButtonSegment(value: PrinterType.bluetooth, label: Text('Bluetooth'), icon: Icon(Icons.bluetooth)),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<PrinterType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
                _startScan();
              },
            ),
            const SizedBox(height: 16),
            _isScanning && _devices.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  )
                : _devices.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No se encontraron impresoras. Verifica que estén encendidas y conectadas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return ListTile(
                              leading: Icon(
                                _selectedType == PrinterType.usb ? Icons.usb : Icons.bluetooth,
                                color: const Color(0xFF10B981),
                              ),
                              title: Text(device.name.isNotEmpty ? device.name : 'Impresora Térmica'),
                              subtitle: Text(device.address ?? 'Sin dirección'),
                              onTap: () => Navigator.of(context).pop(device),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _startScan,
          child: const Text('REESCANEAR'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}