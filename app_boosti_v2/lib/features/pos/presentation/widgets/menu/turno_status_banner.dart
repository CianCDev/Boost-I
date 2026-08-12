// lib/features/pos/presentation/widgets/menu/turno_status_banner.dart

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
    final color = tieneTurno ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            tieneTurno ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tieneTurno ? 'Turno abierto' : 'No tienes un turno abierto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (tieneTurno && horaApertura != null)
                  Text(
                    'Iniciado a las $horaApertura',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                if (!tieneTurno)
                  Text(
                    'Inicia tu jornada laboral',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: tieneTurno ? onCerrarTurno : onAbrirTurno,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(tieneTurno ? 'Cerrar' : 'Abrir Turno'),
          ),
        ],
      ),
    );
  }
}