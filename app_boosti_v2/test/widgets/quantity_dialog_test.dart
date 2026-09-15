// test/widgets/quantity_dialog_test.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/catalog/quantity_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProductoEntity buildProducto({
    int id = 1,
    String nombre = 'Coca-Cola 2L',
    double precio = 5.0,
    bool esPesado = false,
    double stock = 10.0,
  }) {
    return ProductoEntity()
      ..id = id
      ..codigoBarras = '7501234567${id.toString().padLeft(2, '0')}'
      ..nombre = nombre
      ..precioUnidad = precio
      ..stock = stock
      ..esPesado = esPesado
      ..categoria = 'Bebidas'
      ..stockMinimo = 1.0;
  }

  /// Abre el QuantityDialog dentro de un MaterialApp (como si viniera
  /// de un showDialog real) y espera a que se asiente.
  Future<void> openDialog(
    WidgetTester tester, {
    ProductoEntity? producto,
    void Function(ProductoEntity, double)? onAgregar,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => QuantityDialog(
                    producto: producto ?? buildProducto(),
                    onAgregar: onAgregar ?? (_, __) {},
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  /// Localiza el TextField de la sección "Cantidad".
  Finder cantidadField() => find.ancestor(
        of: find.text('Cantidad'),
        matching: find.byType(TextField),
      );

  /// Localiza el TextField de la sección "Precio".
  Finder precioField() => find.ancestor(
        of: find.textContaining('Precio por unidad'),
        matching: find.byType(TextField),
      );

  group('QuantityDialog', () {
    testWidgets('muestra el nombre del producto en el header',
        (tester) async {
      await openDialog(tester);
      expect(find.text('Coca-Cola 2L'), findsOneWidget);
      expect(find.text('Agregar al Carrito'), findsOneWidget);
    });

    testWidgets('precarga cantidad 1 y precio original', (tester) async {
      await openDialog(tester);

      final cCtrl = tester.widget<TextField>(cantidadField()).controller;
      final pCtrl = tester.widget<TextField>(precioField()).controller;

      expect(cCtrl?.text, '1');
      expect(pCtrl?.text, '5.00');
    });

    testWidgets('permite escribir varios dígitos sin perder ninguno',
        (tester) async {
      await openDialog(tester);

      await tester.tap(cantidadField());
      await tester.pump();
      await tester.enterText(cantidadField(), '25');
      await tester.pump();

      final ctrl = tester.widget<TextField>(cantidadField()).controller;
      expect(ctrl?.text, '25');
    });

    testWidgets('permite decimales en producto pesado (hasta 3 dec)',
        (tester) async {
      await openDialog(tester, producto: buildProducto(esPesado: true));

      await tester.enterText(cantidadField(), '1.250');
      await tester.pump();

      final ctrl = tester.widget<TextField>(cantidadField()).controller;
      expect(ctrl?.text, '1.250');
    });

    testWidgets('bloquea letras en el campo cantidad', (tester) async {
      await openDialog(tester);

      await tester.enterText(cantidadField(), 'abc');
      await tester.pump();

      final ctrl = tester.widget<TextField>(cantidadField()).controller;
      expect(ctrl?.text.contains(RegExp(r'[a-zA-Z]')), isFalse);
    });

    testWidgets('botón Agregar deshabilitado con cantidad 0', (tester) async {
      await openDialog(tester);

      await tester.enterText(cantidadField(), '0');
      await tester.pump();

      final elevated = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Agregar al Carrito'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(elevated.onPressed, isNull);
    });

    testWidgets('agrega con cantidad válida y llama al callback',
        (tester) async {
      ProductoEntity? productoRecibido;
      double? cantidadRecibida;

      await openDialog(
        tester,
        onAgregar: (p, c) {
          productoRecibido = p;
          cantidadRecibida = c;
        },
      );

      await tester.enterText(cantidadField(), '3');
      await tester.pump();

      await tester.tap(find.text('Agregar al Carrito'));
      await tester.pump();

      // El callback se dispara tras un Future.delayed(150ms).
      // Damos margen suficiente.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(productoRecibido, isNotNull);
      expect(cantidadRecibida, 3.0);
      expect(productoRecibido?.nombre, 'Coca-Cola 2L');
    });

    testWidgets('respeta el precio editado al agregar', (tester) async {
      ProductoEntity? productoRecibido;

      await openDialog(
        tester,
        onAgregar: (p, _) => productoRecibido = p,
      );

      await tester.enterText(precioField(), '4.50');
      await tester.pump();

      await tester.tap(find.text('Agregar al Carrito'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(productoRecibido?.precioUnidad, 4.50);
    });

    testWidgets('cancelar cierra el diálogo sin llamar al callback',
        (tester) async {
      var agregado = false;

      await openDialog(tester, onAgregar: (_, __) => agregado = true);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Agregar al Carrito'), findsNothing);
      expect(agregado, isFalse);
    });
  });
}