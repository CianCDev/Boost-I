// test/unit/receta_entity_sync_test.dart
//
// R.4 · G.1 · Mapeo de RecetaEntity a/desde Supabase.
//
// Puro Dart: no abre Isar ni habla con la red. Verifica el CONTRATO del
// payload que consume la RPC `guardar_receta(p_receta, p_ingredientes)` y la
// reconstrucción desde una fila con `receta_ingredientes(*)` embebido.
//
// ⚠️ Lo que estos tests NO pueden probar: que la tabla y la RPC existan. Eso
// se verifica con las queries del final de
// `supabase/migrations/20261027000001_recetas.sql`, a mano contra el remoto.
import 'package:app_boosti_v2/features/pos/data/Local/entities/receta_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

/// Fila tal como la devuelve PostgREST con `select('*, receta_ingredientes(*)')`.
Map<String, dynamic> recetaDesdeNube({
  int idIsar = 7,
  String uuid = 'receta-uuid-1',
  int productoIdFk = 42,
  String nombrePlato = 'Pizza margarita',
  num rinde = 1,
  bool activo = true,
  List<Map<String, dynamic>>? ingredientes,
}) {
  return {
    'id': uuid,
    'id_isar': idIsar,
    'tenant_id': 'tenant-uuid',
    'producto_id_fk': productoIdFk,
    'nombre_plato': nombrePlato,
    'rinde_porciones': rinde,
    'activo': activo,
    'sincronizado': true,
    'created_at': '2026-10-20T10:00:00Z',
    'updated_at': '2026-10-21T09:30:00Z',
    'receta_ingredientes': ingredientes ??
        [
          {
            'id': 'ing-1',
            'receta_id': uuid,
            'orden': 0,
            'ingrediente_id_fk': 10,
            'ingrediente_nombre': 'Harina',
            'cantidad': 0.25,
            'unidad': 'kg',
            'es_opcional': false,
          },
        ],
  };
}

void main() {
  group('toSupabaseJson · payload de la RPC', () {
    test('traduce los campos al nombre de columna', () {
      final receta = RecetaEntity()
        ..id = 7
        ..productoId = 42
        ..nombrePlato = 'Pizza margarita'
        ..rindePorciones = 2
        ..activo = false;

      expect(receta.toSupabaseJson(), {
        'id_isar': 7,
        'producto_id_fk': 42,
        'nombre_plato': 'Pizza margarita',
        'rinde_porciones': 2.0,
        'activo': false,
      });
    });

    test('NO manda tenant_id (lo pone current_tenant_id en el server)', () {
      final receta = RecetaEntity()..id = 3;

      expect(receta.toSupabaseJson().containsKey('tenant_id'), isFalse);
    });

    test('rindePorciones 0 o negativo se normaliza a 1', () {
      // La columna tiene CHECK (> 0): sin normalizar, una receta tocada a
      // mano tumbaría el push entero.
      expect((RecetaEntity()..id = 1).toSupabaseJson()['rinde_porciones'], 1.0);
      expect(
        (RecetaEntity()
              ..id = 1
              ..rindePorciones = 0)
            .toSupabaseJson()['rinde_porciones'],
        1.0,
      );
      expect(
        (RecetaEntity()
              ..id = 1
              ..rindePorciones = -3)
            .toSupabaseJson()['rinde_porciones'],
        1.0,
      );
    });
  });

  group('ingredientesToSupabaseJson · orden implícito', () {
    test('el índice de la lista es el campo orden', () {
      final receta = RecetaEntity()
        ..id = 1
        ..items = [
          RecetaItemEntity()
            ..ingredienteId = 10
            ..ingredienteNombre = 'Harina'
            ..cantidad = 0.25
            ..unidad = 'kg',
          RecetaItemEntity()
            ..ingredienteId = 11
            ..ingredienteNombre = 'Queso'
            ..cantidad = 150
            ..unidad = 'g'
            ..esOpcional = true,
        ];

      final payload = receta.ingredientesToSupabaseJson();

      expect(payload, hasLength(2));
      expect(payload[0]['orden'], 0);
      expect(payload[0]['ingrediente_nombre'], 'Harina');
      expect(payload[1]['orden'], 1);
      expect(payload[1]['es_opcional'], isTrue);
    });

    test('ingrediente sin id va como null, no como 0', () {
      // La columna es nullable: un ingrediente borrado no debe romper la FK
      // (que además no existe) ni impedir que la receta viaje.
      final receta = RecetaEntity()
        ..items = [RecetaItemEntity()..ingredienteNombre = 'Fantasma'];

      expect(receta.ingredientesToSupabaseJson().single['ingrediente_id_fk'],
          isNull);
    });

    test('receta vacía manda lista vacía, no null', () {
      expect(RecetaEntity().ingredientesToSupabaseJson(), isEmpty);
    });
  });

  group('fromSupabase · reconstrucción', () {
    test('mapea la fila y el ingrediente embebido', () {
      final receta = RecetaEntity.fromSupabase(
        recetaDesdeNube(),
        localIdResuelto: 3,
      );

      expect(receta.id, 7);
      expect(receta.supabaseId, 'receta-uuid-1');
      expect(receta.localId, 3);
      expect(receta.productoId, 42);
      expect(receta.nombrePlato, 'Pizza margarita');
      expect(receta.rindePorciones, 1.0);
      expect(receta.activo, isTrue);
      expect(receta.sincronizado, isTrue);
      expect(receta.fechaSincronizacion, isNotNull);
      expect(receta.items, hasLength(1));
      expect(receta.items.single.ingredienteId, 10);
      expect(receta.items.single.ingredienteNombre, 'Harina');
      expect(receta.items.single.cantidad, 0.25);
      expect(receta.items.single.unidad, 'kg');
      expect(receta.items.single.esOpcional, isFalse);
    });

    test('respeta el campo orden aunque PostgREST los devuelva desordenados', () {
      final receta = RecetaEntity.fromSupabase(
        recetaDesdeNube(
          ingredientes: [
            {
              'orden': 2,
              'ingrediente_nombre': 'Sal',
              'cantidad': 1,
              'unidad': 'g',
            },
            {
              'orden': 0,
              'ingrediente_nombre': 'Harina',
              'cantidad': 0.25,
              'unidad': 'kg',
            },
            {
              'orden': 1,
              'ingrediente_nombre': 'Queso',
              'cantidad': 150,
              'unidad': 'g',
            },
          ],
        ),
        localIdResuelto: 1,
      );

      expect(
        receta.items.map((i) => i.ingredienteNombre).toList(),
        ['Harina', 'Queso', 'Sal'],
      );
    });

    test('sin localIdResuelto queda en 0 (el caller no pudo resolverlo)', () {
      expect(RecetaEntity.fromSupabase(recetaDesdeNube()).localId, 0);
    });

    test('tolera filas incompletas sin reventar', () {
      final receta = RecetaEntity.fromSupabase({
        'id': 'solo-uuid',
        'id_isar': 5,
      });

      expect(receta.id, 5);
      expect(receta.productoId, 0);
      expect(receta.nombrePlato, '');
      expect(receta.rindePorciones, 1.0);
      expect(receta.activo, isTrue);
      expect(receta.items, isEmpty);
      expect(receta.createdAt, isNull);
    });

    test('sin id_isar cae a autoIncrement (y el pull lo descarta)', () {
      final receta = RecetaEntity.fromSupabase({'id': 'x'});

      expect(receta.id, Isar.autoIncrement);
    });

    test('un ingrediente con datos raros no rompe la lista', () {
      // `unidad` es String libre desde G.1: si llega null, el default es
      // 'unidad', que es lo que espera ConversionUnidades.
      final receta = RecetaEntity.fromSupabase(
        recetaDesdeNube(
          ingredientes: [
            {'orden': 0, 'cantidad': null, 'unidad': null},
          ],
        ),
        localIdResuelto: 1,
      );

      expect(receta.items.single.cantidad, 0.0);
      expect(receta.items.single.unidad, 'unidad');
      expect(receta.items.single.ingredienteId, 0);
    });
  });
}
