// lib/features/pos/presentation/widgets/common/active_toggle.dart
import 'package:flutter/material.dart';

/// Toggle reutilizable de activo/inactivo para cualquier formulario.
/// Unifica el look en crear_local, crear_proveedor, crear_departamento, etc.
class ActiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String activeLabel;
  final String inactiveLabel;
  final String? activeSubtitle;
  final String? inactiveSubtitle;
  final Color activeColor;

  const ActiveToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeLabel,
    required this.inactiveLabel,
    this.activeSubtitle,
    this.inactiveSubtitle,
    this.activeColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final subtitle = value ? activeSubtitle : inactiveSubtitle;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: value
              ? activeColor.withValues(alpha: 0.1)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? activeColor.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: SwitchListTile(
          title: Text(
            value ? activeLabel : inactiveLabel,
            style: TextStyle(
              color: value
                  ? (isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669))
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ),
    );
  }
}