import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

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

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (widget.esSeleccionada) {
      backgroundColor = esStockBajo ? const Color(0xFFEF4444) : const Color(0xFF10B981);
      borderColor = backgroundColor;
      textColor = Colors.white;
    } else {
      backgroundColor = _isHovered ? const Color(0xFFF1F5F9) : Colors.white;
      borderColor = _isHovered ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1);
      textColor = const Color(0xFF334155);
    }

    final double fontSize = isTablet ? 16.0 : 13.0;
    final padding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 6);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: isTablet ? 2 : 1.5),
            boxShadow: widget.esSeleccionada
                ? [
                    BoxShadow(
                      color: (esStockBajo ? Colors.red : const Color(0xFF10B981))
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esStockBajo) ...[
                Icon(Icons.warning_amber_rounded,
                    size: 16,
                    color: widget.esSeleccionada ? Colors.white : Colors.amber),
                const SizedBox(width: 4),
              ] else if (widget.esSeleccionada) ...[
                const Icon(Icons.check_circle, size: 16, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                widget.categoria,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: widget.esSeleccionada ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}