import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';

class InventoryProductCard extends StatelessWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool isMobile;
  final bool isTablet;
  final int index;

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double fontSizeNombre = isMobile ? 12 : (isTablet ? 16 : 14);
    final double fontSizePrecio = isMobile ? 14 : (isTablet ? 18 : 16);
    final double fontSizeDetalle = isMobile ? 8 : (isTablet ? 11 : 10);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 30)),
      curve: Curves.easeOutCubic,
      child: _InventoryProductCardContent(
        producto: producto,
        stockBajo: stockBajo,
        onTap: onTap,
        onLongPress: onLongPress,
        isSelected: isSelected,
        isMobile: isMobile,
        isTablet: isTablet,
        fontSizeNombre: fontSizeNombre,
        fontSizePrecio: fontSizePrecio,
        fontSizeDetalle: fontSizeDetalle,
      ),
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child!),
    );
  }
}

class _InventoryProductCardContent extends StatelessWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool isMobile;
  final bool isTablet;
  final double fontSizeNombre;
  final double fontSizePrecio;
  final double fontSizeDetalle;

  const _InventoryProductCardContent({
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
    required this.isMobile,
    required this.isTablet,
    required this.fontSizeNombre,
    required this.fontSizePrecio,
    required this.fontSizeDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : (stockBajo
                    ? const Color(0xFFFCA5A5)
                    : (isTablet ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0))),
            width: isSelected ? 3 : (stockBajo ? 2 : (isTablet ? 2.5 : 1.5)),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: isTablet ? 0.08 : 0.05),
              blurRadius: isSelected ? 20 : (isTablet ? 16 : 12),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                                  errorBuilder: (_, _, __) =>
                                      Icon(Icons.inventory_2, size: 40, color: const Color(0xFF3B82F6)),
                                )
                              : Icon(Icons.inventory_2, size: 40, color: const Color(0xFF3B82F6)),
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeNombre,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Cód: ${producto.codigoBarras}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: fontSizeDetalle,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${producto.precioUnidad.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizePrecio,
                                color: const Color(0xFF059669),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stockBajo ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                              ),
                              child: Text(
                                'Stock: ${producto.stock}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: fontSizeDetalle,
                                  fontWeight: FontWeight.w600,
                                  color: stockBajo ? const Color(0xFFEF4444) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (producto.categoria.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Cat: ${producto.categoria}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: fontSizeDetalle,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (producto.proveedorNombre.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFC7D2FE), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.phone,
                                    size: isMobile ? 8 : (isTablet ? 12 : 16),
                                    color: const Color(0xFF4F46E5)),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    producto.proveedorNombre,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: fontSizeDetalle - 1,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected)
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
    );
  }
}