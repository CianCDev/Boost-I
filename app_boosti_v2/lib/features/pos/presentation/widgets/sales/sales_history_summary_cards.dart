import 'package:flutter/material.dart';

class SalesHistorySummaryCards extends StatelessWidget {
  final int ventasCount;
  final double totalUSD;
  final double totalBs;
  final bool isMobile;
  final bool isTablet;

  const SalesHistorySummaryCards({
    super.key,
    required this.ventasCount,
    required this.totalUSD,
    required this.totalBs,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Colores más amigables
    final colorVentas = const Color(0xFF4A90D9); // Azul suave
    final colorUSD = const Color(0xFF2ECC71);   // Verde menta
    final colorBs = const Color.fromARGB(255, 198, 99, 255);    // Naranja cálido

    final cards = [
      _SummaryCard(
        icon: Icons.receipt_long_rounded,
        label: 'Ventas',
        value: '$ventasCount',
        color: colorVentas,
        isMobile: isMobile,
        isTablet: isTablet,
        screenWidth: screenWidth,
        onTap: () => _showDetailDialog(context, 'Ventas', '$ventasCount', colorVentas),
      ),
      _SummaryCard(
        icon: Icons.attach_money_rounded,
        label: 'Total USD',
        value: '\$${totalUSD.toStringAsFixed(2)}',
        color: colorUSD,
        isMobile: isMobile,
        isTablet: isTablet,
        screenWidth: screenWidth,
        onTap: () => _showDetailDialog(context, 'Total USD', '\$${totalUSD.toStringAsFixed(2)}', colorUSD),
      ),
      _SummaryCard(
        icon: Icons.monetization_on_rounded,
        label: 'Total Bs.',
        value: 'Bs. ${totalBs.toStringAsFixed(2)}',
        color: colorBs,
        isMobile: isMobile,
        isTablet: isTablet,
        screenWidth: screenWidth,
        onTap: () => _showDetailDialog(context, 'Total Bs.', 'Bs. ${totalBs.toStringAsFixed(2)}', colorBs),
      ),
    ];

    return Wrap(
      spacing: isMobile ? 8 : 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: cards,
    );
  }

  void _showDetailDialog(BuildContext context, String label, String value, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        title: Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: color.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMobile;
  final bool isTablet;
  final double screenWidth;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isMobile,
    required this.isTablet,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calcular ancho máximo según dispositivo
    double maxWidth;
    if (isMobile) {
      maxWidth = screenWidth * 0.45; // Ocupa ~45% del ancho en móvil
    } else if (isTablet) {
      maxWidth = 180;
    } else {
      maxWidth = 200;
    }

    // Asegurar un mínimo
    final minWidth = isMobile ? 80.0 : 100.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 20,
          vertical: isMobile ? 10 : 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : (isMobile ? 10 : 12),
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : (isMobile ? 14 : 18),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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