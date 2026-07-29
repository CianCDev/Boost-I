import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bcv_provider.dart';

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
  final FocusNode _cedulaFocus = FocusNode(); // FocusNode para seleccionar texto rápido de la cédula

  @override
  void initState() {
    super.initState();
    _efectivoUsdController.text = widget.totalAPagar.toStringAsFixed(2);

    // Seleccionar texto completo al recibir foco en la cédula para reescribir fácil
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

  // --- MÉTODOS DE ATAJO RÁPIDO ---
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

  // --- PROCESAR PAGO ---
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

    // Retornamos un Map completo con los nombres requeridos tanto por Isar como por Supabase
    Navigator.of(context).pop({
      'procesado': true,
      'metodoPago': metodoPrincipal,
      'documento': documentoFinal,        // Columna exacta en Supabase DB
      'cedulaCliente': documentoFinal,    // Nombre compatible con la entidad Isar local
      'montoRecibido': totalRecibidoUsd,
      'vuelto': vueltoUsd,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double tasaBcv = ref.watch(bcvProvider).tasa;
    final double tasaValida = (tasaBcv.isNaN || tasaBcv <= 0) ? 1.0 : tasaBcv;

    // Montos ingresados
    final double efectivoUsd = double.tryParse(_efectivoUsdController.text) ?? 0.0;
    final double efectivoBs = double.tryParse(_efectivoBsController.text) ?? 0.0;
    final double pagoMovilBs = double.tryParse(_pagoMovilBsController.text) ?? 0.0;
    final double puntoBs = double.tryParse(_puntoBsController.text) ?? 0.0;

    // Equivalencia total en USD
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
          child: Container(
            width: 580,
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CABECERA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long_outlined, color: Color(0xFF10B981), size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Procesar Cobro',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Text(
                          'BCV: Bs. ${tasaValida.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. BANNER DE TOTALES
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL A PAGAR (\$)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text('\$${widget.totalAPagar.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TOTAL EN BOLÍVARES', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text('Bs. ${totalBs.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. ATAJOS RÁPIDOS
                  const Text('Atajos de Pago Rápido:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _botonAtajo(
                        label: '\$ Exacto',
                        icon: Icons.attach_money_rounded,
                        color: const Color(0xFF10B981),
                        onPressed: _pagarExactoUsd,
                      ),
                      _botonAtajo(
                        label: 'Pago Móvil Exacto',
                        icon: Icons.phone_iphone_rounded,
                        color: const Color(0xFF0284C7),
                        onPressed: () => _pagarExactoPagoMovil(tasaValida),
                      ),
                      _botonAtajo(
                        label: 'Punto Exacto',
                        icon: Icons.credit_card_outlined,
                        color: const Color(0xFF8B5CF6),
                        onPressed: () => _pagarExactoPunto(tasaValida),
                      ),
                      _botonAtajo(
                        label: '\$10',
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF475569),
                        onPressed: () => _pagarConBilleteUsd(10),
                      ),
                      _botonAtajo(
                        label: '\$20',
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF475569),
                        onPressed: () => _pagarConBilleteUsd(20),
                      ),
                      _botonAtajo(
                        label: '\$50',
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF475569),
                        onPressed: () => _pagarConBilleteUsd(50),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. MÉTODOS DE PAGO (CAMPOS DE TEXTO)
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _campoMonto(
                          controller: _pagoMovilBsController,
                          label: 'Pago Móvil Bs',
                          prefixIcon: Icons.phone_iphone_rounded,
                          colorIcon: const Color(0xFF0284C7),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _campoMonto(
                          controller: _puntoBsController,
                          label: 'Punto de Venta Bs',
                          prefixIcon: Icons.credit_card_outlined,
                          colorIcon: const Color(0xFF8B5CF6),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 5. CÉDULA / DOCUMENTO DEL CLIENTE
                  TextField(
                    controller: _cedulaController,
                    focusNode: _cedulaFocus,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: 'Cédula / RIF del Cliente',
                      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF64748B)),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 6. PANEL DINÁMICO VUELTO / FALTANTE
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: pagoCompleto ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
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
                                  const Text('Vuelto / Cambio (\$):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                  Text('\$${vueltoUsd.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Vuelto / Cambio (Bs):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                  Text('Bs. ${vueltoBs.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
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
                                  Text('\$${faltanteUsd.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Faltante (Bs):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                                  Text('Bs. ${faltanteBs.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 22),

                  // 7. BOTONES INFERIORES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pagoCompleto ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: pagoCompleto ? 2 : 0,
                        ),
                        onPressed: pagoCompleto ? () => _confirmarPago(totalRecibidoUsd, vueltoUsd, tasaValida) : null,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('CONFIRMAR PAGO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---
  Widget _botonAtajo({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11.5),
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
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.normal),
        prefixIcon: Icon(prefixIcon, color: colorIcon, size: 20),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorIcon, width: 2),
        ),
      ),
    );
  }
}