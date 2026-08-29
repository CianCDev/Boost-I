import 'package:flutter/material.dart';

class GastosSummaryCards extends StatelessWidget {
  final int gastosCount;
  final double totalUSD;
  final double totalBs;
  final bool isMobile;
  final bool isTablet;
  final double spacingWrap;
  final double fontSizeResumen;
  final double fontSizeResumenValor;

  const GastosSummaryCards({
    super.key,
    required this.gastosCount,
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

    final double cardMinWidth = isTablet ? 200 : 150;

    return Wrap(
      spacing: spacingWrap,
      runSpacing: spacingWrap,
      alignment: WrapAlignment.center,
      children: [
        _buildCard(
          'Gastos',
          '$gastosCount',
          Icons.money_off_rounded,
          const Color(0xFFEF4444),
          colorScheme,
          isDark,
          cardMinWidth,
        ),
        _buildCard(
          'Total USD',
          '\$${totalUSD.toStringAsFixed(2)}',
          Icons.attach_money,
          const Color(0xFFEF4444),
          colorScheme,
          isDark,
          cardMinWidth,
        ),
        _buildCard(
          'Total Bs.',
          'Bs. ${totalBs.toStringAsFixed(2)}',
          Icons.currency_exchange,
          const Color(0xFFEF4444),
          colorScheme,
          isDark,
          cardMinWidth,
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
    double minWidth,
  ) {
    final double iconSize = isTablet ? 28 : 20;
    final double fontSizeTitle = isTablet ? 14 : 11;
    final double fontSizeValue = isTablet ? 24 : 17;
    final double padding = isTablet ? 16 : 10;

    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: EdgeInsets.all(padding),
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
          const SizedBox(width: 10),
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
    );
  }
}