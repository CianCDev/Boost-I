import 'package:app_gestion_m/features/pos/presentation/providers/esc_pos_printer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class PrinterSelectionDialog extends ConsumerStatefulWidget {
  const PrinterSelectionDialog({super.key});

  @override
  ConsumerState<PrinterSelectionDialog> createState() => _PrinterSelectionDialogState();
}

class _PrinterSelectionDialogState extends ConsumerState<PrinterSelectionDialog> {
  PrinterType _printerType = PrinterType.usb;
  final List<PrinterDevice> _devices = [];
  bool _isScanning = false;

  void _scan() {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    PrinterManager.instance.discovery(type: _printerType).listen((device) {
      setState(() {
        _devices.add(device);
      });
    }).onDone(() {
      setState(() => _isScanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conectar Impresora POS'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<PrinterType>(
                  value: _printerType,
                  items: const [
                    DropdownMenuItem(value: PrinterType.usb, child: Text('USB')),
                    DropdownMenuItem(value: PrinterType.bluetooth, child: Text('Bluetooth')),
                    DropdownMenuItem(value: PrinterType.network, child: Text('Red (LAN)')),
                  ],
                  onChanged: (type) {
                    if (type != null) {
                      setState(() => _printerType = type);
                      _scan();
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scan,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        return ListTile(
                          title: Text(device.name),
                          subtitle: Text(device.address ?? device.operatingSystem),
                          trailing: const Icon(Icons.print),
                          onTap: () {
                            ref.read(printerProvider.notifier).seleccionarImpresora(
                                  device,
                                  _printerType,
                                );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Impresora ${device.name} conectada correctamente.'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}