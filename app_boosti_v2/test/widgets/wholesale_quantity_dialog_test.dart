import 'package:app_boosti_v2/features/pos/data/Local/entities/config_descuento_mayorista_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/isar_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/wholesale/wholesale_quantity_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockIsarService extends Mock implements IsarService {}

void main() {
  testWidgets('actualiza subtotal y total al escribir cantidad',
      (tester) async {
    final isar = _MockIsarService();
    when(() => isar.obtenerConfigDescuentos(soloActivos: true))
        .thenAnswer((_) async => <ConfigDescuentoMayoristaEntity>[]);
    final producto = ProductoEntity()
      ..nombre = 'Producto'
      ..precioUnidad = 2;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [isarServiceProvider.overrideWithValue(isar)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => WholesaleQuantityDialog.show(
                  context,
                  producto: producto,
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

    await tester.enterText(find.byType(TextField), '22');
    await tester.pump();

    expect(find.text('\$44.00'), findsNWidgets(2));
  });
}
