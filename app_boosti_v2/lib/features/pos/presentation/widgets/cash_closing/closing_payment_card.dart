// lib/features/pos/presentation/widgets/cash_closing/closing_payment_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/cash_closing_provider.dart';

class ClosingPaymentCard extends ConsumerWidget {
  final Map<String, double> totalesPorMetodo;
  final CashClosingNotifier notifier;
  final bool isMobile;
  final bool isTablet;

  const ClosingPaymentCard({
    super.key,
    required this.totalesPorMetodo,
    required this.notifier,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFF1A2235).withValues(alpha: 0.8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payment_rounded,
                      color: Color(0xFF94A3B8), size: isMobile ? 18 : 24),
                  const SizedBox(width: 8),
                  Text(
                    'Desglose por Método de Pago',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 18,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '${totalesPorMetodo.length} métodos',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Lista de métodos
              ...totalesPorMetodo.entries.map((entry) {
                final metodo = entry.key;
                final monto = entry.value;
                final color = notifier.getNeonColor(metodo);
                final icon = notifier.getMetodoIcono(metodo);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 10 : 14,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: isMobile ? 16 : 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            metodo,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 13 : 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '\$${monto.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 15 : 20,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
              // Total general (suma de todos los métodos)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL GENERAL',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 13 : 16,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '\$${totalesPorMetodo.values.fold(0.0, (sum, v) => sum + v).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 18 : 26,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
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
}