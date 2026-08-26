import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/themes/app_colors.dart';

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
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Colores según el modo
    final cardBackground = isDark ? cardDark : cardLight; // #334155 o #FFFFFF
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color.fromARGB(255, 190, 195, 201); // Borde más visible en claro
    final List<BoxShadow> cardShadow = isDark
        ? []
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ];

    final double stockValue = widget.producto.stock;
    final String stockDisplay = stockValue % 1 == 0
        ? stockValue.toInt().toString()
        : stockValue.toStringAsFixed(1);

    // Layout: en móvil columna (imagen arriba), en tablet/desktop fila (imagen izquierda)
    final bool useRowLayout = !isMobile && (isTablet || !isMobile);

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
              ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.stockBajo
                  ? pumpkinSpice.withValues(alpha: 0.5)
                  : cardBorderColor,
              width: widget.stockBajo ? 2.0 : 1.0,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : cardShadow,
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: useRowLayout
                ? _buildRowLayout(colorScheme, isDark, isTablet, isMobile, stockDisplay)
                : _buildColumnLayout(colorScheme, isDark, isTablet, isMobile, stockDisplay),
          ),
        ),
      ),
    );
  }

  // Layout en fila (imagen izquierda, info derecha) para tablet/desktop
  Widget _buildRowLayout(ColorScheme colorScheme, bool isDark, bool isTablet, bool isMobile, String stockDisplay) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Center(
                    child: widget.producto.imagenUrl.isNotEmpty
                        ? Image.network(
                            widget.producto.imagenUrl,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (_, _, _) =>
                                Icon(Icons.inventory_2, size: 32, color: colorScheme.primary),
                          )
                        : Icon(Icons.inventory_2, size: 32, color: colorScheme.primary),
                  ),
                  if (widget.stockBajo)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: pumpkinSpice,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '¡Stock bajo!',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 14,
                    color: isDark ? Colors.white : textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cód: ${widget.producto.codigoBarras}',
                  style: TextStyle(
                    fontSize: 10,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      widget.producto.esPesado ? Icons.monitor_weight : Icons.inventory_2,
                      size: 12,
                      color: textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.producto.esPesado ? 'Balanza' : 'Unidad',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
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
                        fontSize: isTablet ? 20 : 17,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.stockBajo
                              ? pumpkinSpice
                              : textMuted.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_rounded, size: 10, color: textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: $stockDisplay',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.stockBajo ? pumpkinSpice : textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout en columna (imagen arriba, info abajo) para móvil
  Widget _buildColumnLayout(ColorScheme colorScheme, bool isDark, bool isTablet, bool isMobile, String stockDisplay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                if (widget.stockBajo)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: pumpkinSpice,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Stock bajo',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.producto.esPesado ? Icons.monitor_weight : Icons.inventory_2,
                          size: 12,
                          color: primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.producto.esPesado ? 'Balanza' : 'Unidad',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : textDark,
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
        // Información
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 10.0 : 12.0),
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
                    color: isDark ? Colors.white : textDark,
                  ),
                ),
                Text(
                  'Cód: ${widget.producto.codigoBarras}',
                  style: TextStyle(
                    fontSize: isMobile ? 9 : (isTablet ? 11 : 10),
                    color: textMuted,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : (isTablet ? 20 : 18),
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.stockBajo
                              ? pumpkinSpice
                              : textMuted.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_rounded, size: 10, color: textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: $stockDisplay',
                            style: TextStyle(
                              fontSize: isMobile ? 9 : (isTablet ? 12 : 10),
                              fontWeight: FontWeight.w600,
                              color: widget.stockBajo ? pumpkinSpice : textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}