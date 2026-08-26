// lib/features/pos/presentation/widgets/catalog/product_list_tile.dart
import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';

class ProductListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final imageSize = isMobile ? 50.0 : 70.0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 30)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? deepSpaceBlue : seashell,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stockBajo
              ? pumpkinSpice.withValues(alpha: 0.3)
              : (isDark ? slateGrey.withValues(alpha: 0.2) : slateGrey.withValues(alpha: 0.15)),
          width: stockBajo ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                  child: producto.imagenUrl.isNotEmpty
                      ? Image.network(
                          producto.imagenUrl,
                          fit: BoxFit.cover,
                          width: imageSize,
                          height: imageSize,
                          errorBuilder: (_, _, _) => Icon(
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
                      producto.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: isDark ? brightSnow : deepSpaceBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Cód: ${producto.codigoBarras}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: slateGrey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            Icon(
                              producto.esPesado ? Icons.monitor_weight : Icons.inventory_2,
                              size: 12,
                              color: slateGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              producto.esPesado ? 'Balanza' : 'Unidad',
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 12,
                                color: slateGrey,
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
                          '\$${producto.precioUnidad.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 15 : 17,
                            color: mintLeaf,
                          ),
                        ),
                        if (stockBajo)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: pumpkinSpice,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Stock bajo',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Text(
                            'Stock: ${producto.stock.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 13,
                              fontWeight: FontWeight.w500,
                              color: slateGrey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botón agregar (opcional, se puede usar el tap general)
              Icon(
                Icons.chevron_right_rounded,
                color: slateGrey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}