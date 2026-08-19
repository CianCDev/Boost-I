import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';

class EstadoChip extends StatelessWidget {
  final EstadoPedido estado;

  const EstadoChip({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(estado);
    final icon = _getIcon(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            estado.name.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return Colors.orange.shade600;
      case EstadoPedido.recibido:
        return Colors.green.shade600;
      case EstadoPedido.cancelado:
        return Colors.red.shade600;
    }
  }

  IconData _getIcon(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return Icons.hourglass_top_rounded;
      case EstadoPedido.recibido:
        return Icons.check_circle_rounded;
      case EstadoPedido.cancelado:
        return Icons.cancel_rounded;
    }
  }
}