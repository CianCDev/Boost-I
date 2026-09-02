import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/cash_closing_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_summary_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_payment_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_confirm_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_button.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ticket_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/esc_pos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';


import '../services/cash_register_service.dart';

class CashClosingScreen extends ConsumerStatefulWidget {
  const CashClosingScreen({super.key});

  @override
  ConsumerState<CashClosingScreen> createState() => _CashClosingScreenState();
}

class _CashClosingScreenState extends ConsumerState<CashClosingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final state = ref.watch(cashClosingProvider);
    final notifier = ref.read(cashClosingProvider.notifier);

    final title = isMobile ? 'Cierre de Caja' : 'Cierre de Caja Diario';

    final gradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.9),
              colorScheme.primary,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2235), Color(0xFF2D3748)],
          );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: title,
        showBackButton: false,
        gradient: gradient,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar',
            onPressed: state.isLoading ? null : () => notifier.refrescar(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
          return FadeTransition(
            opacity: _animationController,
            child: _buildBody(
              context,
              state,
              notifier,
              colorScheme,
              isDark,
              isMobile,
              isTablet,
              crossAxisCount,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CashClosingState state,
    CashClosingNotifier notifier,
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
    bool isTablet,
    int crossAxisCount,
  ) {
    // Estado de carga
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando datos del cierre...',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
      );
    }

    // Error
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => notifier.refrescar(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final resumen = state.resumen;
    if (resumen == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin datos disponibles',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
      );
    }

    // Tarjetas de resumen
    final summaryItems = [
      _SummaryItem(
        title: 'Ventas Totales',
        value: '\$${resumen.totalVentas.toStringAsFixed(2)}',
        color: const Color(0xFF00E5FF),
        icon: Icons.attach_money_rounded,
        sparklineData: const [10, 20, 15, 30, 25, 40, 35],
      ),
      _SummaryItem(
        title: 'Efectivo',
        value: '\$${(resumen.totalesPorMetodo['Efectivo'] ?? 0.0).toStringAsFixed(2)}',
        color: const Color(0xFF00E676),
        icon: Icons.money_rounded,
        sparklineData: const [5, 10, 8, 15, 12, 20, 18],
      ),
      _SummaryItem(
        title: 'Tarjeta',
        value: '\$${(resumen.totalesPorMetodo['Tarjeta'] ?? 0.0).toStringAsFixed(2)}',
        color: const Color(0xFFD500F9),
        icon: Icons.credit_card_rounded,
        sparklineData: const [8, 12, 10, 18, 14, 22, 20],
      ),
      _SummaryItem(
        title: 'Transferencia',
        value: '\$${(resumen.totalesPorMetodo['Pago Móvil'] ?? 0.0).toStringAsFixed(2)}',
        color: const Color(0xFFFF9100),
        icon: Icons.phone_android_rounded,
        sparklineData: const [3, 7, 5, 10, 8, 14, 12],
      ),
    ];

    final padding = isMobile ? 12.0 : 20.0;
    final spacing = isMobile ? 8.0 : 14.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjetas de resumen
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: summaryItems.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: ClosingSummaryCard(
                      title: item.title,
                      value: item.value,
                      color: item.color,
                      icon: item.icon,
                      sparklineData: item.sparklineData,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: spacing * 2),

          // Detalle de métodos de pago
          ClosingPaymentCard(
            totalesPorMetodo: resumen.totalesPorMetodo,
            notifier: notifier,
            isMobile: isMobile,
            isTablet: isTablet,
          ),

          SizedBox(height: spacing),

          // Información de actualización
          _buildInfoRow(context, state, colorScheme, isMobile),

          SizedBox(height: spacing * 1.5),

          // Botón de cierre
          ClosingButton(
            isSyncing: state.isSyncing,
            total: resumen.totalVentas,
            onPress: () => _mostrarDialogoCierre(context, notifier, resumen),
            isMobile: isMobile,
            isTablet: isTablet,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    CashClosingState state,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    final now = DateTime.now().toLocal();
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: isMobile ? 14 : 18,
                    color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${now.day}/${now.month}/${now.year}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.timer_outlined,
                    size: isMobile ? 14 : 18,
                    color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.update_rounded,
                  size: isMobile ? 14 : 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Última actualización: hace ${_calcularTiempo(state.lastUpdated)}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calcularTiempo(DateTime updated) {
    final diff = DateTime.now().difference(updated);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  // Diálogo de confirmación con impresión integrada
  void _mostrarDialogoCierre(
    BuildContext context,
    CashClosingNotifier notifier,
    ResumenCorteCaja resumen,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClosingConfirmDialog(
        total: resumen.totalVentas,
        onConfirm: () async {
          // 1. Ejecutar cierre lógico
          await notifier.cerrarCaja();

          // 2. Si el cierre fue exitoso, imprimir ticket
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          if (context.mounted && !notifier.state.isSyncing) {
            await _imprimirCierre(context, resumen);
          }

          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Cierre de caja completado con éxito'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  // Método de impresión de cierre
  Future<void> _imprimirCierre(
    BuildContext context,
    ResumenCorteCaja resumen,
  ) async {
    try {
      final local = await IsarService().obtenerLocalActivo();
      final selectedPrinter = ref.read(printerProvider);

      debugPrint('🖨️ Imprimiendo cierre de caja - Total: ${resumen.totalVentas}');
      debugPrint('📊 Métodos: ${resumen.totalesPorMetodo}');

      await TicketService.imprimirTicketVenta(
        context: context,
        local: local,
        items: [],
        total: resumen.totalVentas,
        metodoPago: 'Cierre de Caja',
        montoRecibido: resumen.totalVentas,
        cambio: 0.0,
        impuesto: 0.0,
        subtotal: resumen.totalVentas,
        fechaVenta: DateTime.now(),
        impresoraSeleccionada: selectedPrinter?.device,
        tipo: TicketType.cierre, // ⭐ USAMOS EL TIPO CIERRE
        totalesPorMetodo: resumen.totalesPorMetodo,
        totalGeneral: resumen.totalVentas,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ticket de cierre impreso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error en _imprimirCierre: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Cierre realizado, pero error al imprimir: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

// ============================================================
// Clase auxiliar para los datos de resumen
// ============================================================
class _SummaryItem {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final List<double> sparklineData;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.sparklineData,
  });
}