import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TurnoClosingDialog extends StatelessWidget {
  final double montoInicial;
  final double montoFinal;
  final DateTime fechaApertura;
  final VoidCallback onConfirm;

  const TurnoClosingDialog({
    super.key,
    required this.montoInicial,
    required this.montoFinal,
    required this.fechaApertura,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fechaStr =
        '${fechaApertura.day}/${fechaApertura.month}/${fechaApertura.year} ${fechaApertura.hour.toString().padLeft(2, '0')}:${fechaApertura.minute.toString().padLeft(2, '0')}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: BoxConstraints(
          maxWidth: 500, // ✅ Más grande
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lottie de cierre de turno (con fallback)
            _buildLottieWithFallback('assets/animations/Clock Alarm Animation.json'),
            const SizedBox(height: 16),
            Text(
              'Cerrar Turno',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Resumen del turno',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    'Inicio del turno',
                    fechaStr,
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Monto inicial',
                    '\$${montoInicial.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Total ventas',
                    '\$${montoFinal.toStringAsFixed(2)}',
                    Icons.trending_up,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: onConfirm,
                    child: const Text('Cerrar Turno'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: color ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLottieWithFallback(String assetPath) {
    try {
      return Lottie.asset(
        assetPath,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.timer,
            size: 80,
            color: const Color(0xFF10B981),
          );
        },
      );
    } catch (e) {
      return Icon(
        Icons.timer,
        size: 80,
        color: const Color(0xFF10B981),
      );
    }
  }
}