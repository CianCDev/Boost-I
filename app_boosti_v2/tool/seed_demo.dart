// Inyector de datos de demostración para Boosti POS.
//
//   dart run tool/seed_demo.dart                → simulación (no escribe nada)
//   dart run tool/seed_demo.dart --apply        → escribe en la base real
//
// Opciones:
//   --dir <ruta>        carpeta Isar (default: %USERPROFILE%\Documents\isar_default)
//   --local <id>        id Isar del local a poblar (default: 2)
//   --mode <modo>       retail | restaurante | servicios (default: restaurante)
//   --ventas <n>        ventas históricas a generar (default: 120; 0 = ninguna)
//   --dias <n>          días hacia atrás (default: 30)
//
// ⚠️ TODO lo que crea lleva syncStatus/sincronizado = synced para que
//    SyncService NO lo suba a Supabase. Es data de prueba, no de producción.
// ⚠️ La app tiene que estar CERRADA (Isar es de un solo proceso).

import 'dart:io';
import 'dart:math';

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
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
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

// ─────────────────────────────────────────────────────────────
// Configuración de la demo
// ─────────────────────────────────────────────────────────────

const double kTasaBcv = 879.1225;

class _ProductoDemo {
  final String nombre;
  final String categoria;
  final double precio;
  final bool vaACocina;
  const _ProductoDemo(this.nombre, this.categoria, this.precio, this.vaACocina);
}

const List<_ProductoDemo> _menu = [
  _ProductoDemo('Arepa Reina Pepiada', 'Platos', 4.50, true),
  _ProductoDemo('Hamburguesa Boosti', 'Platos', 6.50, true),
  _ProductoDemo('Pabellón Criollo', 'Platos', 7.00, true),
  _ProductoDemo('Pollo a la Plancha', 'Platos', 6.00, true),
  _ProductoDemo('Parrilla Mixta', 'Platos', 12.00, true),
  _ProductoDemo('Sopa de Res', 'Platos', 5.00, true),
  _ProductoDemo('Ensalada César', 'Platos', 4.00, true),
  _ProductoDemo('Refresco 350ml', 'Bebidas', 1.50, false),
  _ProductoDemo('Jugo Natural', 'Bebidas', 2.00, false),
  _ProductoDemo('Agua Mineral', 'Bebidas', 1.20, false),
  _ProductoDemo('Café', 'Bebidas', 1.00, false),
  _ProductoDemo('Cerveza', 'Bebidas', 2.50, false),
  _ProductoDemo('Quesillo', 'Postres', 3.00, true),
  _ProductoDemo('Tres Leches', 'Postres', 3.50, true),
];

const List<String> _metodosPago = [
  'Efectivo',
  'Efectivo',
  'Efectivo',
  'Pago Móvil',
  'Pago Móvil',
  'Transferencia',
  'Punto de Venta',
];

const List<List<String>> _clientesDemo = [
  ['María González', '12345678', '0414-1234567', 'maria.gonzalez@correo.com'],
  ['José Pérez', '87654321', '0424-7654321', 'jose.perez@correo.com'],
  ['Carmen Rodríguez', '15478963', '0416-9876543', 'carmen.r@correo.com'],
  ['Luis Herrera', '20147859', '0412-5554433', 'luis.herrera@correo.com'],
  ['Ana Salazar', '18745236', '0426-1112233', 'ana.salazar@correo.com'],
  ['Pedro Marcano', '13579246', '0414-8887766', 'pedro.marcano@correo.com'],
  ['Rosa Bermúdez', '24681357', '0412-3334455', 'rosa.b@correo.com'],
  ['Carlos Rivas', '97531864', '0424-9998877', 'carlos.rivas@correo.com'],
];

// ─────────────────────────────────────────────────────────────

String? _arg(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}

Future<void> main(List<String> args) async {
  final aplicar = args.contains('--apply');
  final dir = _arg(args, '--dir') ??
      '${Platform.environment['USERPROFILE']}\\Documents\\isar_default';
  final localId = int.tryParse(_arg(args, '--local') ?? '2') ?? 2;
  final modo = _arg(args, '--mode') ?? 'restaurante';
  final totalVentas = int.tryParse(_arg(args, '--ventas') ?? '120') ?? 120;
  final dias = int.tryParse(_arg(args, '--dias') ?? '30') ?? 30;

  if (!Directory(dir).existsSync()) {
    stdout.writeln('❌ No existe la carpeta: $dir');
    exit(1);
  }

  stdout.writeln('📂 $dir');
  stdout.writeln('🎯 local=$localId  modo=$modo  ventas=$totalVentas  días=$dias');
  stdout.writeln(aplicar
      ? '🔥 MODO ESCRITURA (--apply)'
      : '🧪 SIMULACIÓN (agregá --apply para escribir)');
  stdout.writeln('');

  // Respaldo antes de abrir.
  if (aplicar) {
    final origen = File('$dir/default.isar');
    if (origen.existsSync()) {
      final sello = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '')
          .replaceAll('.', '')
          .substring(0, 15);
      final destino = File('$dir/default.isar.bak-$sello');
      origen.copySync(destino.path);
      stdout.writeln('💾 Respaldo: ${destino.path}');
      stdout.writeln('');
    }
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

  final local = await isar.localEntitys.get(localId);
  if (local == null) {
    stdout.writeln('❌ No existe el local con id $localId');
    await isar.close();
    exit(1);
  }

  stdout.writeln('🏪 Local: ${local.nombre} (${local.supabaseId})');
  stdout.writeln('');

  final now = DateTime.now();
  final rnd = Random(42);

  // ── 1. Modo de negocio ──────────────────────────────────────
  stdout.writeln('1️⃣  Modo de negocio: ${local.businessMode} → $modo');
  if (aplicar) {
    local
      ..businessMode = modo
      ..modoConfiguradoEn = now
      ..sincronizado = false
      ..updatedAt = now;
    await isar.writeTxn(() => isar.localEntitys.put(local));
  }

  // ── 2. Departamentos (estaciones) ───────────────────────────
  var departamentos = await isar.departamentoEntitys
      .filter()
      .localIdEqualTo(localId)
      .findAll();

  if (aplicar) {
    for (final nombre in ['Cocina', 'Barra', 'Postres']) {
      final yaExiste = departamentos.any(
        (d) => d.nombre.toLowerCase() == nombre.toLowerCase(),
      );
      if (yaExiste) continue;
      final d = DepartamentoEntity()
        ..nombre = nombre
        ..descripcion = 'Estación de $nombre'
        ..localId = localId
        ..orden = departamentos.length
        ..activo = true
        ..sincronizado = true
        ..createdAt = now
        ..updatedAt = now;
      await isar.writeTxn(() => isar.departamentoEntitys.put(d));
    }
    departamentos = await isar.departamentoEntitys
        .filter()
        .localIdEqualTo(localId)
        .findAll();
  }
  stdout.writeln('2️⃣  Departamentos: ${departamentos.map((d) => d.nombre).join(', ')}');

  int? idDepartamento(String nombre) {
    for (final d in departamentos) {
      if (d.nombre.toLowerCase() == nombre.toLowerCase()) return d.id;
    }
    return departamentos.isEmpty ? null : departamentos.first.id;
  }

  // ── 3. Categorías ───────────────────────────────────────────
  final Map<String, int> categoriaId = {};
  for (final nombre in ['Platos', 'Bebidas', 'Postres']) {
    final existente = await isar.categoriaEntitys
        .filter()
        .nombreEqualTo(nombre)
        .findFirst();
    if (existente != null) {
      categoriaId[nombre] = existente.id;
    } else if (aplicar) {
      final c = CategoriaEntity(nombre: nombre)
        ..descripcion = 'Categoría demo'
        ..activo = true
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = 'synced';
      final id = await isar.writeTxn(() => isar.categoriaEntitys.put(c));
      categoriaId[nombre] = id;
    }
  }
  stdout.writeln('3️⃣  Categorías: ${categoriaId.keys.join(', ')}');

  // ── 4. Productos del menú ───────────────────────────────────
  final Map<String, ProductoEntity> productos = {};
  var creados = 0;

  for (var i = 0; i < _menu.length; i++) {
    final demo = _menu[i];
    var p = await isar.productoEntitys
        .filter()
        .nombreEqualTo(demo.nombre)
        .findFirst();

    if (p == null && aplicar) {
      p = ProductoEntity()
        ..codigoBarras = 'DEMO-${(i + 1).toString().padLeft(3, '0')}'
        ..nombre = demo.nombre
        ..precioUnidad = demo.precio
        ..stock = 100
        ..stockMinimo = 10
        ..categoria = demo.categoria
        ..categoriaId = categoriaId[demo.categoria]
        ..departamentoId = demo.vaACocina
            ? idDepartamento(demo.categoria == 'Postres' ? 'Postres' : 'Cocina')
            : null
        ..unidad = 'unidad'
        ..activo = true
        ..sincronizado = true
        ..createdAt = now
        ..updatedAt = now;
      await isar.writeTxn(() => isar.productoEntitys.put(p!));
      creados++;
    }
    if (p != null) {
      final esperado = demo.vaACocina
          ? idDepartamento(demo.categoria == 'Postres' ? 'Postres' : 'Cocina')
          : null;
      if (aplicar && p.departamentoId != esperado) {
        final actualizar = p
          ..departamentoId = esperado
          ..updatedAt = now;
        await isar.writeTxn(() => isar.productoEntitys.put(actualizar));
      }
      productos[demo.nombre] = p;
    }
  }
  stdout.writeln(
      '4️⃣  Productos: ${productos.length} disponibles (nuevos: $creados)');

  // ── 5. Mesas ────────────────────────────────────────────────
  final List<MesaEntity> mesasDemo = [
    MesaEntity()
      ..nombre = 'Salón 1'
      ..zona = MesaZona.salon
      ..capacidad = 4
      ..ordenGrid = 0,
    MesaEntity()
      ..nombre = 'Salón 2'
      ..zona = MesaZona.salon
      ..capacidad = 4
      ..ordenGrid = 1,
    MesaEntity()
      ..nombre = 'Salón 3'
      ..zona = MesaZona.salon
      ..capacidad = 2
      ..ordenGrid = 2,
    MesaEntity()
      ..nombre = 'Salón 4'
      ..zona = MesaZona.salon
      ..capacidad = 6
      ..ordenGrid = 3,
    MesaEntity()
      ..nombre = 'Terraza 1'
      ..zona = MesaZona.terraza
      ..capacidad = 6
      ..ordenGrid = 4,
    MesaEntity()
      ..nombre = 'Terraza 2'
      ..zona = MesaZona.terraza
      ..capacidad = 4
      ..ordenGrid = 5,
    MesaEntity()
      ..nombre = 'Barra 1'
      ..zona = MesaZona.bar
      ..capacidad = 2
      ..ordenGrid = 6,
    MesaEntity()
      ..nombre = 'Privado 1'
      ..zona = MesaZona.privado
      ..capacidad = 8
      ..ordenGrid = 7,
  ];

  for (final m in mesasDemo) {
    m
      ..localId = localId
      ..localSupabaseId = local.supabaseId
      ..recalcularClaveUnica()
      ..estado = MesaEstado.libre
      ..createdAt = now
      ..updatedAt = now
      ..sincronizado = true;
  }

  if (aplicar) {
    await isar.writeTxn(() async {
      for (final m in mesasDemo) {
        final existente = await isar.mesaEntitys
            .filter()
            .claveUnicaEqualTo(m.claveUnica)
            .findFirst();
        if (existente == null) {
          await isar.mesaEntitys.put(m);
        } else {
          m.id = existente.id;
        }
      }
    });
  }
  final mesas = await isar.mesaEntitys
      .filter()
      .localIdEqualTo(localId)
      .sortByOrdenGrid()
      .findAll();
  stdout.writeln('5️⃣  Mesas: ${mesas.length}');

  // ── 6. Clientes ─────────────────────────────────────────────
  var clientesCreados = 0;
  final clientes = <ClienteEntity>[];
  for (final c in _clientesDemo) {
    var cli = await isar.clienteEntitys
        .filter()
        .nombreEqualTo(c[0])
        .findFirst();
    if (cli == null && aplicar) {
      cli = ClienteEntity()
        ..nombre = c[0]
        ..documento = int.tryParse(c[1])
        ..tipoDocumento = 'V'
        ..telefono = c[2]
        ..email = c[3]
        ..localId = localId
        ..localSupabaseId = local.supabaseId
        ..fechaRegistro = now.subtract(Duration(days: 20 + rnd.nextInt(200)))
        ..activo = true
        ..syncStatus = 'synced'
        ..createdAt = now
        ..updatedAt = now;
      await isar.writeTxn(() => isar.clienteEntitys.put(cli!));
      clientesCreados++;
    }
    if (cli != null) clientes.add(cli);
  }
  stdout.writeln(
      '6️⃣  Clientes: ${clientes.length} (nuevos: $clientesCreados)');

  // ── 7. Comandas abiertas (solo restaurante) ─────────────────
  var comandasCreadas = 0;
  if (modo == 'restaurante' && mesas.length >= 3 && aplicar) {
    final mesero = await isar.usuarioEntitys
        .filter()
        .rolEqualTo('cajero')
        .findFirst();
    final meseroId = mesero?.id ?? 0;
    final meseroNombre = mesero?.nombre ?? 'Mesero';

    Future<void> crearComanda({
      required MesaEntity mesa,
      required List<(String, EstadoPlato, String?)> lineas,
      required ComandaEstado estado,
      required int comensales,
      String? clienteNombre,
      int? clienteId,
      String? nota,
    }) async {
      final existente = await isar.cartSessionEntitys
          .filter()
          .sessionIdEqualTo('mesa:${mesa.id}')
          .findFirst();
      if (existente != null) return;

      final enviada = estado == ComandaEstado.enviada;
      final c = CartSessionEntity()
        ..sessionId = 'mesa:${mesa.id}'
        ..usuarioId = meseroId
        ..meseroId = meseroId
        ..meseroNombre = meseroNombre
        ..nombre = 'Comanda ${mesa.nombre}'
        ..mesaId = mesa.id
        ..mesaNombre = mesa.nombre
        ..comensales = comensales
        ..comandaEstado = estado
        ..clienteId = clienteId
        ..clienteNombre = clienteNombre
        ..notas = nota
        ..createdAt = now.subtract(Duration(minutes: 15 + rnd.nextInt(40)))
        ..updatedAt = now
        ..enviadaCocinaAt =
            enviada ? now.subtract(Duration(minutes: 5 + rnd.nextInt(20))) : null
        ..sincronizado = true;

      for (final linea in lineas) {
        final p = productos[linea.$1];
        if (p == null) continue;
        final item = CartSessionItem()
          ..productoId = p.supabaseId ?? 'local-${p.id}'
          ..productoIdLocal = p.id
          ..productoNombre = p.nombre
          ..productoCodigoBarras = p.codigoBarras
          ..productoCategoria = p.categoria
          ..precioUnidad = p.precioUnidad
          ..precioOriginal = p.precioUnidad
          ..cantidad = 1
          ..estadoPlato = linea.$2
          ..nota = linea.$3
          ..estacionId = p.departamentoId
          ..meseroId = meseroId
          ..meseroNombre = meseroNombre
          ..enviadoACocinaAt =
              enviada ? now.subtract(Duration(minutes: 10 + rnd.nextInt(20))) : null
          ..preparacionIniciadaAt = linea.$2 == EstadoPlato.enPreparacion ||
                  linea.$2 == EstadoPlato.listo
              ? now.subtract(Duration(minutes: 6))
              : null
          ..listoAt = linea.$2 == EstadoPlato.listo
              ? now.subtract(Duration(minutes: 2))
              : null;
        c.items.add(item);
      }
      c.itemsNombres = c.items.map((i) => i.productoNombre).toList();

      await isar.writeTxn(() async {
        await isar.cartSessionEntitys.put(c);
        mesa
          ..estado = MesaEstado.ocupada
          ..ocupadaDesde = now.subtract(Duration(minutes: 25))
          ..updatedAt = now;
        await isar.mesaEntitys.put(mesa);
      });
      comandasCreadas++;
    }

    await crearComanda(
      mesa: mesas[0],
      estado: ComandaEstado.abierta,
      comensales: 2,
      lineas: [
        ('Hamburguesa Boosti', EstadoPlato.pendiente, 'Sin cebolla'),
        ('Refresco 350ml', EstadoPlato.pendiente, null),
      ],
    );

    await crearComanda(
      mesa: mesas[1],
      estado: ComandaEstado.enviada,
      comensales: 4,
      clienteNombre: clientes.isNotEmpty ? clientes.first.nombre : null,
      clienteId: clientes.isNotEmpty ? clientes.first.id : null,
      lineas: [
        ('Parrilla Mixta', EstadoPlato.enPreparacion, 'Término medio'),
        ('Ensalada César', EstadoPlato.listo, null),
        ('Jugo Natural', EstadoPlato.enCola, null),
      ],
    );

    await crearComanda(
      mesa: mesas[4],
      estado: ComandaEstado.enviada,
      comensales: 6,
      nota: 'Cumpleaños · traer postre al final',
      lineas: [
        ('Pabellón Criollo', EstadoPlato.enCola, null),
        ('Quesillo', EstadoPlato.enCola, null),
      ],
    );
  }
  stdout.writeln('7️⃣  Comandas creadas: $comandasCreadas');

  // ── 8. Ventas históricas ────────────────────────────────────
  var ventasCreadas = 0;
  if (totalVentas > 0 && aplicar) {
    final existentes = await isar.ventaEntitys.count();
    final aCrear = totalVentas;

    if (existentes >= aCrear) {
      stdout.writeln('8️⃣  Ventas: ya hay $existentes, no se generan más');
    } else {
      final nombres = productos.values.toList();
      final empleados = ['ian', 'Aria Martinez'];
      var contador = 0;
      final inicioHoyVentas = DateTime(now.year, now.month, now.day);

      // Se recorre desde HOY hacia atrás: si el tope de ventas corta la
      // generación, lo que queda afuera es lo más viejo, no el día de hoy.
      for (var d = 0; d < dias; d++) {
        final dia = inicioHoyVentas.subtract(Duration(days: d));
        final porDia = 3 + rnd.nextInt(4);

        for (var i = 0; i < porDia; i++) {
          if (ventasCreadas >= aCrear) break;

          final fecha = DateTime(
            dia.year,
            dia.month,
            dia.day,
            8 + rnd.nextInt(13),
            rnd.nextInt(60),
            rnd.nextInt(60),
          );
          if (fecha.isAfter(now)) continue;

          final nItems = 1 + rnd.nextInt(4);
          final lineas = <DetalleVentaEntity>[];
          double total = 0;

          for (var k = 0; k < nItems; k++) {
            final p = nombres[rnd.nextInt(nombres.length)];
            final cant = 1 + rnd.nextInt(3);
            final sub = p.precioUnidad * cant;
            final det = DetalleVentaEntity()
              ..productoId = p.id
              ..nombreProducto = p.nombre
              ..precioUnidad = p.precioUnidad
              ..precioOriginal = p.precioUnidad
              ..cantidad = cant.toDouble()
              ..subtotal = sub
              ..unidadEmpaque = 'unidad'
              ..unidadesPorEmpaque = 1
              ..syncStatus = 'synced';
            lineas.add(det);
            total += sub;
          }

          if (total <= 0) continue;

          final idVenta = 'seed-${now.millisecondsSinceEpoch}-$contador';
          contador++;

          final venta = VentaEntity()
            ..idSupabase = idVenta
            ..fecha = fecha
            ..subtotal = total
            ..total = total
            ..impuesto = 0
            ..tasaBcv = kTasaBcv
            ..totalBolivares = total * kTasaBcv
            ..metodoPago = _metodosPago[rnd.nextInt(_metodosPago.length)]
            ..empleado = empleados[rnd.nextInt(empleados.length)]
            ..syncStatus = 'synced'
            ..tipoVenta = 'detal'
            ..tipoPago = 'contado'
            ..numeroFactura = 'P91578-2026-${(contador).toString().padLeft(4, '0')}'
            ..documento = 0;

          if (clientes.isNotEmpty && rnd.nextDouble() < 0.35) {
            final cli = clientes[rnd.nextInt(clientes.length)];
            venta
              ..clienteId = cli.id
              ..clienteNombre = cli.nombre
              ..clienteDocumento = cli.documento?.toString();
          }

          for (final det in lineas) {
            det.ventaIdFk = idVenta;
          }

          await isar.writeTxn(() async {
            await isar.ventaEntitys.put(venta);
            await isar.detalleVentaEntitys.putAll(lineas);
          });
          ventasCreadas++;
        }
      }

      // Actualizar agregados de los clientes según lo generado.
      for (final cli in clientes) {
        final ventasCli = await isar.ventaEntitys
            .filter()
            .clienteIdEqualTo(cli.id)
            .findAll();
        if (ventasCli.isEmpty) continue;
        cli
          ..cantidadCompras = ventasCli.length
          ..totalCompras =
              ventasCli.fold<double>(0, (s, v) => s + v.total)
          ..ultimaCompra = ventasCli
              .map((v) => v.fecha)
              .whereType<DateTime>()
              .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a)
          ..frecuente = ventasCli.length >= 3;
        await isar.writeTxn(() => isar.clienteEntitys.put(cli));
      }
    }
  }
  stdout.writeln('8️⃣  Ventas creadas: $ventasCreadas');

  // ── Resumen final ───────────────────────────────────────────
  stdout.writeln('');
  stdout.writeln('=== ESTADO FINAL ===');
  stdout.writeln('  productos        ${await isar.productoEntitys.count()}');
  stdout.writeln('  clientes         ${await isar.clienteEntitys.count()}');
  stdout.writeln('  mesas            ${await isar.mesaEntitys.count()}');
  stdout.writeln('  comandas         ${await isar.cartSessionEntitys.count()}');
  stdout.writeln('  ventas           ${await isar.ventaEntitys.count()}');
  stdout.writeln('  detalles         ${await isar.detalleVentaEntitys.count()}');

  await isar.close();

  if (!aplicar) {
    stdout.writeln('');
    stdout.writeln('🧪 Nada se escribió. Repetí con --apply.');
  } else {
    stdout.writeln('');
    stdout.writeln('✅ Datos inyectados. Abrí la app y entrá a Estadísticas.');
  }
}
