// test/services/recetas_sync_local_test.dart
//
// R.4 · G.1 · Contrato local del sync de recetas.
//
// Lo que se prueba aquí es la parte que NO depende de la red:
//
//   · `guardarReceta` marca la receta como pendiente. Sin eso, editar una
//     receta ya sincronizada dejaba `sincronizado` en `true` y el push la
//     ignoraba PARA SIEMPRE: el cambio se veía en este dispositivo y en
//     ningún otro. Es el bug más caro que podía tener este sync.
//   · El pull escribe con `marcarPendiente: false`. Si no, cada receta
//     bajada se re-subiría en el ciclo siguiente, en un bucle perpetuo.
//   · `marcarRecetaSincronizada` RELEE la fila antes del `put`: `items` es
//     `@embedded`, así que un `put` de una instancia vieja perdería los
//     ingredientes guardados mientras tanto.
//
// ⚠️ Estos tests usan `test()` plano con Isar real en un directorio
// temporal, no `testWidgets`: `FakeAsync` cuelga la I/O de Isar.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/receta_entity.dart';

const int kLocal = 1;

RecetaEntity receta({
  int productoId = 42,
  String nombrePlato = 'Pizza',
  int ingredientes = 1,
  bool sincronizado = false,
}) {
  final r = RecetaEntity()
    ..productoId = productoId
    ..nombrePlato = nombrePlato
    ..localId = kLocal
    ..rindePorciones = 1
    ..items = [
      for (var i = 0; i < ingredientes; i++)
        RecetaItemEntity()
          ..ingredienteId = 100 + i
          ..ingredienteNombre = 'Ingrediente $i'
          ..cantidad = 0.5
          ..unidad = 'kg',
    ];
  r.sincronizado = sincronizado;
  return r;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('recetas_sync_');
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

  group('guardarReceta · marca de pendiente', () {
    test('una receta nueva queda pendiente de subir', () async {
      final id = await IsarService().guardarReceta(receta());

      final guardada = await IsarService().obtenerRecetaPorId(id);
      expect(guardada, isNotNull);
      expect(guardada!.sincronizado, isFalse);
      expect(guardada.items, hasLength(1));
      expect(guardada.createdAt, isNotNull);
    });

    test('editar una receta YA sincronizada la vuelve a marcar pendiente',
        () async {
      final r = receta(sincronizado: true);
      final id = await IsarService().guardarReceta(r);
      // `guardarReceta` es el que decide: aunque llegue en `true`, la
      // escritura local es un cambio que hay que subir.
      expect((await IsarService().obtenerRecetaPorId(id))!.sincronizado,
          isFalse);
    });

    test('marcarPendiente: false conserva el estado (camino del pull)',
        () async {
      final id = await IsarService().guardarReceta(
        receta(sincronizado: true),
        marcarPendiente: false,
      );

      final guardada = await IsarService().obtenerRecetaPorId(id);
      expect(guardada!.sincronizado, isTrue);
    });

    test('sellar createdAt/updatedAt no depende de la UI', () async {
      final r = receta();
      final id = await IsarService().guardarReceta(r);

      final guardada = await IsarService().obtenerRecetaPorId(id);
      expect(r.createdAt, isNotNull);
      expect(guardada!.updatedAt, isNotNull);
    });
  });

  group('obtenerRecetasPendientesSync', () {
    test('devuelve solo las no sincronizadas', () async {
      await IsarService().guardarReceta(receta(nombrePlato: 'Pendiente'));
      await IsarService().guardarReceta(
        receta(nombrePlato: 'Subida', sincronizado: true),
        marcarPendiente: false,
      );

      final pendientes = await IsarService().obtenerRecetasPendientesSync();

      expect(pendientes, hasLength(1));
      expect(pendientes.single.nombrePlato, 'Pendiente');
    });

    test('sin recetas devuelve lista vacía', () async {
      expect(await IsarService().obtenerRecetasPendientesSync(), isEmpty);
    });
  });

  group('marcarRecetaSincronizada', () {
    test('marca sincronizada, guarda el uuid y sella la fecha', () async {
      final id = await IsarService().guardarReceta(receta());

      await IsarService().marcarRecetaSincronizada(
        id,
        supabaseId: 'uuid-123',
      );

      final guardada = await IsarService().obtenerRecetaPorId(id);
      expect(guardada!.sincronizado, isTrue);
      expect(guardada.supabaseId, 'uuid-123');
      expect(guardada.fechaSincronizacion, isNotNull);
      expect(
        await IsarService().obtenerRecetasPendientesSync(),
        isEmpty,
      );
    });

    test('NO pierde los ingredientes ya guardados (items @embedded)',
        () async {
      final r = receta(ingredientes: 3);
      final id = await IsarService().guardarReceta(r);

      await IsarService().marcarRecetaSincronizada(id);

      final guardada = await IsarService().obtenerRecetaPorId(id);
      expect(guardada!.items, hasLength(3));
      expect(guardada.items.map((i) => i.ingredienteNombre).toList(),
          ['Ingrediente 0', 'Ingrediente 1', 'Ingrediente 2']);
    });

    test('un id inexistente no lanza ni crea nada', () async {
      await IsarService().marcarRecetaSincronizada(9999);

      expect(await IsarService().obtenerRecetaPorId(9999), isNull);
    });

    test('sin supabaseId conserva el que ya tenía', () async {
      final id = await IsarService().guardarReceta(
        receta()..supabaseId = 'uuid-previo',
      );

      await IsarService().marcarRecetaSincronizada(id);

      expect(
        (await IsarService().obtenerRecetaPorId(id))!.supabaseId,
        'uuid-previo',
      );
    });
  });

  group('obtenerRecetaPorProducto · sigue funcionando tras el sync', () {
    test('encuentra la receta del local', () async {
      await IsarService().guardarReceta(receta(productoId: 42));

      final encontrada =
          await IsarService().obtenerRecetaPorProducto(kLocal, 42);

      expect(encontrada, isNotNull);
      expect(encontrada!.productoId, 42);
    });

    test('no devuelve la receta de otro local', () async {
      await IsarService().guardarReceta(
        receta(productoId: 42)..localId = 2,
      );

      expect(await IsarService().obtenerRecetaPorProducto(kLocal, 42), isNull);
    });
  });

  group('id de Isar y clave de cruce', () {
    test('guardar dos recetas de platos distintos conserva ids distintos',
        () async {
      final a = await IsarService().guardarReceta(receta(productoId: 1));
      final b = await IsarService().guardarReceta(receta(productoId: 2));

      expect(a, isNot(b));
      // El `id_isar` que viaja a la nube es justo este id: si dos recetas
      // compartieran id, el upsert de una pisaría a la otra.
      expect((await IsarService().obtenerRecetaPorId(a))!.productoId, 1);
      expect((await IsarService().obtenerRecetaPorId(b))!.productoId, 2);
    });

    test('una receta bajada con id explícito se puede releer', () async {
      final desdeNube = RecetaEntity.fromSupabase(
        {
          'id': 'uuid-nube',
          'id_isar': 21,
          'producto_id_fk': 7,
          'nombre_plato': 'Bajada',
          'rinde_porciones': 1,
          'receta_ingredientes': [
            {
              'orden': 0,
              'ingrediente_id_fk': 3,
              'ingrediente_nombre': 'Queso',
              'cantidad': 0.15,
              'unidad': 'kg',
            },
          ],
        },
        localIdResuelto: kLocal,
      );

      await IsarService().guardarReceta(desdeNube, marcarPendiente: false);

      final guardada = await IsarService().obtenerRecetaPorId(21);
      expect(guardada, isNotNull);
      expect(guardada!.supabaseId, 'uuid-nube');
      expect(guardada.items.single.ingredienteNombre, 'Queso');
      expect(guardada.sincronizado, isTrue);
    });
  });
}
