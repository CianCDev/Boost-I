import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/configuracion_moneda.dart';

/// Servicio para obtener tasas de cambio desde las APIs de DolarApi.
class BcvService {
  /// ⚠️ DEPRECATED: mantener por compatibilidad con código existente.
  /// Usar `obtenerTasaPais()` en su lugar.
  static const String _urlApiDolarLegacy =
      'https://ve.dolarapi.com/v1/dolares/oficial';

  /// ══════════════════════════════════════════════════════════════
  /// API LEGACY (compatible hacia atrás)
  /// ══════════════════════════════════════════════════════════════

  /// Obtiene la tasa del dólar BCV en Venezuela.
  /// Devuelve `0.0` ante cualquier error.
  static Future<double> obtenerTasaBcv({http.Client? client}) async {
    return _fetchTasa(
      endpoint: _urlApiDolarLegacy,
      client: client,
    );
  }

  /// ══════════════════════════════════════════════════════════════
  /// API NUEVA (multi-país + multi-moneda)
  /// ══════════════════════════════════════════════════════════════

  /// Obtiene la tasa del dólar en la moneda local del país.
  ///
  /// Ej: para 'VE' devuelve cuántos Bs. vale 1 USD.
  ///     para 'CO' devuelve cuántos COP vale 1 USD.
  ///
  /// Devuelve `0.0` ante cualquier error.
  static Future<double> obtenerTasaDolarDelPais(
    ConfiguracionMoneda config, {
    http.Client? client,
  }) async {
    return _fetchTasa(
      endpoint: config.endpointDolar,
      client: client,
    );
  }

  /// Obtiene la tasa del euro en la moneda local del país.
  ///
  /// Si el país no maneja euro (endpoint null), devuelve `0.0`.
  static Future<double> obtenerTasaEuroDelPais(
    ConfiguracionMoneda config, {
    http.Client? client,
  }) async {
    if (!config.manejaEuro) return 0.0;
    return _fetchTasa(
      endpoint: config.endpointEuro!,
      client: client,
    );
  }

  /// ══════════════════════════════════════════════════════════════
  /// VARIANTES CON FECHA
  // ══════════════════════════════════════════════════════════════
  //
  // Devuelven además la fecha que reporta la API.
  //
  // Por qué no se les cambia la firma a las de arriba: devuelven `double`
  // y están cubiertas por `test/unit/bcv_service_test.dart`. Agregar en
  // vez de modificar evita romper esos tests.

  /// Tasa del dólar con la fecha de la API.
  static Future<({double tasa, DateTime? fecha})> obtenerTasaDolarConFecha(
    ConfiguracionMoneda config, {
    http.Client? client,
  }) async {
    return _fetchTasaYFecha(endpoint: config.endpointDolar, client: client);
  }

  /// Tasa del euro con la fecha de la API.
  ///
  /// Si el país no maneja euro, devuelve tasa `0.0` y fecha `null`.
  static Future<({double tasa, DateTime? fecha})> obtenerTasaEuroConFecha(
    ConfiguracionMoneda config, {
    http.Client? client,
  }) async {
    if (!config.manejaEuro) return (tasa: 0.0, fecha: null);
    return _fetchTasaYFecha(endpoint: config.endpointEuro!, client: client);
  }

  /// ══════════════════════════════════════════════════════════════
  /// IMPLEMENTACIÓN INTERNA
  /// ══════════════════════════════════════════════════════════════

  /// Hace GET al endpoint y extrae el campo `promedio`.
  /// Devuelve `0.0` si falla cualquier cosa.
  static Future<double> _fetchTasa({
    required String endpoint,
    http.Client? client,
  }) async {
    final r = await _fetchTasaYFecha(endpoint: endpoint, client: client);
    return r.tasa;
  }

  /// Hace GET y devuelve la tasa junto con la fecha de la API.
  ///
  /// La fecha sale de `fechaActualizacion` (ISO con offset, ej.
  /// `2026-10-09T00:00:00-04:00`) y es la FECHA REAL de la tasa: la BCV
  /// publica una vez por día. Antes el controller guardaba
  /// `DateTime.now()` al hacer fetch, con lo cual la app declaraba una
  /// frescura de hasta 24 h mayor que la real.
  ///
  /// Si la API no manda fecha, o no se puede parsear, devuelve `null` y
  /// le toca al caller decidir el fallback.
  static Future<({double tasa, DateTime? fecha})> _fetchTasaYFecha({
    required String endpoint,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ✅ Acepta int o double, y si falta `promedio` devuelve 0.0
        final tasa = (data['promedio'] as num?)?.toDouble() ?? 0.0;

        // `fechaActualizacion` es el campo real de dolarapi. `fecha` se
        // acepta como alternativa para no romper endpoints que solo la
        // publiquen.
        final fechaStr =
            (data['fechaActualizacion'] ?? data['fecha']) as String?;
        final fecha = fechaStr == null ? null : DateTime.tryParse(fechaStr);

        return (tasa: tasa, fecha: fecha);
      }
      return (tasa: 0.0, fecha: null);
    } catch (e) {
      debugPrint('Excepción al conectar con la API ($endpoint): $e');
      return (tasa: 0.0, fecha: null);
    } finally {
      if (client == null) httpClient.close();
    }
  }
}