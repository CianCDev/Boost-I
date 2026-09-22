// lib/features/pos/presentation/widgets/wholesale/wholesale_cobrar_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/mayoreo/venta_mayor_service.dart';
import 'all_payment_methods_dialog.dart';

/// Datos que devuelve el diálogo tras confirmar el cobro.
class WholesaleCobrarResult {
  final VentaMayorPagoInput pago;

  const WholesaleCobrarResult({required this.pago});
}

/// Modal de cobro para ventas al mayor.
///
/// Soporta:
///   - Pago único (3 métodos principales)
///   - Multipago (agregar N pagos con distintos métodos)
///   - Validación de mínimo requerido
///   - Métodos secundarios vía `AllPaymentMethodsDialog`
class WholesaleCobrarDialog extends StatefulWidget {
  final double totalUsd;
  final double tasaBcv;
  final double minimoRequeridoPorcentaje;

  const WholesaleCobrarDialog({
    super.key,
    required this.totalUsd,
    required this.tasaBcv,
    this.minimoRequeridoPorcentaje = 0.0,
  });

  static Future<WholesaleCobrarResult?> show(
    BuildContext context, {
    required double totalUsd,
    required double tasaBcv,
    double minimoRequeridoPorcentaje = 0.0,
  }) {
    return showDialog<WholesaleCobrarResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WholesaleCobrarDialog(
        totalUsd: totalUsd,
        tasaBcv: tasaBcv,
        minimoRequeridoPorcentaje: minimoRequeridoPorcentaje,
      ),
    );
  }

  @override
  State<WholesaleCobrarDialog> createState() => _WholesaleCobrarDialogState();
}

class _WholesaleCobrarDialogState extends State<WholesaleCobrarDialog> {
  // ── Estado principal ──
  bool _esMultipago = false;
  String? _metodoPrincipalSeleccionado; // key del método

  // ── Pagos agregados (multipago) ──
  final List<PagoInput> _pagos = [];

  // ── Controllers para el formulario actual ──
  final _montoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _ultimosDigitosController = TextEditingController();
  final _walletController = TextEditingController();
  final _hashController = TextEditingController();
  final _bancoController = TextEditingController();
  final _titularController = TextEditingController();

  @override
  void dispose() {
    _montoController.dispose();
    _referenciaController.dispose();
    _ultimosDigitosController.dispose();
    _walletController.dispose();
    _hashController.dispose();
    _bancoController.dispose();
    _titularController.dispose();
    super.dispose();
  }

  // ──────────────── Cálculos ────────────────

  double get _totalPagadoUsd =>
      _pagos.fold(0.0, (sum, p) => sum + p.montoUsdEquivalente);

  double get _minimoRequeridoUsd =>
      widget.totalUsd * (widget.minimoRequeridoPorcentaje / 100.0);

  double get _faltanteUsd {
    final faltante = widget.totalUsd - _totalPagadoUsd;
    return faltante > 0 ? faltante : 0;
  }

  double get _vueltoUsd {
    final vuelto = _totalPagadoUsd - widget.totalUsd;
    return vuelto > 0 ? vuelto : 0;
  }

  bool get _cumpleMinimo =>
      _totalPagadoUsd >= _minimoRequeridoUsd - 0.01;

  bool get _pagoCompleto => _totalPagadoUsd >= widget.totalUsd - 0.01;

  // ──────────────── Acciones ────────────────

  void _seleccionarMetodo(String key) {
    setState(() {
      _metodoPrincipalSeleccionado = key;
      _limpiarFormulario();
      _montoController.text = _faltanteUsd > 0
          ? _faltanteUsd.toStringAsFixed(2)
          : '';
    });
  }

  void _limpiarFormulario() {
    _montoController.clear();
    _referenciaController.clear();
    _ultimosDigitosController.clear();
    _walletController.clear();
    _hashController.clear();
    _bancoController.clear();
    _titularController.clear();
  }

  Future<void> _abrirTodosLosMetodos() async {
    final seleccionado = await AllPaymentMethodsDialog.show(context);
    if (seleccionado == null || !mounted) return;
    _seleccionarMetodo(seleccionado);
  }

 void _agregarPago() {
  final metodo = _metodoPrincipalSeleccionado;
  if (metodo == null) return;

  final monto = double.tryParse(_montoController.text.replaceAll(',', '.'));
  if (monto == null || monto <= 0) {
    _snack('Ingresa un monto válido', esError: true);
    return;
  }

  final esBs = _metodoUsaBs(metodo);

  // ✅ NUEVO: no permitir agregar pagos en Bs sin tasa válida
  if (esBs && widget.tasaBcv <= 0) {
    _snack(
      'No hay tasa BCV válida para convertir Bs a USD.',
      esError: true,
    );
    return;
  }

  final esUsdt = _metodoUsaUsdt(metodo);
  final montoUsd = esBs ? monto / widget.tasaBcv : monto;
       

    final pago = PagoInput(
      metodo: metodo,
      monto: monto,
      moneda: esBs ? 'VES' : (esUsdt ? 'USDT' : 'USD'),
      montoUsdEquivalente: montoUsd,
      tasaBcv: esBs ? widget.tasaBcv : null,
      referencia: _referenciaController.text.trim().isEmpty
          ? null
          : _referenciaController.text.trim(),
      ultimosDigitos: _ultimosDigitosController.text.trim().isEmpty
          ? null
          : _ultimosDigitosController.text.trim(),
      walletDestino: _walletController.text.trim().isEmpty
          ? null
          : _walletController.text.trim(),
      hashTransaccion: _hashController.text.trim().isEmpty
          ? null
          : _hashController.text.trim(),
      bancoEmisor: _bancoController.text.trim().isEmpty
          ? null
          : _bancoController.text.trim(),
      titular: _titularController.text.trim().isEmpty
          ? null
          : _titularController.text.trim(),
    );

    setState(() {
      _pagos.add(pago);
      _limpiarFormulario();
      _metodoPrincipalSeleccionado = null;
    });

    // ✅ FIX: Feedback al agregar pago
    final totalPagado = _totalPagadoUsd;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_labelMetodo(metodo)} agregado · '
          'Pagado: \$${totalPagado.toStringAsFixed(2)} '
          'de \$${widget.totalUsd.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _eliminarPago(int index) {
    setState(() {
      _pagos.removeAt(index);
    });
  }

  bool _metodoUsaBs(String metodo) =>
      metodo == 'efectivo_bs' ||
      metodo == 'punto' ||
      metodo == 'pago_movil' ||
      metodo == 'transferencia_bs';

  bool _metodoUsaUsdt(String metodo) =>
      metodo == 'binance_pay' || metodo == 'transferencia_usdt';

  String _labelMetodo(String metodo) {
    switch (metodo) {
      case 'efectivo_usd':
        return 'Efectivo USD';
      case 'efectivo_bs':
        return 'Efectivo Bs';
      case 'punto':
        return 'Punto de venta';
      case 'pago_movil':
        return 'Pago Móvil';
      case 'transferencia_bs':
        return 'Transferencia Bs';
      case 'binance_pay':
        return 'Binance Pay';
      case 'transferencia_usdt':
        return 'Transferencia USDT';
      case 'zelle':
        return 'Zelle';
      case 'paypal':
        return 'PayPal';
      default:
        return metodo;
    }
  }

  IconData _iconoMetodo(String metodo) {
    switch (metodo) {
      case 'efectivo_usd':
      case 'efectivo_bs':
        return Icons.payments_rounded;
      case 'punto':
        return Icons.credit_card_rounded;
      case 'pago_movil':
        return Icons.phone_android_rounded;
      case 'transferencia_bs':
        return Icons.account_balance_rounded;
      case 'binance_pay':
        return Icons.currency_bitcoin_rounded;
      case 'transferencia_usdt':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  // ──────────────── Confirmar ────────────────

  Future<void> _confirmar() async {
  // ✅ 1. PRIMERO: validar tasa
  if (widget.tasaBcv <= 0) {
    _snack(
      'No hay tasa BCV válida. No se puede procesar el cobro.',
      esError: true,
    );
    return;
  }

  // ✅ 2. Luego: agregar el pago pendiente si lo hay
  if (_metodoPrincipalSeleccionado != null &&
      _montoController.text.trim().isNotEmpty) {
    _agregarPago();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  if (_pagos.isEmpty) {
    _snack('Agrega al menos un pago', esError: true);
    return;
  }

  if (!_cumpleMinimo) {
    _snack(
      'Falta cubrir el mínimo requerido '
      '(\$${_minimoRequeridoUsd.toStringAsFixed(2)})',
      esError: true,
    );
    return;
  }

  if (!_pagoCompleto) {
    _snack('El pago no cubre el total de la venta', esError: true);
    return;
  }

  final result = WholesaleCobrarResult(
    pago: VentaMayorPagoInput(
      pagos: List.from(_pagos),
      tasaBcv: widget.tasaBcv,
      montoRecibidoUsd: _totalPagadoUsd,
      vueltoUsd: _vueltoUsd,
    ),
  );

  Navigator.of(context).pop(result);
}

  void _snack(String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            esError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ──────────────── Build ────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 780),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark, cs),
            Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
            _buildTotalBanner(isDark, cs),

              // ✅ NUEVO: banner solo si la tasa no es válida
    if (widget.tasaBcv <= 0)
      Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline,
                color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sin tasa BCV válida. No se puede procesar el cobro.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

            // ── Contenido scrollable ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildToggle(isDark, cs),
                    const SizedBox(height: 16),

                    // ✅ FIX #1: mostrar métodos si:
                    //    - No hay método seleccionado actualmente
                    //    - Y (modo multipago activo O aún no hay pagos)
                    if (_metodoPrincipalSeleccionado == null &&
                        (_esMultipago || _pagos.isEmpty)) ...[
                      _buildMetodosPrincipales(isDark, cs),
                    ],

                    // Lista de pagos agregados
                    if (_pagos.isNotEmpty) ...[
                      _buildPagosAgregados(isDark, cs),
                      const SizedBox(height: 16),
                    ],

                    // Formulario del método seleccionado
                    if (_metodoPrincipalSeleccionado != null) ...[
                      _buildFormularioMetodo(isDark, cs),
                    ],

                    // Validaciones
                    if (_pagos.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildValidaciones(isDark, cs),
                    ],
                  ],
                ),
              ),
            ),

            _buildFooter(isDark, cs),
          ],
        ),
      ),
    );
  }

  // ──────────────── Header ────────────────

  Widget _buildHeader(bool isDark, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              size: 22,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Procesar cobro',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Venta al mayor',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 22),
            color: cs.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  // ──────────────── Banner total ────────────────

  Widget _buildTotalBanner(bool isDark, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'TOTAL USD',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '\$${widget.totalUsd.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          if (widget.tasaBcv > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'Bs.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const Spacer(),
                Text(
                  'Bs. ${(widget.totalUsd * widget.tasaBcv).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          if (widget.minimoRequeridoPorcentaje > 0) ...[
            const SizedBox(height: 8),
            Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  size: 14,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 6),
                Text(
                  'Mínimo requerido '
                  '(${widget.minimoRequeridoPorcentaje.toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${_minimoRequeridoUsd.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────── Toggle multipago ────────────────

  Widget _buildToggle(bool isDark, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            'Pago único',
            !_esMultipago,
            () => setState(() => _esMultipago = false),
            isDark,
            cs,
          ),
          _buildToggleOption(
            'Multipago',
            _esMultipago,
            () => setState(() => _esMultipago = true),
            isDark,
            cs,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    bool selected,
    VoidCallback onTap,
    bool isDark,
    ColorScheme cs,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────── Métodos principales ────────────────

  Widget _buildMetodosPrincipales(bool isDark, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMetodoTile(
          key: 'efectivo_usd',
          label: 'Efectivo (Divisas y Bs)',
          subtitle: 'Pago en USD o VES',
          icon: Icons.payments_rounded,
          color: const Color(0xFF10B981),
          isDark: isDark,
          cs: cs,
        ),
        const SizedBox(height: 8),
        _buildMetodoTile(
          key: 'punto',
          label: 'Punto de venta',
          subtitle: 'Cobro con tarjeta',
          icon: Icons.credit_card_rounded,
          color: const Color(0xFF8B5CF6),
          isDark: isDark,
          cs: cs,
        ),
        const SizedBox(height: 8),
        _buildMetodoTile(
          key: 'pago_movil',
          label: 'Pago Móvil',
          subtitle: 'Transferencia inmediata',
          icon: Icons.phone_android_rounded,
          color: const Color(0xFF3B82F6),
          isDark: isDark,
          cs: cs,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: _abrirTodosLosMetodos,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Ver todos los métodos de pago',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(
                color: cs.primary.withValues(alpha: 0.4),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetodoTile({
    required String key,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required ColorScheme cs,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _seleccionarMetodo(key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── Formulario del método ────────────────

  Widget _buildFormularioMetodo(bool isDark, ColorScheme cs) {
    final metodo = _metodoPrincipalSeleccionado!;
    final usaBs = _metodoUsaBs(metodo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _iconoMetodo(metodo),
                size: 20,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _labelMetodo(metodo),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _metodoPrincipalSeleccionado = null;
                    _limpiarFormulario();
                  });
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                color: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Monto
        _buildTextField(
          controller: _montoController,
          label: usaBs ? 'Monto (Bs)' : 'Monto (USD/USDT)',
          icon: usaBs
              ? Icons.payments_outlined
              : Icons.attach_money_rounded,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          isDark: isDark,
          cs: cs,
        ),

        if (usaBs && widget.tasaBcv > 0) ...[
          const SizedBox(height: 6),
          Text(
            'Equivale a: \$${_calcularEquivalenteUsd().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],

        // Campos específicos por método
        if (metodo == 'punto' ||
            metodo == 'pago_movil' ||
            metodo == 'transferencia_bs') ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _referenciaController,
            label: 'Referencia',
            icon: Icons.numbers_rounded,
            isDark: isDark,
            cs: cs,
          ),
        ],

        if (metodo == 'punto') ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _ultimosDigitosController,
            label: 'Últimos 4 dígitos',
            icon: Icons.credit_card_rounded,
            maxLength: 4,
            isDark: isDark,
            cs: cs,
          ),
        ],

        if (metodo == 'pago_movil' || metodo == 'transferencia_bs') ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bancoController,
            label: 'Banco emisor',
            icon: Icons.account_balance_rounded,
            isDark: isDark,
            cs: cs,
          ),
        ],

        if (metodo == 'transferencia_bs') ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _titularController,
            label: 'Titular',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            cs: cs,
          ),
        ],

        if (metodo == 'binance_pay' ||
            metodo == 'transferencia_usdt') ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _walletController,
            label: 'Wallet destino',
            icon: Icons.account_balance_wallet_rounded,
            isDark: isDark,
            cs: cs,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _hashController,
            label: 'Hash de transacción',
            icon: Icons.tag_rounded,
            isDark: isDark,
            cs: cs,
          ),
        ],

        const SizedBox(height: 16),

        // ✅ Bonus: texto dinámico del botón
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: _agregarPago,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              _pagos.isEmpty ? 'Agregar pago' : 'Agregar otro pago',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calcularEquivalenteUsd() {
    final monto = double.tryParse(_montoController.text.replaceAll(',', '.'));
    if (monto == null || widget.tasaBcv <= 0) return 0;
    return monto / widget.tasaBcv;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    required bool isDark,
    required ColorScheme cs,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: formatters,
      maxLength: maxLength,
      onChanged: (_) => setState(() {}),
      style: TextStyle(fontSize: 14, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        prefixIcon: Icon(icon, size: 20),
        counterText: '',
        filled: true,
        fillColor: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  // ──────────────── Pagos agregados ────────────────

  Widget _buildPagosAgregados(bool isDark, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.list_alt_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Pagos agregados (${_pagos.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_pagos.length, (i) {
          final p = _pagos[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _buildPagoTile(p, i, isDark, cs),
          );
        }),
      ],
    );
  }

  Widget _buildPagoTile(
    PagoInput pago,
    int index,
    bool isDark,
    ColorScheme cs,
  ) {
    final usaBs = pago.moneda == 'VES';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconoMetodo(pago.metodo),
              size: 16,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelMetodo(pago.metodo),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  usaBs
                      ? 'Bs. ${pago.monto.toStringAsFixed(2)} '
                          '(≈\$${pago.montoUsdEquivalente.toStringAsFixed(2)})'
                      : '${pago.moneda} ${pago.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _eliminarPago(index),
            icon: const Icon(Icons.close_rounded, size: 18),
            color: const Color(0xFFEF4444),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  // ──────────────── Validaciones ────────────────

  Widget _buildValidaciones(bool isDark, ColorScheme cs) {
    final minimo = _cumpleMinimo;
    final completo = _pagoCompleto;

    Color color;
    IconData icon;
    String titulo;
    String mensaje;

    if (completo) {
      color = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      titulo = 'Pago completo';
      mensaje = _vueltoUsd > 0.01
          ? 'Vuelto: \$${_vueltoUsd.toStringAsFixed(2)}'
          : 'Monto exacto';
    } else if (minimo) {
      color = const Color(0xFFF59E0B);
      icon = Icons.warning_amber_rounded;
      titulo = 'Mínimo cubierto';
      mensaje =
          'Faltante para el total: \$${_faltanteUsd.toStringAsFixed(2)}';
    } else {
      color = const Color(0xFFEF4444);
      icon = Icons.error_rounded;
      titulo = 'Mínimo no cubierto';
      mensaje =
          'Faltan \$${(_minimoRequeridoUsd - _totalPagadoUsd).toStringAsFixed(2)} '
          'para el mínimo requerido';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mensaje,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Pagado',
                style: TextStyle(
                  fontSize: 9,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${_totalPagadoUsd.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────── Footer ────────────────

  Widget _buildFooter(bool isDark, ColorScheme cs) {
    final puedeConfirmar =
        _pagos.isNotEmpty && _cumpleMinimo && _pagoCompleto;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: cs.onSurfaceVariant,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: puedeConfirmar ? _confirmar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Text(
                'Confirmar cobro',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}