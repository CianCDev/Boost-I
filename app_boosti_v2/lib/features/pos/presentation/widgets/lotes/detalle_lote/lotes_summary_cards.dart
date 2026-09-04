// lib/features/pos/presentation/widgets/lotes/lotes_summary_cards.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class LotesSummaryCards extends StatelessWidget {
  final int pendientes;
  final int activos;
  final int proximosAVencer;
  final int historial;

  const LotesSummaryCards({
    super.key,
    required this.pendientes,
    required this.activos,
    required this.proximosAVencer,
    required this.historial,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: isMobile ? 8 : 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildCard(
            context,
            'Pendientes',
            pendientes,
            Colors.orange,
            Icons.hourglass_top_rounded,
            isDark,
            isMobile,
          ),
          _buildCard(
            context,
            'Activos',
            activos,
            Colors.green,
            Icons.check_circle_rounded,
            isDark,
            isMobile,
          ),
          _buildCard(
            context,
            'Vencen pronto',
            proximosAVencer,
            Colors.red,
            Icons.warning_amber_rounded,
            isDark,
            isMobile,
          ),
          _buildCard(
            context,
            'Historial',
            historial,
            Colors.grey,
            Icons.history_rounded,
            isDark,
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
    bool isDark,
    bool isMobile,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Calcular ancho responsivo
    double cardWidth;
    if (isMobile) {
      cardWidth = (screenWidth / 2) - 24;
    } else if (isTablet) {
      cardWidth = 160;
    } else {
      cardWidth = 180;
    }

    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: isMobile ? 16 : 20,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 18 : 22,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 11,
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}