import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';

// ============================================================
// HELPERS
// ============================================================

ProductoEntity crearProducto({
  String codigoBarras = '75010001',
  String nombre = 'Manzana',
  double precio = 3.50,
  double stock = 50.0,
  bool esPesado = false,
  String categoria = 'Frutas',
  double stockMinimo = 5.0,
}) {
  return ProductoEntity()
    ..codigoBarras = codigoBarras
    ..nombre = nombre
    ..precioUnidad = precio
    ..stock = stock
    ..esPesado = esPesado
    ..categoria = categoria
    ..stockMinimo = stockMinimo
    ..activo = true
    ..sincronizado = false;
}

LoteEntity crearLote({
  int productoId = 0,
  int localId = 1,
  double cantidadInicial = 50.0,
  double? cantidadRestante,
  DateTime? fechaVencimiento,
  String estado = 'activo',
}) {
  return LoteEntity()
    ..productoId = productoId
    ..localId = localId
    ..cantidadInicial = cantidadInicial
    ..cantidadRestante = cantidadRestante ?? cantidadInicial
    ..fechaIngreso = DateTime.now()
    ..fechaVencimiento = fechaVencimiento
    ..estado = estado
    ..sincronizado = false;
}

LocalEntity crearLocal({int id = 1, String nombre = 'Local Test'}) {
  return LocalEntity()
    ..id = id
    ..nombre = nombre
    ..activo = true
    ..sincronizado = true
    ..supabaseId = 'local-uuid-test';
}

VentaEntity crearVenta({
  String uuid = 'venta-uuid-1',
  DateTime? fecha,
  double total = 100.0,
  String empleado = 'Admin',
}) {
  return VentaEntity()
    ..idSupabase = uuid
    ..fecha = fecha ?? DateTime.now()
    ..subtotal = total
    ..total = total
    ..impuesto = 0.0
    ..tasaBcv = 36.50
    ..totalBolivares = total * 36.50
    ..metodoPago = 'Efectivo'
    ..empleado = empleado
    ..syncStatus = 'pending';
}

DetalleVentaEntity crearDetalle({
  int productoId = 1,
  String nombreProducto = 'Producto',
  double precioUnidad = 10.0,
  double cantidad = 1.0,
  String ventaIdFk = 'venta-uuid-1',
}) {
  return DetalleVentaEntity()
    ..productoId = productoId
    ..nombreProducto = nombreProducto
    ..precioUnidad = precioUnidad
    ..cantidad = cantidad
    ..subtotal = precioUnidad * cantidad
    ..precioOriginal = precioUnidad
    ..esDescuentoEspecial = false
    ..ventaIdFk = ventaFk(ventaIdFk)
    ..syncStatus = 'pending';
}

String ventaFk(String s) => s;

// ============================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late String testDirPath;

  setUp(() async {
    // ✅ Directorio temporal único por test
    final tempDir = Directory.systemTemp.createTempSync('isar_test_');
    testDirPath = tempDir.path;

    SharedPreferences.setMockInitialValues({
      'empresa_id': 'test_${DateTime.now().microsecondsSinceEpoch}',
    });

    await IsarService.resetForTesting();
    await IsarService().initForTesting(testDirPath);
  });

  tearDown(() async {
    await IsarService.resetForTesting();

    final dir = Directory(testDirPath);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {
        // Ignorar errores de limpieza
      }
    }
  });

  // ══════════════════════════════════════════════════════════════
  // GRUPO 1: Round-trip de producto
  // ══════════════════════════════════════════════════════════════
  group('IsarService — Round-trip producto', () {
    test('guardar y obtener producto por código de barras', () async {
      final isar = IsarService();
      final producto = crearProducto(
        codigoBarras: '75010001',
        nombre: 'Manzana',
        precio: 3.50,
        stock: 50.0,
      );

      await isar.guardarProducto(producto);

      final obtenido =
          await isar.obtenerProductoPorCodigoBarrasExacto('75010001');

      expect(obtenido, isNotNull);
      expect(obtenido!.codigoBarras, '75010001');
      expect(obtenido.nombre, 'Manzana');
      expect(obtenido.precioUnidad, 3.50);
      expect(obtenido.stock, 50.0);
      expect(obtenido.activo, true);
    });

    test('guardar y obtener producto por ID', () async {
      final isar = IsarService();
      final producto = crearProducto(codigoBarras: 'XYZ-001', nombre: 'Test');

      await isar.guardarProducto(producto);

      final todos = await isar.obtenerProductos();
      expect(todos.length, 1);
      final id = todos.first.id;

      final obtenido = await isar.obtenerProductoPorId(id);
      expect(obtenido, isNotNull);
      expect(obtenido!.codigoBarras, 'XYZ-001');
    });

    test('actualizar producto existente preserva ID', () async {
      final isar = IsarService();
      final producto = crearProducto(
        codigoBarras: '75010001',
        nombre: 'Original',
        precio: 3.50,
      );
      await isar.guardarProducto(producto);

      final obtenido =
          await isar.obtenerProductoPorCodigoBarrasExacto('75010001');
      final idOriginal = obtenido!.id;

      obtenido
        ..nombre = 'Actualizado'
        ..precioUnidad = 5.00;
      await isar.guardarProducto(obtenido);

      final actualizado = await isar.obtenerProductoPorId(idOriginal);
      expect(actualizado!.nombre, 'Actualizado');
      expect(actualizado.precioUnidad, 5.00);
      expect(actualizado.id, idOriginal);
    });

    test('obtenerProductos devuelve lista vacía al inicio', () async {
      final isar = IsarService();
      final todos = await isar.obtenerProductos();
      expect(todos, isEmpty);
    });

    test('contarProductos refleja la cantidad real', () async {
      final isar = IsarService();
      expect(await isar.contarProductos(), 0);

      await isar.guardarProducto(crearProducto(codigoBarras: 'A'));
      await isar.guardarProducto(crearProducto(codigoBarras: 'B'));
      await isar.guardarProducto(crearProducto(codigoBarras: 'C'));

      expect(await isar.contarProductos(), 3);
    });

   test('eliminarProducto por ID deja de aparecer', () async {
    final isar = IsarService();
    await isar.guardarProducto(crearProducto(codigoBarras: 'A'));
    await isar.guardarProducto(crearProducto(codigoBarras: 'B'));

    // Buscar el producto A para obtener su ID
    final productoA = await isar.obtenerProductoPorCodigoBarrasExacto('A');
    expect(productoA, isNotNull);

    // Eliminar por ID
    await isar.eliminarProducto(productoA!.id);

    final restantes = await isar.obtenerProductos();
    expect(restantes.length, 1);
    expect(restantes.first.codigoBarras, 'B');
  });

    test('buscarProductoPorCodigoONombre encuentra por nombre', () async {
      final isar = IsarService();
      await isar.guardarProducto(
        crearProducto(codigoBarras: 'A', nombre: 'Manzana Roja'),
      );
      await isar.guardarProducto(
        crearProducto(codigoBarras: 'B', nombre: 'Arroz Premium'),
      );

      final resultados = await isar.buscarProductoPorCodigoONombre('manz');
      expect(resultados.length, 1);
      expect(resultados.first.nombre, 'Manzana Roja');
    });
  });

  // ══════════════════════════════════════════════════════════════
  // GRUPO 2: Round-trip de venta con detalles
  // ══════════════════════════════════════════════════════════════
  group('IsarService — guardarVenta con detalles', () {
    test('guardarVenta con detalles los persiste', () async {
      final isar = IsarService();
      final venta = crearVenta(uuid: 'venta-1', total: 25.0);
      final detalles = [
        crearDetalle(productoId: 1, ventaIdFk: 'venta-1', precioUnidad: 10.0, cantidad: 2),
        crearDetalle(productoId: 2, ventaIdFk: 'venta-1', precioUnidad: 5.0, cantidad: 1),
      ];

      await isar.guardarVenta(venta, detalles: detalles);

      final obtenidos = await isar.obtenerDetallesPorVenta('venta-1');
      expect(obtenidos.length, 2);
      expect(obtenidos.fold<double>(0, (s, d) => s + d.subtotal), 25.0);
    });

    test('guardarVenta sin detalles no falla', () async {
      final isar = IsarService();
      final venta = crearVenta(uuid: 'venta-sin-detalles');

      await isar.guardarVenta(venta);

      final ventas = await isar.obtenerVentas();
      expect(ventas.length, 1);
      expect(ventas.first.idSupabase, 'venta-sin-detalles');
    });

    test('obtenerVentaPorIdString recupera por UUID', () async {
      final isar = IsarService();
      final venta = crearVenta(uuid: 'venta-uuid-abc', total: 42.0);
      await isar.guardarVenta(venta);

      final obtenida = await isar.obtenerVentaPorIdString('venta-uuid-abc');
      expect(obtenida, isNotNull);
      expect(obtenida!.total, 42.0);
    });

    test('obtenerVentasPendientesSync filtra por status', () async {
      final isar = IsarService();
      final ventaPending = crearVenta(uuid: 'v-1')
        ..syncStatus = 'pending';
      final ventaSynced = crearVenta(uuid: 'v-2')
        ..syncStatus = 'synced';

      await isar.guardarVenta(ventaPending);
      await isar.guardarVenta(ventaSynced);

      final pendientes = await isar.obtenerVentasPendientesSync();
      expect(pendientes.length, 1);
      expect(pendientes.first.idSupabase, 'v-1');
    });

    test('guardarDetallesVenta reemplaza detalles existentes', () async {
      final isar = IsarService();
      final venta = crearVenta(uuid: 'v-1');
      await isar.guardarVenta(venta, detalles: [
        crearDetalle(productoId: 1, ventaIdFk: 'v-1'),
      ]);

      // Reemplazar con 2 nuevos
      await isar.guardarDetallesVenta('v-1', [
        crearDetalle(productoId: 2, ventaIdFk: 'v-1'),
        crearDetalle(productoId: 3, ventaIdFk: 'v-1'),
      ]);

      final detalles = await isar.obtenerDetallesPorVenta('v-1');
      expect(detalles.length, 2);
    });

    test('obtenerUltimasVentas ordena por fecha descendente', () async {
      final isar = IsarService();
      final ahora = DateTime.now();

      await isar.guardarVenta(crearVenta(uuid: 'v-old', fecha: ahora.subtract(const Duration(days: 2))));
      await isar.guardarVenta(crearVenta(uuid: 'v-new', fecha: ahora));
      await isar.guardarVenta(crearVenta(uuid: 'v-mid', fecha: ahora.subtract(const Duration(days: 1))));

      final ultimas = await isar.obtenerUltimasVentas(2);
      expect(ultimas.length, 2);
      expect(ultimas[0].idSupabase, 'v-new');
      expect(ultimas[1].idSupabase, 'v-mid');
    });
  });

  // ══════════════════════════════════════════════════════════════
  // GRUPO 3: Lotes y descuento real de stock
  // ══════════════════════════════════════════════════════════════
  group('IsarService — Lotes y descuento de stock', () {
    test('crear lote y obtenerlo por ID', () async {
      final isar = IsarService();
      final lote = crearLote(productoId: 1, cantidadInicial: 100.0);
      await isar.guardarLote(lote);

      final lotes = await isar.obtenerTodosLosLotes();
      expect(lotes.length, 1);
      expect(lotes.first.cantidadRestante, 100.0);
      expect(lotes.first.estado, 'activo');
    });

    test('descontarLote reduce cantidadRestante', () async {
      final isar = IsarService();
      await isar.guardarLote(crearLote(productoId: 1, cantidadInicial: 50.0));

      final lotes = await isar.obtenerTodosLosLotes();
      final loteId = lotes.first.id;

      final exito = await isar.descontarLote(loteId, 10.0);
      expect(exito, true);

      final actualizado = await isar.obtenerLotePorId(loteId);
      expect(actualizado!.cantidadRestante, 40.0);
      expect(actualizado.estado, 'activo');
    });

    test('descontarLote marca agotado cuando llega a 0', () async {
      final isar = IsarService();
      await isar.guardarLote(crearLote(productoId: 1, cantidadInicial: 10.0));

      final loteId = (await isar.obtenerTodosLosLotes()).first.id;

      await isar.descontarLote(loteId, 10.0);

      final lote = await isar.obtenerLotePorId(loteId);
      expect(lote!.cantidadRestante, 0.0);
      expect(lote.estado, 'agotado');
    });

    test('descontarLote falla si pide más de lo disponible', () async {
      final isar = IsarService();
      await isar.guardarLote(crearLote(productoId: 1, cantidadInicial: 5.0));
      final loteId = (await isar.obtenerTodosLosLotes()).first.id;

      final exito = await isar.descontarLote(loteId, 10.0);
      expect(exito, false);

      final lote = await isar.obtenerLotePorId(loteId);
      expect(lote!.cantidadRestante, 5.0); // No cambió
    });

    test('obtenerStockTotalPorProducto suma lotes activos', () async {
      final isar = IsarService();
      await isar.guardarLote(crearLote(productoId: 1, cantidadInicial: 30.0));
      await isar.guardarLote(crearLote(productoId: 1, cantidadInicial: 20.0));
      await isar.guardarLote(crearLote(productoId: 1, cantidadInicial: 10.0, estado: 'agotado'));

      final total = await isar.obtenerStockTotalPorProducto(1);
      expect(total, 50.0); // Solo los activos
    });

    test('obtenerLoteParaVenta prioriza por fecha de vencimiento', () async {
      final isar = IsarService();
      final hoy = DateTime.now();

      // Lote que vence en 1 día
      await isar.guardarLote(crearLote(
        productoId: 1,
        cantidadInicial: 10.0,
        fechaVencimiento: hoy.add(const Duration(days: 1)),
      ));

      // Lote que vence en 30 días
      await isar.guardarLote(crearLote(
        productoId: 1,
        cantidadInicial: 20.0,
        fechaVencimiento: hoy.add(const Duration(days: 30)),
      ));

      final lote = await isar.obtenerLoteParaVenta(1, priorizarVencimiento: true);
      expect(lote, isNotNull);
      expect(lote!.fechaVencimiento!.day, hoy.add(const Duration(days: 1)).day);
    });

    test('flujo completo: venta descuenta lote y actualiza stock', () async {
      final isar = IsarService();

      // 1. Crear producto con stock
      final producto = crearProducto(
        codigoBarras: '75010001',
        nombre: 'Manzana',
        stock: 50.0,
      );
      await isar.guardarProducto(producto);
      final productoId = (await isar.obtenerProductos()).first.id;

      // 2. Crear lote
      await isar.guardarLote(crearLote(
        productoId: productoId,
        cantidadInicial: 50.0,
      ));

      // 3. Simular venta: obtener lote y descontar 15
      final lote = await isar.obtenerLoteParaVenta(productoId);
      expect(lote, isNotNull);
      final descontar = await isar.descontarLote(lote!.id, 15.0);
      expect(descontar, true);

      // 4. Actualizar stock del producto
      final stockTotal = await isar.obtenerStockTotalPorProducto(productoId);
      final productoActualizado = await isar.obtenerProductoPorId(productoId);
      productoActualizado!.stock = stockTotal;
      await isar.guardarProducto(productoActualizado);

      // 5. Guardar venta
      final venta = crearVenta(uuid: 'v-flujo', total: 52.5);
      await isar.guardarVenta(venta, detalles: [
        crearDetalle(
          productoId: productoId,
          ventaIdFk: 'v-flujo',
          precioUnidad: 3.50,
          cantidad: 15.0,
        ),
      ]);

      // 6. Verificaciones
      final productoFinal = await isar.obtenerProductoPorId(productoId);
      expect(productoFinal!.stock, 35.0);

      final loteFinal = await isar.obtenerLotePorId(lote.id);
      expect(loteFinal!.cantidadRestante, 35.0);

      final detalles = await isar.obtenerDetallesPorVenta('v-flujo');
      expect(detalles.length, 1);
      expect(detalles.first.subtotal, 52.5);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // GRUPO 4: migrarStockExistenteALotes
  // ══════════════════════════════════════════════════════════════
  group('IsarService — migrarStockExistenteALotes', () {
    test('crea lote desde producto con stock', () async {
      final isar = IsarService();

      // Crear local (necesario para la migración)
      await isar.guardarLocal(crearLocal(id: 1));

      // Crear producto con stock
      await isar.guardarProducto(
        crearProducto(codigoBarras: 'A', stock: 30.0),
      );

      final resultado = await isar.migrarStockExistenteALotes();

      expect(resultado['success'], true);
      expect(resultado['lotesCreados'], 1);
      expect(resultado['totalProductos'], 1);

      final lotes = await isar.obtenerTodosLosLotes();
      expect(lotes.length, 1);
      expect(lotes.first.cantidadInicial, 30.0);
      expect(lotes.first.cantidadRestante, 30.0);
      expect(lotes.first.localId, 1);
    });

    test('no duplica lote si ya existe', () async {
      final isar = IsarService();
      await isar.guardarLocal(crearLocal(id: 1));
      await isar.guardarProducto(crearProducto(codigoBarras: 'A', stock: 30.0));

      // Primera migración
      await isar.migrarStockExistenteALotes();
      // Segunda migración
      final resultado = await isar.migrarStockExistenteALotes();

      expect(resultado['lotesCreados'], 0);
      expect(resultado['productosConLotesPrevios'], 1);

      final lotes = await isar.obtenerTodosLosLotes();
      expect(lotes.length, 1);
    });

    test('no crea lote para producto sin stock', () async {
      final isar = IsarService();
      await isar.guardarLocal(crearLocal(id: 1));
      await isar.guardarProducto(crearProducto(codigoBarras: 'A', stock: 0.0));

      final resultado = await isar.migrarStockExistenteALotes();

      expect(resultado['lotesCreados'], 0);
      expect(resultado['productosSinStock'], 1);
    });

    test('omite migración si no hay local activo', () async {
      final isar = IsarService();
      // No creamos local
      await isar.guardarProducto(crearProducto(codigoBarras: 'A', stock: 30.0));

      final resultado = await isar.migrarStockExistenteALotes();

      expect(resultado['success'], true);
      expect(resultado['lotesCreados'], 0);
      expect(resultado['omision'], 'sin_local_activo');

      final lotes = await isar.obtenerTodosLosLotes();
      expect(lotes, isEmpty);
    });

    test('migración reporta totales correctamente', () async {
      final isar = IsarService();
      await isar.guardarLocal(crearLocal(id: 1));

      await isar.guardarProducto(crearProducto(codigoBarras: 'A', stock: 10.0));
      await isar.guardarProducto(crearProducto(codigoBarras: 'B', stock: 20.0));
      await isar.guardarProducto(crearProducto(codigoBarras: 'C', stock: 0.0));

      final resultado = await isar.migrarStockExistenteALotes();

      expect(resultado['totalProductos'], 3);
      expect(resultado['lotesCreados'], 2);
      expect(resultado['productosSinStock'], 1);
    });

    test('lote migrado preserva el stock del producto', () async {
      final isar = IsarService();
      await isar.guardarLocal(crearLocal(id: 1));
      await isar.guardarProducto(crearProducto(codigoBarras: 'A', stock: 45.5));

      await isar.migrarStockExistenteALotes();

      final lotes = await isar.obtenerTodosLosLotes();
      expect(lotes.first.cantidadInicial, 45.5);
      expect(lotes.first.cantidadRestante, 45.5);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // GRUPO 5: Filtros por fecha
  // ══════════════════════════════════════════════════════════════
  group('IsarService — Filtros por fecha', () {
    test('obtenerVentasPorRango filtra correctamente', () async {
      final isar = IsarService();
      final ahora = DateTime.now();

      await isar.guardarVenta(crearVenta(
        uuid: 'v-hace-10-dias',
        fecha: ahora.subtract(const Duration(days: 10)),
      ));
      await isar.guardarVenta(crearVenta(
        uuid: 'v-hace-3-dias',
        fecha: ahora.subtract(const Duration(days: 3)),
      ));
      await isar.guardarVenta(crearVenta(uuid: 'v-hoy', fecha: ahora));

      final inicio = ahora.subtract(const Duration(days: 5));
      final fin = ahora.add(const Duration(days: 1));

      final enRango = await isar.obtenerVentasPorRango(inicio, fin);

      expect(enRango.length, 2);
      final ids = enRango.map((v) => v.idSupabase).toSet();
      expect(ids, {'v-hace-3-dias', 'v-hoy'});
    });

    test('obtenerVentasPorRango devuelve vacío si nada cae en rango', () async {
      final isar = IsarService();
      final ahora = DateTime.now();

      await isar.guardarVenta(crearVenta(
        uuid: 'v-vieja',
        fecha: ahora.subtract(const Duration(days: 30)),
      ));

      final inicio = ahora.subtract(const Duration(days: 5));
      final fin = ahora;

      final resultado = await isar.obtenerVentasPorRango(inicio, fin);
      expect(resultado, isEmpty);
    });

    test('obtenerVentasPorRango incluye extremos (includeLower/Upper)', () async {
      final isar = IsarService();
      final fechaExacta = DateTime(2026, 9, 12, 10, 30);
      await isar.guardarVenta(crearVenta(uuid: 'v-exacta', fecha: fechaExacta));

      final inicio = DateTime(2026, 9, 12, 10, 30);
      final fin = DateTime(2026, 9, 12, 10, 30);

      final resultado = await isar.obtenerVentasPorRango(inicio, fin);
      expect(resultado.length, 1);
    });

    test('obtenerVentasPorRango devuelve ordenadas desc por fecha', () async {
      final isar = IsarService();
      final ahora = DateTime.now();

      await isar.guardarVenta(crearVenta(uuid: 'v-1', fecha: ahora.subtract(const Duration(hours: 3))));
      await isar.guardarVenta(crearVenta(uuid: 'v-2', fecha: ahora.subtract(const Duration(hours: 1))));
      await isar.guardarVenta(crearVenta(uuid: 'v-3', fecha: ahora.subtract(const Duration(hours: 2))));

      final inicio = ahora.subtract(const Duration(days: 1));
      final fin = ahora;

      final resultado = await isar.obtenerVentasPorRango(inicio, fin);

      expect(resultado[0].idSupabase, 'v-2');
      expect(resultado[1].idSupabase, 'v-3');
      expect(resultado[2].idSupabase, 'v-1');
    });

    test('obtenerTotalVentasPorRango suma los totales', () async {
      final isar = IsarService();
      final ahora = DateTime.now();

      await isar.guardarVenta(crearVenta(uuid: 'v-1', fecha: ahora, total: 100.0));
      await isar.guardarVenta(crearVenta(uuid: 'v-2', fecha: ahora, total: 50.0));
      await isar.guardarVenta(crearVenta(uuid: 'v-3', fecha: ahora, total: 25.5));

      final inicio = ahora.subtract(const Duration(minutes: 1));
      final fin = ahora.add(const Duration(minutes: 1));

      final total = await isar.obtenerTotalVentasPorRango(inicio, fin);
      expect(total, 175.5);
    });

    test('obtenerVentasPorRango con rango amplio trae todas', () async {
      final isar = IsarService();
      final ahora = DateTime.now();

      for (var i = 0; i < 5; i++) {
        await isar.guardarVenta(crearVenta(
          uuid: 'v-$i',
          fecha: ahora.subtract(Duration(days: i)),
        ));
      }

      final inicio = ahora.subtract(const Duration(days: 30));
      final fin = ahora.add(const Duration(days: 1));

      final resultado = await isar.obtenerVentasPorRango(inicio, fin);
      expect(resultado.length, 5);
    });
  });
}