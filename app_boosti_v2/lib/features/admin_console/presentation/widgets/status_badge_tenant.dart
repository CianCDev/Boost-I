import 'package:flutter/material.dart';

import '../../../pos/presentation/widgets/common/status_badge.dart';
import '../../data/models/suscripcion.dart';

/// Traduce un [EstadoSuscripcion] al `StatusBadge` del POS.
///
/// Es un wrapper: no reimplementa el badge, solo decide label + color +
/// ícono. Así el Control Center no duplica el componente visual del POS.
class StatusBadgeTenant extends StatelessWidget {
  final EstadoSuscripcion estado;
  final StatusBadgeSize size;

  const StatusBadgeTenant({
    super.key,
    required this.estado,
    this.size = StatusBadgeSize.medium,
  });

  // Paleta de estados segun docs/business_rules.md.
  static const Color _ambar = Color(0xFFF59E0B);
  static const Color _verde = Color(0xFF10B981);
  static const Color _rojo = Color(0xFFEF4444);
  static const Color _gris = Colors.grey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Para `desconocido` el color depende del tema, así que no puede ser
    // una constante de clase.
    final (label, color, icon) = switch (estado) {
      EstadoSuscripcion.trial => ('Trial', _ambar, Icons.hourglass_top_rounded),
      EstadoSuscripcion.activo => (
          'Activo',
          _verde,
          Icons.check_circle_rounded
        ),
      EstadoSuscripcion.vencido => (
          'Vencido',
          _rojo,
          Icons.error_rounded
        ),
      EstadoSuscripcion.expirado => (
          'Expirado',
          _rojo,
          Icons.cancel_rounded
        ),
      EstadoSuscripcion.cancelado => (
          'Cancelado',
          _gris,
          Icons.block_rounded
        ),
      EstadoSuscripcion.desconocido => (
          'Desconocido',
          colorScheme.onSurfaceVariant,
          Icons.help_outline_rounded
        ),
    };

    return StatusBadge(
      label: label,
      color: color,
      icon: icon,
      size: size,
    );
  }
}
