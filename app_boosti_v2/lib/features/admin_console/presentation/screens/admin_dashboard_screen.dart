import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pos/presentation/utils/responsive_helper.dart';
import '../../../pos/presentation/widgets/common/card_action_button.dart';
import '../../data/models/plan.dart';
import '../../data/models/suscripcion.dart';
import '../../data/models/tenant.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../widgets/client_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/kpi_card.dart';
import '../widgets/section_header.dart';

/// Pantalla principal del Control Center.
///
/// Muestra las métricas agregadas (`saas_metrics`) y tres listados de
/// clientes que requieren atención. No dispara la carga: el
/// `adminDashboardProvider` ya carga al construirse.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  // Paleta de estados segun docs/business_rules.md.
  static const Color _verde = Color(0xFF10B981);
  static const Color _ambar = Color(0xFFF59E0B);
  static const Color _rojo = Color(0xFFEF4444);
  static const Color _violeta = Color(0xFF8B5CF6);

  /// Ancho máximo del contenido en desktop.
  static const double _anchoMaximo = 1400;

  /// Altura objetivo de cada KpiCard.
  static const double _altoKpi = 110;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminDashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // `metricas` es no-nullable, así que "nunca se cargó" se detecta con
    // `ultimaActualizacion == null`, no comparando las métricas con null.
    final nuncaCargado = state.ultimaActualizacion == null;

    if (state.cargando && nuncaCargado) {
      return _cargandoInicial(colorScheme);
    }

    // La pantalla de error completa solo se muestra si nunca hubo una
    // carga exitosa: si ya hay datos, un refresh fallido no debe
    // borrarlos de la vista.
    if (state.error != null && nuncaCargado) {
      return _pantallaError(state.error!, colorScheme);
    }

    return _contenido(state, colorScheme);
  }

  // ═════════════════════════════════════════════════════════════
  // ESTADOS
  // ═════════════════════════════════════════════════════════════

  Widget _cargandoInicial(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando dashboard...',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pantallaError(String error, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: EmptyState(
        icon: Icons.error_outline_rounded,
        titulo: 'Error al cargar',
        subtitulo: error,
        color: _rojo,
        accion: ElevatedButton.icon(
          onPressed: _reintentar,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Reintentar'),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // CONTENIDO
  // ═════════════════════════════════════════════════════════════

  Widget _contenido(AdminDashboardState state, ColorScheme colorScheme) {
    final esMobile = ResponsiveHelper.isMobile(context);
    final esDesktop = ResponsiveHelper.isDesktop(context);

    final paddingH = esMobile ? 16.0 : (esDesktop ? 32.0 : 24.0);
    final gapSecciones = esMobile ? 24.0 : 32.0;

    return Column(
      children: [
        // Refresco sutil sin perder el contenido ya cargado.
        if (state.cargando)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(paddingH, 20, paddingH, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _anchoMaximo),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(state, colorScheme),
                    SizedBox(height: gapSecciones),
                    _gridKpis(state),
                    SizedBox(height: gapSecciones),
                    _seccionTrials(state),
                    SizedBox(height: gapSecciones),
                    _seccionRiesgo(state),
                    SizedBox(height: gapSecciones),
                    _seccionCancelaciones(state),
                    if (state.error != null) ...[
                      SizedBox(height: gapSecciones),
                      _avisoError(state.error!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // HEADER
  // ═════════════════════════════════════════════════════════════

  Widget _header(AdminDashboardState state, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Última actualización: '
                '${_tiempoRelativo(state.ultimaActualizacion)}',
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
          tooltip: 'Refrescar métricas',
          onPressed: () =>
              ref.read(adminDashboardProvider.notifier).refrescar(),
        ),
      ],
    );
  }

  Widget _avisoError(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rojo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rojo.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: _rojo),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: _rojo),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(onPressed: _reintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // GRID DE KPIs
  // ═════════════════════════════════════════════════════════════

  Widget _gridKpis(AdminDashboardState state) {
    final m = state.metricas;

    // trendPercent/trendUp se dejan en null: la vista `saas_metrics` no
    // guarda histórico, así que todavía no hay con qué calcular variación.
    final kpis = <({String label, String value, IconData icon, Color color})>[
      (
        label: 'MRR',
        value: m.mrrFormateado,
        icon: Icons.attach_money_rounded,
        color: _verde
      ),
      (
        label: 'Clientes activos',
        value: m.clientesActivos.toString(),
        icon: Icons.people_alt_rounded,
        color: _violeta
      ),
      (
        label: 'Trials activos',
        value: m.trialsActivos.toString(),
        icon: Icons.hourglass_top_rounded,
        color: _ambar
      ),
      (
        label: 'Trials por vencer (3d)',
        value: m.trialsPorVencer3d.toString(),
        icon: Icons.timer_rounded,
        color: _ambar
      ),
      (
        label: 'Cancelaciones (30d)',
        value: m.cancelaciones30d.toString(),
        icon: Icons.cancel_rounded,
        color: _rojo
      ),
      (
        label: 'ARR',
        value: m.arrFormateado,
        icon: Icons.trending_up_rounded,
        color: _verde
      ),
    ];

    final columnas = ResponsiveHelper.isMobile(context)
        ? 1
        : (ResponsiveHelper.isTablet(context) ? 2 : 4);
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoItem =
            (constraints.maxWidth - spacing * (columnas - 1)) / columnas;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: kpis.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: anchoItem / _altoKpi,
          ),
          itemBuilder: (context, i) {
            final k = kpis[i];
            return KpiCard(
              label: k.label,
              value: k.value,
              icon: k.icon,
              color: k.color,
            );
          },
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SECCIONES
  // ═════════════════════════════════════════════════════════════

  Widget _seccionTrials(AdminDashboardState state) {
    final items = state.trialsPorVencer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          titulo: 'Trials por vencer',
          icono: Icons.hourglass_top_rounded,
          subtitulo: 'Vencen en los próximos 3 días',
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_outline_rounded,
            titulo: 'Sin trials por vencer',
            subtitulo: 'Todos los trials están al día',
          )
        else
          ...items.map(
            (item) => ClientCard(
              tenant: item['tenant'] as Tenant,
              suscripcion: item['suscripcion'] as Suscripcion,
              plan: item['plan'] as Plan,
              diasRestantes: item['diasHastaVencimiento'] as int,
              subtituloDias: 'Vence en ${_pluralizarDias(
                item['diasHastaVencimiento'] as int,
              )}',
              // Los callbacks se conectan en la fase de "Ficha de Cliente".
              acciones: [
                CardActionButton(
                  icon: Icons.more_time_rounded,
                  color: _ambar,
                  tooltip: 'Extender 7 días',
                  onPressed: () {},
                ),
                CardActionButton(
                  icon: Icons.upgrade_rounded,
                  color: _verde,
                  tooltip: 'Convertir a plan pagado',
                  onPressed: () {},
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _seccionRiesgo(AdminDashboardState state) {
    final items = state.clientesEnRiesgo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          titulo: 'Clientes en riesgo',
          icono: Icons.warning_amber_rounded,
          subtitulo: 'Sin actividad en 15+ días',
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            icon: Icons.sentiment_satisfied_alt_rounded,
            titulo: 'Sin clientes en riesgo',
            subtitulo: 'Todos están activos',
          )
        else
          ...items.map(
            (item) => ClientCard(
              tenant: item['tenant'] as Tenant,
              suscripcion: item['suscripcion'] as Suscripcion,
              plan: item['plan'] as Plan,
              diasRestantes: item['diasInactivo'] as int,
              subtituloDias: 'Sin login hace ${_pluralizarDias(
                item['diasInactivo'] as int,
              )}',
            ),
          ),
      ],
    );
  }

  Widget _seccionCancelaciones(AdminDashboardState state) {
    final items = state.cancelacionesRecientes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          titulo: 'Cancelaciones recientes',
          icono: Icons.history_rounded,
          subtitulo: 'Últimos 30 días',
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            icon: Icons.celebration_rounded,
            titulo: 'Sin cancelaciones recientes',
            subtitulo: 'Buenas noticias',
          )
        else
          ...items.map(
            (item) => ClientCard(
              tenant: item['tenant'] as Tenant,
              suscripcion: item['suscripcion'] as Suscripcion,
              plan: item['plan'] as Plan,
              diasRestantes: item['diasDesdeCancelacion'] as int,
              subtituloDias: 'Canceló hace ${_pluralizarDias(
                item['diasDesdeCancelacion'] as int,
              )}',
            ),
          ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═════════════════════════════════════════════════════════════

  void _reintentar() {
    ref.read(adminDashboardProvider.notifier).cargar();
  }

  /// Fecha relativa corta: "hace 5 min", "hace 2 h", "hace 3 d".
  ///
  /// Implementación propia para no depender de `intl` ni de localización.
  String _tiempoRelativo(DateTime? fecha) {
    if (fecha == null) return 'Cargando...';

    final diff = DateTime.now().difference(fecha);
    if (diff.inSeconds < 60) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  /// Devuelve "1 día" o "N días" según corresponda.
  String _pluralizarDias(int cantidad) {
    return cantidad == 1 ? '1 día' : '$cantidad días';
  }
}
