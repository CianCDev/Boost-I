// lib/features/pos/presentation/widgets/salon/mesa_card.dart
import 'package:flutter/material.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/mesas_provider.dart';

import '../common/glass_item_card.dart';
import '../common/status_badge.dart';

/// Card de una mesa en el grid del salón.
///
/// R.2: el `onTap` abre la COMANDA (libre u ocupada). El `onLongPress`
/// abre la EDICIÓN de la mesa.
class MesaCard extends StatelessWidget {
  final MesaEntity mesa;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const MesaCard({
    super.key,
    required this.mesa,
    required this.onTap,
    this.onLongPress,
  });

  /// Color asociado a cada estado.
  static const colorLibre = Color(0xFF10B981);
  static const colorOcupada = Color(0xFFF59E0B);
  static const colorReservada = Color(0xFF3B82F6);
  static const colorPorLimpiar = Color(0xFF94A3B8);

  static Color colorDeEstado(MesaEstado estado) {
    switch (estado) {
      case MesaEstado.libre:
        return colorLibre;
      case MesaEstado.ocupada:
        return colorOcupada;
      case MesaEstado.reservada:
        return colorReservada;
      case MesaEstado.porLimpiar:
        return colorPorLimpiar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorEstado = colorDeEstado(mesa.estado);
    final icono = switch (mesa.estado) {
      MesaEstado.libre => Icons.event_available_rounded,
      MesaEstado.ocupada => Icons.table_restaurant_rounded,
      MesaEstado.reservada => Icons.event_busy_rounded,
      MesaEstado.porLimpiar => Icons.cleaning_services_rounded,
    };

    return GlassItemCard(
      icon: icono,
      title: mesa.nombre,
      statusColor: colorEstado,
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(12),
      trailingWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(
            label: MesasNotifier.etiquetaEstado(mesa.estado),
            color: colorEstado,
            size: StatusBadgeSize.small,
          ),
          if (mesa.estaUnida) ...[
            const SizedBox(height: 4),
            StatusBadge(
              label: 'Unida',
              color: colorScheme.outline,
              size: StatusBadgeSize.small,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mesa.zonaEfectiva,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text('${mesa.capacidad} pax'),
          if (mesa.estado == MesaEstado.ocupada &&
              mesa.ocupadaDesde != null) ...[
            const SizedBox(height: 4),
            Text(
              _duracion(mesa.ocupadaDesde!),
              style: TextStyle(
                color: colorOcupada,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// "1h 25m" a partir del instante de ocupación.
  static String _duracion(DateTime desde) {
    final d = DateTime.now().difference(desde);
    if (d.inHours <= 0) return '${d.inMinutes}m';
    if (d.inHours < 24) {
      final min = d.inMinutes % 60;
      return min == 0 ? '${d.inHours}h' : '${d.inHours}h ${min}m';
    }
    return '${d.inDays}d';
  }
}
