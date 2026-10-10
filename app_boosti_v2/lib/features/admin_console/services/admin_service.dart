import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio para el Control Center.
///
/// TODO: Implementar lógica real de administración.
class AdminService {
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    return {
      'mrr': 0.0,
      'clientesActivos': 0,
      'trialsActivos': 0,
      'churn': 0.0,
    };
  }
}

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());
