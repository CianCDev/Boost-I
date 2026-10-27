// lib/features/pos/presentation/widgets/dashboard/restaurant_status_card.dart
import 'package:flutter/material.dart';

import 'dashboard_card.dart';

/// Estado operativo del salón: mesas ocupadas y comandas abiertas.
///
/// Solo se muestra cuando el local tiene mesas configuradas, así que en
/// retail no aparece. La ocupación es el indicador que dice si hace falta
/// abrir más mesas o si el turno está flojo.
class RestaurantStatusCard extends StatelessWidget {
  final int mesasTotales;
  final int mesasOcupadas;
  final int comandasAbiertas;
  final String ticketPromedioFormateado;

  const RestaurantStatusCard({
    super.key,
    required this.mesasTotales,
    required this.mesasOcupadas,
    required this.comandasAbiertas,
    required this.ticketPromedioFormateado,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFFFF9100);
    final textColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final muted = isDark ? Colors.white54 : Colors.grey.shade500;

    final ocupacion = mesasTotales > 0 ? mesasOcupadas / mesasTotales : 0.0;
    final libres = mesasTotales - mesasOcupadas;

    return DashboardCard(
      titulo: 'Salón',
      icono: Icons.table_restaurant_rounded,
      color: accent,
      subtitulo: '$mesasOcupadas de $mesasTotales mesas ocupadas',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: ocupacion >= 0.8
              ? Colors.red.withValues(alpha: 0.15)
              : accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${(ocupacion * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ocupacion >= 0.8 ? Colors.red.shade400 : accent,
          ),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ocupacion.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                ocupacion >= 0.8 ? Colors.red.shade400 : accent,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _dato(
                titulo: 'Libres',
                valor: '$libres',
                color: Colors.green.shade400,
                textColor: textColor,
                muted: muted,
              ),
              _dato(
                titulo: 'Comandas',
                valor: '$comandasAbiertas',
                color: const Color(0xFF00E5FF),
                textColor: textColor,
                muted: muted,
              ),
              _dato(
                titulo: 'Ticket prom.',
                valor: ticketPromedioFormateado,
                color: const Color(0xFF00E676),
                textColor: textColor,
                muted: muted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato({
    required String titulo,
    required String valor,
    required Color color,
    required Color textColor,
    required Color muted,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 10,
              color: muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
