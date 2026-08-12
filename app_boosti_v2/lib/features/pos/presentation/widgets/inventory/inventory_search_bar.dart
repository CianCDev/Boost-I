// lib/features/pos/presentation/widgets/inventory/inventory_search_bar.dart
import 'package:flutter/material.dart';
import '../../utils/input_decoration_helper.dart';

class InventorySearchBar extends StatelessWidget {
  final VoidCallback onScanPressed;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onStockBajoToggled;
  final bool soloStockBajo;

  const InventorySearchBar({
    super.key,
    required this.onScanPressed,
    required this.onSearchChanged,
    required this.onStockBajoToggled,
    required this.soloStockBajo,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                onChanged: onSearchChanged,
                enableInteractiveSelection: false,
                enableIMEPersonalizedLearning: false,
                autofillHints: const <String>[],
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecorationHelper.build(
                  context: context,
                  label: '',
                  hintText: isMobile ? 'Buscar...' : 'Buscar por nombre o código...',
                  prefixIcon: null,
                  isDark: isDark,
                ).copyWith(
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.qr_code_scanner_rounded, size: 26, color: colorScheme.onSurfaceVariant),
                          tooltip: 'Escanear código',
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: EdgeInsets.zero,
                          onPressed: onScanPressed,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.search, size: 20, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
          // Botón Stock Bajo (sin cambios)
          GestureDetector(
            onTap: () => onStockBajoToggled(!soloStockBajo),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: soloStockBajo ? colorScheme.error.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: soloStockBajo ? colorScheme.error : colorScheme.outline.withValues(alpha: 0.2),
                  width: soloStockBajo ? 1.5 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: isMobile ? 14 : 16,
                    color: soloStockBajo ? colorScheme.error : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Stock Bajo',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: soloStockBajo ? FontWeight.w600 : FontWeight.w500,
                      color: soloStockBajo ? colorScheme.error : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}