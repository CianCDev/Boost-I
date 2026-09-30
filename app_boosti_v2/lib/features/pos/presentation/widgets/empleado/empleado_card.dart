// lib/features/pos/presentation/widgets/empleado/empleado_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/Local/entities/empleado_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/permissions/roles.dart';

enum EmployeeCardMode { detailed, compact }

class EmployeeCard extends StatefulWidget {
  final UsuarioEntity usuario;
  final EmpleadoInfoEntity? info;
  final EmployeeCardMode mode;
  final bool showEmail;
  final bool showActivity;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final VoidCallback? onDelete;

  const EmployeeCard({
    super.key,
    required this.usuario,
    this.info,
    this.mode = EmployeeCardMode.detailed,
    this.showEmail = true,
    this.showActivity = true,
    this.onTap,
    this.onEdit,
    this.onToggleActive,
    this.onDelete,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  bool _hovered = false;

  UsuarioEntity get u => widget.usuario;
  EmpleadoInfoEntity? get info => widget.info;

  bool get _hasActions =>
      widget.onEdit != null ||
      widget.onToggleActive != null ||
      widget.onDelete != null;

  // ═══════════════════════════════════════════════════════════
  // COLORES
  // ═══════════════════════════════════════════════════════════

  Color get _rolColor {
    final r = u.rol.toLowerCase();
    if (r.contains('admin')) return const Color(0xFF8B5CF6);
    if (r.contains('super')) return const Color(0xFF6366F1);
    if (r.contains('cajer')) return const Color(0xFF14B8A6);
    if (r.contains('almac')) return const Color(0xFFEC4899);
    if (r.contains('rrhh')) return const Color(0xFF10B981);
    if (r.contains('auditor')) return const Color(0xFF64748B);
    if (r.contains('soporte')) return const Color(0xFF6366F1);
    if (r.contains('dev')) return const Color(0xFF06B6D4);
    return const Color(0xFF64748B);
  }

  IconData get _rolIcon {
    final r = u.rol.toLowerCase();
    if (r.contains('admin')) return Icons.admin_panel_settings_rounded;
    if (r.contains('super')) return Icons.shield_rounded;
    if (r.contains('cajer')) return Icons.point_of_sale_rounded;
    if (r.contains('almac')) return Icons.inventory_2_rounded;
    if (r.contains('rrhh')) return Icons.badge_rounded;
    if (r.contains('auditor')) return Icons.verified_rounded;
    if (r.contains('soporte')) return Icons.support_agent_rounded;
    if (r.contains('dev')) return Icons.terminal_rounded;
    return Icons.person_rounded;
  }

  String get _estadoEfectivo {
    final e = u.estado.toLowerCase().trim();
    if (e == 'descanso') return 'descanso';
    if (e == 'inactivo') return 'inactivo';
    if (e == 'desconectado') return 'inactivo';
    if (!u.activo) return 'inactivo';
    return 'activo';
  }

  Color get _estadoColor => switch (_estadoEfectivo) {
        'inactivo' => const Color(0xFFEF4444),
        'descanso' => const Color(0xFFF59E0B),
        _ => const Color(0xFF10B981),
      };

  String get _estadoLabel => switch (_estadoEfectivo) {
        'inactivo' => 'Inactivo',
        'descanso' => 'En descanso',
        _ => 'Activo',
      };

  String get _rolLabel => UserRole.fromString(u.rol).label;

  String get _initials {
    final parts = u.nombre.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get _cargoOCaja {
    final cargo = info?.cargo;
    if (cargo != null && cargo.isNotEmpty) return cargo;
    if (u.cajaAsignada.isNotEmpty) return u.cajaAsignada;
    return _rolLabel;
  }

  String? get _actividad {
    if (!widget.showActivity) return null;
    final ultima = u.ultimaActividad;
    if (ultima == null) return null;

    final diff = DateTime.now().difference(ultima);
    if (diff.inMinutes < 5) return 'En línea ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hoy ${DateFormat('HH:mm').format(ultima)}';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 30) return 'Hace ${diff.inDays} días';
    return DateFormat('dd/MM/yyyy').format(ultima);
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return widget.mode == EmployeeCardMode.detailed
        ? _buildDetailed(context)
        : _buildCompact(context);
  }

  // ═══════════════════════════════════════════════════════════
  // DETALLADA
  // ═══════════════════════════════════════════════════════════

  Widget _buildDetailed(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _rolColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('emp_card_${u.id}'),
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh
                      .withValues(alpha: _hovered ? 0.95 : 0.75)
                  : Colors.white.withValues(alpha: _hovered ? 1.0 : 0.97),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? accent.withValues(alpha: 0.45)
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.2 : (_hovered ? 0.10 : 0.05),
                  ),
                  blurRadius: _hovered ? 18 : 10,
                  offset: Offset(0, _hovered ? 6 : 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: _buildAvatar(size: 64, accent: accent)),
                const SizedBox(height: 8),
                Text(
                  u.nombre,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.showEmail && (u.email ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    u.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [_rolBadge(accent), _estadoBadge()],
                ),
                if (_hasActions) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 6),
                ],
                _contextRow(colorScheme),
                if (_actividad != null) ...[
                  const SizedBox(height: 2),
                  _activityRow(colorScheme),
                ],
                if (_hasActions) ...[
                  const Spacer(),
                  _actionsRow(colorScheme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMPACTA
  // ═══════════════════════════════════════════════════════════

  Widget _buildCompact(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _rolColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('emp_card_${u.id}'),
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh
                      .withValues(alpha: _hovered ? 0.95 : 0.75)
                  : Colors.white.withValues(alpha: _hovered ? 1.0 : 0.97),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? accent.withValues(alpha: 0.45)
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.15 : (_hovered ? 0.08 : 0.04),
                  ),
                  blurRadius: _hovered ? 14 : 8,
                  offset: Offset(0, _hovered ? 5 : 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🎯 UX FIX: Aumento de avatar de 48 a 72 para aprovechar el espacio
                      Center(child: _buildAvatar(size: 72, accent: accent)),
                      const SizedBox(height: 10),
                      Text(
                        u.nombre,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.15,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: _rolBadgeCompact(accent)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: _estadoCompact(colorScheme)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_hasActions)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _compactMenuButton(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AVATAR
  // ═══════════════════════════════════════════════════════════

  Widget _buildAvatar({required double size, required Color accent}) {
    final tieneFoto = u.fotoUrl != null && u.fotoUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, Color.lerp(accent, Colors.black, 0.25)!],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              color: Colors.white,
              child: tieneFoto
                  ? Image.network(
                      u.fotoUrl!,
                      key: ValueKey(u.fotoUrl),
                      fit: BoxFit.cover,
                      cacheWidth: (size * 3).toInt(),
                      errorBuilder: (_, __, ___) => _initialsAvatar(accent),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _initialsAvatar(accent);
                      },
                    )
                  : _initialsAvatar(accent),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.22,
            height: size * 0.22,
            decoration: BoxDecoration(
              color: _estadoColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _estadoColor.withValues(alpha: 0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialsAvatar(Color accent) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, Color.lerp(accent, Colors.black, 0.3)!],
        ),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BADGES
  // ═══════════════════════════════════════════════════════════

  Widget _rolBadge(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_rolIcon, size: 11, color: accent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _rolLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: accent,
                letterSpacing: 0.4,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rolBadgeCompact(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _rolLabel.toUpperCase(),
        style: TextStyle(
          fontSize: 9.0,
          fontWeight: FontWeight.w800,
          color: accent,
          letterSpacing: 0.4,
          height: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _estadoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _estadoColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _estadoColor.withValues(alpha: 0.28)),
      ),
      child: Text(
        _estadoLabel.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: _estadoColor,
          letterSpacing: 0.4,
          height: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _estadoCompact(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _estadoColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _estadoColor.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            _estadoLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _estadoColor,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONTEXTO Y ACTIVIDAD
  // ═══════════════════════════════════════════════════════════

  Widget _contextRow(ColorScheme colorScheme) {
    final esCargo = info?.cargo != null && info!.cargo!.isNotEmpty;
    return Row(
      children: [
        Icon(
          esCargo ? Icons.work_outline_rounded : Icons.point_of_sale_rounded,
          size: 13,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _cargoOCaja,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _activityRow(ColorScheme colorScheme) {
    final isEnLinea = _actividad == 'En línea ahora';
    return Row(
      children: [
        Icon(
          isEnLinea ? Icons.bolt_rounded : Icons.schedule_rounded,
          size: 13,
          color: isEnLinea ? _estadoColor : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _actividad!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isEnLinea ? FontWeight.w700 : FontWeight.w500,
              color: isEnLinea ? _estadoColor : colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ACCIONES
  // ═══════════════════════════════════════════════════════════

  Widget _actionsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        if (widget.onEdit != null)
          Expanded(
            child: _actionButton(
              icon: Icons.edit_outlined,
              label: 'Editar',
              color: const Color(0xFF3B82F6),
              onTap: widget.onEdit!,
            ),
          ),
        if (widget.onEdit != null && widget.onToggleActive != null)
          const SizedBox(width: 6),
        if (widget.onToggleActive != null)
          _iconActionButton(
            icon: u.activo
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            color: u.activo ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
            tooltip: u.activo ? 'Desactivar' : 'Activar',
            onTap: widget.onToggleActive!,
          ),
        if (widget.onDelete != null) ...[
          const SizedBox(width: 6),
          _iconActionButton(
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFFEF4444),
            tooltip: 'Eliminar',
            onTap: widget.onDelete!,
          ),
        ],
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: color),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MENÚ COMPACTO
  // ═══════════════════════════════════════════════════════════

  Widget _compactMenuButton(BuildContext context) {
    return Builder(
      builder: (btnContext) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showCompactMenu(btnContext),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Tooltip(
                message: 'Más acciones',
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _hovered
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _rolColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 16,
                    color: _rolColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCompactMenu(BuildContext btnContext) {
    final RenderBox button = btnContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: btnContext,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        if (widget.onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 16, color: Color(0xFF3B82F6)),
                SizedBox(width: 10),
                Text('Editar', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        if (widget.onToggleActive != null)
          PopupMenuItem(
            value: 'toggle',
            height: 40,
            child: Row(
              children: [
                Icon(
                  u.activo
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 16,
                  color: u.activo
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 10),
                Text(
                  u.activo ? 'Desactivar' : 'Activar',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        if (widget.onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    size: 16, color: Color(0xFFEF4444)),
                SizedBox(width: 10),
                Text(
                  'Eliminar',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value == 'edit') widget.onEdit?.call();
      if (value == 'toggle') widget.onToggleActive?.call();
      if (value == 'delete') widget.onDelete?.call();
    });
  }
}