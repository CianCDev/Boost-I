import 'package:flutter/material.dart';

class ScaleVisorWidget extends StatelessWidget {
  final double pesoActual;
  final bool estaConectada;

  const ScaleVisorWidget({
    super.key,
    required this.pesoActual,
    this.estaConectada = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0F172A), // Fondo oscuro estilo pantalla industrial
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.scale,
                  color: estaConectada ? const Color(0xFF10B981) : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  estaConectada ? 'BALANZA ACTIVA' : 'DESCONECTADA',
                  style: TextStyle(
                    color: estaConectada ? Colors.white70 : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  pesoActual.toStringAsFixed(3),
                  style: const TextStyle(
                    color: Color(0xFF10B981), // Verde LED
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'KG',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}