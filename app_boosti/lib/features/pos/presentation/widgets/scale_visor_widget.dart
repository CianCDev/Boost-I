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

    // Texto de estado más corto en móvil
    final estadoTexto = isMobile ? 'BALANZA' : 'BALANZA ACTIVA';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: estaConectada ? Colors.green.shade700 : Colors.red.shade700,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.scale,
                color: estaConectada ? Colors.green : Colors.red,
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                estadoTexto,
                style: TextStyle(
                  color: Colors.white,
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
                  color: estaConectada ? Colors.greenAccent : Colors.redAccent,
                  fontSize: pesoFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' KG',
                style: TextStyle(
                  color: Colors.grey.shade400,
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