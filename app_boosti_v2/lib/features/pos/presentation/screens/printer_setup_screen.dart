// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/models/printer_models.dart';
import '../services/printer_service.dart';
import '../utils/printer_storage.dart';

class PrinterSetupScreen extends StatefulWidget {
  const PrinterSetupScreen({super.key});

  @override
  State<PrinterSetupScreen> createState() => _PrinterSetupScreenState();
}

class _PrinterSetupScreenState extends State<PrinterSetupScreen> {
  final PrinterService _printerService = PrinterService();
  List<PrinterDevice> _foundPrinters = [];
  bool _isScanning = false;

  Future<void> _checkPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final location = await Permission.location.request();

    if (!bluetoothScan.isGranted || !location.isGranted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permisos necesarios'),
          content: const Text(
            'Para buscar impresoras Bluetooth necesitamos permisos de ubicación y Bluetooth.\n\n'
            'Por favor, actívalos desde los ajustes del sistema.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abrir ajustes'),
            ),
          ],
        ),
      );
      return;
    }
    _startScan();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _foundPrinters = [];
    });

    // ✅ AHORA DEVUELVE RESULTADOS
    final printers = await _printerService.scanBluetoothPrinters();

    setState(() {
      _foundPrinters = printers;
      _isScanning = false;
    });

    if (printers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron impresoras Bluetooth.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _selectPrinter(PrinterDevice printer) async {
    await PrinterStorage.savePrinter(printer);
    if (mounted) {
      Navigator.pop(context, printer);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Impresora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('¿Cómo conectar?'),
                  content: const Text(
                    '1. Asegúrate de que la impresora esté encendida.\n'
                    '2. Para Bluetooth: actívalo y pulsa "Buscar".\n'
                    '3. Para WiFi: pulsa "Agregar Red" e ingresa la IP.\n'
                    '4. Selecciona tu impresora de la lista.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _checkPermissions,
                    icon: _isScanning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bluetooth_searching),
                    label: Text(_isScanning ? 'Buscando...' : 'Buscar Bluetooth'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showAddNetworkPrinterDialog,
                    icon: const Icon(Icons.wifi),
                    label: const Text('Agregar Red'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _foundPrinters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isScanning ? Icons.search : Icons.print_disabled,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isScanning
                                ? 'Buscando impresoras...'
                                : 'No se encontraron impresoras\n\n'
                                    'Prueba a buscar Bluetooth o agregar una IP manualmente.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _foundPrinters.length,
                      itemBuilder: (context, index) {
                        final printer = _foundPrinters[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              printer.type == PrinterType.bluetooth
                                  ? Icons.bluetooth
                                  : Icons.wifi,
                              color: Colors.blue,
                            ),
                            title: Text(printer.name),
                            subtitle: Text(printer.address),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _selectPrinter(printer),
                          ),
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