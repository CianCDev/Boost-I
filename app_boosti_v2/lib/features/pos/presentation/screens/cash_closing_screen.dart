import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cash_register_service.dart';
import '../services/ticket_service.dart';
import '../services/ticket_generator.dart';
import '../services/sync_service.dart';
import '../providers/esc_pos_provider.dart';
import '../utils/responsive_helper.dart';

class CashClosingScreen extends ConsumerStatefulWidget {
  const CashClosingScreen({super.key});

  @override
  ConsumerState<CashClosingScreen> createState() => _CashClosingScreenState();
}

class _CashClosingScreenState extends ConsumerState<CashClosingScreen>
    with SingleTickerProviderStateMixin {
  final CashRegisterService _cashService = CashRegisterService();
  final SyncService _syncService = SyncService();
  bool _isLoading = true;
  bool _descargando = false;
  ResumenCorteCaja? _resumen;

  static const Map<String, Color> _coloresMetodo = {
    'Efectivo': Color(0xFF10B981),
    'Tarjeta': Color(0xFF3B82F6),
    'Pago Móvil': Color(0xFF8B5CF6),
    'Divisas': Color(0xFFF59E0B),
    'Pago Mixto': Color(0xFFEC4899),
    'Otros': Color(0xFF64748B),
  };

  static const Map<String, IconData> _iconosMetodo = {
    'Efectivo': Icons.money_rounded,
    'Tarjeta': Icons.credit_card_rounded,
    'Pago Móvil': Icons.phone_android_rounded,
    'Divisas': Icons.currency_exchange_rounded,
    'Pago Mixto': Icons.swap_horiz_rounded,
    'Otros': Icons.more_horiz_rounded,
  };

  Color _getColorMetodo(String metodo) {
    return _coloresMetodo[metodo] ?? _coloresMetodo['Otros']!;
  }

  IconData _getIconMetodo(String metodo) {
    return _iconosMetodo[metodo] ?? _iconosMetodo['Otros']!;
  }

  @override
  void initState() {
    super.initState();
    _cargarCorte();
  }

  Future<void> _cargarCorte() async {
    setState(() => _isLoading = true);
    try {
      setState(() => _descargando = true);
      await _syncService.descargarVentasDesdeSupabase();
      setState(() => _descargando = false);

      final resumen = await _cashService.calcularCorteDelDia();
      if (mounted) {
        setState(() {
          _resumen = resumen;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _descargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el corte: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _ejecutarCierreYGuardarPdf() async {
    if (_resumen == null) return;

    try {
      final selectedPrinter = ref.read(printerProvider);

      final List<TicketItem> items = [
        TicketItem(
          nombre: 'CIERRE DE CAJA - ${DateTime.now().toLocal().toString().substring(0, 16)}',
          precio: _resumen!.totalVentas,
          cantidad: 1.0,
          esPesado: false,
        ),
        ..._resumen!.totalesPorMetodo.entries.map((entry) {
          return TicketItem(
            nombre: '  ${entry.key}:',
            precio: entry.value,
            cantidad: 1.0,
            esPesado: false,
          );
        }).toList(),
      ];

      await TicketService.imprimirTicketVenta(
        context: context,
        items: items,
        total: _resumen!.totalVentas,
        metodoPago: 'Cierre de Caja',
        montoRecibido: _resumen!.totalVentas,
        cambio: 0.0,
        impuesto: 0.0,
        subtotal: _resumen!.totalVentas,
        fechaVenta: DateTime.now(),
        impresoraSeleccionada: selectedPrinter?.device,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Cierre procesado y ticket impreso'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al imprimir: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final double padding = isMobile ? 10 : 20;
    final double cardPadding = isMobile ? 12 : 20;
    final double spacing = isMobile ? 8 : 14;

    final double fontSizeTotal = isMobile ? 24 : (isTablet ? 36 : 44);
    final double fontSizeTitle = isMobile ? 14 : (isTablet ? 18 : 22);
    final double fontSizeSubtitle = isMobile ? 10 : (isTablet ? 12 : 14);
    final double fontSizeMonto = isMobile ? 12 : (isTablet ? 18 : 22);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          isMobile ? 'Corte de Caja' : 'Corte de Caja Diario',
          style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
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
                    colors: [Color.fromRGBO(68, 109, 241, 1), Color.fromARGB(255, 85, 59, 235)],
                  ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            tooltip: 'Actualizar',
            onPressed: _cargarCorte,
          ),
        ],
      ),
      body: _buildBody(
        context,
        colorScheme,
        isDark,
        isMobile,
        isTablet,
        padding,
        cardPadding,
        spacing,
        fontSizeTotal,
        fontSizeTitle,
        fontSizeSubtitle,
        fontSizeMonto,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
    bool isTablet,
    double padding,
    double cardPadding,
    double spacing,
    double fontSizeTotal,
    double fontSizeTitle,
    double fontSizeSubtitle,
    double fontSizeMonto,
  ) {
    if (_isLoading || _descargando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              _descargando ? 'Descargando ventas...' : 'Calculando corte...',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: fontSizeSubtitle,
              ),
            ),
          ],
        ),
      );
    }

    if (_resumen == null) {
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
                fontSize: fontSizeSubtitle,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTotalCard(colorScheme, isDark, isMobile, cardPadding, fontSizeTotal, fontSizeSubtitle),
          SizedBox(height: spacing),
          _buildPaymentMethodsCard(colorScheme, isDark, isMobile, cardPadding, fontSizeTitle, fontSizeMonto, fontSizeSubtitle),
          SizedBox(height: spacing),
          _buildInfoCard(colorScheme, isDark, isMobile, padding, fontSizeSubtitle),
          SizedBox(height: spacing * 1.5),
          _buildPrintButton(colorScheme, isDark, isMobile),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ✅ CONTENEDOR DE TOTAL MEJORADO (más visible)
  Widget _buildTotalCard(
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
    double cardPadding,
    double fontSizeTotal,
    double fontSizeSubtitle,
  ) {
    return Card(
      elevation: isDark ? 16 : 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.4),
          width: 2.5,
        ),
      ),
      color: colorScheme.surface,
      shadowColor: isDark
          ? colorScheme.primary.withValues(alpha: 0.5)
          : colorScheme.primary.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.primary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding * 1.2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  color: colorScheme.primary,
                  size: isMobile ? 32 : 42,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL RECAUDADO',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: isMobile ? 10 : 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_resumen!.totalVentas.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: fontSizeTotal * 1.1,
                        color: colorScheme.primary,
                        shadows: [
                          Shadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 6 : 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_resumen!.cantidadTransacciones}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 18 : 24,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'ventas',
                      style: TextStyle(
                        fontSize: isMobile ? 8 : 10,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard(
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
    double cardPadding,
    double fontSizeTitle,
    double fontSizeMonto,
    double fontSizeSubtitle,
  ) {
    final methods = _resumen!.totalesPorMetodo;
    final totalMethods = methods.keys.length;

    return Card(
      elevation: isDark ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.surface,
      shadowColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: isMobile ? 16 : 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Métodos de Pago',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeTitle,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$totalMethods',
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 11,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: methods.keys.map((metodo) {
                  final double monto = methods[metodo]!;
                  final Color color = _getColorMetodo(metodo);
                  final IconData icon = _getIconMetodo(metodo);

                  final double itemWidth = isMobile ? 140 : 180;

                  return Container(
                    width: itemWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 16,
                      vertical: isMobile ? 10 : 14,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: isMobile ? 18 : 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                metodo,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? 12 : 14,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${monto.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 14 : 20,
                                  color: color,
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
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
    double padding,
    double fontSizeSubtitle,
  ) {
    final now = DateTime.now().toLocal();

    return Card(
      elevation: isDark ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: colorScheme.surfaceContainerHighest,
      shadowColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: isMobile ? 8 : 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: isMobile ? 12 : 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${now.day}/${now.month}/${now.year}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.timer_outlined,
                  size: isMobile ? 12 : 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  _resumen!.totalesPorMetodo.isNotEmpty
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  size: isMobile ? 16 : 20,
                  color: _resumen!.totalesPorMetodo.isNotEmpty
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  _resumen!.totalesPorMetodo.isNotEmpty ? 'OK' : 'Pendiente',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: _resumen!.totalesPorMetodo.isNotEmpty
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintButton(
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
  ) {
    return SizedBox(
      height: isMobile ? 48 : 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: isDark ? 8 : 3,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: _ejecutarCierreYGuardarPdf,
        icon: Icon(
          Icons.print_rounded,
          size: isMobile ? 18 : 24,
        ),
        label: Text(
          isMobile ? 'Imprimir' : 'Realizar Cierre y Guardar PDF',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 13 : 16,
          ),
        ),
      ),
    );
  }
}