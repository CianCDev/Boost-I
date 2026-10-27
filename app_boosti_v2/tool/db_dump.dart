// Herramienta de diagnóstico: abre la base Isar de la app y muestra
// qué hay dentro, sin escribir nada.
//
// Uso:
//   dart run tool/db_dump.dart "C:\Users\Yan\Documents\isar_default"
//
// ⚠️ La app tiene que estar CERRADA: Isar no permite dos procesos.

import 'dart:io';

import 'package:isar/isar.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_inventario_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/gasto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/turno_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/categoria_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/marca_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/empleado_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/horario_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/nomina_pago_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pago_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cotizacion_mayor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/autorizacion_descuento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/config_descuento_mayorista_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/plan_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/suscripcion_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_anulada_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/gasto_anulado_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/receta_entity.dart';

Future<void> main(List<String> args) async {
  final dir = args.isNotEmpty
      ? args[0]
      : '${Platform.environment['USERPROFILE']}\\Documents\\isar_default';

  if (!Directory(dir).existsSync()) {
    stdout.writeln('❌ No existe la carpeta: $dir');
    exit(1);
  }

  final isar = await Isar.open(
    [
      VentaEntitySchema,
      DetalleVentaEntitySchema,
      ProductoEntitySchema,
      UsuarioEntitySchema,
      MovimientoInventarioEntitySchema,
      GastoEntitySchema,
      LogEntitySchema,
      PedidoEntitySchema,
      DetallePedidoEntitySchema,
      RecepcionEntitySchema,
      CartSessionEntitySchema,
      TurnoEntitySchema,
      LocalEntitySchema,
      ProveedorEntitySchema,
      CodigoBarrasAliasEntitySchema,
      LoteEntitySchema,
      DepartamentoEntitySchema,
      TelegramConfigEntitySchema,
      CategoriaEntitySchema,
      MarcaEntitySchema,
      MovimientoLoteEntitySchema,
      ClienteEntitySchema,
      EmpleadoInfoEntitySchema,
      HorarioEntitySchema,
      NominaPagoEntitySchema,
      PagoVentaEntitySchema,
      CotizacionMayorEntitySchema,
      AutorizacionDescuentoEntitySchema,
      ConfigDescuentoMayoristaEntitySchema,
      PlanEntitySchema,
      SuscripcionEntitySchema,
      VentaAnuladaEntitySchema,
      GastoAnuladoEntitySchema,
      MesaEntitySchema,
      RecetaEntitySchema,
    ],
    directory: dir,
    name: 'default',
  );

  stdout.writeln('📂 $dir');
  stdout.writeln('');

  Future<void> fila(String nombre, Future<int> Function() f) async {
    final n = await f();
    stdout.writeln('  ${nombre.padRight(24)} $n');
  }

  stdout.writeln('=== CONTEO POR COLECCIÓN ===');
  await fila('locales', () => isar.localEntitys.count());
  await fila('usuarios', () => isar.usuarioEntitys.count());
  await fila('productos', () => isar.productoEntitys.count());
  await fila('categorias', () => isar.categoriaEntitys.count());
  await fila('departamentos', () => isar.departamentoEntitys.count());
  await fila('marcas', () => isar.marcaEntitys.count());
  await fila('lotes', () => isar.loteEntitys.count());
  await fila('clientes', () => isar.clienteEntitys.count());
  await fila('ventas', () => isar.ventaEntitys.count());
  await fila('detalle ventas', () => isar.detalleVentaEntitys.count());
  await fila('pagos venta', () => isar.pagoVentaEntitys.count());
  await fila('gastos', () => isar.gastoEntitys.count());
  await fila('turnos', () => isar.turnoEntitys.count());
  await fila('mesas', () => isar.mesaEntitys.count());
  await fila('comandas', () => isar.cartSessionEntitys.count());
  await fila('pedidos', () => isar.pedidoEntitys.count());
  await fila('planes', () => isar.planEntitys.count());
  await fila('suscripciones', () => isar.suscripcionEntitys.count());
  await fila('mov. inventario', () => isar.movimientoInventarioEntitys.count());
  await fila('recetas', () => isar.recetaEntitys.count());
  await fila('logs', () => isar.logEntitys.count());

  stdout.writeln('');
  stdout.writeln('=== LOCALES ===');
  for (final l in await isar.localEntitys.where().findAll()) {
    stdout.writeln(
      '  id=${l.id}  supabaseId=${l.supabaseId}  "${l.nombre}"  modo=${l.businessMode}  activo=${l.activo}',
    );
  }

  stdout.writeln('');
  stdout.writeln('=== USUARIOS ===');
  for (final u in await isar.usuarioEntitys.where().findAll()) {
    stdout.writeln(
      '  id=${u.id}  "${u.nombre}"  rol=${u.rol}  activo=${u.activo}  localId=${u.localId}  tenant=${u.tenantId}',
    );
  }

  stdout.writeln('');
  stdout.writeln('=== PLANES ===');
  for (final p in await isar.planEntitys.where().findAll()) {
    stdout.writeln('  ${p.planId}  "${p.nombre}"  orden=${p.orden}');
  }

  stdout.writeln('');
  stdout.writeln('=== SUSCRIPCIONES ===');
  for (final s in await isar.suscripcionEntitys.where().findAll()) {
    stdout.writeln(
      '  tenant=${s.tenantId}  plan=${s.planId}  estado=${s.estado}  activa=${s.activa}',
    );
  }

  stdout.writeln('');
  stdout.writeln('=== MESAS ===');
  for (final m in await isar.mesaEntitys.where().findAll()) {
    stdout.writeln(
      '  id=${m.id}  "${m.nombre}"  localId=${m.localId}  zona=${m.zona.name}  estado=${m.estado.name}',
    );
  }

  stdout.writeln('');
  stdout.writeln('=== COMANDAS ===');
  final comandas = await isar.cartSessionEntitys.where().findAll();
  stdout.writeln('  total: ${comandas.length}');
  for (final c in comandas) {
    stdout.writeln(
      '  id=${c.id}  session="${c.sessionId}"  estado=${c.comandaEstado.name}'
      '  mesaId=${c.mesaId}  mesa="${c.mesaNombre}"  items=${c.items.length}'
      '  creada=${c.createdAt}',
    );
    for (final i in c.items) {
      stdout.writeln(
        '      · ${i.productoNombre}  cant=${i.cantidad}'
        '  estado=${i.estadoPlato.name}  enviado=${i.enviadoACocinaAt}',
      );
    }
  }

  // ── Lotes: fecha de vencimiento nula ──
  //
  // Se imprime porque `obtenerLotesVencidosConStock()` filtra con
  // `fechaVencimientoLessThan(inicioDia)` y en Isar los `null` ordenan
  // como "menores que todo": un lote sin fecha entraba en la alerta de
  // vencidos y hacía estallar el `!` del diálogo.
  stdout.writeln('');
  stdout.writeln('=== LOTES ===');
  final lotes = await isar.loteEntitys.where().findAll();
  stdout.writeln('  total: ${lotes.length}');
  var sinFecha = 0;
  for (final l in lotes) {
    if (l.fechaVencimiento == null) sinFecha++;
    stdout.writeln(
      '  id=${l.id}  productoId=${l.productoId}'
      '  restante=${l.cantidadRestante}'
      '  vence=${l.fechaVencimiento ?? "SIN FECHA"}'
      '  estado=${l.estado}',
    );
  }
  stdout.writeln('  sin fecha de vencimiento: $sinFecha');

  // ── Rango de ventas y actividad de hoy ──
  final ventas = await isar.ventaEntitys.where().findAll();
  if (ventas.isNotEmpty) {
    final fechas = ventas
        .map((v) => v.fecha)
        .whereType<DateTime>()
        .toList()
      ..sort();
    final ahora = DateTime.now();
    final inicioHoy = DateTime(ahora.year, ahora.month, ahora.day);
    final hoy = fechas.where((f) => !f.isBefore(inicioHoy)).toList();
    final totalHoy = ventas
        .where((v) => v.fecha != null && !v.fecha!.isBefore(inicioHoy))
        .fold<double>(0, (s, v) => s + v.total);

    stdout.writeln('');
    stdout.writeln('=== VENTAS ===');
    stdout.writeln('  primera     ${fechas.first}');
    stdout.writeln('  ultima      ${fechas.last}');
    stdout.writeln('  hoy         ${hoy.length} ventas · \$${totalHoy.toStringAsFixed(2)}');
  }

  await isar.close();
  stdout.writeln('');
  stdout.writeln('✅ listo');
}
