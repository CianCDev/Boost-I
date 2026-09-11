import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Necesario para el ProviderScope
import 'package:app_boosti_v2/main.dart';

void main() {
  testWidgets('App inicializa correctamente (Smoke Test)', (WidgetTester tester) async {
    // Construye la app sin parámetros, igual que en main()
    await tester.pumpWidget(
      const ProviderScope(
        child: BoostiPOS(),
      ),
    );

    // Espera un frame para que la app cargue la SplashScreen
    await tester.pump();

    // Verificamos que el widget principal de la app se haya construido
    // Buscamos algo que siempre esté presente, como el MaterialApp o el título.
    // En tu SplashScreen se muestra "BoostI POS" como texto.
    expect(find.byType(BoostiPOS), findsOneWidget);
    expect(find.text('BoostI POS'), findsOneWidget); // Asumimos que el título está en la Splash
  });
}