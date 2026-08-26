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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Vista:',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: colorScheme.onSurfaceVariant,
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
  ) {
    final selected = current == target;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        ref.read(viewModeProvider.notifier).state = target;
        // Guardar preferencia si se desea con SharedPreferences
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 4 : 6),
        decoration: BoxDecoration(
          color: selected ? mintLeaf : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? mintLeaf : colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile ? 18 : 20,
              color: selected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            if (!isMobile) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}