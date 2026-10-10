import 'package:flutter/material.dart';

import '../../../pos/presentation/widgets/common/glass_card.dart';
import '../../../pos/presentation/widgets/common/status_badge.dart';
import '../../data/models/plan.dart';
import '../../data/models/suscripcion.dart';
import '../../data/models/tenant.dart';
import 'status_badge_tenant.dart';

/// Tarjeta de un cliente (tenant) para el listado del Control Center.
///
/// Muestra el nombre, el plan y el estado de la suscripción. Los textos
/// de días llegan ya formateados desde el provider (`subtituloDias`), y el
/// precio desde `Plan.precioMensualFormateado`: este widget no formatea
/// nada para no duplicar reglas de presentación.
class ClientCard extends StatelessWidget {
  final Tenant tenant;
  final Suscripcion? suscripcion;
  final Plan? plan;

  /// Días relevantes según el contexto de la lista
  /// (`diasHastaVencimiento`, `diasInactivo`, `diasDesdeCancelacion`).
  final int? diasRestantes;

  /// Texto ya formateado, ej. "Vence en 2 días".
  final String? subtituloDias;

  final VoidCallback? onTap;

  /// Botones opcionales alineados a la derecha abajo.
  final List<Widget>? acciones;

  const ClientCard({
    super.key,
    required this.tenant,
    this.suscripcion,
    this.plan,
    this.diasRestantes,
    this.subtituloDias,
    this.onTap,
    this.acciones,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final estado = suscripcion?.estado;
    final colorEstado = _colorEstado(estado);

    return GlassCard(
      onTap: onTap,
      showStatusBar: true,
      statusColor: colorEstado,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Columna izquierda: identidad ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tenant.nombre,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (suscripcion != null) ...[
                          const SizedBox(width: 8),
                          StatusBadgeTenant(
                            estado: estado!,
                            size: StatusBadgeSize.small,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitulo(plan, subtituloDias),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tenant.tieneContacto) ...[
                      const SizedBox(height: 2),
                      Text(
                        _contacto(tenant),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // ── Columna derecha: plan y estado ──
              if (suscripcion != null) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // Si el plan es gratuito (precio 0, típicamente Trial),
                      // mostrar "Gratis" en lugar de "$0". Si no hay plan,
                      // mostrar "—".
                      _textoPrecio(plan),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          // ── Acciones opcionales ──
          if (acciones != null && acciones!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: acciones!,
            ),
          ],
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // HELPERS
  // ═════════════════════════════════════════════════════════════

  /// "Pro · Vence en 2 días", o solo el plan si no hay subtítulo de días.
  String _subtitulo(Plan? plan, String? subtituloDias) {
    final nombrePlan = plan?.nombre ?? 'Sin plan';
    final dias = subtituloDias?.trim() ?? '';
    if (dias.isEmpty) return nombrePlan;
    return '$nombrePlan · $dias';
  }

  /// Texto a mostrar en el slot del precio según el plan.
  /// - Sin plan → '—'
  /// - Plan gratis (precio 0) → 'Gratis'
  /// - Resto → precio formateado ('$25', '$60', '$220')
  String _textoPrecio(Plan? plan) {
    if (plan == null) return '—';
    if (plan.precioMensual == 0) return 'Gratis';
    return plan.precioMensualFormateado;
  }

  /// Email si existe, con el teléfono como fallback.
  String _contacto(Tenant t) {
    final email = t.emailContacto?.trim() ?? '';
    if (email.isNotEmpty) return email;
    final tel = t.telefono?.trim() ?? '';
    return tel.isEmpty ? '' : tel;
  }

  /// Color de la barra de estado según la suscripción.
  ///
  /// El caso `desconocido` (y cualquier valor futuro del enum) cae en
  /// violeta, el color de info.
  Color _colorEstado(EstadoSuscripcion? estado) {
    return switch (estado) {
      EstadoSuscripcion.activo => const Color(0xFF10B981),
      EstadoSuscripcion.trial => const Color(0xFFF59E0B),
      EstadoSuscripcion.vencido => const Color(0xFFEF4444),
      EstadoSuscripcion.expirado => const Color(0xFFEF4444),
      EstadoSuscripcion.cancelado => Colors.grey,
      EstadoSuscripcion.desconocido => const Color(0xFF8B5CF6),
      null => const Color(0xFF8B5CF6),
    };
  }
}
