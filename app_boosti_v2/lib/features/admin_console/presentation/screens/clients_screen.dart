import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pos/presentation/utils/responsive_helper.dart';
import '../../../pos/presentation/widgets/common/card_action_button.dart';
import '../../../pos/presentation/widgets/common/filtro_chip_template.dart';
import '../../../pos/presentation/widgets/common/glass_search_bar.dart';
import '../../data/models/suscripcion.dart';
import '../../providers/clients_provider.dart';
import '../widgets/client_card.dart';
import '../widgets/empty_state.dart';
import 'client_detail_screen.dart';

/// Listado de clientes del Control Center con búsqueda y 6 filtros.
///
/// No declara `Scaffold` propio: se apoya en el que ya provee
/// `ControlCenterScreen`, igual que el Dashboard. Así no hay AppBar
/// duplicado ni Scaffolds anidados.
class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  // Paleta de estados segun docs/business_rules.md.
  static const Color _violeta = Color(0xFF8B5CF6);
  static const Color _verde = Color(0xFF10B981);
  static const Color _ambar = Color(0xFFF59E0B);
  static const Color _rojo = Color(0xFFEF4444);
  static const Color _gris = Colors.grey;

  /// Ancho máximo del contenido en desktop.
  static const double _anchoMaximo = 1400;

  /// Descripción visual de cada filtro.
  static const List<
      ({
        FiltroClientes filtro,
        String label,
        IconData icon,
        Color color,
      })> _filtros = [
    (
      filtro: FiltroClientes.todos,
      label: 'Todos',
      icon: Icons.people_rounded,
      color: _violeta
    ),
    (
      filtro: FiltroClientes.activos,
      label: 'Activos',
      icon: Icons.check_circle_rounded,
      color: _verde
    ),
    (
      filtro: FiltroClientes.trial,
      label: 'Trial',
      icon: Icons.hourglass_top_rounded,
      color: _ambar
    ),
    (
      filtro: FiltroClientes.porVencer,
      label: 'Por vencer',
      icon: Icons.timer_rounded,
      color: _ambar
    ),
    (
      filtro: FiltroClientes.vencidos,
      label: 'Vencidos',
      icon: Icons.error_rounded,
      color: _rojo
    ),
    (
      filtro: FiltroClientes.cancelados,
      label: 'Cancelados',
      icon: Icons.block_rounded,
      color: _gris
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final esMobile = ResponsiveHelper.isMobile(context);
    final paddingH = esMobile
        ? 16.0
        : (ResponsiveHelper.isDesktop(context) ? 32.0 : 24.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(paddingH, 20, paddingH, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _anchoMaximo),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(ref, state, colorScheme),
              const SizedBox(height: 16),
              GlassSearchBar(
                hint: 'Buscar clientes por nombre...',
                onChanged: (q) =>
                    ref.read(clientsProvider.notifier).buscar(q),
              ),
              const SizedBox(height: 12),
              _barraFiltros(ref, state),
              const SizedBox(height: 16),
              Expanded(child: _cuerpo(ref, state)),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // HEADER
  // ═════════════════════════════════════════════════════════════

  Widget _header(
    WidgetRef ref,
    ClientsState state,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Clientes',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subtituloContador(state),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        CardActionButton(
          icon: Icons.refresh_rounded,
          color: _violeta,
          tooltip: 'Refrescar clientes',
          onPressed: () =>
              ref.read(clientsProvider.notifier).refrescar(),
        ),
      ],
    );
  }

  /// "12 clientes" / "1 cliente" / "Cargando...".
  String _subtituloContador(ClientsState state) {
    if (state.cargando && state.todos.isEmpty) return 'Cargando...';
    final n = state.filtrados.length;
    return '$n ${n == 1 ? 'cliente' : 'clientes'}';
  }

  // ═════════════════════════════════════════════════════════════
  // FILTROS
  // ═════════════════════════════════════════════════════════════

  Widget _barraFiltros(WidgetRef ref, ClientsState state) {
    // Los counts vienen del state (reactivos), no del notifier.
    final counts = state.counts;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _filtros) ...[
            FiltroChip(
              label: f.label,
              icon: f.icon,
              color: f.color,
              selected: state.filtro == f.filtro,
              count: counts[f.filtro],
              onTap: () => ref
                  .read(clientsProvider.notifier)
                  .cambiarFiltro(f.filtro),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // CUERPO
  // ═════════════════════════════════════════════════════════════

  Widget _cuerpo(WidgetRef ref, ClientsState state) {
    // 1) Primera carga, sin datos todavía.
    if (state.cargando && state.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) Error en la carga, sin datos que mostrar.
    if (state.error != null && state.todos.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        titulo: 'Error al cargar',
        subtitulo: state.error,
        color: _rojo,
        accion: ElevatedButton(
          onPressed: () => ref.read(clientsProvider.notifier).cargar(),
          child: const Text('Reintentar'),
        ),
      );
    }

    // 3) Sin resultados para el filtro/búsqueda actual.
    if (state.filtrados.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        titulo: 'Sin resultados',
        subtitulo: 'Prueba con otro filtro o búsqueda',
      );
    }

    // 4) Lista.
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: state.filtrados.length,
      itemBuilder: (context, i) {
        final item = state.filtrados[i];
        return ClientCard(
          tenant: item.tenant,
          suscripcion: item.suscripcion,
          plan: item.plan,
          diasRestantes: null,
          subtituloDias: _subtituloPorEstado(item),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClientDetailScreen(tenantId: item.tenant.id),
              ),
            );
          },
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═════════════════════════════════════════════════════════════

  /// Sufijo de estado para el subtítulo de la tarjeta.
  ///
  /// **No** incluye el nombre del plan: `ClientCard._subtitulo()` ya lo
  /// antepone, y devolverlo aquí duplicaba ("Trial · Trial · Activo · …").
  ///
  /// El criterio de trial es el mismo que `_etiquetaPeriodo` del tab
  /// Suscripción, y por eso se comprueba por plan **y** por estado:
  /// `actualizarPlan` solo cambia `plan_id`, así que existe
  /// `plan_id = 'trial'` con `estado = 'activo'`; y `trial_vence_en` queda
  /// poblado en planes de pago, así que mirar solo la fecha mostraría
  /// «Trial vence en» en un plan Pro.
  String _subtituloPorEstado(ClientItem item) {
    final sub = item.suscripcion;
    if (sub == null) return 'Sin suscripción';

    if (sub.estado == EstadoSuscripcion.cancelado) {
      return 'Cancelado hace ${_dias(_diasDesde(sub.canceladoEn))}';
    }

    if (sub.estado == EstadoSuscripcion.vencido ||
        sub.estado == EstadoSuscripcion.expirado) {
      return 'Vencido';
    }

    final diasTrial = sub.diasRestantesTrial;
    final hayTrialVigente = diasTrial != null && diasTrial >= 0;
    final esPlanTrial = item.plan?.id == 'trial';

    if (hayTrialVigente &&
        (esPlanTrial || sub.estado == EstadoSuscripcion.trial)) {
      return 'Trial vence en ${_dias(diasTrial)}';
    }

    if (sub.estado == EstadoSuscripcion.activo) {
      return 'Activo · Renueva en ${_dias(_diasHasta(sub.periodoActualFin))}';
    }

    return sub.estado.label;
  }

  /// "1 día" o "N días". `null` o negativo → "—".
  String _dias(int? cantidad) {
    if (cantidad == null) return '—';
    if (cantidad <= 0) return '—';
    return cantidad == 1 ? '1 día' : '$cantidad días';
  }

  /// Días restantes hasta [fin].
  int? _diasHasta(DateTime? fin) {
    if (fin == null) return null;
    return fin.difference(DateTime.now()).inDays;
  }

  /// Días transcurridos desde [momento].
  int? _diasDesde(DateTime? momento) {
    if (momento == null) return null;
    return DateTime.now().difference(momento).inDays;
  }
}
