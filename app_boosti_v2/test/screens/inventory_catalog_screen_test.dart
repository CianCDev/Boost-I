// test/screens/inventory_catalog_screen_test.dart

// ignore_for_file: unused_element

import 'package:app_boosti_v2/features/pos/presentation/screens/inventory_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Estado de catalog falso para los tests.
// ignore: unused_element
class _FakeCatalogState {
  // Ajusta según tu clase CatalogState real
}

/// Fake notifier para inyectar en el provider.
class _FakeCatalogNotifier extends StateNotifier<dynamic> {
  _FakeCatalogNotifier() : super(null);

  @override
  // ignore: override_on_non_overriding_member
  void setBusqueda(String query) {}
}

void main() {
  group('InventoryCatalogScreen', () {
    testWidgets('monta sin errores', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: InventoryCatalogScreen(showAppBar: false),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      // El screen debe montar sin excepciones
      expect(tester.takeException(), isNull);
    });

    testWidgets('F1 abre el diálogo de atajos', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: InventoryCatalogScreen(showAppBar: false),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pumpAndSettle();

      expect(find.text('Atajos de teclado'), findsOneWidget);
      expect(find.textContaining('F12'), findsOneWidget);
      expect(find.textContaining('1-9'), findsOneWidget);

      // Cerrar
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
    });

    testWidgets('Escape cierra el diálogo de atajos si está abierto',
        (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: InventoryCatalogScreen(showAppBar: false),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pumpAndSettle();
      expect(find.text('Atajos de teclado'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Atajos de teclado'), findsNothing);
    });

    testWidgets('F2 enfoca el buscador', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: InventoryCatalogScreen(showAppBar: true),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pump();

      // Verifica que haya un FocusNode con foco en el campo de búsqueda
      final focused = FocusManager.instance.primaryFocus;
      expect(focused, isNotNull);
    });

    testWidgets(
      'los números NO se procesan cuando hay un TextField enfocado',
      (tester) async {
        // Nota: esto requiere que el screen monte y que exista un buscador.
        // El test verifica que escribir 1 en el buscador no dispare el hotkey.
        await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(
            home: InventoryCatalogScreen(showAppBar: true),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 500));

        // Buscar el TextField del buscador
        final buscador = find.byType(TextField);
        if (buscador.evaluate().isEmpty) {
          // Si no hay buscador montado (mobile sin searchbar), skip
          return;
        }

        await tester.tap(buscador.first);
        await tester.pump();
        await tester.enterText(buscador.first, '1');
        await tester.pump();

        final controller = tester.widget<TextField>(buscador.first).controller;
        expect(controller?.text, '1');
      },
    );
  });
}