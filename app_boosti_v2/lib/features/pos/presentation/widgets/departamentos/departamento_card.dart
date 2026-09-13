// lib/features/pos/presentation/widgets/departamentos/departamento_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';
import '../common/card_action_button.dart';

class DepartamentoCard extends ConsumerWidget {
  final DepartamentoEntity departamento;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback onDelete;

  const DepartamentoCard({
    super.key,
    required this.departamento,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final activo = departamento.activo;
    final estadoColor = activo ? _colorActivo : _colorInactivo;

    final localAsync = departamento.localId != null
        ? ref.watch(localPorIdProvider(departamento.localId!))
        : const AsyncValue<LocalEntity?>.data(null);
    final usuarioAsync = departamento.usuarioId != null
        ? ref.watch(usuarioPorIdProvider(departamento.usuarioId!))
        : const AsyncValue<UsuarioEntity?>.data(null);

    return GlassCard(
      onTap: onTap,
      showStatusBar: true,
      statusColor: estadoColor,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departamento.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (departamento.descripcion?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Text(
                        departamento.descripcion!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 8),
          _infoRow(
            Icons.storefront_rounded,
            localAsync.when(
              data: (l) => l?.nombre ?? 'Sin local asignado',
              loading: () => 'Cargando...',
              error: (_, __) => 'Error',
            ),
            colorScheme,
          ),
          usuarioAsync.when(
            data: (u) {
              if (u == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _infoRow(
                  Icons.person_outline_rounded,
                  'Encargado: ${u.nombre}',
                  colorScheme,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
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

  Widget _infoRow(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}