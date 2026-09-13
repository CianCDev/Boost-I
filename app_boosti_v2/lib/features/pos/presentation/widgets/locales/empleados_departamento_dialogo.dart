// lib/features/pos/presentation/widgets/locales/empleados_departamento_dialogo.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';

class EmpleadosPorDepartamentoDialog extends ConsumerWidget {
  final int localId;

  const EmpleadosPorDepartamentoDialog({super.key, required this.localId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empleadosAsync = ref.watch(empleadosPorLocalProvider(localId));
    final departamentosAsync = ref.watch(departamentosActivosProvider(localId));
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return GlassDialog(
      maxWidth: 500,
      maxHeightFactor: 0.8,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.people_rounded,
              title: 'Empleados por Departamento',
              subtitle: 'Organización del personal',
            ),
            const SizedBox(height: 16),
            Flexible(
              child: empleadosAsync.when(
                data: (empleados) {
                  if (empleados.isEmpty) {
                    return _emptyState('No hay empleados en este local',
                        colorScheme);
                  }

                  return departamentosAsync.when(
                    data: (departamentos) {
                      final agrupados = _agrupar(
                        empleados: empleados,
                        departamentos: departamentos,
                      );

                      if (agrupados.isEmpty) {
                        return _emptyState(
                            'Sin datos para agrupar', colorScheme);
                      }

                      return ListView.builder(
                        itemCount: agrupados.length,
                        itemBuilder: (context, index) {
                          final entry = agrupados.entries.elementAt(index);
                          return _DepartamentoGroup(
                            nombre: entry.key,
                            empleados: entry.value,
                            colorScheme: colorScheme,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text('Error: $err')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String text, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  /// Agrupa empleados por nombre de departamento.
  Map<String, List<UsuarioEntity>> _agrupar({
    required List<UsuarioEntity> empleados,
    required List<dynamic> departamentos,
  }) {
    final Map<int, String> deptosMap = {
      for (var d in departamentos) d.id as int: d.nombre as String,
    };
    final Map<String, List<UsuarioEntity>> agrupados = {};

    for (final u in empleados) {
      final deptoId = u.departamentoId;
      String key;
      if (deptoId != null && deptosMap.containsKey(deptoId)) {
        key = deptosMap[deptoId]!;
      } else if (u.departamento != null && u.departamento!.isNotEmpty) {
        key = u.departamento!;
      } else {
        key = 'Sin departamento';
      }
      agrupados.putIfAbsent(key, () => []).add(u);
    }

    // Orden: primero los que tienen departamento, "Sin departamento" al final
    final sorted = Map.fromEntries(
      agrupados.entries.toList()
        ..sort((a, b) {
          if (a.key == 'Sin departamento') return 1;
          if (b.key == 'Sin departamento') return -1;
          return a.key.compareTo(b.key);
        }),
    );

    return sorted;
  }
}

class _DepartamentoGroup extends StatelessWidget {
  final String nombre;
  final List<UsuarioEntity> empleados;
  final ColorScheme colorScheme;

  const _DepartamentoGroup({
    required this.nombre,
    required this.empleados,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF8B5CF6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                label: '${empleados.length}',
                color: const Color(0xFF8B5CF6),
                size: StatusBadgeSize.small,
              ),
            ],
          ),
        ),
        ...empleados.map((u) => _EmpleadoRow(empleado: u)),
        Divider(
          height: 12,
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

class _EmpleadoRow extends StatelessWidget {
  final UsuarioEntity empleado;

  const _EmpleadoRow({required this.empleado});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activo = empleado.activo;
    final estadoColor =
        activo ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor:
                const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            child: Text(
              empleado.nombre.isNotEmpty
                  ? empleado.nombre[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empleado.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Rol: ${empleado.rol}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: activo ? 'Activo' : 'Inactivo',
            color: estadoColor,
            size: StatusBadgeSize.small,
          ),
        ],
      ),
    );
  }
}