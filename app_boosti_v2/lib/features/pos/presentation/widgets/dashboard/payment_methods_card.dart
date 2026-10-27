// lib/features/pos/presentation/widgets/dashboard/payment_methods_card.dart
import 'package:flutter/material.dart';

import 'dashboard_card.dart';

/// Reparto de la facturación del mes por método de pago.
///
/// Responde una pregunta concreta: ¿cuánto del dinero entró en efectivo
/// y cuánto por transferencia/pago móvil? Si el 80% es efectivo, el
/// cuadre de caja es crítico; si es digital, también lo es la conciliación.
class PaymentMethodsCard extends StatelessWidget {
  /// `{ 'Efectivo': {'total': 120.0, 'count': 8.0}, ... }`
  final Map<String, Map<String, double>> datos;

  const PaymentMethodsCard({super.key, required this.datos});

  static const List<Color> _paleta = [
    Color(0xFF00E676),
    Color(0xFF00E5FF),
    Color(0xFFD500F9),
    Color(0xFFFF9100),
    Color(0xFFFF5252),
    Color(0xFF448AFF),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade700;

    final filas = datos.entries.toList()
      ..sort((a, b) =>
          (b.value['total'] ?? 0).compareTo(a.value['total'] ?? 0));

    final totalGeneral = filas.fold<double>(
      0,
      (suma, e) => suma + (e.value['total'] ?? 0),
    );

    return DashboardCard(
      titulo: 'Métodos de pago (mes)',
      icono: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF00E676),
      subtitulo: filas.isEmpty
          ? 'Sin ventas este mes'
          : '\$${totalGeneral.toStringAsFixed(2)} cobrados',
      child: filas.isEmpty
          ? Text(
              'Todavía no hay cobros registrados en el mes.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey.shade500,
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < filas.length; i++) ...[
                  _fila(
                    context,
                    nombre: filas[i].key,
                    total: filas[i].value['total'] ?? 0,
                    count: (filas[i].value['count'] ?? 0).toInt(),
                    porcentaje: totalGeneral > 0
                        ? ((filas[i].value['total'] ?? 0) / totalGeneral) * 100
                        : 0,
                    color: _paleta[i % _paleta.length],
                    textColor: textColor,
                  ),
                  if (i < filas.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _fila(
    BuildContext context, {
    required String nombre,
    required double total,
    required int count,
    required double porcentaje,
    required Color color,
    required Color textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Text(
              '$count · \$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (porcentaje / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
