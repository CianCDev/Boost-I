// test/widgets/confirmar_cobro_pendientes_dialog_test.dart
//
// R.3.4 F.2.4 · Tests de widget del diálogo de cobro con pendientes.
//
// Tests de widget SIN Riverpod, SIN Isar y SIN `ComandaScreen`: el diálogo
// solo necesita un `BuildContext` y dos enteros. Se monta un `MaterialApp`
// con un botón que dispara `mostrar()` y captura el resultado.
//
// ⚠️ Patrón copiado de `test/widgets/cobrar_dialog_test.dart:109-133`, que
// es el precedente del repo para "abrir un diálogo real desde un contexto
// real y quedarse con su resultado".
//
// ⚠️ Lo que estos tests NO cubren: el conteo de los contadores. Eso vive en
// `KdsTicket.pendientesPorEstado` y lo testea
// `test/features/pos/kds_pendientes_test.dart` (15 tests puros). Aquí solo
// se comprueba que los números se PINTAN bien y que los botones devuelven
// lo correcto.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/presentation/widgets/restaurante/confirmar_cobro_pendientes_dialog.dart';

/// Monta el diálogo y devuelve la función que lo dispara.
Future<Future<bool> Function()> montar(
  WidgetTester tester, {
  required int enCocina,
  required int listos,
}) async {
  bool? resultado;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: ElevatedButton(
              onPressed: () async {
                resultado = await ConfirmarCobroPendientesDialog.mostrar(
                  ctx,
                  enCocina: enCocina,
                  listos: listos,
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  return () async => resultado ?? false;
}

void main() {
  group('ConfirmarCobroPendientesDialog · texto', () {
    testWidgets('2 en cocina → plural', (tester) async {
      await montar(tester, enCocina: 2, listos: 0);
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('· 2 platos en cocina'), findsOneWidget);
      expect(find.text('Hay platos pendientes'), findsOneWidget);
      expect(find.text('¿Cobrar igual?'), findsOneWidget);
    });

    testWidgets('1 en cocina → singular', (tester) async {
      await montar(tester, enCocina: 1, listos: 0);
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('· 1 plato en cocina'), findsOneWidget);
    });

    testWidgets('3 listos → plural', (tester) async {
      await montar(tester, enCocina: 0, listos: 3);
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('· 3 listos para servir'), findsOneWidget);
    });

    testWidgets('1 listo → singular', (tester) async {
      await montar(tester, enCocina: 0, listos: 1);
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('· 1 listo para servir'), findsOneWidget);
    });

    testWidgets('ambos contadores visibles a la vez', (tester) async {
      await montar(tester, enCocina: 2, listos: 1);
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('· 2 platos en cocina'), findsOneWidget);
      expect(find.text('· 1 listo para servir'), findsOneWidget);
    });

    testWidgets('NO muestra la línea del contador que está a 0',
        (tester) async {
      await montar(tester, enCocina: 2, listos: 0);
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // Con 0 listos no debe pintar "0 listos para servir": una línea con
      // un cero se lee como un plato que falta.
      expect(find.textContaining('listo'), findsNothing);
      expect(find.textContaining('en cocina'), findsOneWidget);
    });
  });

  group('ConfirmarCobroPendientesDialog · guarda', () {
    testWidgets('con (0, 0) NO abre el diálogo y devuelve true',
        (tester) async {
      final disparar = await montar(tester, enCocina: 0, listos: 0);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // La guarda vive en `mostrar()`, no en quien llama. Es lo que hace
      // que el widget sea autocontenido.
      expect(find.text('Hay platos pendientes'), findsNothing);
      expect(find.text('¿Cobrar igual?'), findsNothing);
      expect(find.text('Esperar'), findsNothing);

      expect(await disparar(), isTrue);
    });

    testWidgets('con negativos tampoco abre nada', (tester) async {
      // Red de seguridad: `mostrar()` compara con `<= 0`, así que un
      // contador negativo (bug en el caller) no produce un diálogo absurdo.
      final disparar = await montar(tester, enCocina: -1, listos: -1);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Hay platos pendientes'), findsNothing);
      expect(await disparar(), isTrue);
    });
  });

  group('ConfirmarCobroPendientesDialog · botones', () {
    testWidgets('[Esperar] devuelve false', (tester) async {
      final disparar = await montar(tester, enCocina: 2, listos: 1);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esperar'));
      await tester.pumpAndSettle();

      expect(await disparar(), isFalse);
      expect(find.text('Hay platos pendientes'), findsNothing);
    });

    testWidgets('[Cobrar igual] devuelve true', (tester) async {
      final disparar = await montar(tester, enCocina: 2, listos: 1);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cobrar igual'));
      await tester.pumpAndSettle();

      expect(await disparar(), isTrue);
      expect(find.text('Hay platos pendientes'), findsNothing);
    });

    testWidgets('cerrar con el botón atrás devuelve false', (tester) async {
      // Ante la duda, no cobrar: cerrar el diálogo sin elegir equivale a
      // [Esperar].
      final disparar = await montar(tester, enCocina: 1, listos: 0);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // `Navigator.pop()` sin valor simula el botón atrás del diálogo.
      final ctx = tester.element(find.text('Hay platos pendientes'));
      Navigator.of(ctx).pop();
      await tester.pumpAndSettle();

      expect(await disparar(), isFalse);
    });

    testWidgets('los dos botones están siempre presentes', (tester) async {
      await montar(tester, enCocina: 1, listos: 0);
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Esperar'), findsOneWidget);
      expect(find.text('Cobrar igual'), findsOneWidget);
    });
  });
}
