// lib/features/panel/widgets/panel_button.dart
import 'package:flutter/material.dart';

class PanelButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PanelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<PanelButton> createState() => _PanelButtonState();
}

class _PanelButtonState extends State<PanelButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        // 🔥 Fondo sólido (blanco o gris oscuro) como tarjetas de productos
        color: isDark
            ? (_isHovered ? Colors.grey[800] : Colors.grey[850])
            : (_isHovered ? const Color(0xFFFAFAFA) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.05)
              : Colors.black.withValues(alpha: _isHovered ? 0.05 : 0.02),
          width: 1,
        ),
        // 🔥 Sombra suave permanente, como en las tarjetas de productos destacados
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: _isHovered ? 0.15 : 0.05),
            blurRadius: _isHovered ? 12 : 8,
            offset: const Offset(0, 3),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (value) => setState(() => _isHovered = value),
          borderRadius: BorderRadius.circular(16),
          mouseCursor: SystemMouseCursors.click,
          hoverColor: Colors.transparent,
          splashColor: widget.color.withValues(alpha: 0.15),
          highlightColor: widget.color.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _isHovered
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}