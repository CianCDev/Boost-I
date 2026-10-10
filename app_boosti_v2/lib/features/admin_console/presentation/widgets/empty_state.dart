import 'package:flutter/material.dart';

/// Estado vacío reutilizable (sin clientes, sin resultados, sin pagos).
///
/// [color] es nullable a propósito: el valor por defecto depende de
/// `Theme.of(context)`, que no está disponible en un constructor `const`.
/// Cuando es `null` se resuelve a `colorScheme.onSurfaceVariant`.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String? subtitulo;

  /// Acción opcional, ej. un `FilledButton` "Crear cliente".
  final Widget? accion;

  /// Color del ícono. `null` = `colorScheme.onSurfaceVariant`.
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.titulo,
    this.subtitulo,
    this.accion,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colorIcono = color ?? colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: colorIcono.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitulo!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (accion != null) ...[
            const SizedBox(height: 16),
            accion!,
          ],
        ],
      ),
    );
  }
}
