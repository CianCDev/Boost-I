import 'package:esc_pos_utils_lts/esc_pos_utils_lts.dart';
import '../../data/Local/entities/local_entity.dart';

/// Modelo de un ítem del ticket
class TicketItem {
  final String nombre;
  final double precio;
  final double cantidad;
  final bool esPesado;

  TicketItem({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.esPesado = false,
  });

  double get total => precio * cantidad;
}

/// Generador de comandos ESC/POS para tickets
class TicketGenerator {
  static Future<List<int>> generateTicketBytes({
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
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    if (esCierre) {
      return _generateCierreBytes(
        generator,
        local: local,
        totalesPorMetodo: totalesPorMetodo ?? {},
        totalGeneral: total,
        fecha: fechaVenta ?? DateTime.now(),
      );
    } else {
      return _generateVentaBytes(
        generator,
        local: local,
        items: items,
        subtotal: subtotal,
        impuesto: impuesto,
        total: total,
        metodoPago: metodoPago,
        montoRecibido: montoRecibido,
        vuelto: vuelto,
        fecha: fechaVenta ?? DateTime.now(),
      );
    }
  }

  // ============================================================
  // TICKET DE VENTA (original)
  // ============================================================
  static List<int> _generateVentaBytes(
    Generator generator, {
    required LocalEntity? local,
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    required DateTime fecha,
  }) {
    List<int> bytes = [];

    // Encabezado
    if (local != null) {
      bytes += generator.text(
        local.nombre,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      if (local.direccion != null && local.direccion!.isNotEmpty) {
        bytes += generator.text(local.direccion!,
            styles: const PosStyles(align: PosAlign.center));
      }
      if (local.telefono != null && local.telefono!.isNotEmpty) {
        bytes += generator.text('Tel: ${local.telefono}',
            styles: const PosStyles(align: PosAlign.center));
      }
      if (local.email != null && local.email!.isNotEmpty) {
        bytes += generator.text('Email: ${local.email}',
            styles: const PosStyles(align: PosAlign.center));
      }
      if (local.rif != null && local.rif!.isNotEmpty) {
        bytes += generator.text('RIF: ${local.rif}',
            styles: const PosStyles(align: PosAlign.center));
      }
    } else {
      bytes += generator.text('--- LOCAL NO CONFIGURADO ---',
          styles: const PosStyles(align: PosAlign.center));
    }

    bytes += generator.text('--------------------------------',
        styles: const PosStyles(align: PosAlign.center));

    // Fecha
    final fechaStr =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    bytes += generator.text('Fecha: $fechaStr');

    // Items
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'CANT  PRODUCTO                PRECIO',
      styles: const PosStyles(bold: true),
    );
    bytes += generator.text('--------------------------------');

    for (var item in items) {
      final cantidadStr = item.cantidad.toStringAsFixed(item.esPesado ? 3 : 0);
      final nombreTruncado = item.nombre.length > 20
          ? '${item.nombre.substring(0, 20)}...'
          : item.nombre;
      final precioStr = '\$${item.total.toStringAsFixed(2)}';
      final linea = '$cantidadStr  $nombreTruncado'.padRight(32) + precioStr;
      bytes += generator.text(linea);
    }

    bytes += generator.text('--------------------------------');

    // Totales
    bytes += generator.text(
        // ignore: prefer_interpolation_to_compose_strings
        'Subtotal:'.padRight(32) + '\$${subtotal.toStringAsFixed(2)}');
    bytes += generator.text(
        '${'Impuesto:'.padRight(32)}\$${impuesto.toStringAsFixed(2)}');
    bytes += generator.text(
      '${'TOTAL:'.padRight(32)}\$${total.toStringAsFixed(2)}',
      styles: const PosStyles(bold: true, height: PosTextSize.size2),
    );
    bytes += generator.text('--------------------------------');

    bytes += generator.text(
        '${'Método: $metodoPago'.padRight(32)}Recibido: \$${montoRecibido.toStringAsFixed(2)}');
    bytes += generator.text(
        'Vuelto: \$${vuelto.toStringAsFixed(2)}'.padRight(40));

    // Pie
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      '¡Gracias por su compra!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  // ============================================================
  // TICKET DE CIERRE DE CAJA (NUEVO FORMATO)
  // ============================================================
  static List<int> _generateCierreBytes(
    Generator generator, {
    required LocalEntity? local,
    required Map<String, double> totalesPorMetodo,
    required double totalGeneral,
    required DateTime fecha,
  }) {
    List<int> bytes = [];

    // Encabezado
    if (local != null) {
      bytes += generator.text(
        local.nombre,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      if (local.direccion != null && local.direccion!.isNotEmpty) {
        bytes += generator.text(local.direccion!,
            styles: const PosStyles(align: PosAlign.center));
      }
      if (local.telefono != null && local.telefono!.isNotEmpty) {
        bytes += generator.text('Tel: ${local.telefono}',
            styles: const PosStyles(align: PosAlign.center));
      }
      if (local.email != null && local.email!.isNotEmpty) {
        bytes += generator.text('Email: ${local.email}',
            styles: const PosStyles(align: PosAlign.center));
      }
      if (local.rif != null && local.rif!.isNotEmpty) {
        bytes += generator.text('RIF: ${local.rif}',
            styles: const PosStyles(align: PosAlign.center));
      }
    } else {
      bytes += generator.text('--- LOCAL NO CONFIGURADO ---',
          styles: const PosStyles(align: PosAlign.center));
    }

    bytes += generator.text('================================',
        styles: const PosStyles(align: PosAlign.center));

    // Título
    bytes += generator.text(
      'CIERRE DE CAJA',
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );

    // Fecha
    final fechaStr =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    bytes += generator.text('Fecha: $fechaStr',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.text('--------------------------------');

    // Desglose por método
    bytes += generator.text('RESUMEN POR MÉTODO:',
        styles: const PosStyles(bold: true));
    for (var entry in totalesPorMetodo.entries) {
      final linea =
          '${'${entry.key}:'.padRight(25)}\$${entry.value.toStringAsFixed(2)}';
      bytes += generator.text(linea);
    }

    bytes += generator.text('--------------------------------');

    // Total general
    bytes += generator.text(
      '${'TOTAL GENERAL:'.padRight(25)}\$${totalGeneral.toStringAsFixed(2)}',
      styles: const PosStyles(bold: true, height: PosTextSize.size2),
    );

    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'Cierre realizado correctamente.',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      '¡Gracias por su trabajo!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}