// lib/features/pos/presentation/widgets/common/dialog_header.dart
import 'package:flutter/material.dart';

/// Cabecera estándar para diálogos: ícono + título/subtítulo + botón cerrar.
class DialogHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final bool useGradient;
  final VoidCallback? onClose;
  final double iconSize;

  const DialogHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color = const Color(0xFF8B5CF6),
    this.useGradient = true,
    this.onClose,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(useGradient ? 12 : 10),
          decoration: BoxDecoration(
            gradient: useGradient
                ? LinearGradient(
                    colors: [
                      color,
                      Color.lerp(color, Colors.black, 0.15)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: useGradient ? null : color.withValues(alpha: 0.1),
            shape: useGradient ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: useGradient ? BorderRadius.circular(14) : null,
            boxShadow: useGradient
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: useGradient ? Colors.white : color,
            size: iconSize,
          ),
        ),
        SizedBox(width: useGradient ? 14 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            onPressed: onClose ?? () => Navigator.pop(context),
            tooltip: 'Cerrar',
          ),
        ),
      ],
    );
  }
}