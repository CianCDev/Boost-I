// test/features/pos/recetas_modelo_test.dart
//
// R.4 G.1 · Persistencia del modelo de recetas.
//
// Tests con `test()` PLANO (no `testWidgets`) + Isar real en base temporal,
// el patrón de `asignacion_estaciones_test.dart`.
//
// ⚠️ POR QUÉ `test()` Y NO `testWidgets()`
//
// `testWidgets` corre el cuerpo dentro de un `FakeAsync` que intercepta
// `Timer` y `scheduleMicrotask`. Isar resuelve sus consultas en un isolate
// real, cuya respuesta llega por el event loop REAL. Un `await` de I/O de
// Isar dentro de `FakeAsync` suspende la función y devuelve el control a un
// bucle que nunca regresa: cuelgue. Es el mismo deadlock que we documented
// en `kds_pantalla_test.dart`, y la razón de que los tests con Isar en este
// repo sean todos `test()`.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_inventario_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/receta_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;
  late IsarService isar;
  var seq = 0;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('recetas_');
    testDirPath = tempDir.path;

    SharedPreferences.setMockInitialValues({
      'empresa_id': 'test_${DateTime.now().microsecondsSinceEpoch}',
    });

    await IsarService.resetForTesting();
    await IsarService().initForTesting(testDirPath);
    isar = IsarService();
    seq = 0;
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

  /// Ingredient dentro de una receta.
  RecetaItemEntity ing({
    int ingredienteId = 1,
    String nombre = 'Arroz',
    double cantidad = 0.2,
    String unidad = 'kg',
    bool opcional = false,
  }) {
    return RecetaItemEntity()
      ..ingredienteId = ingredienteId
      ..ingredienteNombre = nombre
      ..cantidad = cantidad
      ..unidad = unidad
      ..esOpcional = opcional;
  }

  /// Receta lista para guardar.
  RecetaEntity receta({
    int localId = 1,
    int productoId = 7,
    String nombre = 'Paella',
    double rinde = 1.0,
    List<RecetaItemEntity>? items,
  }) {
    return RecetaEntity()
      ..localId = localId
      ..productoId = productoId
      ..nombrePlato = nombre
      ..rindePorciones = rinde
      ..activo = true
      ..items = items ?? [ing()];
  }

  /// Producto por `isar.db`, no por `guardarProducto()`: ese devuelve
  /// `Future<void>` y estos tests necesitan el id que asigna Isar.
  Future<int> crearProducto({
    String? nombre,
    bool? esIngrediente,
    String unidad = 'unidad',
    bool activo = true,
  }) async {
    final n = nombre ?? 'Prod ${seq++}';
    final db = await isar.db;
    return db.writeTxn(
      () => db.productoEntitys.put(
        ProductoEntity()
          ..codigoBarras = 'code-$seq-${n.hashCode.abs()}'
          ..nombre = n
          ..precioUnidad = 10.0
          ..stock = 50.0
          ..activo = activo
          ..esIngrediente = esIngrediente
          ..unidad = unidad,
      ),
    );
  }

  Future<RecetaEntity?> leerReceta(int id) async {
    final db = await isar.db;
    return db.recetaEntitys.get(id);
  }

  // ══════════════════════════════════════════════════════════════
  // CRUD de recetas
  // ══════════════════════════════════════════════════════════════

  test('una receta nueva se persiste y se lee', () async {
    final id = await isar.guardarReceta(receta());

    expect(id, greaterThan(0), reason: 'Isar debe asignar un id');

    final leida = await leerReceta(id);
    expect(leida, isNotNull);
    expect(leida!.nombrePlato, 'Paella');
    expect(leida.localId, 1);
    expect(leida.productoId, 7);
    expect(leida.rindePorciones, 1.0);
    expect(leida.activo, isTrue);
    expect(leida.items, hasLength(1));
  });

  test('guardarReceta sella createdAt y updatedAt', () async {
    final r = receta();
    // Sin `createdAt` previo: el servicio debe rellenarlo.
    expect(r.createdAt, isNull);

    await isar.guardarReceta(r);

    expect(r.createdAt, isNotNull);
    expect(r.updatedAt, isNotNull);
  });

  test('guardar la misma receta dos veces actualiza, no duplica',
      () async {
    final r = receta();
    final id1 = await isar.guardarReceta(r);

    r.nombrePlato = 'Paella Valenciana';
    r.updatedAt = null;
    final id2 = await isar.guardarReceta(r);

    expect(id2, id1, reason: 'el id debe ser el mismo');
    expect((await leerReceta(id1))!.nombrePlato, 'Paella Valenciana');
  });

  // ══════════════════════════════════════════════════════════════
  // obtenerRecetaPorProducto
  // ══════════════════════════════════════════════════════════════

  test('obtenerRecetaPorProducto devuelve la receta correcta', () async {
    await isar.guardarReceta(receta(localId: 1, productoId: 7));
    await isar.guardarReceta(receta(
      localId: 1,
      productoId: 8,
      nombre: 'Lomo',
    ));

    final r = await isar.obtenerRecetaPorProducto(1, 7);

    expect(r, isNotNull);
    expect(r!.productoId, 7);
    expect(r.nombrePlato, 'Paella');
  });

  test('obtenerRecetaPorProducto con otro producto → null', () async {
    await isar.guardarReceta(receta(productoId: 7));

    expect(await isar.obtenerRecetaPorProducto(1, 999), isNull);
  });

  test('obtenerRecetaPorProducto con localId distinto → null', () async {
    await isar.guardarReceta(receta(localId: 1, productoId: 7));

    // ⚠️ La receta del local 1 NO debe verse desde el local 2, aunque el
    // productoId coincida.
    expect(await isar.obtenerRecetaPorProducto(2, 7), isNull);
    expect(await isar.obtenerRecetaPorProducto(99, 7), isNull);
  });

  test('dos locales con el MISMO productoId tienen recetas distintas',
      () async {
    // ⭐ EL TEST CLAVE. Justifica haber quitado `@Index(unique: true)` de
    // `productoId`.
    //
    // `productoId` es un id local de Isar, autoincremental POR BASE. Con
    // dos sucursales, el producto 7 del local A y el producto 7 del local B
    // son productos distintos. Un índice único sobre `productoId` haría
    // que esta segunda escritura machacara o fuera rechazada.
    //
    // El `unique` de `codigoBarras` en `ProductoEntity` no estorba porque
    // aquí no se crean productos, solo recetas.
    final idA = await isar.guardarReceta(receta(
      localId: 1,
      productoId: 7,
      nombre: 'Paella',
    ));
    final idB = await isar.guardarReceta(receta(
      localId: 2,
      productoId: 7,
      nombre: 'Arroz a la cubana',
    ));

    expect(idA, isNot(idB), reason: 'deben ser dos recetas distintas');
    expect(idB, greaterThan(0),
        reason: 'la segunda escritura NO debe fallar ni ser ignorada');

    final desdeA = await isar.obtenerRecetaPorProducto(1, 7);
    final desdeB = await isar.obtenerRecetaPorProducto(2, 7);

    expect(desdeA!.nombrePlato, 'Paella');
    expect(desdeB!.nombrePlato, 'Arroz a la cubana');
    expect(desdeA.localId, 1);
    expect(desdeB.localId, 2);
  });

  // ══════════════════════════════════════════════════════════════
  // Listado y borrado
  // ══════════════════════════════════════════════════════════════

  test('obtenerRecetasDelLocal solo devuelve las de ese local', () async {
    await isar.guardarReceta(receta(localId: 1, productoId: 1));
    await isar.guardarReceta(receta(localId: 1, productoId: 2));
    await isar.guardarReceta(receta(localId: 2, productoId: 3));

    final mias = await isar.obtenerRecetasDelLocal(1);

    expect(mias, hasLength(2));
    expect(mias.every((r) => r.localId == 1), isTrue);
  });

  test('obtenerRecetasDelLocal ordena por nombre de plato', () async {
    await isar.guardarReceta(receta(productoId: 1, nombre: 'Zarzuela'));
    await isar.guardarReceta(receta(productoId: 2, nombre: 'Arroz'));
    await isar.guardarReceta(receta(productoId: 3, nombre: 'Migas'));

    final lista = await isar.obtenerRecetasDelLocal(1);

    expect(lista.map((r) => r.nombrePlato), ['Arroz', 'Migas', 'Zarzuela']);
  });

  test('obtenerRecetasDelLocal excluye las inactivas', () async {
    await isar.guardarReceta(receta(productoId: 1, nombre: 'Activa'));
    await isar.guardarReceta(
      receta(productoId: 2, nombre: 'Inactiva')..activo = false,
    );

    final lista = await isar.obtenerRecetasDelLocal(1);

    expect(lista, hasLength(1));
    expect(lista.first.nombrePlato, 'Activa');
  });

  test('eliminarReceta la quita de Isar', () async {
    final id = await isar.guardarReceta(receta());
    expect(await leerReceta(id), isNotNull);

    final ok = await isar.eliminarReceta(id);

    expect(ok, isTrue);
    expect(await leerReceta(id), isNull);
    expect(await isar.obtenerRecetaPorProducto(1, 7), isNull);
  });

  test('eliminarReceta de un id inexistente devuelve false', () async {
    // El caller tiene que poder distinguir "no había nada" de "no se pudo
    // borrar" para no mostrar un "borrado" que no ocurrió.
    expect(await isar.eliminarReceta(9999), isFalse);
  });

  // ══════════════════════════════════════════════════════════════
  // Items embebidos
  // ══════════════════════════════════════════════════════════════

  test('los items embebidos persisten sus 5 campos', () async {
    final id = await isar.guardarReceta(receta(items: [
      ing(ingredienteId: 11, nombre: 'Arroz', cantidad: 0.25,
          unidad: 'kg', opcional: false),
      ing(ingredienteId: 12, nombre: 'Azafrán', cantidad: 0.001,
          unidad: 'g', opcional: true),
      ing(ingredienteId: 13, nombre: 'Sal', cantidad: 5.0,
          unidad: 'g', opcional: false),
    ]));

    final leida = await leerReceta(id);
    expect(leida!.items, hasLength(3));

    // 1. ingredienteId
    expect(leida.items[0].ingredienteId, 11);
    expect(leida.items[1].ingredienteId, 12);
    expect(leida.items[2].ingredienteId, 13);

    // 2. ingredienteNombre
    expect(leida.items[0].ingredienteNombre, 'Arroz');
    expect(leida.items[1].ingredienteNombre, 'Azafrán');

    // 3. cantidad (con decimales: 0.001 no debe redondearse a 0)
    expect(leida.items[0].cantidad, 0.25);
    expect(leida.items[1].cantidad, 0.001);
    expect(leida.items[2].cantidad, 5.0);

    // 4. unidad
    expect(leida.items[0].unidad, 'kg');
    expect(leida.items[1].unidad, 'g');
    expect(leida.items[2].unidad, 'g');

    // 5. esOpcional
    expect(leida.items[0].esOpcional, isFalse);
    expect(leida.items[1].esOpcional, isTrue);
    expect(leida.items[2].esOpcional, isFalse);
  });

  test('rindePorciones persiste decimales', () async {
    final id = await isar.guardarReceta(receta(rinde: 10.0));
    expect((await leerReceta(id))!.rindePorciones, 10.0);

    final id2 = await isar.guardarReceta(receta(productoId: 8, rinde: 0.5));
    expect((await leerReceta(id2))!.rindePorciones, 0.5);
  });

  test('los helpers @ignore derivan bien de items', () async {
    final conObligatorios = receta(items: [
      ing(nombre: 'Arroz'),
      ing(nombre: 'Sal'),
      ing(nombre: 'Perejil', opcional: true),
    ]);

    expect(conObligatorios.ingredientesObligatorios, 2);
    expect(conObligatorios.vacia, isFalse);

    final soloOpcionales = receta(
      productoId: 2,
      items: [ing(nombre: 'Guarnicion', opcional: true)],
    );

    expect(soloOpcionales.ingredientesObligatorios, 0);
    expect(soloOpcionales.vacia, isTrue,
        reason: 'una receta solo con opcionales no toca stock');

    expect(receta(productoId: 3, items: []).vacia, isTrue);
  });

  // ══════════════════════════════════════════════════════════════
  // ProductoEntity: esIngrediente y unidad
  // ══════════════════════════════════════════════════════════════

  test('esIngrediente persiste los 3 estados', () async {
    // Es `bool?` y no `bool` a propósito: `null` (nunca revisado) tiene que
    // seguir siendo distinguible de `false` (revisado y descartado).
    final idNull = await crearProducto(nombre: 'Arroz');
    final idTrue = await crearProducto(
      nombre: 'Azafrán',
      esIngrediente: true,
    );
    final idFalse = await crearProducto(
      nombre: 'Caja de carton',
      esIngrediente: false,
    );

    final db = await isar.db;
    expect((await db.productoEntitys.get(idNull))!.esIngrediente, isNull);
    expect((await db.productoEntitys.get(idTrue))!.esIngrediente, isTrue);
    expect((await db.productoEntitys.get(idFalse))!.esIngrediente, isFalse);
  });

  test('unidad persiste y el default es "unidad"', () async {
    final idPorDefecto = await crearProducto(nombre: 'Papas');
    final idKg = await crearProducto(nombre: 'Harina', unidad: 'kg');
    final idMl = await crearProducto(nombre: 'Leche', unidad: 'ml');

    final db = await isar.db;
    expect((await db.productoEntitys.get(idPorDefecto))!.unidad, 'unidad');
    expect((await db.productoEntitys.get(idKg))!.unidad, 'kg');
    expect((await db.productoEntitys.get(idMl))!.unidad, 'ml');
  });

  // ══════════════════════════════════════════════════════════════
  // MovimientoInventarioEntity.localId
  // ══════════════════════════════════════════════════════════════

  test('MovimientoInventarioEntity.localId persiste', () async {
    final db = await isar.db;

    final idConLocal = await db.writeTxn(
      () => db.movimientoInventarioEntitys.put(
        MovimientoInventarioEntity()
          ..productoId = 1
          ..nombreProducto = 'Arroz'
          ..tipoMovimiento = 'salida'
          ..cantidad = -0.2
          ..localId = 5,
      ),
    );

    final idSinLocal = await db.writeTxn(
      () => db.movimientoInventarioEntitys.put(
        MovimientoInventarioEntity()
          ..productoId = 2
          ..nombreProducto = 'Sal'
          ..tipoMovimiento = 'salida'
          ..cantidad = -5.0,
      ),
    );

    expect((await db.movimientoInventarioEntitys.get(idConLocal))!.localId, 5);

    // Los movimientos legacy quedan en 0 = "local desconocido".
    expect((await db.movimientoInventarioEntitys.get(idSinLocal))!.localId, 0);
  });

  // ══════════════════════════════════════════════════════════════
  // obtenerIngredientes
  // ══════════════════════════════════════════════════════════════

  test('obtenerIngredientes solo devuelve esIngrediente == true',
      () async {
    await crearProducto(nombre: 'Arroz', esIngrediente: true);
    await crearProducto(nombre: 'Azafrán', esIngrediente: true);
    await crearProducto(nombre: 'Detergente', esIngrediente: false);
    await crearProducto(nombre: 'Caja', esIngrediente: null);

    final ingredientes = await isar.obtenerIngredientes(1);

    expect(ingredientes, hasLength(2));
    expect(ingredientes.map((p) => p.nombre), ['Arroz', 'Azafrán']);
    expect(ingredientes.every((p) => p.esIngrediente == true), isTrue);
  });

  test('obtenerIngredientes excluye los inactivos', () async {
    await crearProducto(nombre: 'Arroz', esIngrediente: true);
    await crearProducto(
      nombre: 'Pimienta',
      esIngrediente: true,
      activo: false,
    );

    final ingredientes = await isar.obtenerIngredientes(1);

    expect(ingredientes, hasLength(1));
    expect(ingredientes.first.nombre, 'Arroz');
  });

  test('obtenerIngredientes con ninguno devuelve lista vacía', () async {
    await crearProducto(nombre: 'Arroz', esIngrediente: false);

    expect(await isar.obtenerIngredientes(1), isEmpty);
  });
}
