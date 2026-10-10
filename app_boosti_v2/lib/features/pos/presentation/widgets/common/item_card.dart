// lib/features/pos/presentation/widgets/common/item_card.dart
import 'package:flutter/material.dart';

import 'glass_card.dart';
import 'quantity_control.dart';

/// Línea de producto reutilizable (comanda, KDS, carrito).
///
/// Sin lógica de negocio: no toca Riverpod, ni Isar, ni calcula precios. Todo
/// llega ya calculado por los parámetros. La idea es que `ComandaScreen`
/// (PASO C) y el KDS (PASO E) monten la misma estructura visual y solo
/// cambien lo que le pasan.
///
/// Layout normal:
///
/// ```text
/// ┌──────────────────────────────────────────┐
/// │ [img]  Nombre producto           $1.20  │
/// │  56px  1 × $1.20                         │
/// │                                          │
/// │        [badge de estado]                 │
/// │        [nota]                            │
/// │                                          │
/// │        [cantidad]              [acciones]│
/// └──────────────────────────────────────────┘
/// ```
///
/// Compact = thumbnail 40 px y sin precio suelto (el precio va dentro de
/// [detalle]), pensado para listas largas como la cola del KDS.
class ItemCard extends StatelessWidget {
  final Widget? thumbnail;
  final String nombre;

  /// Texto secundario bajo el nombre: "1 × $1.20", "2 kg × $8.00".
  final String? detalle;

  /// Precio alineado a la derecha. Vacío si [compact].
  final String precio;

  /// `TimeBadge`, `StatusBadge` o lo que sea.
  final Widget? badgeEstado;

  /// `StickyNote` ya construida. Null = sin nota.
  final Widget? nota;

  final QuantityControl? cantidad;

  /// Pinta el borde lateral en ese color. Null = borde por defecto.
  final Color? colorBorde;

  /// Acciones a la derecha (botones de estado, kebab, etc.).
  final Widget? trailing;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final bool compact;

  const ItemCard({
    super.key,
    required this.nombre,
    this.thumbnail,
    this.detalle,
    this.precio = '',
    this.badgeEstado,
    this.nota,
    this.cantidad,
    this.colorBorde,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final separaciones = compact ? 6.0 : 10.0;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(separaciones),
      onTap: onTap,
      onLongPress: onLongPress,
      showStatusBar: colorBorde != null,
      statusColor: colorBorde ?? const Color(0xFF10B981),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Fila principal: imagen + nombre + precio ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbnail != null) ...[
                thumbnail!,
                SizedBox(width: separaciones),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nombre,
                      style: TextStyle(
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (detalle != null && detalle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detalle!,
                        style: TextStyle(
                          fontSize: compact ? 11 : 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!compact && precio.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  precio,
                  style: TextStyle(
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),

          // ── Badge y nota ──
          if (badgeEstado != null || nota != null) ...[
            SizedBox(height: separaciones),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (badgeEstado != null) badgeEstado!,
                if (nota != null) nota!,
              ],
            ),
          ],

          // ── Cantidad y acciones ──
          if (cantidad != null || trailing != null) ...[
            SizedBox(height: separaciones),
            Row(
              children: [
                if (cantidad != null) cantidad!,
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ],
        ],
      ),
    );
  }
}
