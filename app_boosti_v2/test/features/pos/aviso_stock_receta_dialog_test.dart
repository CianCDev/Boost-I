// test/features/pos/aviso_stock_receta_dialog_test.dart
//
// R.4 · G.3 · Contrato del aviso de stock insuficiente del KDS.
//
// Antes era un Snackbar y competía con el aviso de pedido nuevo. Ahora es un
// `AlertDialog`: no se cierra solo, deduplica los ingredientes y no deja
// pasar el mensaje en silencio.
import 'package:app_boosti_v2/features/pos/presentation/widgets/restaurante/aviso_stock_receta_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Monta un botón que abre el diálogo, igual que el KDS al entregar.
  Future<void> montar(WidgetTester tester, List<String> faltantes) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AvisoStockRecetaDialog.mostrar(
                context,
                faltantes: faltantes,
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el título y cada ingrediente faltante', (tester) async {
    await montar(tester, ['Queso', 'Jamón']);

    expect(find.text('Stock insuficiente'), findsOneWidget);
    expect(find.text('Queso'), findsOneWidget);
    expect(find.text('Jamón'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);
  });

  testWidgets('deduplica y ordena los ingredientes', (tester) async {
    // El provider puede repetir un ingrediente cuando se queda corto en
    // varios lotes seguidos.
    await montar(tester, ['Queso', 'Jamón', 'Queso']);

    expect(find.text('Queso'), findsOneWidget);
    expect(find.text('Jamón'), findsOneWidget);
  });

  testWidgets('no se cierra solo', (tester) async {
    await montar(tester, ['Queso']);

    // Muy por encima de los 4 segundos que duraba el Snackbar.
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    expect(find.text('Stock insuficiente'), findsOneWidget);
  });

  testWidgets('"Entendido" cierra el diálogo', (tester) async {
    await montar(tester, ['Queso']);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    expect(find.text('Stock insuficiente'), findsNothing);
  });
}
