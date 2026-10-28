import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

/// R.1c · Comandas multi-dispositivo (persistencia local).
///
/// Cubre lo que el sync necesita para no duplicar mesas ni perder comandas:
///  · `syncKey` se genera una sola vez y no cambia al editar.
///  · El pull (`marcarPendiente: false`) NO deja la fila pendiente.
///  · Las comandas de retail (`mesaId == null`) no se suben.
///  · `sessionId` de históricas no choca con el de la viva de la mesa.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('isar_comandas_test_');
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

  CartSessionEntity comanda({
    int? mesaId = 1,
    ComandaEstado estado = ComandaEstado.abierta,
    String? sessionId,
    String? syncKey,
    String? supabaseId,
    DateTime? updatedAt,
    bool sincronizado = false,
    List<CartSessionItem>? items,
  }) {
    final c = CartSessionEntity()
      ..sessionId = sessionId ??
          (mesaId == null
              ? 'uuid-retail'
              : CartSessionEntity.sessionIdDeMesa(mesaId))
      ..usuarioId = 7
      ..nombre = 'Comanda Mesa'
      ..mesaId = mesaId
      ..mesaNombre = mesaId == null ? null : 'Mesa 1'
      ..comandaEstado = estado
      ..sincronizado = sincronizado
      ..items = items ?? <CartSessionItem>[];
    if (syncKey != null) c.syncKey = syncKey;
    if (supabaseId != null) c.supabaseId = supabaseId;
    if (updatedAt != null) c.updatedAt = updatedAt;
    return c;
  }

  group('Comandas — identidad de sync', () {
    test('guardarComanda genera syncKey y deja pendiente', () async {
      final isar = IsarService();
      final id = await isar.guardarComanda(comanda());

      final guardada = await isar.obtenerComandaPorId(id);
      expect(guardada, isNotNull);
      expect(guardada!.syncKey, isNotNull);
      expect(guardada.syncKey!.length, 36); // UUID v4
      expect(guardada.sincronizado, isFalse);
    });

    test('editar NO cambia el syncKey', () async {
      final isar = IsarService();
      final id = await isar.guardarComanda(comanda());
      final primera = (await isar.obtenerComandaPorId(id))!;

      primera.notas = 'sin cebolla';
      await isar.guardarComanda(primera);

      final segunda = (await isar.obtenerComandaPorId(id))!;
      expect(segunda.syncKey, primera.syncKey);
    });

    test('un carrito de retail no recibe syncKey ni se sube', () async {
      final isar = IsarService();
      final id = await isar.guardarComanda(comanda(mesaId: null));

      final guardada = await isar.obtenerComandaPorId(id);
      expect(guardada!.syncKey, isNull);
      expect(await isar.obtenerComandasPendientesSync(), isEmpty);
    });

    test('marcarPendiente:false NO toca el flag de sincronizado', () async {
      final isar = IsarService();
      final id = await isar.guardarComanda(
        comanda(
          supabaseId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
          sincronizado: true,
        ),
        marcarPendiente: false,
      );

      final guardada = await isar.obtenerComandaPorId(id);
      expect(guardada!.sincronizado, isTrue);
      expect(await isar.obtenerComandasPendientesSync(), isEmpty);
    });
  });

  group('Comandas — pendientes de sync', () {
    test('incluye vivas antiguas y recientes cerradas, no el histórico',
        () async {
      final isar = IsarService();
      final vieja = DateTime.now().subtract(const Duration(days: 30));

      final vivaAntigua = await isar.guardarComanda(comanda(
        mesaId: 1,
        updatedAt: vieja,
      ));
      final cerradaVieja = await isar.guardarComanda(comanda(
        mesaId: 2,
        estado: ComandaEstado.cerrada,
        updatedAt: vieja,
      ));
      final cerradaReciente = await isar.guardarComanda(comanda(
        mesaId: 3,
        estado: ComandaEstado.cerrada,
      ));

      // `guardarComanda` sella `updatedAt = now()`. Para simular una comanda
      // cerrada hace un mes hay que retroceder la fecha después de guardar.
      final isarDb = await isar.db;
      await isarDb.writeTxn(() async {
        for (final id in [vivaAntigua, cerradaVieja]) {
          final c = await isarDb.cartSessionEntitys.get(id);
          if (c != null) {
            c.updatedAt = vieja;
            await isarDb.cartSessionEntitys.put(c);
          }
        }
      });

      final pendientes = await isar.obtenerComandasPendientesSync();
      final ids = pendientes.map((c) => c.id).toSet();

      expect(ids, contains(vivaAntigua));
      expect(ids, contains(cerradaReciente));
      expect(ids, isNot(contains(cerradaVieja)));
    });
  });

  group('Comandas — búsquedas del pull', () {
    test('obtenerComandaVivaDeMesa ignora cerradas y canceladas', () async {
      final isar = IsarService();
      await isar.guardarComanda(comanda(
        mesaId: 5,
        estado: ComandaEstado.cancelada,
        sessionId: 'mesa:5#hist',
      ));
      expect(await isar.obtenerComandaVivaDeMesa(5), isNull);

      final viva = await isar.guardarComanda(comanda(mesaId: 5));
      final encontrada = await isar.obtenerComandaVivaDeMesa(5);
      expect(encontrada?.id, viva);
    });

    test('busca por supabaseId y por syncKey', () async {
      final isar = IsarService();
      final id = await isar.guardarComanda(comanda(
        supabaseId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        syncKey: '11111111-2222-3333-4444-555555555555',
      ));

      expect(
        (await isar.obtenerComandaPorSupabaseId(
                'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'))
            ?.id,
        id,
      );
      expect(
        (await isar.obtenerComandaPorSyncKey(
                '11111111-2222-3333-4444-555555555555'))
            ?.id,
        id,
      );
      expect(await isar.obtenerComandaPorSyncKey('no-existe'), isNull);
    });
  });

  group('Comandas — sessionId', () {
    test('la histórica no choca con la viva de la mesa', () {
      final viva = CartSessionEntity.sessionIdDeMesa(9);
      final historica = CartSessionEntity.sessionIdHistorico(
          9, 'abcdef12-3456-7890-abcd-ef1234567890');

      expect(viva, 'mesa:9');
      expect(historica, 'mesa:9#abcdef12');
      expect(historica, isNot(viva));
    });

    test('dos históricas de la misma mesa conviven en Isar', () async {
      final isar = IsarService();
      final a = await isar.guardarComanda(comanda(
        mesaId: 9,
        estado: ComandaEstado.cancelada,
        sessionId: CartSessionEntity.sessionIdHistorico(9, 'aaaaaaaa-1'),
        syncKey: 'aaaaaaaa-1',
      ));
      final b = await isar.guardarComanda(comanda(
        mesaId: 9,
        estado: ComandaEstado.cancelada,
        sessionId: CartSessionEntity.sessionIdHistorico(9, 'bbbbbbbb-2'),
        syncKey: 'bbbbbbbb-2',
      ));

      expect(await isar.obtenerComandaPorId(a), isNotNull);
      expect(await isar.obtenerComandaPorId(b), isNotNull);
      expect(a, isNot(b));
    });
  });

  group('KDS — el avance de cocina queda pendiente de subir', () {
    test('marcarPendientesComoEnCola deja sincronizado en false', () async {
      final isar = IsarService();
      final item = CartSessionItem()
        ..productoId = 'prod-1'
        ..productoNombre = 'Pizza'
        ..cantidad = 1
        ..estadoPlato = EstadoPlato.pendiente;

      final id = await isar.guardarComanda(
        comanda(items: [item], sincronizado: true),
        marcarPendiente: false,
      );
      expect((await isar.obtenerComandaPorId(id))!.sincronizado, isTrue);

      final marcados =
          await isar.marcarPendientesComoEnCola(id, DateTime.now());
      expect(marcados, 1);

      final guardada = await isar.obtenerComandaPorId(id);
      expect(guardada!.sincronizado, isFalse);
      expect(guardada.items.first.estadoPlato, EstadoPlato.enCola);
      expect(guardada.items.first.enviadoACocinaAt, isNotNull);
    });

    test('actualizarPausaItem deja sincronizado en false', () async {
      final isar = IsarService();
      final item = CartSessionItem()
        ..productoId = 'prod-2'
        ..productoNombre = 'Sopa'
        ..cantidad = 2;

      final id = await isar.guardarComanda(
        comanda(items: [item], sincronizado: true),
        marcarPendiente: false,
      );

      await isar.actualizarPausaItem(id, 0, pausado: true, motivo: 'falta sal');

      final guardada = await isar.obtenerComandaPorId(id);
      expect(guardada!.sincronizado, isFalse);
      expect(guardada.items.first.pausado, isTrue);
      expect(guardada.items.first.motivoPausa, 'falta sal');
    });
  });
}
