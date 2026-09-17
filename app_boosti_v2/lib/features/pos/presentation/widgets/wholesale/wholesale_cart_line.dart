// lib/features/pos/presentation/widgets/wholesale/wholesale_cart_line.dart
import 'package:flutter/material.dart';

import '../../../domain/wholesale/wholesale_cart_item.dart';
import '../../services/mayoreo/wholesale_pricing_service.dart';
import '../common/status_badge.dart';

/// Línea individual del carrito de ventas al mayor.
///
/// Muestra: producto, tipo de precio, cantidad, precio unitario, descuentos
/// y subtotal. Permite editar cantidad, editar descuento y eliminar.
class WholesaleCartLine extends StatelessWidget {
  final WholesaleCartItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onEditDiscount;

  const WholesaleCartLine({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onEditDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    final tieneDescuento =
        item.tieneDescuentoAuto || item.tieneDescuentoManual;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.requiereAutorizacionDescuento
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: item.requiereAutorizacionDescuento ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Fila superior: nombre + tier badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildTierBadge(),
            ],
          ),

          const SizedBox(height: 8),

          // ── Cantidad × precio ──
          Row(
            children: [
              Icon(
                Icons.numbers_rounded,
                size: 14,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _labelCantidad(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '× \$${item.precioUnitario.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '\$${item.subtotalFinal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          // ── Descuentos aplicados ──
          if (tieneDescuento) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (item.tieneDescuentoAuto)
                  _buildDescuentoChip(
                    label:
                        'Vol. -${item.descuentoAutoPorcentaje.toStringAsFixed(0)}%',
                    color: const Color(0xFFF59E0B),
                    icon: Icons.trending_down_rounded,
                  ),
                if (item.tieneDescuentoManual)
                  _buildDescuentoChip(
                    label:
                        'Manual -${item.descuentoManualPorcentaje.toStringAsFixed(0)}%',
                    color: item.descuentoAutorizado
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    icon: item.descuentoAutorizado
                        ? Icons.verified_rounded
                        : Icons.warning_amber_rounded,
                  ),
              ],
            ),
          ],

          // ── Alerta de ahorro ──
          if (item.ahorroVsDetal > 0.01) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.savings_rounded,
                  size: 12,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  'Ahorro: \$${item.ahorroVsDetal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 6),

          // ── Acciones ──
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.percent_rounded,
                label: item.tieneDescuentoManual ? 'Editar %' : 'Descuento',
                color: const Color(0xFF8B5CF6),
                onTap: onEditDiscount,
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Cant.',
                color: const Color(0xFF3B82F6),
                onTap: onEdit,
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Quitar',
                color: const Color(0xFFEF4444),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────── Helpers ────────────────

  String _labelCantidad() {
    if (item.unidadEmpaque == 'unidad') {
      return '${item.cantidad} u.';
    }
    // Bulto / caja
    final bultos = item.cantidad ~/ item.unidadesPorEmpaque;
    return '$bultos ${item.unidadEmpaque}s (${item.cantidad} u.)';
  }

  Widget _buildTierBadge() {
    Color color;
    String label;
    IconData icon;

    switch (item.tipoPrecio) {
      case PrecioTipo.mayor:
        color = const Color(0xFF10B981);
        label = 'MAYOR';
        icon = Icons.workspace_premium_rounded;
      case PrecioTipo.medioMayor:
        color = const Color(0xFF3B82F6);
        label = 'MEDIO';
        icon = Icons.trending_up_rounded;
      case PrecioTipo.detal:
        color = const Color(0xFF64748B);
        label = 'DETAL';
        icon = Icons.local_offer_rounded;
    }

    return StatusBadge(
      label: label,
      color: color,
      icon: icon,
      size: StatusBadgeSize.small,
    );
  }

  Widget _buildDescuentoChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}