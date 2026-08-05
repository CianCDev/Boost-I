import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bcv_provider.dart';
import '../utils/responsive_helper.dart';

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

  void _pagarConBilleteUsd(double denominacion) {
    setState(() {
      _limpiarMetodos();
      _efectivoUsdController.text = denominacion.toStringAsFixed(2);
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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);

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
              color: theme.dialogBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
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
                  // ---- CABECERA ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              color: const Color(0xFF10B981),
                              size: isMobile ? 22 : 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isMobile ? 'Cobro' : 'Procesar Cobro',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 18 : 24,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Text(
                          'BCV: Bs. ${tasaValida.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFF0284C7),
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 10 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---- BANNER DE TOTALES (MODERNO) ----
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F172A),
                          Color(0xFF1E293B),
                        ],
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
                                  const Text(
                                    'TOTAL A PAGAR (\$)',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.totalAPagar.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL EN BS',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Bs. ${totalBs.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                  const Text(
                                    'TOTAL A PAGAR (\$)',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${widget.totalAPagar.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'TOTAL EN BOLÍVARES',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bs. ${totalBs.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  // ---- SELECTOR DE MÉTODO (CHIPS) ----
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildMetodoChip('Efectivo', Icons.payments, _metodoPagoSeleccionado == 'Efectivo', isMobile),
                          const SizedBox(width: 8),
                          _buildMetodoChip('Pago Móvil', Icons.phone_android, _metodoPagoSeleccionado == 'Pago Móvil', isMobile),
                          const SizedBox(width: 8),
                          _buildMetodoChip('Punto de Venta', Icons.credit_card, _metodoPagoSeleccionado == 'Punto de Venta', isMobile),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---- CAMPOS DE PAGO SEGÚN MÉTODO ----
                  if (_metodoPagoSeleccionado == 'Efectivo')
                    _buildEfectivoFields(tasaValida, isMobile)
                  else if (_metodoPagoSeleccionado == 'Pago Móvil')
                    _buildPagoMovilFields(tasaValida, isMobile)
                  else
                    _buildPuntoFields(tasaValida, isMobile),

                  const SizedBox(height: 14),

                  // ---- CÉDULA / RIF ----
                  TextField(
                    controller: _cedulaController,
                    focusNode: _cedulaFocus,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Cédula / RIF del Cliente',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 22, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---- PANEL DE VUELTO / FALTANTE ----
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      color: pagoCompleto ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pagoCompleto ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                        width: 1.5,
                      ),
                    ),
                    child: pagoCompleto
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Vuelto (\$):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                  Text(
                                    '\$${vueltoUsd.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Vuelto (Bs):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                  Text(
                                    'Bs. ${vueltoBs.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Faltante (\$):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                                  Text(
                                    '\$${faltanteUsd.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Faltante (Bs):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                                  Text(
                                    'Bs. ${faltanteBs.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),

                  // ---- BOTONES DE ACCIÓN ----
                  isMobile
                      ? _buildMobileButtons(pagoCompleto, totalRecibidoUsd, vueltoUsd, tasaValida)
                      : _buildDesktopButtons(pagoCompleto, totalRecibidoUsd, vueltoUsd, tasaValida),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MÉTODOS DE CONSTRUCCIÓN DE CAMPOS
  // ==========================================

  Widget _buildMetodoChip(String label, IconData icon, bool selected, bool isMobile) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _metodoPagoSeleccionado = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF10B981) : theme.dividerColor,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : theme.iconTheme.color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfectivoFields(double tasaValida, bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _campoMonto(
                controller: _efectivoUsdController,
                focusNode: _efectivoUsdFocus,
                label: 'Efectivo \$',
                prefixIcon: Icons.attach_money_rounded,
                colorIcon: const Color(0xFF10B981),
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
                colorIcon: const Color(0xFF0284C7),
                onChanged: (_) => setState(() {}),
                isMobile: isMobile,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _botonAtajo(label: '\$ Exacto', icon: Icons.attach_money_rounded, color: const Color(0xFF10B981), onPressed: _pagarExactoUsd, isMobile: isMobile),
            _botonAtajo(label: '\$10', icon: Icons.payments_outlined, color: const Color(0xFF475569), onPressed: () => _pagarConBilleteUsd(10), isMobile: isMobile),
            _botonAtajo(label: '\$20', icon: Icons.payments_outlined, color: const Color(0xFF475569), onPressed: () => _pagarConBilleteUsd(20), isMobile: isMobile),
            _botonAtajo(label: '\$50', icon: Icons.payments_outlined, color: const Color(0xFF475569), onPressed: () => _pagarConBilleteUsd(50), isMobile: isMobile),
          ],
        ),
      ],
    );
  }

  Widget _buildPagoMovilFields(double tasaValida, bool isMobile) {
    return Column(
      children: [
        _campoMonto(
          controller: _pagoMovilBsController,
          label: 'Monto en Bs (Pago Móvil)',
          prefixIcon: Icons.phone_android,
          colorIcon: const Color(0xFF0284C7),
          onChanged: (_) => setState(() {}),
          isMobile: isMobile,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _referenciaController,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Número de Referencia',
            prefixIcon: const Icon(Icons.numbers, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nombreClienteController,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Nombre del Cliente',
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _botonAtajo(
              label: 'Pago Móvil Exacto',
              icon: Icons.phone_android,
              color: const Color(0xFF0284C7),
              onPressed: () => _pagarExactoPagoMovil(tasaValida),
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPuntoFields(double tasaValida, bool isMobile) {
    return Column(
      children: [
        _campoMonto(
          controller: _puntoBsController,
          label: 'Monto en Bs (Punto)',
          prefixIcon: Icons.credit_card,
          colorIcon: const Color(0xFF8B5CF6),
          onChanged: (_) => setState(() {}),
          isMobile: isMobile,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nombreClienteController,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Nombre del Cliente',
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _botonAtajo(
              label: 'Punto Exacto',
              icon: Icons.credit_card,
              color: const Color(0xFF8B5CF6),
              onPressed: () => _pagarExactoPunto(tasaValida),
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // COMPONENTES AUXILIARES
  // ==========================================

  Widget _botonAtajo({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 11 : 13,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.2),
        backgroundColor: color.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 6 : 10),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _campoMonto({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData prefixIcon,
    required Color colorIcon,
    required ValueChanged<String> onChanged,
    bool isMobile = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: colorIcon, size: 22),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorIcon, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDesktopButtons(bool pagoCompleto, double totalRecibidoUsd, double vueltoUsd, double tasaValida) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: pagoCompleto ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: pagoCompleto ? 4 : 0,
          ),
          onPressed: pagoCompleto ? () => _confirmarPago(totalRecibidoUsd, vueltoUsd, tasaValida) : null,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 22),
              SizedBox(width: 8),
              Text('CONFIRMAR PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileButtons(bool pagoCompleto, double totalRecibidoUsd, double vueltoUsd, double tasaValida) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pagoCompleto ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: pagoCompleto ? 4 : 0,
            ),
            onPressed: pagoCompleto ? () => _confirmarPago(totalRecibidoUsd, vueltoUsd, tasaValida) : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 22),
                SizedBox(width: 10),
                Text('CONFIRMAR PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
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