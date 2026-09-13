import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';

class PedidoCard extends StatefulWidget {
  final PedidoEntity pedido;
  final VoidCallback onTap;

  const PedidoCard({super.key, required this.pedido, required this.onTap});

  @override
  State<PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  static const _colorPendiente = Color(0xFFF59E0B);
  static const _colorRecibido = Color(0xFF10B981);
  static const _colorCancelado = Color(0xFFEF4444);

  Future<int> _getCantidadProductos() async {
    try {
      final isar = IsarService();
      final detalles = await isar.obtenerDetallesPorPedido(widget.pedido.id);
      return detalles.length;
    } catch (_) {
      return 0;
    }
  }

  Color _barColor(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return _colorPendiente;
      case EstadoPedido.recibido:
        return _colorRecibido;
      case EstadoPedido.cancelado:
        return _colorCancelado;
    }
  }

  IconData _icono(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return Icons.hourglass_top_rounded;
      case EstadoPedido.recibido:
        return Icons.check_circle_rounded;
      case EstadoPedido.cancelado:
        return Icons.cancel_rounded;
    }
  }

  String _label(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return 'Pendiente';
      case EstadoPedido.recibido:
        return 'Recibido';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final barColor = _barColor(widget.pedido.estado);

    return GlassCard(
      onTap: widget.onTap,
      showStatusBar: true,
      statusColor: barColor,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + estado
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.pedido.proveedorNombre,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: _label(widget.pedido.estado),
                color: barColor,
                icon: _icono(widget.pedido.estado),
                size: StatusBadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Empresa + fecha
          Row(
            children: [
              Icon(Icons.business_rounded,
                  size: isMobile ? 12 : 13,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.pedido.proveedorEmpresa ?? 'Sin empresa',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.calendar_today_rounded,
                  size: isMobile ? 12 : 13,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(widget.pedido.fechaPedido),
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Cantidad + total
          Row(
            children: [
              Icon(Icons.shopping_bag_rounded,
                  size: isMobile ? 12 : 13,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              FutureBuilder<int>(
                future: _getCantidadProductos(),
                initialData: 0,
                builder: (context, snapshot) {
                  final cantidad = snapshot.data ?? 0;
                  return Text(
                    '$cantidad productos',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
              const Spacer(),
              Text(
                '\$${widget.pedido.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: _colorRecibido,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}