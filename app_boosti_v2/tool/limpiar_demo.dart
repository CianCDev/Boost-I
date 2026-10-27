// Limpieza de los datos de demostración del modo restaurante.
//
//   dart run tool/limpiar_demo.dart                 → simulación (no escribe)
//   dart run tool/limpiar_demo.dart --apply         → borra de verdad
//
// Opciones:
//   --dir <ruta>      carpeta Isar (default: %USERPROFILE%\Documents\isar_default)
//   --antes <fecha>   borra comandas creadas ANTES de esa fecha (AAAA-MM-DD)
//                     (default: la fecha de hoy)
//
// Qué borra, y solo esto:
//   · Comandas con 0 items (fantasmas de mesas que se movieron o cancelaron).
//   · Comandas creadas antes de `--antes` (la demo del seed del 23/10).
//
// Qué NO toca:
//   · Ventas, detalles, movimientos de inventario ni lotes.
//   · Productos, clientes, proveedores ni usuarios.
//
// Y después de borrar: libera toda mesa que se quede sin comanda viva
// (`libre`, `ocupadaDesde = null`). Si una mesa tiene otra comanda viva, se
// respeta.
//
// ⚠️ La app tiene que estar CERRADA (Isar es de un solo proceso).

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

String? _arg(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}

Future<void> main(List<String> args) async {
  final aplicar = args.contains('--apply');
  final dir = _arg(args, '--dir') ??
      '${Platform.environment['USERPROFILE']}\\Documents\\isar_default';

  final ahora = DateTime.now();
  final antes = DateTime.tryParse(_arg(args, '--antes') ?? '') ??
      DateTime(ahora.year, ahora.month, ahora.day);

  if (!Directory(dir).existsSync()) {
    stdout.writeln('No existe la carpeta: $dir');
    exit(1);
  }

  stdout.writeln('Carpeta: $dir');
  stdout.writeln('Corte: comandas creadas antes de $antes');
  stdout.writeln(aplicar
      ? 'MODO ESCRITURA (--apply)'
      : 'SIMULACION (agrega --apply para escribir)');
  stdout.writeln('');

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

  // Solo se cuentan las comandas abiertas/enviadas: una cancelada o cerrada
  // ya no ocupa mesa, así que no debe impedir liberarla.
  final comandas = await isar.cartSessionEntitys.where().findAll();
  final aBorrar = <CartSessionEntity>[];
  final infoAntes = <String>[];

  for (final c in comandas) {
    final vacia = c.items.isEmpty;
    final vieja = c.createdAt.isBefore(antes);
    if (!vacia && !vieja) continue;
    aBorrar.add(c);
    final motivo = vacia ? '0 items' : 'creada ${c.createdAt}';
    infoAntes.add(
      '  id=${c.id}  session="${c.sessionId}"  mesa=${c.mesaNombre}'
      '  estado=${c.comandaEstado.name}  items=${c.items.length}  ($motivo)',
    );
  }

  final idsBorrados = aBorrar.map((c) => c.id).toSet();
  final vivas = comandas.where((c) => !idsBorrados.contains(c.id)).toList();
  final mesasOcupadasPorVivas = vivas
      .where((c) =>
          c.comandaEstado == ComandaEstado.abierta ||
          c.comandaEstado == ComandaEstado.enviada)
      .map((c) => c.mesaId)
      .whereType<int>()
      .toSet();

  stdout.writeln('=== COMANDAS A BORRAR: ${aBorrar.length} de ${comandas.length} ===');
  for (final l in infoAntes) {
    stdout.writeln(l);
  }
  stdout.writeln('');

  final mesas = await isar.mesaEntitys.where().findAll();
  final aLiberar = mesas
      .where((m) =>
          m.estado == MesaEstado.ocupada &&
          !mesasOcupadasPorVivas.contains(m.id))
      .toList();

  stdout.writeln('=== MESAS A LIBERAR: ${aLiberar.length} ===');
  for (final m in aLiberar) {
    stdout.writeln(
      '  id=${m.id}  "${m.nombre}"  era=${m.estado.name}'
      '  desde=${m.ocupadaDesde}',
    );
  }
  stdout.writeln('');

  if (vivas.isNotEmpty) {
    stdout.writeln('=== COMANDAS QUE SE CONSERVAN ===');
    for (final c in vivas) {
      stdout.writeln(
        '  id=${c.id}  session="${c.sessionId}"  mesa=${c.mesaNombre}'
        '  estado=${c.comandaEstado.name}  items=${c.items.length}',
      );
    }
    stdout.writeln('');
  }

  if (!aplicar) {
    stdout.writeln('Simulacion terminada. Nada se escribio.');
    await isar.close();
    return;
  }

  await isar.writeTxn(() async {
    await isar.cartSessionEntitys.deleteAll(
      aBorrar.map((c) => c.id).toList(),
    );
    final sello = DateTime.now();
    for (final m in aLiberar) {
      m
        ..estado = MesaEstado.libre
        ..ocupadaDesde = null
        ..updatedAt = sello;
      await isar.mesaEntitys.put(m);
    }
  });

  stdout.writeln('Borradas ${aBorrar.length} comandas.');
  stdout.writeln('Liberadas ${aLiberar.length} mesas.');
  stdout.writeln('');
  stdout.writeln('=== QUEDAN ===');
  final restantes = await isar.cartSessionEntitys.where().findAll();
  stdout.writeln('  comandas: ${restantes.length}');
  for (final c in restantes) {
    stdout.writeln(
      '  id=${c.id}  session="${c.sessionId}"  mesa=${c.mesaNombre}'
      '  estado=${c.comandaEstado.name}  items=${c.items.length}',
    );
  }
  final mesasFinal = await isar.mesaEntitys.where().findAll();
  for (final m in mesasFinal) {
    stdout.writeln('  mesa id=${m.id}  "${m.nombre}"  ${m.estado.name}');
  }

  await isar.close();
}
