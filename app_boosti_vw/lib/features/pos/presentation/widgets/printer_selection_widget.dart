// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/printer_models.dart';
import '../../domain/enums/printer_error.dart';
import '../services/printer_service.dart';
import '../providers/esc_pos_provider.dart';
import 'dialogos_genericos/succes_dialog.dart';
import '../widgets/dialogos_genericos/error_dialog.dart';
import '../widgets/dialogos_genericos/confirm_dialog.dart';

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
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    // Obtener la impresora seleccionada actualmente
    final current = ref.read(printerProvider);
    _selectedAddress = current?.device.address;
  }

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
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            title: 'Sin dispositivos',
            content: 'No se encontraron impresoras Bluetooth disponibles.',
          ),
        );
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error de escaneo',
            content: 'Ocurrió un error: $e',
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
        title: const Text('Agregar impresora de red'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Impresora Oficina',
                  prefixIcon: Icon(Icons.print_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'Dirección IP',
                  hintText: 'Ej: 192.168.1.100',
                  prefixIcon: Icon(Icons.wifi_rounded),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              const Text(
                'Puerto: 9100 (por defecto)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
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
    setState(() => _selectedAddress = printer.address);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => SuccessDialog(
        title: '¡Impresora seleccionada!',
        content: '${printer.name} (${printer.address}) está lista para usar.',
      ),
    );
  }

  // ============================================================
  // PROBAR IMPRESORA
  // ============================================================
  Future<void> _testPrinter(PrinterDevice printer) async {
    // Mostrar un diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Probando impresora...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await _printerService.testPrinter(printer);
      Navigator.pop(context); // cerrar diálogo de carga

      if (result.success) {
        showDialog(
          context: context,
          builder: (_) => const SuccessDialog(
            title: 'Prueba exitosa',
            content: 'La impresora funciona correctamente.',
          ),
        );
      } else {
        String errorMessage = _getErrorMessage(result.error ?? PrinterError.unknown);
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Prueba fallida',
            content: errorMessage,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // cerrar diálogo de carga
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(
          title: 'Error',
          content: 'Error inesperado: $e',
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
  // CONFIRMAR DESCONEXIÓN (opcional)
  // ============================================================
  void _confirmDisconnect() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Desconectar impresora',
        content: '¿Estás seguro de que deseas desconectar la impresora actual?',
        confirmText: 'Desconectar',
        confirmColor: Colors.red,
        onConfirm: () {
          ref.read(printerProvider.notifier).deseleccionarImpresora();
          setState(() => _selectedAddress = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impresora desconectada'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD CON GLASSMORPHISM
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final currentPrinter = ref.watch(printerProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: isMobile ? double.infinity : 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          // ✨ Glassmorphism
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]!.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: Theme.of(context).brightness == Brightness.dark
                ? const ColorFilter.mode(Colors.transparent, BlendMode.srcOver)
                : const ColorFilter.mode(Colors.white, BlendMode.srcOver),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.print_rounded, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Conectar Impresora',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (currentPrinter != null)
                              Text(
                                'Actual: ${currentPrinter.device.name}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (currentPrinter != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.red),
                          tooltip: 'Desconectar',
                          onPressed: _confirmDisconnect,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // CONTROLES
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<PrinterType>(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? Colors.blue.withValues(alpha: 0.15)
                                  : Colors.transparent,
                            ),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: PrinterType.bluetooth,
                              label: Text('Bluetooth'),
                              icon: Icon(Icons.bluetooth_rounded),
                            ),
                            ButtonSegment(
                              value: PrinterType.network,
                              label: Text('WiFi'),
                              icon: Icon(Icons.wifi_rounded),
                            ),
                          ],
                          selected: {_printerType},
                          onSelectionChanged: (newType) {
                            setState(() {
                              _printerType = newType.first;
                              _devices.clear();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isScanning ? null : _scan,
                        icon: _isScanning
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search_rounded),
                        label: Text(_isScanning ? 'Buscando...' : 'Buscar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // LISTA DE DISPOSITIVOS
                  Expanded(
                    child: _isScanning
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Buscando impresoras...'),
                              ],
                            ),
                          )
                        : _devices.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 60,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _printerType == PrinterType.bluetooth
                                          ? 'No se encontraron impresoras Bluetooth.\n'
                                              'Asegúrate de que estén encendidas.'
                                          : 'Presiona "Buscar" para escanear WiFi\no agrega una IP manualmente.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _devices.length,
                                itemBuilder: (context, index) {
                                  final device = _devices[index];
                                  final isSelected =
                                      _selectedAddress == device.address;

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    elevation: isSelected ? 0 : 1,
                                    color: isSelected
                                        ? Colors.green.withValues(alpha: 0.08)
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: isSelected
                                          ? BorderSide(
                                              color: Colors.green.shade400,
                                              width: 2,
                                            )
                                          : BorderSide.none,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: device.type ==
                                                  PrinterType.bluetooth
                                              ? Colors.blue.withValues(alpha: 0.1)
                                              : Colors.orange.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          device.type == PrinterType.bluetooth
                                              ? Icons.bluetooth_rounded
                                              : Icons.wifi_rounded,
                                          color: device.type ==
                                                  PrinterType.bluetooth
                                              ? Colors.blue
                                              : Colors.orange,
                                        ),
                                      ),
                                      title: Text(
                                        device.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        device.address,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Botón de prueba
                                          IconButton(
                                            icon: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.orange,
                                            ),
                                            tooltip: 'Probar impresora',
                                            onPressed: () =>
                                                _testPrinter(device),
                                            splashRadius: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          if (isSelected)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'ACTIVA',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            )
                                          else
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 16,
                                              color: Colors.grey.shade400,
                                            ),
                                        ],
                                      ),
                                      onTap: () => _selectPrinter(device),
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 12),
                  // BOTÓN CERRAR
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}