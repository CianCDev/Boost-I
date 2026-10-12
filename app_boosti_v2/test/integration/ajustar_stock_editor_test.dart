// test/integration/ajustar_stock_editor_test.dart
//
// Regresión del bug `EDIT-`.
//
// `ajustarStockDesdeEditor` sumaba el delta SOLO sobre `cantidadRestante`,
// nunca sobre `cantidadInicial`. Con el campo "Stock inicial" del editor de
// productos, cada ajuste hacia arriba dejaba el lote con `restante > inicial`.
//
// Medido en la nube (2026-10-08), los tres casos tenían `inicial = 100`:
//   · Arroz    → restante 512   (se tipeó 512)
//   · 133cf99a → restante 200   (se tipeó 200)
//   · 20680fa5 → restante 150   (se tipeó 150)
//
// El fix es la Opción A: `cantidadInicial` sube junto con `cantidadRestante`.
// `cantidad_inicial` deja de ser "el acta de recepción" y pasa a ser "lo
// recibido más las reposiciones", que es la semántica correcta bajo el modelo
// "lotes = fuente única de verdad".
//
// El stock que ve el usuario nunca estuvo mal: `recalcularStockDe` recalcula
// `productos.stock` como `SUM(restante)`. Lo corrupto era el histórico.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';

// ══════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════

ProductoEntity crearProducto({
  String nombre = 'Producto Test',
  double precio = 10.0,
}) {
  // `codigoBarras` es `Object` en la entidad (admite barcode numérico o
  // string), así que el valor tiene que ser un `String` explícito.
  final codigo = 'TEST-${DateTime.now().microsecondsSinceEpoch}';
  return ProductoEntity()
    ..codigoBarras = codigo
    ..nombre = nombre
    ..precioUnidad = precio
    ..stock = 0.0
    ..stockMinimo = 5.0
    ..esPesado = false
    ..categoria = 'General'
    ..activo = true
    ..sincronizado = false;
}

LoteEntity crearLote({
  required int productoId,
  required double cantidadInicial,
  required double cantidadRestante,
  DateTime? fechaVencimiento,
  String estado = 'activo',
}) {
  return LoteEntity()
    ..productoId = productoId
    ..localId = 1
    ..cantidadInicial = cantidadInicial
    ..cantidadRestante = cantidadRestante
    ..fechaIngreso = DateTime.now()
    ..fechaVencimiento = fechaVencimiento
    ..estado = estado
    ..sincronizado = false;
}

/// Crea un producto con UN lote y devuelve el id de ese lote.
Future<int> prepararProductoConLote({
  required double cantidadInicial,
  required double cantidadRestante,
  DateTime? fechaVencimiento,
}) async {
  final isar = IsarService();

  final producto = crearProducto();
  await isar.guardarProducto(producto);

  await isar.guardarLote(crearLote(
    productoId: producto.id,
    cantidadInicial: cantidadInicial,
    cantidadRestante: cantidadRestante,
    fechaVencimiento: fechaVencimiento,
  ));

  final lote = (await isar.obtenerTodosLosLotes()).first;
  return lote.id;
}

// ══════════════════════════════════════════════════════════════

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('isar_editor_');
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

  // ════════════════════════════════════════════════════════════
  // GRUPO: Clamp de Opción A (el bug `EDIT-`)
  // ════════════════════════════════════════════════════════════

  group('ajustarStockDesdeEditor · clamp de cantidad_inicial', () {
    test('suma delta a inicial y restante', () async {
      final isar = IsarService();

      // setup: lote inicial=100, restante=50 → stock total = 50
      final loteId = await prepararProductoConLote(
        cantidadInicial: 100.0,
        cantidadRestante: 50.0,
      );
      final productoId = (await isar.obtenerTodosLosLotes()).first.productoId;

      // act: objetivo 200 → delta = 200 - 50 = 150
      final ok = await isar.ajustarStockDesdeEditor(
        productoId: productoId,
        stockObjetivo: 200.0,
        usuarioId: 1,
      );

      expect(ok, true);

      final lote = await isar.obtenerLotePorId(loteId);
      // 50 + 150 = 200
      expect(lote!.cantidadRestante, 200.0);
      // 100 + 150 = 250 → el invariante restante <= inicial se mantiene
      expect(lote.cantidadInicial, 250.0);
    });

    test('deja un movimiento de reposicion', () async {
      final isar = IsarService();

      final loteId = await prepararProductoConLote(
        cantidadInicial: 100.0,
        cantidadRestante: 50.0,
      );
      final productoId = (await isar.obtenerTodosLosLotes()).first.productoId;

      await isar.ajustarStockDesdeEditor(
        productoId: productoId,
        stockObjetivo: 200.0,
        usuarioId: 1,
      );

      final movimientos = await isar.obtenerMovimientosPorLote(loteId);
      final reposiciones =
          movimientos.where((m) => m.tipo == 'reposicion').toList();

      expect(reposiciones.length, 1);
      // delta = 200 - 50 = 150
      expect(reposiciones.first.cantidad, 150.0);
      expect(reposiciones.first.usuarioId, 1);
    });

    test('con delta negativo descuenta FEFO sin tocar inicial', () async {
      final isar = IsarService();

      // setup: un solo lote, inicial=100, restante=100 → stock total = 100
      final loteId = await prepararProductoConLote(
        cantidadInicial: 100.0,
        cantidadRestante: 100.0,
      );
      final productoId = (await isar.obtenerTodosLosLotes()).first.productoId;

      // act: objetivo 30 → delta = 30 - 100 = -70
      final ok = await isar.ajustarStockDesdeEditor(
        productoId: productoId,
        stockObjetivo: 30.0,
        usuarioId: 1,
      );

      expect(ok, true);

      final lote = await isar.obtenerLotePorId(loteId);
      expect(lote!.cantidadRestante, 30.0);
      // Una salida NO sube la inicial: por eso el clamp es solo de entrada.
      expect(lote.cantidadInicial, 100.0);

      final movimientos = await isar.obtenerMovimientosPorLote(loteId);
      expect(
        movimientos.where((m) => m.tipo == 'reposicion').isEmpty,
        true,
        reason: 'Un descuento no es una reposición',
      );
    });

    test('con delta negativo descuenta FEFO por vencimiento', () async {
      final isar = IsarService();

      // setup: producto con 2 lotes activos y vencimientos distintos.
      //   lote A: inicial=100, restante=100, vence 2026-11-01 (antes)
      //   lote B: inicial=50,  restante=50,  vence 2026-12-01 (después)
      final producto = crearProducto();
      await isar.guardarProducto(producto);

      await isar.guardarLote(crearLote(
        productoId: producto.id,
        cantidadInicial: 100.0,
        cantidadRestante: 100.0,
        fechaVencimiento: DateTime(2026, 11, 1),
      ));
      await isar.guardarLote(crearLote(
        productoId: producto.id,
        cantidadInicial: 50.0,
        cantidadRestante: 50.0,
        fechaVencimiento: DateTime(2026, 12, 1),
      ));

      final lotes = await isar.obtenerTodosLosLotes();
      final loteA = lotes.firstWhere((l) => l.cantidadInicial == 100.0);
      final loteB = lotes.firstWhere((l) => l.cantidadInicial == 50.0);

      // stock total = 100 + 50 = 150
      // act: objetivo 120 → delta = 120 - 150 = -30
      final ok = await isar.ajustarStockDesdeEditor(
        productoId: producto.id,
        stockObjetivo: 120.0,
        usuarioId: 1,
      );

      expect(ok, true);

      final a = await isar.obtenerLotePorId(loteA.id);
      final b = await isar.obtenerLotePorId(loteB.id);

      // FEFO: se descuenta primero el que vence antes (A).
      expect(a!.cantidadRestante, 70.0);
      expect(a.cantidadInicial, 100.0);
      // B queda intacto.
      expect(b!.cantidadRestante, 50.0);
      expect(b.cantidadInicial, 50.0);
    });
  });
}