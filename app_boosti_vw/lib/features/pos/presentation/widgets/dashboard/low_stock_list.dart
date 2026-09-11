import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';

/// Lista compacta de productos con stock crítico.
class LowStockList extends StatelessWidget {
  final List<ProductoEntity> productos;
  final VoidCallback? onVerInventario;
  final void Function(ProductoEntity producto)? onReponer;

  const LowStockList({
    super.key,
    required this.productos,
    this.onVerInventario,
    this.onReponer,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mostrar = productos.take(isMobile ? 3 : 5).toList();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 20, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Stock crítico',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ),
                if (onVerInventario != null)
                  TextButton(
                    onPressed: onVerInventario,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Ver inventario',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista
            if (productos.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 18, color: Colors.green.shade500),
                      const SizedBox(width: 8),
                      Text(
                        '✅ Todos los productos tienen stock suficiente',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              for (int i = 0; i < mostrar.length; i++) ...[
                _buildItem(mostrar[i], i, isMobile, isDark),
                if (i < mostrar.length - 1) const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ProductoEntity producto, int index, bool isMobile, bool isDark) {
    final porcentaje = producto.stock / producto.stockMinimo;
    final colorBar = porcentaje < 0.3
        ? Colors.red.shade600
        : porcentaje < 0.6
            ? Colors.orange.shade600
            : Colors.amber.shade600;

    final cantidadColor = Colors.red.shade400;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorBar,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: porcentaje.clamp(0.0, 1.0),
                      backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      color: colorBar,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '${producto.stock.toStringAsFixed(0)}/${producto.stockMinimo.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: cantidadColor,
                  ),
                ),
                const SizedBox(width: 8),
                if (onReponer != null)
                  IconButton(
                    onPressed: () => onReponer!(producto),
                    icon: Icon(
                      Icons.add_shopping_cart_rounded,
                      size: isMobile ? 18 : 22,
                      color: Colors.orange.shade400,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    tooltip: 'Reponer producto',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}