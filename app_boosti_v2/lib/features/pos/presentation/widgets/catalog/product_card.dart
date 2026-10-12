import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/lotes_provider.dart';
import '../../providers/marca_provider.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/expiry_style.dart';
import '../../utils/expiry_utils.dart';
import '../../utils/responsive_helper.dart';

class ProductCard extends ConsumerStatefulWidget {
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
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context);

    // Estilo igual que InventoryProductCard
    final Color cardBackground = isDark ? cardDark : Colors.white;

    final Color cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.1);

    final List<BoxShadow> cardShadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
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

    final double fontSizeNombre = widget.isMobile ? 13 : (isTablet ? 15 : 16);
    final double fontSizeMarca = widget.isMobile ? 11 : (isTablet ? 13 : 14);
    final double fontSizeCodigo = widget.isMobile ? 10 : (isTablet ? 12 : 13);
    final double fontSizePrecio = widget.isMobile ? 16 : (isTablet ? 18 : 20);
    final double fontSizeStock = widget.isMobile ? 10 : (isTablet ? 12 : 13);
    final double badgeFontSize = widget.isMobile ? 10 : (isTablet ? 12 : 13);
    final double badgePadding = widget.isMobile ? 4 : (isTablet ? 6 : 8);
    final double typeBadgeFontSize = widget.isMobile ? 9 : (isTablet ? 11 : 12);
    final double typeBadgePadding = widget.isMobile ? 4 : (isTablet ? 6 : 8);

    // ✅ Nombre de la marca.
    //
    // Antes: `ref.watch(marcaNombrePorSupabaseIdProvider(...))`, una query
    // a Isar POR CARD (~200 round-trips al abrir la grilla, cada una con su
    // transición loading→data). Ahora es un único Map leído una vez y
    // lookup O(1), sin rebuilds por card.
    final marcaNombres =
        ref.watch(marcaNombresPorSupabaseIdProvider).valueOrNull ??
            const <String, String>{};
    final marcaNombre = widget.producto.marcaSupabaseId != null
        ? marcaNombres[widget.producto.marcaSupabaseId!]
        : null;

    // ✅ Vencimiento más próximo del producto (derivado de los lotes).
    // En móvil, cuando el stock ya está marcado, el label se acorta para
    // que los dos badges no se solapen: "¡Stock bajo!" mide ~70px y la
    // card ronda los 150px.
    final vencimientos = ref.watch(vencimientosProvider);
    final fechaVenc = vencimientos[widget.producto.id];
    final diasVenc =
        fechaVenc == null ? null : ExpiryUtils.diasRestantes(fechaVenc);

    // ⚠️ `clasificar` decide SI se muestra (null = >15 días, no badge).
    // `diasVenc` es el valor crudo que el chip usa para el texto y los
    // colores. Los dos van juntos: uno decide visibilidad, el otro contenido.
    final expiryInfo = ExpiryUtils.clasificar(fechaVenc);

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
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          // ✅ Solo llamamos a setState una vez
          setState(() => _isHovering = true);
        },
        onExit: (event) {
          // ✅ También usamos 'event' para evitar conflicto con el '_'
          setState(() => _isHovering = false);
        },
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
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----- SECCIÓN SUPERIOR (55%) -----
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
                                    // ✅ Nombres descriptivos para evitar '_'
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
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
                      // Badge de Stock (superior izquierda)
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
                              widget.producto.stock <= 0
                                  ? 'Sin Stock'
                                  : '¡Stock bajo!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: badgeFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Badge de vencimiento (superior derecha).
                      // Simetrico al de stock, que esta arriba-izquierda.
                      // Va en el Stack de la imagen y no en la seccion de
                      // datos porque esa region es Expanded(flex: 45) y ya
                      // tiene 4 elementos: sumar un chip ahi le roba
                      // altura al nombre, que hoy tiene maxLines: 2.
                      if (expiryInfo != null && diasVenc != null)
                        Positioned(
                          top: widget.isMobile ? 8 : 10,
                          right: widget.isMobile ? 8 : 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  expiryFondo(diasVenc).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 11, color: expiryTexto(diasVenc)),
                                const SizedBox(width: 4),
                                // `FittedBox` porque en móvil la card
                                // ronda los 150px y con "¡Stock bajo!"
                                // al lado el "Vencido" (7 chars) se
                                // cortaba. Escala en vez de desbordar.
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      expiryLabel(diasVenc),
                                      style: TextStyle(
                                        color: expiryTexto(diasVenc),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Badge de tipo (inferior derecha)
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
                    ],
                  ),
                ),

                // ----- LÍNEA SUTIL -----
                Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),

                // ----- SECCIÓN INFERIOR (45%) -----
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nombre
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
                        // Marca
                        if (marcaNombre != null)
                          Text(
                            'Marca: $marcaNombre',
                            style: TextStyle(
                              fontSize: fontSizeMarca,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const SizedBox.shrink(),
                        // Código
                        Text(
                          'Cód: ${widget.producto.codigoBarras}',
                          style: TextStyle(
                            fontSize: fontSizeCodigo,
                            color: isDark ? Colors.white60 : textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Fila inferior: Precio y stock
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
                                        color:
                                            pumpkinSpice.withValues(alpha: 0.3),
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
      ),
    );
  }

  // Los helpers del badge (`expiryFondo` / `expiryTexto` / `expiryLabel`)
  // viven en `utils/expiry_style.dart`, compartidos con
  // `product_list_tile.dart`. Ver ese archivo.
}
