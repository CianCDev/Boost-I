// lib/features/pos/presentation/widgets/common/segmented_toggle.dart
import 'package:flutter/material.dart';

/// Toggle segmentado custom que reemplaza SegmentedButton con mejor estética
/// y comportamiento consistente en la app.
class SegmentedToggle<T> extends StatelessWidget {
  final List<SegmentedToggleItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color accentColor;

  /// Fuerza el modo "solo icono" independientemente del ancho.
  /// Si es `false`, se activa automáticamente cuando el ancho < 380.
  final bool compact;

  const SegmentedToggle({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.accentColor = const Color(0xFF8B5CF6),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final autoCompact = constraints.maxWidth < 380;
        final useCompact = compact || autoCompact;
  

        final hPad = useCompact ? 16.0 : 18.0;
        final vPad = useCompact ? 12.0 : 10.0;
        final iconSize = useCompact ? 20.0 : 16.0;
        return Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                final isSelected = item.value == selected;
                return Flexible(
                  fit: FlexFit.loose,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onChanged(item.value),
                      child: AnimatedScale(
                        scale: isSelected ? 1.0 : 0.96,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: hPad,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? accentColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: accentColor
                                          .withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: iconSize,   // ✅ antes era 16 fijo
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black54),
                              ),
                              if (!useCompact) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black54),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class SegmentedToggleItem<T> {
  final T value;
  final String label;
  final IconData icon;
  const SegmentedToggleItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}