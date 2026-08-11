import 'package:flutter/material.dart';
import '../../../data/Local/entities/producto_entity.dart';

class LowStockList extends StatelessWidget {
  final List<ProductoEntity> productos;

  const LowStockList({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final mostrar = productos.take(isMobile ? 3 : 5).toList();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Stock crítico',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (productos.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: Colors.green.shade500),
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
                _buildItem(mostrar[i], i, isMobile),
                if (i < mostrar.length - 1) const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ProductoEntity producto, int index, bool isMobile) {
    final porcentaje = producto.stock / producto.stockMinimo;
    final colorBar = porcentaje < 0.3
        ? Colors.red.shade600
        : porcentaje < 0.6
            ? Colors.orange.shade600
            : Colors.amber.shade600;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle_rounded, size: 8, color: colorBar),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  producto.nombre,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                '${producto.stock.toStringAsFixed(0)} / ${producto.stockMinimo.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  color: colorBar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade100,
              color: colorBar,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}