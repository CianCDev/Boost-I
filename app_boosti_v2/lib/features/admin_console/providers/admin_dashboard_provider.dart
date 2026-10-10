import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/saas_metrics.dart';
import '../data/repositories/metrics_repository.dart';
import 'subscriptions_provider.dart';

// ═══════════════════════════════════════════════════════════════
// REPOSITORIOS (inyectables para tests)
// ═══════════════════════════════════════════════════════════════

/// Repositorio de métricas. Se expone como provider para poder sustituirlo
/// con un fake en los tests.
///
/// El repositorio de suscripciones se reutiliza desde
/// `subscriptions_provider.dart` para no duplicar la instancia.
final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepository();
});

// ═══════════════════════════════════════════════════════════════
// ESTADO DEL DASHBOARD
// ═══════════════════════════════════════════════════════════════

/// Estado agregado del Dashboard del Control Center.
class AdminDashboardState {
  final bool cargando;
  final String? error;
  final SaasMetrics metricas;
  final List<Map<String, dynamic>> trialsPorVencer;
  final List<Map<String, dynamic>> clientesEnRiesgo;
  final List<Map<String, dynamic>> cancelacionesRecientes;
  final DateTime? ultimaActualizacion;

  /// [metricas] es required a propósito (ver [AdminDashboardState.inicial]).
  ///
  /// No puede tener default porque `SaasMetrics.empty()` es un `factory` que
  /// llama a `DateTime.now()`, y los valores por defecto de un constructor
  /// deben ser constantes de compilación. Se prefiere no-nullable para que la
  /// UI no tenga que chequear null en cada KPI card.
  AdminDashboardState({
    this.cargando = false,
    this.error,
    required this.metricas,
    this.trialsPorVencer = const [],
    this.clientesEnRiesgo = const [],
    this.cancelacionesRecientes = const [],
    this.ultimaActualizacion,
  });

  /// Estado inicial: sin cargar y con métricas vacías.
  ///
  /// Alternativa a un `const AdminDashboardState()` con
  /// `metricas: SaasMetrics.empty()`, que no compila por lo anterior.
  factory AdminDashboardState.inicial() {
    return AdminDashboardState(
      metricas: SaasMetrics.empty(),
    );
  }

  /// Estado de carga: conserva los datos ya cargados y **limpia** el error.
  ///
  /// Hace falta porque `copyWith(error: null)` conservaría el error anterior
  /// (un `copyWith` no puede distinguir "no cambies" de "pon null").
  AdminDashboardState aCargando() {
    return AdminDashboardState(
      cargando: true,
      metricas: metricas,
      trialsPorVencer: trialsPorVencer,
      clientesEnRiesgo: clientesEnRiesgo,
      cancelacionesRecientes: cancelacionesRecientes,
      ultimaActualizacion: ultimaActualizacion,
    );
  }

  AdminDashboardState copyWith({
    bool? cargando,
    String? error,
    SaasMetrics? metricas,
    List<Map<String, dynamic>>? trialsPorVencer,
    List<Map<String, dynamic>>? clientesEnRiesgo,
    List<Map<String, dynamic>>? cancelacionesRecientes,
    DateTime? ultimaActualizacion,
  }) {
    return AdminDashboardState(
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
      metricas: metricas ?? this.metricas,
      trialsPorVencer: trialsPorVencer ?? this.trialsPorVencer,
      clientesEnRiesgo: clientesEnRiesgo ?? this.clientesEnRiesgo,
      cancelacionesRecientes:
          cancelacionesRecientes ?? this.cancelacionesRecientes,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════

/// Orquestador de los datos del Dashboard.
///
/// Lanza las 4 consultas en paralelo y las agrega en un único estado.
/// La lógica de negocio vive en los repositorios: aquí solo se coordina.
class AdminDashboardNotifier extends StateNotifier<AdminDashboardState> {
  AdminDashboardNotifier(this._ref) : super(AdminDashboardState.inicial());

  final Ref _ref;

  // ═════════════════════════════════════════════════════════════
  // CARGA
  // ═════════════════════════════════════════════════════════════

  /// Carga métricas, trials por vencer, clientes en riesgo y
  /// cancelaciones en una sola pasada.
  Future<void> cargar() async {
    state = state.aCargando();

    try {
      final metricasRepo = _ref.read(metricsRepositoryProvider);
      final subsRepo = _ref.read(subscriptionsRepositoryProvider);

      // Los repositorios nunca lanzan: devuelven null/[] y loguean. Por eso
      // Future.wait no se rechaza en el flujo normal y los casts son seguros.
      final resultados = await Future.wait<Object?>([
        metricasRepo.obtenerMetricas(),
        subsRepo.trialsPorVencer(),
        subsRepo.clientesEnRiesgo(),
        subsRepo.cancelacionesRecientes(),
      ]);

      state = state.copyWith(
        cargando: false,
        metricas: resultados[0] as SaasMetrics,
        trialsPorVencer: resultados[1] as List<Map<String, dynamic>>,
        clientesEnRiesgo: resultados[2] as List<Map<String, dynamic>>,
        cancelacionesRecientes: resultados[3] as List<Map<String, dynamic>>,
        ultimaActualizacion: DateTime.now(),
      );

      debugPrint(
        '[AdminDashboardProvider] Dashboard cargado: '
        'trials=${state.trialsPorVencer.length} '
        'riesgo=${state.clientesEnRiesgo.length} '
        'bajas=${state.cancelacionesRecientes.length}',
      );
    } catch (e, stack) {
      debugPrint('[AdminDashboardProvider] Error en cargar(): $e');
      debugPrint('[AdminDashboardProvider] Stack: $stack');
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  /// Refresca la vista materializada de Supabase y vuelve a cargar todo.
  ///
  /// `refrescarMetricas()` sí puede lanzar, por eso va fuera del `try` de
  /// [cargar] para no tragarse el error: la UI necesita saber que el
  /// refresco remoto falló.
  Future<void> refrescar() async {
    state = state.aCargando();

    try {
      await _ref.read(metricsRepositoryProvider).refrescarMetricas();
      debugPrint('[AdminDashboardProvider] Métricas refrescadas en Supabase');
    } catch (e, stack) {
      debugPrint('[AdminDashboardProvider] Error refrescando métricas: $e');
      debugPrint('[AdminDashboardProvider] Stack: $stack');
      state = state.copyWith(cargando: false, error: e.toString());
      return;
    }

    await cargar();
  }
}

// ═══════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════

final adminDashboardProvider =
    StateNotifierProvider<AdminDashboardNotifier, AdminDashboardState>((ref) {
  final notifier = AdminDashboardNotifier(ref);
  // Carga inicial al construir el provider.
  notifier.cargar();
  return notifier;
});
