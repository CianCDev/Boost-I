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
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    ResponsiveHelper.isTablet(context);
    final fontSize = ResponsiveHelper.getFontSize(context, baseSize: 14);

    final horizontalPadding = isMobile ? 12.0 : 16.0;
    final verticalPadding = isMobile ? 6.0 : 8.0;
    final iconSize = isMobile ? 18.0 : 24.0;
    final pesoFontSize = isMobile ? fontSize * 1.1 : fontSize * 1.5;

    // Colores dinámicos
    final Color fondo = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : const Color(0xFFF1F5F9);

    final Color bordeConectado = theme.brightness == Brightness.dark
        ? Colors.green.shade400
        : Colors.green.shade300;

    final Color bordeDesconectado = theme.brightness == Brightness.dark
        ? Colors.red.shade400
        : Colors.red.shade300;

    final Color colorConectado = theme.brightness == Brightness.dark
        ? Colors.green.shade300
        : Colors.green.shade600;

    final Color colorDesconectado = theme.brightness == Brightness.dark
        ? Colors.red.shade300
        : Colors.red;

    final Color textoPeso = theme.textTheme.bodyLarge?.color ?? const Color(0xFF0F172A);
    final Color textoKg = theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: estaConectada ? bordeConectado : bordeDesconectado,
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
                color: estaConectada ? colorConectado : colorDesconectado,
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                estaConectada ? 'BALANZA' : 'DESCONECTADA',
                style: TextStyle(
                  color: estaConectada ? colorConectado : colorDesconectado,
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
                    color: estaConectada ? colorConectado : colorDesconectado,
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
                  color: textoPeso,
                  fontSize: pesoFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' KG',
                style: TextStyle(
                  color: textoKg,
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