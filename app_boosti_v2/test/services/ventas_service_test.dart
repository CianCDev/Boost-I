// test/services/venta_service_test.dart
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/venta_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ✅ Necesario para que QueryBuilder resuelva findAll/count/sortBy...
import 'package:isar/isar.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await setupIsarForTest();
  });

  tearDownAll(() async {
    await tearDownIsarForTest(tempDir);
  });

  setUp(() async {
    final db = await IsarService().db;
    await db.writeTxn(() async => db.clear());
  });

  // ────────────────────────────────────────────────────────────
  // SEED
  // ────────────────────────────────────────────────────────────

  Future<ProductItem> seedProducto({
    required int id,
    String nombre = 'Producto Test',
    double precio = 10.0,
    double stock = 50,
  }) async {
    final db = await IsarService().db;

    final producto = ProductoEntity()
      ..id = id
      ..nombre = nombre
      ..codigoBarras = 'cod-$id'
      ..precioUnidad = precio
      ..stock = stock
      ..stockMinimo = 0.0
      ..activo = true
      ..sincronizado = false;

    final lote = LoteEntity()
      ..productoId = id
      ..cantidadInicial = stock
      ..cantidadRestante = stock
      ..fechaIngreso = DateTime(2026, 1, 1)
      ..fechaVencimiento = DateTime(2027, 1, 1)
      ..estado = 'activo'
      ..sincronizado = false;

    await db.writeTxn(() async {
      await db.productoEntitys.put(producto);
      await db.loteEntitys.put(lote);
    });

    return ProductItem(
      id: id.toString(),
      nombre: nombre,
      precioUnidad: precio,
      codigoBarras: 'cod-$id',
      categoria: 'General',
      esPesado: false,
    );
  }

  UsuarioEntity buildUsuario() => UsuarioEntity()
    ..id = 42
    ..nombre = 'Cajero Test'
    ..rol = 'cajero'
    ..activo = true;

  /// Monta un MaterialApp con ProviderScope y expone el BuildContext.
  ///
  /// NO overrideamos printerProvider: el VentaService envuelve la
  /// impresión en try/catch y traga cualquier error.
  Future<(ProviderContainer, BuildContext)> mountApp(
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    late BuildContext capturedContext;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return (container, capturedContext);
  }

  // ════════════════════════════════════════════════════════════
  // PERSISTENCIA
  // ════════════════════════════════════════════════════════════

  testWidgets('guarda 1 venta + N detalles en Isar', (tester) async {
    final p1 =
        await seedProducto(id: 1, nombre: 'Arroz', precio: 5.0, stock: 100);
    final p2 =
        await seedProducto(id: 2, nombre: 'Frijol', precio: 8.0, stock: 100);

    final (container, context) = await mountApp(tester);

    container.read(cartProvider.notifier).agregarItem(p1, 2.0);
    container.read(cartProvider.notifier).agregarItem(p2, 1.0);
    await tester.pump();

    final service = container.read(ventaServiceProvider);
    await service.procesarVenta(
      context,
      metodoPago: 'Efectivo',
      cambio: 0,
      recibido: 18.0,
      tasaActual: 36.5,
      usuarioLogueado: buildUsuario(),
    );
    await tester.pump();

    final db = await IsarService().db;
    final ventas = await db.ventaEntitys.where().findAll();
    expect(ventas.length, 1);
    expect(ventas.first.total, closeTo(18.0, 0.01));
    expect(ventas.first.metodoPago, 'Efectivo');
    expect(ventas.first.tasaBcv, 36.5);
    expect(ventas.first.totalBolivares, closeTo(18.0 * 36.5, 0.01));
    expect(ventas.first.syncStatus, 'pending');

    final detalles = await db.detalleVentaEntitys.where().findAll();
    expect(detalles.length, 2);
  });

  testWidgets('carrito vacío: no guarda ninguna venta', (tester) async {
    final (container, context) = await mountApp(tester);

    final service = container.read(ventaServiceProvider);
    await service.procesarVenta(
      context,
      metodoPago: 'Efectivo',
      cambio: 0,
      recibido: 0,
      tasaActual: 36.5,
    );
    await tester.pump();

    final db = await IsarService().db;
    expect(await db.ventaEntitys.where().count(), 0);
  });

  // ════════════════════════════════════════════════════════════
  // DESCUENTO DE STOCK Y LOTES
  // ════════════════════════════════════════════════════════════

  testWidgets('descuenta stock del producto vendido', (tester) async {
    final p = await seedProducto(id: 10, precio: 10.0, stock: 30);

    final (container, context) = await mountApp(tester);
    container.read(cartProvider.notifier).agregarItem(p, 5.0);
    await tester.pump();

    final service = container.read(ventaServiceProvider);
    await service.procesarVenta(
      context,
      metodoPago: 'Efectivo',
      cambio: 0,
      recibido: 50.0,
      tasaActual: 36.5,
    );
    await tester.pump();

    final db = await IsarService().db;
    final actualizado = await db.productoEntitys.get(10);
    expect(actualizado!.stock, closeTo(25.0, 0.001));
  });

  testWidgets('consume primero el lote con vencimiento más próximo',
      (tester) async {
    final p = await seedProducto(id: 20, precio: 10.0, stock: 10);
    final db = await IsarService().db;

    // Reemplazamos los lotes por dos con distinto vencimiento.
    await db.writeTxn(() async {
      await db.loteEntitys.clear();

      await db.loteEntitys.put(LoteEntity()
        ..productoId = 20
        ..cantidadInicial = 5
        ..cantidadRestante = 5
        ..fechaIngreso = DateTime(2025, 1, 1)
        ..fechaVencimiento = DateTime(2026, 1, 1) // viejo
        ..estado = 'activo');

      await db.loteEntitys.put(LoteEntity()
        ..productoId = 20
        ..cantidadInicial = 5
        ..cantidadRestante = 5
        ..fechaIngreso = DateTime(2025, 6, 1)
        ..fechaVencimiento = DateTime(2027, 6, 1) // nuevo
        ..estado = 'activo');
    });

    final (container, context) = await mountApp(tester);
    container.read(cartProvider.notifier).agregarItem(p, 3.0);
    await tester.pump();

    final service = container.read(ventaServiceProvider);
    await service.procesarVenta(
      context,
      metodoPago: 'Efectivo',
      cambio: 0,
      recibido: 30.0,
      tasaActual: 36.5,
    );
    await tester.pump();

    final lotes =
        await db.loteEntitys.where().sortByFechaVencimiento().findAll();
    // El más viejo consume 3 → 5-3=2
    expect(lotes.first.cantidadRestante, closeTo(2.0, 0.001));
    // El nuevo sigue intacto
    expect(lotes.last.cantidadRestante, closeTo(5.0, 0.001));
  });

  testWidgets('sin stock suficiente → lanza excepción y no guarda venta',
      (tester) async {
    final p = await seedProducto(id: 30, precio: 10.0, stock: 2);

    final (container, context) = await mountApp(tester);
    container.read(cartProvider.notifier).agregarItem(p, 5.0);
    await tester.pump();

    final service = container.read(ventaServiceProvider);
    await expectLater(
      () => service.procesarVenta(
        context,
        metodoPago: 'Efectivo',
        cambio: 0,
        recibido: 50.0,
        tasaActual: 36.5,
      ),
      throwsA(isA<Exception>()),
    );
    await tester.pump();

    final db = await IsarService().db;
    expect(await db.ventaEntitys.where().count(), 0);
  });

  // ════════════════════════════════════════════════════════════
  // CLIENTE
  // ════════════════════════════════════════════════════════════

  testWidgets('con cliente: actualiza estadísticas de fidelización',
      (tester) async {
    final p = await seedProducto(id: 40, precio: 30.0, stock: 10);
    final db = await IsarService().db;

    final cliente = ClienteEntity()
      ..id = 1
      ..nombre = 'Juan Pérez'
      ..documento = 12345678
      ..cantidadCompras = 0
      ..totalCompras = 0.0
      ..activo = true
      ..frecuente = false
      ..preferenciasMarketing = true;

    await db.writeTxn(() async => db.clienteEntitys.put(cliente));

    final (container, context) = await mountApp(tester);
    container.read(cartProvider.notifier).agregarItem(p, 2.0);
    await tester.pump();

    final service = container.read(ventaServiceProvider);
    await service.procesarVenta(
      context,
      metodoPago: 'Efectivo',
      cambio: 0,
      recibido: 60.0,
      tasaActual: 36.5,
      cliente: cliente,
    );
    await tester.pump();

    final actualizado = await db.clienteEntitys.get(1);
    expect(actualizado!.cantidadCompras, 1);
    expect(actualizado.totalCompras, closeTo(60.0, 0.01));
    expect(actualizado.frecuente, isTrue);
  });

  // ════════════════════════════════════════════════════════════
  // POST-VENTA
  // ════════════════════════════════════════════════════════════

  testWidgets('tras venta exitosa el carrito queda vacío', (tester) async {
    final p = await seedProducto(id: 50, precio: 10.0, stock: 10);

    final (container, context) = await mountApp(tester);
    container.read(cartProvider.notifier).agregarItem(p, 1.0);
    await tester.pump();

    expect(container.read(cartProvider).items, isNotEmpty);

    final service = container.read(ventaServiceProvider);
    await service.procesarVenta(
      context,
      metodoPago: 'Efectivo',
      cambio: 0,
      recibido: 10.0,
      tasaActual: 36.5,
    );
    await tester.pump();

    expect(container.read(cartProvider).items, isEmpty);
  });
}