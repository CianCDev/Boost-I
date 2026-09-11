// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/models/printer_models.dart';
import '../../data/Local/entities/local_entity.dart';
import 'ticket_generator.dart';

/// Tipo de ticket
enum TicketType { venta, cierre, codigo }

class TicketService {
  static Future<void> imprimirTicketVenta({
    required BuildContext context,
    required List<TicketItem> items,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double cambio,
    double impuesto = 0.0,
    double subtotal = 0.0,
    DateTime? fechaVenta,
    PrinterDevice? impresoraSeleccionada,
    LocalEntity? local,
    TicketType tipo = TicketType.venta,
    Map<String, double>? totalesPorMetodo,
    double? totalGeneral,
  }) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La impresión no está disponible en la versión Web')),
      );
    }
  }

  static Future<void> imprimirCodigoBarras({
    required String codigo,
    required Uint8List imageBytes,
  }) async {
    // Método vacío para Web
  }
}