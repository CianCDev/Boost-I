// lib/features/pos/presentation/widgets/printer_selection_widget.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/printer_models.dart';
import '../../domain/enums/printer_error.dart';
import '../services/printer_service.dart';
import '../providers/esc_pos_provider.dart';
import 'common/glass_dialog.dart';
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

  // ═══════════════════════════════════════════════════════════════════
  // PLATAFORMA
  // ═══════════════════════════════════════════════════════════════════

  /// ¿Esta plataforma soporta escaneo Bluetooth con `flutter_blue_plus`?
  ///
  /// Soporta:
  ///   - Android
  ///   - iOS
  ///   - macOS
  ///
  /// NO soporta (lanza "Unsupported operation"):
  ///   - Windows
  ///   - Linux
  ///   - Web
  ///
  /// ⚠️ Usamos `defaultTargetPlatform` en vez de `Platform` (dart:io)
  ///    para no romper builds web. Es la forma idiomática en Flutter.
  bool get _bluetoothSoportado {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();

    // 🎯 Si la plataforma no soporta Bluetooth, arrancamos en modo Red.
    //    Así el usuario no se topa con un botón que no funciona.
    if (!_bluetoothSoportado) {
      _printerType = PrinterType.network;
    }

    final current = ref.read(printerProvider);
    _selectedAddress = current?.device.address;
  }

  // ═══════════════════════════════════════════════════════════════════
  // ESCANEO / AGREGAR
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _scan() async {
    // ── Modo Red: abrir diálogo de IP directamente ──
    if (_printerType == PrinterType.network) {
      _showAddNetworkPrinterDialog();
      return;
    }

    // ── Modo Bluetooth: validar plataforma ──
    if (!_bluetoothSoportado) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            title: 'Bluetooth no disponible',
            content:
                'El escaneo Bluetooth solo funciona en Android, iOS y macOS.\n\n'
                'En esta plataforma usa una impresora de red (WiFi).',
          ),
        );
      }
      return;
    }

    // ── Escaneo Bluetooth real ──
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      final results = await _printerService.scanBluetoothPrinters(
        timeout: const Duration(seconds: 8),
      );

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

  // ═══════════════════════════════════════════════════════════════════
  // AGREGAR IMPRESORA DE RED MANUAL
  // ═══════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════
  // SELECCIONAR
  // ═══════════════════════════════════════════════════════════════════

  void _selectPrinter(PrinterDevice printer) {
    ref
        .read(printerProvider.notifier)
        .seleccionarImpresora(printer, printer.type);
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

  // ═══════════════════════════════════════════════════════════════════
  // PROBAR
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _testPrinter(PrinterDevice printer) async {
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
      Navigator.pop(context);

      if (result.success) {
        showDialog(
          context: context,
          builder: (_) => const SuccessDialog(
            title: 'Prueba exitosa',
            content: 'La impresora funciona correctamente.',
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Prueba fallida',
            content: _getErrorMessage(result.error ?? PrinterError.unknown),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
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

  // ═══════════════════════════════════════════════════════════════════
  // DESCONECTAR
  // ═══════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════
  // WIDGETS INTERNOS
  // ═══════════════════════════════════════════════════════════════════

  /// Segmentado adaptativo. Solo incluye "Bluetooth" si la plataforma
  /// lo soporta. En Windows/Linux/Web queda únicamente "WiFi".
  Widget _buildSegmented(bool isCompact) {
    final segments = <ButtonSegment<PrinterType>>[];

    if (_bluetoothSoportado) {
      segments.add(
        ButtonSegment(
          value: PrinterType.bluetooth,
          icon: const Icon(Icons.bluetooth_rounded),
          label: isCompact ? null : const Text('Bluetooth'),
          tooltip: 'Buscar por Bluetooth',
        ),
      );
    }

    segments.add(
      ButtonSegment(
        value: PrinterType.network,
        icon: const Icon(Icons.wifi_rounded),
        label: isCompact ? null : const Text('WiFi'),
        tooltip: 'Agregar impresora de red',
      ),
    );

    return SegmentedButton<PrinterType>(
      showSelectedIcon: !isCompact,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: isCompact ? 14 : 16,
            vertical: 12,
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.blue.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
      ),
      segments: segments,
      selected: {_printerType},
      onSelectionChanged: (newType) {
        setState(() {
          _printerType = newType.first;
          _devices.clear();
        });
      },
    );
  }

  /// Botón principal: "Buscar" en Bluetooth, "Agregar" en Red.
  /// Si `isCompact`, se convierte en un IconButton para ganar espacio.
  Widget _buildSearchButton(bool isCompact) {
    final isNetworkMode = _printerType == PrinterType.network;

    final icon = _isScanning
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Icon(isNetworkMode ? Icons.add_rounded : Icons.search_rounded);

    final label = _isScanning
        ? 'Buscando...'
        : (isNetworkMode ? 'Agregar' : 'Buscar');

    if (isCompact) {
      return IconButton.filled(
        onPressed: _isScanning ? null : _scan,
        icon: icon,
        style: IconButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
        ),
        tooltip: isNetworkMode
            ? 'Agregar impresora de red'
            : 'Buscar impresoras',
      );
    }

    return ElevatedButton.icon(
      onPressed: _isScanning ? null : _scan,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Bloque de controles con layout responsive.
  ///
  /// Desktop/Tablet (≥ 500px):
  ///   [ SegmentedButton (expanded) ] [ Buscar/Agregar ]
  ///
  /// Mobile (≥ 400px):
  ///   [ SegmentedButton — ancho completo           ]
  ///   [                              Buscar/Agregar ]
  ///
  /// Compacto (< 400px):
  ///   [ Solo iconos WiFi | BT ] [ 🔍/＋ ]
  Widget _buildControls({
    required bool isMobile,
    required bool isCompact,
  }) {
    final segmented = _buildSegmented(isCompact);
    final actionButton = _buildSearchButton(isCompact);

    // ── Desktop / Tablet: 1 fila ──
    if (!isMobile) {
      return Row(
        children: [
          Expanded(child: segmented),
          const SizedBox(width: 12),
          actionButton,
        ],
      );
    }

    // ── Mobile: 2 filas ──
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        segmented,
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: actionButton,
        ),
      ],
    );
  }

  /// Texto contextual según el modo activo y la plataforma.
  String _emptyStateText() {
    if (_printerType == PrinterType.bluetooth) {
      return 'No se encontraron impresoras Bluetooth.\n'
          'Asegúrate de que estén encendidas.';
    }
    return 'Presiona "Agregar" para configurar una impresora\n'
        'de red por IP (ej: 192.168.1.100).';
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 500;
    final isCompact = screenWidth < 400;

    final currentPrinter = ref.watch(printerProvider);

    return GlassDialog(
      maxWidth: 500,
      maxHeightFactor: 0.8,
      accentColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ HEADER ═══
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.print_rounded,
                    color: Colors.blue,
                  ),
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                if (currentPrinter != null)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                    ),
                    tooltip: 'Desconectar',
                    onPressed: _confirmDisconnect,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // ═══ CONTROLES ═══
            _buildControls(
              isMobile: isMobile,
              isCompact: isCompact,
            ),
            const SizedBox(height: 16),

            // ═══ LISTA DE DISPOSITIVOS ═══
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: Text(
                                  _emptyStateText(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
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
                            final isBluetooth =
                                device.type == PrinterType.bluetooth;

                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isBluetooth
                                        ? Colors.blue.withValues(alpha: 0.1)
                                        : Colors.orange
                                            .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isBluetooth
                                        ? Icons.bluetooth_rounded
                                        : Icons.wifi_rounded,
                                    color: isBluetooth
                                        ? Colors.blue
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  device.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  device.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.orange,
                                      ),
                                      tooltip: 'Probar impresora',
                                      onPressed: () => _testPrinter(device),
                                      splashRadius: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
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

            // ═══ BOTÓN CERRAR ═══
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
    );
  }
}