import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/marca_provider.dart';
import '../../providers/themes/app_colors.dart'; 
import '../../utils/responsive_helper.dart';

class InventoryProductCard extends ConsumerStatefulWidget {
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
  ConsumerState<InventoryProductCard> createState() => _InventoryProductCardState();
}

class _InventoryProductCardState extends ConsumerState<InventoryProductCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context);

    // ✅ Obtener el nombre de la marca usando el provider
    final marcaNombreAsync = widget.producto.marcaSupabaseId != null
        ? ref.watch(marcaNombrePorSupabaseIdProvider(widget.producto.marcaSupabaseId!))
        : null;

    // Colores responsivos (igual que antes)
    final cardBackground = isDark ? cardDark : cardLight;
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
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

    final double fontSizeNombre = widget.isMobile ? 13 : (isTablet ? 18 : 20);
    final double fontSizeMarca = widget.isMobile ? 11 : (isTablet ? 15 : 16);
    final double fontSizeCodigo = widget.isMobile ? 10 : (isTablet ? 14 : 15);
    final double fontSizePrecio = widget.isMobile ? 16 : (isTablet ? 22 : 24);
    final double fontSizeStock = widget.isMobile ? 10 : (isTablet ? 14 : 16);
    final double badgeFontSize = widget.isMobile ? 10 : (isTablet ? 14 : 16);
    final double badgePadding = widget.isMobile ? 4 : (isTablet ? 8 : 10);
    final double typeBadgeFontSize = widget.isMobile ? 9 : (isTablet ? 13 : 14);
    final double typeBadgePadding = widget.isMobile ? 4 : (isTablet ? 8 : 10);

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
            ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.stockBajo
                ? pumpkinSpice.withValues(alpha: 0.5)
                : cardBorderColor,
            width: widget.stockBajo ? 1.5 : 1.0,
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
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- SECCIÓN SUPERIOR: IMAGEN Y BADGES (55%) -----
              Expanded(
                flex: 55,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.producto.imagenUrl != null &&
                                  widget.producto.imagenUrl!.isNotEmpty
                              ? Image.network(
                                  widget.producto.imagenUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.inventory_2,
                                    size: 40,
                                    color: colorScheme.outline,
                                  ),
                                )
                              : Icon(
                                  Icons.inventory_2,
                                  size: 40,
                                  color: colorScheme.outline,
                                ),
                        ),
                      ),
                    ),
                    if (widget.stockBajo)
                      Positioned(
                        top: widget.isMobile ? 8 : 10,
                        left: widget.isMobile ? 8 : 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: badgePadding,
                            vertical: badgePadding * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: pumpkinSpice,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.producto.stock <= 0 ? 'Sin Stock' : '¡Stock bajo!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: widget.isMobile ? 8 : 10,
                      right: widget.isMobile ? 8 : 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: typeBadgePadding,
                          vertical: typeBadgePadding * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.75)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.producto.esPesado
                                  ? Icons.monitor_weight
                                  : Icons.inventory_2,
                              size: typeBadgeFontSize + 2,
                              color: primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.producto.esPesado ? 'Balanza' : 'Unidad',
                              style: TextStyle(
                                fontSize: typeBadgeFontSize,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : textDark,
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
                            color: pumpkinSpice,
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
              Container(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              // ----- SECCIÓN INFERIOR: INFORMACIÓN (45%) -----
              Expanded(
                flex: 45,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.producto.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizeNombre,
                          color: isDark ? Colors.white : textDark,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // ✅ Marca
                      if (marcaNombreAsync != null)
                        marcaNombreAsync.when(
                          data: (nombre) => nombre != null
                              ? Text(
                                  'Marca: $nombre',
                                  style: TextStyle(
                                    fontSize: fontSizeMarca,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            height: 16,
                            child: Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        'Cód: ${widget.producto.codigoBarras}',
                        style: TextStyle(
                          fontSize: fontSizeCodigo,
                          color: isDark ? Colors.white60 : textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizePrecio,
                              color: primaryGreen,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isMobile ? 6 : 10,
                              vertical: widget.isMobile ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                              border: widget.stockBajo
                                  ? Border.all(
                                      color: pumpkinSpice.withValues(alpha: 0.3),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              'Stock: $stockDisplay',
                              style: TextStyle(
                                fontSize: fontSizeStock,
                                fontWeight: FontWeight.w600,
                                color: widget.stockBajo
                                    ? pumpkinSpice
                                    : (isDark ? Colors.white70 : textDark),
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