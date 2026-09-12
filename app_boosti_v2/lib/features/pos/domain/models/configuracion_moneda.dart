// lib/features/pos/domain/models/configuracion_moneda.dart

/// Configuración de monedas y tasas por país.
///
/// TODO(multi-pais): Migrar a entidad Isar `ConfiguracionPaisEntity`
/// cuando se implemente la configuración inicial post-empresa.
class ConfiguracionMoneda {
  /// Código ISO del país ('VE', 'CO', 'CL', 'AR').
  final String codigoPais;

  /// Símbolo de la moneda local (ej. 'Bs.', 'COP', 'CLP', 'ARS').
  final String simboloMoneda;

  /// Nombre de la moneda local (ej. 'Bolívares', 'Pesos Colombianos').
  final String nombreMoneda;

  /// Endpoint para obtener la tasa de cambio del USD en moneda local.
  ///
  /// Ej: `ve.dolarapi.com/v1/dolares/oficial` devuelve cuántos Bs. vale 1 USD.
  final String endpointDolar;

  /// Endpoint para obtener la tasa de cambio del EUR en moneda local.
  ///
  /// Puede ser null si el país no maneja Euro (ej. Argentina).
  final String? endpointEuro;

  /// Decimales para mostrar la moneda local.
  /// - VE: 2 (Bs. 36.50)
  /// - CO: 0 (COP 4.000)
  /// - CL: 0 (CLP 950)
  /// - AR: 0 (ARS 1.000)
  final int decimalesMonedaLocal;

  const ConfiguracionMoneda({
    required this.codigoPais,
    required this.simboloMoneda,
    required this.nombreMoneda,
    required this.endpointDolar,
    this.endpointEuro,
    this.decimalesMonedaLocal = 2,
  });

  // ══════════════════════════════════════════════════════════════
  // CONFIGURACIONES POR PAÍS
  // ══════════════════════════════════════════════════════════════
  // TODO(multi-pais): Cuando se integren CO/CL/AR, activar esos endpoints.

  static const Map<String, ConfiguracionMoneda> porPais = {
    'VE': ConfiguracionMoneda(
      codigoPais: 'VE',
      simboloMoneda: 'Bs.',
      nombreMoneda: 'Bolívares',
      endpointDolar: 'https://ve.dolarapi.com/v1/dolares/oficial',
      endpointEuro: 'https://ve.dolarapi.com/v1/euros/oficial',
      decimalesMonedaLocal: 2,
    ),
    'CO': ConfiguracionMoneda(
      codigoPais: 'CO',
      simboloMoneda: 'COP',
      nombreMoneda: 'Pesos Colombianos',
      endpointDolar: 'https://co.dolarapi.com/v1/dolares/oficial',
      endpointEuro: 'https://co.dolarapi.com/v1/euros/oficial',
      decimalesMonedaLocal: 0,
    ),
    'CL': ConfiguracionMoneda(
      codigoPais: 'CL',
      simboloMoneda: 'CLP',
      nombreMoneda: 'Pesos Chilenos',
      endpointDolar: 'https://cl.dolarapi.com/v1/dolares/oficial',
      endpointEuro: 'https://cl.dolarapi.com/v1/euros/oficial',
      decimalesMonedaLocal: 0,
    ),
    'AR': ConfiguracionMoneda(
      codigoPais: 'AR',
      simboloMoneda: 'ARS',
      nombreMoneda: 'Pesos Argentinos',
      endpointDolar: 'https://ar.dolarapi.com/v1/dolares/oficial',
      endpointEuro: 'https://ar.dolarapi.com/v1/euros/oficial',
      decimalesMonedaLocal: 0,
    ),
  };

  static ConfiguracionMoneda porDefecto() => porPais['VE']!;

  /// Verifica si este país maneja Euro BCV.
  bool get manejaEuro => endpointEuro != null && endpointEuro!.isNotEmpty;

  /// Formatea un monto en la moneda local.
  /// Ej: `formatear(1234.5)` → `"Bs. 1.234,50"` (o `"COP 1.234"` para Colombia).
  String formatear(double monto) {
    final String montoStr = monto.toStringAsFixed(decimalesMonedaLocal);
    return '$simboloMoneda $montoStr';
  }

  /// Formatea un monto en USD.
  String formatearUsd(double monto) => '\$${monto.toStringAsFixed(2)}';

  /// Formatea un monto en EUR.
  String formatearEur(double monto) => '€${monto.toStringAsFixed(2)}';
}