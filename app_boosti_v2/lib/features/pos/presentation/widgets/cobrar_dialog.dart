import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bcv_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/input_decoration_helper.dart';

class CobrarDialog extends ConsumerStatefulWidget {
  final double totalAPagar;
  final List<Map<String, dynamic>> productos;

  const CobrarDialog({
    super.key,
    required this.totalAPagar,
    required this.productos,
  });

  @override
  ConsumerState<CobrarDialog> createState() => _CobrarDialogState();
}

class _CobrarDialogState extends ConsumerState<CobrarDialog> {
  final TextEditingController _efectivoUsdController = TextEditingController();
  final TextEditingController _efectivoBsController = TextEditingController();
  final TextEditingController _pagoMovilBsController = TextEditingController();
  final TextEditingController _puntoBsController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController(text: 'V-00000000');
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _nombreClienteController = TextEditingController();

  String _metodoPagoSeleccionado = 'Efectivo';

  final FocusNode _efectivoUsdFocus = FocusNode();
  final FocusNode _cedulaFocus = FocusNode();

  static const Color _colorEfectivo = Color(0xFF10B981);
  static const Color _colorPagoMovil = Color(0xFF3B82F6);
  static const Color _colorPunto = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _efectivoUsdController.text = widget.totalAPagar.toStringAsFixed(2);

    _cedulaFocus.addListener(() {
      if (_cedulaFocus.hasFocus && _cedulaController.text == 'V-00000000') {
        _cedulaController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _cedulaController.text.length,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _efectivoUsdFocus.requestFocus();
      _efectivoUsdController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _efectivoUsdController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _efectivoUsdController.dispose();
    _efectivoBsController.dispose();
    _pagoMovilBsController.dispose();
    _puntoBsController.dispose();
    _cedulaController.dispose();
    _referenciaController.dispose();
    _nombreClienteController.dispose();
    _efectivoUsdFocus.dispose();
    _cedulaFocus.dispose();
    super.dispose();
  }

  void _limpiarMetodos() {
    _efectivoUsdController.clear();
    _efectivoBsController.clear();
    _pagoMovilBsController.clear();
    _puntoBsController.clear();
  }

  void _pagarExactoUsd() {
    setState(() {
      _limpiarMetodos();
      _efectivoUsdController.text = widget.totalAPagar.toStringAsFixed(2);
    });
  }

  void _pagarExactoPagoMovil(double tasa) {
    if (tasa <= 0) return;
    final totalBs = widget.totalAPagar * tasa;
    setState(() {
      _limpiarMetodos();
      _pagoMovilBsController.text = totalBs.toStringAsFixed(2);
    });
  }

  void _pagarExactoPunto(double tasa) {
    if (tasa <= 0) return;
    final totalBs = widget.totalAPagar * tasa;
    setState(() {
      _limpiarMetodos();
      _puntoBsController.text = totalBs.toStringAsFixed(2);
    });
  }

  void _confirmarPago(double totalRecibidoUsd, double vueltoUsd, double tasa) {
    if (totalRecibidoUsd < (widget.totalAPagar - 0.01)) return;

    String metodoPrincipal = _metodoPagoSeleccionado;
    String? referencia = _referenciaController.text.trim().isEmpty ? null : _referenciaController.text.trim();
    String? nombreCliente = _nombreClienteController.text.trim().isEmpty ? null : _nombreClienteController.text.trim();

    final efUsd = double.tryParse(_efectivoUsdController.text) ?? 0.0;
    final pmBs = (double.tryParse(_pagoMovilBsController.text) ?? 0.0) / (tasa > 0 ? tasa : 1.0);
    final ptBs = (double.tryParse(_puntoBsController.text) ?? 0.0) / (tasa > 0 ? tasa : 1.0);

    if (pmBs > efUsd && pmBs > ptBs) {
      metodoPrincipal = 'Pago Móvil';
    } else if (ptBs > efUsd && ptBs > pmBs) {
      metodoPrincipal = 'Punto de Venta';
    } else if (efUsd > 0 && (pmBs > 0 || ptBs > 0)) {
      metodoPrincipal = 'Pago Mixto';
    }

    final String docTexto = _cedulaController.text.trim();
    final String documentoFinal = docTexto.isEmpty ? 'V-00000000' : docTexto;

    Navigator.of(context).pop({
      'procesado': true,
      'metodoPago': metodoPrincipal,
      'documento': documentoFinal,
      'cedulaCliente': documentoFinal,
      'montoRecibido': totalRecibidoUsd,
      'vuelto': vueltoUsd,
      'referencia': referencia,
      'nombreCliente': nombreCliente,
    });
  }

  Color _getColorMetodo() {
    switch (_metodoPagoSeleccionado) {
      case 'Efectivo':
        return _colorEfectivo;
      case 'Pago Móvil':
        return _colorPagoMovil;
      case 'Punto de Venta':
        return _colorPunto;
      default:
        return _colorEfectivo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double tasaBcv = ref.watch(bcvProvider).tasa;
    final double tasaValida = (tasaBcv.isNaN || tasaBcv <= 0) ? 1.0 : tasaBcv;

    final double efectivoUsd = double.tryParse(_efectivoUsdController.text) ?? 0.0;
    final double efectivoBs = double.tryParse(_efectivoBsController.text) ?? 0.0;
    final double pagoMovilBs = double.tryParse(_pagoMovilBsController.text) ?? 0.0;
    final double puntoBs = double.tryParse(_puntoBsController.text) ?? 0.0;

    final double totalRecibidoUsd = efectivoUsd +
        (efectivoBs / tasaValida) +
        (pagoMovilBs / tasaValida) +
        (puntoBs / tasaValida);

    final double totalBs = widget.totalAPagar * tasaValida;
    final double diferenciaUsd = totalRecibidoUsd - widget.totalAPagar;
    final bool pagoCompleto = totalRecibidoUsd >= (widget.totalAPagar - 0.01);

    final double vueltoUsd = diferenciaUsd > 0 ? diferenciaUsd : 0.0;
    final double vueltoBs = vueltoUsd * tasaValida;
    final double faltanteUsd = diferenciaUsd < 0 ? diferenciaUsd.abs() : 0.0;
    final double faltanteBs = faltanteUsd * tasaValida;

    double dialogWidth = isMobile ? MediaQuery.of(context).size.width * 0.95 : (isTablet ? 700 : 800);
    final Color colorMetodo = _getColorMetodo();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (pagoCompleto) _confirmarPago(totalRecibidoUsd, vueltoUsd, tasaValida);
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop(null);
        },
      },
      child: Focus(
        autofocus: true,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          insetPadding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0)
              : const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CABECERA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorMetodo.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              color: colorMetodo,
                              size: isMobile ? 22 : 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isMobile ? 'Cobro' : 'Procesar Cobro',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 18 : 24,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'BCV: Bs. ${tasaValida.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 10 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BANNER DE TOTALES
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [colorScheme.surfaceContainerHighest, colorScheme.surfaceContainer]
                            : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isMobile
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TOTAL A PAGAR (\$)',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                                  Text('\$${widget.totalAPagar.toStringAsFixed(2)}',
                                      style: TextStyle(color: colorScheme.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TOTAL EN BS',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                                  Text('Bs. ${totalBs.toStringAsFixed(2)}',
                                      style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL A PAGAR (\$)',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('\$${widget.totalAPagar.toStringAsFixed(2)}',
                                      style: TextStyle(color: colorScheme.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('TOTAL EN BOLÍVARES',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Bs. ${totalBs.toStringAsFixed(2)}',
                                      style: TextStyle(color: colorScheme.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  // CHIPS DE MÉTODO
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMetodoChip('Efectivo', Icons.payments, _colorEfectivo, isMobile),
                        const SizedBox(width: 8),
                        _buildMetodoChip('Pago Móvil', Icons.phone_android, _colorPagoMovil, isMobile),
                        const SizedBox(width: 8),
                        _buildMetodoChip('Punto de Venta', Icons.credit_card, _colorPunto, isMobile),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // CAMPOS CON ANIMACIÓN
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutCubic,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: _buildCamposPorMetodo(tasaValida, isMobile, colorMetodo, colorScheme, isDark),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ✅ CÉDULA / RIF
                  _campoTexto(
                    controller: _cedulaController,
                    focusNode: _cedulaFocus,
                    label: 'Cédula / RIF del Cliente',
                    prefixIcon: Icons.badge_outlined,
                    color: colorMetodo,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 14),

                  // PANEL DE VUELTO / FALTANTE
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      color: pagoCompleto
                          ? colorScheme.primaryContainer.withValues(alpha: 0.2)
                          : colorScheme.errorContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pagoCompleto ? colorScheme.primary : colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    child: pagoCompleto
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Vuelto (\$):',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                                  Text('\$${vueltoUsd.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Vuelto (Bs):',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                                  Text('Bs. ${vueltoBs.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Faltante (\$):',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.error)),
                                  Text('\$${faltanteUsd.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.error)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Faltante (Bs):',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.error)),
                                  Text('Bs. ${faltanteBs.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.error)),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),

                  // BOTONES DE ACCIÓN
                  isMobile
                      ? _buildMobileButtons(pagoCompleto, totalRecibidoUsd, vueltoUsd, tasaValida, colorMetodo)
                      : _buildDesktopButtons(pagoCompleto, totalRecibidoUsd, vueltoUsd, tasaValida, colorMetodo),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // CHIP DE MÉTODO
  // ===============================
  Widget _buildMetodoChip(String label, IconData icon, Color color, bool isMobile) {
    final bool selected = _metodoPagoSeleccionado == label;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _metodoPagoSeleccionado = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 10 : 12),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile ? 18 : 20,
              color: selected ? colorScheme.onPrimary : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? colorScheme.onPrimary : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // CAMPOS SEGÚN MÉTODO
  // ===============================
  Widget _buildCamposPorMetodo(double tasaValida, bool isMobile, Color colorMetodo, ColorScheme colorScheme, bool isDark) {
    switch (_metodoPagoSeleccionado) {
      case 'Efectivo':
        return _buildEfectivoFields(tasaValida, isMobile, colorMetodo, colorScheme, isDark);
      case 'Pago Móvil':
        return _buildPagoMovilFields(tasaValida, isMobile, colorMetodo, colorScheme, isDark);
      case 'Punto de Venta':
        return _buildPuntoFields(tasaValida, isMobile, colorMetodo, colorScheme, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ===============================
  // CAMPOS: EFECTIVO
  // ===============================
  Widget _buildEfectivoFields(double tasaValida, bool isMobile, Color color, ColorScheme colorScheme, bool isDark) {
    return Column(
      key: const ValueKey('efectivo'),
      children: [
        Row(
          children: [
            Expanded(
              child: _campoMonto(
                controller: _efectivoUsdController,
                focusNode: _efectivoUsdFocus,
                label: 'Efectivo \$',
                prefixIcon: Icons.attach_money_rounded,
                color: color,
                colorScheme: colorScheme,
                isDark: isDark,
                onChanged: (_) => setState(() {}),
                isMobile: isMobile,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campoMonto(
                controller: _efectivoBsController,
                label: 'Efectivo Bs',
                prefixIcon: Icons.payments_outlined,
                color: color,
                colorScheme: colorScheme,
                isDark: isDark,
                onChanged: (_) => setState(() {}),
                isMobile: isMobile,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _pagarExactoUsd,
            icon: Icon(Icons.attach_money, size: 16, color: color),
            label: Text(
              '\$ Exacto',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 14),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
              backgroundColor: color.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 8 : 12),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================
  // CAMPOS: PAGO MÓVIL
  // ===============================
  Widget _buildPagoMovilFields(double tasaValida, bool isMobile, Color color, ColorScheme colorScheme, bool isDark) {
    return Column(
      key: const ValueKey('pago_movil'),
      children: [
        _campoMonto(
          controller: _pagoMovilBsController,
          label: 'Monto en Bs (Pago Móvil)',
          prefixIcon: Icons.phone_android,
          color: color,
          colorScheme: colorScheme,
          isDark: isDark,
          onChanged: (_) => setState(() {}),
          isMobile: isMobile,
        ),
        const SizedBox(height: 10),
        _campoTexto(
          controller: _referenciaController,
          label: 'Número de Referencia',
          prefixIcon: Icons.numbers,
          color: color,
          colorScheme: colorScheme,
          isDark: isDark,
          isMobile: isMobile,
        ),
        const SizedBox(height: 10),
        _campoTexto(
          controller: _nombreClienteController,
          label: 'Nombre del Cliente',
          prefixIcon: Icons.person_outline,
          color: color,
          colorScheme: colorScheme,
          isDark: isDark,
          isMobile: isMobile,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _pagarExactoPagoMovil(tasaValida),
            icon: Icon(Icons.phone_android, size: 16, color: color),
            label: Text(
              'Pago Móvil Exacto',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 14),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
              backgroundColor: color.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 8 : 12),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================
  // CAMPOS: PUNTO DE VENTA
  // ===============================
  Widget _buildPuntoFields(double tasaValida, bool isMobile, Color color, ColorScheme colorScheme, bool isDark) {
    return Column(
      key: const ValueKey('punto'),
      children: [
        _campoMonto(
          controller: _puntoBsController,
          label: 'Monto en Bs (Punto)',
          prefixIcon: Icons.credit_card,
          color: color,
          colorScheme: colorScheme,
          isDark: isDark,
          onChanged: (_) => setState(() {}),
          isMobile: isMobile,
        ),
        const SizedBox(height: 10),
        _campoTexto(
          controller: _nombreClienteController,
          label: 'Nombre del Cliente',
          prefixIcon: Icons.person_outline,
          color: color,
          colorScheme: colorScheme,
          isDark: isDark,
          isMobile: isMobile,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _pagarExactoPunto(tasaValida),
            icon: Icon(Icons.credit_card, size: 16, color: color),
            label: Text(
              'Punto Exacto',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 14),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
              backgroundColor: color.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 8 : 12),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================
  // CAMPOS REUTILIZABLES (CON HELPER)
  // ===============================
  Widget _campoTexto({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData prefixIcon,
    required Color color,
    required ColorScheme colorScheme,
    bool isDark = false,
    bool isMobile = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enableInteractiveSelection: false,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecorationHelper.build(
        context: context,
        label: label,
        prefixIcon: prefixIcon,
        errorText: null,
        isDark: isDark,
      ),
    );
  }

  Widget _campoMonto({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData prefixIcon,
    required Color color,
    required ColorScheme colorScheme,
    bool isDark = false,
    required ValueChanged<String> onChanged,
    bool isMobile = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      onChanged: onChanged,
      enableInteractiveSelection: false,
      style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      decoration: InputDecorationHelper.build(
        context: context,
        label: label,
        prefixIcon: prefixIcon,
        errorText: null,
        isDark: isDark,
      ),
    );
  }

  // ===============================
  // BOTONES DE ACCIÓN
  // ===============================
  Widget _buildDesktopButtons(bool pagoCompleto, double totalRecibidoUsd, double vueltoUsd, double tasaValida, Color colorMetodo) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: pagoCompleto ? colorMetodo : colorScheme.surfaceContainerHighest,
            foregroundColor: pagoCompleto ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: pagoCompleto ? 4 : 0,
          ),
          onPressed: pagoCompleto ? () => _confirmarPago(totalRecibidoUsd, vueltoUsd, tasaValida) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 22),
              const SizedBox(width: 8),
              Text('CONFIRMAR PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileButtons(bool pagoCompleto, double totalRecibidoUsd, double vueltoUsd, double tasaValida, Color colorMetodo) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pagoCompleto ? colorMetodo : colorScheme.surfaceContainerHighest,
              foregroundColor: pagoCompleto ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: pagoCompleto ? 4 : 0,
            ),
            onPressed: pagoCompleto ? () => _confirmarPago(totalRecibidoUsd, vueltoUsd, tasaValida) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 22),
                const SizedBox(width: 10),
                Text('CONFIRMAR PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3)),
        ),
      ],
    );
  }
}