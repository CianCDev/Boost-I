// lib/features/pos/presentation/widgets/common/status_badge.dart
import 'package:flutter/material.dart';

/// Badge de estado compacto (Activo, Inactivo, ACTUAL, etc.).
enum StatusBadgeSize { small, medium, large }

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final StatusBadgeSize size;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.size = StatusBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final dims = switch (size) {
      StatusBadgeSize.small => const _Dims(hPad: 6, vPad: 2, font: 9, icon: 10),
      StatusBadgeSize.medium => const _Dims(hPad: 8, vPad: 3, font: 10, icon: 12),
      StatusBadgeSize.large => const _Dims(hPad: 10, vPad: 5, font: 12, icon: 14),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dims.hPad,
        vertical: dims.vPad,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dims.icon, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dims.font,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dims {
  final double hPad, vPad, font, icon;
  const _Dims({
    required this.hPad,
    required this.vPad,
    required this.font,
    required this.icon,
  });
}