// test/widgets/quantity_dialog_test.dart
import 'dart:async';

import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/scale_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/scale_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/catalog/quantity_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestScaleService extends ScaleService {
  final StreamController<double> _weights =
      StreamController<double>.broadcast();

  @override
  Stream<double> get weightStream => _weights.stream;

  @override
  Future<bool> connect() async => true;

  void emitWeight(double weight) => _weights.add(weight);

  Future<void> close() => _weights.close();
}

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
    ScaleService? scaleService,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (scaleService != null)
            scaleServiceProvider.overrideWithValue(scaleService),
        ],
        child: MaterialApp(
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
    testWidgets('muestra el nombre del producto en el header', (tester) async {
      await openDialog(tester);
      expect(find.text('Agregar al carrito'), findsOneWidget);
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

    testWidgets('actualiza el total al cambiar cantidad y precio',
        (tester) async {
      await openDialog(tester);

      expect(find.text('Total'), findsOneWidget);
      expect(find.text('\$5.00'), findsNWidgets(2));

      await tester.enterText(cantidadField(), '22');
      await tester.pump();
      expect(find.text('\$110.00'), findsNWidgets(2));

      await tester.enterText(precioField(), '3.50');
      await tester.pump();
      expect(find.text('\$77.00'), findsNWidgets(2));
    });

    testWidgets('el peso recibido actualiza cantidad, total y carrito',
        (tester) async {
      final scaleService = _TestScaleService();
      double? cantidadRecibida;

      await openDialog(
        tester,
        producto: buildProducto(esPesado: true),
        onAgregar: (_, cantidad) => cantidadRecibida = cantidad,
        scaleService: scaleService,
      );

      expect(tester.widget<TextField>(precioField()).controller?.text, '5.00');
      scaleService.emitWeight(2.5);
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(cantidadField()).controller?.text,
        '2.500',
      );
      expect(tester.widget<TextField>(precioField()).controller?.text, '5.00');
      expect(find.text('\$12.50'), findsNWidgets(2));

      await tester.tap(find.text('Agregar al Carrito'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(cantidadRecibida, 2.5);
      await scaleService.close();
    });

    testWidgets('permite decimales en producto pesado (hasta 3 dec)',
        (tester) async {
      final scaleService = _TestScaleService();
      await openDialog(
        tester,
        producto: buildProducto(esPesado: true),
        scaleService: scaleService,
      );

      await tester.enterText(cantidadField(), '1.250');
      await tester.pump();

      final ctrl = tester.widget<TextField>(cantidadField()).controller;
      expect(ctrl?.text, '1.250');
      await scaleService.close();
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
