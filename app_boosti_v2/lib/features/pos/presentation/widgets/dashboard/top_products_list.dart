import 'package:flutter/material.dart';

class TopProductsList extends StatelessWidget {
  final List<Map<String, dynamic>> productos;

  const TopProductsList({super.key, required this.productos});

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
            Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 20, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Productos más vendidos',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (productos.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Aún no hay productos vendidos',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ] else ...[
              for (int i = 0; i < mostrar.length; i++) ...[
                _buildItem(mostrar[i], i, isMobile, isDark),
                if (i < mostrar.length - 1) const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item, int index, bool isMobile, bool isDark) {
    final cantidad = (item['cantidad'] as double).toStringAsFixed(0);
    final colorRanking = index == 0
        ? Colors.amber.shade600
        : index == 1
            ? Colors.grey.shade600
            : index == 2
                ? Colors.brown.shade400
                : Colors.purple.shade300;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(20 * (1 - opacity), 0),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorRanking.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorRanking.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorRanking,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item['nombre'] ?? '',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.shade200,
                width: 0.5,
              ),
            ),
            child: Text(
              '$cantidad uds',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}