// lib/features/pos/presentation/widgets/salon/mesa_card.dart
import 'package:flutter/material.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/mesas_provider.dart';

import '../common/glass_card.dart';
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

    return GlassCard(
      onTap: onTap,
      onLongPress: onLongPress,
      showStatusBar: true,
      statusColor: colorEstado,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Nombre ──
          Text(
            mesa.nombre,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // ── Estado + Zona ──
          Row(
            children: [
              StatusBadge(
                label: MesasNotifier.etiquetaEstado(mesa.estado),
                color: colorEstado,
                size: StatusBadgeSize.small,
              ),
              const SizedBox(width: 6),
              if (mesa.estaUnida)
                StatusBadge(
                  label: 'Unida',
                  color: colorScheme.outline,
                  size: StatusBadgeSize.small,
                ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Zona + capacidad ──
          Row(
            children: [
              Icon(
                Icons.place_outlined,
                size: 13,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  etiquetaZona(mesa.zona),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.people_alt_outlined,
                size: 13,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                '${mesa.capacidad} pax',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // ── Tiempo de ocupación ──
          if (mesa.estado == MesaEstado.ocupada &&
              mesa.ocupadaDesde != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: colorOcupada,
                ),
                const SizedBox(width: 4),
                Text(
                  _duracion(mesa.ocupadaDesde!),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorOcupada,
                  ),
                ),
              ],
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