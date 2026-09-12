import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_boosti_v2/features/pos/presentation/services/bcv_service.dart';
import 'package:app_boosti_v2/features/pos/domain/models/configuracion_moneda.dart';

// ============================================================
// HELPERS
// ============================================================

http.Response respuestaOk(dynamic promedio) {
  return http.Response(
    jsonEncode({
      'promedio': promedio,
      'nombre': 'Oficial',
      'fecha': '2026-09-12',
    }),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

http.Response respuestaError(int statusCode) {
  return http.Response('Error', statusCode);
}

// ============================================================

void main() {
  // ══════════════════════════════════════════════════════════════
  // LEGACY: obtenerTasaBcv (compatibilidad)
  // ══════════════════════════════════════════════════════════════
  group('BcvService — obtenerTasaBcv (legacy)', () {
    test('devuelve la tasa del USD VE', () async {
      final client = MockClient((request) async => respuestaOk(36.50));

      final tasa = await BcvService.obtenerTasaBcv(client: client);
      expect(tasa, 36.50);
    });

    test('usa el endpoint de VE', () async {
      Uri? uri;
      final client = MockClient((request) async {
        uri = request.url;
        return respuestaOk(36.50);
      });

      await BcvService.obtenerTasaBcv(client: client);

      expect(uri!.host, 've.dolarapi.com');
      expect(uri!.path, '/v1/dolares/oficial');
    });
  });

  // ══════════════════════════════════════════════════════════════
  // NUEVO: obtenerTasaDolarDelPais
  // ══════════════════════════════════════════════════════════════
  group('BcvService — obtenerTasaDolarDelPais', () {
    test('VE devuelve la tasa del dólar', () async {
      final config = ConfiguracionMoneda.porPais['VE']!;
      final client = MockClient((request) async => respuestaOk(36.50));

      final tasa =
          await BcvService.obtenerTasaDolarDelPais(config, client: client);
      expect(tasa, 36.50);
    });

    test('CO usa el endpoint de Colombia', () async {
      final config = ConfiguracionMoneda.porPais['CO']!;
      Uri? uri;
      final client = MockClient((request) async {
        uri = request.url;
        return respuestaOk(4000.0);
      });

      await BcvService.obtenerTasaDolarDelPais(config, client: client);

      expect(uri!.host, 'co.dolarapi.com');
      expect(uri!.path, '/v1/dolares/oficial');
    });

    test('CL usa el endpoint de Chile', () async {
      final config = ConfiguracionMoneda.porPais['CL']!;
      Uri? uri;
      final client = MockClient((request) async {
        uri = request.url;
        return respuestaOk(950.0);
      });

      await BcvService.obtenerTasaDolarDelPais(config, client: client);

      expect(uri!.host, 'cl.dolarapi.com');
    });

    test('AR usa el endpoint de Argentina', () async {
      final config = ConfiguracionMoneda.porPais['AR']!;
      Uri? uri;
      final client = MockClient((request) async {
        uri = request.url;
        return respuestaOk(1000.0);
      });

      await BcvService.obtenerTasaDolarDelPais(config, client: client);

      expect(uri!.host, 'ar.dolarapi.com');
    });
  });

  // ══════════════════════════════════════════════════════════════
  // NUEVO: obtenerTasaEuroDelPais
  // ══════════════════════════════════════════════════════════════
  group('BcvService — obtenerTasaEuroDelPais', () {
    test('VE devuelve la tasa del euro', () async {
      final config = ConfiguracionMoneda.porPais['VE']!;
      final client = MockClient((request) async => respuestaOk(40.20));

      final tasa =
          await BcvService.obtenerTasaEuroDelPais(config, client: client);
      expect(tasa, 40.20);
    });

    test('VE usa el endpoint de euros', () async {
      final config = ConfiguracionMoneda.porPais['VE']!;
      Uri? uri;
      final client = MockClient((request) async {
        uri = request.url;
        return respuestaOk(40.20);
      });

      await BcvService.obtenerTasaEuroDelPais(config, client: client);

      expect(uri!.host, 've.dolarapi.com');
      expect(uri!.path, '/v1/euros/oficial');
    });

    test('país sin endpoint de euro devuelve 0.0 sin request', () async {
      // Crear una config temporal sin endpoint euro
      const configSinEuro = ConfiguracionMoneda(
        codigoPais: 'XX',
        simboloMoneda: 'XXX',
        nombreMoneda: 'Test',
        endpointDolar: 'https://test.com/dolar',
        // endpointEuro null
      );

      int requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return respuestaOk(40.20);
      });

      final tasa =
          await BcvService.obtenerTasaEuroDelPais(configSinEuro, client: client);
      expect(tasa, 0.0);
      expect(requestCount, 0, reason: 'No debe hacer request si no hay endpoint');
    });
  });

  // ══════════════════════════════════════════════════════════════
  // ERRORES
  // ══════════════════════════════════════════════════════════════
  group('BcvService — Errores', () {
    test('status 404 devuelve 0.0', () async {
      final config = ConfiguracionMoneda.porPais['VE']!;
      final client = MockClient((request) async => respuestaError(404));

      final tasa =
          await BcvService.obtenerTasaDolarDelPais(config, client: client);
      expect(tasa, 0.0);
    });

    test('excepción de red devuelve 0.0', () async {
      final config = ConfiguracionMoneda.porPais['VE']!;
      final client = MockClient((request) async {
        throw http.ClientException('Sin conexión');
      });

      final tasa =
          await BcvService.obtenerTasaDolarDelPais(config, client: client);
      expect(tasa, 0.0);
    });

    test('JSON sin "promedio" devuelve 0.0', () async {
      final config = ConfiguracionMoneda.porPais['VE']!;
      final client = MockClient((request) async => http.Response(
            jsonEncode({'otro': 'campo'}),
            200,
          ));

      final tasa =
          await BcvService.obtenerTasaDolarDelPais(config, client: client);
      expect(tasa, 0.0);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // CONFIGURACIÓN POR PAÍS
  // ══════════════════════════════════════════════════════════════
  group('ConfiguracionMoneda', () {
    test('VE tiene todos los datos correctos', () {
      final ve = ConfiguracionMoneda.porPais['VE']!;
      expect(ve.codigoPais, 'VE');
      expect(ve.simboloMoneda, 'Bs.');
      expect(ve.manejaEuro, true);
      expect(ve.decimalesMonedaLocal, 2);
    });

    test('CO tiene decimales 0', () {
      final co = ConfiguracionMoneda.porPais['CO']!;
      expect(co.decimalesMonedaLocal, 0);
    });

    test('todos los países tienen endpoint de dólar', () {
      for (final config in ConfiguracionMoneda.porPais.values) {
        expect(config.endpointDolar, isNotEmpty,
            reason: '${config.codigoPais} debe tener endpoint de dólar');
      }
    });

    test('formatear VE usa 2 decimales y símbolo Bs.', () {
      final ve = ConfiguracionMoneda.porPais['VE']!;
      expect(ve.formatear(365.50), 'Bs. 365.50');
    });

    test('formatear CO usa 0 decimales y símbolo COP', () {
      final co = ConfiguracionMoneda.porPais['CO']!;
      expect(co.formatear(4000.0), 'COP 4000');
    });

    test('formatear USD usa \$ y 2 decimales', () {
  final ve = ConfiguracionMoneda.porPais['VE']!;
  expect(ve.formatearUsd(10.5), '\$10.50');
  });

    test('formatear EUR usa € y 2 decimales', () {
      final ve = ConfiguracionMoneda.porPais['VE']!;
      expect(ve.formatearEur(10.5), '€10.50');
    });
  });
}