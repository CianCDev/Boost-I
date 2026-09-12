import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme.dart';

/// Smoke tests: verifican que el tema y widgets básicos se construyen sin errores.
///
/// NO arranca la app completa porque eso requiere Supabase e Isar inicializados.
/// Para eso están los integration tests (test/integration/).
void main() {
  group('Smoke tests', () {
    testWidgets('Light theme se construye sin errores', (tester) async {
      final theme = lightTheme();
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('Dark theme se construye sin errores', (tester) async {
      final theme = darkTheme();
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('Un widget básico se renderiza', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: lightTheme(),
            home: const Scaffold(
              body: Center(child: Text('BoostI POS')),
            ),
          ),
        ),
      );

      expect(find.text('BoostI POS'), findsOneWidget);
    });
  });
}