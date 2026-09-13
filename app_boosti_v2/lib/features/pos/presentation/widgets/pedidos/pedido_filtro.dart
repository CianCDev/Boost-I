// lib/features/pos/presentation/widgets/pedidos/pedidos_filtros.dart
import 'package:flutter/material.dart';
import '../common/filtro_chip_template.dart';
import '../common/metric_pedido.dart';

/// Enum de período de tiempo para filtrar pedidos.
enum PeriodoPedido { hoy, semana, mes, anio, todas }

/// Enum de estado para filtrar pedidos.
enum EstadoFiltroPedido { todos, pendiente, recibido, cancelado }

/// Sección completa de métricas + filtros de período + filtros de estado.
class PedidosFiltros extends StatelessWidget {
  final int total;
  final int pendientes;
  final int recibidos;
  final int cancelados;

  final PeriodoPedido periodoActual;
  final EstadoFiltroPedido estadoActual;

  final ValueChanged<PeriodoPedido> onPeriodoChanged;
  final ValueChanged<EstadoFiltroPedido> onEstadoChanged;

  const PedidosFiltros({
    super.key,
    required this.total,
    required this.pendientes,
    required this.recibidos,
    required this.cancelados,
    required this.periodoActual,
    required this.estadoActual,
    required this.onPeriodoChanged,
    required this.onEstadoChanged,
  });

  static const Color _colorTotal = Color(0xFF8B5CF6);
  static const Color _colorPendiente = Color(0xFFF59E0B);
  static const Color _colorRecibido = Color(0xFF10B981);
  static const Color _colorCancelado = Color(0xFFEF4444);
  static const Color _colorPeriodo = Color(0xFF3B82F6);
  static const Color _colorTodas = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ===== MÉTRICAS =====
        Row(
          children: [
            Expanded(
              child: MetricPedido(
                label: 'Total',
                value: total,
                color: _colorTotal,
                icon: Icons.list_alt_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricPedido(
                label: 'Pendientes',
                value: pendientes,
                color: _colorPendiente,
                icon: Icons.hourglass_top_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricPedido(
                label: 'Recibidos',
                value: recibidos,
                color: _colorRecibido,
                icon: Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricPedido(
                label: 'Cancelados',
                value: cancelados,
                color: _colorCancelado,
                icon: Icons.cancel_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ===== CONTENEDOR DE FILTROS =====
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Período ----
              _buildSectionTitle(
                'Filtrar por Período',
                Icons.date_range_rounded,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildPeriodoFilters(isMobile),

              // ---- Divisor ----
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),

              // ---- Estado ----
              _buildSectionTitle(
                'Filtrar por Estado',
                Icons.filter_alt_rounded,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildEstadoFilters(isMobile),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TÍTULO DE SECCIÓN
  // ============================================================
  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.black54),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTROS DE PERÍODO
  // ============================================================
  Widget _buildPeriodoFilters(bool isMobile) {
    final chips = <Widget>[
      FiltroChip(
        label: 'Hoy',
        icon: Icons.today_rounded,
        color: _colorPeriodo,
        selected: periodoActual == PeriodoPedido.hoy,
        onTap: () => onPeriodoChanged(PeriodoPedido.hoy),
        size: FiltroChipSize.medium,
      ),
      FiltroChip(
        label: 'Semana',
        icon: Icons.date_range_rounded,
        color: _colorPeriodo,
        selected: periodoActual == PeriodoPedido.semana,
        onTap: () => onPeriodoChanged(PeriodoPedido.semana),
        size: FiltroChipSize.medium,
      ),
      FiltroChip(
        label: 'Mes',
        icon: Icons.calendar_month_rounded,
        color: _colorPeriodo,
        selected: periodoActual == PeriodoPedido.mes,
        onTap: () => onPeriodoChanged(PeriodoPedido.mes),
        size: FiltroChipSize.medium,
      ),
      FiltroChip(
        label: 'Año',
        icon: Icons.calendar_today_rounded,
        color: _colorPeriodo,
        selected: periodoActual == PeriodoPedido.anio,
        onTap: () => onPeriodoChanged(PeriodoPedido.anio),
        size: FiltroChipSize.medium,
      ),
      FiltroChip(
        label: 'Todas',
        icon: Icons.all_inclusive_rounded,
        color: _colorTodas,
        selected: periodoActual == PeriodoPedido.todas,
        onTap: () => onPeriodoChanged(PeriodoPedido.todas),
        size: FiltroChipSize.medium,
      ),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              chips[i],
            ],
          ],
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: chips,
    );
  }

  // ============================================================
  // FILTROS DE ESTADO
  // ============================================================
  Widget _buildEstadoFilters(bool isMobile) {
    final chips = <Widget>[
      FiltroChip(
        label: 'Todos',
        icon: Icons.list_alt_rounded,
        color: _colorTotal,
        count: total,
        selected: estadoActual == EstadoFiltroPedido.todos,
        onTap: () => onEstadoChanged(EstadoFiltroPedido.todos),
        size: FiltroChipSize.medium,
      ),
      FiltroChip(
        label: 'Pendientes',
        icon: Icons.hourglass_top_rounded,
        color: _colorPendiente,
        count: pendientes,
        selected: estadoActual == EstadoFiltroPedido.pendiente,
        onTap: () => onEstadoChanged(EstadoFiltroPedido.pendiente),
        size: FiltroChipSize.medium,
      ),
      FiltroChip(
        label: 'Recibidos',
        icon: Icons.check_circle_rounded,
        color: _colorRecibido,
        count: recibidos,
        selected: estadoActual == EstadoFiltroPedido.recibido,
        onTap: () => onEstadoChanged(EstadoFiltroPedido.recibido),
        size: FiltroChipSize.medium,
      ),
      FiltroChip(
        label: 'Cancelados',
        icon: Icons.cancel_rounded,
        color: _colorCancelado,
        count: cancelados,
        selected: estadoActual == EstadoFiltroPedido.cancelado,
        onTap: () => onEstadoChanged(EstadoFiltroPedido.cancelado),
        size: FiltroChipSize.medium,
      ),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              chips[i],
            ],
          ],
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: chips,
    );
  }
}