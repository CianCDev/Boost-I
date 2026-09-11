import 'package:flutter/foundation.dart';
import '../../domain/models/printer_models.dart';
import '../../domain/enums/printer_error.dart';
import 'label_generator.dart';
import 'ticket_generator.dart';
import '../../data/Local/entities/local_entity.dart';

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
  }) async {
    // En Web no se imprime
    return PrintResult.failure(PrinterError.unknown, 'No soportado en Web');
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
  }) async {
    return PrintResult.failure(PrinterError.unknown, 'No soportado en Web');
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
  }) async {
    return PrintResult.failure(PrinterError.unknown, 'No soportado en Web');
  }

  // =========================================================
  // PRUEBA DE CONEXIÓN
  // =========================================================
  Future<PrintResult> testPrinter(PrinterDevice printer) async {
    return PrintResult.failure(PrinterError.unknown, 'No soportado en Web');
  }

  // =========================================================
  // 🆕 IMPRESIÓN DE ETIQUETAS
  // =========================================================
  Future<PrintResult> printLabel({
    required PrinterDevice printer,
    required List<LabelItem> labels,
    int maxRetries = 2,
  }) async {
    return PrintResult.failure(PrinterError.unknown, 'No soportado en Web');
  }

  // =========================================================
  // ESCANEO BLUETOOTH
  // =========================================================
  Future<List<PrinterDevice>> scanBluetoothPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return []; // No hay escaneo en Web
  }

  // =========================================================
  // LOGS
  // =========================================================
  // ignore: unused_element
  void _log(String message) {
    debugPrint('[PrinterService] $message');
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