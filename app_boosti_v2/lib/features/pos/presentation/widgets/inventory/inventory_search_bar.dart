import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: isMobile ? 'Buscar...' : 'Buscar por nombre o código...',
                  hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.grey.shade500),
                  isDense: true,
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 28, color: Color(0xFF475569)),
                          tooltip: 'Escanear código',
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          padding: EdgeInsets.zero,
                          onPressed: onScanPressed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    ],
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('⚠️ Stock Bajo'),
            selected: soloStockBajo,
            onSelected: onStockBajoToggled,
            selectedColor: const Color(0xFFFEE2E2),
            checkmarkColor: Colors.red,
            labelStyle: TextStyle(fontSize: isMobile ? 10 : 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}