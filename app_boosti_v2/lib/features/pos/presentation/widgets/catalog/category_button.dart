import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/themes/app_colors.dart';

class CategoryButton extends StatefulWidget {
  final String categoria;
  final bool esSeleccionada;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.categoria,
    required this.esSeleccionada,
    required this.onTap,
  });

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool esStockBajo = widget.categoria.trim().toLowerCase() == 'stock bajo';
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool seleccionado = widget.esSeleccionada;

    // Colores
    final Color baseColor = esStockBajo ? pumpkinSpice : primaryGreen;

    final Color backgroundColor = seleccionado
        ? baseColor
        : (_isHovered
            ? (isDark ? Colors.white.withValues(alpha: 0.08) : textMuted.withValues(alpha: 0.05))
            : Colors.transparent);

    final Color textColor = seleccionado
        ? Colors.white
        : (isDark ? Colors.white : textDark);

    final Color borderColor = seleccionado
        ? Colors.transparent
        : (_isHovered
            ? (isDark ? Colors.white.withValues(alpha: 0.15) : textMuted.withValues(alpha: 0.15))
            : (isDark ? Colors.white.withValues(alpha: 0.05) : textMuted.withValues(alpha: 0.2)));

    final Color shadowColor = seleccionado
        ? baseColor.withValues(alpha: 0.35)
        : (_isHovered
            ? (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04))
            : Colors.transparent);

    // Tamaños responsivos
    final double fontSize = isTablet ? 15.0 : 13.0;
    final EdgeInsets padding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 4);

    // Lógica del Icono: solo en Stock Bajo (siempre) o en chips seleccionados
    final bool mostrarIcono = seleccionado || esStockBajo;
    IconData iconData;
    Color iconColor;

    if (seleccionado) {
      // Si está seleccionado, mostrar check (o advertencia si es Stock Bajo)
      iconData = esStockBajo ? Icons.warning_amber_rounded : Icons.check_circle_rounded;
      iconColor = Colors.white;
    } else if (esStockBajo) {
      // Si es Stock Bajo pero no seleccionado, mostrar advertencia naranja
      iconData = Icons.warning_amber_rounded;
      iconColor = pumpkinSpice;
    } else {
      // No debería llegar aquí, pero por seguridad
      iconData = Icons.check_circle_rounded;
      iconColor = Colors.white;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: seleccionado ? 12 : 8,
              offset: Offset(0, seleccionado ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Icono con animación de ancho + opacidad
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: mostrarIcono ? 24.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: mostrarIcono ? 1.0 : 0.0,
                        child: Icon(
                          iconData,
                          size: 18,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                  // ✅ Texto con animación de color
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 0.3,
                      height: 1.0,
                    ),
                    child: Text(widget.categoria),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}