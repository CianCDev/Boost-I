import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class ScaleVisorWidget extends StatelessWidget {
  final double pesoActual;
  final bool estaConectada;

  const ScaleVisorWidget({
    super.key,
    required this.pesoActual,
    this.estaConectada = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    ResponsiveHelper.isTablet(context);
    final fontSize = ResponsiveHelper.getFontSize(context, baseSize: 14);

    // Ajustar padding según el dispositivo
    final horizontalPadding = isMobile ? 12.0 : 16.0;
    final verticalPadding = isMobile ? 6.0 : 8.0;

    // Tamaño del icono
    final iconSize = isMobile ? 18.0 : 24.0;

    // Tamaño de la fuente del peso
    final pesoFontSize = isMobile ? fontSize * 1.1 : fontSize * 1.5;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Fondo gris muy suave y amigable (antes era 0xFF0F172A)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: estaConectada ? Colors.green.shade300 : Colors.red.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.scale,
                color: estaConectada ? Colors.green.shade600 : Colors.red,
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                estaConectada ? 'BALANZA' : 'DESCONECTADA',
                style: TextStyle(
                  color: estaConectada ? Colors.green.shade700 : Colors.red,
                  fontSize: isMobile ? fontSize * 0.75 : fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: estaConectada ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),  
          Row(
            children: [
              Text(
                pesoActual.toStringAsFixed(3),
                style: TextStyle(
                  color: const Color(0xFF0F172A), // Texto oscuro para contrastar con el fondo claro
                  fontSize: pesoFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' KG',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isMobile ? fontSize * 0.7 : fontSize * 0.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}