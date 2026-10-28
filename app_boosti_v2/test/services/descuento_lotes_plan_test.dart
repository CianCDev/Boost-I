// test/services/descuento_lotes_plan_test.dart
//
// G.3 · Descuento de stock planificado y ATÓMICO.
//
// Lo que se cubre aquí es la parte nueva de `IsarService`:
//
//   · `planificarDescuentoLotes` — reparto FEFO en solo lectura, con
//     faltante expuesto y filtro por local (los lotes de OTRO local no
//     entran en el FEFO de esta caja; los legacy sin local sí).
//   · `aplicarDescuentosLotes` — descuentos + recálculo de stock +
//     movimientos en UNA transacción, con `stockResultante` real.
//   · `registrarVentaConDescuento` — venta + detalles + descuento en UNA
//     transacción: si un lote ya no tiene lo prometido, NADA se escribe.
//
// Los caminos completos de venta siguen en `ventas_service_test.dart`:
// aquí se prueba el mecanismo, allí el flujo.
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/descuento_lote_plan.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_inventario_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Crea un lote activo y devuelve el id de Isar (el `put` lo rellena en
/// la misma instancia).
///
/// Hace el `put` DIRECTO replicando `guardarLote` (isar_service.dart:4263,
/// `Future<void>`): el plan necesita el id Isar del lote recién creado y
/// `guardarLote` no lo retorna, así que se escribe aquí a mano.
Future<int> crearLote({
  required int productoId,
  required double restante,
  DateTime? vencimiento,
  int? localId,
}) async {
  final lote = LoteEntity()
    ..productoId = productoId
    ..cantidadInicial = restante
    ..cantidadRestante = restante
    ..fechaIngreso = DateTime(2026, 1, 1)
    ..fechaVencimiento = vencimiento ?? DateTime(2027, 1, 1)
    ..estado = 'activo'
    ..localId = localId
    ..sincronizado = false;
  final isar = await IsarService().db;
  await isar.writeTxn(() async {
    await isar.loteEntitys.put(lote);
  });
  return lote.id;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('plan_lotes_');
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
        // La limpieza del temp no debe romper la suite.
      }
    }
  });

  ProductoEntity producto(int id, {double stock = 0.0}) {
    final p = ProductoEntity()
      ..id = id
      ..nombre = 'Producto $id'
      ..codigoBarras = 'cod-$id'
      ..precioUnidad = 10.0
      ..stock = stock
      ..activo = true
      ..sincronizado = false;
    return p;
  }

  group('planificarDescuentoLotes · FEFO en solo lectura', () {
    test('reparte entre varios lotes por vencimiento (FEFO)', () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(1, stock: 3.0));
      });
      // El lote que vence PRIMERO se vacía primero.
      await crearLote(
          productoId: 1,
          restante: 2.0,
          vencimiento: DateTime(2026, 6, 1));
      await crearLote(
          productoId: 1,
          restante: 2.0,
          vencimiento: DateTime(2027, 6, 1));

      final planificacion = await IsarService().planificarDescuentoLotes(
        productoId: 1,
        cantidad: 3.0,
      );

      expect(planificacion.faltante, 0.0);
      expect(planificacion.plan, hasLength(2));
      // El primer paso del plan es el lote más cercano a vencer, por el
      // total del lote; el segundo paso cubre lo que falta.
      final primero = await IsarService().obtenerLoteParaVenta(1);
      expect(planificacion.plan.first.loteId, primero!.id);
      expect(planificacion.plan.first.cantidad, 2.0);
      expect(planificacion.plan.last.cantidad, 1.0);

      // NADA cambió: planificar es solo lectura.
      final stock = await IsarService().obtenerStockTotalPorProducto(1);
      expect(stock, 4.0);
    });

    test('sin stock deja el faltante y un plan vacío', () async {
      final planificacion = await IsarService().planificarDescuentoLotes(
        productoId: 99,
        cantidad: 5.0,
      );

      expect(planificacion.completo, isFalse);
      expect(planificacion.faltante, 5.0);
      expect(planificacion.plan, isEmpty);
    });

    test('con faltante parcial planifica lo que había', () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(2));
      });
      await crearLote(productoId: 2, restante: 1.5);

      final planificacion = await IsarService().planificarDescuentoLotes(
        productoId: 2,
        cantidad: 4.0,
      );

      expect(planificacion.completo, isFalse);
      expect(planificacion.faltante, 2.5);
      expect(planificacion.plan, hasLength(1));
      expect(planificacion.plan.single.cantidad, 1.5);
    });

    test('el filtro de local saca los lotes de OTRO local del FEFO',
        () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(3));
      });
      // El único lote con stock es del local 2.
      await crearLote(productoId: 3, restante: 9.0, localId: 2);

      final planificacion = await IsarService().planificarDescuentoLotes(
        productoId: 3,
        cantidad: 1.0,
        localId: 1,
      );

      // Los lotes de otro local NO alimentan esta caja.
      expect(planificacion.completo, isFalse);
      expect(planificacion.plan, isEmpty);
    });

    test('los lotes legacy sin local NO quedan fuera del filtro', () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(4));
      });
      // Sin `localId` (null): datos anteriores al multi-local.
      await crearLote(productoId: 4, restante: 9.0, localId: null);

      final planificacion = await IsarService().planificarDescuentoLotes(
        productoId: 4,
        cantidad: 1.0,
        localId: 1,
      );

      expect(planificacion.completo, isTrue);
      expect(planificacion.plan, hasLength(1));
    });
  });

  group('aplicarDescuentosLotes · una transacción', () {
    test('descuenta, recalcula stock y sella stockResultante real',
        () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(10, stock: 999.0));
      });
      final idLote = await crearLote(productoId: 10, restante: 5.0);

      await IsarService().aplicarDescuentosLotes(
        plan: [
          DescuentoLotePlan(loteId: idLote, productoId: 10, cantidad: 2.0),
        ],
        movimientos: [
          MovimientoInventarioEntity()
            ..productoId = 10
            ..nombreProducto = 'Producto 10'
            ..tipoMovimiento = 'Consumo receta'
            ..cantidad = 2.0
            ..stockResultante = 0.0
            ..syncStatus = 'pending',
        ],
      );

      final lote = await IsarService().obtenerLotePorId(idLote);
      expect(lote!.cantidadRestante, 3.0);
      // El stock derivado quedó recalculado, no en 999 ni en 997.
      final productoDb = await isar.productoEntitys.get(10);
      expect(productoDb!.stock, 3.0);
      // El movimiento trae el stock ya movido (3.0), NO el valor viejo.
      final movs = await isar.movimientoInventarioEntitys.where().findAll();
      expect(movs.single.stockResultante, 3.0);
      expect(movs.single.syncStatus, 'pending');
      // El lote quedó marcado pendiente de subir.
      expect(
        await IsarService().obtenerLotesPendientesSync(),
        isNotEmpty,
      );
    });

    test('al llegar a cero el lote pasa a agotado', () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(11));
      });
      final idLote = await crearLote(productoId: 11, restante: 1.0);

      await IsarService().aplicarDescuentosLotes(
        plan: [
          DescuentoLotePlan(loteId: idLote, productoId: 11, cantidad: 1.0),
        ],
      );

      final lote = await IsarService().obtenerLotePorId(idLote);
      expect(lote!.cantidadRestante, 0.0);
      expect(lote.estado, 'agotado');
    });

    test('aborta ENTERO si un lote ya no tiene lo prometido', () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(12, stock: 8.0));
      });
      final idLoteOk = await crearLote(productoId: 12, restante: 5.0);
      final idLoteCorto = await crearLote(productoId: 12, restante: 1.0);

      await expectLater(
        IsarService().aplicarDescuentosLotes(
          plan: [
            DescuentoLotePlan(loteId: idLoteOk, productoId: 12, cantidad: 2.0),
            DescuentoLotePlan(
                loteId: idLoteCorto, productoId: 12, cantidad: 3.0),
          ],
          movimientos: [
            MovimientoInventarioEntity()
              ..productoId = 12
              ..tipoMovimiento = 'Consumo receta'
              ..cantidad = 2.0,
          ],
        ),
        throwsA(isA<StockInsuficienteException>()),
      );

      // NADA de lo prometido se escribió: el lote sano sigue en 5.
      final loteOk = await IsarService().obtenerLotePorId(idLoteOk);
      expect(loteOk!.cantidadRestante, 5.0);
      final productoDb = await isar.productoEntitys.get(12);
      expect(productoDb!.stock, 8.0);
      expect(
        await isar.movimientoInventarioEntitys.where().findAll(),
        isEmpty,
      );
    });
  });

  group('registrarVentaConDescuento · venta atómica', () {
    VentaEntity ventaBase({
      String uuid = 'venta-atomica-1',
      double total = 30.0,
    }) {
      return VentaEntity()
        ..idSupabase = uuid
        ..fecha = DateTime(2026, 10, 28, 10)
        ..total = total
        ..subtotal = 30.0
        ..impuesto = 0
        ..metodoPago = 'efectivo'
        ..empleado = 'Cajero Test'
        ..syncStatus = 'pending';
    }

    DetalleVentaEntity detalle({
      int productoId = 20,
      double cantidad = 3.0,
      String ventaIdFk = 'venta-atomica-1',
    }) {
      return DetalleVentaEntity()
        ..productoId = productoId
        ..nombreProducto = 'Producto $productoId'
        ..precioUnidad = 10.0
        ..cantidad = cantidad
        ..subtotal = 30.0
        ..ventaIdFk = ventaIdFk
        ..syncStatus = 'pending';
    }

    test('venta + detalles + descuento + recálculo quedan juntos',
        () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(20, stock: 99.0));
      });
      final idLote = await crearLote(productoId: 20, restante: 5.0);

      await IsarService().registrarVentaConDescuento(
        venta: ventaBase(),
        detalles: [detalle()],
        plan: [
          DescuentoLotePlan(loteId: idLote, productoId: 20, cantidad: 3.0),
        ],
      );

      final lote = await IsarService().obtenerLotePorId(idLote);
      expect(lote!.cantidadRestante, 2.0);
      final productoDb = await isar.productoEntitys.get(20);
      expect(productoDb!.stock, 2.0);
      final ventas = await isar.ventaEntitys.where().findAll();
      expect(ventas, hasLength(1));
      expect(ventas.single.syncStatus, 'pending');
      final detalles = await isar.detalleVentaEntitys.where().findAll();
      expect(detalles, hasLength(1));
      expect(detalles.single.ventaIdFk, 'venta-atomica-1');
    });

    test('si un lote falla, NO queda venta NI stock movido', () async {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto(21, stock: 8.0));
      });
      final idLote = await crearLote(productoId: 21, restante: 2.0);

      // El plan promete 3 y el lote tiene 2: la lectura del plan no
      // alcanzó a ver que otra transacción movió el lote entretanto.
      await expectLater(
        IsarService().registrarVentaConDescuento(
          venta: ventaBase(uuid: 'venta-atomica-2'),
          detalles: [
            detalle(productoId: 21, ventaIdFk: 'venta-atomica-2'),
          ],
          plan: [
            DescuentoLotePlan(loteId: idLote, productoId: 21, cantidad: 3.0),
          ],
        ),
        throwsA(isA<StockInsuficienteException>()),
      );

      final lote = await IsarService().obtenerLotePorId(idLote);
      expect(lote!.cantidadRestante, 2.0);
      final productoDb = await isar.productoEntitys.get(21);
      expect(productoDb!.stock, 8.0);
      expect(await isar.ventaEntitys.where().findAll(), isEmpty);
      expect(await isar.detalleVentaEntitys.where().findAll(), isEmpty);
    });

    test('venta sin plan no toca lotes (producto no inventariable)',
        () async {
      final isar = await IsarService().db;
      final venta = ventaBase(uuid: 'venta-atomica-3', total: 5.0);

      await IsarService().registrarVentaConDescuento(
        venta: venta,
        detalles: [detalle(ventaIdFk: 'venta-atomica-3')],
        plan: const [],
      );

      expect(await isar.ventaEntitys.where().findAll(), hasLength(1));
      expect(await isar.loteEntitys.where().findAll(), isEmpty);
    });
  });
}
