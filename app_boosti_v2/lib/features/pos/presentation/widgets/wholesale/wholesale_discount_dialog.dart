// lib/features/pos/presentation/widgets/wholesale/wholesale_discount_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/permissions/roles.dart';
import '../../services/mayoreo/wholesale_authorization_service.dart';
import '../admin_validation_dialog.dart';

/// Resultado del diálogo de descuento.
class DiscountResult {
  /// Porcentaje aplicado (0-100).
  final double porcentaje;

  /// Nombre de quien autorizó (si fue necesario).
  final String? autorizadoPorNombre;

  const DiscountResult({
    required this.porcentaje,
    this.autorizadoPorNombre,
  });
}

/// Diálogo para aplicar descuentos (por línea o global).
///
/// Detecta automáticamente si el descuento requiere autorización según
/// el rol del usuario. Si la requiere, abre `AdminValidationDialog`.
class WholesaleDiscountDialog extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final double porcentajeInicial;
  final UserRole rolUsuario;

  /// Cuándo es un descuento global (afecta al subtotal).
  final bool esGlobal;

  const WholesaleDiscountDialog({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.rolUsuario,
    this.porcentajeInicial = 0.0,
    this.esGlobal = false,
  });

  /// Muestra el diálogo y devuelve el resultado o `null`.
  static Future<DiscountResult?> show(
    BuildContext context, {
    required String titulo,
    required String subtitulo,
    required UserRole rolUsuario,
    double porcentajeInicial = 0.0,
    bool esGlobal = false,
  }) {
    return showDialog<DiscountResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WholesaleDiscountDialog(
        titulo: titulo,
        subtitulo: subtitulo,
        rolUsuario: rolUsuario,
        porcentajeInicial: porcentajeInicial,
        esGlobal: esGlobal,
      ),
    );
  }

  @override
  State<WholesaleDiscountDialog> createState() =>
      _WholesaleDiscountDialogState();
}

class _WholesaleDiscountDialogState extends State<WholesaleDiscountDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  late double _porcentajeActual;
  bool _procesando = false;

  /// Nombres predefinidos para acceso rápido.
  static const List<double> _presets = [0, 5, 10, 15, 20, 25, 30, 40, 50];

  double get _topeRol =>
      WholesaleAuthorizationService.topeParaRol(widget.rolUsuario);

  @override
  void initState() {
    super.initState();
    _porcentajeActual = widget.porcentajeInicial.clamp(0.0, 100.0);
    _controller.text = _formatearValor(_porcentajeActual);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _formatearValor(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  void _onInputChanged(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed != null) {
      setState(() => _porcentajeActual = parsed.clamp(0.0, 100.0));
    } else if (value.isEmpty) {
      setState(() => _porcentajeActual = 0);
    }
  }

  void _setPreset(double v) {
    _controller.text = _formatearValor(v);
    setState(() => _porcentajeActual = v);
  }

  // ──────────────── Confirmar ────────────────

  Future<void> _confirmar() async {
    if (_procesando) return;

    // Validaciones básicas
    if (_porcentajeActual < 0 || _porcentajeActual > 100) {
      _snack('El descuento debe estar entre 0% y 100%');
      return;
    }

    if (_porcentajeActual == 0) {
      Navigator.of(context).pop(
        const DiscountResult(porcentaje: 0),
      );
      return;
    }

    // ¿Requiere autorización?
    final evaluacion = WholesaleAuthorizationService.evaluar(
      descuentoPorcentaje: _porcentajeActual,
      rolSolicitante: widget.rolUsuario,
    );

    if (!evaluacion.esValido) {
      _snack(evaluacion.motivoInvalidez ?? 'Descuento inválido');
      return;
    }

    // Sin autorización: aplicar directo
    if (!evaluacion.requiereAutorizacion) {
      Navigator.of(context).pop(
        DiscountResult(porcentaje: _porcentajeActual),
      );
      return;
    }

    // Con autorización: abrir AdminValidationDialog
    setState(() => _procesando = true);

    final autorizado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AdminValidationDialog(
        onSuccess: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );

    if (!mounted) return;
    setState(() => _procesando = false);

    if (autorizado != true) return;

    // Pasar al padre con el nombre del autorizador.
    // Nota: AdminValidationDialog no devuelve nombre; usamos "Administrador".
    Navigator.of(context).pop(
      DiscountResult(
        porcentaje: _porcentajeActual,
        autorizadoPorNombre: 'Administrador',
      ),
    );
  }

  void _cancelar() {
    Navigator.of(context).pop();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
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

    final requiereAuth = _porcentajeActual > _topeRol;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              _buildHeader(isDark, cs),
              const SizedBox(height: 20),

              // ── Presets ──
              _buildPresets(isDark),
              const SizedBox(height: 16),

              // ── Input manual ──
              _buildInput(isDark, cs),
              const SizedBox(height: 16),

              // ── Preview / Info ──
              _buildInfoPanel(cs, isDark, requiereAuth),
              const SizedBox(height: 20),

              // ── Botones ──
              _buildBotones(isDark, cs),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── Header ────────────────

  Widget _buildHeader(bool isDark, ColorScheme cs) {
    final color = widget.esGlobal
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF3B82F6);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.esGlobal
                ? Icons.percent_rounded
                : Icons.local_offer_rounded,
            size: 22,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitulo,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _cancelar,
          icon: const Icon(Icons.close_rounded, size: 20),
          color: cs.onSurfaceVariant,
        ),
      ],
    );
  }

  // ──────────────── Presets ────────────────

  Widget _buildPresets(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presets.map((v) {
        final selected = v == _porcentajeActual;
        final excedeTope = v > _topeRol;

        Color color;
        if (excedeTope) {
          color = const Color(0xFFF59E0B);
        } else {
          color = const Color(0xFF10B981);
        }

        return GestureDetector(
          onTap: () => _setPreset(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? color
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? color
                    : color.withValues(alpha: 0.3),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              v == 0 ? 'Sin desc.' : '${v.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : (excedeTope ? color : (isDark ? Colors.white70 : Colors.black87)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ──────────────── Input ────────────────

  Widget _buildInput(bool isDark, ColorScheme cs) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
      ],
      onChanged: _onInputChanged,
      onSubmitted: (_) => _confirmar(),
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Descuento manual',
        labelStyle: TextStyle(
          fontSize: 13,
          color: cs.onSurfaceVariant,
        ),
        prefixIcon: const Icon(Icons.percent_rounded, size: 20),
        suffixText: '%',
        suffixStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: cs.onSurfaceVariant,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF10B981),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // ──────────────── Info panel ────────────────

  Widget _buildInfoPanel(
    ColorScheme cs,
    bool isDark,
    bool requiereAuth,
  ) {
    Color borderColor;
    Color bgColor;
    Color textColor;
    IconData icon;
    String titulo;
    String mensaje;

    if (requiereAuth) {
      borderColor = const Color(0xFFF59E0B);
      bgColor = borderColor.withValues(alpha: isDark ? 0.15 : 0.1);
      textColor = borderColor;
      icon = Icons.lock_rounded;
      titulo = 'Requiere autorización';
      mensaje =
          'El ${_formatearValor(_porcentajeActual)}% supera tu tope de '
          '${_formatearValor(_topeRol)}%. Se pedirá aprobación del admin.';
    } else {
      borderColor = const Color(0xFF10B981);
      bgColor = borderColor.withValues(alpha: isDark ? 0.15 : 0.08);
      textColor = borderColor;
      icon = Icons.check_circle_rounded;
      titulo = 'Dentro de tu tope';
      mensaje =
          'Puedes aplicar hasta ${_formatearValor(_topeRol)}% sin autorización.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textColor),
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
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mensaje,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Botones ────────────────

  Widget _buildBotones(bool isDark, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _procesando ? null : _cancelar,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: cs.onSurfaceVariant,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
            onPressed: _procesando ? null : _confirmar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
            child: _procesando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Aplicar descuento',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }
}