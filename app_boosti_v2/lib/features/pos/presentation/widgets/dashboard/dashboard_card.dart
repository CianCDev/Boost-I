// lib/features/pos/presentation/widgets/dashboard/dashboard_card.dart
import 'package:flutter/material.dart';

/// Contenedor base para las tarjetas del dashboard.
///
/// Centraliza el estilo (fondo, borde, radio y sombra) para que las
/// secciones nuevas no repitan la misma decoración con variaciones
/// mínimas entre archivo y archivo.
class DashboardCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final Widget child;
  final String? subtitulo;
  final Widget? trailing;

  const DashboardCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.color,
    required this.child,
    this.subtitulo,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A2235) : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final subtitleColor = isDark ? Colors.white54 : Colors.grey.shade500;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (subtitulo != null)
                      Text(
                        subtitulo!,
                        style: TextStyle(
                          fontSize: 10,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
