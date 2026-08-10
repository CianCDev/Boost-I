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
            backgroundColor: Colors.redAccent,
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
        // ignore: unnecessary_to_list_in_spreads
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
        const SnackBar(
          content: Text('✅ Cierre procesado y ticket impreso'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al imprimir: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          isMobile ? 'Corte de Caja' : 'Corte de Caja Diario',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColorDark,
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar',
            onPressed: _cargarCorte,
          ),
        ],
      ),
      body: _buildBody(theme, isMobile, isTablet, padding, cardPadding, spacing,
          fontSizeTotal, fontSizeTitle, fontSizeSubtitle, fontSizeMonto),
    );
  }

  Widget _buildBody(
    ThemeData theme,
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
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              _descargando ? 'Descargando ventas...' : 'Calculando corte...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
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
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin datos disponibles',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
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
          _buildTotalCard(theme, isMobile, cardPadding, fontSizeTotal, fontSizeSubtitle),
          SizedBox(height: spacing),
          _buildPaymentMethodsCard(theme, isMobile, cardPadding,
              fontSizeTitle, fontSizeMonto, fontSizeSubtitle),
          SizedBox(height: spacing),
          _buildInfoCard(theme, isMobile, padding, fontSizeSubtitle),
          SizedBox(height: spacing * 1.5),
          _buildPrintButton(isMobile, theme),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTotalCard(
    ThemeData theme,
    bool isMobile,
    double cardPadding,
    double fontSizeTotal,
    double fontSizeSubtitle,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.attach_money_rounded,
                color: const Color(0xFF10B981),
                size: isMobile ? 22 : 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL RECAUDADO',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: isMobile ? 9 : 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${_resumen!.totalVentas.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeTotal,
                      color: const Color(0xFF10B981),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 2 : 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${_resumen!.cantidadTransacciones}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 18,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    'ventas',
                    style: TextStyle(
                      fontSize: isMobile ? 7 : 9,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MÉTODOS DE PAGO CON WRAP MEJORADO ESTÉTICAMENTE
  // ============================================================
  Widget _buildPaymentMethodsCard(
    ThemeData theme,
    bool isMobile,
    double cardPadding,
    double fontSizeTitle,
    double fontSizeMonto,
    double fontSizeSubtitle,
  ) {
    final methods = _resumen!.totalesPorMetodo;
    final totalMethods = methods.keys.length;

    // Ancho mínimo para cada elemento
    // ignore: unused_local_variable
    final double minItemWidth = isMobile ? 140 : 180;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: const Color(0xFF64748B),
                  size: isMobile ? 16 : 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Métodos de Pago',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeTitle,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$totalMethods',
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Wrap centrado con elementos de tamaño mínimo
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: methods.keys.map((metodo) {
                  final double monto = methods[metodo]!;
                  final Color color = _getColorMetodo(metodo);
                  final IconData icon = _getIconMetodo(metodo);

                  // Tamaño del elemento: mínimo, pero se expande si es necesario
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
                                  color: const Color(0xFF0F172A),
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
    ThemeData theme,
    bool isMobile,
    double padding,
    double fontSizeSubtitle,
  ) {
    final now = DateTime.now().toLocal();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: Colors.grey.shade50,
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
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${now.day}/${now.month}/${now.year}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.timer_outlined,
                  size: isMobile ? 12 : 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
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
                      ? const Color(0xFF10B981)
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  _resumen!.totalesPorMetodo.isNotEmpty ? 'OK' : 'Pendiente',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: _resumen!.totalesPorMetodo.isNotEmpty
                        ? const Color(0xFF10B981)
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintButton(bool isMobile, ThemeData theme) {
    return SizedBox(
      height: isMobile ? 48 : 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
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