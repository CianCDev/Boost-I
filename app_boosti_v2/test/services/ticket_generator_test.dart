// test/services/ticket_generator_test.dart
//
// Cubre el camino del logo en el ticket termico (refactor async).
//
// El generador es lo unico que se testea aca: la descarga de Storage y la
// cache viven en `PrinterService._resolverLogoDelLocal`, que toca
// `Supabase.instance` y no se puede montar en un test unitario. Lo que SI
// importa aqui es que `logoBytes` no pueda romper el ticket: si un logo
// corrupto voltea `_appendHeaderLocal`, el cliente se queda sin
// comprobante de venta.
import 'dart:typed_data';

import 'package:app_boosti_v2/features/pos/presentation/services/ticket_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  // `CapabilityProfile.load()` lee un asset del paquete por rootBundle,
  // que exige el binding de Flutter inicializado.
  TestWidgetsFlutterBinding.ensureInitialized();

  Uint8List pngDePrueba({required int ancho, required int alto}) {
    final imagen = img.Image(width: ancho, height: alto);
    img.fill(imagen, color: img.ColorRgb8(0, 0, 0));
    return Uint8List.fromList(img.encodePng(imagen));
  }

  final itemDePrueba = <TicketItem>[
    TicketItem(nombre: 'Arroz 1kg', precio: 1.5, cantidad: 2),
  ];

  group('TicketGenerator.generateTicketBytes', () {
    test('sin logo no rompe y devuelve bytes', () async {
      final bytes = await TicketGenerator.generateTicketBytes(
        items: itemDePrueba,
        subtotal: 3.0,
        impuesto: 0.0,
        total: 3.0,
        metodoPago: 'efectivo_usd',
        montoRecibido: 5.0,
        vuelto: 2.0,
        logoBytes: null,
      );

      expect(bytes, isNotEmpty);
    });

    test('con logo valido devuelve mas bytes que sin logo', () async {
      final sinLogo = await TicketGenerator.generateTicketBytes(
        items: itemDePrueba,
        subtotal: 3.0,
        impuesto: 0.0,
        total: 3.0,
        metodoPago: 'efectivo_usd',
        montoRecibido: 5.0,
        vuelto: 2.0,
        logoBytes: null,
      );

      final conLogo = await TicketGenerator.generateTicketBytes(
        items: itemDePrueba,
        subtotal: 3.0,
        impuesto: 0.0,
        total: 3.0,
        metodoPago: 'efectivo_usd',
        montoRecibido: 5.0,
        vuelto: 2.0,
        logoBytes: pngDePrueba(ancho: 512, alto: 200),
      );

      expect(conLogo.length, greaterThan(sinLogo.length));
    });

    test('un logo corrupto no voltea el ticket', () async {
      final bytes = await TicketGenerator.generateTicketBytes(
        items: itemDePrueba,
        subtotal: 3.0,
        impuesto: 0.0,
        total: 3.0,
        metodoPago: 'efectivo_usd',
        montoRecibido: 5.0,
        vuelto: 2.0,
        logoBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      expect(bytes, isNotEmpty);
    });

    test('el ticket de cierre ignora el logo (no tiene encabezado)', () async {
      final bytes = await TicketGenerator.generateTicketBytes(
        items: const [],
        subtotal: 0,
        impuesto: 0,
        total: 100.0,
        metodoPago: 'efectivo_usd',
        montoRecibido: 0,
        vuelto: 0,
        esCierre: true,
        totalesPorMetodo: const {'efectivo_usd': 100.0},
        logoBytes: pngDePrueba(ancho: 512, alto: 200),
      );

      expect(bytes, isNotEmpty);
    });
  });
}
