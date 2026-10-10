import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/plan.dart';
import '../data/models/suscripcion.dart';
import '../data/models/tenant.dart';
import '../data/repositories/tenants_repository.dart';

// ═══════════════════════════════════════════════════════════════
// REPOSITORIO (inyectable para tests)
// ═══════════════════════════════════════════════════════════════

/// Repositorio de tenants. Se expone como provider para poder sustituirlo
/// con un fake en los tests.
final tenantsRepositoryProvider = Provider<TenantsRepository>((ref) {
  return TenantsRepository();
});

// ═══════════════════════════════════════════════════════════════
// MODELO INTERNO
// ═══════════════════════════════════════════════════════════════

/// Un tenant junto a su suscripción y el plan de esa suscripción.
///
/// La suscripción es nullable porque un tenant puede existir sin ella
/// (recién creado, o dado de alta sin plan asignado todavía). El plan
/// depende de la suscripción: sin suscripción no hay plan.
class ClientItem {
  final Tenant tenant;
  final Suscripcion? suscripcion;
  final Plan? plan;

  const ClientItem({required this.tenant, this.suscripcion, this.plan});
}

// ═══════════════════════════════════════════════════════════════
// FILTROS
// ═══════════════════════════════════════════════════════════════

/// Filtros disponibles en la lista de clientes.
enum FiltroClientes {
  todos,
  activos,
  trial,

  /// Trial que vence en los próximos 3 días.
  porVencer,

  /// Suscripción vencida o expirada.
  vencidos,

  /// Suscripción cancelada.
  cancelados,
}

// ═══════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════

/// Estado de la lista de clientes del Control Center.
class ClientsState {
  final bool cargando;
  final String? error;

  /// Lista cruda traída del repositorio (tenant + suscripción).
  final List<ClientItem> todos;

  /// Resultado de aplicar [filtro] y [busqueda] sobre [todos].
  final List<ClientItem> filtrados;

  final FiltroClientes filtro;
  final String busqueda;
  final DateTime? ultimaActualizacion;

  /// Cuántos clientes cumplirían cada filtro, **sin aplicar la búsqueda**.
  ///
  /// Vive en el state (y no como getter del notifier) para que sea
  /// reactivo: los chips se redibujan solos al recargar o cambiar de
  /// filtro. No depende de `busqueda` a propósito, para que el número de
  /// un chip no parpadee mientras el super admin escribe.
  final Map<FiltroClientes, int> counts;

  ClientsState({
    this.cargando = false,
    this.error,
    this.todos = const [],
    this.filtrados = const [],
    this.filtro = FiltroClientes.activos,
    this.busqueda = '',
    this.ultimaActualizacion,
    this.counts = const {},
  });

  /// Estado inicial: sin cargar.
  ///
  /// Alternativa a un `const ClientsState()` con defaults no-nullable.
  factory ClientsState.inicial() => ClientsState();

  /// Estado de carga: conserva la lista ya traída y **limpia** el error.
  ///
  /// Hace falta porque `copyWith(error: null)` conservaría el error anterior
  /// (un `copyWith` no puede distinguir "no cambies" de "pon null").
  ClientsState aCargando() {
    return ClientsState(
      cargando: true,
      todos: todos,
      filtrados: filtrados,
      filtro: filtro,
      busqueda: busqueda,
      ultimaActualizacion: ultimaActualizacion,
      counts: counts,
    );
  }

  ClientsState copyWith({
    bool? cargando,
    String? error,
    List<ClientItem>? todos,
    List<ClientItem>? filtrados,
    FiltroClientes? filtro,
    String? busqueda,
    DateTime? ultimaActualizacion,
    Map<FiltroClientes, int>? counts,
  }) {
    return ClientsState(
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
      todos: todos ?? this.todos,
      filtrados: filtrados ?? this.filtrados,
      filtro: filtro ?? this.filtro,
      busqueda: busqueda ?? this.busqueda,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      counts: counts ?? this.counts,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════

/// Orquestador de la lista de clientes: carga, filtra y busca.
///
/// El cruce con `suscripciones` llega ya hecho desde
/// [TenantsRepository.listarConSuscripcion], así que los 6 filtros se
/// resuelven en memoria sin consultas extra.
class ClientsNotifier extends StateNotifier<ClientsState> {
  ClientsNotifier(this._ref) : super(ClientsState.inicial());

  final Ref _ref;

  // ═════════════════════════════════════════════════════════════
  // ACCIONES
  // ═════════════════════════════════════════════════════════════

  /// Carga los tenants con su suscripción.
  ///
  /// Se piden también los inactivos para que el filtro `todos` ↔ `activos`
  /// alterne sin otra ida a la red.
  Future<void> cargar() async {
    state = state.aCargando();

    try {
      final items = await _ref
          .read(tenantsRepositoryProvider)
          .listarConSuscripcion(soloActivos: false);

      state = state.copyWith(
        cargando: false,
        todos: items
            .map(
              (row) => ClientItem(
                tenant: row['tenant'] as Tenant,
                suscripcion: row['suscripcion'] as Suscripcion?,
                plan: row['plan'] as Plan?,
              ),
            )
            .toList(),
        ultimaActualizacion: DateTime.now(),
      );

      _recalcular();

      debugPrint(
        '[ClientsProvider] ${state.todos.length} clientes cargados '
        '(${state.filtrados.length} tras filtro ${state.filtro})',
      );
    } catch (e, stack) {
      debugPrint('[ClientsProvider] Error en cargar(): $e');
      debugPrint('[ClientsProvider] Stack: $stack');
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  /// Cambia el filtro activo y recalcula la lista visible.
  void cambiarFiltro(FiltroClientes filtro) {
    state = state.copyWith(filtro: filtro);
    _recalcular();
    debugPrint(
      '[ClientsProvider] Filtro → $filtro (${state.filtrados.length})',
    );
  }

  /// Actualiza el texto de búsqueda y recalcula la lista visible.
  void buscar(String query) {
    state = state.copyWith(busqueda: query);
    _recalcular();
  }

  /// Vuelve a pedir los datos al repositorio.
  ///
  /// Alias explícito de [cargar] para que la UI distinga "pull to refresh"
  /// de la carga inicial.
  Future<void> refrescar() => cargar();

  // ═════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═════════════════════════════════════════════════════════════

  /// Recalcula [ClientsState.filtrados] y [ClientsState.counts] con el
  /// filtro y la búsqueda actuales, sin volver a tocar la red.
  void _recalcular() {
    state = state.copyWith(
      filtrados: _aplicarFiltros(state.todos, state.filtro, state.busqueda),
      counts: contarPorFiltro(),
    );
  }

  /// Cuántos items de [origen] cumplirían cada filtro.
  ///
  /// Reutiliza [_cumpleFiltro] para no duplicar las reglas de filtrado.
  Map<FiltroClientes, int> contarPorFiltro([List<ClientItem>? origen]) {
    final lista = origen ?? state.todos;
    return {
      for (final filtro in FiltroClientes.values)
        filtro: lista.where((i) => _cumpleFiltro(i, filtro)).length,
    };
  }

  /// Aplica filtro y búsqueda en memoria (AND lógico entre ambos).
  List<ClientItem> _aplicarFiltros(
    List<ClientItem> origen,
    FiltroClientes filtro,
    String busqueda,
  ) {
    final porFiltro = origen.where((i) => _cumpleFiltro(i, filtro));

    final q = busqueda.trim().toLowerCase();
    if (q.isEmpty) return porFiltro.toList();

    return porFiltro
        .where((i) => i.tenant.nombre.toLowerCase().contains(q))
        .toList();
  }

  /// Reglas de cada filtro.
  ///
  /// `activos` incluye a los tenants sin suscripción, para no ocultarlos
  /// del super admin que necesita verlos.
  bool _cumpleFiltro(ClientItem item, FiltroClientes filtro) {
    final sub = item.suscripcion;

    return switch (filtro) {
      FiltroClientes.todos => true,
      FiltroClientes.activos =>
        item.tenant.activo &&
            (sub == null ||
                sub.estado == EstadoSuscripcion.activo ||
                sub.estado == EstadoSuscripcion.trial),
      FiltroClientes.trial => sub?.estado == EstadoSuscripcion.trial,
      FiltroClientes.porVencer =>
        sub?.estado == EstadoSuscripcion.trial && sub!.trialPorVencer,
      FiltroClientes.vencidos =>
        sub?.estado == EstadoSuscripcion.vencido ||
            sub?.estado == EstadoSuscripcion.expirado,
      FiltroClientes.cancelados =>
        sub?.estado == EstadoSuscripcion.cancelado,
    };
  }
}

// ═══════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════

final clientsProvider =
    StateNotifierProvider<ClientsNotifier, ClientsState>((ref) {
  final notifier = ClientsNotifier(ref);
  // Carga inicial al construir el provider.
  notifier.cargar();
  return notifier;
});
