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

    String metodoPrincipal = 'Efectivo';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    ResponsiveHelper.getFontSize(context, baseSize: 14);

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

    double dialogWidth;
    double dialogPadding;

    if (isMobile) {
      dialogWidth = MediaQuery.of(context).size.width * 0.95;
      dialogPadding = 16.0;
    } else if (isTablet) {
      dialogWidth = 700.0;
      dialogPadding = 24.0;
    } else {
      dialogWidth = 800.0; // Tamaño grande para PC
      dialogPadding = 28.0;
    }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          insetPadding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0)
              : const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: EdgeInsets.all(dialogPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CABECERA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long_outlined, color: const Color(0xFF10B981), size: isMobile ? 22 : 28),
                            const SizedBox(width: 10),
                            Text(isMobile ? 'Cobro' : 'Procesar Cobro', style: TextStyle(fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), letterSpacing: -0.3)),
                          ],
                        ),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBAE6FD))), child: Text('BCV: Bs. ${tasaValida.toStringAsFixed(2)}', style: TextStyle(color: const Color(0xFF0284C7), fontWeight: FontWeight.w700, fontSize: isMobile ? 10 : 12))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2. BANNER DE TOTALES
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 12 : 20),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14)),
                      child: isMobile
                          ? Column(
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL A PAGAR (\$)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)), Text('\$${widget.totalAPagar.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 24, fontWeight: FontWeight.bold))]),
                                const SizedBox(height: 4),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL EN BS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)), Text('Bs. ${totalBs.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.bold))]),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('TOTAL A PAGAR (\$)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)), const SizedBox(height: 4), Text('\$${widget.totalAPagar.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 32, fontWeight: FontWeight.bold))]),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('TOTAL EN BOLÍVARES', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)), const SizedBox(height: 4), Text('Bs. ${totalBs.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 26, fontWeight: FontWeight.bold))]),
                              ],
                            ),
                    ),
                    const SizedBox(height: 14),

                    // 3. ATAJOS Y CAMPOS DE PAGO
                    isMobile
                        ? _buildMobilePaymentFields(tasaValida, isMobile)
                        : _buildDesktopPaymentFields(tasaValida, isMobile),

                    // 4. CÉDULA / DOCUMENTO DEL CLIENTE
                    const SizedBox(height: 14),
                    TextField(
                      controller: _cedulaController,
                      focusNode: _cedulaFocus,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: isMobile ? 14 : 16, color: const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        labelText: 'Cédula / RIF del Cliente',
                        labelStyle: TextStyle(color: const Color(0xFF64748B), fontSize: isMobile ? 13 : 14),
                        prefixIcon: const Icon(Icons.badge_outlined, size: 22, color: Color(0xFF64748B)),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 14 : 18),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0284C7), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. PANEL DINÁMICO VUELTO / FALTANTE
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24, vertical: isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: pagoCompleto ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: pagoCompleto ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA), width: 1.5),
                      ),
                      child: pagoCompleto
                          ? Column(children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Vuelto (\$):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16, color: const Color(0xFF047857))), Text('\$${vueltoUsd.toStringAsFixed(2)}', style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF047857)))]),
                              const SizedBox(height: 4),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Vuelto (Bs):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16, color: const Color(0xFF047857))), Text('Bs. ${vueltoBs.toStringAsFixed(2)}', style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF047857)))])
                            ])
                          : Column(children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Faltante (\$):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16, color: const Color(0xFFB91C1C))), Text('\$${faltanteUsd.toStringAsFixed(2)}', style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFFB91C1C)))]),
                              const SizedBox(height: 4),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Faltante (Bs):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16, color: const Color(0xFFB91C1C))), Text('Bs. ${faltanteBs.toStringAsFixed(2)}', style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFFB91C1C)))])
                            ]),
                    ),
                    const SizedBox(height: 20),

                    // 6. BOTONES INFERIORES
                    isMobile
                        ? _buildMobileButtons(pagoCompleto, totalRecibidoUsd, vueltoUsd, tasaValida)
                        : _buildDesktopButtons(pagoCompleto, totalRecibidoUsd, vueltoUsd, tasaValida),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // COMPONENTES AUXILIARES
  // ==========================================
  Widget _botonAtajo({required String label, required IconData icon, required Color color, required VoidCallback onPressed, required bool isMobile}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          // Aumentamos el padding en tablet/desktop para que sean más fáciles de tocar
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 6 : 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 11 : 13, // Aumentado ligeramente en tablet/desktop
                ),
              ),
            ],
          ),
        ),
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
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 15 : 16, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF64748B), fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.normal),
        prefixIcon: Icon(prefixIcon, color: colorIcon, size: 22),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        // Aumentamos ligeramente el padding vertical para ser más táctil
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 14 : 20), 
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colorIcon, width: 2)),
      ),
    );
  }

  // ==========================================
  // LAYOUTS DE CAMPOS DE PAGO
  // ==========================================
  Widget _buildDesktopPaymentFields(double tasaValida, bool isMobile) {
    return Column(
      children: [
        // Atajos de pago
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _botonAtajo(label: '\$ Exacto', icon: Icons.attach_money_rounded, color: const Color(0xFF10B981), onPressed: _pagarExactoUsd, isMobile: isMobile),
            _botonAtajo(label: 'Pago Móvil', icon: Icons.phone_iphone_rounded, color: const Color(0xFF0284C7), onPressed: () => _pagarExactoPagoMovil(tasaValida), isMobile: isMobile),
            _botonAtajo(label: 'Punto', icon: Icons.credit_card_outlined, color: const Color(0xFF8B5CF6), onPressed: () => _pagarExactoPunto(tasaValida), isMobile: isMobile),
            _botonAtajo(label: '\$10', icon: Icons.payments_outlined, color: const Color(0xFF475569), onPressed: () => _pagarConBilleteUsd(10), isMobile: isMobile),
            _botonAtajo(label: '\$20', icon: Icons.payments_outlined, color: const Color(0xFF475569), onPressed: () => _pagarConBilleteUsd(20), isMobile: isMobile),
            _botonAtajo(label: '\$50', icon: Icons.payments_outlined, color: const Color(0xFF475569), onPressed: () => _pagarConBilleteUsd(50), isMobile: isMobile),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _campoMonto(controller: _efectivoUsdController, focusNode: _efectivoUsdFocus, label: 'Efectivo \$', prefixIcon: Icons.attach_money_rounded, colorIcon: const Color(0xFF10B981), onChanged: (_) => setState(() {}), isMobile: isMobile)),
            const SizedBox(width: 12),
            Expanded(child: _campoMonto(controller: _efectivoBsController, label: 'Efectivo Bs', prefixIcon: Icons.payments_outlined, colorIcon: const Color(0xFF0284C7), onChanged: (_) => setState(() {}), isMobile: isMobile)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _campoMonto(controller: _pagoMovilBsController, label: 'Pago Móvil Bs', prefixIcon: Icons.phone_iphone_rounded, colorIcon: const Color(0xFF0284C7), onChanged: (_) => setState(() {}), isMobile: isMobile)),
            const SizedBox(width: 12),
            Expanded(child: _campoMonto(controller: _puntoBsController, label: 'Punto de Venta Bs', prefixIcon: Icons.credit_card_outlined, colorIcon: const Color(0xFF8B5CF6), onChanged: (_) => setState(() {}), isMobile: isMobile)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobilePaymentFields(double tasaValida, bool isMobile) {
    return Column(
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _botonAtajo(label: '\$ Exacto', icon: Icons.attach_money_rounded, color: const Color(0xFF10B981), onPressed: _pagarExactoUsd, isMobile: isMobile),
            _botonAtajo(label: 'Pago Móvil', icon: Icons.phone_iphone_rounded, color: const Color(0xFF0284C7), onPressed: () => _pagarExactoPagoMovil(tasaValida), isMobile: isMobile),
            _botonAtajo(label: 'Punto', icon: Icons.credit_card_outlined, color: const Color(0xFF8B5CF6), onPressed: () => _pagarExactoPunto(tasaValida), isMobile: isMobile),
            _botonAtajo(label: '\$20', icon: Icons.payments_outlined, color: const Color(0xFF475569), onPressed: () => _pagarConBilleteUsd(20), isMobile: isMobile),
          ],
        ),
        const SizedBox(height: 10),
        _campoMonto(controller: _efectivoUsdController, focusNode: _efectivoUsdFocus, label: 'Efectivo \$', prefixIcon: Icons.attach_money_rounded, colorIcon: const Color(0xFF10B981), onChanged: (_) => setState(() {}), isMobile: isMobile),
        const SizedBox(height: 8),
        _campoMonto(controller: _efectivoBsController, label: 'Efectivo Bs', prefixIcon: Icons.payments_outlined, colorIcon: const Color(0xFF0284C7), onChanged: (_) => setState(() {}), isMobile: isMobile),
        const SizedBox(height: 8),
        _campoMonto(controller: _pagoMovilBsController, label: 'Pago Móvil Bs', prefixIcon: Icons.phone_iphone_rounded, colorIcon: const Color(0xFF0284C7), onChanged: (_) => setState(() {}), isMobile: isMobile),
        const SizedBox(height: 8),
        _campoMonto(controller: _puntoBsController, label: 'Punto de Venta Bs', prefixIcon: Icons.credit_card_outlined, colorIcon: const Color(0xFF8B5CF6), onChanged: (_) => setState(() {}), isMobile: isMobile),
      ],
    );
  }

  // ==========================================
  // BOTONES INFERIORES
  // ==========================================
  Widget _buildDesktopButtons(bool pagoCompleto, double totalRecibidoUsd, double vueltoUsd, double tasaValida) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3)),
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
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pagoCompleto ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: pagoCompleto ? 4 : 0,
            ),
            onPressed: pagoCompleto ? () => _confirmarPago(totalRecibidoUsd, vueltoUsd, tasaValida) : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 22),
                SizedBox(width: 10),
                Text('CONFIRMAR PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.3)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3)),
        ),
      ],
    );
  }
}
