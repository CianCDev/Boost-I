// lib/features/pos/presentation/widgets/catalog/view_mode_toggle.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog/view_mode_provider.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';

class ViewModeToggle extends ConsumerWidget {
  const ViewModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(viewModeProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Vista:',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: isDark ? Colors.white70 : textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            context,
            ref,
            currentMode,
            ViewMode.grid,
            Icons.grid_view_rounded,
            'Grid',
            isMobile,
            isDark,
          ),
          const SizedBox(width: 4),
          _buildToggleButton(
            context,
            ref,
            currentMode,
            ViewMode.list,
            Icons.list_rounded,
            'Lista',
            isMobile,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    WidgetRef ref,
    ViewMode current,
    ViewMode target,
    IconData icon,
    String label,
    bool isMobile,
    bool isDark,
  ) {
    final selected = current == target;
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(
        builder: (context, setState) {
          // ignore: unused_local_variable
          bool isHovered = false;

          return GestureDetector(
            onTap: () {
              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
              ref.read(viewModeProvider.notifier).state = target;
            },
            onTapDown: (_) => setState(() => isHovered = true),
            onTapUp: (_) => setState(() => isHovered = false),
            onTapCancel: () => setState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 14,
                vertical: isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? primaryGreen
                    : (Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : (textMuted.withValues(alpha: 0.2)),
                  width: 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: isMobile ? 18 : 20,
                    color: selected ? Colors.white : (isDark ? Colors.white70 : textMuted),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? Colors.white : (isDark ? Colors.white70 : textMuted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}