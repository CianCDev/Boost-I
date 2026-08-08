import 'package:esc_pos_utils_lts/esc_pos_utils_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:esc_pos_printer_lts/esc_pos_printer_lts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/models/printer_models.dart';
import '../../domain/enums/printer_error.dart';
import 'ticket_generator.dart';
import 'label_generator.dart'; // 👈 Importar el generador de etiquetas

class PrinterService {
  // =========================================================
  // 1. IMPRESIÓN POR RED (WIFI/ETHERNET) CON REINTENTOS
  // =========================================================
  Future<PrintResult> printViaNetwork({
    required PrinterDevice printer,
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    PrintResult? lastResult;

    while (attempts < maxRetries) {
      attempts++;
      _log('🔄 Intento $attempts de $maxRetries para impresión por red');

      try {
        final bytes = await TicketGenerator.generateTicketBytes(
          items: items,
          subtotal: subtotal,
          impuesto: impuesto,
          total: total,
          metodoPago: metodoPago,
          montoRecibido: montoRecibido,
          vuelto: vuelto,
          fechaVenta: fechaVenta,
        );

        const PaperSize paper = PaperSize.mm80;
        final profile = await CapabilityProfile.load();
        final networkPrinter = NetworkPrinter(paper, profile);

        // Conectar
        final connectResult = await networkPrinter.connect(
          printer.address,
          port: printer.port ?? 9100,
        );

        if (connectResult != PosPrintResult.success) {
          _log('❌ Error de conexión: ${connectResult.msg}');
          lastResult = PrintResult.failure(
            PrinterError.notConnected,
            'Error de conexión: ${connectResult.msg}',
          );
          continue; // Reintentar
        }

        // Enviar bytes (rawBytes es el método correcto según tu experiencia)
        networkPrinter.rawBytes(bytes);

        // Desconectar
         networkPrinter.disconnect();

        _log('✅ Impresión por red exitosa en intento $attempts');
        return PrintResult.success();
      } catch (e) {
        _log('❌ Error en intento $attempts: $e');
        lastResult = PrintResult.failure(PrinterError.unknown, e.toString());

        // Esperar antes de reintentar (excepto en el último intento)
        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    // Si llegamos aquí, todos los intentos fallaron
    return lastResult ?? PrintResult.failure(PrinterError.unknown, 'Falló la impresión');
  }

  // =========================================================
  // 2. IMPRESIÓN POR BLUETOOTH CON REINTENTOS
  // =========================================================
  Future<PrintResult> printViaBluetooth({
    required PrinterDevice printer,
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    PrintResult? lastResult;

    while (attempts < maxRetries) {
      attempts++;
      _log('🔄 Intento $attempts de $maxRetries para impresión por Bluetooth');

      try {
        final bytes = await TicketGenerator.generateTicketBytes(
          items: items,
          subtotal: subtotal,
          impuesto: impuesto,
          total: total,
          metodoPago: metodoPago,
          montoRecibido: montoRecibido,
          vuelto: vuelto,
          fechaVenta: fechaVenta,
        );

        // Conectar al dispositivo Bluetooth
        final device = BluetoothDevice.fromId(printer.address);
        await device.connect();

        // Descubrir servicios
        final services = await device.discoverServices();

        // Buscar la característica para impresión
        BluetoothCharacteristic? characteristic;
        for (final service in services) {
          for (final char in service.characteristics) {
            final uuid = char.uuid.toString().toLowerCase();
            if (uuid.contains('ffe1') || uuid.contains('abf1')) {
              characteristic = char;
              break;
            }
          }
          if (characteristic != null) break;
        }

        if (characteristic == null) {
          _log('❌ Característica no encontrada');
          lastResult = PrintResult.failure(
            PrinterError.unknown,
            'Característica de impresión no encontrada',
          );
          await device.disconnect();
          continue;
        }

        // Enviar bytes
        await characteristic.write(bytes, withoutResponse: true);

        // Desconectar
        await device.disconnect();

        _log('✅ Impresión por Bluetooth exitosa en intento $attempts');
        return PrintResult.success();
      } catch (e) {
        _log('❌ Error en intento $attempts: $e');
        lastResult = PrintResult.failure(PrinterError.unknown, e.toString());

        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    return lastResult ?? PrintResult.failure(PrinterError.unknown, 'Falló la impresión');
  }

  // =========================================================
  // 3. MÉTODO UNIFICADO PARA TICKETS
  // =========================================================
  Future<PrintResult> printTicket({
    required PrinterDevice printer,
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
  }) async {
    _log('📨 Iniciando impresión de ticket en ${printer.type.name}');

    switch (printer.type) {
      case PrinterType.bluetooth:
        return await printViaBluetooth(
          printer: printer,
          items: items,
          subtotal: subtotal,
          impuesto: impuesto,
          total: total,
          metodoPago: metodoPago,
          montoRecibido: montoRecibido,
          vuelto: vuelto,
          fechaVenta: fechaVenta,
        );
      case PrinterType.network:
        return await printViaNetwork(
          printer: printer,
          items: items,
          subtotal: subtotal,
          impuesto: impuesto,
          total: total,
          metodoPago: metodoPago,
          montoRecibido: montoRecibido,
          vuelto: vuelto,
          fechaVenta: fechaVenta,
        );
    }
  }

  // =========================================================
  // 4. PRUEBA DE CONEXIÓN (TICKET DE PRUEBA)
  // =========================================================
  Future<PrintResult> testPrinter(PrinterDevice printer) async {
    _log('🧪 Probando impresora: ${printer.name}');

    // Crear un ticket de prueba simple
    final testItems = [
      TicketItem(
        nombre: '---- PRUEBA ----',
        precio: 0,
        cantidad: 1,
        esPesado: false,
      ),
    ];

    return await printTicket(
      printer: printer,
      items: testItems,
      subtotal: 0,
      impuesto: 0,
      total: 0,
      metodoPago: 'prueba',
      montoRecibido: 0,
      vuelto: 0,
    );
  }

  // =========================================================
  // 5. ESCANEO BLUETOOTH CON FILTRADO
  // =========================================================
  Future<List<PrinterDevice>> scanBluetoothPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _log('🔍 Iniciando escaneo Bluetooth...');
    try {
      final List<PrinterDevice> foundDevices = [];

      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final device = result.device;
          final name = device.platformName.toLowerCase();

          // ✅ FILTRO: solo dispositivos que parezcan impresoras
          final isPrinter = name.contains('printer') ||
              name.contains('pos') ||
              name.contains('bt') ||
              name.contains('mp') ||
              name.contains('thermal') ||
              name.contains('bixolon') ||
              name.contains('zjiang') ||
              name.contains('epson');

          if (isPrinter &&
              device.platformName.isNotEmpty &&
              !foundDevices.any((d) => d.address == device.remoteId.str)) {
            _log('📟 Impresora encontrada: ${device.platformName} (${device.remoteId.str})');
            foundDevices.add(PrinterDevice(
              name: device.platformName,
              address: device.remoteId.str,
              type: PrinterType.bluetooth,
            ));
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: timeout);
      await Future.delayed(timeout);
      await FlutterBluePlus.stopScan();
      await subscription.cancel();

      _log('✅ Escaneo completado. ${foundDevices.length} impresoras encontradas.');
      return foundDevices;
    } catch (e) {
      _log('❌ Error en escaneo Bluetooth: $e');
      return [];
    }
  }

  // =========================================================
  // 🆕 6. IMPRESIÓN DE ETIQUETAS (NUEVO)
  // =========================================================
  Future<PrintResult> printLabel({
    required PrinterDevice printer,
    required List<LabelItem> labels,
    int maxRetries = 2,
  }) async {
    _log('🏷️ Iniciando impresión de ${labels.length} etiqueta(s)');

    // Generar bytes para todas las etiquetas
    List<int> allBytes = [];
    for (final label in labels) {
      final bytes = await LabelGenerator.generateLabelBytes(item: label);
      allBytes.addAll(bytes);
    }

    int attempts = 0;
    PrintResult? lastResult;

    while (attempts < maxRetries) {
      attempts++;
      _log('🔄 Intento $attempts de $maxRetries para imprimir etiquetas');

      try {
        if (printer.type == PrinterType.network) {
          // Impresión por red
          const PaperSize paper = PaperSize.mm58; // Usamos 58mm para etiquetas
          final profile = await CapabilityProfile.load();
          final networkPrinter = NetworkPrinter(paper, profile);

          final connectResult = await networkPrinter.connect(
            printer.address,
            port: printer.port ?? 9100,
          );
          if (connectResult != PosPrintResult.success) {
            _log('❌ Error de conexión: ${connectResult.msg}');
            lastResult = PrintResult.failure(
              PrinterError.notConnected,
              'Error de conexión: ${connectResult.msg}',
            );
            continue;
          }

          networkPrinter.rawBytes(allBytes);
           networkPrinter.disconnect();

          _log('✅ Etiquetas impresas por red en intento $attempts');
          return PrintResult.success();
        } else if (printer.type == PrinterType.bluetooth) {
          // Impresión por Bluetooth
          final device = BluetoothDevice.fromId(printer.address);
          await device.connect();

          final services = await device.discoverServices();
          BluetoothCharacteristic? characteristic;
          for (final service in services) {
            for (final char in service.characteristics) {
              final uuid = char.uuid.toString().toLowerCase();
              if (uuid.contains('ffe1') || uuid.contains('abf1')) {
                characteristic = char;
                break;
              }
            }
            if (characteristic != null) break;
          }

          if (characteristic == null) {
            _log('❌ Característica no encontrada');
            await device.disconnect();
            lastResult = PrintResult.failure(
              PrinterError.unknown,
              'Característica de impresión no encontrada',
            );
            continue;
          }

          await characteristic.write(allBytes, withoutResponse: true);
          await device.disconnect();

          _log('✅ Etiquetas impresas por Bluetooth en intento $attempts');
          return PrintResult.success();
        } else {
          throw Exception('Tipo de impresora no soportado para etiquetas');
        }
      } catch (e) {
        _log('❌ Error en intento $attempts: $e');
        lastResult = PrintResult.failure(PrinterError.unknown, e.toString());

        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    return lastResult ?? PrintResult.failure(PrinterError.unknown, 'Falló la impresión de etiquetas');
  }

  // =========================================================
  // LOGS CON TIMESTAMP
  // =========================================================
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(0, 19);
    debugPrint('[$timestamp] [PrinterService] $message');
  }
}