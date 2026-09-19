// lib/features/pos/presentation/widgets/proveedores/proveedor_card.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';
import '../common/card_action_button.dart';

class ProveedorCard extends StatelessWidget {
  final ProveedorEntity proveedor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback onDelete;

  const ProveedorCard({
    super.key,
    required this.proveedor,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActivo,
    required this.onDelete,
  });

  static const _colorActivo = Color(0xFF10B981);
  static const _colorInactivo = Color(0xFFEF4444);
  static const _colorEdit = Color(0xFF8B5CF6);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorAccent = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activo = proveedor.activo;
    final estadoColor = activo ? _colorActivo : _colorInactivo;

    final mostrarEmpresa = proveedor.empresa != null &&
        proveedor.empresa!.isNotEmpty &&
        proveedor.empresa!.toLowerCase() !=
            proveedor.nombre.toLowerCase();

    final tieneDoc = proveedor.documentoFormateado.isNotEmpty;
    final tieneTel = proveedor.telefono?.isNotEmpty ?? false;
    final tieneEmail = proveedor.email?.isNotEmpty ?? false;
    final tieneAlgunDato = tieneDoc || tieneTel || tieneEmail;

    return GlassCard(
      onTap: onTap,
      showStatusBar: true,
      statusColor: estadoColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══ HEADER: avatar + nombre + empresa + badge ═══
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      proveedor.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (mostrarEmpresa) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              proveedor.empresa!,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: activo ? 'Activo' : 'Inactivo',
                color: estadoColor,
                size: StatusBadgeSize.small,
              ),
            ],
          ),

          // ═══ INFO PILLS ═══
          if (tieneAlgunDato) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (tieneDoc)
                  _infoPill(
                    context,
                    icon: _iconoDocumento(proveedor.tipoDocumento),
                    text: proveedor.documentoFormateado,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    color: _colorAccent,
                    highlight: true,
                  ),
                if (tieneTel)
                  _infoPill(
                    context,
                    icon: Icons.phone_rounded,
                    text: proveedor.telefono!,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                if (tieneEmail)
                  _infoPill(
                    context,
                    icon: Icons.email_rounded,
                    text: proveedor.email!,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
              ],
            ),
          ],

          // ═══ ACCIONES ═══
          const SizedBox(height: 12),
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

  // ═══════════════════════════════════════════════════════════════
  // AVATAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAvatar() {
    final inicial = proveedor.nombre.isNotEmpty
        ? proveedor.nombre[0].toUpperCase()
        : '?';
    final activo = proveedor.activo;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: activo
              ? const [_colorAccent, Color(0xFF6D28D9)]
              : [
                  _colorAccent.withValues(alpha: 0.5),
                  const Color(0xFF6D28D9).withValues(alpha: 0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _colorAccent.withValues(alpha: activo ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          inicial,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INFO PILL — chip con icono + texto (anti-overflow en mobile)
  // ═══════════════════════════════════════════════════════════════

  Widget _infoPill(
    BuildContext context, {
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
    required bool isDark,
    Color? color,
    bool highlight = false,
  }) {
    final effectiveColor = color ?? colorScheme.onSurfaceVariant;

    final bgColor = highlight
        ? effectiveColor.withValues(alpha: isDark ? 0.14 : 0.08)
        : (isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.035));

    final borderColor = highlight
        ? effectiveColor.withValues(alpha: 0.3)
        : colorScheme.outlineVariant.withValues(alpha: 0.3);

    final textColor = highlight
        ? effectiveColor
        : colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      // ✅ Techo de ancho para no desbordar en mobile con emails/RIFs largos.
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: effectiveColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight:
                      highlight ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                  letterSpacing: highlight ? -0.1 : 0,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  IconData _iconoDocumento(String? tipo) {
    switch (tipo) {
      case 'J':
        return Icons.storefront_rounded;
      case 'G':
        return Icons.account_balance_rounded;
      case 'P':
        return Icons.flight_takeoff_rounded;
      case 'C':
        return Icons.groups_rounded;
      case 'V':
      case 'E':
      default:
        return Icons.badge_rounded;
    }
  }
}