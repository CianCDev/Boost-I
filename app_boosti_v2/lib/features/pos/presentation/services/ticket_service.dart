// lib/features/pos/presentation/services/ticket_service.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/local_entity.dart';
import '../../domain/enums/printer_error.dart';
import '../../domain/models/printer_models.dart';
import 'printer_service.dart';
import 'ticket_generator.dart';

// Re-export para consumidores
export 'ticket_generator.dart'
    show TicketItem, TicketCliente, TicketPago;

/// Tipo de ticket para organizar archivos y formato
enum TicketType { venta, cierre, codigo }

class TicketService {
  /// Label base del documento en el PDF.
  ///
  /// Es un parámetro de diseño, no una constante de negocio: si el
  /// SENIAT exige "COMPROBANTE" en vez de "FACTURA", se cambia acá y
  /// en ningún otro lado. Ver `docs/TODO.md` (U41).
  static const _labelDocumento = 'COMPROBANTE';

  /// Método principal: intenta impresión directa ESC/POS, si falla usa PDF.
  ///
  /// Soporta ventas de **detal** y **al mayor** (con RIF, razón social,
  /// multipago y tipos de precio).
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

    // ── Cierre de caja ──
    Map<String, double>? totalesPorMetodo,
    double? totalGeneral,

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

    /// Numeración fiscal. `null` = no se conoce (call sites que no la
    /// tienen a mano); el PDF sale con "FACTURA" y sin N°.
    String? numeroFactura,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    local ??= await IsarService().obtenerLocalActivo();

    final subtotalCalculado =
        subtotal > 0 ? subtotal : items.fold(0.0, (sum, i) => sum + i.total);

    // Fallback para cierre: si no hay totales por método, extraer de items
    if (tipo == TicketType.cierre && totalesPorMetodo == null) {
      final Map<String, double> extraidos = {};
      for (final item in items) {
        final nombre = item.nombre.trim();
        if (nombre.startsWith('  ') && nombre.endsWith(':')) {
          final metodo = nombre.substring(2, nombre.length - 1).trim();
          extraidos[metodo] = item.precio;
        }
      }
      totalesPorMetodo = extraidos;
      totalGeneral = total;
    }

    // ── Intentar impresión ESC/POS ──
    if (impresoraSeleccionada != null) {
      final snackBar = SnackBar(
        content: Row(
          children: const [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Imprimiendo ticket...'),
          ],
        ),
        duration: const Duration(seconds: 10),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      try {
        final printerService = PrinterService();
        final result = await printerService.printTicket(
          printer: impresoraSeleccionada,
          items: items,
          subtotal: subtotalCalculado,
          impuesto: impuesto,
          total: total,
          metodoPago: metodoPago,
          montoRecibido: montoRecibido,
          vuelto: cambio,
          fechaVenta: fechaVenta,
          local: local,
          esCierre: tipo == TicketType.cierre,
          totalesPorMetodo: totalesPorMetodo,
          // ✅ Extras mayoristas
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

        ScaffoldMessenger.of(context).clearSnackBars();

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ticket impreso correctamente'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        final errorMessage = _getErrorMessage(result.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al imprimir: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        developer.log('Fallo en impresión ESC/POS: ${result.message}');
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        developer.log('Error en impresión ESC/POS: $e');
      }
    }

    // ── Fallback: PDF ──
    //
    // El logo se resuelve ANTES de generar el PDF, igual que en el camino
    // térmico. `PrinterService` es el dueño de la descarga y de la cache
    // por sesión: sin esto, el PDF de respaldo saldría siempre sin logo
    // aunque el local tenga uno.
    //
    // `resolverLogoDelLocal` es top-level en `printer_service.dart`, no
    // un método de `PrinterService`: la descarga y la cache viven a nivel
    // de librería precisamente para que ambos caminos (térmico y PDF)
    // compartan la misma cache por sesión.
    final logoBytes = await resolverLogoDelLocal(local?.logoPath);

    final pdf = await _generarDocumentoFallback(
      items: items,
      subtotal: subtotalCalculado,
      impuesto: impuesto,
      total: total,
      metodoPago: metodoPago,
      montoRecibido: montoRecibido,
      vuelto: cambio,
      fechaVenta: fechaVenta,
      local: local,
      tipo: tipo,
      totalesPorMetodo: totalesPorMetodo,
      totalGeneral: totalGeneral ?? total,
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

    final bytes = await pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${_generarNombreArchivo(tipo)}.pdf');
    await file.writeAsBytes(bytes);

    await OpenFilex.open(file.path);
    await _guardarEnDiscoSilencioso(bytes, tipo: tipo);
  }

  // ══════════════════════════════════════════════════════════════
  // MENSAJES DE ERROR
  // ══════════════════════════════════════════════════════════════

  static String _getErrorMessage(PrinterError? error) {
    if (error == null) return 'Error desconocido';
    switch (error) {
      case PrinterError.none:
        return 'Sin errores';
      case PrinterError.notConnected:
        return 'No se pudo conectar a la impresora. ¿Está encendida y en la misma red?';
      case PrinterError.outOfPaper:
        return 'La impresora no tiene papel. Por favor, recárgala.';
      case PrinterError.offline:
        return 'La impresora está fuera de línea. Verifica la conexión.';
      case PrinterError.timeout:
        return 'Tiempo de espera agotado. La impresora no responde.';
      case PrinterError.unknown:
        return 'Error desconocido. Intenta de nuevo.';
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PDF FALLBACK
  // ══════════════════════════════════════════════════════════════

  static Future<pw.Document> _generarDocumentoFallback({
    required List<TicketItem> items,
    required double subtotal,
    required double impuesto,
    required double total,
    required String metodoPago,
    required double montoRecibido,
    required double vuelto,
    DateTime? fechaVenta,
    LocalEntity? local,
    TicketType tipo = TicketType.venta,
    Map<String, double>? totalesPorMetodo,
    double? totalGeneral,
    TicketCliente? cliente,
    List<TicketPago>? pagos,
    String tipoVenta = 'detal',
    String? tipoDocumento,
    double tasaBcv = 0.0,
    double montoDescuentoTotal = 0.0,
    bool requiereAutorizacion = false,
    String? autorizadoPorNombre,
    String? vendedor,

    /// Numeración fiscal (`P123-2026-0001`). Mismo dato que imprime el
    /// ticket térmico; `null` = venta sin numerar (anterior a la
    /// migración `20261012000003`).
    String? numeroFactura,

    /// Bytes del logo ya descargados. Los resuelve `PrinterService`
    /// (descarga + cache por sesión); acá solo se pintan.
    List<int>? logoBytes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          marginLeft: 10,
          marginRight: 10,
          marginTop: 10,
          marginBottom: 10,
        ),
        build: (context) {
          if (tipo == TicketType.cierre) {
            return _buildCierrePdf(
              context,
              local: local,
              totalesPorMetodo: totalesPorMetodo ?? {},
              totalGeneral: totalGeneral ?? total,
              fecha: fechaVenta ?? DateTime.now(),
              logoBytes: logoBytes,
            );
          }

          return _buildVentaPdf(
            context,
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
        },
      ),
    );
    return pdf;
  }

  // ══════════════════════════════════════════════════════════════
  // PDF VENTA (detal + mayor)
  // ══════════════════════════════════════════════════════════════

  static pw.Widget _buildVentaPdf(
    pw.Context context, {
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
    final esMayor = tipoVenta == 'mayor';
    final esMultipago = (pagos?.length ?? 0) > 1;

    // Título del documento. Se calcula ANTES del `return` porque es una
    // declaración (`final`), y un literal de lista (`children: [...]`)
    // solo admite expresiones: adentro no se puede declarar nada.
    //
    // El título va SIEMPRE, también en venta al detal: un comprobante
    // tiene que decir qué tipo de documento es.
    //
    // ⚠️ `_labelDocumento` es un parámetro de diseño, no una constante de
    //    negocio: si el SENIAT exige "COMPROBANTE" en vez de "FACTURA",
    //    se cambia en UNA línea y no en 4 ramas de un ternario.
    //    Ver `docs/TODO.md` (U41).
    final titulo = switch ((esMayor, tipoDocumento)) {
      (true, 'nota_entrega') => 'NOTA DE ENTREGA - MAYOR',
      (true, 'factura') => '$_labelDocumento - MAYOR',
      // Cualquier documento que no sea explícitamente nota_entrega sale
      // como COMPROBANTE. El fallback 'DOCUMENTO' se elimina: no aporta
      // información y confunde (¿es un comprobante o un documento?).
      (true, _) => '$_labelDocumento - MAYOR',
      (false, 'nota_entrega') => 'NOTA DE ENTREGA',
      (false, 'factura') => _labelDocumento,
      (false, _) => _labelDocumento,
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── Logo ──
        //
        // Va PRIMERO, arriba de todo: es lo que identifica al negocio a
        // distancia en un papel de 80 mm. `height: 60` en vez de los 96
        // del detalle del local porque el PDF usa `roll80` con 10pt de
        // margen y un logo grande se come el encabezado.
        if (logoBytes != null && logoBytes.isNotEmpty) ...[
          pw.Center(
            child: pw.Image(
              pw.MemoryImage(Uint8List.fromList(logoBytes)),
              height: 60,
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 6),
        ],

        // ── Encabezado local ──
        //
        // Mismo orden que el ticket térmico (`ticket_generator.dart`):
        // razón social primero (es el dato que identifica legalmente al
        // emisor), nombre de fantasía debajo, y después los datos de
        // contacto.
        if (local != null) ...[
          if ((local.razonSocial ?? '').isNotEmpty)
            pw.Center(
              child: pw.Text(
                local.razonSocial!,
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          pw.Center(
            child: pw.Text(
              local.nombre,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if ((local.rif ?? '').isNotEmpty)
            pw.Center(child: pw.Text('RIF: ${local.rif}')),
          if ((local.direccion ?? '').isNotEmpty)
            pw.Center(child: pw.Text(local.direccion!)),
          if ((local.telefono ?? '').isNotEmpty)
            pw.Center(child: pw.Text('Tel: ${local.telefono}')),
          if ((local.email ?? '').isNotEmpty)
            pw.Center(child: pw.Text('Email: ${local.email}')),
        ],

        // ── Tipo de documento + numeración fiscal ──
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),

        // Número fiscal. Va en su propia línea, centrada, porque es el
        // dato que el SENIAT controla. `null` = venta anterior a la
        // migración `20261012000003`: se omite la línea en vez de
        // imprimir "pendiente", que en un PDF que se archiva no aporta.
        if ((numeroFactura ?? '').isNotEmpty)
          pw.Center(
            child: pw.Text(
              'N° $numeroFactura',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),

        pw.SizedBox(height: 8),
        pw.Divider(),

        // ── Fecha ──
        pw.Text('Fecha: ${fecha.toLocal().toString().substring(0, 16)}'),

        // ── Cliente ──
        if (cliente != null && cliente.tieneDatos) ...[
          pw.SizedBox(height: 6),
          pw.Text('CLIENTE:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if ((cliente.nombre ?? '').isNotEmpty)
            pw.Text('  ${cliente.nombre}'),
          if ((cliente.rif ?? '').isNotEmpty) pw.Text('  RIF: ${cliente.rif}'),
          if ((cliente.documento ?? '').isNotEmpty)
            pw.Text('  Doc: ${cliente.documento}'),
          if ((cliente.razonSocial ?? '').isNotEmpty)
            pw.Text('  ${cliente.razonSocial}'),
        ],

        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.SizedBox(height: 4),

        // ── Items ──
        ...items.map((item) => _buildItemRow(item)),

        pw.SizedBox(height: 4),
        pw.Divider(),
        pw.SizedBox(height: 6),

        // ── Totales ──
        _buildFilaPdf('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
        if (montoDescuentoTotal > 0.01)
          _buildFilaPdf(
              'Descuentos:', '-\$${montoDescuentoTotal.toStringAsFixed(2)}'),
        // Con la alícuota explícita, igual que el ticket térmico. Sin el
        // porcentaje, un ticket con impuesto no permite saber si es 16%,
        // exento o una tasa especial.
        _buildFilaPdf('IVA 16%:', '\$${impuesto.toStringAsFixed(2)}'),
        _buildFilaPdf(
          'TOTAL USD:',
          '\$${total.toStringAsFixed(2)}',
          bold: true,
          size: 13,
        ),

        if (tasaBcv > 0) ...[
          pw.SizedBox(height: 4),
          _buildFilaPdf(
              'Bs:', 'Bs. ${(total * tasaBcv).toStringAsFixed(2)}'),
          _buildFilaPdf('Tasa:', '@ ${tasaBcv.toStringAsFixed(2)}'),
        ],

        // ── Pagos ──
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.SizedBox(height: 6),

        if (esMultipago && pagos != null) ...[
          pw.Text('PAGOS (${pagos.length}):',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          ...pagos.map((p) => _buildFilaPdf(
                '  ${p.label}',
                p.moneda == 'VES'
                    ? 'Bs. ${p.monto.toStringAsFixed(2)}'
                    : (p.moneda == 'USDT'
                        ? '${p.monto.toStringAsFixed(2)} USDT'
                        : '\$${p.monto.toStringAsFixed(2)}'),
              )),
        ] else
          _buildFilaPdf('Método:', metodoPago),

        pw.SizedBox(height: 6),
        _buildFilaPdf('Recibido:', '\$${montoRecibido.toStringAsFixed(2)}'),
        if (vuelto > 0.01)
          _buildFilaPdf('Vuelto:', '\$${vuelto.toStringAsFixed(2)}'),

        // ── Autorización ──
        if (requiereAutorizacion && (autorizadoPorNombre ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.Text(
            'Autorizado por: $autorizadoPorNombre',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],

        // ── Vendedor: ELIMINADO (2026-10-12) ──
        //
        // Dato personal del empleado en un papel que el cliente archiva.
        // El parámetro `vendedor` se conserva en la firma para no romper
        // los call sites, pero no se imprime.
        //
        // if ((vendedor ?? '').isNotEmpty) ...[
        //   pw.SizedBox(height: 8),
        //   pw.Divider(),
        //   pw.Text('Vendedor: $vendedor'),
        // ],

        // ── Pie ──
        pw.SizedBox(height: 14),
        pw.Center(
          child: pw.Text(
            '¡Gracias por su compra!',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemRow(TicketItem item) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                '${item.cantidad.toStringAsFixed(item.esPesado ? 3 : 0)}x ${item.nombre}',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Text('\$${item.total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 10)),
          ],
        ),
        if (item.esMayorista)
          pw.Text(
            '   @ \$${item.precio.toStringAsFixed(2)} '
            '[${item.tipoPrecio == 'mayor' ? 'MAYOR' : 'MEDIO'}]',
            style: pw.TextStyle(
                fontSize: 8, color: PdfColors.green700),
          ),
        if (item.tieneDescuento)
          pw.Text(
            '   Desc: -${item.descuentoPorcentaje.toStringAsFixed(0)}%'
            '${item.autorizadoPorLinea != null ? ' (${item.autorizadoPorLinea})' : ''}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.orange700),
          ),
        if (item.precioDetalOriginal != null &&
            item.precioDetalOriginal! > item.precio + 0.001)
          pw.Text(
            '   Detal: \$${item.precioDetalOriginal!.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              decoration: pw.TextDecoration.lineThrough,
            ),
          ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  static pw.Widget _buildFilaPdf(
    String left,
    String right, {
    bool bold = false,
    double size = 10,
  }) {
    final style = pw.TextStyle(
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(left, style: style),
        pw.Text(right, style: style),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PDF CIERRE (sin cambios)
  // ══════════════════════════════════════════════════════════════

  static pw.Widget _buildCierrePdf(
    pw.Context context, {
    required LocalEntity? local,
    required Map<String, double> totalesPorMetodo,
    required double totalGeneral,
    required DateTime fecha,
    List<int>? logoBytes,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // El cierre no es una venta, así que NO lleva "FACTURA" ni número
        // fiscal. Pero sí la razón social: el papel identifica a quién
        // cerró la caja, y es el mismo dato legal que en la factura.
        //
        // El logo va también: el cierre es el papel que se archiva junto
        // con la factura del día, y sin logo no se distingue de otro
        // cierre de otro local.
        if (logoBytes != null && logoBytes.isNotEmpty) ...[
          pw.Center(
            child: pw.Image(
              pw.MemoryImage(Uint8List.fromList(logoBytes)),
              height: 60,
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 6),
        ],
        if (local != null) ...[
          if ((local.razonSocial ?? '').isNotEmpty)
            pw.Center(
              child: pw.Text(
                local.razonSocial!,
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          pw.Center(
            child: pw.Text(
              local.nombre,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if ((local.direccion ?? '').isNotEmpty)
            pw.Center(child: pw.Text(local.direccion!)),
          if ((local.telefono ?? '').isNotEmpty)
            pw.Center(child: pw.Text('Tel: ${local.telefono}')),
          if ((local.rif ?? '').isNotEmpty)
            pw.Center(child: pw.Text('RIF: ${local.rif}')),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'CIERRE DE CAJA',
            style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            fecha.toLocal().toString().substring(0, 16),
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Resumen de ventas:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...totalesPorMetodo.entries.map((entry) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(entry.key),
              pw.Text('\$${entry.value.toStringAsFixed(2)}'),
            ],
          );
        }),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TOTAL GENERAL',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '\$${totalGeneral.toStringAsFixed(2)}',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Text(
            'Cierre realizado correctamente.',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            '¡Gracias por su trabajo!',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // GUARDAR PDF
  // ══════════════════════════════════════════════════════════════

  static Future<void> _guardarEnDiscoSilencioso(
    List<int> bytes, {
    TicketType tipo = TicketType.venta,
  }) async {
    try {
      if (bytes.isEmpty) {
        developer.log('⚠️ Bytes vacíos, no se guardará el PDF.');
        return;
      }
      final directory = await getApplicationDocumentsDirectory();

      String subfolder;
      String prefix;
      switch (tipo) {
        case TicketType.venta:
          subfolder = 'Ventas';
          prefix = 'Venta';
        case TicketType.cierre:
          subfolder = 'Cierres';
          prefix = 'Cierre';
        case TicketType.codigo:
          subfolder = 'Codigos';
          prefix = 'Codigo';
      }

      final folderPath = '${directory.path}/Tickets_POS/$subfolder';
      final folder = Directory(folderPath);
      if (!await folder.exists()) await folder.create(recursive: true);

      final now = DateTime.now();
      final fechaStr = '${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}'
          '${now.second.toString().padLeft(2, '0')}';

      final file = File('$folderPath/${prefix}_$fechaStr.pdf');
      await file.writeAsBytes(bytes);
      developer.log('✅ PDF guardado en: ${file.path}');
    } catch (e) {
      developer.log('❌ Error guardando PDF: $e');
    }
  }

  static String _generarNombreArchivo(TicketType tipo) {
    final now = DateTime.now();
    final fechaStr = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    final prefix = switch (tipo) {
      TicketType.venta => 'Venta',
      TicketType.cierre => 'Cierre',
      TicketType.codigo => 'Codigo',
    };
    return '${prefix}_$fechaStr';
  }

  // ══════════════════════════════════════════════════════════════
  // CÓDIGO DE BARRAS (sin cambios)
  // ══════════════════════════════════════════════════════════════

  static Future<void> imprimirCodigoBarras({
    required String codigo,
    required Uint8List imageBytes,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      final pdf = pw.Document();
      final fontRegular = pw.Font.helvetica();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginLeft: 10,
            marginRight: 10,
            marginTop: 10,
            marginBottom: 10,
          ),
          theme: pw.ThemeData.withFont(base: fontRegular),
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Código de Barras',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Image(pw.MemoryImage(imageBytes),
                      width: 200, height: 80),
                  pw.SizedBox(height: 10),
                  pw.Text(codigo, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await pdf.save();
      await _guardarEnDiscoSilencioso(bytes, tipo: TicketType.codigo);

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/${_generarNombreArchivo(TicketType.codigo)}.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint('❌ Error en imprimirCodigoBarras: $e');
      rethrow;
    }
  }
}