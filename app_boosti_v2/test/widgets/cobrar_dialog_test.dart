// test/widgets/cobrar_dialog_test.dart
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/bcv_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/clientes/clientes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/cobrar_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

// ════════════════════════════════════════════════════════════════
// FAKES
// ════════════════════════════════════════════════════════════════

class FakeUsuariosNotifier extends UsuariosNotifier {
  FakeUsuariosNotifier(super.ref, UsuarioEntity? initial){
    state = initial;
  }
}

/// Notifier fake de clientes.
class FakeClientesNotifier extends ClientesNotifier {
  FakeClientesNotifier(super.ref, {List<ClienteEntity> initial = const []}){
    state = initial;
  }

  @override
  Future<void> cargarClientes() async {}
}

// ════════════════════════════════════════════════════════════════
// TESTS
// ════════════════════════════════════════════════════════════════

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await setupIsarForTest();
  });

  tearDownAll(() async {
    await tearDownIsarForTest(tempDir);
  });

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

  ClienteEntity buildCliente({
    int id = 1,
    String nombre = 'Juan Pérez',
    String documento = 'V-12345678',
  }) {
    return ClienteEntity()
      ..id = id
      ..nombre = nombre
      ..documento = documento as int?;
  }

  /// Abre el CobrarDialog con overrides de dependencias.
  ///
  /// ✅ Ajusta el viewport a 1280×1024 (evita "Offset outside bounds" en
  ///    botones del fondo del diálogo). Restaura al terminar el test.
  ///
  /// ✅ `await tester.pumpWidget(...)` — imprescindible para respetar
  ///    las reglas de `TestAsyncUtils.guard`.
  Future<Future<Map<String, dynamic>?> Function()> openDialog(
    WidgetTester tester, {
    double totalAPagar = 10.0,
    double tasa = 36.5,
    List<ClienteEntity> clientes = const [],
    UsuarioEntity? usuario,
  }) async {
    // ✅ Viewport amplio para que TODO el diálogo quede visible.
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Map<String, dynamic>? finalResult;
    var dialogClosed = false;

    Future<void> triggerOpen() async {
      final r = await showDialog<Map<String, dynamic>>(
        context: tester.element(find.byType(ElevatedButton)),
        builder: (_) => CobrarDialog(
          totalAPagar: totalAPagar,
          productos: const [],
        ),
      );
      finalResult = r; // ✅ Captura el null directamente o el Map
      dialogClosed = true;
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasasDisponiblesProvider.overrideWithValue({'USD': tasa}),
          clientesProvider.overrideWith(
            (ref) => FakeClientesNotifier(ref, initial: clientes),
          ),
          usuarioActualProvider.overrideWith(
            (ref) => FakeUsuariosNotifier(ref, usuario ?? buildUser()),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => triggerOpen(),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    return () async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      if (!dialogClosed) return null;
      return finalResult;
    };
  }

  /// Bombea frames fijos en vez de pumpAndSettle (que se cuelga con
  /// animaciones perpetuas tipo AnimatedRotation/AnimatedSize).
  Future<void> waitDialog(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Localiza el primer TextField.
  Finder field(int index) => find.byType(TextField).at(index);

  /// Botones principales.
  Finder confirmarBtn() => find.text('CONFIRMAR PAGO');
  Finder cancelarBtn() => find.text('CANCELAR');

  /// ✅ Toca el botón tras asegurar visibilidad (por si acaso).
  Future<void> tapConfirmar(WidgetTester tester) async {
    await tester.ensureVisible(confirmarBtn());
    await tester.pump();
    await tester.tap(confirmarBtn());
  }

  Future<void> tapCancelar(WidgetTester tester) async {
    await tester.ensureVisible(cancelarBtn());
    await tester.pump();
    await tester.tap(cancelarBtn());
  }

  /// ✅ Busca un texto SOLO dentro de los ListTile (evita colisión con
  ///    el texto del buscador u otros widgets).
  Finder clienteTile(String nombre) => find.descendant(
        of: find.byType(ListTile),
        matching: find.text(nombre),
      );

  // ════════════════════════════════════════════════════════════
  // RENDER
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — render', () {
    testWidgets('muestra el header', (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      expect(find.text('Procesar Cobro'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('muestra tabs Método de pago y Cliente', (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      expect(find.text('Método de pago'), findsOneWidget);
      expect(find.text('Cliente'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('muestra el total a pagar', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 25.50);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      expect(find.text('\$25.50'), findsWidgets);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('precarga efectivo USD con el total', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 15.75);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      final ctrl = tester.widget<TextField>(field(0)).controller;
      expect(ctrl?.text, '15.75');

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('muestra las 3 cards de método de pago', (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      expect(find.text('Efectivo'), findsWidgets);
      expect(find.text('Pago Móvil'), findsWidgets);
      expect(find.text('Punto'), findsWidgets);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });
  });

  // ════════════════════════════════════════════════════════════
  // CAMBIO DE MÉTODO
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — cambio de método limpia campos', () {
    testWidgets('cambiar de Efectivo a Pago Móvil limpia los campos',
        (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      expect(
        tester.widget<TextField>(field(0)).controller?.text,
        isNotEmpty,
      );

      await tester.tap(find.text('Pago Móvil').first);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(field(0)).controller?.text, '');
      expect(tester.widget<TextField>(field(1)).controller?.text, '');

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('cambiar a Punto limpia los campos de Pago Móvil',
        (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Pago Móvil').first);
      await tester.pumpAndSettle();

      await tester.enterText(field(0), '100');
      await tester.pump();
      expect(tester.widget<TextField>(field(0)).controller?.text, '100');

      await tester.tap(find.text('Punto').first);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(field(0)).controller?.text, '');

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('volver al método anterior NO restaura los valores',
        (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.enterText(field(0), '999');
      await tester.pump();

      await tester.tap(find.text('Pago Móvil').first);
      await tester.pumpAndSettle();
      await tester.enterText(field(0), '5000');
      await tester.pump();

      await tester.tap(find.text('Efectivo').first);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(field(0)).controller?.text, '');

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });
  });

  // ════════════════════════════════════════════════════════════
  // PANEL DE VUELTO / FALTANTE
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — panel de vuelto', () {
    testWidgets('sin monto suficiente muestra FALTANTE', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 100.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.enterText(field(0), '50');
      await tester.pumpAndSettle();

      expect(find.text('FALTANTE'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('con monto exacto muestra PAGO EXACTO', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 50.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      expect(find.text('PAGO EXACTO'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('con monto mayor muestra VUELTO', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 50.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.enterText(field(0), '100');
      await tester.pumpAndSettle();

      expect(find.text('VUELTO'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });
  });

  // ════════════════════════════════════════════════════════════
  // BOTONES "EXACTO"
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — botones Exacto', () {
    testWidgets('"\$ Exacto" rellena efectivo USD con el total',
        (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 77.50);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.enterText(field(0), '');
      await tester.pump();
      await tester.tap(find.text('\$ Exacto'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(field(0)).controller?.text,
        '77.50',
      );

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('"Pago Móvil Exacto" rellena Bs = total × tasa',
        (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 10.0, tasa: 40.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Pago Móvil').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pago Móvil Exacto'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(field(0)).controller?.text,
        '400.00',
      );

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('"Punto Exacto" rellena Bs = total × tasa', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 20.0, tasa: 36.5);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Punto').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Punto Exacto'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(field(0)).controller?.text,
        '730.00',
      );

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });
  });

  // ════════════════════════════════════════════════════════════
  // BOTÓN CONFIRMAR
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — botón Confirmar', () {
    testWidgets('deshabilitado con pago incompleto', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 100.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.enterText(field(0), '20');
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.ancestor(
          of: confirmarBtn(),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(btn.onPressed, isNull);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('habilitado con pago completo', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 20.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      final btn = tester.widget<ElevatedButton>(
        find.ancestor(
          of: confirmarBtn(),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(btn.onPressed, isNotNull);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });
  });

  // ════════════════════════════════════════════════════════════
  // CONFIRMAR PAGO
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — confirmar pago devuelve resultado', () {
    testWidgets('pop con metodoPago "Efectivo" y montoRecibido',
        (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 15.0, tasa: 36.5);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tapConfirmar(tester);
      await tester.pump();
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      final r = await getResult();
      expect(r, isNotNull);
      expect(r!['procesado'], true);
      expect(r['metodoPago'], 'Efectivo');
      expect(r['montoRecibido'], 15.0);
      expect(r['vuelto'], 0.0);
      expect(r['tasaUsada'], 36.5);
      expect(r['monedaUsada'], 'USD');
      expect(r['cliente'], isNull);
      expect(r['documento'], 'V-00000000');
    });

    testWidgets('pop con metodoPago "Pago Móvil"', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 10.0, tasa: 40.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Pago Móvil').first);
      await tester.pumpAndSettle();

      await tester.enterText(field(0), '400');
      await tester.pumpAndSettle();

      await tapConfirmar(tester);
      await tester.pump();
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      final r = await getResult();
      expect(r, isNotNull);
      expect(r!['metodoPago'], 'Pago Móvil');
      expect(r['montoRecibido'], closeTo(10.0, 0.01));
      expect(r['monedaUsada'], 'USD');
    });

    testWidgets('pop con referencia cuando se llena', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 10.0, tasa: 40.0);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Pago Móvil').first);
      await tester.pumpAndSettle();

      await tester.enterText(field(0), '400');
      await tester.enterText(field(1), '123456');
      await tester.pumpAndSettle();

      await tapConfirmar(tester);
      await tester.pump();
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      final r = await getResult();
      expect(r!['referencia'], '123456');
    });

    testWidgets('calcula vuelto correctamente', (tester) async {
      final getResult = await openDialog(tester, totalAPagar: 50.0, tasa: 36.5);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.enterText(field(0), '70');
      await tester.pumpAndSettle();

      await tapConfirmar(tester);
      await tester.pump();
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      final r = await getResult();
      expect(r!['montoRecibido'], 70.0);
      expect(r['vuelto'], closeTo(20.0, 0.01));
    });
  });

  // ════════════════════════════════════════════════════════════
  // CANCELAR
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — cancelar', () {
    testWidgets('botón CANCELAR cierra sin resultado', (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tapCancelar(tester);
      await tester.pumpAndSettle();

      final r = await getResult();
      expect(r, isNull);
    });

    testWidgets('icono cerrar cierra sin resultado', (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();

      final r = await getResult();
      expect(r, isNull);
    });
  });

  // ════════════════════════════════════════════════════════════
  // TAB CLIENTE
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — tab Cliente', () {
    testWidgets('cambiar a tab Cliente muestra búsqueda', (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Cliente'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Buscar por nombre'),
        findsOneWidget,
      );
      expect(find.text('Registrar nuevo cliente'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('muestra empty state sin cliente seleccionado',
        (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Cliente'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sin cliente asignado'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('buscar cliente filtra por nombre', (tester) async {
      final clientes = [
        buildCliente(id: 1, nombre: 'Juan Pérez'),
        buildCliente(id: 2, nombre: 'María González', documento: 'V-87654321'),
      ];

      final getResult = await openDialog(tester, clientes: clientes);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Cliente'));
      await tester.pumpAndSettle();

      await tester.enterText(field(0), 'Juan');
      await tester.pumpAndSettle();

      // ✅ Solo el ListTile debe contener "Juan Pérez".
      expect(clienteTile('Juan Pérez'), findsOneWidget);
      expect(clienteTile('María González'), findsNothing);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('seleccionar cliente muestra la card', (tester) async {
      final clientes = [
        buildCliente(id: 1, nombre: 'Juan Pérez'),
      ];

      final getResult = await openDialog(tester, clientes: clientes);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.text('Cliente'));
      await tester.pumpAndSettle();

      await tester.enterText(field(0), 'Juan');
      await tester.pumpAndSettle();

      // ✅ Tocar SOLO el ListTile (evita colisión con el buscador).
      await tester.tap(clienteTile('Juan Pérez'));
      await tester.pumpAndSettle();

      // ✅ Tras seleccionar, el nombre aparece en la card y el buscador,
      //    por eso usamos findsWidgets en vez de findsOneWidget.
      expect(find.text('Juan Pérez'), findsWidgets);
      expect(find.text('V-12345678'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('cliente seleccionado viaja en el pop', (tester) async {
      final cliente = buildCliente(id: 1, nombre: 'Juan Pérez');
      final getResult = await openDialog(
        tester,
        totalAPagar: 10.0,
        clientes: [cliente],
      );
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      // Seleccionar cliente — solo el ListTile.
      await tester.tap(find.text('Cliente'));
      await tester.pumpAndSettle();
      await tester.enterText(field(0), 'Juan');
      await tester.pumpAndSettle();
      await tester.tap(clienteTile('Juan Pérez'));
      await tester.pumpAndSettle();

      // Volver a Método de pago
      await tester.tap(find.text('Método de pago'));
      await tester.pumpAndSettle();

      // Confirmar
      await tapConfirmar(tester);
      await tester.pump();
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      final r = await getResult();
      expect(r!['cliente'], isNotNull);
      expect(r['cliente'].nombre, 'Juan Pérez');
      expect(r['documento'], 'V-12345678');
    });
  });

  // ════════════════════════════════════════════════════════════
  // SELECTOR DE MONEDA
  // ════════════════════════════════════════════════════════════

  group('CobrarDialog — selector de tasa', () {
    testWidgets('expandir chip de tasa muestra opciones', (tester) async {
      final getResult = await openDialog(tester, tasa: 36.5);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.textContaining('Dólar'));
      await tester.pumpAndSettle();

      expect(find.text('Manual'), findsWidgets);

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });

    testWidgets('seleccionar Manual muestra campo de tasa', (tester) async {
      final getResult = await openDialog(tester);
      await tester.tap(find.text('Abrir'));
      await waitDialog(tester);

      await tester.tap(find.textContaining('Dólar'));
      await tester.pumpAndSettle();

      // ✅ Hay dos "Manual" potencialmente (chip + algo más) → usamos .first.
      await tester.tap(find.text('Manual').first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Tasa manual'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Cerrar'));
      await waitDialog(tester);
      await getResult();
    });
  });
}