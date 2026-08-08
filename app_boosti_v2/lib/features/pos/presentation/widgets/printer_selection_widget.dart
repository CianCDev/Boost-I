// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/printer_models.dart';
import '../../domain/enums/printer_error.dart';
import '../services/printer_service.dart';
import '../providers/esc_pos_provider.dart';

class PrinterSelectionDialog extends ConsumerStatefulWidget {
  const PrinterSelectionDialog({super.key});

  @override
  ConsumerState<PrinterSelectionDialog> createState() =>
      _PrinterSelectionDialogState();
}

class _PrinterSelectionDialogState
    extends ConsumerState<PrinterSelectionDialog> {
  final PrinterService _printerService = PrinterService();
  PrinterType _printerType = PrinterType.bluetooth;
  final List<PrinterDevice> _devices = [];
  bool _isScanning = false;

  // ============================================================
  // ESCANEO DE DISPOSITIVOS
  // ============================================================
  Future<void> _scan() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      List<PrinterDevice> results = [];

      if (_printerType == PrinterType.bluetooth) {
        results = await _printerService.scanBluetoothPrinters(
          timeout: const Duration(seconds: 8),
        );
      } else if (_printerType == PrinterType.network) {
        _showAddNetworkPrinterDialog();
        setState(() => _isScanning = false);
        return;
      }

      setState(() {
        _devices.addAll(results);
        _isScanning = false;
      });

      if (results.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron impresoras.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============================================================
  // AGREGAR IMPRESORA DE RED MANUAL
  // ============================================================
  void _showAddNetworkPrinterDialog() {
    final ipController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Impresora de Red (WiFi)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la impresora',
                hintText: 'Ej: Impresora Oficina',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'Dirección IP',
                hintText: 'Ej: 192.168.1.100',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            const Text(
              'Puerto: 9100 (por defecto)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (ipController.text.isNotEmpty) {
                final printer = PrinterDevice(
                  name: nameController.text.isNotEmpty
                      ? nameController.text
                      : 'Impresora Red',
                  address: ipController.text.trim(),
                  type: PrinterType.network,
                  port: 9100,
                );
                Navigator.pop(context);
                _selectPrinter(printer);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECCIONAR IMPRESORA
  // ============================================================
  void _selectPrinter(PrinterDevice printer) {
    ref.read(printerProvider.notifier).seleccionarImpresora(printer, printer.type);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Impresora "${printer.name}" seleccionada.'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  // ============================================================
  // PROBAR IMPRESORA
  // ============================================================
  Future<void> _testPrinter(PrinterDevice printer) async {
    // Mostrar indicador de prueba
    final snackBar = SnackBar(
      content: Row(
        children: const [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Probando impresora...'),
        ],
      ),
      duration: const Duration(seconds: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      final result = await _printerService.testPrinter(printer);

      // Cerrar el SnackBar de carga
      ScaffoldMessenger.of(context).clearSnackBars();

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Prueba exitosa. La impresora funciona correctamente.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        String errorMessage = _getErrorMessage(result.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Prueba fallida: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error inesperado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getErrorMessage(PrinterError error) {
    switch (error) {
      case PrinterError.none:
        return 'Sin errores';
      case PrinterError.notConnected:
        return 'No se pudo conectar. ¿Está encendida?';
      case PrinterError.outOfPaper:
        return 'Sin papel. Recarga la impresora.';
      case PrinterError.offline:
        return 'Impresora fuera de línea.';
      case PrinterError.timeout:
        return 'Tiempo de espera agotado.';
      case PrinterError.unknown:
        return 'Error desconocido.';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conectar Impresora POS'),
      content: SizedBox(
        width: 400,
        height: 400, // Aumentamos altura para el botón de prueba
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<PrinterType>(
                  value: _printerType,
                  items: const [
                    DropdownMenuItem(
                      value: PrinterType.bluetooth,
                      child: Text('Bluetooth'),
                    ),
                    DropdownMenuItem(
                      value: PrinterType.network,
                      child: Text('Red (WiFi)'),
                    ),
                  ],
                  onChanged: (type) {
                    if (type != null) {
                      setState(() => _printerType = type);
                      setState(() => _devices.clear());
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scan,
                  icon: const Icon(Icons.search),
                  label: Text(_isScanning ? 'Buscando...' : 'Buscar'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : _devices.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron dispositivos.\n'
                            'Presiona "Buscar" para escanear Bluetooth,\n'
                            'o selecciona "Red (WiFi)" para ingresar una IP.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            final isSelected =
                                ref.watch(printerProvider)?.device.address ==
                                    device.address;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: isSelected ? Colors.green.shade50 : null,
                              child: ListTile(
                                leading: Icon(
                                  device.type == PrinterType.bluetooth
                                      ? Icons.bluetooth
                                      : Icons.wifi,
                                  color: isSelected ? Colors.green : Colors.blue,
                                ),
                                title: Text(device.name),
                                subtitle: Text(device.address),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ✅ BOTÓN DE PRUEBA
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow,
                                          color: Colors.orange),
                                      tooltip: 'Probar impresora',
                                      onPressed: () => _testPrinter(device),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.arrow_forward_ios,
                                      color: isSelected ? Colors.green : Colors.grey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                onTap: () => _selectPrinter(device),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}