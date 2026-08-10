import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';

class ProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final start = 0.05 * index;
        final end = start + 0.1;
        final double scale = Tween<double>(begin: 0.8, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: animationController,
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
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: stockBajo
                    ? const Color(0xFFFCA5A5)
                    : (isTablet ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
                width: stockBajo ? 2 : (isTablet ? 2.5 : 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isTablet ? 0.08 : 0.04),
                  blurRadius: isTablet ? 16 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGEN (flex 5)
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Center(
                          child: producto.imagenUrl.isNotEmpty
                              ? Image.network(
                                  producto.imagenUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.inventory_2, size: 40, color: Color(0xFF3B82F6)),
                                )
                              : const Icon(Icons.inventory_2, size: 40, color: Color(0xFF3B82F6)),
                        ),
                        if (stockBajo)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '¡STOCK BAJO!',
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              producto.esPesado ? 'Balanza' : 'Unidad',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // INFORMACIÓN (flex 4)
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : (isTablet ? 16 : 14),
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Cód: ${producto.codigoBarras}',
                          style: TextStyle(
                            fontSize: isMobile ? 8 : (isTablet ? 11 : 10),
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${producto.precioUnidad.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : (isTablet ? 18 : 16),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stockBajo ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                              ),
                              child: Text(
                                'Stock: ${producto.stock}',
                                style: TextStyle(
                                  fontSize: isMobile ? 8 : (isTablet ? 11 : 10),
                                  fontWeight: FontWeight.w600,
                                  color: stockBajo ? const Color(0xFFEF4444) : const Color(0xFF475569),
                                ),
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