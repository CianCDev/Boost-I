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
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
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

  // ══════════════════════════════════════════════════════════════
  // DATOS LEGALES DEL EMISOR
  //
  // `Generator.text` codifica con `latin1.encode`, así que el texto
  // ASCII queda literal en el byte stream y se puede buscar. Por eso
  // estos tests sí afirman sobre CONTENIDO y no solo sobre el largo de
  // los bytes como los de arriba.
  // ══════════════════════════════════════════════════════════════
  group('TicketGenerator - datos legales del emisor', () {
    String textoDelTicket(List<int> bytes) =>
        latin1.decode(bytes, allowInvalid: true);

    LocalEntity localCompleto() => LocalEntity()
      ..nombre = 'Boosti POS'
      ..razonSocial = 'JAHTLABS C.A.'
      ..rif = 'J-40123456-7'
      ..direccion = 'Av. Libertador, Caracas'
      ..telefono = '04121234567';

    Future<List<int>> ticketCon(
      LocalEntity local, {
      String? vendedor = 'Juan Perez',
    }) {
      return TicketGenerator.generateTicketBytes(
        local: local,
        items: itemDePrueba,
        subtotal: 3.0,
        impuesto: 0.48,
        total: 3.48,
        metodoPago: 'efectivo_usd',
        montoRecibido: 5.0,
        vuelto: 1.52,
        vendedor: vendedor,
      );
    }

    test('imprime razon social, RIF y direccion del emisor', () async {
      final texto = textoDelTicket(await ticketCon(localCompleto()));

      expect(texto, contains('JAHTLABS C.A.'));
      expect(texto, contains('J-40123456-7'));
      expect(texto, contains('Av. Libertador, Caracas'));
      // El nombre de fantasía también va, debajo de la razón social.
      expect(texto, contains('Boosti POS'));
    });

    test('sin razon social muestra el aviso, no un hueco', () async {
      final local = localCompleto()..razonSocial = null;
      final texto = textoDelTicket(await ticketCon(local));

      expect(texto, contains('Razón social: [no configurada]'));
    });

    test('NO imprime el nombre del vendedor', () async {
      final texto = textoDelTicket(await ticketCon(localCompleto()));

      expect(texto, isNot(contains('Vendedor:')));
      expect(texto, isNot(contains('Juan Perez')));
    });

    test('el IVA declara su alicuota', () async {
      final texto = textoDelTicket(await ticketCon(localCompleto()));

      expect(texto, contains('IVA 16%:'));
    });
  });

  group('TicketGenerator - numeración fiscal', () {
    String textoDelTicket(List<int> bytes) =>
        latin1.decode(bytes, allowInvalid: true);

    Future<List<int>> ticket({String? numeroFactura}) {
      return TicketGenerator.generateTicketBytes(
        items: itemDePrueba,
        subtotal: 3.0,
        impuesto: 0.48,
        total: 3.48,
        metodoPago: 'efectivo_usd',
        montoRecibido: 5.0,
        vuelto: 1.52,
        numeroFactura: numeroFactura,
      );
    }

    test('imprime el numero fiscal si está presente', () async {
      final texto = textoDelTicket(
        await ticket(numeroFactura: 'P12345-2026-0007'),
      );

      expect(texto, contains('P12345-2026-0007'));
      expect(texto, isNot(contains('pendiente')));
    });

    test('muestra "pendiente" si el numero fiscal es null', () async {
      // Las ventas anteriores a la migración 20261012000003 llegan sin
      // número. La línea tiene que seguir apareciendo: omitirla dejaría
      // un comprobante sin numeración sin que nadie lo note.
      final texto = textoDelTicket(await ticket());

      expect(texto, contains('N° pendiente'));
    });
  });
}
