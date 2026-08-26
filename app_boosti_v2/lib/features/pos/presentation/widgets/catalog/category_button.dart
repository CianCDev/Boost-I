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
    final bool esStockBajo = widget.categoria == 'Stock Bajo';
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool seleccionado = widget.esSeleccionada;

    // 1. Colores de Fondo y Texto
    final Color baseColor = esStockBajo ? pumpkinSpice : primaryGreen;
    
    final Color backgroundColor = seleccionado
        ? baseColor
        : (_isHovered
            ? (isDark ? Colors.white.withValues(alpha: 0.08) : textMuted.withValues(alpha: 0.05))
            : Colors.transparent);

    final Color textColor = seleccionado
        ? Colors.white
        : (isDark ? Colors.white : textDark);

    // 2. Bordes: Mismo grosor siempre para evitar saltos de layout
    final Color borderColor = seleccionado
        ? Colors.transparent
        : (_isHovered
            ? (isDark ? Colors.white.withValues(alpha: 0.15) : textMuted.withValues(alpha: 0.15))
            : (isDark ? Colors.white.withValues(alpha: 0.05) : textMuted.withValues(alpha: 0.2)));

    // 3. Sombras dinámicas mediante opacidad (Evita crear/destruir el BoxShadow)
    final Color shadowColor = seleccionado
        ? baseColor.withValues(alpha: 0.35)
        : (_isHovered
            ? (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04))
            : Colors.transparent);

    final double fontSize = isTablet ? 15.0 : 13.0;
    final EdgeInsets padding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 0)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 0);

    // 4. Lógica del Icono
    final bool showIcon = seleccionado || esStockBajo;
    IconData iconData = Icons.warning_amber_rounded;
    Color iconColor = pumpkinSpice;

    if (seleccionado) {
      iconData = esStockBajo ? Icons.warning_amber_rounded : Icons.check_circle_rounded;
      iconColor = Colors.white;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic, // Curva suave estándar de Material 3
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: 1.0, // Grosor fijo
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: seleccionado ? 12 : 8,
              offset: Offset(0, seleccionado ? 4 : 2),
            ),
          ],
        ),
        // Envolvemos en Material para un InkWell (efecto ripple) nativo y contenido
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
                  // Animación de expansión del Icono (Desliza el texto sin saltos)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: showIcon ? 18.0 : 0.0,
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(), // ✅ Aserción corregida
                    child: Icon(
                      iconData,
                      size: 18,
                      color: iconColor,
                    ),
                  ),
                  // Espaciado dinámico
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: showIcon ? 6.0 : 0.0,
                  ),
                  // Texto estático en layout, animado en color
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500, // Mismo peso para evitar saltos
                        color: textColor,
                        letterSpacing: 0.3,
                      ),
                      child: Text(widget.categoria),
                    ),
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