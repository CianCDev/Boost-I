// lib/features/pos/presentation/widgets/wholesale/wholesale_cart_summary.dart
import 'package:flutter/material.dart';

import '../../providers/wholesale/wholesale_cart_provider.dart';

/// Panel de totales del carrito de ventas al mayor.
class WholesaleCartSummary extends StatelessWidget {
  final WholesaleCartState cartState;
  final double tasaBcv;

  const WholesaleCartSummary({
    super.key,
    required this.cartState,
    required this.tasaBcv,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${cartState.cantidadItems} items',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 12),

          // ── Subtotal ──
          _buildRow(
            'Subtotal',
            '\$${cartState.subtotal.toStringAsFixed(2)}',
            cs,
          ),

          // ── Descuento global ──
          if (cartState.descuentoGlobalPorcentaje > 0) ...[
            const SizedBox(height: 6),
            _buildRow(
              'Desc. global (${cartState.descuentoGlobalPorcentaje.toStringAsFixed(0)}%)',
              '-\$${cartState.montoDescuentoGlobal.toStringAsFixed(2)}',
              cs,
              valueColor: const Color(0xFFF59E0B),
            ),
          ],

          // ── Ahorro total ──
          if (cartState.ahorroTotalVsDetal > 0.01) ...[
            const SizedBox(height: 6),
            _buildRow(
              'Ahorro vs. detal',
              '-\$${cartState.ahorroTotalVsDetal.toStringAsFixed(2)}',
              cs,
              valueColor: const Color(0xFF10B981),
              small: true,
            ),
          ],

          // ── IVA ──
          const SizedBox(height: 6),
          _buildRow(
            'IVA (${WholesaleCartState.ivaPorcentaje.toStringAsFixed(0)}%)',
            '\$${cartState.impuesto.toStringAsFixed(2)}',
            cs,
          ),

          const SizedBox(height: 12),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 12),

          // ── Total USD ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
              Text(
                cartState.total.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
            ],
          ),

          // ── Total Bs ──
          if (tasaBcv > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.currency_exchange_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Bs. ${(cartState.total * tasaBcv).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '@ ${tasaBcv.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    ColorScheme cs, {
    Color? valueColor,
    bool small = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: small ? 11 : 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}