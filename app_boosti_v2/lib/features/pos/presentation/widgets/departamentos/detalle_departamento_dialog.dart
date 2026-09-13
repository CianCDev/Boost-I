// lib/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';
import 'crear_departamento_dialog.dart';

class DetalleDepartamentoDialog extends ConsumerWidget {
  final DepartamentoEntity departamento;

  const DetalleDepartamentoDialog({super.key, required this.departamento});

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAsync = departamento.localId != null
        ? ref.watch(localPorIdProvider(departamento.localId!))
        : const AsyncValue<LocalEntity?>.data(null);
    final usuarioAsync = departamento.usuarioId != null
        ? ref.watch(usuarioPorIdProvider(departamento.usuarioId!))
        : const AsyncValue<UsuarioEntity?>.data(null);
    final productosCount =
        ref.watch(productosPorDepartamentoProvider(departamento.id));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final activo = departamento.activo;
    final estadoColor = activo ? _colorSuccess : _colorDanger;

    return GlassDialog(
      maxWidth: 520,
      maxHeightFactor: 0.9,
      scrollable: true,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== HEADER =====
            DialogHeader(
              icon: Icons.business_center_rounded,
              title: departamento.nombre,
              subtitle: departamento.supabaseId != null
                  ? 'ID: ${departamento.supabaseId!.substring(0, 8)}...'
                  : null,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: activo ? 'Activo' : 'Inactivo',
                color: estadoColor,
                size: StatusBadgeSize.medium,
              ),
            ),
            const SizedBox(height: 20),

            // ===== INFO SECTION =====
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  _infoTile(
                    Icons.description_rounded,
                    'Descripción',
                    departamento.descripcion?.isNotEmpty == true
                        ? departamento.descripcion!
                        : 'Sin descripción',
                    colorScheme,
                  ),
                  _divider(colorScheme),
                  _infoTile(
                    Icons.storefront_rounded,
                    'Local asociado',
                    localAsync.when(
                      data: (l) => l?.nombre ?? 'Sin local asignado',
                      loading: () => 'Cargando...',
                      error: (_, __) => 'Error',
                    ),
                    colorScheme,
                  ),
                  _divider(colorScheme),
                  _infoTile(
                    Icons.person_rounded,
                    'Encargado',
                    usuarioAsync.when(
                      data: (u) =>
                          u != null ? '${u.nombre} (${u.rol})' : 'Sin encargado',
                      loading: () => 'Cargando...',
                      error: (_, __) => 'Error',
                    ),
                    colorScheme,
                    trailingAvatar:
                        usuarioAsync.whenOrNull(data: (u) => u),
                  ),
                  _divider(colorScheme),
                  _infoTile(
                    Icons.inventory_2_rounded,
                    'Productos',
                    productosCount.when(
                      data: (count) => count > 0
                          ? '$count productos enlazados'
                          : 'Sin productos',
                      loading: () => 'Cargando...',
                      error: (_, __) => 'Error',
                    ),
                    colorScheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== NOTA =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _colorPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _colorPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _colorPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: _colorPrimary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Los productos de este departamento se pueden gestionar desde el inventario.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== BOTONES =====
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => CrearDepartamentoDialog(
                            departamento: departamento,
                            localIdPreseleccionado: departamento.localId,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Editar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToggleActivoButton(
                    activo: activo,
                    onConfirm: (nuevoEstado) => _toggleActivo(
                      context,
                      ref,
                      nuevoEstado,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    UsuarioEntity? trailingAvatar,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: _colorPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trailingAvatar != null) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: _colorPrimary.withValues(alpha: 0.15),
              child: Text(
                trailingAvatar.nombre.isNotEmpty
                    ? trailingAvatar.nombre[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: _colorPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
      indent: 56,
      endIndent: 16,
    );
  }

  Future<void> _toggleActivo(
    BuildContext context,
    WidgetRef ref,
    bool nuevoEstado,
  ) async {
    try {
      final actualizado = DepartamentoEntity()
        ..id = departamento.id
        ..nombre = departamento.nombre
        ..descripcion = departamento.descripcion
        ..localId = departamento.localId
        ..usuarioId = departamento.usuarioId
        ..activo = nuevoEstado
        ..supabaseId = departamento.supabaseId
        ..sincronizado = false;

      await ref.read(guardarDepartamentoProvider(actualizado).future);

      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) =>
              DetalleDepartamentoDialog(departamento: actualizado),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Error: $e'),
            backgroundColor: _colorDanger,
          ),
        );
      }
    }
  }
}

// ============================================================
// BOTÓN TOGGLE ACTIVO
// ============================================================
class _ToggleActivoButton extends StatefulWidget {
  final bool activo;
  final Future<void> Function(bool nuevoEstado) onConfirm;

  const _ToggleActivoButton({
    required this.activo,
    required this.onConfirm,
  });

  @override
  State<_ToggleActivoButton> createState() => _ToggleActivoButtonState();
}

class _ToggleActivoButtonState extends State<_ToggleActivoButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.activo
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return MouseRegion(
      cursor: _loading
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: _loading
            ? null
            : () async {
                setState(() => _loading = true);
                await widget.onConfirm(!widget.activo);
                if (mounted) setState(() => _loading = false);
              },
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                widget.activo
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                size: 18,
              ),
        label: Text(
          _loading
              ? 'Procesando'
              : (widget.activo ? 'Desactivar' : 'Activar'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}