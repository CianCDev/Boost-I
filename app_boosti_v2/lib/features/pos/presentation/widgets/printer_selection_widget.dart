import '../../presentation/providers/esc_pos_provider.dart';
import '../../domain/models/printer_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrinterSelectionDialog extends ConsumerStatefulWidget {
  const PrinterSelectionDialog({super.key});

  @override
  ConsumerState<PrinterSelectionDialog> createState() =>
      _PrinterSelectionDialogState();
}

class _PrinterSelectionDialogState
    extends ConsumerState<PrinterSelectionDialog> {
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
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.transparent,
          width: 1,
        ),
      ),
      backgroundColor: theme.cardColor,
      title: Text(
        'Conectar Impresora POS',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<PrinterType>(
                  value: _printerType,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PrinterType.usb,
                      child: Text('USB'),
                    ),
                    DropdownMenuItem(
                      value: PrinterType.bluetooth,
                      child: Text('Bluetooth'),
                    ),
                    DropdownMenuItem(
                      value: PrinterType.network,
                      child: Text('Red (LAN)'),
                    ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: theme.brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                    disabledForegroundColor: theme.brightness == Brightness.dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade600,
                  ),
                  onPressed: _isScanning ? null : _scan,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
            Divider(color: theme.dividerColor),
            Expanded(
              child: _isScanning
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.brightness == Brightness.dark
                            ? Colors.green.shade300
                            : const Color(0xFF10B981),
                      ),
                    )
                  : _devices.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron dispositivos.\nPresiona "Buscar" para escanear.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return ListTile(
                              leading: Icon(
                                Icons.print,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              title: Text(
                                device.name,
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                device.address ?? device.operatingSystem!,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.4),
                              ),
                              onTap: () {
                                ref
                                    .read(printerProvider.notifier)
                                    .seleccionarImpresora(device, _printerType);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Impresora "${device.name}" conectada.',
                                    ),
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
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.textTheme.bodyMedium?.color,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}