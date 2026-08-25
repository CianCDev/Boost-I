import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';

class ProductCard extends StatefulWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final bool isMobile;
  final int index;
  final AnimationController animationController;

  const ProductCard({
    super.key,
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    this.isMobile = false,
    required this.index,
    required this.animationController,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double stockValue = widget.producto.stock;
    final String stockDisplay = stockValue % 1 == 0
        ? stockValue.toInt().toString()
        : stockValue.toStringAsFixed(1);

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final start = 0.05 * widget.index;
        final end = start + 0.1;
        final double scale = Tween<double>(begin: 0.8, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: widget.animationController,
                curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic),
              ),
            )
            .value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isHovering = true);
          });
        },
        onExit: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isHovering = false);
          });
        },
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _isHovering
              ? Matrix4.diagonal3Values(1.03, 1.03, 1.0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.stockBajo
                  ? colorScheme.error.withValues(alpha: 0.4)
                  : (isDark
                      ? colorScheme.outline.withValues(alpha: 0.2)
                      : colorScheme.outline.withValues(alpha: 0.3)),
              width: widget.stockBajo ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovering
                    ? (isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.2))
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.12)),
                blurRadius: _isHovering ? 24 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- IMAGEN ----
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Center(
                          child: widget.producto.imagenUrl.isNotEmpty
                              ? Image.network(
                                  widget.producto.imagenUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, _, _) =>
                                      Icon(Icons.inventory_2, size: 40, color: colorScheme.primary),
                                )
                              : Icon(Icons.inventory_2, size: 40, color: colorScheme.primary),
                        ),
                        // Badge STOCK BAJO
                        if (widget.stockBajo)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                              ),
                              child: Text(
                                '¡STOCK BAJO!',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : (isTablet ? 16 : 14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // Badge tipo de producto
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.producto.esPesado ? Icons.monitor_weight : Icons.inventory_2,
                                  size: isMobile ? 14 : (isTablet ? 18 : 16),
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.producto.esPesado ? 'Balanza' : 'Unidad',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : (isTablet ? 14 : 13),
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ---- INFORMACIÓN ----
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 10.0 : 14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 13 : (isTablet ? 16 : 14),
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Cód: ${widget.producto.codigoBarras}',
                          style: TextStyle(
                            fontSize: isMobile ? 9 : (isTablet ? 11 : 10),
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isMobile ? 15 : (isTablet ? 20 : 17),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 60),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.stockBajo
                                      ? colorScheme.error
                                      : colorScheme.outline.withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'Stock: $stockDisplay',
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : (isTablet ? 13 : 11),
                                  fontWeight: FontWeight.w600,
                                  color: widget.stockBajo
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}