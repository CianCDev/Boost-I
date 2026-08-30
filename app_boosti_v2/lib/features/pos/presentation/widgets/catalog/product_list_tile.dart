// lib/features/pos/presentation/widgets/catalog/product_list_tile.dart
import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';

class ProductListTile extends StatefulWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final int index;

  const ProductListTile({
    super.key,
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final imageSize = isMobile ? 50.0 : 70.0;

    final cardBackground = isDark ? cardDark : cardLight;
    final borderColor = widget.stockBajo
        ? pumpkinSpice.withValues(alpha: 0.5)
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1));
    final borderWidth = widget.stockBajo ? 2.0 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
            : Matrix4.identity(),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? (widget.stockBajo ? pumpkinSpice : primaryGreen.withValues(alpha: 0.5))
                : borderColor,
            width: _isHovered ? 2.0 : borderWidth,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : primaryGreen.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : primaryGreen.withValues(alpha: 0.1),
          highlightColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : primaryGreen.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Imagen
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.producto.imagenUrl != null &&
                            widget.producto.imagenUrl!.isNotEmpty
                        ? Image.network(
                            widget.producto.imagenUrl!,
                            fit: BoxFit.cover,
                            width: imageSize,
                            height: imageSize,
                            errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.inventory_2,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                          )
                        : Icon(
                            Icons.inventory_2,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.producto.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                          color: isDark ? Colors.white : textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Cód: ${widget.producto.codigoBarras}',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              color: isDark ? Colors.white60 : textMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Icon(
                                widget.producto.esPesado
                                    ? Icons.monitor_weight
                                    : Icons.inventory_2,
                                size: 12,
                                color: isDark ? Colors.white60 : textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.producto.esPesado ? 'Balanza' : 'Unidad',
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 12,
                                  color: isDark ? Colors.white60 : textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 15 : 17,
                              color: primaryGreen,
                            ),
                          ),
                          if (widget.stockBajo)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: pumpkinSpice,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Stock bajo',
                                style: TextStyle(
                                  fontSize: isMobile ? 9 : 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Stock: ${widget.producto.stock.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white60 : textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Flecha indicadora
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : textMuted,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}