// lib/features/pos/presentation/services/ticket_generator.dart
import 'package:esc_pos_utils_lts/esc_pos_utils_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../data/Local/entities/local_entity.dart';

// ═══════════════════════════════════════════════════════════════════
// MODELOS DE TICKET
// ═══════════════════════════════════════════════════════════════════

/// Ítem del ticket. Soporta ventas de detal y al mayor.
class TicketItem {
  final String nombre;
  final double precio;
  final double cantidad;
  final bool esPesado;

  // ── Extras Venta al Mayor (todos opcionales) ──

  /// 'detal' | 'medio_mayor' | 'mayor'
  final String? tipoPrecio;

  /// % de descuento aplicado a esta línea.
  final double descuentoPorcentaje;

  /// Precio detal original (para mostrar tachado si aplicó descuento).
  final double? precioDetalOriginal;

  /// 'unidad' | 'bulto' | 'caja'
  final String unidadEmpaque;

  /// Nombre del autorizador de un descuento manual (si aplica).
  final String? autorizadoPorLinea;

  TicketItem({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.esPesado = false,
    this.tipoPrecio,
    this.descuentoPorcentaje = 0.0,
    this.precioDetalOriginal,
    this.unidadEmpaque = 'unidad',
    this.autorizadoPorLinea,
  });

  double get total => precio * cantidad;

  bool get esMayorista => tipoPrecio == 'mayor' || tipoPrecio == 'medio_mayor';
  bool get tieneDescuento => descuentoPorcentaje > 0.01;
  bool get esBulto => unidadEmpaque != 'unidad' && unidadEmpaque.isNotEmpty;
}

/// Datos del cliente para el encabezado del ticket.
class TicketCliente {
  final String? nombre;
  final String? rif;
  final String? documento;
  final String? razonSocial;

  const TicketCliente({
    this.nombre,
    this.rif,
    this.documento,
    this.razonSocial,
  });

  bool get tieneDatos =>
      (nombre?.isNotEmpty ?? false) ||
      (rif?.isNotEmpty ?? false) ||
      (documento?.isNotEmpty ?? false) ||
      (razonSocial?.isNotEmpty ?? false);
}

/// Un pago individual del ticket (para multipago).
class TicketPago {
  final String metodo;
  final double monto;
  final String moneda;
  final double? montoUsdEquivalente;
  final String? referencia;

  const TicketPago({
    required this.metodo,
    required this.monto,
    this.moneda = 'USD',
    this.montoUsdEquivalente,
    this.referencia,
  });

  String get label {
    switch (metodo) {
      case 'efectivo_usd':
        return 'Efectivo USD';
      case 'efectivo_bs':
        return 'Efectivo Bs';
      case 'punto':
        return 'Punto de venta';
      case 'pago_movil':
        return 'Pago Movil';
      case 'transferencia_bs':
        return 'Transfer. Bs';
      case 'binance_pay':
        return 'Binance Pay';
      case 'transferencia_usdt':
        return 'Transfer USDT';
      case 'zelle':
        return 'Zelle';
      case 'paypal':
        return 'PayPal';
      default:
        return metodo;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// GENERADOR
// ═══════════════════════════════════════════════════════════════════

class TicketGenerator {
  /// Ancho útil de una impresora térmica de 80mm con Font A.
  /// 48 columnas es el estándar más seguro.
  static const int _kWidth = 48;

  // ══════════════════════════════════════════════════════════════
  // API PRINCIPAL
  // ══════════════════════════════════════════════════════════════

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

    // ── Extras Venta al Mayor (todos opcionales) ──
    TicketCliente? cliente,
    List<TicketPago>? pagos,
    String tipoVenta = 'detal',
    String? tipoDocumento,
    double tasaBcv = 0.0,
    double montoDescuentoTotal = 0.0,
    bool requiereAutorizacion = false,
    String? autorizadoPorNombre,
    String? vendedor,

    /// Numeración fiscal de la venta (`P123-2026-0001`).
    ///
    /// Va por parámetro y no se lee de la `LocalEntity` porque el
    /// número pertenece a la VENTA, no al local. `null` = venta sin
    /// numerar (anterior a la migración 20261012000003) → el ticket
    /// imprime "pendiente" en vez de omitir la línea, para que la
    /// falencia se vea en el papel.
    String? numeroFactura,

    /// Bytes del logo ya descargados de Storage. Los resuelve
    /// `PrinterService`; acá solo se decodifican. `null` = sin logo.
    List<int>? logoBytes,
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
    }

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
      logoBytes: logoBytes,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TICKET DE VENTA (detal + mayor)
  // ══════════════════════════════════════════════════════════════

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
    TicketCliente? cliente,
    List<TicketPago>? pagos,
    String tipoVenta = 'detal',
    String? tipoDocumento,
    double tasaBcv = 0.0,
    double montoDescuentoTotal = 0.0,
    bool requiereAutorizacion = false,
    String? autorizadoPorNombre,
    String? vendedor,
    String? numeroFactura,
    List<int>? logoBytes,
  }) {
    final bytes = <int>[];
    final esMayor = tipoVenta == 'mayor';
    final esMultipago = (pagos?.length ?? 0) > 1;

    // ── Encabezado del local ──
    _appendHeaderLocal(generator, bytes, local, logoBytes: logoBytes);

    // ── Tipo de documento ──
    if (esMayor) {
      final docLabel = tipoDocumento == 'nota_entrega'
          ? 'NOTA DE ENTREGA'
          : (tipoDocumento == 'factura' ? 'FACTURA' : 'DOCUMENTO');
      bytes.addAll(generator.text(
        '$docLabel - MAYOR',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ));
    }

    // ── Numeración fiscal ──
    //
    // Va SIEMPRE, también en venta al detal: un ticket sin número
    // correlativo no es comprobante fiscal. `pendiente` marca las
    // ventas anteriores a la migración 20261012000003, que es
    // información útil (faltó numerar) y no un error de impresión.
    bytes.addAll(generator.text(
      'N° ${numeroFactura ?? "pendiente"}',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    ));

    // ── Fecha ──
    bytes.addAll(generator.text('--------------------------------'));

    final fechaStr = _fmtFecha(fecha);
    bytes.addAll(generator.text('Fecha: $fechaStr'));

    // ── Cliente (si aplica) ──
    if (cliente != null && cliente.tieneDatos) {
      bytes.addAll(generator.text('--------------------------------'));
      bytes.addAll(generator.text('CLIENTE:',
          styles: const PosStyles(bold: true)));
      if ((cliente.nombre ?? '').isNotEmpty) {
        bytes.addAll(generator.text('  ${cliente.nombre}'));
      }
      if ((cliente.rif ?? '').isNotEmpty) {
        bytes.addAll(generator.text('  RIF: ${cliente.rif}'));
      }
      if ((cliente.documento ?? '').isNotEmpty) {
        bytes.addAll(generator.text('  Doc: ${cliente.documento}'));
      }
      if ((cliente.razonSocial ?? '').isNotEmpty) {
        bytes.addAll(
            generator.text(_truncar(cliente.razonSocial!, _kWidth - 2)));
      }
    }

    // ── Items ──
    bytes.addAll(generator.text('--------------------------------'));
    bytes.addAll(generator.text(
      _padDual('CANT', 'IMPORTE'),
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text('--------------------------------'));

    for (final item in items) {
      _appendItemLine(generator, bytes, item);
    }

    // ── Totales ──
    bytes.addAll(generator.text('--------------------------------'));

    bytes.addAll(generator.text(_filaDual(
      'Subtotal:',
      '\$${subtotal.toStringAsFixed(2)}',
    )));

    if (montoDescuentoTotal > 0.01) {
      bytes.addAll(generator.text(_filaDual(
        'Descuentos:',
        '-\$${montoDescuentoTotal.toStringAsFixed(2)}',
      )));
    }

    // El IVA va con su alícuota explícita. Sin el porcentaje, un ticket
    // con impuesto no permite saber si es 16%, exento o una tasa
    // especial: el monto solo no dice nada.
    bytes.addAll(generator.text(_filaDual(
      'IVA 16%:',
      '\$${impuesto.toStringAsFixed(2)}',
    )));

    bytes.addAll(generator.text(
      _filaDual('TOTAL USD:', '\$${total.toStringAsFixed(2)}'),
      styles: const PosStyles(bold: true, height: PosTextSize.size2),
    ));

    // ── Bolívares (si hay tasa) ──
    if (tasaBcv > 0) {
      bytes.addAll(generator.text(_filaDual(
        'Bs:',
        'Bs. ${(total * tasaBcv).toStringAsFixed(2)}',
      )));
      bytes.addAll(generator.text(_filaDual(
        'Tasa:',
        '@ ${tasaBcv.toStringAsFixed(2)}',
      )));
    }

    // ── Pagos ──
    bytes.addAll(generator.text('================================'));

    if (esMultipago && pagos != null) {
      bytes.addAll(generator.text(
        'PAGOS (${pagos.length}):',
        styles: const PosStyles(bold: true),
      ));
      for (final p in pagos) {
        bytes.addAll(generator.text(_filaDual(
          '  ${p.label}',
          _fmtPagoMonto(p),
        )));
      }
    } else {
      bytes.addAll(generator.text(_filaDual(
        'Metodo:',
        metodoPago,
      )));
    }

    bytes.addAll(generator.text(_filaDual(
      'Recibido:',
      '\$${montoRecibido.toStringAsFixed(2)}',
    )));

    if (vuelto > 0.01) {
      bytes.addAll(generator.text(_filaDual(
        'Vuelto:',
        '\$${vuelto.toStringAsFixed(2)}',
      )));
    }

    // ── Autorización (si aplica) ──
    if (requiereAutorizacion && (autorizadoPorNombre ?? '').isNotEmpty) {
      bytes.addAll(generator.text('--------------------------------'));
      bytes.addAll(generator.text(
        'Autorizado por: $autorizadoPorNombre',
        styles: const PosStyles(bold: true),
      ));
    }

    // ── Vendedor: ELIMINADO (2026-10-12) ──
    //
    // El ticket es un comprobante que el cliente se lleva y archiva. El
    // nombre del vendedor no es un dato exigido por la factura y suma
    // una línea de dato personal del empleado a un papel que circula.
    //
    // El parámetro `vendedor` se conserva en la firma: quitarlo rompería
    // a los 5 call sites de `printer_service.dart`/`ticket_service.dart`
    // y no aporta nada funcional. Se ignora acá a propósito.
    //
    // Antes:
    //   if ((vendedor ?? '').isNotEmpty) {
    //     bytes.addAll(generator.text('--------------------------------'));
    //     bytes.addAll(generator.text('Vendedor: $vendedor'));
    //   }
    //
    // ⚠️ `vendedor` queda sin uso dentro del método. Si el analizador se
    //    queja, la solución es `_ = vendedor;` o dejar el parámetro con
    //    su docstring — NO reintroducir la línea.

    // ── Pie ──
    bytes.addAll(generator.text('================================'));
    bytes.addAll(generator.text(
      'Gracias por su compra!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(generator.feed(3));
    bytes.addAll(generator.cut());

    return bytes;
  }

  // ══════════════════════════════════════════════════════════════
  // TICKET DE CIERRE DE CAJA
  // ══════════════════════════════════════════════════════════════

  static List<int> _generateCierreBytes(
    Generator generator, {
    required LocalEntity? local,
    required Map<String, double> totalesPorMetodo,
    required double totalGeneral,
    required DateTime fecha,
  }) {
    final bytes = <int>[];

    _appendHeaderLocal(generator, bytes, local);

    bytes.addAll(generator.text('================================',
        styles: const PosStyles(align: PosAlign.center)));

    bytes.addAll(generator.text(
      'CIERRE DE CAJA',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    ));

    bytes.addAll(generator.text('Fecha: ${_fmtFecha(fecha)}',
        styles: const PosStyles(align: PosAlign.center)));

    bytes.addAll(generator.text('--------------------------------'));
    bytes.addAll(generator.text('RESUMEN POR METODO:',
        styles: const PosStyles(bold: true)));

    for (final entry in totalesPorMetodo.entries) {
      bytes.addAll(generator.text(_filaDual(
        '${entry.key}:',
        '\$${entry.value.toStringAsFixed(2)}',
      )));
    }

    bytes.addAll(generator.text('--------------------------------'));
    bytes.addAll(generator.text(
      _filaDual('TOTAL GENERAL:',
          '\$${totalGeneral.toStringAsFixed(2)}'),
      styles: const PosStyles(bold: true, height: PosTextSize.size2),
    ));

    bytes.addAll(generator.text('--------------------------------'));
    bytes.addAll(generator.text(
      'Cierre realizado correctamente.',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(generator.text(
      'Gracias por su trabajo!',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.feed(3));
    bytes.addAll(generator.cut());

    return bytes;
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS PRIVADOS
  // ══════════════════════════════════════════════════════════════

  /// Agrega el logo del local al ticket, si se resolvió uno.
  ///
  /// Los bytes llegan ya descargados y redimensionados: acá solo se
  /// decodifican. La resolución (descarga de Storage + caché) vive en
  /// `PrinterService`, porque este método es síncrono.
  ///
  /// ⚠️ Un logo roto NO puede voltear el ticket. Por eso cualquier
  ///    error se traga y se sigue imprimiendo el texto.
  ///
  /// 512 px de ancho máximo: `PaperSize.mm80` son 558 dots de ancho. Con
  /// 512 queda un margen de ~23 dots por lado y no hay recorte.
  static void _appendLogo(Generator g, List<int> bytes, List<int>? logoBytes) {
    if (logoBytes == null || logoBytes.isEmpty) return;
    try {
      // `decodeImage` pide Uint8List; el caller entrega List<int>.
      final decodificada = img.decodeImage(Uint8List.fromList(logoBytes));
      if (decodificada == null) return;

      final ancho = decodificada.width > _anchoMaxLogo
          ? _anchoMaxLogo
          : decodificada.width;
      final imagen = decodificada.width == ancho
          ? decodificada
          : img.copyResize(decodificada, width: ancho);

      bytes.addAll(g.image(imagen, align: PosAlign.center));
      bytes.addAll(g.emptyLines(1));
    } catch (e) {
      debugPrint('Ticket: no se pudo imprimir el logo ($e)');
    }
  }

  /// Ancho máximo del logo en pixels, para una impresora de 80 mm.
  static const int _anchoMaxLogo = 512;

  static void _appendHeaderLocal(
    Generator g,
    List<int> bytes,
    LocalEntity? local, {
    List<int>? logoBytes,
  }) {
    _appendLogo(g, bytes, logoBytes);

    if (local == null) {
      bytes.addAll(g.text('--- LOCAL NO CONFIGURADO ---',
          styles: const PosStyles(align: PosAlign.center)));
      return;
    }

    // Razón social PRIMERO: es el dato que identifica legalmente al
    // emisor. `nombre` va debajo como nombre de fantasía.
    //
    // Los locales creados antes de la migración `20261012000002` la
    // tienen en NULL. Se imprime el aviso en vez de dejar un hueco, para
    // que el faltante se vea en el papel y alguien lo cargue.
    if ((local.razonSocial ?? '').isNotEmpty) {
      bytes.addAll(g.text(
        local.razonSocial!,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ));
    } else {
      bytes.addAll(g.text('Razón social: [no configurada]',
          styles: const PosStyles(align: PosAlign.center)));
    }

    bytes.addAll(g.text(
      local.nombre,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    ));
    if ((local.direccion ?? '').isNotEmpty) {
      bytes.addAll(g.text(local.direccion!,
          styles: const PosStyles(align: PosAlign.center)));
    }
    if ((local.telefono ?? '').isNotEmpty) {
      bytes.addAll(g.text('Tel: ${local.telefono}',
          styles: const PosStyles(align: PosAlign.center)));
    }
    if ((local.rif ?? '').isNotEmpty) {
      bytes.addAll(g.text('RIF: ${local.rif}',
          styles: const PosStyles(align: PosAlign.center)));
    }
    if ((local.email ?? '').isNotEmpty) {
      bytes.addAll(g.text('Email: ${local.email}',
          styles: const PosStyles(align: PosAlign.center)));
    }
  }

  /// Imprime un ítem en 2-3 líneas:
  ///   L1: `CANT  NOMBRE...             IMPORTE`
  ///   L2: `      @ $X.XX [MAYOR]`  (solo si mayorista o descuento)
  ///   L3: `      Detal: $Y.YY`      (solo si aplica descuento)
  static void _appendItemLine(
    Generator g,
    List<int> bytes,
    TicketItem item,
  ) {
    // ── Línea 1: cantidad + nombre + importe ──
    final cantStr = item.esPesado
        ? item.cantidad.toStringAsFixed(3)
        : (item.esBulto
            ? '${(item.cantidad ~/ 1)}b' // bultos
            : item.cantidad.toStringAsFixed(0));

    final importe = '\$${item.total.toStringAsFixed(2)}';
    final espacioNombre = _kWidth - cantStr.length - importe.length - 3;

    final nombreTrunc = _truncar(item.nombre, espacioNombre);
    bytes.addAll(g.text(
      '$cantStr  $nombreTrunc'.padRight(_kWidth - importe.length) + importe,
    ));

    // ── Línea 2: tier / precio unitario (si es mayorista) ──
    if (item.esMayorista) {
      final tierLabel = item.tipoPrecio == 'mayor'
          ? 'MAYOR'
          : (item.tipoPrecio == 'medio_mayor' ? 'MEDIO' : '');
      final linea = '      @ \$${item.precio.toStringAsFixed(2)}'
          '${tierLabel.isNotEmpty ? ' [$tierLabel]' : ''}';
      bytes.addAll(g.text(linea));
    }

    // ── Línea 3: descuento aplicado ──
    if (item.tieneDescuento) {
      final linea = '      Desc: -${item.descuentoPorcentaje.toStringAsFixed(0)}%'
          '${item.autorizadoPorLinea != null ? ' (${item.autorizadoPorLinea})' : ''}';
      bytes.addAll(g.text(_truncar(linea, _kWidth)));
    }

    // ── Línea 4: precio detal original (informativo) ──
    if (item.precioDetalOriginal != null &&
        item.precioDetalOriginal! > item.precio + 0.001) {
      bytes.addAll(g.text(
        '      Detal: \$${item.precioDetalOriginal!.toStringAsFixed(2)}',
      ));
    }
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS DE FORMATO
  // ══════════════════════════════════════════════════════════════

  static String _fmtFecha(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  /// Fila con 2 columnas alineadas al ancho total.
  static String _filaDual(String left, String right) {
    final space = _kWidth - left.length - right.length;
    if (space <= 0) return '$left $right';
    return left + ' ' * space + right;
  }

  /// Cabecera tipo "CANT ... IMPORTE".
  static String _padDual(String left, String right) {
    return _filaDual(left, right);
  }

  /// Trunca un string con "…" si excede.
  static String _truncar(String s, int max) {
    if (s.length <= max) return s;
    if (max <= 3) return s.substring(0, max);
    return '${s.substring(0, max - 3)}...';
  }

  static String _fmtPagoMonto(TicketPago p) {
    switch (p.moneda) {
      case 'VES':
        return 'Bs. ${p.monto.toStringAsFixed(2)}';
      case 'USDT':
        return '${p.monto.toStringAsFixed(2)} USDT';
      default:
        return '\$${p.monto.toStringAsFixed(2)}';
    }
  }
}