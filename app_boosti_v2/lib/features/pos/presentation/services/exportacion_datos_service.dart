// lib/features/pos/presentation/services/exportacion_datos_service.dart
//
// R.5 · Exportación de datos a CSV.
//
// Genera un ZIP con un CSV por tabla del tenant activo. El objetivo es que
// el dueño del negocio pueda abrir sus datos en Excel / LibreOffice sin
// depender de la app ni de Supabase.
//
// Decisiones:
//   · Un archivo por tabla (no un CSV gigante con secciones): así Excel no
//     mezcla columnas de entidades distintas.
//   · BOM UTF-8 al inicio de cada CSV: sin él, Excel en Windows abre los
//     acentos como mojibake.
//   · Todas las celdas entre comillas y comillas internas duplicadas: es la
//     única forma de que una nota con coma o salto de línea no rompa la fila.
//   · Se exporta la base Isar COMPLETA, que ya está aislada por tenant
//     (`isar_$empresaId`). No hace falta filtrar por `tenant_id`.
//
// ⚠️ NUNCA se exportan credenciales:
//   · `usuarios.pin` (hash del PIN) y `usuarios.password`.
//   · `telegram_config` (token cifrado + chat id).
//   Es un archivo que el usuario comparte por WhatsApp o correo.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/Local/entities/cart_session_entity.dart';
import '../../data/Local/entities/categoria_entity.dart';
import '../../data/Local/entities/cliente_entity.dart';
import '../../data/Local/entities/departamento_entity.dart';
import '../../data/Local/entities/detalle_pedido_entity.dart';
import '../../data/Local/entities/detalle_venta_entity.dart';
import '../../data/Local/entities/gasto_anulado_entity.dart';
import '../../data/Local/entities/gasto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/log_entity.dart';
import '../../data/Local/entities/lote_entity.dart';
import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/mesa_entity.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../data/Local/entities/movimiento_lote_entity.dart';
import '../../data/Local/entities/pago_venta_entity.dart';
import '../../data/Local/entities/pedido_entity.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/proveedor_entity.dart';
import '../../data/Local/entities/recepcion_entity.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/venta_anulada_entity.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/zona_entity.dart';

/// Resultado de una exportación.
class ResultadoExportacion {
  const ResultadoExportacion({
    required this.archivo,
    required this.filasPorTabla,
    required this.iniciadoEn,
    required this.duracion,
  });

  final File archivo;

  /// Nombre de tabla → cantidad de filas exportadas.
  final Map<String, int> filasPorTabla;

  final DateTime iniciadoEn;
  final Duration duracion;

  int get totalFilas =>
      filasPorTabla.values.fold(0, (total, filas) => total + filas);

  int get totalTablas => filasPorTabla.length;

  String get nombreArchivo => archivo.uri.pathSegments.last;

  double get tamanoKb => archivo.lengthSync() / 1024;
}

/// Servicio de exportación a CSV (ZIP con un archivo por tabla).
class ExportacionDatosService {
  ExportacionDatosService({IsarService? isarService, Directory? destino})
      : _isarService = isarService ?? IsarService(),
        _destino = destino;

  final IsarService _isarService;

  /// Carpeta de salida. `null` = Documentos del sistema.
  ///
  /// Existe para los tests, que no pueden resolver `path_provider`.
  final Directory? _destino;

  /// Subcarpeta dentro de Documentos donde se dejan los ZIP.
  static const String carpeta = 'Boosti/Exportaciones';

  /// Exporta la base local completa a un ZIP de CSV.
  ///
  /// Nunca lanza por una tabla rota: la salta, la deja con 0 filas y sigue.
  Future<ResultadoExportacion> exportar() async {
    final iniciadoEn = DateTime.now();
    final isar = await _isarService.db;

    final archivo = Archive();
    final filasPorTabla = <String, int>{};

    for (final tabla in _tablas) {
      List<Map<String, dynamic>> filas;
      try {
        filas = await tabla.leer(isar);
      } catch (e, stack) {
        debugPrint('⚠️ Exportación: falló la tabla ${tabla.nombre}: $e');
        debugPrint('$stack');
        filas = const [];
      }

      final csv = _construirCsv(tabla.columnas, filas);
      final bytes = utf8.encode(csv);
      archivo.addFile(ArchiveFile('${tabla.nombre}.csv', bytes.length, bytes));
      filasPorTabla[tabla.nombre] = filas.length;
    }

    // Manifiesto: qué se exportó, cuándo y cuántas filas.
    final manifiesto = _construirManifiesto(
      filasPorTabla,
      iniciadoEn,
    );
    final manifiestoBytes = utf8.encode(manifiesto);
    archivo.addFile(
      ArchiveFile('LEEME.txt', manifiestoBytes.length, manifiestoBytes),
    );

    final zipBytes = ZipEncoder().encode(archivo);
    if (zipBytes == null) {
      throw StateError('No se pudo generar el ZIP de exportación.');
    }
    final carpetaDestino = await _obtenerCarpeta();
    final nombre =
        'boosti_datos_${_marcaTiempo(iniciadoEn).replaceAll(':', '').replaceAll(' ', '_')}.zip';
    final file = File('${carpetaDestino.path}/$nombre');
    await file.writeAsBytes(zipBytes, flush: true);

    final duracion = DateTime.now().difference(iniciadoEn);
    debugPrint('✅ Exportación: ${file.path} (${zipBytes.length} bytes, '
        '${filasPorTabla.length} tablas) en ${duracion.inMilliseconds} ms');

    return ResultadoExportacion(
      archivo: file,
      filasPorTabla: filasPorTabla,
      iniciadoEn: iniciadoEn,
      duracion: duracion,
    );
  }

  /// Comparte el ZIP por el share sheet del sistema.
  Future<void> compartir(ResultadoExportacion resultado) async {
    try {
      await Share.shareXFiles(
        [XFile(resultado.archivo.path, mimeType: 'application/zip')],
        subject: 'Datos de Boosti POS',
        text: 'Exportación de datos: ${resultado.totalFilas} filas '
            'en ${resultado.totalTablas} tablas.',
      );
    } catch (e) {
      debugPrint('⚠️ Error al compartir la exportación: $e');
    }
  }

  Future<Directory> _obtenerCarpeta() async {
    final destino = _destino;
    if (destino != null) {
      if (!await destino.exists()) {
        await destino.create(recursive: true);
      }
      return destino;
    }

    final baseDir = await getApplicationDocumentsDirectory();
    final carpetaSistema = Directory('${baseDir.path}/$carpeta');
    if (!await carpetaSistema.exists()) {
      await carpetaSistema.create(recursive: true);
    }
    return carpetaSistema;
  }

  // ────────────────────────────────────────────────────────────────
  // CSV
  // ────────────────────────────────────────────────────────────────

  String _construirCsv(
    List<String> columnas,
    List<Map<String, dynamic>> filas,
  ) {
    final buffer = StringBuffer();

    // BOM: sin esto Excel en Windows rompe los acentos.
    buffer.write('\uFEFF');
    buffer.write(columnas.map(_escapar).join(','));
    buffer.write('\r\n');

    for (final fila in filas) {
      buffer.write(columnas.map((c) => _escapar(_celda(fila[c]))).join(','));
      buffer.write('\r\n');
    }

    return buffer.toString();
  }

  /// Comillas siempre + duplicado de comillas internas.
  String _escapar(String valor) => '"${valor.replaceAll('"', '""')}"';

  String _celda(dynamic valor) {
    if (valor == null) return '';
    if (valor is bool) return valor ? 'SI' : 'NO';
    if (valor is DateTime) return _fecha(valor);
    if (valor is double) {
      // Sin notación científica y sin `-0.0`.
      if (valor == 0) return '0';
      return valor.toString();
    }
    if (valor is Iterable) {
      return valor.map(_celda).join(' | ');
    }
    return valor.toString();
  }

  String _fecha(DateTime valor) {
    final local = valor.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${dos(local.month)}-${dos(local.day)} '
        '${dos(local.hour)}:${dos(local.minute)}:${dos(local.second)}';
  }

  String _marcaTiempo(DateTime valor) {
    final local = valor.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${local.year}${dos(local.month)}${dos(local.day)}_'
        '${dos(local.hour)}:${dos(local.minute)}:${dos(local.second)}';
  }

  String _construirManifiesto(
    Map<String, int> filasPorTabla,
    DateTime generadoEn,
  ) {
    final buffer = StringBuffer()
      ..writeln('Exportación de datos — Boosti POS')
      ..writeln('Generado: ${_fecha(generadoEn)}')
      ..writeln()
      ..writeln('Un archivo CSV por tabla. Codificación UTF-8 con BOM;')
      ..writeln('separador coma, todas las celdas entre comillas.')
      ..writeln()
      ..writeln('Tabla,Filas');

    final nombres = filasPorTabla.keys.toList()..sort();
    for (final nombre in nombres) {
      buffer.writeln('$nombre,${filasPorTabla[nombre]}');
    }

    buffer
      ..writeln()
      ..writeln('NO se exportan credenciales (PIN, contraseñas ni la')
      ..writeln('configuración de Telegram).');

    return buffer.toString();
  }
}

/// Una tabla exportable: nombre del CSV, columnas y lector.
class _TablaExportable {
  const _TablaExportable(this.nombre, this.columnas, this.leer);

  final String nombre;
  final List<String> columnas;
  final Future<List<Map<String, dynamic>>> Function(Isar isar) leer;
}

/// Catálogo de tablas exportadas.
///
/// ⚠️ Al agregar un campo a una entidad sincronizada, sumarlo también acá:
/// un CSV al que le falta una columna no falla, simplemente miente.
final List<_TablaExportable> _tablas = [
  _TablaExportable(
    'ventas',
    const [
      'id', 'id_supabase', 'fecha', 'documento', 'numero_factura',
      'tipo_documento', 'empleado', 'cliente_nombre', 'cliente_documento',
      'cliente_rif', 'cliente_razon_social', 'subtotal', 'impuesto',
      'total', 'tasa_bcv', 'total_bolivares', 'metodo_pago', 'tipo_pago',
      'es_multipago', 'tipo_venta', 'tiene_descuento_especial',
      'monto_descuento_total', 'monto_descuento_porcentaje',
      'requiere_autorizacion', 'autorizado_por_nombre', 'autorizado_por_rol',
      'fecha_autorizacion', 'sync_status',
    ],
    (isar) async {
      final rows = await isar.ventaEntitys.where().findAll();
      return rows
          .map((v) => <String, dynamic>{
                'id': v.id,
                'id_supabase': v.idSupabase,
                'fecha': v.fecha,
                'documento': v.documento,
                'numero_factura': v.numeroFactura,
                'tipo_documento': v.tipoDocumento,
                'empleado': v.empleado,
                'cliente_nombre': v.clienteNombre,
                'cliente_documento': v.clienteDocumento,
                'cliente_rif': v.clienteRif,
                'cliente_razon_social': v.clienteRazonSocial,
                'subtotal': v.subtotal,
                'impuesto': v.impuesto,
                'total': v.total,
                'tasa_bcv': v.tasaBcv,
                'total_bolivares': v.totalBolivares,
                'metodo_pago': v.metodoPago,
                'tipo_pago': v.tipoPago,
                'es_multipago': v.esMultipago,
                'tipo_venta': v.tipoVenta,
                'tiene_descuento_especial': v.tieneDescuentoEspecial,
                'monto_descuento_total': v.montoDescuentoTotal,
                'monto_descuento_porcentaje': v.montoDescuentoPorcentaje,
                'requiere_autorizacion': v.requiereAutorizacion,
                'autorizado_por_nombre': v.autorizadoPorNombre,
                'autorizado_por_rol': v.autorizadoPorRol,
                'fecha_autorizacion': v.fechaAutorizacion,
                'sync_status': v.syncStatus,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'detalle_ventas',
    const [
      'id', 'venta_id_fk', 'producto_id', 'nombre_producto', 'cantidad',
      'precio_unidad', 'precio_original', 'subtotal', 'tipo_precio',
      'descuento_porcentaje_linea', 'es_descuento_especial', 'es_pesado',
      'unidad_empaque', 'unidades_por_empaque', 'costo_unitario_snapshot',
      'lote_id_isar', 'autorizado_por_linea', 'sync_status',
    ],
    (isar) async {
      final rows = await isar.detalleVentaEntitys.where().findAll();
      return rows
          .map((d) => <String, dynamic>{
                'id': d.id,
                'venta_id_fk': d.ventaIdFk,
                'producto_id': d.productoId,
                'nombre_producto': d.nombreProducto,
                'cantidad': d.cantidad,
                'precio_unidad': d.precioUnidad,
                'precio_original': d.precioOriginal,
                'subtotal': d.subtotal,
                'tipo_precio': d.tipoPrecio,
                'descuento_porcentaje_linea': d.descuentoPorcentajeLinea,
                'es_descuento_especial': d.esDescuentoEspecial,
                'es_pesado': d.esPesado,
                'unidad_empaque': d.unidadEmpaque,
                'unidades_por_empaque': d.unidadesPorEmpaque,
                'costo_unitario_snapshot': d.costoUnitarioSnapshot,
                'lote_id_isar': d.loteIdIsar,
                'autorizado_por_linea': d.autorizadoPorLinea,
                'sync_status': d.syncStatus,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'pagos_ventas',
    const [
      'id', 'supabase_id', 'venta_id_fk', 'venta_supabase_id', 'metodo',
      'monto', 'moneda', 'monto_usd_equivalente', 'tasa_bcv', 'referencia',
      'ultimos_digitos', 'wallet_destino', 'banco_emisor', 'titular',
      'fecha', 'sync_status',
    ],
    (isar) async {
      final rows = await isar.pagoVentaEntitys.where().findAll();
      return rows
          .map((p) => <String, dynamic>{
                'id': p.id,
                'supabase_id': p.supabaseId,
                'venta_id_fk': p.ventaIdFk,
                'venta_supabase_id': p.ventaSupabaseId,
                'metodo': p.metodo,
                'monto': p.monto,
                'moneda': p.moneda,
                'monto_usd_equivalente': p.montoUsdEquivalente,
                'tasa_bcv': p.tasaBcv,
                'referencia': p.referencia,
                'ultimos_digitos': p.ultimosDigitos,
                'wallet_destino': p.walletDestino,
                'banco_emisor': p.bancoEmisor,
                'titular': p.titular,
                'fecha': p.fecha,
                'sync_status': p.syncStatus,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'ventas_anuladas',
    const [
      'id', 'venta_id_original', 'motivo', 'usuario_nombre', 'usuario_rol',
      'fecha_anulacion', 'monto_original', 'sincronizado',
    ],
    (isar) async {
      final rows = await isar.ventaAnuladaEntitys.where().findAll();
      return rows
          .map((v) => <String, dynamic>{
                'id': v.id,
                'venta_id_original': v.ventaIdOriginal,
                'motivo': v.motivo,
                'usuario_nombre': v.usuarioNombre,
                'usuario_rol': v.usuarioRol,
                'fecha_anulacion': v.fechaAnulacion,
                'monto_original': v.montoOriginal,
                'sincronizado': v.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'gastos',
    const [
      'id', 'supabase_id', 'descripcion', 'monto', 'moneda', 'tasa_bcv',
      'categoria', 'usuario_nombre', 'fecha', 'sync_status',
    ],
    (isar) async {
      final rows = await isar.gastoEntitys.where().findAll();
      return rows
          .map((g) => <String, dynamic>{
                'id': g.id,
                'supabase_id': g.supabaseId,
                'descripcion': g.descripcion,
                'monto': g.monto,
                'moneda': g.moneda,
                'tasa_bcv': g.tasaBcv,
                'categoria': g.categoria,
                'usuario_nombre': g.usuarioNombre,
                'fecha': g.fecha,
                'sync_status': g.syncStatus,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'gastos_anulados',
    const [
      'id', 'gasto_id_original', 'motivo', 'usuario_nombre',
      'fecha_anulacion', 'monto_original', 'sincronizado',
    ],
    (isar) async {
      final rows = await isar.gastoAnuladoEntitys.where().findAll();
      return rows
          .map((g) => <String, dynamic>{
                'id': g.id,
                'gasto_id_original': g.gastoIdOriginal,
                'motivo': g.motivo,
                'usuario_nombre': g.usuarioNombre,
                'fecha_anulacion': g.fechaAnulacion,
                'monto_original': g.montoOriginal,
                'sincronizado': g.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'productos',
    const [
      'id', 'supabase_id', 'codigo_barras', 'nombre', 'categoria',
      'categoria_id', 'departamento_id', 'marca', 'marca_supabase_id',
      'precio_unidad', 'precio_mayor', 'cantidad_minima_mayor',
      'precio_medio_mayor', 'cantidad_minima_medio_mayor', 'stock',
      'stock_minimo', 'unidad', 'unidades_por_bulto', 'es_pesado',
      'es_ingrediente', 'permite_venta_mayor', 'costo_unitario_promedio',
      'proveedor_nombre', 'activo', 'imagen_url', 'created_at',
      'updated_at', 'sincronizado',
    ],
    (isar) async {
      final rows = await isar.productoEntitys.where().findAll();
      return rows
          .map((p) => <String, dynamic>{
                'id': p.id,
                'supabase_id': p.supabaseId,
                'codigo_barras': p.codigoBarras,
                'nombre': p.nombre,
                'categoria': p.categoria,
                'categoria_id': p.categoriaId,
                'departamento_id': p.departamentoId,
                'marca': p.marca,
                'marca_supabase_id': p.marcaSupabaseId,
                'precio_unidad': p.precioUnidad,
                'precio_mayor': p.precioMayor,
                'cantidad_minima_mayor': p.cantidadMinimaMayor,
                'precio_medio_mayor': p.precioMedioMayor,
                'cantidad_minima_medio_mayor': p.cantidadMinimaMedioMayor,
                'stock': p.stock,
                'stock_minimo': p.stockMinimo,
                'unidad': p.unidad,
                'unidades_por_bulto': p.unidadesPorBulto,
                'es_pesado': p.esPesado,
                'es_ingrediente': p.esIngrediente,
                'permite_venta_mayor': p.permiteVentaMayor,
                'costo_unitario_promedio': p.costoUnitarioPromedio,
                'proveedor_nombre': p.proveedorNombre,
                'activo': p.activo,
                'imagen_url': p.imagenUrl,
                'created_at': p.createdAt,
                'updated_at': p.updatedAt,
                'sincronizado': p.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'categorias',
    const [
      'id', 'supabase_id', 'nombre', 'descripcion', 'activo', 'created_at',
      'updated_at',
    ],
    (isar) async {
      final rows = await isar.categoriaEntitys.where().findAll();
      return rows
          .map((c) => <String, dynamic>{
                'id': c.id,
                'supabase_id': c.supabaseId,
                'nombre': c.nombre,
                'descripcion': c.descripcion,
                'activo': c.activo,
                'created_at': c.createdAt,
                'updated_at': c.updatedAt,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'marcas',
    const [
      'id', 'supabase_id', 'nombre', 'descripcion', 'logo_path', 'activo',
      'created_at', 'updated_at',
    ],
    (isar) async {
      final rows = await isar.marcaEntitys.where().findAll();
      return rows
          .map((m) => <String, dynamic>{
                'id': m.id,
                'supabase_id': m.supabaseId,
                'nombre': m.nombre,
                'descripcion': m.descripcion,
                'logo_path': m.logoPath,
                'activo': m.activo,
                'created_at': m.createdAt,
                'updated_at': m.updatedAt,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'lotes',
    const [
      'id', 'supabase_id', 'producto_id', 'codigo_lote_proveedor',
      'cantidad_inicial', 'cantidad_restante', 'fecha_ingreso',
      'fecha_vencimiento', 'estado', 'costo_unitario', 'proveedor_nombre',
      'sincronizado',
    ],
    (isar) async {
      final rows = await isar.loteEntitys.where().findAll();
      return rows
          .map((l) => <String, dynamic>{
                'id': l.id,
                'supabase_id': l.supabaseId,
                'producto_id': l.productoId,
                'codigo_lote_proveedor': l.codigoLoteProveedor,
                'cantidad_inicial': l.cantidadInicial,
                'cantidad_restante': l.cantidadRestante,
                'fecha_ingreso': l.fechaIngreso,
                'fecha_vencimiento': l.fechaVencimiento,
                'estado': l.estado,
                'costo_unitario': l.costoUnitario,
                'proveedor_nombre': l.proveedorNombre,
                'sincronizado': l.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'movimientos_inventario',
    const [
      'id', 'nombre_producto', 'tipo_movimiento', 'cantidad',
      'stock_resultante', 'fecha', 'usuario_id', 'local_id', 'sync_status',
    ],
    (isar) async {
      final rows = await isar.movimientoInventarioEntitys.where().findAll();
      return rows
          .map((m) => <String, dynamic>{
                'id': m.id,
                'nombre_producto': m.nombreProducto,
                'tipo_movimiento': m.tipoMovimiento,
                'cantidad': m.cantidad,
                'stock_resultante': m.stockResultante,
                'fecha': m.fecha,
                'usuario_id': m.usuarioId,
                'local_id': m.localId,
                'sync_status': m.syncStatus,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'movimientos_lotes',
    const [
      'id', 'lote_id', 'tipo', 'cantidad', 'stock_antes', 'stock_despues',
      'fecha', 'usuario_id', 'observaciones', 'sincronizado',
    ],
    (isar) async {
      final rows = await isar.movimientoLoteEntitys.where().findAll();
      return rows
          .map((m) => <String, dynamic>{
                'id': m.id,
                'lote_id': m.loteId,
                'tipo': m.tipo,
                'cantidad': m.cantidad,
                'stock_antes': m.stockAntes,
                'stock_despues': m.stockDespues,
                'fecha': m.fecha,
                'usuario_id': m.usuarioId,
                'observaciones': m.observaciones,
                'sincronizado': m.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'clientes',
    const [
      'id', 'supabase_id', 'nombre', 'razon_social', 'tipo_documento',
      'documento', 'rif', 'telefono', 'email', 'direccion', 'es_mayorista',
      'limite_credito', 'dias_credito', 'descuento_preferencial',
      'frecuente', 'total_compras', 'cantidad_compras', 'ultima_compra',
      'fecha_nacimiento', 'preferencias_marketing', 'notas', 'activo',
      'fecha_registro',
    ],
    (isar) async {
      final rows = await isar.clienteEntitys.where().findAll();
      return rows
          .map((c) => <String, dynamic>{
                'id': c.id,
                'supabase_id': c.supabaseId,
                'nombre': c.nombre,
                'razon_social': c.razonSocial,
                'tipo_documento': c.tipoDocumento,
                'documento': c.documento,
                'rif': c.rif,
                'telefono': c.telefono,
                'email': c.email,
                'direccion': c.direccion,
                'es_mayorista': c.esMayorista,
                'limite_credito': c.limiteCredito,
                'dias_credito': c.diasCredito,
                'descuento_preferencial': c.descuentoPreferencial,
                'frecuente': c.frecuente,
                'total_compras': c.totalCompras,
                'cantidad_compras': c.cantidadCompras,
                'ultima_compra': c.ultimaCompra,
                'fecha_nacimiento': c.fechaNacimiento,
                'preferencias_marketing': c.preferenciasMarketing,
                'notas': c.notas,
                'activo': c.activo,
                'fecha_registro': c.fechaRegistro,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'proveedores',
    const [
      'id', 'supabase_id', 'nombre', 'empresa', 'tipo_documento',
      'documento', 'rif', 'cedula', 'telefono', 'email', 'direccion',
      'activo',
    ],
    (isar) async {
      final rows = await isar.proveedorEntitys.where().findAll();
      return rows
          .map((p) => <String, dynamic>{
                'id': p.id,
                'supabase_id': p.supabaseId,
                'nombre': p.nombre,
                'empresa': p.empresa,
                'tipo_documento': p.tipoDocumento,
                'documento': p.documento,
                'rif': p.rif,
                'cedula': p.cedula,
                'telefono': p.telefono,
                'email': p.email,
                'direccion': p.direccion,
                'activo': p.activo,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'pedidos',
    const [
      'id', 'supabase_id', 'local_origen_id', 'local_destino_id',
      'proveedor_nombre', 'proveedor_empresa', 'fecha_pedido', 'estado',
      'total', 'observaciones', 'sincronizado',
    ],
    (isar) async {
      final rows = await isar.pedidoEntitys.where().findAll();
      return rows
          .map((p) => <String, dynamic>{
                'id': p.id,
                'supabase_id': p.supabaseId,
                'local_origen_id': p.localOrigenId,
                'local_destino_id': p.localDestinoId,
                'proveedor_nombre': p.proveedorNombre,
                'proveedor_empresa': p.proveedorEmpresa,
                'fecha_pedido': p.fechaPedido,
                'estado': p.estado.name,
                'total': p.total,
                'observaciones': p.observaciones,
                'sincronizado': p.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'detalle_pedidos',
    const [
      'id', 'supabase_id', 'pedido_id', 'producto_id', 'nombre_producto',
      'cantidad', 'precio_unidad', 'subtotal',
    ],
    (isar) async {
      final rows = await isar.detallePedidoEntitys.where().findAll();
      return rows
          .map((d) => <String, dynamic>{
                'id': d.id,
                'supabase_id': d.supabaseId,
                'pedido_id': d.pedidoId,
                'producto_id': d.productoId,
                'nombre_producto': d.nombreProducto,
                'cantidad': d.cantidad,
                'precio_unidad': d.precioUnidad,
                'subtotal': d.subtotal,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'recepciones',
    const [
      'id', 'supabase_id', 'pedido_id', 'fecha_recepcion', 'usuario_id',
      'observaciones', 'sincronizado',
    ],
    (isar) async {
      final rows = await isar.recepcionEntitys.where().findAll();
      return rows
          .map((r) => <String, dynamic>{
                'id': r.id,
                'supabase_id': r.supabaseId,
                'pedido_id': r.pedidoId,
                'fecha_recepcion': r.fechaRecepcion,
                'usuario_id': r.usuarioId,
                'observaciones': r.observaciones,
                'sincronizado': r.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'turnos',
    const [
      'id', 'turno_id', 'usuario_nombre', 'caja_nombre', 'monto_inicial',
      'monto_final', 'fecha_apertura', 'fecha_cierre', 'estado',
      'ventas_count', 'total_ventas',
    ],
    (isar) async {
      final rows = await isar.turnoEntitys.where().findAll();
      return rows
          .map((t) => <String, dynamic>{
                'id': t.id,
                'turno_id': t.turnoId,
                'usuario_nombre': t.usuarioNombre,
                'caja_nombre': t.cajaNombre,
                'monto_inicial': t.montoInicial,
                'monto_final': t.montoFinal,
                'fecha_apertura': t.fechaApertura,
                'fecha_cierre': t.fechaCierre,
                'estado': t.estado,
                'ventas_count': t.ventasCount,
                'total_ventas': t.totalVentas,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'comandas',
    const [
      'id', 'session_id', 'supabase_id', 'sync_key', 'mesa_id',
      'mesa_nombre', 'nombre', 'estado', 'comensales', 'mesero_nombre',
      'notas', 'total', 'enviada_cocina_at', 'cerrada_at', 'created_at',
      'updated_at', 'sincronizado',
    ],
    (isar) async {
      final rows = await isar.cartSessionEntitys.where().findAll();
      return rows
          .map((c) => <String, dynamic>{
                'id': c.id,
                'session_id': c.sessionId,
                'supabase_id': c.supabaseId,
                'sync_key': c.syncKey,
                'mesa_id': c.mesaId,
                'mesa_nombre': c.mesaNombre,
                'nombre': c.nombre,
                'estado': c.comandaEstado.name,
                'comensales': c.comensales,
                'mesero_nombre': c.meseroNombre,
                'notas': c.notas,
                'total': c.total,
                'enviada_cocina_at': c.enviadaCocinaAt,
                'cerrada_at': c.cerradaAt,
                'created_at': c.createdAt,
                'updated_at': c.updatedAt,
                'sincronizado': c.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'comandas_items',
    const [
      'comanda_id', 'comanda_sync_key', 'mesa_id', 'mesa_nombre',
      'comanda_estado', 'linea', 'producto_id', 'producto_nombre',
      'cantidad', 'precio_unidad', 'subtotal', 'nota', 'estacion_nombre',
      'estado_plato', 'pausado', 'motivo_pausa', 'enviado_a_cocina_at',
    ],
    (isar) async {
      final comandas = await isar.cartSessionEntitys.where().findAll();
      final filas = <Map<String, dynamic>>[];
      for (final c in comandas) {
        for (var i = 0; i < c.items.length; i++) {
          final item = c.items[i];
          filas.add(<String, dynamic>{
            'comanda_id': c.id,
            'comanda_sync_key': c.syncKey,
            'mesa_id': c.mesaId,
            'mesa_nombre': c.mesaNombre,
            'comanda_estado': c.comandaEstado.name,
            'linea': i + 1,
            'producto_id': item.productoId,
            'producto_nombre': item.productoNombre,
            'cantidad': item.cantidad,
            'precio_unidad': item.precioUnidad,
            'subtotal': item.precioUnidad * item.cantidad,
            'nota': item.nota,
            'estacion_nombre': item.estacionNombre,
            'estado_plato': item.estadoPlato.name,
            'pausado': item.pausado,
            'motivo_pausa': item.motivoPausa,
            'enviado_a_cocina_at': item.enviadoACocinaAt,
          });
        }
      }
      return filas;
    },
  ),
  _TablaExportable(
    'mesas',
    const [
      'id', 'supabase_id', 'nombre', 'zona_nombre', 'zona_legacy',
      'capacidad', 'estado', 'orden_grid', 'unida_con_mesa_id',
      'ocupada_desde', 'eliminado', 'sincronizado', 'created_at',
      'updated_at',
    ],
    (isar) async {
      final rows = await isar.mesaEntitys.where().findAll();
      return rows
          .map((m) => <String, dynamic>{
                'id': m.id,
                'supabase_id': m.supabaseId,
                'nombre': m.nombre,
                'zona_nombre': m.zonaNombre,
                'zona_legacy': m.zona.name,
                'capacidad': m.capacidad,
                'estado': m.estado.name,
                'orden_grid': m.ordenGrid,
                'unida_con_mesa_id': m.unidaConMesaId,
                'ocupada_desde': m.ocupadaDesde,
                'eliminado': m.eliminado,
                'sincronizado': m.sincronizado,
                'created_at': m.createdAt,
                'updated_at': m.updatedAt,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'zonas',
    const [
      'id', 'supabase_id', 'nombre', 'orden', 'activo', 'eliminado',
      'sincronizado', 'created_at', 'updated_at',
    ],
    (isar) async {
      final rows = await isar.zonaEntitys.where().findAll();
      return rows
          .map((z) => <String, dynamic>{
                'id': z.id,
                'supabase_id': z.supabaseId,
                'nombre': z.nombre,
                'orden': z.orden,
                'activo': z.activo,
                'eliminado': z.eliminado,
                'sincronizado': z.sincronizado,
                'created_at': z.createdAt,
                'updated_at': z.updatedAt,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'departamentos',
    const [
      'id', 'supabase_id', 'nombre', 'descripcion', 'orden', 'activo',
      'sincronizado',
    ],
    (isar) async {
      final rows = await isar.departamentoEntitys.where().findAll();
      return rows
          .map((d) => <String, dynamic>{
                'id': d.id,
                'supabase_id': d.supabaseId,
                'nombre': d.nombre,
                'descripcion': d.descripcion,
                'orden': d.orden,
                'activo': d.activo,
                'sincronizado': d.sincronizado,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'usuarios',
    // ⚠️ Sin `pin` ni `password`: es un archivo que se comparte.
    const [
      'id', 'supabase_id', 'nombre', 'rol', 'activo', 'estado',
      'caja_asignada', 'email', 'departamento', 'local_id', 'created_at',
      'updated_at',
    ],
    (isar) async {
      final rows = await isar.usuarioEntitys.where().findAll();
      return rows
          .map((u) => <String, dynamic>{
                'id': u.id,
                'supabase_id': u.supabaseId,
                'nombre': u.nombre,
                'rol': u.rol,
                'activo': u.activo,
                'estado': u.estado,
                'caja_asignada': u.cajaAsignada,
                'email': u.email,
                'departamento': u.departamento,
                'local_id': u.localId,
                'created_at': u.createdAt,
                'updated_at': u.updatedAt,
              })
          .toList();
    },
  ),
  _TablaExportable(
    'logs',
    const [
      'id', 'usuario_nombre', 'usuario_rol', 'accion', 'detalles', 'fecha',
      'sincronizado',
    ],
    (isar) async {
      final rows = await isar.logEntitys.where().findAll();
      return rows
          .map((l) => <String, dynamic>{
                'id': l.id,
                'usuario_nombre': l.usuarioNombre,
                'usuario_rol': l.usuarioRol,
                'accion': l.accion,
                'detalles': l.detalles,
                'fecha': l.fecha,
                'sincronizado': l.sincronizado,
              })
          .toList();
    },
  ),
];
