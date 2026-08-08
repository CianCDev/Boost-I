import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';


// ============================================================
// MODELO TICKET ITEM (ÚNICO)
// ============================================================
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

  double get total => cantidad * precio;
}

// ============================================================
// GENERADOR DE TICKET (ESC/POS)
// ============================================================
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
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // ✅ ACUMULADOR: donde guardaremos todos los comandos
    List<int> bytes = [];

    final fecha = fechaVenta ?? DateTime.now();
    final fechaStr =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    // ---------- ENCABEZADO ----------
    bytes += generator.text(
      'MI NEGOCIO / TIENDA',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'COMPROBANTE DE PAGO',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      '-' * 32,
      styles: const PosStyles(align: PosAlign.center),
    );

    // ---------- INFORMACIÓN DE VENTA ----------
    bytes += generator.text('Fecha: $fechaStr');
    bytes += generator.text('Pago: ${metodoPago.toUpperCase()}');
    if (metodoPago.toLowerCase() == 'efectivo') {
      bytes += generator.text('Recibido: ${montoRecibido.toStringAsFixed(2)} Bs');
      bytes += generator.text('Vuelto: ${vuelto.toStringAsFixed(2)} Bs');
    }
    bytes += generator.text(
      '-' * 32,
      styles: const PosStyles(align: PosAlign.center),
    );

    // ---------- DETALLE DE PRODUCTOS ----------
    bytes += generator.row([
      PosColumn(text: 'Cant', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Producto', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Total', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    for (final item in items) {
      final cantStr = item.cantidad % 1 == 0
          ? item.cantidad.toInt().toString()
          : item.cantidad.toStringAsFixed(3);
      final totalStr = '\$${item.total.toStringAsFixed(2)}';
      bytes += generator.row([
        PosColumn(text: cantStr, width: 2),
        PosColumn(text: '${item.nombre} x \$${item.precio.toStringAsFixed(2)}', width: 6),
        PosColumn(text: totalStr, width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    // ---------- TOTALES ----------
    bytes += generator.text(
      '-' * 32,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.row([
      PosColumn(text: 'SUBTOTAL:', width: 8),
      PosColumn(text: '\$${subtotal.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
    ]);
    if (impuesto > 0) {
      bytes += generator.row([
        PosColumn(text: 'IMPUESTO:', width: 8),
        PosColumn(text: '\$${impuesto.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }
    bytes += generator.row([
      PosColumn(text: 'TOTAL:', width: 8, styles: const PosStyles(bold: true)),
      PosColumn(text: '\$${total.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    // ---------- PIE DE PÁGINA ----------
    bytes += generator.text(
      '-' * 32,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      '¡Gracias por su compra!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      '-' * 32,
      styles: const PosStyles(align: PosAlign.center),
    );

    // Avanzar papel y cortar
    bytes += generator.feed(2);
    bytes += generator.cut();

    // ✅ Devuelves la lista acumulada
    return bytes;
  }
}