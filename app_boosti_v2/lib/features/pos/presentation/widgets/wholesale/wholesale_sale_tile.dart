// lib/features/pos/presentation/widgets/wholesale/wholesale_sale_tile.dart
import 'package:flutter/material.dart';

import '../../../data/Local/entities/venta_entity.dart';

/// Tarjeta compacta de una venta al mayor en el historial.
class WholesaleSaleTile extends StatelessWidget {
  final VentaEntity venta;
  final VoidCallback onTap;

  const WholesaleSaleTile({
    super.key,
    required this.venta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    final fecha = venta.fecha;
    final hora = fecha != null
        ? '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final fechaStr = fecha != null
        ? '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}'
        : '--/--/----';

    final esNota = venta.tipoDocumento == 'nota_entrega';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? cs.surfaceContainerHigh.withValues(alpha: 0.5)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Fila superior ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono documento
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      esNota
                          ? Icons.description_outlined
                          : Icons.receipt_long_rounded,
                      size: 18,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venta.clienteNombre ?? 'Sin cliente',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if ((venta.clienteRif ?? '').isNotEmpty) ...[
                              Icon(
                                Icons.badge_rounded,
                                size: 11,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                venta.clienteRif!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$fechaStr · $hora',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${venta.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (venta.tasaBcv > 0)
                        Text(
                          'Bs. ${(venta.total * venta.tasaBcv).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // ── Badges inferiores ──
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _chip(
                    '${venta.esMultipago ? 'Multipago' : venta.metodoPago}',
                    color: const Color(0xFF3B82F6),
                    icon: venta.esMultipago
                        ? Icons.account_balance_wallet_rounded
                        : Icons.payments_rounded,
                  ),
                  if (venta.tieneDescuentoEspecial)
                    _chip(
                      'Desc. \$${venta.montoDescuentoTotal.toStringAsFixed(2)}',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.percent_rounded,
                    ),
                  if (venta.requiereAutorizacion)
                    _chip(
                      'Autorizado',
                      color: const Color(0xFFEF4444),
                      icon: Icons.verified_user_rounded,
                    ),
                  if ((venta.empleado).isNotEmpty)
                    _chip(
                      venta.empleado,
                      color: cs.onSurfaceVariant,
                      icon: Icons.person_outline_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, {required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
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
}