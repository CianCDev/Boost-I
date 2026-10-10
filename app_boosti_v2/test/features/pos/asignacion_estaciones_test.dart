// test/features/pos/asignacion_estaciones_test.dart
//
// R.3.2 PASO D · Asignación de estación de preparación a productos.
//
// Cubre:
//
//   · El campo `ProductoEntity.departamentoId` persiste y se puede cambiar.
//   · El bulk `asignarDepartamentoAProductos` respeta los que YA tienen
//     estación (decisión Q2) y puede desasignar.
//
// ⚠️ Solo toca `isar_service` y `ProductoEntity`. El `ProductFormDialog` y
// el `DepartamentoSelector` son UI y quedan para prueba manual: montarlos
// exige todo el árbol de providers de inventario.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;
  late IsarService isar;
  var seq = 0;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('estaciones_');
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

  /// Producto con `categoriaId` fijo para poder agrupar en el bulk.
  ///
  /// ⚠️ Va por `isar.db` y no por `IsarService.guardarProducto()`: ese
  /// método devuelve `Future<void>` y estos tests necesitan el id que Isar
  /// asigna.
  Future<int> crearProducto({
    int? categoriaId,
    int? departamentoId,
    String? nombre,
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
          ..categoriaId = categoriaId
          ..categoria = categoriaId == null ? 'General' : 'Cat$categoriaId'
          ..departamentoId = departamentoId,
      ),
    );
  }

  Future<int?> deId(int id) async {
    final db = await isar.db;
    return (await db.productoEntitys.get(id))?.departamentoId;
  }

  // ══════════════════════════════════════════════════════════════
  // Form individual (el campo del entity)
  // ══════════════════════════════════════════════════════════════

  group('ProductoEntity.departamentoId', () {
    test('un producto nuevo SIN estación queda en null', () async {
      final id = await crearProducto();
      expect(await deId(id), isNull);
    });

    test('un producto con estación persiste el id', () async {
      final id = await crearProducto(departamentoId: 5);
      expect(await deId(id), 5);
    });

    test('editar cambia la estación', () async {
      final id = await crearProducto(departamentoId: 5);

      final db = await isar.db;
      final p = (await db.productoEntitys.get(id))!;
      p.departamentoId = 9;
      await db.writeTxn(() => db.productoEntitys.put(p));

      expect(await deId(id), 9);
    });

    test('asignar y luego desasignar (null) en el form', () async {
      final id = await crearProducto();

      final db = await isar.db;
      final p = (await db.productoEntitys.get(id))!;
      p.departamentoId = 3;
      await db.writeTxn(() => db.productoEntitys.put(p));
      expect(await deId(id), 3);

      p.departamentoId = null;
      await db.writeTxn(() => db.productoEntitys.put(p));
      expect(await deId(id), isNull);
    });

    test('NO aparece en toJson (local-only, decisión D2a)', () async {
      // Si apareciera, el SyncService escribiría una columna que no existe en
      // Supabase y el push de productos fallaría.
      //
      // ⚠️ El `toJson()` va FUERA del cascade a propósito: en Dart
      // `..toJson()` se ata al objetivo del cascade (`ProductoEntity`) y
      // descarta el resultado, así que `json` sería el entity y
      // `containsKey` no existiría sobre él.
      final producto = ProductoEntity()
        ..codigoBarras = 'x'
        ..departamentoId = 7;

      final Map<String, dynamic> json = producto.toJson();

      expect(json.containsKey('departamento_id'), isFalse,
          reason: 'R.1b añadirá la columna; hasta entonces no se sincroniza');
      expect(json.containsKey('departamentoId'), isFalse);
      expect(producto.departamentoId, 7,
          reason: 'el campo SÍ existe en el entity, solo no se exporta');
    });

    test('fromJson ignora una departamento_id inesperada', () async {
      // Defensive: si alguien sube el campo antes de que exista la columna,
      // el import no debe romper.
      final p = ProductoEntity.fromJson({
        'codigo_barras': 'z',
        'nombre': 'Test',
        'departamento_id': 4,
      });
      expect(p.departamentoId, isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // Bulk
  // ══════════════════════════════════════════════════════════════

  group('asignarDepartamentoAProductos', () {
    test('5 productos null reciben la misma estación', () async {
      const cat = 100;
      final ids = <int>[];
      for (var i = 0; i < 5; i++) {
        ids.add(await crearProducto(categoriaId: cat));
      }

      final modificados = await isar.asignarDepartamentoAProductos(ids, 7);

      expect(modificados, 5);
      for (final id in ids) {
        expect(await deId(id), 7);
      }
    });

    test('respeta los que YA tienen estación (decisión Q2)', () async {
      final idA = await crearProducto(departamentoId: 1);
      final idB = await crearProducto(departamentoId: null);
      final idC = await crearProducto(departamentoId: 2);

      final modificados = await isar
          .asignarDepartamentoAProductos([idA, idB, idC], 7);

      expect(modificados, 1, reason: 'solo el que estaba en null');
      expect(await deId(idA), 1, reason: 'no se pisa el trabajo previo');
      expect(await deId(idB), 7);
      expect(await deId(idC), 2, reason: 'no se pisa el trabajo previo');
    });

    test('sobrescribir: true reemplaza TODOS', () async {
      final idA = await crearProducto(departamentoId: 1);
      final idB = await crearProducto(departamentoId: null);

      final modificados = await isar.asignarDepartamentoAProductos(
        [idA, idB],
        7,
        sobrescribir: true,
      );

      expect(modificados, 2);
      expect(await deId(idA), 7);
      expect(await deId(idB), 7);
    });

    test('departamentoId = null DESASIGNA', () async {
      final id = await crearProducto(departamentoId: 4);

      final modificados = await isar.asignarDepartamentoAProductos([id], null);

      // Con el filtro por defecto no toca nada: el producto ya tiene
      // estación. Hace falta `sobrescribir` para desasignar.
      expect(modificados, 0);
      expect(await deId(id), 4);

      final conForce = await isar.asignarDepartamentoAProductos(
        [id],
        null,
        sobrescribir: true,
      );
      expect(conForce, 1);
      expect(await deId(id), isNull);
    });

    test('lista vacía → 0 modificados, sin tocar nada', () async {
      final id = await crearProducto(departamentoId: 1);
      expect(await isar.asignarDepartamentoAProductos([], 7), 0);
      expect(await deId(id), 1);
    });

    test('ids inexistentes se ignoran sin romper el lote', () async {
      final id = await crearProducto();
      final modificados = await isar
          .asignarDepartamentoAProductos([id, 999999, 999998], 7);

      expect(modificados, 1);
      expect(await deId(id), 7);
    });

    test('el bulk marca sincronizado=false para forzar el push', () async {
      final id = await crearProducto();
      final db = await isar.db;
      await db.writeTxn(() async {
        final p = (await db.productoEntitys.get(id))!..sincronizado = true;
        await db.productoEntitys.put(p);
      });

      await isar.asignarDepartamentoAProductos([id], 7);

      expect((await db.productoEntitys.get(id))!.sincronizado, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // Lectura por categoría + contador
  // ══════════════════════════════════════════════════════════════

  group('obtenerProductosPorCategoriaId / contarProductosSinEstacion', () {
    test('devuelve solo los de esa categoría', () async {
      final catA = 200;
      final catB = 201;
      final a1 = await crearProducto(categoriaId: catA);
      await crearProducto(categoriaId: catA);
      await crearProducto(categoriaId: catB);
      await crearProducto();

      final deA = await isar.obtenerProductosPorCategoriaId(catA);
      expect(deA.length, 2);
      expect(deA.map((p) => p.id), contains(a1));

      expect(await isar.obtenerProductosPorCategoriaId(999), isEmpty);
    });

    test('cuenta los que aún no tienen estación', () async {
      await crearProducto();
      await crearProducto();
      await crearProducto(departamentoId: 1);

      expect(await isar.contarProductosSinEstacion(), 2);
    });
  });
}
