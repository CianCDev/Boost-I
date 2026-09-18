// test/widgets/save_cart_dialog_test.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_sessions_controller.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/catalog/cart/save_cart_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ════════════════════════════════════════════════════════════════
// FAKES
// ════════════════════════════════════════════════════════════════

/// Captura las llamadas a `parkearCarritoActivo` para poder assertearlas.
class ParkCall {
  final String nombre;
  final ClienteEntity? cliente;
  ParkCall({required this.nombre, this.cliente});
}

/// Fake del notifier que:
/// - Arranca con la lista de sesiones dada (para testear el nombre autogen).
/// - No toca Isar.
/// - Captura las llamadas a `parkearCarritoActivo`.
/// - Puede devolver un error simulado.
class FakeCartSessionsNotifier extends CartSessionsNotifier {
  final List<ParkCall> parkCalls = [];
  String? simulatedError;

  FakeCartSessionsNotifier(
    super.ref, {
    List<CartSessionEntity> initial = const [],
    this.simulatedError,
  }){
    state = CartSessionsState(sessions: initial);
  }

  @override
  Future<void> cargarSesiones(int usuarioId) async {}

  @override
  Future<void> recargar() async {}

  @override
  Future<String?> parkearCarritoActivo({
    required String nombre,
    ClienteEntity? cliente,
    String? clienteNombreLibre,
    String? notas,
  }) async {
    parkCalls.add(ParkCall(nombre: nombre, cliente: cliente));
    return simulatedError;
  }
}

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

  UsuarioEntity buildUser() {
    return UsuarioEntity()
      ..id = 42
      ..nombre = 'Cajero Test'
      ..rol = 'cajero'
      ..activo = true;
  }

  CartSessionEntity buildSession({
    required String sessionId,
    String nombre = 'Mesa',
  }) {
    return CartSessionEntity()
      ..sessionId = sessionId
      ..usuarioId = 42
      ..nombre = nombre;
  }

  /// Monta el dialog con las dependencias ya resueltas.
  /// Devuelve el fake del notifier para que el test pueda assertear.
  ///
  /// Usa `conUsuario: false` para simular el caso "sin sesión iniciada".
  Future<FakeCartSessionsNotifier> pumpDialog(
    WidgetTester tester, {
    List<CartSessionEntity> sessions = const [],
    bool conUsuario = true,
    String? simulatedError,
    ClienteEntity? cliente,
  }) async {
    late FakeCartSessionsNotifier fake;
    final usuario = conUsuario ? buildUser() : null;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usuarioActualProvider.overrideWith(
            (ref) => FakeUsuariosNotifier(ref, usuario),
          ),
          cartSessionsProvider.overrideWith((ref) {
            fake = FakeCartSessionsNotifier(
              ref,
              initial: sessions,
              simulatedError: simulatedError,
            );
            return fake;
          }),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SaveCartDialog(cliente: cliente),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return fake;
  }

  Finder nombreField() => find.byType(TextField);

  /// Localiza SOLO el botón "Poner en espera" (no el título).
  Finder botonPonerEnEspera() => find.widgetWithText(
        ElevatedButton,
        'Poner en espera',
      );

  // ════════════════════════════════════════════════════════════
  // RENDER
  // ════════════════════════════════════════════════════════════

  group('SaveCartDialog — render', () {
    testWidgets('muestra el header con título y subtítulo', (tester) async {
      await pumpDialog(tester);

      // "Poner en espera" aparece 2 veces: título (header) y botón.
      expect(find.text('Poner en espera'), findsNWidgets(2));
      // El subtítulo es único del header.
      expect(find.text('Podrás retomarlo cuando quieras'), findsOneWidget);
    });

    testWidgets('tiene un campo de texto para el nombre', (tester) async {
      await pumpDialog(tester);

      expect(nombreField(), findsOneWidget);
    });

    testWidgets('muestra el botón Cancelar', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('muestra el botón "Poner en espera"', (tester) async {
      await pumpDialog(tester);

      expect(botonPonerEnEspera(), findsOneWidget);
    });

    testWidgets('muestra chips de sugerencia', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('Mesa 2'), findsOneWidget);
      expect(find.text('Mesa 3'), findsOneWidget);
      expect(find.text('Para llevar'), findsOneWidget);
      expect(find.text('Cliente'), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════
  // NOMBRE AUTOGENERADO
  // ════════════════════════════════════════════════════════════

  group('SaveCartDialog — nombre autogenerado', () {
    testWidgets('con 0 sesiones sugiere "Carrito 1"', (tester) async {
      await pumpDialog(tester, sessions: []);

      final tf = tester.widget<TextField>(nombreField());
      expect(tf.controller?.text, 'Carrito 1');
    });

    testWidgets('con 3 sesiones sugiere "Carrito 4"', (tester) async {
      await pumpDialog(
        tester,
        sessions: [
          buildSession(sessionId: 's1'),
          buildSession(sessionId: 's2'),
          buildSession(sessionId: 's3'),
        ],
      );

      final tf = tester.widget<TextField>(nombreField());
      expect(tf.controller?.text, 'Carrito 4');
    });

    testWidgets('con 9 sesiones sugiere "Carrito 10"', (tester) async {
      await pumpDialog(
        tester,
        sessions: List.generate(9, (i) => buildSession(sessionId: 's$i')),
      );

      final tf = tester.widget<TextField>(nombreField());
      expect(tf.controller?.text, 'Carrito 10');
    });
  });

  // ════════════════════════════════════════════════════════════
  // CHIPS DE SUGERENCIA
  // ════════════════════════════════════════════════════════════

  group('SaveCartDialog — chips de sugerencia', () {
    testWidgets('tocar "Mesa 3" cambia el nombre del campo',
        (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('Mesa 3'));
      await tester.pump();

      final tf = tester.widget<TextField>(nombreField());
      expect(tf.controller?.text, 'Mesa 3');
    });

    testWidgets('tocar "Para llevar" cambia el nombre', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('Para llevar'));
      await tester.pump();

      final tf = tester.widget<TextField>(nombreField());
      expect(tf.controller?.text, 'Para llevar');
    });

    testWidgets('tocar varios chips reemplaza el nombre cada vez',
        (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('Mesa 1'));
      await tester.pump();
      var tf = tester.widget<TextField>(nombreField());
      expect(tf.controller?.text, 'Mesa 1');

      await tester.tap(find.text('Mesa 2'));
      await tester.pump();
      tf = tester.widget<TextField>(nombreField());
      expect(tf.controller?.text, 'Mesa 2');
    });
  });

  // ════════════════════════════════════════════════════════════
  // GUARDAR — caso feliz
  // ════════════════════════════════════════════════════════════

  group('SaveCartDialog — guardar exitoso', () {
    testWidgets('llama parkearCarritoActivo con el nombre del campo',
        (tester) async {
      final fake = await pumpDialog(tester);

      await tester.enterText(nombreField(), 'Mesa 7');
      await tester.pump();

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      expect(fake.parkCalls.length, 1);
      expect(fake.parkCalls.first.nombre, 'Mesa 7');
    });

    testWidgets('pasa el cliente al notifier', (tester) async {
      final cliente = ClienteEntity()
        ..id = 7
        ..nombre = 'Juan Pérez'
        ..documento = 12345678;

      final fake = await pumpDialog(tester, cliente: cliente);

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      expect(fake.parkCalls.length, 1);
      expect(fake.parkCalls.first.cliente?.nombre, 'Juan Pérez');
      expect(fake.parkCalls.first.cliente?.documento, 'V-12345678');
    });

    testWidgets('nombre vacío NO rompe el flujo', (tester) async {
      final fake = await pumpDialog(tester);

      await tester.enterText(nombreField(), '');
      await tester.pump();

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      // El diálogo igual llama al notifier con string vacío.
      // El notifier real lo normaliza a 'Carrito'.
      expect(fake.parkCalls.length, 1);
      expect(fake.parkCalls.first.nombre, '');
    });

    testWidgets('con éxito, no muestra SnackBar de error', (tester) async {
      await pumpDialog(tester);

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('Error'),
        ),
        findsNothing,
      );
    });
  });

  // ════════════════════════════════════════════════════════════
  // GUARDAR — caso de error (límite alcanzado)
  // ════════════════════════════════════════════════════════════

  group('SaveCartDialog — límite alcanzado', () {
    testWidgets('muestra SnackBar con el mensaje del notifier',
        (tester) async {
      await pumpDialog(
        tester,
        simulatedError:
            'Límite alcanzado: máximo $kMaxCarritosEnEspera carritos en espera',
      );

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Límite alcanzado'),
        findsOneWidget,
      );
    });

    testWidgets('NO cierra el diálogo tras el error', (tester) async {
      await pumpDialog(tester, simulatedError: 'Error de prueba');

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      // El diálogo sigue visible
      expect(botonPonerEnEspera(), findsOneWidget);
    });

    testWidgets('permite reintentar después de un error', (tester) async {
      final fake = await pumpDialog(
        tester,
        simulatedError: 'Error transitorio',
      );

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      expect(fake.parkCalls.length, 1);

      // Segundo intento
      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      expect(fake.parkCalls.length, 2);
    });

    testWidgets('el botón se re-habilita tras el error', (tester) async {
      await pumpDialog(tester, simulatedError: 'Error');

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(botonPonerEnEspera());
      expect(btn.onPressed, isNotNull);
    });
  });

  // ════════════════════════════════════════════════════════════
  // CANCELAR
  // ════════════════════════════════════════════════════════════

  group('SaveCartDialog — cancelar', () {
    testWidgets('NO llama a parkearCarritoActivo', (tester) async {
      final fake = await pumpDialog(tester);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(fake.parkCalls, isEmpty);
    });

    testWidgets('no muestra SnackBar', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });
  });

  // ════════════════════════════════════════════════════════════
  // USUARIO NULL
  // ════════════════════════════════════════════════════════════

  group('SaveCartDialog — sin usuario', () {
    testWidgets('no llama al notifier si no hay usuario', (tester) async {
      final fake = await pumpDialog(tester, conUsuario: false);

      await tester.tap(botonPonerEnEspera());
      await tester.pumpAndSettle();

      expect(fake.parkCalls, isEmpty);
    });
  });
}