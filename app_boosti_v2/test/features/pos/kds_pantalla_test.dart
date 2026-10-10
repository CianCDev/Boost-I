// test/features/pos/kds_pantalla_test.dart
//
// R.3.2 PASO E + E.3 · Pantalla de cocina, ticket, badge y onboarding.
//
// ══════════════════════════════════════════════════════════════════
// ⚠️ POR QUÉ NO HAY ISAR EN NINGÚN `testWidgets` DE ESTE ARCHIVO
//
// (Esta nota es el fix del cuelgue. Leer antes de tocar el archivo.)
//
// La versión anterior de este test hacía:
//
//   testWidgets('enCola ofrece Iniciar y Pausar', (tester) async {
//     final comandaId = await comandaEnIsar([...]);   // ← Isar real
//     await tester.pumpWidget(montar(...));            // ← nunca llegaba
//   });
//
// y la suite se quedaba colgada en ESE test (222 pasaban, 223 no
// terminaba nunca).
//
// La causa NO era el `Timer.periodic(30s)` de `KdsScreen`, que fue el
// primer sospechoso. `testWidgets` corre el cuerpo dentro de un
// `FakeAsync` que intercepta `Timer` y `scheduleMicrotask`. Isar resuelve
// sus consultas en un isolate real, y ese isolate entrega su respuesta a
// través del event loop REAL. `await isar.guardarComanda(...)` dentro de
// `FakeAsync` suspende la función asíncrona y devuelve el control… a un
// bucle que jamás vuelve al event loop real. Deadlock.
//
// Eso es exactamente para lo que existe `tester.runAsync()`, y explica
// por qué en este repo los tests con Isar real (`kds_fase_a_test.dart`,
// `comanda_edicion_test.dart`) son `test()` plano, nunca `testWidgets`.
//
// La solución NO fue `runAsync` sino quitar el Isar de los tests de
// widget, por dos razones:
//
//   1. Lo que la tarjeta tiene que decidir es "¿qué método del notifier
//      llamo y con qué índices?". `_NotificadorEspia` responde a eso sin
//      base de datos, y el test queda determinista.
//   2. Lo que los métodos del notifier hacen contra Isar YA está
//      cubierto en `kds_fase_a_test.dart` con `test()` plano e Isar real
//      (`pausarItem`, `reanudarItem`, `marcar*`). Los dos tests juntos
//      cubren la cadena; ninguno necesita repetir la parte del otro.
//
// ══════════════════════════════════════════════════════════════════
// LÍMITE DE COBERTURA HONESTO
//
//   · `_PausaItemDialog` y `ConfigurarEstacionesDialog` son públicos
//     (este último) / privados (el primero). El de pausa se prueba a
//     través del botón "Pausar" de la tarjeta.
//   · El `Timer.periodic(30s)` de `KdsScreen` sigue vivo al terminar los
//     tests de pantalla: se cancela en `cerrarPantalla`. Lo que NO se
//     prueba es que el repintado ocurra a los 30 s (exigiría esperar 30 s
//     reales).
//   · `sembrarEstaciones` se prueba con `escribir` inyectado, así que el
//     camino real contra `guardarDepartamentoProvider` (validación de
//     duplicados incluida) NO se cubre aquí.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/domain/permissions/roles.dart';
import 'package:app_boosti_v2/features/pos/presentation/config/menu_config.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/kds_ticket.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/restaurante/configurar_estaciones_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/restaurante/kds_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/restaurante/kds_ticket_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/filtro_chip_template.dart';

// ══════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════

final _base = DateTime(2026, 5, 1, 12);

CartSessionItem plato({
  String nombre = 'Plato',
  int? estacionId,
  EstadoPlato estado = EstadoPlato.enCola,
  bool pausado = false,
  String? nota,
}) {
  return CartSessionItem()
    ..productoId = nombre
    ..productoNombre = nombre
    ..productoCategoria = 'Platos'
    ..precioUnidad = 10.0
    ..cantidad = 1.0
    ..estacionId = estacionId
    ..estadoPlato = estado
    ..enviadoACocinaAt = _base
    ..pausado = pausado
    ..motivoPausa = pausado ? 'sin sal' : null
    ..pausadoEn = pausado ? _base : null
    ..nota = nota;
}

KdsTicketItem itemTicket({
  required int comandaId,
  required int index,
  String nombre = 'Plato',
  EstadoPlato estado = EstadoPlato.enCola,
  bool pausado = false,
  int? estacionId,
  String? nota,
}) {
  return KdsTicketItem(
    comandaId: comandaId,
    itemIndex: index,
    item: plato(
      nombre: nombre,
      estado: estado,
      pausado: pausado,
      estacionId: estacionId,
      nota: nota,
    ),
  );
}

KdsTicket ticketDe(
  List<KdsTicketItem> items, {
  String mesa = 'Mesa 1',
  int comandaId = 1,
}) {
  return KdsTicket(
    comandaId: comandaId,
    mesaId: 1,
    mesaNombre: mesa,
    items: items,
    pausados: items.where((i) => i.item.pausado).length,
  );
}

CartSessionEntity comandaDe(List<CartSessionItem> items, {int id = 1}) {
  return CartSessionEntity()
    ..id = id
    ..sessionId = 'mesa:$id'
    ..nombre = 'Comanda $id'
    ..usuarioId = 1
    ..mesaId = 1
    ..mesaNombre = 'Mesa 1'
    ..comandaEstado = ComandaEstado.enviada
    ..items = items
    ..itemsNombres = items.map((i) => i.productoNombre).toList();
}

DepartamentoEntity depto(String nombre, {int id = 1, int orden = 0}) {
  return DepartamentoEntity()
    ..id = id
    ..nombre = nombre
    ..localId = 1
    ..orden = orden
    ..activo = true;
}

/// Notifier que registra qué método se llamó, sin tocar Isar.
///
/// ⚠️ `cargar()` se anula a propósito. El constructor base la dispara
/// (comanda_provider.dart:243) y, con `localActualId` a 1, iría a
/// `obtenerComandasDeLocal`: una lectura real de Isar dentro del
/// `FakeAsync` de `testWidgets`, que es justo el deadlock de la nota de
/// cabecera. Anulándola, el estado queda exactamente como lo siembre el
/// test.
///
/// Es legal sobrescribir un método llamado desde el constructor base
/// porque el cuerpo del override no toca campos de la subclase: los
/// inicializadores de campo corren DESPUÉS de `super()`, y este método se
/// llama durante `super()`.
class _NotificadorEspia extends ComandasNotifier {
  _NotificadorEspia(super.ref) : super(isar: IsarService());

  final List<String> llamadas = [];

  @override
  Future<void> cargar() async {}

  @override
  Future<bool> marcarEnPreparacion(int comandaId, int itemIndex) async {
    llamadas.add('enPreparacion:$comandaId:$itemIndex');
    return true;
  }

  @override
  Future<bool> marcarListo(int comandaId, int itemIndex) async {
    llamadas.add('listo:$comandaId:$itemIndex');
    return true;
  }

  @override
  Future<bool> marcarEntregado(int comandaId, int itemIndex) async {
    llamadas.add('entregado:$comandaId:$itemIndex');
    return true;
  }

  @override
  Future<bool> pausarItem(
    int comandaId,
    int itemIndex,
    String? motivo,
  ) async {
    llamadas.add('pausar:$comandaId:$itemIndex:$motivo');
    return true;
  }

  @override
  Future<bool> reanudarItem(int comandaId, int itemIndex) async {
    llamadas.add('reanudar:$comandaId:$itemIndex');
    return true;
  }
}

/// `localActualProvider` fijado a 1, sin efectos secundarios.
///
/// ⚠️ `overrideWith` debe devolver un `LocalActualNotifier`, NO un `int`:
/// es un `StateNotifierProvider`. Y no hace falta espiar nada aquí, porque
/// `LocalActualNotifier` (local_actual_provider.dart:39) no dispara nada en
/// su constructor — la llamada a `cargarLocalActual()` vive en el factory de
/// la línea 262, no en el constructor. Por eso se puede instanciar a mano
/// sin arriesgar un `SharedPreferences.getInstance()` colgado dentro del
/// `FakeAsync`.
LocalActualNotifier localActivoEn(Ref ref) {
  return LocalActualNotifier(ref, isar: IsarService())..state = 1;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const claves = <String>{'offline', 'reports'};

  FeatureFlags flags(BusinessMode modo) => FeatureFlags(
        mode: modo,
        planActivo: true,
        planId: 'basico',
        featuresHabilitadas: claves,
      );

  // ══════════════════════════════════════════════════════════════
  // 1 · PURO · Badge y gate del menú
  // ══════════════════════════════════════════════════════════════

  group('PASO E · badge y gate de la opción Estaciones', () {
    MenuOption? opcion(List<MenuSection> secciones, String id) {
      for (final s in secciones) {
        for (final o in s.options) {
          if (o.id == id) return o;
        }
      }
      return null;
    }

    /// `buildSections` NO es puro: toma un `BuildContext` para los
    /// `Navigator.push` de cada `onTap`. Los closures nunca se ejecutan,
    /// así que basta un contexto de un árbol mínimo real: inventarse un
    /// `BuildContext` a mano no es posible.
    List<MenuSection> construir(BuildContext context, {int? kdsBadge}) {
      return MenuBuilder.buildSections(
        usuario: UsuarioEntity()..rol = 'admin',
        context: context,
        flags: flags(BusinessMode.restaurante),
        onCrearBackup: () async {},
        onSincronizar: () async {},
        ventasPendientesSync: 0,
        kdsBadge: kdsBadge,
      );
    }

    Future<BuildContext> contextoDe(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      return tester.element(find.byType(Scaffold));
    }

    testWidgets('la opción "kds" existe y se titula Estaciones',
        (tester) async {
      final secciones = construir(await contextoDe(tester));
      final kds = opcion(secciones, 'kds');

      expect(kds, isNotNull, reason: 'la opción Estaciones debe existir');
      expect(kds!.title, 'Estaciones');
      expect(kds.subtitle, 'Áreas de preparación');
      expect(kds.icon, Icons.soup_kitchen_rounded);
    });

    testWidgets('kdsBadge llega a MenuOption.badge', (tester) async {
      final secciones = construir(await contextoDe(tester), kdsBadge: 7);
      expect(opcion(secciones, 'kds')!.badge, 7);
    });

    testWidgets('sin kdsBadge el badge es null (no un 0)', (tester) async {
      final secciones = construir(await contextoDe(tester));
      expect(opcion(secciones, 'kds')!.badge, isNull);
    });

    testWidgets('el badge va en rojo, no en el verde de la opción',
        (tester) async {
      final secciones = construir(await contextoDe(tester), kdsBadge: 3);
      final kds = opcion(secciones, 'kds')!;

      expect(kds.badgeColor, isNotNull);
      expect(kds.badgeColor, isNot(kds.color));
      expect(kds.color, const Color(0xFF10B981));
    });

    testWidgets('las demás opciones siguen sin badge', (tester) async {
      final secciones = construir(await contextoDe(tester), kdsBadge: 7);
      final conBadge = <String>[];
      for (final s in secciones) {
        for (final o in s.options) {
          if (o.badge != null) conBadge.add(o.id);
        }
      }
      expect(conBadge, ['kds'],
          reason: 'solo la opción de cocina lleva contador');
    });

    test('"kds" se ve en restaurante y NO en retail', () {
      expect(
        MenuBuilder.puedeVerOpcion(
          UserRole.admin,
          'kds',
          flags(BusinessMode.restaurante),
        ),
        isTrue,
      );
      expect(
        MenuBuilder.puedeVerOpcion(
          UserRole.admin,
          'kds',
          flags(BusinessMode.retail),
        ),
        isFalse,
        reason: 'en retail no hay comandas por mesa que mostrar',
      );
    });

    test('los roles sin acceso al POS no ven la cocina', () {
      for (final rol in [UserRole.rrhh, UserRole.almacen, UserRole.dev]) {
        expect(
          MenuBuilder.puedeVerOpcion(
            rol,
            'kds',
            flags(BusinessMode.restaurante),
          ),
          isFalse,
          reason: '$rol no entra al POS, así que no entra a la cocina',
        );
      }
    });

    test('cajero sí ve la cocina: es parte del POS', () {
      expect(
        MenuBuilder.puedeVerOpcion(
          UserRole.cajero,
          'kds',
          flags(BusinessMode.restaurante),
        ),
        isTrue,
      );
    });

    testWidgets('"Estaciones" cuelga de OPERACIÓN, tras el Salón',
        (tester) async {
      final secciones = construir(await contextoDe(tester));
      final operacion =
          secciones.firstWhere((s) => s.title == 'OPERACIÓN');
      final ids = operacion.options.map((o) => o.id).toList();

      expect(ids, contains('mesas'));
      expect(ids.indexOf('kds'), lessThan(ids.indexOf('ventas_mayor')));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 2 · WIDGET · KdsTicketCard (sin Isar)
  // ══════════════════════════════════════════════════════════════

  group('PASO E · KdsTicketCard', () {
    late _NotificadorEspia espia;

    Widget montar(Widget hijo) {
      return ProviderScope(
        overrides: [
          localActualProvider.overrideWith(localActivoEn),
          comandasProvider.overrideWith((ref) {
            espia = _NotificadorEspia(ref);
            return espia;
          }),
        ],
        child: MaterialApp(home: Scaffold(body: hijo)),
      );
    }

    Widget tarjeta(KdsTicket ticket) {
      return KdsTicketCard(ticket: ticket, ahora: _base);
    }

    // ── Qué botones hay según el estado ──

    testWidgets('enCola ofrece Iniciar y Pausar, y no Listo',
        (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0),
      ]))));

      expect(find.text('Iniciar'), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);
      expect(find.text('Listo'), findsNothing);
      expect(find.text('Entregado'), findsNothing);
      expect(find.text('Reanudar'), findsNothing);
    });

    testWidgets('enPreparacion ofrece Listo y Pausar, no Iniciar',
        (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0, estado: EstadoPlato.enPreparacion),
      ]))));

      expect(find.text('Listo'), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);
      expect(find.text('Iniciar'), findsNothing);
    });

    testWidgets('listo ofrece solo Entregado', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0, estado: EstadoPlato.listo),
      ]))));

      expect(find.text('Entregado'), findsOneWidget);
      expect(find.text('Listo'), findsNothing);
      expect(find.text('Iniciar'), findsNothing);
    });

    testWidgets('un plato pausado ofrece solo Reanudar', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0, pausado: true),
      ]))));

      expect(find.text('Reanudar'), findsOneWidget);
      expect(find.text('Iniciar'), findsNothing);
      expect(find.text('Pausar'), findsNothing);
      expect(find.text('Listo'), findsNothing);
    });

    // ── A qué método llama cada botón ──

    testWidgets('Iniciar llama marcarEnPreparacion con el índice real',
        (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 7, index: 3),
      ]))));

      await tester.tap(find.text('Iniciar'));
      await tester.pumpAndSettle();

      expect(espia.llamadas, ['enPreparacion:7:3']);
    });

    testWidgets('Listo llama marcarListo', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(
          comandaId: 7,
          index: 3,
          estado: EstadoPlato.enPreparacion,
        ),
      ]))));

      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();

      expect(espia.llamadas, ['listo:7:3']);
    });

    testWidgets('Entregado llama marcarEntregado', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 7, index: 3, estado: EstadoPlato.listo),
      ]))));

      await tester.tap(find.text('Entregado'));
      await tester.pumpAndSettle();

      expect(espia.llamadas, ['entregado:7:3']);
    });

    testWidgets('Reanudar llama reanudarItem', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 7, index: 3, pausado: true),
      ]))));

      await tester.tap(find.text('Reanudar'));
      await tester.pumpAndSettle();

      expect(espia.llamadas, ['reanudar:7:3']);
    });

    testWidgets('el índice es el REAL, no la posición entre visibles',
        (tester) async {
      // Índices 0 y 2 visibles; el 1 es `pendiente` y no se pinta.
      // Si la tarjeta usara la posición filtrada (0 y 1), el botón del
      // segundo plato avanzaría el plato INDICE 1, que no está en cocina.
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 7, index: 0, nombre: 'Arroz'),
        itemTicket(
          comandaId: 7,
          index: 1,
          nombre: 'Oculto',
          estado: EstadoPlato.pendiente,
        ),
        itemTicket(comandaId: 7, index: 2, nombre: 'Sopa'),
      ]))));

      expect(find.text('Arroz'), findsOneWidget);
      expect(find.text('Oculto'), findsNothing);
      expect(find.text('Sopa'), findsOneWidget);

      final botones = find.text('Iniciar');
      expect(botones, findsNWidgets(2));

      await tester.tap(botones.last);
      await tester.pumpAndSettle();

      expect(espia.llamadas, ['enPreparacion:7:2'],
          reason: 'el segundo plato visible es el índice real 2');
    });

    // ── Diálogo de pausa ──

    testWidgets('Pausar abre el diálogo y cancelar NO pausa', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 7, index: 3),
      ]))));

      await tester.tap(find.text('Pausar'));
      await tester.pumpAndSettle();

      expect(find.text('Pausar el plato'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Pausar el plato'), findsNothing);
      expect(espia.llamadas, isEmpty,
          reason: 'cancelar no debe llamar a pausarItem');
    });

    testWidgets('Pausar con motivo lo envía a pausarItem', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 7, index: 3),
      ]))));

      await tester.tap(find.text('Pausar'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'falta pescado');
      await tester.tap(find.widgetWithText(FilledButton, 'Pausar'));
      await tester.pumpAndSettle();

      expect(find.text('Pausar el plato'), findsNothing);
      expect(espia.llamadas, ['pausar:7:3:falta pescado']);
    });

    testWidgets('pausar sin motivo lo envía vacío, no null', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 7, index: 3),
      ]))));

      await tester.tap(find.text('Pausar'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Pausar'));
      await tester.pumpAndSettle();

      // Vacío (""), no `null`: `null` significa "canceló" en este
      // diálogo, así que mandarlo a `pausarItem` pausaría sin avisar.
      expect(espia.llamadas, ['pausar:7:3:']);
    });

    // ── Cabecera y notas ──

    testWidgets('la cabecera muestra mesa y número de platos',
        (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0, nombre: 'Arroz'),
        itemTicket(comandaId: 1, index: 1, nombre: 'Sopa'),
      ], mesa: 'Mesa 7'))));

      expect(find.text('Mesa 7'), findsOneWidget);
      expect(find.text('2 platos'), findsOneWidget);
      expect(find.text('Arroz'), findsOneWidget);
      expect(find.text('Sopa'), findsOneWidget);
    });

    testWidgets('un solo plato dice "1 plato" en singular', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0),
      ]))));

      expect(find.text('1 plato'), findsOneWidget);
    });

    testWidgets('avisa de los platos pausados en la cabecera',
        (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0, nombre: 'Arroz'),
        itemTicket(comandaId: 1, index: 1, pausado: true),
      ]))));

      expect(find.text('1 pausado'), findsOneWidget);
    });

    testWidgets('una comanda sin mesa se lee "Para llevar"', (tester) async {
      await tester.pumpWidget(montar(KdsTicketCard(
        ticket: KdsTicket(
          comandaId: 1,
          mesaId: null,
          mesaNombre: 'Para llevar',
          items: [itemTicket(comandaId: 1, index: 0)],
          pausados: 0,
        ),
        ahora: _base,
      )));

      expect(find.text('Para llevar'), findsOneWidget);
    });

    testWidgets('pinta la nota del plato', (tester) async {
      await tester.pumpWidget(montar(tarjeta(ticketDe([
        itemTicket(comandaId: 1, index: 0, nota: 'sin cebolla'),
      ]))));

      expect(find.text('sin cebolla'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 3 · WIDGET · KdsScreen (sin Isar)
  // ══════════════════════════════════════════════════════════════

  group('PASO E · KdsScreen', () {
    late _NotificadorEspia espia;

    /// Monta la pantalla con el estado que se le pase.
    ///
    /// ⚠️ `departamentosActivosProvider` va SOBREESCRITO porque es un
    /// `FutureProvider` que consulta Isar. Igual que `cargar()`, dentro
    /// del `FakeAsync` de `testWidgets` su `Future` nunca se resolvería y
    /// la pantalla se quedaría en el spinner de carga para siempre.
    Future<void> abrir(
      WidgetTester tester, {
      List<CartSessionEntity> comandas = const [],
      List<DepartamentoEntity> departamentos = const [],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localActualProvider.overrideWith(localActivoEn),
            comandasProvider.overrideWith((ref) {
              espia = _NotificadorEspia(ref)
                ..state = ComandasState(
                  comandas: comandas,
                  isLoading: false,
                );
              return espia;
            }),
            departamentosActivosProvider(1).overrideWith(
              (ref) async => departamentos,
            ),
          ],
          child: const MaterialApp(home: KdsScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// ⚠️ CIERRE OBLIGATORIO de todo test que abra `KdsScreen`.
    ///
    /// La pantalla arranca un `Timer.periodic(30s)` en `initState`. Montar
    /// un árbol vacío fuerza el `dispose()`, que es quien hace
    /// `_timer?.cancel()`. Sin esto `flutter_test` falla con
    /// "A Timer is still pending".
    Future<void> cerrar(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }

    testWidgets('sin comandas muestra el empty state', (tester) async {
      await abrir(tester, departamentos: [depto('Cocina')]);

      expect(find.text('No hay pedidos en cola'), findsOneWidget);
      expect(find.text('Configurar estaciones'), findsNothing);

      await cerrar(tester);
    });

    testWidgets('renderiza el ticket en cola con sus botones',
        (tester) async {
      await abrir(
        tester,
        departamentos: [depto('Cocina')],
        comandas: [comandaDe([plato(nombre: 'Bandeja')])],
      );

      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('Bandeja'), findsOneWidget);
      expect(find.text('Iniciar'), findsOneWidget);
      expect(find.text('No hay pedidos en cola'), findsNothing);

      await cerrar(tester);
    });

    testWidgets('el botón del ticket llega al notifier', (tester) async {
      await abrir(
        tester,
        departamentos: [depto('Cocina')],
        comandas: [comandaDe([plato(nombre: 'Bandeja')])],
      );

      await tester.tap(find.text('Iniciar'));
      await tester.pumpAndSettle();

      expect(espia.llamadas, ['enPreparacion:1:0']);

      await cerrar(tester);
    });

    testWidgets('excluye del KDS lo que ya no está en cocina',
        (tester) async {
      await abrir(
        tester,
        departamentos: [depto('Cocina')],
        comandas: [comandaDe([
          plato(nombre: 'Visible'),
          plato(nombre: 'YaServido', estado: EstadoPlato.entregado),
          plato(nombre: 'NiEnviado', estado: EstadoPlato.pendiente),
        ])],
      );

      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('YaServido'), findsNothing);
      expect(find.text('NiEnviado'), findsNothing);

      await cerrar(tester);
    });

    testWidgets('el selector filtra por estación', (tester) async {
      await abrir(
        tester,
        departamentos: [depto('Cocina', id: 1), depto('Barra', id: 2,
            orden: 1)],
        comandas: [
          comandaDe([
            plato(nombre: 'Arroz', estacionId: 1),
            plato(nombre: 'Cerveza', estacionId: 2),
          ]),
        ],
      );

      expect(find.text('Arroz'), findsOneWidget);
      expect(find.text('Cerveza'), findsOneWidget);

      await tester.tap(find.text('Barra'));
      await tester.pumpAndSettle();

      expect(find.text('Cerveza'), findsOneWidget);
      expect(find.text('Arroz'), findsNothing,
          reason: 'el filtro recorta el ticket, no solo lo oculta');

      await cerrar(tester);
    });

    testWidgets('"Sin estación" aparece si hay platos sin clasificar',
        (tester) async {
      await abrir(
        tester,
        departamentos: [depto('Cocina')],
        comandas: [comandaDe([plato(nombre: 'Arroz')])],
      );

      expect(find.text('Sin estación'), findsOneWidget);

      await cerrar(tester);
    });

    testWidgets('"Sin estación" NO aparece si todo está clasificado',
        (tester) async {
      await abrir(
        tester,
        departamentos: [depto('Cocina')],
        comandas: [comandaDe([plato(nombre: 'Arroz', estacionId: 1)])],
      );

      expect(find.text('Sin estación'), findsNothing);

      await cerrar(tester);
    });

    testWidgets('una estación sin platos no genera chip', (tester) async {
      // El selector solo muestra estaciones con platos en cola. El caso
      // "filtrar por una estación que se quedó vacía" no es alcanzable
      // desde la UI justamente por esto, que es lo correcto.
      await abrir(
        tester,
        departamentos: [depto('Cocina', id: 1), depto('Barra', id: 2,
            orden: 1)],
        comandas: [comandaDe([plato(nombre: 'Cerveza', estacionId: 2)])],
      );

      // ⚠️ El finder va POR TIPO, no `find.text('Cocina')`.
      //
      // 'Cocina' aquí es el NOMBRE DE LA ESTACIÓN, no la pantalla: el
      // `CustomAppBar` se titula 'Estaciones' desde el rename. Aun así el
      // finder sigue siendo POR TIPO a propósito: acota al `FiltroChip` y
      // expresa la intención real ("no hay un chip de estación Cocina") en
      // vez de depender de que no haya ningún otro texto 'Cocina' en árbol.
      expect(
        find.widgetWithText(FiltroChip, 'Cocina'),
        findsNothing,
        reason: 'Cocina no tiene platos, así que no debe generar chip',
      );

      // Y el selector NO se ha vaciado por error: Barra sí tiene platos.
      expect(find.widgetWithText(FiltroChip, 'Barra'), findsOneWidget);
      expect(find.widgetWithText(FiltroChip, 'Todas'), findsOneWidget);

      await cerrar(tester);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 4 · PASO E.3 · Onboarding de estaciones
  // ══════════════════════════════════════════════════════════════

  group('PASO E.3 · construirEstacionesIniciales', () {
    test('crea 3 estaciones con orden 0, 1 y 2', () {
      final lista = construirEstacionesIniciales(
        kEstacionesIniciales,
        localId: 7,
      );

      expect(lista.map((d) => d.nombre), ['Cocina', 'Barra', 'Postres']);
      expect(lista.map((d) => d.orden), [0, 1, 2]);
      expect(lista.every((d) => d.localId == 7), isTrue);
      expect(lista.every((d) => d.activo), isTrue);
    });

    test('respeta el orden de la lista, no el alfabético', () {
      final lista = construirEstacionesIniciales(
        ['Postres', 'Cocina', 'Barra'],
        localId: 1,
      );

      expect(lista.map((d) => d.nombre), ['Postres', 'Cocina', 'Barra']);
      expect(lista.map((d) => d.orden), [0, 1, 2]);
    });

    test('una lista vacía no crea nada', () {
      expect(construirEstacionesIniciales([], localId: 1), isEmpty);
    });
  });

  group('PASO E.3 · diálogo de estaciones', () {
    /// Lanza el diálogo y devuelve lo que el usuario "eligió".
    ///
    /// [desmarcar] son las estaciones que el test desmarca antes de
    /// confirmar. Vacío = confirma tal cual.
    Future<List<String>?> abrirYDarOk(
      WidgetTester tester, {
      List<String> desmarcar = const [],
    }) async {
      List<String>? resultado;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    resultado = await ConfigurarEstacionesDialog.mostrar(
                      context,
                    );
                  },
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Configurar estaciones de cocina'), findsOneWidget);

      for (final nombre in desmarcar) {
        // ⚠️ Sin `const`: la interpolación de `$nombre` dentro de un
        // `const` no compila.
        await tester.tap(find.byKey(ValueKey('estacion-$nombre')));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      return resultado;
    }

    testWidgets('viene con las 3 marcadas por defecto', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ConfigurarEstacionesDialog()),
      );
      await tester.pumpAndSettle();

      for (final nombre in kEstacionesIniciales) {
        final tile = tester.widget<CheckboxListTile>(
          find.byKey(ValueKey('estacion-$nombre')),
        );
        expect(tile.value, isTrue, reason: '$nombre debe venir marcada');
      }
    });

    testWidgets('3 marcadas -> 3 estaciones', (tester) async {
      final resultado = await abrirYDarOk(tester);

      expect(resultado, ['Cocina', 'Barra', 'Postres']);
    });

    testWidgets('desmarcar Barra -> 2 estaciones', (tester) async {
      final resultado = await abrirYDarOk(tester, desmarcar: ['Barra']);

      expect(resultado, ['Cocina', 'Postres']);
      expect(resultado, isNot(contains('Barra')));
    });

    testWidgets('desmarcar las 3 -> lista vacía, no null', (tester) async {
      final resultado = await abrirYDarOk(
        tester,
        desmarcar: kEstacionesIniciales,
      );

      // Vacío = "acepté pero no marqué nada": el diálogo cierra y no se
      // crea nada. `null` = cancelé. Confundirlos dejaría el diálogo
      // abierto o avisaría de un éxito que no hubo.
      expect(resultado, isNotNull);
      expect(resultado, isEmpty);
    });

    testWidgets('desmarcar y volver a marcar restituye', (tester) async {
      List<String>? resultado;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  resultado = await ConfigurarEstacionesDialog.mostrar(
                    context,
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('estacion-Cocina')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('estacion-Cocina')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(resultado, ['Cocina', 'Barra', 'Postres']);
    });

    testWidgets('Cancelar devuelve null', (tester) async {
      List<String>? resultado;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  resultado = await ConfigurarEstacionesDialog.mostrar(
                    context,
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(resultado, isNull);
      expect(find.text('Configurar estaciones de cocina'), findsNothing);
    });
  });

  group('PASO E.3 · sembrarEstaciones', () {
    /// Saca un `WidgetRef` de un árbol mínimo.
    ///
    /// `sembrarEstaciones` es una función suelta (no un widget), pero
    /// necesita un `WidgetRef`. Se obtiene montando un `Consumer` que lo
    /// publica.
    Future<WidgetRef> refDe(WidgetTester tester) async {
      late WidgetRef ref;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, r, _) {
              ref = r;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      return ref;
    }

    testWidgets('3 nombres -> 3 escrituras con orden 0/1/2',
        (tester) async {
      final ref = await refDe(tester);
      final escritas = <DepartamentoEntity>[];

      final r = await sembrarEstaciones(
        ref,
        localId: 1,
        nombres: kEstacionesIniciales,
        escribir: (d) async => escritas.add(d),
      );

      expect(r.creadas, 3);
      expect(r.completo, isTrue);
      expect(escritas.map((d) => d.nombre),
          ['Cocina', 'Barra', 'Postres']);
      expect(escritas.map((d) => d.orden), [0, 1, 2]);
      expect(escritas.every((d) => d.activo && d.localId == 1), isTrue);
    });

    testWidgets('sin nombres -> 0 escrituras, sin error', (tester) async {
      final ref = await refDe(tester);
      final escritas = <DepartamentoEntity>[];

      final r = await sembrarEstaciones(
        ref,
        localId: 1,
        nombres: const [],
        escribir: (d) async => escritas.add(d),
      );

      expect(r.creadas, 0);
      expect(r.completo, isTrue);
      expect(escritas, isEmpty);
    });

    testWidgets('un fallo no aborta el resto', (tester) async {
      final ref = await refDe(tester);
      final escritas = <String>[];

      final r = await sembrarEstaciones(
        ref,
        localId: 1,
        nombres: kEstacionesIniciales,
        escribir: (d) async {
          if (d.nombre == 'Barra') throw Exception('Ya existe');
          escritas.add(d.nombre);
        },
      );

      // La clave: un duplicado en Barra no puede dejar Cocina y Postres
      // sin crear, que es lo que pasaría con un `return` temprano.
      expect(escritas, ['Cocina', 'Postres']);
      expect(r.creadas, 2);
      expect(r.completo, isFalse);
      expect(r.fallos.single, contains('Barra'));
      expect(r.fallos.single, isNot(contains('Exception:')),
          reason: 'el prefijo hay que quitarlo antes de mostrarlo');
    });
  });

  group('PASO E.3 · el botón solo aparece con 0 estaciones', () {
    late _NotificadorEspia espia;

    Future<void> abrir(
      WidgetTester tester, {
      required List<DepartamentoEntity> departamentos,
      List<CartSessionEntity> comandas = const [],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localActualProvider.overrideWith(localActivoEn),
            comandasProvider.overrideWith((ref) {
              espia = _NotificadorEspia(ref)
                ..state = ComandasState(
                  comandas: comandas,
                  isLoading: false,
                );
              return espia;
            }),
            departamentosActivosProvider(1).overrideWith(
              (ref) async => departamentos,
            ),
          ],
          child: const MaterialApp(home: KdsScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> cerrar(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }

    testWidgets('con estaciones NO aparece', (tester) async {
      await abrir(tester, departamentos: [depto('Cocina')]);

      expect(find.byKey(const Key('btn-configurar-estaciones')),
          findsNothing);

      await cerrar(tester);
    });

    testWidgets('sin estaciones y sin pedidos, aparece el botón grande',
        (tester) async {
      await abrir(tester, departamentos: const []);

      expect(find.text('Este local no tiene estaciones'), findsOneWidget);
      expect(find.byKey(const Key('btn-configurar-estaciones')),
          findsOneWidget);

      await cerrar(tester);
    });

    testWidgets('sin estaciones pero CON pedidos, aparece la barra',
        (tester) async {
      await abrir(
        tester,
        departamentos: const [],
        comandas: [comandaDe([plato(nombre: 'Bandeja')])],
      );

      // El botón sigue estando, pero los pedidos NO se tapan: el
      // cocinero tiene que poder trabajar mientras da de alta las
      // estaciones.
      expect(find.byKey(const Key('btn-configurar-estaciones')),
          findsOneWidget);
      expect(find.text('Bandeja'), findsOneWidget);
      expect(find.text('Este local no tiene estaciones'), findsNothing);

      await cerrar(tester);
    });
  });
}
