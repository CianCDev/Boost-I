// lib/features/pos/presentation/widgets/common/segmented_toggle.dart
import 'package:flutter/material.dart';

/// Toggle segmentado custom que reemplaza SegmentedButton con mejor estética
/// y comportamiento consistente en la app.
class SegmentedToggle<T> extends StatelessWidget {
  final List<SegmentedToggleItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color accentColor;

  const SegmentedToggle({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.accentColor = const Color(0xFF8B5CF6),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
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
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(item.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 10,
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
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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