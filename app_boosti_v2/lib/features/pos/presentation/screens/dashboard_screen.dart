// lib/features/pos/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard/metric_card.dart';
import '../widgets/dashboard/sales_chart.dart';
import '../widgets/dashboard/top_products_list.dart';
import '../widgets/dashboard/low_stock_list.dart';
import '../widgets/dashboard/employee_activity.dart';
import '../widgets/dashboard/recent_sales_list.dart';
import '../widgets/dashboard/dashboard_skeleton.dart';
import '../widgets/appbar.dart';
import '../utils/responsive_helper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _cargaInicial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).cargarDatos();
      _cargaInicial = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: isMobile ? 'Estadísticas' : 'Estadísticas Generales',
        showBackButton: true,
        centerTitle: false,
        actions: [
          IconButton(
            icon: estado.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: estado.isLoading ? null : () => notifier.refrescar(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: estado.isLoading && !_cargaInicial
            ? const DashboardSkeleton(key: ValueKey('skeleton'))
            : estado.error != null
                ? _buildErrorWidget(estado.error!, notifier)
                : RefreshIndicator(
                    key: const ValueKey('content'),
                    onRefresh: notifier.refrescar,
                    color: theme.colorScheme.primary,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
                        final isDesktop = constraints.maxWidth >= 1200;

                        final double horizontalPadding = isMobile ? 12 : (isTablet ? 24 : 32);
                        final double verticalPadding = isMobile ? 8 : (isTablet ? 16 : 24);
                        final double spacing = isMobile ? 12 : (isTablet ? 16 : 20);

                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding,
                          ),
                          child: Column(
                            children: [
                              // ✅ Grid de métricas
                              _buildMetricas(
                                estado,
                                notifier,
                                isMobile,
                                isTablet,
                                isDesktop,
                                spacing,
                              ),
                              const SizedBox(height: 16),

                              // ✅ Gráfico principal
                              SalesChart(
                                datos: estado.ventasPorDia,
                                compacto: isMobile,
                              ),
                              const SizedBox(height: 16),

                              // ✅ Grid inferior (2 columnas en escritorio)
                              if (isMobile) ...[
                                const TopProductsList(),
                                const SizedBox(height: 16),
                                LowStockList(productos: estado.stockBajo),
                                const SizedBox(height: 16),
                                EmployeeActivity(empleados: estado.ventasPorEmpleado),
                                const SizedBox(height: 16),
                                RecentSalesList(ventas: estado.ultimasVentas),
                              ] else ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Izquierda: Top productos + Stock crítico
                                    Expanded(
                                      flex: isTablet ? 5 : 5,
                                      child: Column(
                                        children: [
                                          const TopProductsList(),
                                          const SizedBox(height: 16),
                                          LowStockList(
                                            productos: estado.stockBajo,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Derecha: Empleados + Ventas recientes
                                    Expanded(
                                      flex: isTablet ? 5 : 6,
                                      child: Column(
                                        children: [
                                          EmployeeActivity(
                                            empleados: estado.ventasPorEmpleado,
                                          ),
                                          const SizedBox(height: 16),
                                          RecentSalesList(
                                            ventas: estado.ultimasVentas,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),

                              // ✅ Footer
                              _buildFooter(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  // ============================================================
  // GRID DE MÉTRICAS
  // ============================================================
  Widget _buildMetricas(
    DashboardState estado,
    DashboardNotifier notifier,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    double spacing,
  ) {
    int crossAxisCount;
    double childAspectRatio;

    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.2;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 1.4;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.6;
    }

    final metricas = [
      MetricCard(
        titulo: 'Total Hoy',
        valor: notifier.totalHoyFormateado,
        icono: Icons.today_rounded,
        color: const Color(0xFF00E5FF),
        subtitulo: '${estado.ventasHoy} ventas',
        index: 0,
        variacion: notifier.variacionHoy,
        variacionPositiva: notifier.variacionHoy >= 0,
      ),
      MetricCard(
        titulo: 'Total Semana',
        valor: notifier.totalSemanaFormateado,
        icono: Icons.calendar_view_week_rounded,
        color: const Color(0xFFD500F9),
        index: 1,
        variacion: notifier.variacionSemana,
        variacionPositiva: notifier.variacionSemana >= 0,
      ),
      MetricCard(
        titulo: 'Total Mes',
        valor: notifier.totalMesFormateado,
        icono: Icons.calendar_month_rounded,
        color: const Color(0xFF00E676),
        subtitulo: 'Gastos: ${notifier.totalGastosMesFormateado}',
        subtituloColor: const Color(0xFFFF9100),
        index: 2,
        variacion: notifier.variacionMes,
        variacionPositiva: notifier.variacionMes >= 0,
      ),
      MetricCard(
        titulo: 'vs Ayer',
        valor: notifier.variacionFormateada,
        icono: notifier.variacionIcon,
        color: notifier.variacionColor,
        subtitulo: estado.variacion >= 0 ? '↑ Creciendo' : '↓ Decreciendo',
        subtituloColor: notifier.variacionColor,
        index: 3,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: metricas,
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================
  Widget _buildErrorWidget(String error, DashboardNotifier notifier) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: notifier.refrescar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================
  Widget _buildFooter() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'Datos actualizados en tiempo real • ${_formatFecha(DateTime.now())}',
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UTILIDADES
  // ============================================================
  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);

    if (diff.inSeconds < 60) {
      return 'hace ${diff.inSeconds} segundos';
    } else if (diff.inMinutes < 60) {
      return 'hace ${diff.inMinutes} minutos';
    } else if (diff.inHours < 24) {
      return 'hace ${diff.inHours} horas';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    }
  }
}