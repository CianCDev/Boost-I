// lib/features/pos/presentation/widgets/common/glass_search_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// Barra de búsqueda con glassmorphism + animaciones.
///
/// - Fondo tipo vidrio con blur.
/// - Al enfocar: glow con el color `accentColor` (o `primary` del tema),
///   el icono rota ligeramente y el borde se ilumina.
/// - Botón "limpiar" aparece/desaparece con `AnimatedSwitcher`.
///
/// La API es retrocompatible: puedes seguir usando solo `hint` + `onChanged`.
class GlassSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final IconData prefixIcon;

  /// Radio del borde. Ajustable por si se usa dentro de contenedores
  /// con radios distintos (ej. 16 para diálogos, 12 para cards).
  final double borderRadius;

  /// Padding vertical interno. Ajustable para tamaños compactos.
  final double verticalPadding;

  /// Color del glow al enfocar. Si es null usa el `primary` del tema.
  final Color? accentColor;

  /// Permite desactivar todas las animaciones (útil para tests).
  final bool enableAnimations;

  const GlassSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.prefixIcon = Icons.search_rounded,
    this.borderRadius = 16,
    this.verticalPadding = 12,
    this.accentColor,
    this.enableAnimations = true,
  });

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  late final FocusNode _focusNode;
  late final TextEditingController _internalController;
  bool _isFocused = false;
  String _value = '';

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  Duration get _fast => widget.enableAnimations
      ? const Duration(milliseconds: 200)
      : Duration.zero;
  Duration get _med => widget.enableAnimations
      ? const Duration(milliseconds: 260)
      : Duration.zero;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _internalController = TextEditingController();
    _value = _controller.text;
    _focusNode.addListener(_onFocus);
    _controller.addListener(_onText);
  }

  void _onFocus() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onText() {
    if (mounted) setState(() => _value = _controller.text);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _controller.removeListener(_onText);
    _focusNode.dispose();
    if (widget.controller == null) _internalController.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final primary = widget.accentColor ?? colorScheme.primary;

    final unfocusedFill = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.45);

    final focusedFill = isDark
        ? primary.withValues(alpha: 0.12)
        : primary.withValues(alpha: 0.07);

    final unfocusedBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.65);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: _med,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isFocused ? focusedFill : unfocusedFill,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isFocused
                  ? primary.withValues(alpha: 0.65)
                  : unfocusedBorder,
              width: _isFocused ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (_isFocused)
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.30 : 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            cursorColor: primary,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              prefixIcon: AnimatedRotation(
                turns: (_isFocused && widget.enableAnimations) ? 0.05 : 0.0,
                duration: _med,
                curve: Curves.easeOutCubic,
                child: Icon(
                  widget.prefixIcon,
                  color: _isFocused
                      ? primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              suffixIcon: AnimatedSwitcher(
                duration: _fast,
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _value.isEmpty
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : IconButton(
                        key: const ValueKey('clear'),
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        color: colorScheme.onSurfaceVariant,
                        tooltip: 'Limpiar',
                        onPressed: _clear,
                      ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.verticalPadding,
              ),
            ),
          ),
        ),
      ),
    );
  }
}