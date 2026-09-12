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
  /// IMPLEMENTACIÓN INTERNA
  /// ══════════════════════════════════════════════════════════════

  /// Hace GET al endpoint y extrae el campo `promedio`.
  /// Devuelve `0.0` si falla cualquier cosa.
  static Future<double> _fetchTasa({
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
        return tasa;
      }
      return 0.0;
    } catch (e) {
      debugPrint('Excepción al conectar con la API ($endpoint): $e');
      return 0.0;
    } finally {
      if (client == null) httpClient.close();
    }
  }
}