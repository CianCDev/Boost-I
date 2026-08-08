import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cash_register_service.dart';
import '../services/ticket_service.dart';
import '../services/ticket_generator.dart';
import '../providers/esc_pos_provider.dart';
import '../utils/responsive_helper.dart';

class CashClosingScreen extends ConsumerStatefulWidget {
  const CashClosingScreen({super.key});

  @override
  ConsumerState<CashClosingScreen> createState() => _CashClosingScreenState();
}

class _CashClosingScreenState extends ConsumerState<CashClosingScreen> {
  final CashRegisterService _cashService = CashRegisterService();
  bool _isLoading = true;
  ResumenCorteCaja? _resumen;

  // Colores por método de pago (igual que en CobrarDialog)
  static const Map<String, Color> _coloresMetodo = {
    'Efectivo': Color(0xFF10B981),
    'Tarjeta': Color(0xFF3B82F6),
    'Pago Móvil': Color(0xFF8B5CF6),
    'Divisas': Color(0xFFF59E0B),
    'Pago Mixto': Color(0xFFEC4899),
    'Otros': Color(0xFF64748B),
  };

  Color _getColorMetodo(String metodo) {
    return _coloresMetodo[metodo] ?? _coloresMetodo['Otros']!;
  }

  @override
  void initState() {
    super.initState();
    _cargarCorte();
  }

  Future<void> _cargarCorte() async {
    setState(() => _isLoading = true);
    try {
      final resumen = await _cashService.calcularCorteDelDia();
      if (mounted) {
        setState(() {
          _resumen = resumen;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al calcular el corte: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ✅ CORREGIDO: ahora usa ref para la impresora y los parámetros correctos
  Future<void> _ejecutarCierreYGuardarPdf() async {
    if (_resumen == null) return;

    try {
      // 1. Obtener la impresora seleccionada desde Riverpod
      final selectedPrinter = ref.read(printerProvider);

      // 2. Construir el ticket de resumen (con un solo ítem que muestre el total)
      final List<TicketItem> items = [
        TicketItem(
          nombre: 'CIERRE DE CAJA - ${DateTime.now().toLocal().toString().substring(0, 16)}',
          precio: _resumen!.totalVentas,
          cantidad: 1.0,
          esPesado: false,
        ),
      ];

      // 3. Llamar al servicio de impresión con los parámetros correctos
      await TicketService.imprimirTicketVenta(
        context: context, // ← OBLIGATORIO
        items: items,      // ← Usamos la lista items, no itemsArqueo
        total: _resumen!.totalVentas,
        metodoPago: 'Cierre de Caja',
        montoRecibido: _resumen!.totalVentas, // Para el ticket
        cambio: 0.0,
        impuesto: 0.0,
        subtotal: _resumen!.totalVentas,
        fechaVenta: DateTime.now(),
        impresoraSeleccionada: selectedPrinter?.device,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cierre de caja procesado y ticket impreso con éxito! 📄'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al imprimir el cierre: $e'),
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

    // Ajustes de tamaño (sin cambios)
    final double paddingHorizontal = isMobile ? 16 : (isTablet ? 24 : 32);
    final double paddingVertical = isMobile ? 12 : 20;
    final double fontSizeTotal = isMobile ? 28 : (isTablet ? 36 : 42);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Corte de Caja Diario',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
            tooltip: 'Actualizar Corte',
            onPressed: _cargarCorte,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.primaryColor,
                ),
              ),
            )
          : _resumen == null
              ? Center(
                  child: Text(
                    'No hay datos disponibles',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TARJETA PRINCIPAL (TOTAL)
                      Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F172A),
                              Color(0xFF1E293B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TOTAL RECAUDADO HOY',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${_resumen!.totalVentas.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: const Color(0xFF34D399),
                                      fontSize: fontSizeTotal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 14 : 20,
                                vertical: isMobile ? 8 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF10B981),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Transacciones',
                                    style: TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_resumen!.cantidadTransacciones}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 18 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TÍTULO DESGLOSE
                      Text(
                        'Desglose por Método de Pago',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 16 : (isTablet ? 18 : 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // GRID DE MÉTODOS (COMPACTO EN MÓVIL)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
                          crossAxisSpacing: isMobile ? 10 : 14,
                          mainAxisSpacing: isMobile ? 10 : 14,
                          childAspectRatio: isMobile ? 2.0 : 1.8,
                        ),
                        itemCount: _resumen!.totalesPorMetodo.keys.length,
                        itemBuilder: (context, index) {
                          final String metodo =
                              _resumen!.totalesPorMetodo.keys.elementAt(index);
                          final double monto =
                              _resumen!.totalesPorMetodo[metodo]!;
                          final int cantidad =
                              _resumen!.conteoPorMetodo[metodo]!;
                          final Color color = _getColorMetodo(metodo);

                          // Tamaños adaptados
                          final double fontSizeNombre =
                              isMobile ? 12 : (isTablet ? 14 : 16);
                          final double fontSizeMonto =
                              isMobile ? 16 : (isTablet ? 20 : 24);
                          final double paddingInterno =
                              isMobile ? 10 : (isTablet ? 14 : 18);

                          return Container(
                            padding: EdgeInsets.all(paddingInterno),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Fila superior: círculo + nombre + badge
                                Row(
                                  children: [
                                    Container(
                                      width: isMobile ? 8 : 10,
                                      height: isMobile ? 8 : 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        metodo,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSizeNombre,
                                          color: theme
                                              .textTheme.bodyMedium?.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Badge "ops"
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 4 : 8,
                                        vertical: isMobile ? 1 : 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$cantidad',
                                        style: TextStyle(
                                          fontSize: isMobile ? 9 : 11,
                                          fontWeight: FontWeight.w500,
                                          color: theme.textTheme.bodySmall
                                              ?.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Monto
                                Text(
                                  '\$${monto.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: fontSizeMonto,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // BOTÓN DE CIERRE
                      SizedBox(
                        height: isMobile ? 52 : 60,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF10B981)
                                .withValues(alpha: 0.3),
                          ),
                          onPressed: _ejecutarCierreYGuardarPdf,
                          icon: Icon(
                            Icons.print,
                            size: isMobile ? 20 : 24,
                          ),
                          label: Text(
                            'Realizar Cierre y Guardar PDF',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}