// lib/features/pos/presentation/widgets/lotes/lotes_summary_cards.dart
import 'package:flutter/material.dart';
import '../../common/metric_pedido.dart';

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

  static const _colorPendiente = Color(0xFFF59E0B);
  static const _colorActivo = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorHistorial = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MetricPedido(
          label: 'Pendientes',
          value: pendientes,
          color: _colorPendiente,
          icon: Icons.hourglass_top_rounded,
        ),
        const SizedBox(width: 8),
        MetricPedido(
          label: 'Activos',
          value: activos,
          color: _colorActivo,
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: 8),
        MetricPedido(
          label: 'Vencen pronto',
          value: proximosAVencer,
          color: _colorDanger,
          icon: Icons.warning_amber_rounded,
        ),
        const SizedBox(width: 8),
        MetricPedido(
          label: 'Historial',
          value: historial,
          color: _colorHistorial,
          icon: Icons.history_rounded,
        ),
      ],
    );
  }
}