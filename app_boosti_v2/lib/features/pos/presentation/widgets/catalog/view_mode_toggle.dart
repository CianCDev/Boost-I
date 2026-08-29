// lib/features/pos/presentation/widgets/catalog/view_mode_toggle.dart
// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog/view_mode_provider.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';

class ViewModeToggle extends ConsumerWidget {
  final Widget gridChild;
  final Widget listChild;

  const ViewModeToggle({
    super.key,
    required this.gridChild,
    required this.listChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(viewModeProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ----- BARRA DE TOGGLE -----
        Container(
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
        ),
        // ----- CONTENIDO ANIMADO (desvanecimiento puro) -----
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350), // ⬅️ 350ms para transición suave
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              // ✅ Solo desvanecimiento, sin escala ni desplazamiento
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            // ✅ Clave única para que AnimatedSwitcher reconozca el cambio
            child: currentMode == ViewMode.grid
                ? gridChild
                : listChild,
          ),
        ),
      ],
    );
  }

  // ---------- BOTONES DE TOGGLE (sin cambios) ----------
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

    return StatefulBuilder(
      builder: (context, setState) {
        // ignore: unused_local_variable
        bool isHovered = false;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () {
              ref.read(viewModeProvider.notifier).state = target;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 14,
                vertical: isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? primaryGreen
                    : ((isDark ? Colors.grey.shade900 : Colors.grey.shade100)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : ((isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                  width: 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: primaryGreen.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      icon,
                      key: ValueKey('$selected-$icon'),
                      size: isMobile ? 18 : 20,
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade600),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey.shade600),
                      ),
                      child: Text(label),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}