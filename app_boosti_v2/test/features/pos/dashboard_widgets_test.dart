import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/presentation/widgets/dashboard/hourly_sales_chart.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/dashboard/payment_methods_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/dashboard/restaurant_status_card.dart';

Widget _envolver(Widget hijo) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: hijo),
      ),
    ),
  );
}

void main() {
  group('HourlySalesChart', () {
    testWidgets('sin ventas muestra el estado vacío', (tester) async {
      final datos = [
        for (var h = 0; h < 24; h++) {'hora': h, 'total': 0.0},
      ];

      await tester.pumpWidget(_envolver(HourlySalesChart(datos: datos)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin ventas'), findsOneWidget);
    });

    testWidgets('con ventas marca la hora pico', (tester) async {
      final datos = [
        for (var h = 0; h < 24; h++)
          {'hora': h, 'total': h == 14 ? 100.0 : 0.0},
      ];

      await tester.pumpWidget(_envolver(HourlySalesChart(datos: datos)));
      await tester.pumpAndSettle();

      expect(find.textContaining('14:00'), findsOneWidget);
    });
  });

  group('PaymentMethodsCard', () {
    testWidgets('ordena los métodos por monto y muestra el total', (tester) async {
      final datos = {
        'Efectivo': {'total': 60.0, 'count': 3.0},
        'Pago Móvil': {'total': 40.0, 'count': 2.0},
      };

      await tester.pumpWidget(_envolver(PaymentMethodsCard(datos: datos)));
      await tester.pumpAndSettle();

      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('Pago Móvil'), findsOneWidget);
      expect(find.textContaining('100.00'), findsOneWidget);
    });

    testWidgets('sin datos muestra el mensaje de mes vacío', (tester) async {
      await tester
          .pumpWidget(_envolver(const PaymentMethodsCard(datos: {})));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin ventas'), findsOneWidget);
    });
  });

  group('RestaurantStatusCard', () {
    testWidgets('muestra ocupación, libres y comandas', (tester) async {
      await tester.pumpWidget(_envolver(const RestaurantStatusCard(
        mesasTotales: 8,
        mesasOcupadas: 3,
        comandasAbiertas: 2,
        ticketPromedioFormateado: '\$5.20',
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 de 8'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // mesas libres
      expect(find.text('2'), findsOneWidget); // comandas abiertas
    });
  });
}
