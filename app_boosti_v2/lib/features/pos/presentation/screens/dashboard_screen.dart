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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);

    // Tamaños adaptativos para desktop/tablet
    final double paddingHorizontal = isMobile ? 8 : (isTablet ? 24 : 32);
    final double paddingVertical = isMobile ? 8 : (isTablet ? 24 : 32);
    final double gridSpacing = isMobile ? 12 : (isTablet ? 16 : 20);
    final double childAspectRatio = isMobile ? 1.2 : (isTablet ? 1.4 : 1.6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Panel de Control',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 2,
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
                : Icon(
                    Icons.refresh_rounded,
                    color: theme.appBarTheme.foregroundColor,
                  ),
            onPressed: estado.isLoading ? null : () => notifier.refrescar(),
            tooltip: 'Refrescar',
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Última actualización: ${_formatFecha(estado.ultimaActualizacion)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.appBarTheme.foregroundColor?.withValues(alpha: 0.7),
                  ),
                ),
              ),
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
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical,
                      ),
                      child: Column(
                        children: [
                          _buildMetricas(
                            estado,
                            notifier,
                            isMobile,
                            gridSpacing,
                            childAspectRatio,
                          ),
                          const SizedBox(height: 16),
                          SalesChart(
                            datos: estado.ventasPorDia,
                            compacto: isMobile,
                          ),
                          const SizedBox(height: 16),
                          if (isMobile) ...[
                            TopProductsList(productos: estado.topProductos),
                            const SizedBox(height: 16),
                            LowStockList(productos: estado.stockBajo),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: TopProductsList(
                                    productos: estado.topProductos,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 5,
                                  child: LowStockList(
                                    productos: estado.stockBajo,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (isMobile) ...[
                            EmployeeActivity(empleados: estado.ventasPorEmpleado),
                            const SizedBox(height: 16),
                            RecentSalesList(ventas: estado.ultimasVentas),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: EmployeeActivity(
                                    empleados: estado.ventasPorEmpleado,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 6,
                                  child: RecentSalesList(
                                    ventas: estado.ultimasVentas,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // ==========================================
  // MÉTRICAS
  // ==========================================
  Widget _buildMetricas(
    DashboardState estado,
    DashboardNotifier notifier,
    bool isMobile,
    double spacing,
    double aspectRatio,
  ) {
    final crossAxisCount = isMobile ? 2 : 4;

    final metricas = [
      MetricCard(
        titulo: 'Total Hoy',
        valor: notifier.totalHoyFormateado,
        icono: Icons.today_rounded,
        color: Colors.blue.shade600,
        subtitulo: '${estado.ventasHoy} ventas',
        index: 0,
      ),
      MetricCard(
        titulo: 'Total Semana',
        valor: notifier.totalSemanaFormateado,
        icono: Icons.calendar_view_week_rounded,
        color: Colors.purple.shade600,
        index: 1,
      ),
      MetricCard(
        titulo: 'Total Mes',
        valor: notifier.totalMesFormateado,
        icono: Icons.calendar_month_rounded,
        color: Colors.teal.shade600,
        subtitulo: 'Gastos: ${notifier.totalGastosMesFormateado}',
        subtituloColor: Colors.red.shade600,
        index: 2,
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
      childAspectRatio: aspectRatio,
      children: metricas,
    );
  }

  // ==========================================
  // ERROR WIDGET
  // ==========================================
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

  // ==========================================
  // FOOTER
  // ==========================================
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

  // ==========================================
  // UTILIDADES
  // ==========================================
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