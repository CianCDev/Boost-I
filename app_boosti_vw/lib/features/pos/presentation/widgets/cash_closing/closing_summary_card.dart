// lib/features/pos/presentation/widgets/cash_closing/closing_summary_card.dart
import 'package:flutter/material.dart';

class ClosingSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final List<double> sparklineData;
  final bool isMobile;
  final bool isTablet;

  const ClosingSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.sparklineData,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 12 : 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.transparent,
      shadowColor: color.withValues(alpha: 0.25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Glassmorphism
          color: Color(0xFF1A2235).withValues(alpha: 0.85),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Sparkline en el fondo
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                height: 60,
                child: CustomPaint(
                  painter: SparklinePainter(
                    data: sparklineData,
                    color: color.withValues(alpha: 0.15),
                    lineWidth: 2.0,
                  ),
                ),
              ),
              // Contenido
              Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: isMobile ? 20 : 28),
                        ),
                        const Spacer(),
                        // Indicador de tendencia (solo si hay datos)
                        if (sparklineData.length >= 2) ...[
                          _buildTrendIndicator(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 28,
                        fontWeight: FontWeight.w800,
                        color: color,
                        shadows: [
                          Shadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final first = sparklineData.first;
    final last = sparklineData.last;
    final isUp = last >= first;
    final percent = first != 0 ? ((last - first) / first) * 100 : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isUp ? Colors.green : Colors.red).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isUp ? Colors.green : Colors.red,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            '${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isUp ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SPARKLINE PAINTER
// ============================================================
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double lineWidth;

  const SparklinePainter({
    required this.data,
    required this.color,
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * size.width;
      final double y = size.height - ((data[i] - minVal) / range) * size.height * 0.8 - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}