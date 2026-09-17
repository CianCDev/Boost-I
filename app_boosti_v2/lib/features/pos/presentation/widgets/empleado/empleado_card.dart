// lib/features/pos/presentation/widgets/empleados/employee_card.dart
import 'package:flutter/material.dart';

import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/models/empleado_view_model.dart';
import '../../../domain/permissions/roles.dart';
import '../../utils/responsive_helper.dart';
import '../common/status_badge.dart';

/// Card de un empleado en el listado.
///
/// Muestra avatar, nombre, documento, rol, cargo, antigüedad y estado.
/// Al hacer hover, se eleva ligeramente y aparece un borde de color
/// según el rol.
class EmployeeCard extends StatefulWidget {
  final EmpleadoViewModel empleado;
  final VoidCallback? onTap;

  const EmployeeCard({
    super.key,
    required this.empleado,
    this.onTap,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final empleado = widget.empleado;
    final accent = _roleColor(empleado.rol);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh
                    .withValues(alpha: _hovered ? 0.9 : 0.7)
                : Colors.white.withValues(alpha: _hovered ? 1.0 : 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? accent.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.2 : (_hovered ? 0.08 : 0.04),
                ),
                blurRadius: _hovered ? 14 : 8,
                offset: Offset(0, _hovered ? 5 : 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Fila superior: avatar + nombre + estado ──
              Row(
                children: [
                  _buildAvatar(empleado, accent, isMobile),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          empleado.nombre,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          empleado.documentoCompleto,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: empleado.activo ? 'Activo' : 'Inactivo',
                    color: empleado.activo
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    size: StatusBadgeSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Badge de rol ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_roleIcon(empleado.rol),
                            size: 11, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          empleado.rol.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: accent,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (empleado.antiguedad != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '· ${empleado.antiguedad}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // ── Info secundaria ──
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (empleado.cargo != null &&
                      empleado.cargo!.isNotEmpty)
                    _infoChip(
                      Icons.work_outline_rounded,
                      empleado.cargo!,
                      colorScheme,
                    ),
                  if (empleado.telefono != null &&
                      empleado.telefono!.isNotEmpty)
                    _infoChip(
                      Icons.phone_outlined,
                      empleado.telefono!,
                      colorScheme,
                    ),
                  if (empleado.tieneSalarioConfigurado)
                    _infoChip(
                      Icons.attach_money_rounded,
                      '${empleado.monedaSalario ?? "USD"} '
                      '${empleado.salarioBase!.toStringAsFixed(0)}',
                      colorScheme,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(
    EmpleadoViewModel empleado,
    Color accent,
    bool isMobile,
  ) {
    final size = isMobile ? 44.0 : 52.0;
    final tieneFoto =
        empleado.fotoUrl != null && empleado.fotoUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: tieneFoto
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  Color.lerp(accent, Colors.black, 0.2)!,
                ],
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: tieneFoto
            ? Image.network(
                empleado.fotoUrl!,
                fit: BoxFit.cover,
                cacheWidth: (size * 2).toInt(),
                errorBuilder: (_, __, ___) =>
                    _fallbackInitials(empleado.inicial),
              )
            : _fallbackInitials(empleado.inicial),
      ),
    );
  }

  Widget _fallbackInitials(String inicial) {
    return Center(
      child: Text(
        inicial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

Color _roleColor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return const Color(0xFF3B82F6);
    case UserRole.supervisor:
      return const Color(0xFF8B5CF6);
    case UserRole.rrhh:
      return const Color(0xFF10B981);
    case UserRole.cajero:
      return const Color(0xFF14B8A6);
    case UserRole.auditor:
      return const Color(0xFF64748B);
    case UserRole.almacen:
      return const Color(0xFFF59E0B);
    case UserRole.dev:
      return const Color(0xFF06B6D4);
    case UserRole.soporte:
      return const Color(0xFF6366F1);
  }
}

IconData _roleIcon(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return Icons.admin_panel_settings_rounded;
    case UserRole.supervisor:
      return Icons.supervisor_account_rounded;
    case UserRole.rrhh:
      return Icons.badge_rounded;
    case UserRole.cajero:
      return Icons.point_of_sale_rounded;
    case UserRole.auditor:
      return Icons.verified_rounded;
    case UserRole.almacen:
      return Icons.inventory_2_rounded;
    case UserRole.dev:
      return Icons.terminal_rounded;
    case UserRole.soporte:
      return Icons.support_agent_rounded;
  }
}