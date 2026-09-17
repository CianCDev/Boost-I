// lib/features/pos/presentation/widgets/wholesale/wholesale_quantity_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/isar_provider.dart';
import '../../services/mayoreo/wholesale_pricing_service.dart';
import '../../services/scale_service.dart';

/// Resultado del diálogo de cantidad al mayor.
class WholesaleQuantityResult {
  final int cantidad;
  final String unidadEmpaque;

  const WholesaleQuantityResult({
    required this.cantidad,
    required this.unidadEmpaque,
  });
}

/// Diálogo para agregar productos al carrito de ventas al mayor.
///
/// Características:
///   - Selector de unidad (unidad / bulto / caja)
///   - Balanza automática para productos pesados
///   - Cálculo automático de precio (mayor / medio mayor / detal)
///   - Preview del subtotal, descuento por volumen y ahorro
///   - Sin edición manual de precio
class WholesaleQuantityDialog extends ConsumerStatefulWidget {
  final ProductoEntity producto;

  /// Cantidad inicial sugerida (default 1 unidad o 1 bulto).
  final int cantidadInicial;

  /// Unidad de empaque inicial.
  final String unidadInicial;

  const WholesaleQuantityDialog({
    super.key,
    required this.producto,
    this.cantidadInicial = 1,
    this.unidadInicial = 'unidad',
  });

  /// Muestra el diálogo y devuelve el resultado o `null` si se cancela.
  static Future<WholesaleQuantityResult?> show(
    BuildContext context, {
    required ProductoEntity producto,
    int cantidadInicial = 1,
    String unidadInicial = 'unidad',
  }) {
    return showDialog<WholesaleQuantityResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WholesaleQuantityDialog(
        producto: producto,
        cantidadInicial: cantidadInicial,
        unidadInicial: unidadInicial,
      ),
    );
  }

  @override
  ConsumerState<WholesaleQuantityDialog> createState() =>
      _WholesaleQuantityDialogState();
}

class _WholesaleQuantityDialogState
    extends ConsumerState<WholesaleQuantityDialog> {
  final ScaleService _scaleService = ScaleService();
  final TextEditingController _cantidadController = TextEditingController();
  final FocusNode _cantidadFocus = FocusNode();

  late String _unidadEmpaque;
  bool _usandoPesoAutomatico = true;
  bool _cerrando = false;

  StreamSubscription<double>? _weightSubscription;

  // Cache del precio resuelto
  PrecioResuelto? _precioActual;

  @override
  void initState() {
    super.initState();
    _unidadEmpaque = widget.unidadInicial;

    if (widget.producto.esPesado) {
      _cantidadController.text = '0.000';
    } else {
      _cantidadController.text = widget.cantidadInicial.toString();
    }

    // Balanza para productos pesados
    if (widget.producto.esPesado) {
      _weightSubscription = _scaleService.weightStream.listen((peso) {
        if (peso > 0 && mounted && _usandoPesoAutomatico) {
          final nuevo = peso.toStringAsFixed(3);
          if (_cantidadController.text != nuevo) {
            _cantidadController.text = nuevo;
            _recalcularPrecio();
          }
        }
      });
    }

    _cantidadFocus.addListener(() {
      if (_cantidadFocus.hasFocus) {
        _cantidadController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _cantidadController.text.length,
        );
      }
    });

    // Primera resolución de precio
    _recalcularPrecio();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cantidadFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _weightSubscription?.cancel();
    _cantidadController.dispose();
    _cantidadFocus.dispose();
    super.dispose();
  }

  // ──────────────── Cálculos ────────────────

  /// Convierte la cantidad ingresada a unidades totales, según el empaque.
  int get _unidadesTotales {
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;
    if (cantidad <= 0) return 0;

    switch (_unidadEmpaque) {
      case 'bulto':
      case 'caja':
        final porEmpaque = widget.producto.unidadesPorBulto > 0
            ? widget.producto.unidadesPorBulto
            : 1;
        return cantidad * porEmpaque;
      case 'unidad':
      default:
        return cantidad;
    }
  }

  /// Recalcula el precio para la cantidad actual.
  Future<void> _recalcularPrecio() async {
    final unidades = _unidadesTotales;
    if (unidades <= 0) {
      if (mounted) setState(() => _precioActual = null);
      return;
    }

    try {
      final isar = ref.read(isarServiceProvider);
      final reglas = await isar.obtenerConfigDescuentos(soloActivos: true);

      final precio = WholesalePricingService.resolver(
        producto: widget.producto,
        cantidad: unidades,
        reglasVolumen: reglas,
      );

      if (mounted) setState(() => _precioActual = precio);
    } catch (e) {
      debugPrint('⚠️ Error recalculando precio: $e');
    }
  }

  // ──────────────── Build ────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 20),

                // ── Selector de unidad (solo si no es pesado) ──
                if (!widget.producto.esPesado) ...[
                  _buildUnidadSelector(isDark, colorScheme),
                  const SizedBox(height: 16),
                ],

                // ── Cantidad ──
                _buildCantidadField(isDark),
                const SizedBox(height: 16),

                // ── Preview del precio ──
                if (_precioActual != null)
                  _buildPrecioPreview(_precioActual!, isDark, colorScheme),

                const SizedBox(height: 24),

                // ── Botones ──
                _buildBotones(isDark, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────── Header ────────────────

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.producto.esPesado
                ? Icons.monitor_weight_rounded
                : Icons.shopping_cart_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar al mayor',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.producto.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (widget.producto.esPesado && _weightSubscription != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_tethering_rounded,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                SizedBox(width: 4),
                Text(
                  'Balanza',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ──────────────── Selector de unidad ────────────────

  Widget _buildUnidadSelector(bool isDark, ColorScheme cs) {
    final unidades = widget.producto.unidadesPorBulto;
    final tieneBultos = unidades > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presentación',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _unidadChip(
                label: 'Unidad',
                icon: Icons.straighten_rounded,
                value: 'unidad',
                selected: _unidadEmpaque == 'unidad',
                isDark: isDark,
                cs: cs,
              ),
            ),
            if (tieneBultos) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _unidadChip(
                  label: 'Bulto ($unidades u.)',
                  icon: Icons.inventory_2_rounded,
                  value: 'bulto',
                  selected: _unidadEmpaque == 'bulto',
                  isDark: isDark,
                  cs: cs,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _unidadChip({
    required String label,
    required IconData icon,
    required String value,
    required bool selected,
    required bool isDark,
    required ColorScheme cs,
  }) {
    final color = const Color(0xFF10B981);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_unidadEmpaque == value) return;
          setState(() => _unidadEmpaque = value);
          _recalcularPrecio();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: isDark ? 0.2 : 0.12)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.6)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? color
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? color
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── Campo de cantidad ────────────────

  Widget _buildCantidadField(bool isDark) {
    final esPesado = widget.producto.esPesado;
    final esBulto = _unidadEmpaque != 'unidad';

    return TextField(
      controller: _cantidadController,
      focusNode: _cantidadFocus,
      keyboardType: TextInputType.numberWithOptions(decimal: esPesado),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          esPesado ? RegExp(r'^\d*\.?\d{0,3}') : RegExp(r'^\d*'),
        ),
      ],
      onChanged: (_) => _recalcularPrecio(),
      onTap: () {
        if (esPesado && _usandoPesoAutomatico) {
          setState(() => _usandoPesoAutomatico = false);
          _weightSubscription?.cancel();
          _weightSubscription = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✏️ Edición manual activada'),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      },
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: esBulto ? 'Cantidad de bultos' : 'Cantidad',
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        prefixIcon: esPesado
            ? Icon(
                _usandoPesoAutomatico
                    ? Icons.wifi_tethering
                    : Icons.edit_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              )
            : const Icon(
                Icons.numbers_rounded,
                color: Color(0xFF10B981),
              ),
        suffixText: esPesado
            ? 'kg'
            : esBulto
                ? 'bultos'
                : 'unid',
        suffixStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onSubmitted: (_) => _confirmar(),
    );
  }

  // ──────────────── Preview de precio ────────────────

  Widget _buildPrecioPreview(
    PrecioResuelto precio,
    bool isDark,
    ColorScheme cs,
  ) {
    final unidades = _unidadesTotales;
    final subtotalBruto = precio.precioUnitario * unidades;
    final descuentoAuto = subtotalBruto * (precio.descuentoAutoPorcentaje / 100);
    final subtotalFinal = subtotalBruto - descuentoAuto;
    final ahorroTotal = precio.ahorroVsDetal(unidades);
    final esBulto = _unidadEmpaque != 'unidad';

    // Color por tier
    Color tierColor;
    String tierLabel;
    IconData tierIcon;

    switch (precio.tipo) {
      case PrecioTipo.mayor:
        tierColor = const Color(0xFF10B981);
        tierLabel = 'Precio Mayor';
        tierIcon = Icons.workspace_premium_rounded;
      case PrecioTipo.medioMayor:
        tierColor = const Color(0xFF3B82F6);
        tierLabel = 'Medio Mayor';
        tierIcon = Icons.trending_up_rounded;
      case PrecioTipo.detal:
        tierColor = const Color(0xFF64748B);
        tierLabel = 'Precio Detal';
        tierIcon = Icons.local_offer_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tierColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Badge del tier ──
          Row(
            children: [
              Icon(tierIcon, size: 14, color: tierColor),
              const SizedBox(width: 6),
              Text(
                tierLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: tierColor,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '\$${precio.precioUnitario.toStringAsFixed(2)} / unid',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: tierColor.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),

          // ── Conversión de bultos ──
          if (esBulto) ...[
            _previewRow(
              'Conversión',
              '${_cantidadController.text.isEmpty ? 0 : _cantidadController.text} bultos × '
                  '${widget.producto.unidadesPorBulto} u. = $unidades unid',
              cs,
              isDark,
            ),
            const SizedBox(height: 8),
          ],

          // ── Subtotal ──
          _previewRow(
            'Subtotal',
            '\$${subtotalBruto.toStringAsFixed(2)}',
            cs,
            isDark,
          ),

          // ── Descuento automático ──
          if (precio.descuentoAutoPorcentaje > 0) ...[
            const SizedBox(height: 8),
            _previewRow(
              'Desc. volumen (${precio.descuentoAutoPorcentaje.toStringAsFixed(0)}%)',
              '-\$${descuentoAuto.toStringAsFixed(2)}',
              cs,
              isDark,
              color: const Color(0xFFF59E0B),
            ),
            if (precio.reglaAplicada != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '📋 ${precio.reglaAplicada}',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: 12),
          Divider(color: tierColor.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),

          // ── Total ──
          Row(
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '\$${subtotalFinal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: tierColor,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          // ── Ahorro ──
          if (ahorroTotal > 0.01) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.savings_rounded,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ahorro vs. detal: \$${ahorroTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _previewRow(
    String label,
    String value,
    ColorScheme cs,
    bool isDark, {
    Color? color,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color ?? cs.onSurface,
          ),
        ),
      ],
    );
  }

  // ──────────────── Botones ────────────────

  Widget _buildBotones(bool isDark, ColorScheme cs) {
    final valido = _unidadesTotales > 0 && _precioActual != null;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              _weightSubscription?.cancel();
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: isDark ? Colors.white70 : Colors.black54,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: valido ? _confirmar : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  valido ? const Color(0xFF10B981) : cs.surfaceContainerHighest,
              foregroundColor:
                  valido ? Colors.white : cs.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: valido ? 3 : 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_shopping_cart_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Agregar al carrito',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────── Confirmar ────────────────

  void _confirmar() {
    if (_cerrando) return;

    final unidades = _unidadesTotales;
    if (unidades <= 0) return;
    if (_precioActual == null) return;

    _cerrando = true;
    _weightSubscription?.cancel();
    _weightSubscription = null;
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(
      WholesaleQuantityResult(
        cantidad: unidades,
        unidadEmpaque: _unidadEmpaque,
      ),
    );
  }
}