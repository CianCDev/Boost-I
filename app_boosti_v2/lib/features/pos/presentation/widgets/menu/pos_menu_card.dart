// lib/features/pos/presentation/widgets/menu/pos_menu_card.dart
import 'package:flutter/material.dart';

import '../../utils/responsive_helper.dart';

/// Card genérica para opciones de menú / accesos rápidos.
///
/// Sirve tanto para `PosMenuScreen` como para `MainPosScreen`.
///
/// Soporta:
/// - Icono con fondo tintado según color de la opción.
/// - Título + subtítulo opcional.
/// - Badge opcional (contador rojo en la esquina).
/// - Hover con elevación y borde del color de la opción.
/// - Layout responsive: horizontal en desktop/tablet, vertical en mobile
///   cuando `layout` es `auto`, o forzado con `MenuCardLayout`.
/// - Cursor pointer nativo.
class PosMenuCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  /// Contador opcional para mostrar badge numérico (ej: pendientes).
  final int? badge;

  /// Ícono opcional en lugar del chevron por defecto.
  final Widget? trailing;

  /// Controla el layout del contenido.
  final MenuCardLayout layout;

  /// Padding interno. `null` usa el default responsive.
  final EdgeInsets? padding;

  const PosMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.badge,
    this.trailing,
    this.layout = MenuCardLayout.auto,
    this.padding,
  });

  @override
  State<PosMenuCard> createState() => _PosMenuCardState();
}

enum MenuCardLayout {
  /// Horizontal en tablet/desktop, vertical en mobile.
  auto,

  /// Siempre horizontal.
  horizontal,

  /// Siempre vertical (icono arriba).
  vertical,
}

class _PosMenuCardState extends State<PosMenuCard> {
  bool _hovered = false;

  bool get _usarVertical {
    if (widget.layout == MenuCardLayout.vertical) return true;
    if (widget.layout == MenuCardLayout.horizontal) return false;
    // auto → vertical solo en mobile
    return ResponsiveHelper.isMobile(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: widget.padding ??
              EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh
                    .withValues(alpha: _hovered ? 0.9 : 0.7)
                : Colors.white.withValues(alpha: _hovered ? 1.0 : 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.2 : (_hovered ? 0.08 : 0.04),
                ),
                blurRadius: _hovered ? 14 : 8,
                offset: Offset(0, _hovered ? 5 : 3),
              ),
            ],
          ),
          child: _usarVertical ? _buildVertical(theme) : _buildHorizontal(theme),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LAYOUT HORIZONTAL (desktop / tablet)
  // ══════════════════════════════════════════════════════════════

  Widget _buildHorizontal(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Row(
      children: [
        _iconBox(isMobile ? 22 : 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.badge != null && widget.badge! > 0)
                    _badgeChip(),
                ],
              ),
              if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        widget.trailing ?? _defaultTrailing(),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LAYOUT VERTICAL (mobile)
  // ══════════════════════════════════════════════════════════════

  Widget _buildVertical(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _iconBox(28),
            if (widget.badge != null && widget.badge! > 0)
              Positioned(
                top: -6,
                right: -6,
                child: _badgeChip(),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════

  Widget _iconBox(double iconSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.color
            .withValues(alpha: _hovered ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.icon,
        size: iconSize,
        color: widget.color,
      ),
    );
  }

  Widget _defaultTrailing() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.only(left: _hovered ? 4 : 0),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: _hovered
            ? widget.color
            : Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.4),
      ),
    );
  }

  Widget _badgeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        widget.badge! > 99 ? '99+' : '${widget.badge}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}