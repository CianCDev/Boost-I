import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';
import 'cart_bottom_sheet.dart';

class FixedCartSummary extends ConsumerWidget {
  final VoidCallback onCobrar;

  const FixedCartSummary({super.key, required this.onCobrar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final bcvTasa = ref.watch(bcvProvider).tasa;
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBlue : cardLight;
    final textColor = isDark ? Colors.white : textDark;
    final textSecondaryColor = isDark ? Colors.white70 : textMuted;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : primaryGreen.withValues(alpha: 0.30);

    // Determinar si hay items
    final hasItems = cartState.items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // ajuste
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: isDark ? 20 : 12,
            offset: const Offset(0, -8),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: isDark ? 1 : 1.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Totales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total USD: ',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: textSecondaryColor,
                        ),
                      ),
                      Text(
                        '\$${cartState.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 22 : 18,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bs. ${(cartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 13,
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Contador de items
            if (hasItems)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pumpkinSpice,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cartState.items.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 14,
                    color: Colors.white,
                  ),
                ),
              ),

            // Botón "Ver Carrito" (dinámico)
            MouseRegion(
              cursor: hasItems ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: ElevatedButton(
                onPressed: hasItems
                    ? () => _openCartBottomSheet(context, ref, onCobrar)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasItems ? primaryGreen : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  minimumSize: Size(0, isTablet ? 56 : 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: isTablet ? 20 : 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTablet ? 'Ver Carrito' : 'Carrito',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCartBottomSheet(BuildContext context, WidgetRef ref, VoidCallback onCobrar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return CartBottomSheet(
          onCobrar: onCobrar,
        );
      },
    );
  }
}