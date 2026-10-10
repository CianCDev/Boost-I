// lib/features/pos/presentation/services/ticket_cocina_service.dart
//
// R.3.3 · Ticket de cocina impreso + PDF.
//
// ⚠️ POR QUÉ NO SE REUSA `TicketItem`
//
// `TicketItem` (ticket_generator.dart:11) tiene `precio` como campo
// `required` y no nullable, y tanto `TicketGenerator` como
// `TicketService._buildItemRow` imprimen `\$${item.total}` en CADA línea.
// El ticket de cocina no lleva precios (decisión del cliente: quien lee
// esto en la barra no cobra). Reutilizarlo obligaba a meter precios a 0 y
// sacar un "0.0000" en cada plato, o a tocar `_buildItemRow` y arriesgar
// la venta. Por eso hay un formateador propio.
//
// ⚠️ EL FORMATO SE ARMA UNA VEZ Y SE USA DOS VECES
//
// [lineasTicket] devuelve `List<String>`: el texto tal cual, sin
// depender de ESC/POS ni del PDF. El generador térmico lo pasa a
// `generator.text()` y el PDF lo reparte en `pw.Text`. Si algún día
// cambian las reglas del ticket, se tocan en un solo sitio y ambos
// formatos cambian juntos. Es lo que hace testeable el formato sin
// depender de una impresora.
import 'dart:async';
import 'dart:io';

import 'package:esc_pos_utils_lts/esc_pos_utils_lts.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/Local/entities/cart_session_entity.dart';
import '../../domain/models/printer_models.dart';
import '../providers/kds_ticket.dart';
import '../utils/pdf_utils.dart';
import 'printer_service.dart';

/// Outcome de [TicketCocinaService.procesarEnvio].
class ResultadoEnvioCocina {
  final bool impreso;
  final String? rutaPdf;
  final String? error;

  const ResultadoEnvioCocina({
    required this.impreso,
    this.rutaPdf,
    this.error,
  });
}

class TicketCocinaService {
  TicketCocinaService._();

  /// Columnas por línea. 32 es lo que caben sin partir palabras en una
  /// impresora de 58 mm con Font A; 42 es cómodo en 80 mm.
  ///
  /// ⚠️ Es un valor FIJO, no se consulta el ancho real de la impresora:
  /// `TicketGenerator` hace lo mismo (`_kWidth = 48`) y cambiarlo aquí
  /// obligaría a medir el papel en runtime, que `esc_pos_utils_lts` no
  /// expone. 32 es el peor caso: si la impresora es más ancha, sobra
  /// margen; nunca se parte una línea.
  static const int ancho = 32;

  /// Carpeta donde quedan los PDF de cocina, dentro de Documents.
  static const String carpeta = 'Tickets_POS/Cocina';

  // ══════════════════════════════════════════════════════════════
  // API PÚBLICA
  // ══════════════════════════════════════════════════════════════

  /// Imprime el ticket en la impresora térmica.
  ///
  /// Devuelve `true` solo si los bytes salieron. Sin impresora
  /// configurada devuelve `false` SIN error: no es un fallo, es que
  /// nadie ha configurado una impresora todavía.
  static Future<bool> imprimirEnImpresora(
    KdsTicket ticket, {
    required PrinterDevice? impresora,
  }) async {
    if (impresora == null) return false;
    if (ticket.items.isEmpty) return false;

    try {
      final bytes = await _bytesTermicos(ticket);
      final service = PrinterService();
      final resultado = await service.imprimirBytes(
        printer: impresora,
        bytes: bytes,
      );
      return resultado.success;
    } catch (e) {
      debugPrint('❌ [Cocina] Error imprimiendo: $e');
      return false;
    }
  }

  /// Genera el PDF, lo guarda en Documents y devuelve su ruta.
  ///
  /// Devuelve `null` si falla. Nunca lanza.
  static Future<String?> generarPdf(KdsTicket ticket) async {
    if (ticket.items.isEmpty) return null;

    try {
      final documento = await _bytesPdf(ticket);
      return await PdfUtils.guardarPdf(
        bytes: documento,
        nombreBase: _nombreArchivo(ticket),
        subcarpeta: carpeta,
      );
    } catch (e) {
      debugPrint('❌ [Cocina] Error generando PDF: $e');
      return null;
    }
  }

  /// Imprime Y genera el PDF. Ninguno de los dos bloquea al otro.
  ///
  /// ⚠️ Se usa `Future.wait`: si la impresora se cuelga 10 s esperando la
  /// red, el PDF no tiene por qué esperar a que venza ese timeout para
  /// existir. Y si el PDF falla, el ticket ya impreso en papel sigue
  /// valiendo.
  static Future<ResultadoEnvioCocina> procesarEnvio(
    KdsTicket ticket, {
    required PrinterDevice? impresora,
  }) async {
    final resultados = await Future.wait([
      imprimirEnImpresora(ticket, impresora: impresora),
      generarPdf(ticket),
    ]);

    return ResultadoEnvioCocina(
      impreso: resultados[0] as bool,
      rutaPdf: resultados[1] as String?,
      error: resultados[0] as bool ? null : 'No se pudo imprimir',
    );
  }

  /// Abre el share sheet con el PDF y avisa con un Snackbar.
  static Future<void> compartirPdf(
    BuildContext context,
    String rutaPdf,
  ) async {
    try {
      await Share.shareXFiles([XFile(rutaPdf)]);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF de cocina generado: ${_nombreCorto(rutaPdf)}'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo compartir el PDF: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // FORMATO (puro, sin ESC/POS ni PDF)
  // ══════════════════════════════════════════════════════════════

  /// Arma el ticket como lista de líneas ya centradas/truncadas.
  ///
  /// Es la ÚNICA fuente de verdad del formato. Sin precios, sin IVA, sin
  /// totales monetarios: solo qué hay que preparar, cuánto y con qué
  /// notas.
  static List<String> lineasTicket(KdsTicket ticket) {
    final lineas = <String>[];

    // ── Encabezado ──
    lineas.add(_centrar('================'));
    lineas.add(_centrar('COCINA · ${ticket.mesaNombre}'));
    lineas.add(_centrar(_fmtFecha(DateTime.now())));
    lineas.add('--------------------------------');

    // ── Agrupación por estación ──
    final grupos = _agruparPorEstacion(ticket.items);
    final multiEstacion = grupos.length > 1;

    for (final grupo in grupos) {
      // Con una sola estación el encabezado sobra: repetiría "COCINA"
      // justo debajo de un ticket que ya se titula "COCINA".
      if (multiEstacion) {
        lineas.add(grupo.nombre.toUpperCase());
        lineas.add('--------------------------------');
      }

      for (final item in grupo.items) {
        final nombre = _truncar(item.item.productoNombre, ancho - 8);
        lineas.add('  ${_cantidad(item.item)}x $nombre');

        final nota = item.item.nota?.trim();
        if (nota != null && nota.isNotEmpty) {
          lineas.add(_truncar('     ! $nota', ancho));
        }
      }

      if (multiEstacion) {
        lineas.add('--------------------------------');
      }
    }

    // ── Pie ──
    lineas.add('Servicio: ${ticket.meseroNombre ?? '-'}');
    lineas.add('Total: ${ticket.items.length} platos');
    lineas.add(_centrar('================'));

    return lineas;
  }

  /// Agrupa por nombre de estación conservando el orden de aparición.
  ///
  /// ⚠️ `estacionNombre` es un SNAPSHOT de `CartSessionItem`, así que dos
  /// items de la misma estación traen el mismo texto y el `Map` de Dart
  /// (que es `LinkedHashMap`) los deja juntos. Si el snapshot viniera
  /// vacío se cairía a "Sin estacion", que es justo la columna donde el
  /// KDS mete esos platos.
  static List<_GrupoEstacion> _agruparPorEstacion(
    List<KdsTicketItem> items,
  ) {
    final mapa = <String, List<KdsTicketItem>>{};

    for (final item in items) {
      final nombre = item.item.estacionNombre?.trim();
      final clave = (nombre == null || nombre.isEmpty)
          ? 'Sin estacion'
          : nombre;
      mapa.putIfAbsent(clave, () => []).add(item);
    }

    return mapa.entries
        .map((e) => _GrupoEstacion(e.key, e.value))
        .toList();
  }

  /// "2" o "1.250 kg". El decimal solo cuando el producto se vende a peso,
  /// igual que en la tarjeta del KDS.
  static String _cantidad(CartSessionItem item) => item.esPesado
      ? '${item.cantidad.toStringAsFixed(3)} kg'
      : '${item.cantidad.round()}';

  /// A5 (148×210 mm): cabe de sobra el ancho de 42 columnas de una
  /// impresora de 80 mm sin partir líneas, que es el ancho útil que
  /// importa aquí (el texto ya viene truncado a 32 por [_truncar]).
  static PdfPageFormat _formatoPdf() => PdfPageFormat.a5;

  static String _nombreArchivo(KdsTicket ticket) {
    final ahora = DateTime.now();
    final sello =
        '${ahora.year}${_dos(ahora.month)}${_dos(ahora.day)}'
        '_${_dos(ahora.hour)}${_dos(ahora.minute)}${_dos(ahora.second)}';

    // El id de la mesa en el nombre evita que dos tickets del mismo
    // segundo se pisen al guardarse en la misma carpeta.
    final mesa = ticket.mesaId ?? 0;
    return 'Cocina_Mesa${mesa}_$sello';
  }

  // ══════════════════════════════════════════════════════════════
  // ESC/POS
  // ══════════════════════════════════════════════════════════════

  static Future<List<int>> _bytesTermicos(KdsTicket ticket) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    for (final linea in lineasTicket(ticket)) {
      bytes.addAll(generator.text(
        linea,
        styles: _esTitulo(linea)
            ? const PosStyles(bold: true, align: PosAlign.center)
            : const PosStyles(),
      ));
    }

    // Cortar el papel: sin esto el ticket se queda asomando y el
    // siguiente se pega encima.
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return bytes;
  }

  // ══════════════════════════════════════════════════════════════
  // PDF
  // ══════════════════════════════════════════════════════════════

  static Future<List<int>> _bytesPdf(KdsTicket ticket) async {
    final documento = pw.Document();
    final lineas = lineasTicket(ticket);

    documento.addPage(
      pw.Page(
        pageFormat: _formatoPdf(),
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final linea in lineas)
              pw.Text(
                linea,
                style: pw.TextStyle(
                  // Monoespaciada para que las líneas centradas del
                  // ESC/POS queden centradas también en el PDF. Con
                  // Helvetica proporcional, el centrado calculado para
                  // 32 columnas se ve descuadrado.
                  font: pw.Font.courier(),
                  fontSize: 9,
                  fontWeight: _esTitulo(linea)
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Generado por el KDS · ${_fmtFecha(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ],
        ),
      ),
    );

    return documento.save();
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS DE FORMATO
  // ══════════════════════════════════════════════════════════════

  static String _fmtFecha(DateTime d) {
    return '${_dos(d.day)}/${_dos(d.month)}/${d.year} '
        '${_dos(d.hour)}:${_dos(d.minute)}';
  }

  static String _dos(int n) => n.toString().padLeft(2, '0');

  /// Trunca con "…" si excede. A diferencia de `TicketGenerator`, aquí
  /// `max <= 3` devuelve el prefijo entero sin puntos: son 3 caracteres
  /// que se comen el nombre, no una elipsis.
  static String _truncar(String s, int max) {
    if (s.length <= max) return s;
    if (max <= 3) return s.substring(0, max);
    return '${s.substring(0, max - 1)}~';
  }

  static String _centrar(String texto) {
    if (texto.length >= ancho) return texto;
    final margen = (ancho - texto.length) ~/ 2;
    return '${' ' * margen}$texto';
  }

  /// Si una línea es la del título ("COCINA · Mesa 3").
  ///
  /// ⚠️ Los dos renderizadores (ESC/POS y PDF) consultan ESTE predicado
  /// para decidir la negrita, en vez de meter marcas de negrita dentro de
  /// las cadenas: [lineasTicket] tiene que devolver texto plano para que
  /// sea comparable en los tests sin tener que parsear ANSI ni convención.
  static bool _esTitulo(String linea) =>
      linea.trimLeft().startsWith('COCINA ·');

  static String _nombreCorto(String ruta) {
    final partes = ruta.split(Platform.pathSeparator);
    return partes.isEmpty ? ruta : partes.last;
  }
}

/// Grupo de platos de una misma estación.
class _GrupoEstacion {
  final String nombre;
  final List<KdsTicketItem> items;

  const _GrupoEstacion(this.nombre, this.items);
}
