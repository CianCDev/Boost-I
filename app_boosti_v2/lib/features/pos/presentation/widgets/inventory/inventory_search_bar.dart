// lib/features/pos/presentation/widgets/inventory/inventory_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';

class InventorySearchBar extends ConsumerWidget {
  final VoidCallback onScanPressed;
  final ValueChanged<String> onSearchChanged;

  const InventorySearchBar({
    super.key,
    required this.onScanPressed,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? bgDark : bgLight;
    final textColor = isDark ? Colors.white : textDark;
    final hintColor = textMuted;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : textMuted.withValues(alpha: 0.2);
    final focusedColor = primaryGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                style: TextStyle(
                  color: textColor,
                  fontSize: isMobile ? 14 : 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre / código...',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: isMobile ? 13 : 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: hintColor,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: focusedColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón Escáner (igual que en catálogo)
          _ScanButton(onPressed: onScanPressed, isMobile: isMobile),
        ],
      ),
    );
  }
}

// Botón de escáner (extraído para mantener estado)
class _ScanButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isMobile;

  const _ScanButton({
    required this.onPressed,
    required this.isMobile,
  });

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> {
  bool isPressed = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    double scaleFactor = 1.0;
    if (isPressed) {
      scaleFactor = 0.92;
    } else if (isHovered) {
      scaleFactor = 1.05;
    }

    return Tooltip(
      message: 'Escanear código de barras',
      waitDuration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: Matrix4.diagonal3Values(scaleFactor, scaleFactor, 1.0),
            transformAlignment: Alignment.center,
            padding: EdgeInsets.all(widget.isMobile ? 12 : 14),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}