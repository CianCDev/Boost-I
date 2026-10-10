// test/features/pos/kds_estados_test.dart
//
// R.3.1 · KDS — ciclo de estados de los platos.
//
// Dos bloques con dependencias distintas:
//
//   1. Matriz de transiciones  → PURO. Sin Isar, sin Riverpod.
//   2. Ciclo contra Isar real  → abre una base temporal por test.
//
// El bloque 2 existe por DOS riesgos concretos que no se pueden comprobar
// leyendo el código:
//
//   · `@Enumerated(EnumType.name)` dentro de un `@embedded`. Es el primer
//     enum que el proyecto mete en un embebido (`CartSessionItem` es el
//     único `@embedded` del repo). Si el generator lo aceptara pero el
//     schema serializara mal, el estado volvería como otro valor. Por eso
//     el test escribe y RELEE los 6 estados.
//   · `CartSessionItem` no es una colección: mutarlo exige leer la comanda
//     entera y hacer `put()`. Si el array no se reconstruyera bien, el
//     cambio se perdería en silencio.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/domain/models/cart_item.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';

CartSessionItem plato({
  String nombre = 'Plato',
  int? estacionId,
  EstadoPlato estado = EstadoPlato.pendiente,
}) {
  return CartSessionItem()
    ..productoId = nombre
    ..productoNombre = nombre
    ..productoCategoria = 'Platos'
    ..precioUnidad = 10.0
    ..cantidad = 1.0
    ..estacionId = estacionId
    ..estadoPlato = estado;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ══════════════════════════════════════════════════════════════
  // 1 · MATRIZ DE TRANSICIONES (puro)
  // ══════════════════════════════════════════════════════════════

  group('R.3.1 · transiciones válidas', () {
    bool ok(EstadoPlato a, EstadoPlato b) =>
        ComandasNotifier.transicionValida(a, b);

    test('el ciclo feliz completo es válido', () {
      expect(ok(EstadoPlato.pendiente, EstadoPlato.enCola), isTrue);
      expect(ok(EstadoPlato.enCola, EstadoPlato.enPreparacion), isTrue);
      expect(ok(EstadoPlato.enPreparacion, EstadoPlato.listo), isTrue);
      expect(ok(EstadoPlato.listo, EstadoPlato.entregado), isTrue);
    });

    test('se puede cancelar desde cualquier estado no terminal', () {
      for (final e in [
        EstadoPlato.pendiente,
        EstadoPlato.enCola,
        EstadoPlato.enPreparacion,
        EstadoPlato.listo,
      ]) {
        expect(ok(e, EstadoPlato.cancelado), isTrue,
            reason: 'debe poder cancelarse desde ${e.name}');
      }
    });

    test('entregado es terminal: no sale a ningún estado', () {
      for (final destino in EstadoPlato.values) {
        expect(ok(EstadoPlato.entregado, destino), isFalse,
            reason: 'entregado → ${destino.name} debe rechazarse');
      }
    });

    test('cancelado es terminal: no sale a ningún estado', () {
      for (final destino in EstadoPlato.values) {
        expect(ok(EstadoPlato.cancelado, destino), isFalse,
            reason: 'cancelado → ${destino.name} debe rechazarse');
      }
    });

    test('no se puede saltarse etapas', () {
      // Un doble toque o un bug de UI no debe teletransportar un plato.
      expect(ok(EstadoPlato.pendiente, EstadoPlato.listo), isFalse);
      expect(ok(EstadoPlato.pendiente, EstadoPlato.entregado), isFalse);
      expect(ok(EstadoPlato.enCola, EstadoPlato.entregado), isFalse);
      expect(ok(EstadoPlato.enPreparacion, EstadoPlato.entregado), isFalse);
    });

    test('no se puede retroceder', () {
      expect(ok(EstadoPlato.enCola, EstadoPlato.pendiente), isFalse);
      expect(ok(EstadoPlato.listo, EstadoPlato.enCola), isFalse);
      expect(ok(EstadoPlato.entregado, EstadoPlato.enPreparacion), isFalse);
    });

    test('un estado no puede pasar a sí mismo', () {
      // Importa para el KDS: evita re-llamar al método si ya está en ese
      // estado (doble toque rápido del cocinero).
      for (final e in EstadoPlato.values) {
        expect(ok(e, e), isFalse, reason: '${e.name} → ${e.name}');
      }
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 2 · CICLO CONTRA ISAR REAL
  // ══════════════════════════════════════════════════════════════

  group('R.3.1 · KDS contra Isar', () {
    late String testDirPath;
    const localId = 1;

    setUp(() async {
      final tempDir = Directory.systemTemp.createTempSync('kds_test_');
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

    /// Crea una mesa del local de pruebas y devuelve su id.
    ///
    /// `guardarMesa` calcula `claveUnica` sola, que es lo que hace único al
    /// par (localId, nombre).
    Future<int> crearMesa(String nombre) async {
      final isar = IsarService();
      final id = await isar.guardarMesa(
        MesaEntity()
          ..localId = localId
          ..nombre = nombre
          ..zona = MesaZona.salon
          ..estado = MesaEstado.ocupada
          ..capacidad = 4,
      );
      return id;
    }

    /// Crea una comanda viva anclada a `mesaId`.
    Future<int> crearComanda(
      int mesaId,
      List<CartSessionItem> items, {
      ComandaEstado estado = ComandaEstado.abierta,
      String sessionId = 'mesa:test',
    }) async {
      final isar = IsarService();
      final id = await isar.guardarComanda(
        CartSessionEntity()
          ..sessionId = sessionId
          ..nombre = 'Comanda test'
          ..usuarioId = 1
          ..mesaId = mesaId
          ..mesaNombre = 'Mesa test'
          ..comandaEstado = estado
          ..items = items
          ..itemsNombres = items.map((i) => i.productoNombre).toList(),
      );
      return id;
    }

    // ── Enum embebido: el riesgo real ───────────────────────────

    test('los 6 EstadoPlato se persisten y releen sin corromperse', () async {
      final isar = IsarService();
      final mesaId = await crearMesa('M1');

      final items = [
        for (final e in EstadoPlato.values)
          plato(nombre: e.name)..estadoPlato = e,
      ];
      final comandaId = await crearComanda(mesaId, items);

      // Relee desde disco, no desde el objeto en memoria.
      final db = await isar.db;
      final leida = await db.cartSessionEntitys.get(comandaId);

      expect(leida, isNotNull);
      expect(leida!.items.length, EstadoPlato.values.length);

      for (var i = 0; i < EstadoPlato.values.length; i++) {
        expect(leida.items[i].estadoPlato, EstadoPlato.values[i],
            reason: 'el estado "${EstadoPlato.values[i].name}" debe volver '
                'idéntico tras el round-trip');
      }
    });

    test('un item nuevo nace en `pendiente`', () async {
      final isar = IsarService();
      final mesaId = await crearMesa('M1');
      final comandaId = await crearComanda(mesaId, [plato()]);

      final leida = await isar.obtenerComandaPorId(comandaId);
      expect(leida!.items.first.estadoPlato, EstadoPlato.pendiente);
      expect(leida.items.first.enviadoACocinaAt, isNull);
    });

    // ── marcarPendientesComoEnCola ─────────────────────────────

    test('marcarPendientesComoEnCola marca SOLO los pendientes', () async {
      final isar = IsarService();
      final mesaId = await crearMesa('M1');
      final t0 = DateTime(2026, 1, 1, 12);

      final comandaId = await crearComanda(mesaId, [
        plato(nombre: 'A'),
        plato(nombre: 'B')..estadoPlato = EstadoPlato.enPreparacion,
        plato(nombre: 'C'),
      ]);

      final marcados = await isar.marcarPendientesComoEnCola(comandaId, t0);
      expect(marcados, 2, reason: 'solo A y C estaban pendientes');

      final items =
          (await isar.obtenerComandaPorId(comandaId))!.items;

      expect(items[0].estadoPlato, EstadoPlato.enCola);
      expect(items[0].enviadoACocinaAt, t0);

      expect(items[1].estadoPlato, EstadoPlato.enPreparacion,
          reason: 'B no debe tocarse');

      expect(items[2].estadoPlato, EstadoPlato.enCola);
      expect(items[2].enviadoACocinaAt, t0);
    });

    test('un doble envío NO duplica ni resetea el timestamp', () async {
      final isar = IsarService();
      final mesaId = await crearMesa('M1');
      final t0 = DateTime(2026, 1, 1, 12);
      final comandaId = await crearComanda(mesaId, [plato()]);

      expect(await isar.marcarPendientesComoEnCola(comandaId, t0), 1);

      // Segundo envío con OTRO timestamp: no debe pisar el original.
      final masTarde = t0.add(const Duration(hours: 1));
      expect(
        await isar.marcarPendientesComoEnCola(comandaId, masTarde),
        0,
        reason: 'ya no hay pendientes: debe ser no-op',
      );

      final item = (await isar.obtenerComandaPorId(comandaId))!.items.first;
      expect(item.estadoPlato, EstadoPlato.enCola);
      expect(item.enviadoACocinaAt, t0,
          reason: 'el segundo envío no debe alterar el timestamp original');
    });

    test('marcarPendientesComoEnCola sobre comanda inexistente = 0', () async {
      final isar = IsarService();
      expect(
        await isar.marcarPendientesComoEnCola(999999, DateTime.now()),
        0,
      );
    });

    // ── actualizarItemDeComanda + timestamps ────────────────────

    test('actualizarItemDeComanda sella el timestamp de cada estado', () async {
      final isar = IsarService();
      final mesaId = await crearMesa('M1');
      final t0 = DateTime(2026, 2, 2, 10);
      final comandaId = await crearComanda(mesaId, [plato()]);

      await isar.marcarPendientesComoEnCola(comandaId, t0);

      expect(
        await isar.actualizarItemDeComanda(
            comandaId, 0, EstadoPlato.enPreparacion, timestamp: t0),
        comandaId,
      );
      var item = (await isar.obtenerComandaPorId(comandaId))!.items.first;
      expect(item.estadoPlato, EstadoPlato.enPreparacion);
      expect(item.preparacionIniciadaAt, t0);
      expect(item.listoAt, isNull);

      await isar.actualizarItemDeComanda(
          comandaId, 0, EstadoPlato.listo, timestamp: t0);
      item = (await isar.obtenerComandaPorId(comandaId))!.items.first;
      expect(item.listoAt, t0);
      expect(item.entregadoAt, isNull);

      await isar.actualizarItemDeComanda(
          comandaId, 0, EstadoPlato.entregado, timestamp: t0);
      item = (await isar.obtenerComandaPorId(comandaId))!.items.first;
      expect(item.entregadoAt, t0);
    });

    test('actualizarItemDeComanda con índice fuera de rango = -1', () async {
      final isar = IsarService();
      final mesaId = await crearMesa('M1');
      final comandaId = await crearComanda(mesaId, [plato()]);

      expect(
        await isar.actualizarItemDeComanda(
            comandaId, 5, EstadoPlato.enPreparacion),
        -1,
      );
      expect(
        await isar.actualizarItemDeComanda(
            comandaId, -1, EstadoPlato.enPreparacion),
        -1,
      );
    });

    // ── obtenerComandasConItemsEnCola + FIFO ────────────────────

    test('obtenerComandasConItemsEnCola ordena FIFO por enviadoACocinaAt',
        () async {
      final isar = IsarService();
      final base = DateTime(2026, 3, 3, 9);

      // Se crean en orden INVERSO al esperado para que el sort importe.
      final tC = base.add(const Duration(minutes: 30));
      final mesaC = await crearMesa('M3');
      final idC = await crearComanda(mesaC, [plato(nombre: 'C')],
          sessionId: 'mesa:m3');
      await isar.marcarPendientesComoEnCola(idC, tC);

      final tB = base.add(const Duration(minutes: 20));
      final mesaB = await crearMesa('M2');
      final idB = await crearComanda(mesaB, [plato(nombre: 'B')],
          sessionId: 'mesa:m2');
      await isar.marcarPendientesComoEnCola(idB, tB);

      final tA = base.add(const Duration(minutes: 10));
      final mesaA = await crearMesa('M1');
      final idA = await crearComanda(mesaA, [plato(nombre: 'A')],
          sessionId: 'mesa:m1');
      await isar.marcarPendientesComoEnCola(idA, tA);

      final cola = await isar.obtenerComandasConItemsEnCola(localId);

      expect(cola.length, 3);
      expect(cola.map((c) => c.id).toList(), [idA, idB, idC],
          reason: 'la más antigua primero');
    });

    test('obtenerComandasConItemsEnCola excluye lo que no está en cola',
        () async {
      final isar = IsarService();
      final t0 = DateTime(2026, 4, 4, 9);

      final mesaA = await crearMesa('M1');
      await crearComanda(mesaA, [plato(nombre: 'pendiente')],
          sessionId: 'mesa:a1');

      final mesaB = await crearMesa('M2');
      final entregado = plato(nombre: 'entregado')
        ..estadoPlato = EstadoPlato.entregado;
      final idB = await crearComanda(mesaB, [entregado]);
      await isar.marcarPendientesComoEnCola(idB, t0);
      await isar.actualizarItemDeComanda(
          idB, 0, EstadoPlato.enPreparacion, timestamp: t0);
      await isar.actualizarItemDeComanda(
          idB, 0, EstadoPlato.listo, timestamp: t0);
      await isar.actualizarItemDeComanda(
          idB, 0, EstadoPlato.entregado, timestamp: t0);

      final mesaC = await crearMesa('M3');
      final idC = await crearComanda(mesaC, [plato(nombre: 'encolado')],
          sessionId: 'mesa:c1');
      await isar.marcarPendientesComoEnCola(idC, t0);

      final cola = await isar.obtenerComandasConItemsEnCola(localId);

      expect(cola.map((c) => c.id).toList(), [idC],
          reason: 'solo la comanda con un plato enCola debe aparecer');
    });

    test('obtenerComandasConItemsEnCola ignora comandas cerradas', () async {
      final isar = IsarService();
      final t0 = DateTime(2026, 5, 5, 9);

      final mesaA = await crearMesa('M1');
      final idA = await crearComanda(mesaA, [plato()], sessionId: 'mesa:a1');
      await isar.marcarPendientesComoEnCola(idA, t0);

      final mesaB = await crearMesa('M2');
      final idB = await crearComanda(mesaB, [plato()],
          sessionId: 'mesa:b1', estado: ComandaEstado.cancelada);
      await isar.marcarPendientesComoEnCola(idB, t0);

      final cola = await isar.obtenerComandasConItemsEnCola(localId);
      expect(cola.map((c) => c.id).toList(), [idA]);
    });

    test('otro local no ve la cola', () async {
      final isar = IsarService();
      final t0 = DateTime(2026, 6, 6, 9);

      final mesa = await crearMesa('M1');
      final id = await crearComanda(mesa, [plato()], sessionId: 'mesa:x1');
      await isar.marcarPendientesComoEnCola(id, t0);

      expect(await isar.obtenerComandasConItemsEnCola(localId), hasLength(1));
      expect(await isar.obtenerComandasConItemsEnCola(999), isEmpty);
    });

    // ── estación ────────────────────────────────────────────────

    test('estacionId sobrevive al round-trip del item', () async {
      final isar = IsarService();
      final mesaId = await crearMesa('M1');
      final comandaId = await crearComanda(
        mesaId,
        [plato(estacionId: 3), plato()],
      );

      final db = await isar.db;
      final leida = await db.cartSessionEntitys.get(comandaId);

      expect(leida!.items[0].estacionId, 3);
      expect(leida.items[1].estacionId, isNull,
          reason: 'un producto sin departamento debe quedar null');
    });

    test('estadosVisiblesEnKds cubre enCola, enPreparacion y listo', () {
      expect(IsarService.estadosVisiblesEnKds, hasLength(3));
      expect(IsarService.estadosVisiblesEnKds,
          containsAll(<EstadoPlato>[
            EstadoPlato.enCola,
            EstadoPlato.enPreparacion,
            EstadoPlato.listo,
          ]));
      expect(IsarService.estadosVisiblesEnKds,
          isNot(contains(EstadoPlato.pendiente)));
      expect(IsarService.estadosVisiblesEnKds,
          isNot(contains(EstadoPlato.entregado)));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 3 · PROPAGACIÓN DE LA ESTACIÓN (puro)
  //
  // Los mappers (`_cartItemToSessionItem`) son privados de
  // `CartSessionsNotifier` y `ComandasNotifier`, así que aquí se prueba la
  // API pública que los sostiene: `CartItem` es inmutable, así que la
  // estación tiene que sobrevivir al constructor y al `copyWith`.
  // ══════════════════════════════════════════════════════════════

  group('R.3.1 · CartItem.estacionId', () {
    CartItem item({int? estacionId}) => CartItem(
          producto: ProductItem(
            id: '1',
            nombre: 'Lomo saltado',
            codigoBarras: '111',
            categoria: 'Platos',
            precioUnidad: 25.0,
            esPesado: false,
          ),
          cantidad: 2.0,
          estacionId: estacionId,
        );

    test('por defecto es null (retail, venta directa)', () {
      expect(item().estacionId, isNull);
    });

    test('guarda la estación que le pasan', () {
      expect(item(estacionId: 2).estacionId, 2);
    });

    test('copyWith la conserva cuando no se cambia', () {
      expect(item(estacionId: 2).copyWith(cantidad: 5).estacionId, 2,
          reason: 'cambiar la cantidad no debe perder la estación');
    });

    test('copyWith puede asignarla después', () {
      expect(item().copyWith(estacionId: 7).estacionId, 7);
    });

    test('toJson la incluye', () {
      expect(item(estacionId: 4).toJson()['estacionId'], 4);
      expect(item().toJson()['estacionId'], isNull);
    });

    test('no afecta al subtotal', () {
      expect(item(estacionId: 9).subtotal, 50.0);
    });
  });
}
