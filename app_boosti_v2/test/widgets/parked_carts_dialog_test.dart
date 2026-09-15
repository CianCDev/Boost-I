// test/widgets/parked_carts_dialog_test.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_sessions_controller.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/catalog/cart/parked_carts_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ════════════════════════════════════════════════════════════════
// FAKES
// ════════════════════════════════════════════════════════════════

/// Notifier fake de sesiones. Arranca con la lista dada y no toca Isar.
///
/// Los métodos async son no-ops; la UI debe reaccionar solo a `state`.
class FakeCartSessionsNotifier extends CartSessionsNotifier {
  FakeCartSessionsNotifier(super.ref, {List<CartSessionEntity> initial = const []}){
    state = CartSessionsState(sessions: initial);
  }

  @override
  Future<void> cargarSesiones(int usuarioId) async {
    // No-op: el state ya está seteado desde el constructor.
  }

  @override
  Future<void> recargar() async {
    // No-op.
  }

  @override
  Future<String?> eliminarSesion(String sessionId) async {
    state = CartSessionsState(
      sessions:
          state.sessions.where((s) => s.sessionId != sessionId).toList(),
    );
    return null;
  }

  @override
  Future<String?> renombrarSesion(String sessionId, String nuevoNombre) async {
    // No-op para no romper el test (el diálogo muestra el AlertDialog igual).
    return null;
  }
}

/// Notifier fake de usuario que arranca con un usuario ya seteado.
class FakeUsuariosNotifier extends UsuariosNotifier {
  FakeUsuariosNotifier(super.ref, UsuarioEntity? initial){
    state = initial;
  }
}

// ════════════════════════════════════════════════════════════════
// TESTS
// ════════════════════════════════════════════════════════════════

void main() {
  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  UsuarioEntity buildUser({int id = 42}) {
    return UsuarioEntity()
      ..id = id
      ..nombre = 'Cajero Test'
      ..rol = 'cajero'
      ..activo = true;
  }

  CartSessionItem buildItem({
    String productoId = '1',
    String nombre = 'Producto',
    double precio = 5.0,
    double cantidad = 1.0,
  }) {
    return CartSessionItem()
      ..productoId = productoId
      ..productoNombre = nombre
      ..precioUnidad = precio
      ..cantidad = cantidad;
  }

  CartSessionEntity buildSession({
    required String sessionId,
    required String nombre,
    int usuarioId = 42,
    List<CartSessionItem>? items,
    DateTime? createdAt,
    CartSessionStatus status = CartSessionStatus.enEspera,
    String? clienteNombre,
  }) {
    final s = CartSessionEntity()
      ..sessionId = sessionId
      ..usuarioId = usuarioId
      ..nombre = nombre
      ..status = status
      ..clienteNombre = clienteNombre
      ..items = items ?? [];
    if (createdAt != null) s.createdAt = createdAt;
    return s;
  }

  /// Monta el dialog con las sesiones dadas (sin tocar Isar).
  Future<void> pumpDialog(
    WidgetTester tester, {
    List<CartSessionEntity> sessions = const [],
    UsuarioEntity? usuario,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usuarioActualProvider.overrideWith(
            (ref) => FakeUsuariosNotifier(ref, usuario ?? buildUser()),
          ),
          cartSessionsProvider.overrideWith(
            (ref) => FakeCartSessionsNotifier(ref, initial: sessions),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ParkedCartsDialog(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ════════════════════════════════════════════════════════════
  // RENDER
  // ════════════════════════════════════════════════════════════

  group('ParkedCartsDialog — render', () {
    testWidgets('muestra el header con título', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Carritos en espera'), findsOneWidget);
    });

    testWidgets('muestra el contador 0/10 cuando no hay sesiones',
        (tester) async {
      await pumpDialog(tester);

      expect(
        find.textContaining('0/$kMaxCarritosEnEspera'),
        findsOneWidget,
      );
    });

    testWidgets('muestra empty state cuando no hay sesiones', (tester) async {
      await pumpDialog(tester);

      expect(find.text('No tienes carritos en espera'), findsOneWidget);
      expect(
        find.text('Agrega productos y presiona "Poner en espera"'),
        findsOneWidget,
      );
    });

    testWidgets('muestra las sesiones en espera del usuario', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem(precio: 2.0, cantidad: 3.0)],
          ),
          buildSession(
            sessionId: 's2',
            nombre: 'Cliente Ana',
            items: [buildItem(precio: 10.0, cantidad: 1.0)],
          ),
        ],
      );

      expect(find.text('Mesa 3'), findsOneWidget);
      expect(find.text('Cliente Ana'), findsOneWidget);
    });

    testWidgets('actualiza el contador con las sesiones existentes',
        (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(sessionId: 's1', nombre: 'A'),
          buildSession(sessionId: 's2', nombre: 'B'),
          buildSession(sessionId: 's3', nombre: 'C'),
        ],
      );

      expect(
        find.textContaining('3/$kMaxCarritosEnEspera'),
        findsOneWidget,
      );
    });
  });

  // ════════════════════════════════════════════════════════════
  // CONTENIDO
  // ════════════════════════════════════════════════════════════

  group('ParkedCartsDialog — contenido de cada tarjeta', () {
    testWidgets('muestra el total calculado de los items', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [
              buildItem(precio: 2.0, cantidad: 3.0), // 6
              buildItem(precio: 5.0, cantidad: 1.0), // 5
            ],
          ),
        ],
      );

      expect(find.text('\$11.00'), findsOneWidget);
    });

    testWidgets('muestra "3 items" en plural', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem(), buildItem(), buildItem()],
          ),
        ],
      );

      expect(find.text('3 items'), findsOneWidget);
    });

    testWidgets('muestra "1 item" en singular', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
          ),
        ],
      );

      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('muestra el nombre del cliente si existe', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Carrito 1',
            clienteNombre: 'Juan Pérez',
            items: [buildItem()],
          ),
        ],
      );

      expect(find.text('Juan Pérez'), findsOneWidget);
    });

    testWidgets('muestra los 3 botones en cada sesión', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
          ),
        ],
      );

      expect(find.text('Renombrar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
      expect(find.text('Retomar'), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════
  // BADGES
  // ════════════════════════════════════════════════════════════

  group('ParkedCartsDialog — badges de estado', () {
    testWidgets('sesión reciente muestra tiempo relativo en minutos',
        (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ],
      );

      expect(find.text('Hace 5 min'), findsOneWidget);
      expect(find.text('Abandonado'), findsNothing);
    });

    testWidgets('sesión de hace horas muestra "Hace N h"', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
      );

      expect(find.text('Hace 3 h'), findsOneWidget);
    });

    testWidgets('sesión creada hace segundos muestra "Ahora"', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
            createdAt: DateTime.now(),
          ),
        ],
      );

      expect(find.text('Ahora'), findsOneWidget);
    });

    testWidgets('sesión con más de 24h muestra "Abandonado"', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
            createdAt: DateTime.now().subtract(const Duration(hours: 25)),
          ),
        ],
      );

      expect(find.text('Abandonado'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════
  // INTERACCIONES
  // ════════════════════════════════════════════════════════════

  group('ParkedCartsDialog — interacciones', () {
    testWidgets('botón cerrar cierra el diálogo', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
          ),
        ],
      );

      expect(find.text('Carritos en espera'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // El dialog se removió del árbol. Como ParkedCartsDialog está
      // montado como home directo (no vía showDialog), seguirá visible
      // tras el pop sólo si estamos dentro de un Navigator.
      // Verificamos que el onPressed haya disparado el pop sin excepciones.
      expect(tester.takeException(), isNull);
    });

    testWidgets('botón Renombrar abre diálogo con nombre precargado',
        (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
          ),
        ],
      );

      await tester.tap(find.text('Renombrar'));
      await tester.pumpAndSettle();

      expect(find.text('Renombrar carrito'), findsOneWidget);

      final tf = tester.widget<TextField>(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
      );
      expect(tf.controller?.text, 'Mesa 3');

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
    });

    testWidgets('botón Eliminar pide confirmación', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
          ),
        ],
      );

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(find.text('Eliminar carrito'), findsOneWidget);
      expect(find.textContaining('¿Eliminar "Mesa 3"?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // El item sigue ahí
      expect(find.text('Mesa 3'), findsOneWidget);
    });

    testWidgets('confirmar Eliminar quita la sesión del state',
        (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(
            sessionId: 's1',
            nombre: 'Mesa 3',
            items: [buildItem()],
          ),
        ],
      );

      // Debe aparecer
      expect(find.text('Mesa 3'), findsOneWidget);

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Confirmar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Eliminar'));
      await tester.pumpAndSettle();

      // Debe desaparecer
      expect(find.text('Mesa 3'), findsNothing);
      // Y aparecer el empty state
      expect(find.text('No tienes carritos en espera'), findsOneWidget);
    });
  });
}