// lib/features/pos/presentation/services/monthly_report_service.dart
import 'dart:io';
import 'dart:convert';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ═══════════════════════════════════════════════════════════════════════
// MODELO: Resultado del reporte
// ═══════════════════════════════════════════════════════════════════════

class ReporteGenerado {
  final String rutaCompleta;
  final String carpeta;
  final String nombreArchivo;
  final int transacciones;
  final int tamanoBytes;
  final String periodo;
  final DateTime generadoEn;

  const ReporteGenerado({
    required this.rutaCompleta,
    required this.carpeta,
    required this.nombreArchivo,
    required this.transacciones,
    required this.tamanoBytes,
    required this.periodo,
    required this.generadoEn,
  });

  String get tamanoLegible {
    if (tamanoBytes < 1024) return '$tamanoBytes B';
    if (tamanoBytes < 1024 * 1024) {
      return '${(tamanoBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(tamanoBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SERVICIO
// ═══════════════════════════════════════════════════════════════════════

/// Reporte mensual en CSV con estructura en 4 secciones visuales.
///
/// Los archivos se guardan en:
///   <Documents>/Tickets_POS/Reportes/reporte_YYYY_MM.csv
class MonthlyReportService {
  final IsarService _isarService;

  MonthlyReportService({IsarService? isarService})
      : _isarService = isarService ?? IsarService();

  /// Carpeta destino: `<Documents>/Tickets_POS/Reportes`.
  ///
  /// La crea si no existe.
  static Future<Directory> obtenerCarpetaReportes() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${baseDir.path}/Yan/Documentos/Tickets_POS/Reportes');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    return carpeta;
  }

  /// Genera el CSV del mes indicado y lo guarda en `Tickets_POS/Reportes`.
  ///
  /// NO comparte automáticamente. El llamador decide si compartir.
  /// Devuelve un [ReporteGenerado] con toda la info, o `null` si no hay datos.
  Future<ReporteGenerado?> generar({
    int? mes,
    int? anio,
  }) async {
    try {
      final ahora = DateTime.now();
      final mesTarget = mes ?? ahora.month;
      final anioTarget = anio ?? ahora.year;

      final inicio = DateTime(anioTarget, mesTarget, 1);
      final fin = DateTime(anioTarget, mesTarget + 1, 0, 23, 59, 59, 999);

      final ventas = await _isarService.obtenerVentasPorRango(inicio, fin);
      if (ventas.isEmpty) {
        debugPrint('ℹ️ No hay ventas en $mesTarget/$anioTarget');
        return null;
      }

      // Cargar detalles (fix del bug IsarLinks lazy)
      final Map<String, List<DetalleVentaEntity>> detallesPorVenta = {};
      for (final v in ventas) {
        final idStr = v.ventaIdString;
        if (idStr.isEmpty) continue;
        detallesPorVenta[idStr] =
            await _isarService.obtenerDetallesPorVenta(idStr);
      }

      final csv = _construirCSV(
        ventas: ventas,
        detallesPorVenta: detallesPorVenta,
        mes: mesTarget,
        anio: anioTarget,
      );

      // Guardar en Tickets_POS/Reportes
      final carpeta = await obtenerCarpetaReportes();
      final nombreArchivo =
          'reporte_${anioTarget}_${mesTarget.toString().padLeft(2, '0')}.csv';
      final file = File('${carpeta.path}/$nombreArchivo');
      await file.writeAsString(csv, encoding: utf8);

      final tamano = await file.length();
      debugPrint('✅ Reporte: ${file.path} ($tamano bytes)');

      return ReporteGenerado(
        rutaCompleta: file.path,
        carpeta: carpeta.path,
        nombreArchivo: nombreArchivo,
        transacciones: ventas.length,
        tamanoBytes: tamano,
        periodo: '${_nombreMes(mesTarget)} $anioTarget',
        generadoEn: ahora,
      );
    } catch (e, stack) {
      debugPrint('❌ Error generando reporte: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  /// Comparte un reporte ya generado.
  Future<void> compartir(ReporteGenerado reporte) async {
    try {
      await Share.shareXFiles(
        [XFile(reporte.rutaCompleta)],
        subject: 'Reporte ${reporte.periodo}',
        text: 'Reporte de ventas — ${reporte.transacciones} transacciones.',
      );
    } catch (e) {
      debugPrint('⚠️ Error al compartir: $e');
    }
  }

  /// Abre la carpeta contenedora en el explorador del sistema.
  ///
  /// Desktop solamente (Windows / macOS / Linux). En mobile hace no-op.
  static Future<void> abrirCarpeta(String carpeta) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', [carpeta]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [carpeta]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [carpeta]);
      } else {
        debugPrint('ℹ️ Abrir carpeta no soportado en esta plataforma');
      }
    } catch (e) {
      debugPrint('⚠️ No se pudo abrir la carpeta: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // CSV
  // ════════════════════════════════════════════════════════════════════

  String _construirCSV({
    required List<VentaEntity> ventas,
    required Map<String, List<DetalleVentaEntity>> detallesPorVenta,
    required int mes,
    required int anio,
  }) {
    final buffer = StringBuffer();
    buffer.write('\uFEFF'); // BOM UTF-8 para Excel

    // ── Datos agregados ──
    final totalTransacciones = ventas.length;
    final totalFacturadoUsd = ventas.fold<double>(0, (s, v) => s + v.total);
    final totalFacturadoBs =
        ventas.fold<double>(0, (s, v) => s + v.totalBolivares);
    final totalDescuentos =
        ventas.fold<double>(0, (s, v) => s + v.montoDescuentoTotal);
    final totalImpuestos = ventas.fold<double>(0, (s, v) => s + v.impuesto);
    final totalSubtotal = ventas.fold<double>(0, (s, v) => s + v.subtotal);

    final totalItemsVendidos = detallesPorVenta.values
        .expand((e) => e)
        .fold<int>(0, (s, d) => s + d.cantidad.toInt());

    final formatoGenerado =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final dateFormat = DateFormat('dd/MM/yyyy');
    final horaFormat = DateFormat('HH:mm');

    // ══════════════════════════════════════════════════════════════════
    // ENCABEZADO + INFORMACIÓN GENERAL
    // ══════════════════════════════════════════════════════════════════
    final sepDoble = '═' * 75;
    final sepSimple = '─' * 75;

    buffer.writeln(sepDoble);
    buffer.writeln('  REPORTE MENSUAL DE VENTAS');
    buffer.writeln(sepDoble);
    buffer.writeln();

    buffer.writeln('INFORMACIÓN GENERAL');
    buffer.writeln(sepSimple);
    buffer.writeln('Período;${_nombreMes(mes)} $anio');
    buffer.writeln('Generado;$formatoGenerado');
    buffer.writeln('Transacciones;$totalTransacciones');
    buffer.writeln('Total ítems vendidos;$totalItemsVendidos');
    buffer.writeln('Subtotal general;\$${totalSubtotal.toStringAsFixed(2)}');
    buffer.writeln('Descuentos aplicados;\$${totalDescuentos.toStringAsFixed(2)}');
    buffer.writeln('Impuestos;\$${totalImpuestos.toStringAsFixed(2)}');
    buffer.writeln('TOTAL USD;\$${totalFacturadoUsd.toStringAsFixed(2)}');
    buffer.writeln('TOTAL Bs;Bs. ${totalFacturadoBs.toStringAsFixed(2)}');
    buffer.writeln();
    buffer.writeln();

    // ══════════════════════════════════════════════════════════════════
    // SECCIÓN 1 · RESUMEN DE VENTAS
    // ══════════════════════════════════════════════════════════════════
    buffer.writeln(sepDoble);
    buffer.writeln('  SECCIÓN 1 · RESUMEN DE VENTAS');
    buffer.writeln(sepDoble);
    buffer.writeln(
      'ID;Fecha;Hora;Empleado;Método de pago;Cliente;Documento;'
      'Ítems;Subtotal USD;Impuesto USD;Descuento USD;'
      'Total USD;Tasa BCV;Total Bs',
    );

    for (final v in ventas) {
      final detalles = detallesPorVenta[v.ventaIdString] ?? [];
      final items = detalles.fold<int>(0, (s, d) => s + d.cantidad.toInt());
      final fechaStr = v.fecha != null ? dateFormat.format(v.fecha!) : '';
      final horaStr = v.fecha != null ? horaFormat.format(v.fecha!) : '';

      buffer.writeln([
        v.id,
        fechaStr,
        horaStr,
        _escape(v.empleadoNombre),
        _escape(v.metodoPago),
        _escape(v.clienteNombre ?? 'Consumidor final'),
        _escape(v.clienteDocumento ?? '—'),
        items,
        v.subtotal.toStringAsFixed(2),
        v.impuesto.toStringAsFixed(2),
        v.montoDescuentoTotal.toStringAsFixed(2),
        v.total.toStringAsFixed(2),
        v.tasaBcv.toStringAsFixed(2),
        v.totalBolivares.toStringAsFixed(2),
      ].join(';'));
    }

    buffer.writeln();
    buffer.writeln();

    // ══════════════════════════════════════════════════════════════════
    // SECCIÓN 2 · DETALLE DE PRODUCTOS
    // ══════════════════════════════════════════════════════════════════
    buffer.writeln(sepDoble);
    buffer.writeln('  SECCIÓN 2 · DETALLE DE PRODUCTOS');
    buffer.writeln(sepDoble);
    buffer.writeln(
      'ID Venta;Fecha;Producto;Cantidad;Precio Unit. USD;'
      'Descuento %;Subtotal USD',
    );

    for (final v in ventas) {
      final detalles = detallesPorVenta[v.ventaIdString] ?? [];
      final fechaStr = v.fecha != null ? dateFormat.format(v.fecha!) : '';
      for (final d in detalles) {
        buffer.writeln([
          v.id,
          fechaStr,
          _escape(d.nombreProducto),
          d.cantidad.toStringAsFixed(d.cantidad % 1 == 0 ? 0 : 2),
          d.precioUnidad.toStringAsFixed(2),
          d.descuentoPorcentajeLinea.toStringAsFixed(2),
          d.subtotal.toStringAsFixed(2),
        ].join(';'));
      }
    }

    buffer.writeln();
    buffer.writeln();

    // ══════════════════════════════════════════════════════════════════
    // SECCIÓN 3 · TOTALES CONSOLIDADOS
    // ══════════════════════════════════════════════════════════════════
    buffer.writeln(sepDoble);
    buffer.writeln('  SECCIÓN 3 · TOTALES CONSOLIDADOS');
    buffer.writeln(sepDoble);
    buffer.writeln('Total transacciones;$totalTransacciones');
    buffer.writeln('Total ítems vendidos;$totalItemsVendidos');
    buffer.writeln('Subtotal general;\$${totalSubtotal.toStringAsFixed(2)}');
    buffer.writeln('Descuentos aplicados;\$${totalDescuentos.toStringAsFixed(2)}');
    buffer.writeln('Impuestos;\$${totalImpuestos.toStringAsFixed(2)}');
    buffer.writeln(sepSimple);
    buffer.writeln('TOTAL USD;\$${totalFacturadoUsd.toStringAsFixed(2)}');
    buffer.writeln('TOTAL Bs;Bs. ${totalFacturadoBs.toStringAsFixed(2)}');
    buffer.writeln(sepDoble);

    return buffer.toString();
  }

  // ════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════

  String _nombreMes(int mes) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    if (mes < 1 || mes > 12) return 'Mes $mes';
    return meses[mes - 1];
  }

  String _escape(String input) {
    final limpio = input.replaceAll('"', '""');
    if (limpio.contains(';') || limpio.contains('"') || limpio.contains('\n')) {
      return '"$limpio"';
    }
    return limpio;
  }
}