import 'package:flutter/material.dart';

/// Encabezado de sección con ícono, divisor y acción opcional.
///
/// Reemplaza el patrón repetido "ícono + título uppercase + Divider +
/// botón 'Ver todos'" que usan las secciones del Control Center.
class SectionHeader extends StatelessWidget {
  final String titulo;
  final IconData? icono;
  final String? subtitulo;

  /// Acción a la derecha, ej. `TextButton("Ver todos")`.
  final Widget? trailing;

  /// Color del ícono y del título. Por defecto violeta (info).
  final Color? color;

  const SectionHeader({
    super.key,
    required this.titulo,
    this.icono,
    this.subtitulo,
    this.trailing,
    this.color,
  });

  /// Violeta = color de info en docs/business_rules.md.
  static const Color _colorPorDefecto = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorTitulo = color ?? _colorPorDefecto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icono != null) ...[
              Icon(icono, size: 18, color: colorTitulo),
              const SizedBox(width: 8),
            ],
            Text(
              titulo.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: colorTitulo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Divider(
                color: colorTitulo.withValues(alpha: 0.2),
                height: 1,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitulo!,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
