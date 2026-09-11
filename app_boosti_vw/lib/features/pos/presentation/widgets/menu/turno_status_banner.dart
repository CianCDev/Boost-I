import 'package:flutter/material.dart';

class TurnoStatusBanner extends StatelessWidget {
  final bool tieneTurno;
  final String? horaApertura;
  final VoidCallback onAbrirTurno;
  final VoidCallback onCerrarTurno;

  const TurnoStatusBanner({
    super.key,
    required this.tieneTurno,
    this.horaApertura,
    required this.onAbrirTurno,
    required this.onCerrarTurno,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color baseColor = tieneTurno ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final IconData icon = tieneTurno ? Icons.check_circle_rounded : Icons.warning_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: baseColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tieneTurno ? 'Turno abierto' : 'No hay turno activo',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (tieneTurno && horaApertura != null)
                  Text(
                    'Iniciado a las $horaApertura',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                if (!tieneTurno)
                  Text(
                    'Inicia tu jornada laboral',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: tieneTurno ? onCerrarTurno : onAbrirTurno,
            style: ElevatedButton.styleFrom(
              backgroundColor: baseColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            child: Text(tieneTurno ? 'Cerrar' : 'Abrir'),
          ),
        ],
      ),
    );
  }
}