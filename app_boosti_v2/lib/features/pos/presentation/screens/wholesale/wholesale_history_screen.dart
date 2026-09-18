// lib/features/pos/presentation/screens/wholesale/wholesale_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/wholesale/wholesale_history_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/glass_search_bar.dart';
import '../../widgets/wholesale/wholesale_sale_tile.dart';
import 'wholesale_sale_detail_screen.dart';

class WholesaleHistoryScreen extends ConsumerStatefulWidget {
  const WholesaleHistoryScreen({super.key});

  @override
  ConsumerState<WholesaleHistoryScreen> createState() =>
      _WholesaleHistoryScreenState();
}

class _WholesaleHistoryScreenState
    extends ConsumerState<WholesaleHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────── Date picker ────────────────

  Future<void> _abrirRangoPersonalizado() async {
    final state = ref.read(wholesaleHistoryProvider);
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: state.filtros.fechaDesde != null &&
              state.filtros.fechaHasta != null
          ? DateTimeRange(
              start: state.filtros.fechaDesde!,
              end: state.filtros.fechaHasta!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF10B981),
                ),
          ),
          child: child!,
        );
      },
    );

    if (rango == null) return;
    final fin = DateTime(
      rango.end.year,
      rango.end.month,
      rango.end.day,
      23,
      59,
      59,
    );
    ref
        .read(wholesaleHistoryProvider.notifier)
        .setRangoPersonalizado(rango.start, fin);
  }

  // ──────────────── Build ────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final state = ref.watch(wholesaleHistoryProvider);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Historial al Mayor',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: () =>
                ref.read(wholesaleHistoryProvider.notifier).cargar(),
            icon: const Icon(Icons.refresh_rounded, size: 22),
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Column(
              children: [
                // ── Banner KPIs ──
                _buildKpis(state, isMobile),

                // ── Filtros de rango ──
                _buildRangoChips(state.filtros),

                // ── Buscador ──
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 12 : 20,
                    8,
                    isMobile ? 12 : 20,
                    8,
                  ),
                  child: GlassSearchBar(
                    hint: 'Buscar por cliente, RIF, documento o empleado…',
                    controller: _searchController,
                    onChanged: (v) => ref
                        .read(wholesaleHistoryProvider.notifier)
                        .setBusqueda(v),
                    accentColor: const Color(0xFF10B981),
                  ),
                ),

                // ── Lista de ventas ──
                Expanded(
                  child: _buildLista(state, isMobile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────── KPIs ────────────────

  Widget _buildKpis(WholesaleHistoryState state, bool isMobile) {
    // ignore: unused_local_variable
    final cs = Theme.of(context).colorScheme;

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _kpiChip(
              icon: Icons.receipt_long_rounded,
              label: 'Ventas',
              value: '${state.cantidadVentas}',
              color: const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            _kpiChip(
              icon: Icons.attach_money_rounded,
              label: 'Total USD',
              value: '\$${state.totalVentasUsd.toStringAsFixed(2)}',
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 8),
            _kpiChip(
              icon: Icons.trending_up_rounded,
              label: 'Promedio',
              value: '\$${state.ticketPromedio.toStringAsFixed(2)}',
              color: const Color(0xFF8B5CF6),
            ),
            if (state.totalDescuentosUsd > 0) ...[
              const SizedBox(width: 8),
              _kpiChip(
                icon: Icons.percent_rounded,
                label: 'Descuentos',
                value: '-\$${state.totalDescuentosUsd.toStringAsFixed(2)}',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _kpiCard(
              icon: Icons.receipt_long_rounded,
              label: 'Ventas',
              value: '${state.cantidadVentas}',
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kpiCard(
              icon: Icons.attach_money_rounded,
              label: 'Total USD',
              value: '\$${state.totalVentasUsd.toStringAsFixed(2)}',
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kpiCard(
              icon: Icons.trending_up_rounded,
              label: 'Promedio',
              value: '\$${state.ticketPromedio.toStringAsFixed(2)}',
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kpiCard(
              icon: Icons.percent_rounded,
              label: 'Descuentos',
              value: '-\$${state.totalDescuentosUsd.toStringAsFixed(2)}',
              color: const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kpiCard(
              icon: Icons.verified_user_rounded,
              label: 'Con autorización',
              value: '${state.ventasConAutorizacion}',
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────── Chips de rango ────────────────

  Widget _buildRangoChips(WholesaleHistoryFilters filtros) {
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final r in WholesaleHistoryRange.values) ...[
              if (r != WholesaleHistoryRange.personalizado)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _rangoChip(
                    label: r.label,
                    selected: filtros.rango == r,
                    onTap: () =>
                        ref.read(wholesaleHistoryProvider.notifier).setRango(r),
                  ),
                ),
            ],
            _rangoChip(
              label: 'Rango',
              icon: Icons.calendar_month_rounded,
              selected: filtros.rango == WholesaleHistoryRange.personalizado,
              onTap: _abrirRangoPersonalizado,
            ),
            const SizedBox(width: 12),
            if (filtros.tieneFiltrosActivos)
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  ref.read(wholesaleHistoryProvider.notifier).limpiarFiltros();
                },
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Limpiar', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _rangoChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final color = const Color(0xFF10B981);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.6)
                  : Colors.grey.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? color : Colors.grey,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── Lista ────────────────

  Widget _buildLista(WholesaleHistoryState state, bool isMobile) {
    if (state.cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (state.error != null) {
      return _buildError(state.error!);
    }

    if (state.ventas.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        4,
        isMobile ? 12 : 20,
        24,
      ),
      itemCount: state.ventas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final venta = state.ventas[i];
        return WholesaleSaleTile(
          venta: venta,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WholesaleSaleDetailScreen(venta: venta),
              ),
            );
          },
        );
      },
    );
  }

  // ──────────────── Empty ────────────────

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 72,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin ventas en este período',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Prueba ampliar el rango de fechas o limpiar los filtros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(wholesaleHistoryProvider.notifier).cargar(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}