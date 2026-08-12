import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';

class InventoryProductCard extends StatefulWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool isMobile;
  final bool isTablet;
  final int index;
  final AnimationController? animationController;

  const InventoryProductCard({
    super.key,
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
    required this.isMobile,
    required this.isTablet,
    required this.index,
    this.animationController,
  });

  @override
  State<InventoryProductCard> createState() => _InventoryProductCardState();
}

class _InventoryProductCardState extends State<InventoryProductCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double stockValue = widget.producto.stock ?? 0.0;
    final String stockDisplay = stockValue % 1 == 0
        ? stockValue.toInt().toString()
        : stockValue.toStringAsFixed(1);

    // ✅ Tamaños adaptativos (más grandes en tablet/PC)
    final double paddingHorizontal = isTablet ? 16.0 : (isMobile ? 10.0 : 14.0);
    final double paddingVertical = isTablet ? 14.0 : (isMobile ? 10.0 : 12.0);

    final double fontSizeNombre = isTablet ? 18 : (isMobile ? 13 : 16);
    final double fontSizeCodigo = isTablet ? 13 : (isMobile ? 9 : 11);
    final double fontSizePrecio = isTablet ? 24 : (isMobile ? 15 : 18);
    final double fontSizeStock = isTablet ? 15 : (isMobile ? 10 : 12);
    final double fontSizeCategoria = isTablet ? 14 : (isMobile ? 9 : 11);
    final double fontSizeProveedor = isTablet ? 13 : (isMobile ? 8 : 10);

    final double iconSizeProveedor = isTablet ? 18 : (isMobile ? 8 : 14);

    Widget child = MouseRegion(
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
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- IMAGEN (sin cambios) ----
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
                      if (widget.isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B5CF6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // ---- INFORMACIÓN MEJORADA ----
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y código en una fila
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Text(
                              widget.producto.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeNombre,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Text(
                              'Cód: ${widget.producto.codigoBarras}',
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: fontSizeCodigo,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Precio y stock (con stock más visible)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: fontSizePrecio,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 70),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12 : 8,
                              vertical: isTablet ? 4 : 2,
                            ),
                            decoration: BoxDecoration(
                              // ✅ Fondo sutil para destacar el stock
                              color: widget.stockBajo
                                  ? colorScheme.error.withValues(alpha: 0.12)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.stockBajo
                                    ? colorScheme.error
                                    : colorScheme.outline.withValues(alpha: 0.3),
                                width: widget.stockBajo ? 1.5 : 1.0,
                              ),
                            ),
                            child: Text(
                              'Stock: $stockDisplay',
                              style: TextStyle(
                                fontSize: fontSizeStock,
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
                      // Categoría (con badge más estilizado)
                      if (widget.producto.categoria.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 6,
                            vertical: isTablet ? 4 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            widget.producto.categoria,
                            style: TextStyle(
                              fontSize: fontSizeCategoria,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      // Proveedor (con icono más grande y mejor espaciado)
                      if (widget.producto.proveedorNombre.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: iconSizeProveedor,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.producto.proveedorNombre,
                                style: TextStyle(
                                  fontSize: fontSizeProveedor,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.animationController != null) {
      return AnimatedBuilder(
        animation: widget.animationController!,
        builder: (context, _) {
          final start = 0.05 * widget.index;
          final end = start + 0.1;
          final double scale = Tween<double>(begin: 0.8, end: 1.0)
              .animate(
                CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic),
                ),
              )
              .value;
          return Transform.scale(scale: scale, child: child);
        },
      );
    }

    return child;
  }
}