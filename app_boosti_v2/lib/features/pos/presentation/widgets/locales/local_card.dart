// lib/features/pos/presentation/widgets/locales/local_card.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';
import '../common/card_action_button.dart';

class LocalCard extends StatelessWidget {
  final LocalEntity local;
  final bool isLocalActual;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback onDelete;

  const LocalCard({
    super.key,
    required this.local,
    this.isLocalActual = false,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActivo,
    required this.onDelete,
  });

  static const _colorActivo = Color(0xFF10B981);
  static const _colorInactivo = Color(0xFFEF4444);
  static const _colorEdit = Color(0xFF8B5CF6);
  static const _colorWarning = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activo = local.activo;
    final estadoColor = activo ? _colorActivo : _colorInactivo;

    return GlassCard(
      onTap: onTap,
      showStatusBar: true,
      statusColor: estadoColor,
      isHighlighted: isLocalActual,
      highlightColor: _colorActivo,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TÍTULO + BADGES =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  local.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 15 : 18,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (isLocalActual) ...[
                const StatusBadge(
                  label: 'ACTUAL',
                  color: _colorActivo,
                  size: StatusBadgeSize.small,
                ),
                const SizedBox(width: 6),
              ],
              StatusBadge(
                label: activo ? 'Activo' : 'Inactivo',
                color: estadoColor,
                size: StatusBadgeSize.small,
              ),
            ],
          ),

          // ===== DIRECCIÓN =====
          if (local.direccion != null && local.direccion!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: isMobile ? 12 : 14,
                    color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    local.direccion!,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // ===== TELÉFONO / EMAIL / RIF =====
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              if (local.telefono?.isNotEmpty ?? false)
                _infoItem(Icons.phone_rounded, local.telefono!,
                    colorScheme, isMobile),
              if (local.email?.isNotEmpty ?? false)
                _infoItem(Icons.email_rounded, local.email!,
                    colorScheme, isMobile),
              if (local.rif?.isNotEmpty ?? false)
                _infoItem(Icons.assignment_rounded, 'RIF: ${local.rif}',
                    colorScheme, isMobile),
            ],
          ),

          // ===== BOTONES DE ACCIÓN =====
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CardActionButton(
                icon: Icons.edit_rounded,
                color: _colorEdit,
                tooltip: 'Editar',
                onPressed: onEdit,
              ),
              CardActionButton(
                icon: activo
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                color: activo ? _colorWarning : _colorActivo,
                tooltip: activo ? 'Desactivar' : 'Activar',
                onPressed: onToggleActivo,
              ),
              CardActionButton(
                icon: Icons.delete_outline_rounded,
                color: _colorInactivo,
                tooltip: 'Eliminar',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, ColorScheme colorScheme, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: isMobile ? 12 : 14,
            color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 11 : 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}