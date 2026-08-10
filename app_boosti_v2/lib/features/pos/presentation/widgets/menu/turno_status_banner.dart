import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

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
    final isMobile = ResponsiveHelper.isMobile(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: tieneTurno
            ? Colors.green.shade50.withValues(alpha: 0.6)
            : Colors.amber.shade50.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: tieneTurno ? Colors.green.shade300 : Colors.amber.shade300,
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            tieneTurno ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            key: ValueKey(tieneTurno),
            color: tieneTurno ? Colors.green.shade700 : Colors.amber.shade800,
            size: 24,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: tieneTurno ? Colors.green.shade800 : Colors.amber.shade800,
                  ),
                ),
                if (tieneTurno && horaApertura != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Iniciado: $horaApertura',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!tieneTurno)
            OutlinedButton(
              onPressed: onAbrirTurno,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber.shade800,
                side: BorderSide(color: Colors.amber.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 13),
              ),
              child: const Text('Abrir Turno'),
            ),
          if (tieneTurno)
            TextButton(
              onPressed: onCerrarTurno,
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 13),
              ),
              child: const Text('Cerrar Turno'),
            ),
        ],
      ),
    );
  }
}