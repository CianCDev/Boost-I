import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1. DEFINICIÓN DEL PROVIDER PARA RIVERPOD
final escPosPrinterServiceProvider = Provider<EscPosPrinterService>((ref) {
  return EscPosPrinterService();
});

class EscPosPrinterService {
  final PrinterManager _printerManager = PrinterManager.instance;

  // Estado interno para almacenar la impresora configurada
  PrinterDevice? _selectedPrinter;
  PrinterType _selectedPrinterType = PrinterType.usb;

  /// Getter para comprobar si hay una impresora vinculada/seleccionada
  bool get hayImpresoraConectada => _selectedPrinter != null;

  /// Método para guardar la impresora activa en la app
  void establecerImpresora(PrinterDevice device, PrinterType type) {
    _selectedPrinter = device;
    _selectedPrinterType = type;
  }

  /// Método principal para generar e imprimir el recibo de venta
  Future<bool> imprimirTicketVenta({
    required double totalUsd,
    required double tasaBcv,
    required String metodoPago,
    required double montoRecibido,
    required double vueltoUsd,
    required double vueltoBs,
    required List<Map<String, dynamic>> desglosePagos,
    String nombreNegocio = 'MI NEGOCIO C.A.',
    String rif = 'J-12345678-9',
    String direccion = 'Valencia, Venezuela',
    String numFactura = '00001',
    List<Map<String, dynamic>> productos = const [],
    PrinterDevice? printerDevice,
    PrinterType? printerType,
  }) async {
    final targetDevice = printerDevice ?? _selectedPrinter;
    final targetType = printerType ?? _selectedPrinterType;

    // Si no hay impresora configurada ni enviada por parámetro, se interrumpe
    if (targetDevice == null) return false;

    try {
      final double totalBs = totalUsd * tasaBcv;

      // 1. Cargar el perfil estándar de la impresora (POS-58 / POS-80)
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      List<int> bytes = [];

      // --- ENCABEZADO ---
      bytes += generator.text(
        nombreNegocio,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text('RIF: $rif', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text(direccion, styles: const PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(1);

      bytes += generator.text(
        'TICKET N°: $numFactura',
        styles: const PosStyles(bold: true, align: PosAlign.left),
      );
      bytes += generator.text(
        'FECHA: ${_fechaActual()}',
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.text(
        'TASA BCV: Bs. ${tasaBcv.toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.hr();

      // --- DETALLE DE PRODUCTOS (SI SE PROPORCIONAN) ---
      if (productos.isNotEmpty) {
        bytes += generator.row([
          PosColumn(text: 'Cant/Producto', width: 6, styles: const PosStyles(bold: true)),
          PosColumn(text: 'P.Unit', width: 3, styles: const PosStyles(bold: true, align: PosAlign.right)),
          PosColumn(text: 'Total\$', width: 3, styles: const PosStyles(bold: true, align: PosAlign.right)),
        ]);
        bytes += generator.hr();

        for (var prod in productos) {
          final cant = prod['cantidad'] ?? 1;
          final nombre = prod['nombre'] ?? 'Producto';
          final precio = (prod['precio'] as num).toDouble();
          final subtotal = cant * precio;

          bytes += generator.row([
            PosColumn(text: '${cant}x $nombre', width: 6),
            PosColumn(text: precio.toStringAsFixed(2), width: 3, styles: const PosStyles(align: PosAlign.right)),
            PosColumn(text: subtotal.toStringAsFixed(2), width: 3, styles: const PosStyles(align: PosAlign.right)),
          ]);
        }
        bytes += generator.hr();
      }

      // --- TOTALES DUALES ---
      bytes += generator.row([
        PosColumn(text: 'TOTAL USD:', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: '\$${totalUsd.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(bold: true, align: PosAlign.right, height: PosTextSize.size1),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: 'TOTAL BS:', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: 'Bs. ${totalBs.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);

      bytes += generator.hr();

      // --- FORMA DE PAGO Y DESGLOSE MIXTO ---
      bytes += generator.text('Forma de Pago: $metodoPago', styles: const PosStyles(bold: true));

      if (desglosePagos.isNotEmpty) {
        for (var pago in desglosePagos) {
          final metodo = pago['metodo'] ?? '';
          final mUsd = (pago['montoUsd'] as num?)?.toDouble() ?? 0.0;
          final mBs = (pago['montoBs'] as num?)?.toDouble() ?? 0.0;

          if (mBs > 0) {
            bytes += generator.text(' - $metodo: Bs. ${mBs.toStringAsFixed(2)}');
          } else {
            bytes += generator.text(' - $metodo: \$${mUsd.toStringAsFixed(2)}');
          }
        }
      }

      if (vueltoUsd > 0) {
        bytes += generator.text('Vuelto (\$): \$${vueltoUsd.toStringAsFixed(2)}');
        bytes += generator.text('Vuelto (Bs): Bs. ${vueltoBs.toStringAsFixed(2)}');
      }

      bytes += generator.emptyLines(1);
      bytes += generator.text(
        '¡Gracias por su compra!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.emptyLines(2);

      // Corte de papel
      bytes += generator.cut();

      // 2. Configurar el canal de conexión
      final BasePrinterInput printerInput;

      if (targetType == PrinterType.bluetooth) {
        printerInput = BluetoothPrinterInput(
          address: targetDevice.address ?? '',
          name: targetDevice.name,
        );
      } else if (targetType == PrinterType.network) {
        printerInput = TcpPrinterInput(
          ipAddress: targetDevice.address ?? '',
        );
      } else {
        printerInput = UsbPrinterInput(
          name: targetDevice.name,
          vendorId: targetDevice.vendorId,
          productId: targetDevice.productId,
        );
      }

      // Conectar e imprimir
      await _printerManager.connect(
        type: targetType,
        model: printerInput,
      );

      final result = await _printerManager.send(
        type: targetType,
        bytes: bytes,
      );

      return result;
    } catch (e) {
      debugPrint('Error en la impresión del ticket: $e');
      return false;
    }
  }

  String _fechaActual() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}