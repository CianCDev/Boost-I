import 'package:flutter/material.dart';

class SalesHistorySummaryCards extends StatelessWidget {
  final int ventasCount;
  final double totalUSD;
  final double totalBs;
  final bool isMobile;
  final bool isTablet;
  final double spacingWrap;
  final double fontSizeResumen;
  final double fontSizeResumenValor;

  const SalesHistorySummaryCards({
    super.key,
    required this.ventasCount,
    required this.totalUSD,
    required this.totalBs,
    required this.isMobile,
    required this.isTablet,
    required this.spacingWrap,
    required this.fontSizeResumen,
    required this.fontSizeResumenValor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ancho fijo en tablet/PC para que no se estiren demasiado
    final double cardWidth = isTablet ? 240 : (isMobile ? double.infinity : 200);

    return Wrap(
      spacing: spacingWrap,
      runSpacing: spacingWrap,
      alignment: WrapAlignment.start,
      children: [
        _buildCard(
          'Ventas',
          '$ventasCount',
          Icons.receipt_long,
          const Color(0xFF3B82F6),
          colorScheme,
          isDark,
          cardWidth,
        ),
        _buildCard(
          'Total USD',
          '\$${totalUSD.toStringAsFixed(2)}',
          Icons.attach_money,
          const Color(0xFF10B981),
          colorScheme,
          isDark,
          cardWidth,
        ),
        _buildCard(
          'Total Bs.',
          'Bs. ${totalBs.toStringAsFixed(2)}',
          Icons.currency_exchange,
          const Color(0xFF0284C7),
          colorScheme,
          isDark,
          cardWidth,
        ),
      ],
    );
  }

  Widget _buildCard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
    ColorScheme colorScheme,
    bool isDark,
    double width,
  ) {
    final double iconSize = isTablet ? 32 : 24;
    final double fontSizeTitle = isTablet ? 16 : 12;
    final double fontSizeValue = isTablet ? 28 : 20;
    final double spacing = 12;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: iconSize),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: fontSizeTitle,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: fontSizeValue,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
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
    );
  }
}