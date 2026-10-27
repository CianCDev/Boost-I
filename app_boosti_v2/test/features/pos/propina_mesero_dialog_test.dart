// test/features/pos/propina_mesero_dialog_test.dart
//
// R.4 · Contrato del diálogo de propina + mesero.
//
// No toca Isar ni providers: el diálogo es puro estado de UI y recibe la
// lista de empleados por constructor. Por eso se prueba en un MaterialApp
// vacío, sin montar el POS.
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/restaurante/propina_mesero_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resultado pendiente de un diálogo abierto desde el botón "abrir".
class _Sesion {
  ResultadoPropina? resultado;
  bool abierto = false;
}

void main() {
  UsuarioEntity mesero({required int id, required String nombre}) =>
      UsuarioEntity()
        ..id = id
        ..nombre = nombre
        ..rol = 'cajero'
        ..activo = true
        ..estado = 'activo';

  final meseros = [
    mesero(id: 1, nombre: 'Ana'),
    mesero(id: 2, nombre: 'Luis'),
  ];

  /// Monta un botón que abre el diálogo y deja el resultado en [_Sesion].
  Future<_Sesion> montar(
    WidgetTester tester, {
    required double totalConsumo,
  }) async {
    final sesion = _Sesion();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                sesion.abierto = true;
                sesion.resultado = await showDialog<ResultadoPropina>(
                  context: context,
                  builder: (_) => PropinaMeseroDialog(
                    totalConsumo: totalConsumo,
                    meseros: meseros,
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return sesion;
  }

  Future<void> elegirMesero(WidgetTester tester, String nombre) async {
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('$nombre · cajero').last);
    await tester.pumpAndSettle();
  }

  testWidgets('sin mesero no se puede continuar', (tester) async {
    final sesion = await montar(tester, totalConsumo: 20.0);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Propina y mesero'), findsOneWidget);
    // Arranca en "Sin propina": el total mostrado es el consumo.
    expect(find.text('Sin propina'), findsOneWidget);
    expect(find.text('\$20.00'), findsOneWidget);

    final boton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continuar al cobro'),
    );
    expect(boton.onPressed, isNull);

    // Cancelar devuelve null → el caller no cobra.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(sesion.abierto, isTrue);
    expect(sesion.resultado, isNull);
  });

  testWidgets('un porcentaje calcula la propina y actualiza el total',
      (tester) async {
    final sesion = await montar(tester, totalConsumo: 100.0);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('10 %'));
    await tester.pumpAndSettle();

    // 100 + 10 % = 110.
    expect(find.text('\$110.00'), findsOneWidget);
    expect(find.text('Incluye \$10.00 de propina'), findsOneWidget);

    await elegirMesero(tester, 'Ana');

    await tester.tap(find.text('Continuar al cobro'));
    await tester.pumpAndSettle();

    final resultado = sesion.resultado;
    expect(resultado, isNotNull);
    expect(resultado!.propina, closeTo(10.0, 0.01));
    expect(resultado.meseroNombre, 'Ana');
  });

  testWidgets('el monto libre reemplaza al porcentaje', (tester) async {
    final sesion = await montar(tester, totalConsumo: 50.0);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('15 %'));
    await tester.pumpAndSettle();
    expect(find.text('\$57.50'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '3.75');
    await tester.pumpAndSettle();
    expect(find.text('\$53.75'), findsOneWidget);

    await elegirMesero(tester, 'Luis');

    await tester.tap(find.text('Continuar al cobro'));
    await tester.pumpAndSettle();

    final resultado = sesion.resultado;
    expect(resultado!.propina, closeTo(3.75, 0.01));
    expect(resultado.meseroNombre, 'Luis');
  });

  testWidgets('"Sin propina" no deja monto pendiente', (tester) async {
    final sesion = await montar(tester, totalConsumo: 80.0);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12');
    await tester.pumpAndSettle();
    expect(find.text('\$92.00'), findsOneWidget);

    // Volver al chip de 0 limpia el campo y el monto.
    await tester.tap(find.text('Sin propina'));
    await tester.pumpAndSettle();
    expect(find.text('\$80.00'), findsOneWidget);
    expect(find.text('Incluye \$12.00 de propina'), findsNothing);

    await elegirMesero(tester, 'Ana');

    await tester.tap(find.text('Continuar al cobro'));
    await tester.pumpAndSettle();

    final resultado = sesion.resultado;
    expect(resultado!.propina, 0.0);
    expect(resultado.meseroNombre, 'Ana');
  });
}
