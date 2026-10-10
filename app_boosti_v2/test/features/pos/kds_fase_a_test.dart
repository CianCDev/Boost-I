// test/features/pos/kds_fase_a_test.dart
//
// R.3.2 Fase A · Pausa de platos + derivados del KDS.
//
// Dos grupos con dependencias distintas:
//
//   1. Puro      → sin Isar, sin Riverpod. Cubre la lógica NUEVA:
//                  agrupación de tickets, índice real, FIFO, contador.
//   2. Isar real → abre una base temporal por test. Cubre la
//                  persistencia de los 3 campos de pausa.
//
// ⚠️ LÍMITE DE COBERTURA HONESTO: `ComandasNotifier.pausarItem()` y
// `reanudarItem()` NO se prueban end-to-end. El notifier construye su
// Isar con `IsarService()` hardcodeado (no inyectable), así que instanciarlo
// exige montar además `localActualProvider`, `authProvider` y `cartProvider`.
// Lo que sí queda verificado es: la matriz `estadoPlatoPausable` (estática),
// el recorte `normalizarMotivoPausa` (estático) y `actualizarPausaItem`
// contra Isar real. La validación "no pausar un entregado" se comprueba
// sobre la función pura que el notifier consulta, no sobre el notifier.
// Ver `docs/TODO.md` → inyectar Isar en ComandasNotifier.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/kds_ticket.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';

// ══════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════

CartSessionItem plato({
  String nombre = 'Plato',
  int? estacionId,
  EstadoPlato estado = EstadoPlato.pendiente,
  DateTime? enviadoAt,
  bool pausado = false,
  String? motivoPausa,
}) {
  return CartSessionItem()
    ..productoId = nombre
    ..productoNombre = nombre
    ..productoCategoria = 'Platos'
    ..precioUnidad = 10.0
    ..cantidad = 1.0
    ..estacionId = estacionId
    ..estadoPlato = estado
    ..enviadoACocinaAt = enviadoAt
    ..pausado = pausado
    ..motivoPausa = motivoPausa
    ..pausadoEn = pausado ? (enviadoAt ?? DateTime(2026, 1, 1)) : null;
}

CartSessionEntity comanda({
  required int id,
  String? mesaNombre = 'Mesa 1',
  List<CartSessionItem>? items,
  ComandaEstado estado = ComandaEstado.enviada,
}) {
  final lista = items ?? <CartSessionItem>[];
  return CartSessionEntity()
    ..id = id
    ..sessionId = 'mesa:$id'
    ..nombre = 'Comanda $id'
    ..usuarioId = 1
    ..mesaId = id
    ..mesaNombre = mesaNombre
    ..comandaEstado = estado
    ..items = lista
    ..itemsNombres = lista.map((i) => i.productoNombre).toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final base = DateTime(2026, 5, 1, 12);

  // ══════════════════════════════════════════════════════════════
  // 1 · PURO
  // ══════════════════════════════════════════════════════════════

  group('Fase A · matriz de pausabilidad', () {
    bool pausable(EstadoPlato e) => ComandasNotifier.estadoPlatoPausable(e);

    test('se puede pausar lo que está en marcha', () {
      expect(pausable(EstadoPlato.enCola), isTrue);
      expect(pausable(EstadoPlato.enPreparacion), isTrue);
    });

    test('NO se puede pausar lo que ya salió o no ha salido', () {
      expect(pausable(EstadoPlato.pendiente), isFalse,
          reason: 'aún no está en la barra');
      expect(pausable(EstadoPlato.listo), isFalse,
          reason: 'ya está cocinado, no hay nada que detener');
      expect(pausable(EstadoPlato.entregado), isFalse,
          reason: 'ya salió hacia la mesa');
      expect(pausable(EstadoPlato.cancelado), isFalse);
    });
  });

  group('Fase A · recorte del motivo de pausa', () {
    String? n(String? s) => ComandasNotifier.normalizarMotivoPausa(s);

    test('el tope es 60 caracteres', () {
      expect(ComandasNotifier.maxCharsMotivoPausa, 60);
    });

    test('recorta los espacios de los bordes', () {
      expect(n('  falta pescado  '), 'falta pescado');
    });

    test('null entra y sale como null', () {
      expect(n(null), isNull);
    });

    test('vacío o solo espacios se vuelve null', () {
      expect(n(''), isNull);
      expect(n('     '), isNull);
      expect(n('\t\n'), isNull);
    });

    test('corta a 60 sin dejar espacio a medias que duela', () {
      final largo = 'a' * 200;
      final recortado = n(largo)!;
      expect(recortado.length, 60);
      expect(recortado, 'a' * 60);
    });

    test('un texto de exactamente 60 no se toca', () {
      final exacto = 'b' * 60;
      expect(n(exacto), exacto);
    });

    test('recorta ANTES de contar, no al revés', () {
      // 58 letras + 2 espacios = 60 crudos, pero 58 útiles.
      final conEspacios = '${'c' * 58}  ';
      expect(conEspacios.length, 60);
      expect(n(conEspacios)!.length, 58,
          reason: 'primero trim, luego corte: el tope es de contenido');
    });
  });

  group('Fase A · ticketsEnCola agrupa y expone el índice real', () {
    test('una comanda = un ticket, con todos sus items visibles', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(
            id: 1,
            items: [
              plato(nombre: 'A', estado: EstadoPlato.enCola, enviadoAt: base),
              plato(nombre: 'B', estado: EstadoPlato.enCola, enviadoAt: base),
            ],
          ),
        ],
      );

      // Anotaciones explícitas a propósito: fijan el contrato del getter
      // (`List<KdsTicket>`, no un `List<dynamic>` disfrazado) y son las que
      // justifican el import de `kds_ticket.dart`.
      final List<KdsTicket> tickets = state.ticketsEnCola;
      expect(tickets.length, 1);
      expect(tickets.first.comandaId, 1);
      expect(tickets.first.mesaNombre, 'Mesa 1');

      final List<KdsTicketItem> items = tickets.first.items;
      expect(items.length, 2);
      expect(items.every((i) => i.comandaId == 1), isTrue);
    });

    test('⚠️ itemIndex es el REAL dentro de comanda.items', () {
      // 4 items: el #0 y el #3 no están en el KDS (pendiente y entregado).
      // Los visibles son el #1 y el #2, así que sus índices reales son 1 y 2,
      // NO 0 y 1. Si el índice fuera la posición en la lista filtrada, un
      // toque sobre "el primero" avanzaría el pendiente.
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(
            id: 7,
            items: [
              plato(nombre: 'oculto-0', estado: EstadoPlato.pendiente),
              plato(nombre: 'visible-1',
                  estado: EstadoPlato.enCola, enviadoAt: base),
              plato(nombre: 'visible-2',
                  estado: EstadoPlato.enCola, enviadoAt: base),
              plato(nombre: 'oculto-3', estado: EstadoPlato.entregado),
            ],
          ),
        ],
      );

      final items = state.ticketsEnCola.first.items;
      expect(items.length, 2);
      expect(items[0].itemIndex, 1);
      expect(items[1].itemIndex, 2);
      expect(items[0].item.productoNombre, 'visible-1');
    });

    test('el índice real apunta al item correcto al resolver', () {
      final lista = <CartSessionItem>[
        plato(nombre: 'oculto-0', estado: EstadoPlato.pendiente),
        plato(nombre: 'visible-1', estado: EstadoPlato.enCola),
        plato(nombre: 'visible-2', estado: EstadoPlato.enCola),
      ];
      final c = comanda(id: 9, items: lista);
      final state = ComandasState(isLoading: false, comandas: [c]);

      final primero = state.ticketsEnCola.first.items.first;
      // Esto es lo que haría el botón "Iniciar" en el KDS.
      expect(lista[primero.itemIndex].productoNombre, 'visible-1');
    });

    test('descarta estados que no están en cocina', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(
            id: 1,
            items: [
              for (final e in EstadoPlato.values)
                plato(nombre: e.name, estado: e, enviadoAt: base),
            ],
          ),
        ],
      );

      final nombres = state.ticketsEnCola.first.items
          .map((i) => i.item.productoNombre)
          .toSet();

      expect(nombres, {'enCola', 'enPreparacion', 'listo'});
      expect(nombres, isNot(contains('pendiente')));
      expect(nombres, isNot(contains('entregado')));
      expect(nombres, isNot(contains('cancelado')));
    });

    test('una comanda sin nada visible NO genera ticket', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 1, items: [plato(estado: EstadoPlato.pendiente)]),
        ],
      );
      expect(state.ticketsEnCola, isEmpty);
    });

    test('sin mesaId la etiqueta es "Para llevar" (R.5)', () {
      final c = comanda(id: 1, mesaNombre: null, items: [
        plato(estado: EstadoPlato.enCola, enviadoAt: base),
      ]);
      c.mesaNombre = null;
      final state = ComandasState(isLoading: false, comandas: [c]);

      expect(state.ticketsEnCola.first.mesaNombre, 'Para llevar');
      expect(state.ticketsEnCola.first.mesaId, 1);
    });

    test('items sin estacionId NO se descartan (van a "Sin estación")', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 1, items: [
            plato(nombre: 'sin-est', estado: EstadoPlato.enCola,
                enviadoAt: base),
            plato(nombre: 'con-est', estacionId: 3,
                estado: EstadoPlato.enCola, enviadoAt: base),
          ]),
        ],
      );

      final items = state.ticketsEnCola.first.items;
      expect(items.length, 2, reason: 'ambos deben aparecer');
      expect(items.any((i) => i.item.estacionId == null), isTrue);
    });
  });

  group('Fase A · pausados primero y contabilizados', () {
    ComandasState conPausado() => ComandasState(
          isLoading: false,
          comandas: [
            comanda(id: 1, items: [
              plato(nombre: 'normal-1',
                  estado: EstadoPlato.enCola, enviadoAt: base),
              plato(nombre: 'pausado-2',
                  estado: EstadoPlato.enCola,
                  enviadoAt: base,
                  pausado: true,
                  motivoPausa: 'falta pescado'),
              plato(nombre: 'normal-3',
                  estado: EstadoPlato.enCola, enviadoAt: base),
            ]),
          ],
        );

    test('los pausados se cuentan en el ticket', () {
      expect(conPausado().ticketsEnCola.first.pausados, 1);
      expect(conPausado().ticketsEnCola.first.tienePausados, isTrue);
    });

    test('un pausado va PRIMERO, porque bloquea el pedido', () {
      final items = conPausado().ticketsEnCola.first.items;
      expect(items.first.item.productoNombre, 'pausado-2');
      expect(items.first.item.pausado, isTrue);
    });

    test('los pausados SIGUEN en el ticket, no se filtran', () {
      expect(conPausado().ticketsEnCola.first.items.length, 3);
    });

    test('totalItemsEnKds NO cuenta los pausados', () {
      // 3 en cola, 1 pausado → 2.
      expect(conPausado().totalItemsEnKds, 2);
    });

    test('totalItemsEnKds ignora pendientes y entregados', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 1, items: [
            for (final e in EstadoPlato.values)
              plato(nombre: e.name, estado: e, enviadoAt: base),
          ]),
        ],
      );
      // Solo enCola + enPreparacion + listo.
      expect(state.totalItemsEnKds, 3);
    });
  });

  group('Fase A · totalItemsEnKds es reactivo por valor', () {
    test('devuelve un int comparable con ==', () {
      // Este es el punto crítico: `ref.watch(provider.select((s) =>
      // s.totalItemsEnKds))` en el menú comparará con `==`. Si devolviera
      // una List, dos listas nuevas nunca serían iguales y el menú se
      // reconstruiría en bucle.
      final a = const ComandasState(isLoading: false);
      final b = const ComandasState(isLoading: false);
      expect(a.totalItemsEnKds, b.totalItemsEnKds);
      expect(a.totalItemsEnKds, 0);

      // Mismo contenido → mismo valor, aunque sean objetos distintos.
      final c1 = ComandasState(
        isLoading: false,
        comandas: [comanda(id: 1, items: [
          plato(estado: EstadoPlato.enCola, enviadoAt: base),
        ])],
      );
      final c2 = ComandasState(
        isLoading: false,
        comandas: [comanda(id: 1, items: [
          plato(estado: EstadoPlato.enCola, enviadoAt: base),
        ])],
      );
      expect(identical(c1, c2), isFalse);
      expect(c1.totalItemsEnKds, c2.totalItemsEnKds);
      expect(c1.totalItemsEnKds, 1);
    });

    test('contar items de varias comandas', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 1, mesaNombre: 'M1', items: [
            plato(estado: EstadoPlato.enCola, enviadoAt: base),
            plato(estado: EstadoPlato.enPreparacion, enviadoAt: base),
          ]),
          comanda(id: 2, mesaNombre: 'M2', items: [
            plato(estado: EstadoPlato.listo, enviadoAt: base),
          ]),
        ],
      );
      expect(state.totalItemsEnKds, 3);
    });
  });

  group('Fase A · FIFO de tickets', () {
    test('la comanda con el item más ANTIGUO va primero', () {
      // Se construyen en orden inverso al esperado, para que un sort
      //incorrecto se note.
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 3, mesaNombre: 'M3', items: [
            plato(estado: EstadoPlato.enCola,
                enviadoAt: base.add(const Duration(minutes: 30))),
          ]),
          comanda(id: 1, mesaNombre: 'M1', items: [
            plato(estado: EstadoPlato.enCola,
                enviadoAt: base.add(const Duration(minutes: 10))),
          ]),
          comanda(id: 2, mesaNombre: 'M2', items: [
            plato(estado: EstadoPlato.enCola,
                enviadoAt: base.add(const Duration(minutes: 20))),
          ]),
        ],
      );

      expect(
        state.ticketsEnCola.map((t) => t.comandaId).toList(),
        [1, 2, 3],
      );
    });

    test('dentro del ticket también manda el más viejo', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 1, items: [
            plato(nombre: 'joven',
                estado: EstadoPlato.enCola,
                enviadoAt: base.add(const Duration(minutes: 5))),
            plato(nombre: 'viejo',
                estado: EstadoPlato.enCola, enviadoAt: base),
            plato(nombre: 'medio',
                estado: EstadoPlato.enCola,
                enviadoAt: base.add(const Duration(minutes: 2))),
          ]),
        ],
      );

      expect(
        state.ticketsEnCola.first.items
            .map((i) => i.item.productoNombre)
            .toList(),
        ['viejo', 'medio', 'joven'],
      );
    });

    test('la urgencia del ticket la marca su item MÁS VIEJO', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 1, items: [
            plato(estado: EstadoPlato.enCola,
                enviadoAt: base.add(const Duration(minutes: 1))),
            plato(estado: EstadoPlato.enCola,
                enviadoAt: base.add(const Duration(minutes: 40))),
          ]),
        ],
      );

      final t = state.ticketsEnCola.first;
      expect(t.entradaEn, base.add(const Duration(minutes: 1)));
      expect(t.minutosEnCola, greaterThanOrEqualTo(39));
    });

    test('un ticket nunca enviado va al final', () {
      final state = ComandasState(
        isLoading: false,
        comandas: [
          comanda(id: 1, mesaNombre: 'sin-fecha', items: [
            plato(estado: EstadoPlato.listo, enviadoAt: null),
          ]),
          comanda(id: 2, mesaNombre: 'con-fecha', items: [
            plato(estado: EstadoPlato.enCola, enviadoAt: base),
          ]),
        ],
      );

      expect(
        state.ticketsEnCola.map((t) => t.comandaId).toList(),
        [2, 1],
      );
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 2 · ISAR REAL
  // ══════════════════════════════════════════════════════════════

  group('Fase A · pausa contra Isar', () {
    late String testDirPath;
    const localId = 1;

    setUp(() async {
      final tempDir = Directory.systemTemp.createTempSync('kds_pausa_');
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

    Future<int> crearComandaConItems(List<CartSessionItem> items) async {
      final isar = IsarService();
      final mesaId = await isar.guardarMesa(
        MesaEntity()
          ..localId = localId
          ..nombre = 'Mesa Isar'
          ..estado = MesaEstado.ocupada,
      );
      return isar.guardarComanda(
        CartSessionEntity()
          ..sessionId = 'mesa:$mesaId'
          ..nombre = 'Comanda Isar'
          ..usuarioId = 1
          ..mesaId = mesaId
          ..mesaNombre = 'Mesa Isar'
          ..comandaEstado = ComandaEstado.enviada
          ..items = items
          ..itemsNombres = items.map((i) => i.productoNombre).toList(),
      );
    }

    test('pausado/pausadoEn/motivoPausa sobreviven al round-trip',
        () async {
      final isar = IsarService();
      final id = await crearComandaConItems([
        plato(estado: EstadoPlato.enCola, enviadoAt: base),
      ]);

      final escrito = await isar.actualizarPausaItem(
        id,
        0,
        pausado: true,
        motivo: 'falta pescado',
      );
      expect(escrito, id);

      // Relee DESDE DISCO, no del objeto en memoria.
      final leida = await isar.obtenerComandaPorId(id);
      final item = leida!.items.first;

      expect(item.pausado, isTrue);
      expect(item.motivoPausa, 'falta pescado');
      expect(item.pausadoEn, isNotNull);
    });

    test('reanudar limpia los 3 campos', () async {
      final isar = IsarService();
      final id = await crearComandaConItems([
        plato(estado: EstadoPlato.enPreparacion,
            enviadoAt: base, pausado: true, motivoPausa: 'falta pescado'),
      ]);

      expect(await isar.actualizarPausaItem(id, 0, pausado: false), id);

      final item = (await isar.obtenerComandaPorId(id))!.items.first;
      expect(item.pausado, isFalse);
      expect(item.pausadoEn, isNull);
      expect(item.motivoPausa, isNull);
    });

    test('reanudar NO toca el estadoPlato', () async {
      // Eje ortogonales: pausar y avanzar. Un plato pausado en
      // preparación debe seguir en preparación al reanudarse.
      final isar = IsarService();
      final id = await crearComandaConItems([
        plato(estado: EstadoPlato.enPreparacion,
            enviadoAt: base, pausado: true, motivoPausa: 'x'),
      ]);

      await isar.actualizarPausaItem(id, 0, pausado: false);

      final item = (await isar.obtenerComandaPorId(id))!.items.first;
      expect(item.estadoPlato, EstadoPlato.enPreparacion);
    });

    test('pausar con motivo vacío lo guarda como null', () async {
      final isar = IsarService();
      final id = await crearComandaConItems([
        plato(estado: EstadoPlato.enCola, enviadoAt: base),
      ]);

      await isar.actualizarPausaItem(id, 0, pausado: true, motivo: '   ');

      final item = (await isar.obtenerComandaPorId(id))!.items.first;
      expect(item.pausado, isTrue);
      expect(item.motivoPausa, isNull);
    });

    test('pausar SIN motivo también es válido', () async {
      final isar = IsarService();
      final id = await crearComandaConItems([
        plato(estado: EstadoPlato.enCola, enviadoAt: base),
      ]);

      await isar.actualizarPausaItem(id, 0, pausado: true);

      final item = (await isar.obtenerComandaPorId(id))!.items.first;
      expect(item.pausado, isTrue);
      expect(item.motivoPausa, isNull);
    });

    test('un item nuevo nace SIN pausa', () async {
      final isar = IsarService();
      final id = await crearComandaConItems([
        plato(estado: EstadoPlato.enCola, enviadoAt: base),
      ]);

      final item = (await isar.obtenerComandaPorId(id))!.items.first;
      expect(item.pausado, isFalse);
      expect(item.pausadoEn, isNull);
      expect(item.motivoPausa, isNull);
    });

    test('actualizarPausaItem con índice fuera de rango = -1', () async {
      final isar = IsarService();
      final id = await crearComandaConItems([
        plato(estado: EstadoPlato.enCola, enviadoAt: base),
      ]);

      expect(
        await isar.actualizarPausaItem(id, 9, pausado: true),
        -1,
      );
      expect(
        await isar.actualizarPausaItem(999999, 0, pausado: true),
        -1,
      );
    });

    test('pausar no revierte el envío a la cola', () async {
      final isar = IsarService();
      final id = await crearComandaConItems([plato()]);

      await isar.marcarPendientesComoEnCola(id, base);
      await isar.actualizarPausaItem(id, 0, pausado: true, motivo: 'espera');

      final item = (await isar.obtenerComandaPorId(id))!.items.first;
      expect(item.estadoPlato, EstadoPlato.enCola);
      expect(item.enviadoACocinaAt, base);
      expect(item.pausado, isTrue);
    });

    test('un plato pausado sigue apareciendo en la cola del KDS', () async {
      // La pausa NO saca el plato de la cola: se sigue cocinando en el
      // sentido de que sigue pendiente de algo. Por eso
      // `estadosVisiblesEnKds` no mira `pausado`.
      final isar = IsarService();
      final id = await crearComandaConItems([plato()]);

      await isar.marcarPendientesComoEnCola(id, base);
      await isar.actualizarPausaItem(id, 0, pausado: true, motivo: 'espera');

      final items = await isar.obtenerComandasConItemsEnCola(localId);
      expect(items.length, 1);
      expect(items.first.items.length, 1);
      expect(items.first.items.first.pausado, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 3 · NOTIFIER END-TO-END
  //
  // Estas pruebas son las que cierran el hueco #2: verifican que
  // `pausarItem` / `reanudarItem` / `itemsEnColaPorEstacion` hacen lo que
  // prometen, y sobre todo que el `itemIndex` que llega desde
  // `ticketsEnCola` apunta al plato correcto.
  //
  // Usa `comandasProviderConIsar` + `ProviderScope`, para no montar
  // `localActualProvider`, `authProvider` ni `cartProvider`.
  // ══════════════════════════════════════════════════════════════

  group('Fase A · notifier end-to-end', () {
    late String testDirPath;

    setUp(() async {
      final tempDir = Directory.systemTemp.createTempSync('kds_notif_');
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

    /// Comanda de 4 items donde SOLO los visibles (índices 1 y 2) están
    /// en cola. Los índices 0 y 3 no deben poder pausarse.
    Future<int> crearComandaMixta() async {
      final isar = IsarService();
      final mesaId = await isar.guardarMesa(
        MesaEntity()
          ..localId = 1
          ..nombre = 'Mesa Mixta'
          ..estado = MesaEstado.ocupada,
      );

      final items = <CartSessionItem>[
        plato(nombre: 'oculto-0', estado: EstadoPlato.pendiente),
        plato(nombre: 'visible-1',
            estado: EstadoPlato.enCola, enviadoAt: base),
        plato(nombre: 'visible-2',
            estado: EstadoPlato.enCola, enviadoAt: base),
        plato(nombre: 'oculto-3', estado: EstadoPlato.entregado),
      ];

      return isar.guardarComanda(
        CartSessionEntity()
          ..sessionId = 'mesa:$mesaId'
          ..nombre = 'Comanda Mixta'
          ..usuarioId = 1
          ..mesaId = mesaId
          ..mesaNombre = 'Mesa Mixta'
          ..comandaEstado = ComandaEstado.enviada
          ..items = items
          ..itemsNombres = items.map((i) => i.productoNombre).toList(),
      );
    }

    /// Corre el cuerpo contra el notifier real, con Isar real detrás.
    ///
    /// ⚠️ El override de `localActualProvider` NO es opcional. Sin él,
    /// `LocalActualNotifier` arranca en `null` y lanza `cargarLocalActual()`
    /// sin esperar; `ComandasNotifier.cargar()` ve `localActualId == null` y
    /// corta, dejando `state.comandas` VACÍO. Los tests que solo llaman a
    /// `pausarItem` pasaban igual (leen por id contra Isar), pero los que
    /// leen `state.comandas` — `itemsEnColaPorEstacion`, `totalItemsEnKds`,
    /// `ticketsEnCola` — fallaban de forma intermitente según cuánto tardara
    /// la carga asíncrona.
    ///
    /// Fijando el estado a `1` en el propio factory se elimina la carrera:
    /// `cargar()` ve el valor de inmediato.
    Future<void> conNotifier(Future<void> Function(ComandasNotifier) cuerpo) {
      final container = ProviderContainer(
        overrides: [
          localActualProvider.overrideWith((ref) {
            final notifier = LocalActualNotifier(ref, isar: IsarService())
              ..state = 1;
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(comandasProviderConIsar.notifier);
      // El constructor dispara `cargar()` sin await. Sin esto, el assert
      // siguiente podría correr contra `state.comandas` todavía vacío, y
      // el `container.dispose()` del tearDown ocurriría con la carga en
      // vuelo.
      return notifier.esperarCargaInicial.then((_) => cuerpo(notifier));
    }

    test('pausarItem(comandaId, itemIndex) pausa el item correcto',
        () async {
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        // Índice 1 = "visible-1", tal como lo daría `ticketsEnCola`.
        final ok = await notifier.pausarItem(comandaId, 1, 'sin sal');
        expect(ok, isTrue);
      });

      final items = (await isar.obtenerComandaPorId(comandaId))!.items;

      expect(items[1].pausado, isTrue,
          reason: 'el índice 1 es el que se pidió pausar');
      expect(items[1].motivoPausa, 'sin sal');
      expect(items[1].pausadoEn, isNotNull);

      // Los otros tres intactos. Este es el test que caza el error de
      // "pausar por posición en la lista filtrada": si el notifier
      // reindexara, alguno de estos se habría pausado por error.
      expect(items[0].pausado, isFalse, reason: 'pendiente no se toca');
      expect(items[2].pausado, isFalse, reason: 'el #2 no se pidió');
      expect(items[3].pausado, isFalse, reason: 'entregado no se toca');
    });

    test('pausarItem marca los 3 campos y respeta el motivo', () async {
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        final ok = await notifier.pausarItem(comandaId, 2, 'falta pescado');
        expect(ok, isTrue);
      });

      final item = (await isar.obtenerComandaPorId(comandaId))!.items[2];
      expect(item.pausado, isTrue);
      expect(item.pausadoEn, isNotNull);
      expect(item.motivoPausa, 'falta pescado');
    });

    test('pausarItem RECHAZA un entregado', () async {
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        expect(await notifier.pausarItem(comandaId, 3, 'tarde'), isFalse,
            reason: 'un entregado no se pausa');
      });

      final item = (await isar.obtenerComandaPorId(comandaId))!.items[3];
      expect(item.pausado, isFalse);
    });

    test('pausarItem RECHAZA un pendiente', () async {
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        expect(await notifier.pausarItem(comandaId, 0, 'tarde'), isFalse,
            reason: 'aún no está en la barra');
      });
    });

    test('pausarItem con motivo largo lo recorta a 60', () async {
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        await notifier.pausarItem(comandaId, 1, 'x' * 200);
      });

      final motivo =
          (await isar.obtenerComandaPorId(comandaId))!.items[1].motivoPausa!;
      expect(motivo.length, 60);
    });

    test('reanudarItem limpia los 3 campos', () async {
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        expect(await notifier.pausarItem(comandaId, 1, 'sin sal'), isTrue);
        expect(await notifier.reanudarItem(comandaId, 1), isTrue);
      });

      final item = (await isar.obtenerComandaPorId(comandaId))!.items[1];
      expect(item.pausado, isFalse);
      expect(item.pausadoEn, isNull);
      expect(item.motivoPausa, isNull);
      // Y no toca el estado.
      expect(item.estadoPlato, EstadoPlato.enCola);
    });

    test('reanudarItem RECHAZA un item no pausado', () async {
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        expect(await notifier.reanudarItem(comandaId, 2), isFalse);
      });

      final item = (await isar.obtenerComandaPorId(comandaId))!.items[2];
      expect(item.pausado, isFalse);
    });

    test('itemsEnColaPorEstacion(excluirPausados) ignora los pausados',
        () async {
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        await notifier.pausarItem(comandaId, 1, 'sin sal');

        // Sin excluir: ambos visibles.
        expect(notifier.itemsEnColaPorEstacion(null).length, 2);

        // Excluyendo: solo el #2.
        final sinPausados =
            notifier.itemsEnColaPorEstacion(null, excluirPausados: true);
        expect(sinPausados.length, 1);
        expect(sinPausados.first.productoNombre, 'visible-2');
      });
    });

    test('itemsEnColaPorEstacion filtra por estación', () async {
      final isar = IsarService();
      final mesaId = await isar.guardarMesa(
        MesaEntity()
          ..localId = 1
          ..nombre = 'Mesa Est'
          ..estado = MesaEstado.ocupada,
      );

      await isar.guardarComanda(
        CartSessionEntity()
          ..sessionId = 'mesa:$mesaId'
          ..nombre = 'Comanda Est'
          ..usuarioId = 1
          ..mesaId = mesaId
          ..comandaEstado = ComandaEstado.enviada
          ..items = [
            plato(nombre: 'cocina',
                estacionId: 1,
                estado: EstadoPlato.enCola,
                enviadoAt: base),
            plato(nombre: 'barra',
                estacionId: 2,
                estado: EstadoPlato.enCola,
                enviadoAt: base),
            plato(nombre: 'sin-est',
                estado: EstadoPlato.enCola,
                enviadoAt: base),
          ],
      );

      await conNotifier((notifier) async {
        expect(notifier.itemsEnColaPorEstacion(1).length, 1);
        expect(notifier.itemsEnColaPorEstacion(1).first.productoNombre,
            'cocina');
        expect(notifier.itemsEnColaPorEstacion(2).first.productoNombre,
            'barra');
        expect(notifier.itemsEnColaPorEstacion(null).length, 3);
        expect(notifier.itemsEnColaPorEstacion(99).length, 0);
      });
    });

    test('totalItemsEnKds refleja la pausa tras una acción', () async {
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        expect(notifier.state.totalItemsEnKds, 2);

        await notifier.pausarItem(comandaId, 1, 'sin sal');
        expect(notifier.state.totalItemsEnKds, 1,
            reason: 'el pausado no cuenta para el badge');

        await notifier.reanudarItem(comandaId, 1);
        expect(notifier.state.totalItemsEnKds, 2);
      });
    });

    test('ticketsEnCola del notifier trae el itemIndex correcto', () async {
      await crearComandaMixta();

      await conNotifier((notifier) async {
        final tickets = notifier.state.ticketsEnCola;
        expect(tickets.length, 1);
        expect(tickets.first.items.map((i) => i.itemIndex).toList(), [1, 2]);
      });
    });

    test('avanzar un estado NO toca los demás items', () async {
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        expect(await notifier.marcarEnPreparacion(comandaId, 1), isTrue);
      });

      final items = (await isar.obtenerComandaPorId(comandaId))!.items;
      expect(items[1].estadoPlato, EstadoPlato.enPreparacion);
      expect(items[2].estadoPlato, EstadoPlato.enCola);
      expect(items[0].estadoPlato, EstadoPlato.pendiente);
      expect(items[3].estadoPlato, EstadoPlato.entregado);
    });

    test('avanzar un item pausado sigue funcionando (ejes ortogonales)',
        () async {
      // Pausar y avanzar son ejes independientes: un plato pausado en
      // preparación sigue avanzando si el estado lo permite. Lo que la
      // pausa bloquea son los BOTONES en la UI (PASO E), no la validación.
      final isar = IsarService();
      final comandaId = await crearComandaMixta();

      await conNotifier((notifier) async {
        await notifier.pausarItem(comandaId, 1, 'sin sal');
        expect(await notifier.marcarEnPreparacion(comandaId, 1), isTrue);

        final item = (await isar.obtenerComandaPorId(comandaId))!.items[1];
        expect(item.estadoPlato, EstadoPlato.enPreparacion);
        expect(item.pausado, isTrue);
      });
    });
  });
}
