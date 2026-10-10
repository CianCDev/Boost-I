import 'package:flutter/material.dart';

import '../../../pos/presentation/widgets/common/glass_card.dart';

/// Tarjeta de indicador clave (MRR, clientes activos, trials, etc.).
///
/// Envuelve [GlassCard] para no duplicar el estilo base. Recibe el `value`
/// ya formateado desde la capa de providers (`SaasMetrics.mrrFormateado`,
/// etc.) para que este widget no tenga lógica de presentation.
///
/// El trend solo se dibuja si se pasan **ambos** [trendPercent] y [trendUp]:
/// sin la dirección no hay color ni icono definibles.
class KpiCard extends StatelessWidget {
  /// Texto de la métrica, ej. "MRR".
  final String label;

  /// Valor ya formateado, ej. "$1,240".
  final String value;

  final IconData icon;

  /// Color de acento: ícono y fondo del cuadrado.
  final Color color;

  /// Variación porcentual vs. el mes anterior. `null` = sin trend.
  final double? trendPercent;

  /// Dirección del trend. `null` = no mostrar trend.
  final bool? trendUp;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trendPercent,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      // El grid exterior controla el espaciado entre tarjetas.
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          if (trendPercent != null && trendUp != null) ...[
            const SizedBox(height: 6),
            _Trend(
              trendPercent: trendPercent!,
              trendUp: trendUp!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila de variación porcentual bajo el valor del KPI.
class _Trend extends StatelessWidget {
  final double trendPercent;
  final bool trendUp;

  const _Trend({required this.trendPercent, required this.trendUp});

  /// Verde esmeralda = success, rojo = error (docs/business_rules.md).
  static const Color _verde = Color(0xFF10B981);
  static const Color _rojo = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final color = trendUp ? _verde : _rojo;
    final icono =
        trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Row(
      children: [
        Icon(icono, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${trendPercent.toStringAsFixed(1)}% vs mes anterior',
            style: TextStyle(fontSize: 12, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
