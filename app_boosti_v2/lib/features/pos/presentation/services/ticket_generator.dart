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
    LocalEntity? local, // NUEVO: datos del local
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    // ==================== ENCABEZADO ====================
    if (local != null) {
      // Nombre del local (negrita, tamaño 2)
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
        bytes += generator.text(
          local.direccion!,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      if (local.telefono != null && local.telefono!.isNotEmpty) {
        bytes += generator.text(
          'Tel: ${local.telefono}',
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      if (local.email != null && local.email!.isNotEmpty) {
        bytes += generator.text(
          'Email: ${local.email}',
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      if (local.rif != null && local.rif!.isNotEmpty) {
        bytes += generator.text(
          'RIF: ${local.rif}',
          styles: const PosStyles(align: PosAlign.center),
        );
      }
    } else {
      bytes += generator.text(
        '--- LOCAL NO CONFIGURADO ---',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );

    // ==================== FECHA ====================
    final now = fechaVenta ?? DateTime.now();
    final fechaStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    bytes += generator.text('Fecha: $fechaStr');

    // ==================== ITEMS ====================
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

    // ==================== TOTALES ====================
    bytes += generator.text(
      'Subtotal:'.padRight(32) + '\$${subtotal.toStringAsFixed(2)}',
    );
    bytes += generator.text(
      'Impuesto:'.padRight(32) + '\$${impuesto.toStringAsFixed(2)}',
    );
    bytes += generator.text(
      'TOTAL:'.padRight(32) + '\$${total.toStringAsFixed(2)}',
      styles: const PosStyles(bold: true, height: PosTextSize.size2),
    );
    bytes += generator.text('--------------------------------');

    bytes += generator.text(
      'Método: $metodoPago'.padRight(32) + 'Recibido: \$${montoRecibido.toStringAsFixed(2)}',
    );
    bytes += generator.text(
      'Vuelto: \$${vuelto.toStringAsFixed(2)}'.padRight(40),
    );

    // ==================== PIE ====================
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      '¡Gracias por su compra!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}