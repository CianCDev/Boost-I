import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class EmpleadosPorDepartamentoDialog extends ConsumerWidget {
  final int localId;

  const EmpleadosPorDepartamentoDialog({super.key, required this.localId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empleadosAsync = ref.watch(empleadosPorLocalProvider(localId));
    final departamentosAsync = ref.watch(departamentosActivosProvider(localId));
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Empleados por Departamento',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // CONTENIDO
            Expanded(
              child: empleadosAsync.when(
                data: (empleados) {
                  if (empleados.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: colorScheme.outline),
                          const SizedBox(height: 12),
                          Text(
                            'No hay empleados en este local.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }

                  return departamentosAsync.when(
                    data: (departamentos) {
                      final Map<int, String> deptosMap = {for (var d in departamentos) d.id: d.nombre};
                      final Map<String?, List<UsuarioEntity>> agrupados = {};

                      for (var u in empleados) {
                        // Asumiendo que UsuarioEntity tiene 'departamentoId' (puedes usar 'departamento' legacy)
                        final deptoId = u.departamentoId; // ← usa el campo que tengas
                        final key = deptoId != null ? deptosMap[deptoId] : null;
                        agrupados.putIfAbsent(key, () => []).add(u);
                      }

                      // Si no hay departamentoId, usar 'departamento' (legacy)
                      // Como fallback, agrupamos por 'departamento' si existe
                      if (agrupados.isEmpty && empleados.isNotEmpty) {
                        for (var u in empleados) {
                          final key = u.departamento != null && u.departamento!.isNotEmpty
                              ? u.departamento
                              : 'Sin departamento';
                          agrupados.putIfAbsent(key, () => []).add(u);
                        }
                      }

                      final keys = agrupados.keys.toList()
                        ..sort((a, b) {
                          if (a == null) return 1;
                          if (b == null) return -1;
                          return a.compareTo(b);
                        });

                      return ListView.builder(
                        itemCount: keys.length,
                        itemBuilder: (context, index) {
                          final deptoNombre = keys[index] ?? 'Sin departamento';
                          final lista = agrupados[keys[index]]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  deptoNombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              ...lista.map((u) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    child: Text(
                                      u.nombre.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF8B5CF6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    u.nombre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  subtitle: Text(
                                    'Rol: ${u.rol}',
                                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: u.activo ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: u.activo ? Colors.green : Colors.red,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      u.activo ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: u.activo ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const Divider(height: 1),
                            ],
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error al cargar departamentos: $err')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error al cargar empleados: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}