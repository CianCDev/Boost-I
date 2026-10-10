import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio de métricas para el Control Center.
///
/// TODO: Implementar lógica real de métricas.
class MetricsService {
  Future<Map<String, double>> getGrowthMetrics() async {
    return {
      'mrrGrowth': 0.0,
      'clientGrowth': 0.0,
    };
  }
}

final metricsServiceProvider = Provider<MetricsService>((ref) => MetricsService());
