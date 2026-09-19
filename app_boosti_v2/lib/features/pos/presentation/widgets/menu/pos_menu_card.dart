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
/// - Badge opcional (contador en la esquina).
/// - Hover con elevación y borde del color de la opción.
/// - Layout responsive: horizontal en desktop/tablet, vertical en mobile
///   cuando `layout` es `auto`, o forzado con `MenuCardLayout`.
/// - Cursor pointer nativo.
/// - `compactMode`: oculta el subtitle y reduce tamaños/paddings,
///   ideal para grids de 2 columnas en mobile sin overflow.
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

  /// Modo compacto: oculta el subtitle y reduce paddings/tamaños.
  /// Ideal para grids de 2 columnas en mobile.
  final bool compactMode;

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
    this.compactMode = false,
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

    // Padding por defecto: compacto < mobile < tablet/desktop
    final defaultPadding = widget.compactMode
        ? 10.0
        : (isMobile ? 14.0 : 16.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          clipBehavior: Clip.hardEdge,
          padding: widget.padding ?? EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh
                    .withValues(alpha: _hovered ? 0.9 : 0.7)
                : Colors.white.withValues(alpha: _hovered ? 1.0 : 0.95),
            borderRadius: BorderRadius.circular(16),
            // ✅ Ancho FIJO (1.0): solo cambia el color en hover.
            //    Antes era 1.0 → 1.5, lo que robaba 1px de espacio interno
            //    y provocaba el "BOTTOM OVERFLOWED BY 1.00 PIXELS".
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1.0,
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
          child: _usarVertical
              ? _buildVertical(theme)
              : _buildHorizontal(theme),
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
    final compact = widget.compactMode;

    // ✅ En compactMode NUNCA se muestra el subtitle.
    final mostrarSubtitle = !compact &&
        widget.subtitle != null &&
        widget.subtitle!.isNotEmpty;

    return Row(
      children: [
        _iconBox(isMobile ? 22.0 : 24.0),
        SizedBox(width: compact ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: compact ? 13 : (isMobile ? 14 : 15),
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.badge != null && widget.badge! > 0)
                    _badgeChip(),
                ],
              ),
              if (mostrarSubtitle) ...[
                const SizedBox(height: 3),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.2,
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
    final compact = widget.compactMode;

    // ✅ En compactMode NUNCA se muestra el subtitle.
    //    Antes se mostraba igual y provocaba el "BOTTOM OVERFLOWED BY 24 PIXELS".
    final mostrarSubtitle = !compact &&
        widget.subtitle != null &&
        widget.subtitle!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // ✅ 22.0 / 26.0 son double (antes eran int → error de tipo).
            _iconBox(compact ? 22.0 : 26.0),
            if (widget.badge != null && widget.badge! > 0)
              Positioned(
                top: -6,
                right: -6,
                child: _badgeChip(),
              ),
          ],
        ),
        SizedBox(height: compact ? 6 : 10),
        // Flexible permite que el título se encoja si el card es muy bajo,
        // evitando overflows en títulos de 2 líneas.
        Flexible(
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 12.5 : 13.5,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.2,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (mostrarSubtitle) ...[
          const SizedBox(height: 3),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              height: 1.2,
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
    final compact = widget.compactMode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: _hovered ? 0.20 : 0.12),
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