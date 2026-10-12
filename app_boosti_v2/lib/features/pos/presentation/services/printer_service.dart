// lib/features/pos/presentation/services/printer_service.dart
import 'package:esc_pos_utils_lts/esc_pos_utils_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:esc_pos_printer_lts/esc_pos_printer_lts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/Local/entities/local_entity.dart';
import '../../domain/enums/printer_error.dart';
import '../../domain/models/printer_models.dart';
import 'label_generator.dart';
import 'error_service.dart';
import 'ticket_generator.dart';

/// Descarga y cachea el logo del local para imprimirlo en los tickets.
///
/// Vive acá, y no en `TicketGenerator`, porque el generador es síncrono
/// y la descarga de Storage es async.
///
/// La cache es por path y no tiene expiration: el nombre del archivo lleva
/// un timestamp (`logo_1699...png`), así que un logo nuevo es un path
/// nuevo. El viejo se queda en memoria — son unos pocos KB.
Future<List<int>?> resolverLogoDelLocal(String? logoPath) async {
  // Diagnóstico 2026-10-12 (temporal, sacar tras el smoke test).
  //
  // El síntoma "el ticket sale sin logo" es indistinguible entre tres
  // causas, y antes no había forma de separarlas: (a) el local no tiene
  // logo, (b) el path no llega al call site, (c) RLS del bucket lo
  // rechaza. En (a) y (b) se salía por el `return null` de abajo SIN
  // excepción, así que el `catch` no reportaba nada y Sentry tampoco.
  if (logoPath == null || logoPath.isEmpty) {
    debugPrint('🔍 [_resolverLogoDelLocal] logoPath vacío — no hay logo '
        'para descargar. El local no tiene logoPath o no se hidrató.');
    return null;
  }

  final cache = _logoCache;
  final hit = cache[logoPath];
  if (hit != null) return hit;

  // Va DESPUÉS del hit de cache a propósito: si se imprimiera antes,
  // anunciaría una descarga que no ocurre (la cache la evita), y el log
  // mentiría justo cuando uno está depurando la descarga.
  debugPrint('🔍 [_resolverLogoDelLocal] Intentando descargar: $logoPath');

  try {
    final bytes = await Supabase.instance.client.storage
        .from('locales')
        .download(logoPath);
    debugPrint('✅ [_resolverLogoDelLocal] Descargados ${bytes.length} bytes');

    final decodificada = img.decodeImage(bytes);
    if (decodificada == null) {
      debugPrint('❌ [_resolverLogoDelLocal] Los ${bytes.length} bytes NO '
          'son una imagen decodificable.');
      return null;
    }

    // `PaperSize.mm80` de la impresora son 558 dots de ancho. 512 deja
    // un margen de ~23 dots por lado: se centra sin recortar.
    final redimensionada = decodificada.width > _anchoMaxLogo
        ? img.copyResize(decodificada, width: _anchoMaxLogo)
        : decodificada;
    final finales = img.encodePng(redimensionada);

    cache[logoPath] = finales;
    return finales;
  } catch (e, stack) {
    // Un logo caído NO puede impedir la venta. Se reporta y se sigue.
    debugPrint('❌ [_resolverLogoDelLocal] Falló la descarga de $logoPath: $e');
    ErrorService.captureError(e,
        stack: stack, hint: 'resolverLogoDelLocal_fallo');
    return null;
  }
}

const int _anchoMaxLogo = 512;
final Map<String, List<int>> _logoCache = {};

class PrinterService {
  // =========================================================
  // IMPRESIÓN POR RED (WIFI/ETHERNET)
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
    LocalEntity? local,
    int maxRetries = 2,
    bool esCierre = false,
    Map<String, double>? totalesPorMetodo,

    // ── Extras Venta al Mayor (opcionales) ──
    TicketCliente? cliente,
    List<TicketPago>? pagos,
    String tipoVenta = 'detal',
    String? tipoDocumento,
    double tasaBcv = 0.0,
    double montoDescuentoTotal = 0.0,
    bool requiereAutorizacion = false,
    String? autorizadoPorNombre,
    String? vendedor,

    /// Numeración fiscal (`P123-2026-0001`). Se propaga al generador;
    /// si es null el ticket imprime "N° pendiente".
    String? numeroFactura,
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
          local: local,
          esCierre: esCierre,
          totalesPorMetodo: totalesPorMetodo,
          cliente: cliente,
          pagos: pagos,
          tipoVenta: tipoVenta,
          tipoDocumento: tipoDocumento,
          tasaBcv: tasaBcv,
          montoDescuentoTotal: montoDescuentoTotal,
          requiereAutorizacion: requiereAutorizacion,
          autorizadoPorNombre: autorizadoPorNombre,
          vendedor: vendedor,
          numeroFactura: numeroFactura,
          logoBytes: await resolverLogoDelLocal(local?.logoPath),
        );

        const PaperSize paper = PaperSize.mm80;
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

        networkPrinter.rawBytes(bytes);
        networkPrinter.disconnect();

        _log('✅ Impresión por red exitosa en intento $attempts');
        return PrintResult.success();
      } catch (e) {
        _log('❌ Error en intento $attempts: $e');
        lastResult = PrintResult.failure(PrinterError.unknown, e.toString());
        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    return lastResult ??
        PrintResult.failure(PrinterError.unknown, 'Falló la impresión');
  }

  // =========================================================
  // IMPRESIÓN POR BLUETOOTH
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
    LocalEntity? local,
    int maxRetries = 2,
    bool esCierre = false,
    Map<String, double>? totalesPorMetodo,

    // ── Extras Venta al Mayor (opcionales) ──
    TicketCliente? cliente,
    List<TicketPago>? pagos,
    String tipoVenta = 'detal',
    String? tipoDocumento,
    double tasaBcv = 0.0,
    double montoDescuentoTotal = 0.0,
    bool requiereAutorizacion = false,
    String? autorizadoPorNombre,
    String? vendedor,

    /// Numeración fiscal (`P123-2026-0001`). Se propaga al generador;
    /// si es null el ticket imprime "N° pendiente".
    String? numeroFactura,
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
          local: local,
          esCierre: esCierre,
          totalesPorMetodo: totalesPorMetodo,
          cliente: cliente,
          pagos: pagos,
          tipoVenta: tipoVenta,
          tipoDocumento: tipoDocumento,
          tasaBcv: tasaBcv,
          montoDescuentoTotal: montoDescuentoTotal,
          requiereAutorizacion: requiereAutorizacion,
          autorizadoPorNombre: autorizadoPorNombre,
          vendedor: vendedor,
          numeroFactura: numeroFactura,
          logoBytes: await resolverLogoDelLocal(local?.logoPath),
        );

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

        await characteristic.write(bytes, withoutResponse: true);
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

    return lastResult ??
        PrintResult.failure(PrinterError.unknown, 'Falló la impresión');
  }

  // =========================================================
  // BYTES CRUDOS (R.3.3 · ticket de cocina)
  // =========================================================

  /// Envía [bytes] YA GENERADOS a la impresora, sin pasar por
  /// [TicketGenerator].
  ///
  /// Existe porque el ticket de cocina tiene su propio formato (sin
  /// precios) y [printTicket] genera los bytes internamente desde
  /// `TicketItem`, que además exige `precio`. Meter un ticket de cocina
  /// por ahí imprimiría `$0.00` por línea o, peor, obligaría a tocar
  /// `_buildItemRow` y arriesgar el ticket de venta.
  ///
  /// Aditivo: no cambia el comportamiento de ningún método existente.
  /// [printTicket] sigue igual; quien tiene su formato propio genera sus
  /// bytes y entra por aquí.
  ///
  /// Reutiliza la MISMA conexión que [printViaNetwork] y
  /// [printViaBluetooth] —mismos reintentos, mismo descubrimiento de
  /// característica bluetooth, mismos errores— para que un ticket de
  /// cocina y uno de venta se comporten igual de bien o de mal.
  ///
  /// NO sustituye a [printTicket]: es la vía "cruda", para callers que ya
  /// generan sus propios bytes. Hoy el único es `TicketCocinaService`.
  Future<PrintResult> imprimirBytes({
    required PrinterDevice printer,
    required List<int> bytes,
    int maxRetries = 2,
  }) async {
    if (bytes.isEmpty) {
      return PrintResult.failure(
        PrinterError.unknown,
        'No hay nada que imprimir',
      );
    }

    _log('📨 R.3.3 · ${bytes.length} bytes en ${printer.type.name}');

    int attempts = 0;
    PrintResult? lastResult;

    while (attempts < maxRetries) {
      attempts++;

      try {
        if (printer.type == PrinterType.network) {
          final profile = await CapabilityProfile.load();
          final networkPrinter =
              NetworkPrinter(PaperSize.mm58, profile);

          final connectResult = await networkPrinter.connect(
            printer.address,
            port: printer.port ?? 9100,
          );

          if (connectResult != PosPrintResult.success) {
            lastResult = PrintResult.failure(
              PrinterError.notConnected,
              'Error de conexión: ${connectResult.msg}',
            );
            continue;
          }

          networkPrinter.rawBytes(bytes);
          networkPrinter.disconnect();

          _log('✅ R.3.3 · red OK en intento $attempts');
          return PrintResult.success();
        }

        // Bluetooth: mismo descubrimiento de characteristic que
        // printViaBluetooth.
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
          await device.disconnect();
          lastResult = PrintResult.failure(
            PrinterError.unknown,
            'Característica de impresión no encontrada',
          );
          continue;
        }

        await characteristic.write(bytes, withoutResponse: true);
        await device.disconnect();

        _log('✅ R.3.3 · bluetooth OK en intento $attempts');
        return PrintResult.success();
      } catch (e) {
        _log('❌ R.3.3 · error en intento $attempts: $e');
        lastResult = PrintResult.failure(PrinterError.unknown, e.toString());
        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    return lastResult ??
        PrintResult.failure(PrinterError.unknown, 'Falló la impresión');
  }

  // =========================================================
  // MÉTODO UNIFICADO PARA TICKETS
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
    LocalEntity? local,
    bool esCierre = false,
    Map<String, double>? totalesPorMetodo,

    // ── Extras Venta al Mayor (opcionales) ──
    TicketCliente? cliente,
    List<TicketPago>? pagos,
    String tipoVenta = 'detal',
    String? tipoDocumento,
    double tasaBcv = 0.0,
    double montoDescuentoTotal = 0.0,
    bool requiereAutorizacion = false,
    String? autorizadoPorNombre,
    String? vendedor,
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
          local: local,
          esCierre: esCierre,
          totalesPorMetodo: totalesPorMetodo,
          cliente: cliente,
          pagos: pagos,
          tipoVenta: tipoVenta,
          tipoDocumento: tipoDocumento,
          tasaBcv: tasaBcv,
          montoDescuentoTotal: montoDescuentoTotal,
          requiereAutorizacion: requiereAutorizacion,
          autorizadoPorNombre: autorizadoPorNombre,
          vendedor: vendedor,
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
          local: local,
          esCierre: esCierre,
          totalesPorMetodo: totalesPorMetodo,
          cliente: cliente,
          pagos: pagos,
          tipoVenta: tipoVenta,
          tipoDocumento: tipoDocumento,
          tasaBcv: tasaBcv,
          montoDescuentoTotal: montoDescuentoTotal,
          requiereAutorizacion: requiereAutorizacion,
          autorizadoPorNombre: autorizadoPorNombre,
          vendedor: vendedor,
        );
    }
  }

  // =========================================================
  // PRUEBA DE CONEXIÓN
  // =========================================================
  Future<PrintResult> testPrinter(PrinterDevice printer) async {
    _log('🧪 Probando impresora: ${printer.name}');

    final testItems = [
      TicketItem(
        nombre: '---- PRUEBA ----',
        precio: 0,
        cantidad: 1,
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
      local: null,
    );
  }

  // =========================================================
  // IMPRESIÓN DE ETIQUETAS (sin cambios)
  // =========================================================
  Future<PrintResult> printLabel({
    required PrinterDevice printer,
    required List<LabelItem> labels,
    int maxRetries = 2,
  }) async {
    _log('🏷️ Iniciando impresión de ${labels.length} etiqueta(s)');

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
          const PaperSize paper = PaperSize.mm58;
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

    return lastResult ??
        PrintResult.failure(PrinterError.unknown, 'Falló la impresión de etiquetas');
  }

  // =========================================================
  // ESCANEO BLUETOOTH (sin cambios)
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
  // LOGS
  // =========================================================
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(0, 19);
    debugPrint('[$timestamp] [PrinterService] $message');
  }
}

/// Resultado de impresión
class PrintResult {
  final bool success;
  final PrinterError? error;
  final String? message;

  PrintResult._({required this.success, this.error, this.message});

  factory PrintResult.success() => PrintResult._(success: true);
  factory PrintResult.failure(PrinterError error, [String? message]) =>
      PrintResult._(success: false, error: error, message: message);
}