import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../dialogos_genericos/dialogos_genericos.dart';
import 'empleados_departamento_dialogo.dart';
import 'seleccionar_departamento_dialog.dart';

class DetalleLocalDialog extends ConsumerStatefulWidget {
  final LocalEntity local;

  const DetalleLocalDialog({super.key, required this.local});

  @override
  ConsumerState<DetalleLocalDialog> createState() => _DetalleLocalDialogState();
}

class _DetalleLocalDialogState extends ConsumerState<DetalleLocalDialog> {
  @override
  Widget build(BuildContext context) {
    final local = widget.local;
    final departamentosAsync = ref.watch(departamentosActivosProvider(local.id));
    final empleadosAsync = ref.watch(empleadosPorLocalProvider(local.id));
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final Color estadoColor = local.activo ? Colors.green.shade500 : Colors.red.shade400;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== HEADER ==========
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: const Color(0xFF8B5CF6),
                    size: isMobile ? 24 : 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : 22,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: estadoColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              local.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: estadoColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (local.supabaseId != null)
                            Text(
                              'ID: ${local.supabaseId!.substring(0, 8)}...',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ========== INFORMACIÓN ==========
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.location_on_rounded,
                    'Dirección',
                    local.direccion ?? 'No registrada',
                    colorScheme,
                    isMobile,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    Icons.phone_rounded,
                    'Teléfono',
                    local.telefono ?? 'No registrado',
                    colorScheme,
                    isMobile,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    Icons.email_rounded,
                    'Correo',
                    local.email ?? 'No registrado',
                    colorScheme,
                    isMobile,
                  ),
                  if (local.rif != null && local.rif!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      context,
                      Icons.assignment_rounded,
                      'RIF',
                      local.rif!,
                      colorScheme,
                      isMobile,
                    ),
                  ],
                  if (local.createdAt != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today_rounded,
                      'Creado',
                      '${local.createdAt!.day}/${local.createdAt!.month}/${local.createdAt!.year}',
                      colorScheme,
                      isMobile,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ========== EMPLEADOS ==========
            Row(
              children: [
                Icon(Icons.people_rounded, color: const Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Empleados del local',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ Contador de empleados
                empleadosAsync.when(
                  data: (empleados) => Text(
                    '(${empleados.length})',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                // ✅ Botón "Ver todos"
                if (!isMobile)
                  _buildAdaptiveButton(
                    context,
                    icon: Icons.visibility_rounded,
                    label: 'Ver todos',
                    onPressed: () => _mostrarEmpleadosPorDepartamento(),
                    color: Colors.grey.shade600,
                    isMobile: isMobile,
                  ),
                const SizedBox(width: 8),
                // Botón "Agregar"
                _buildAdaptiveButton(
                  context,
                  icon: Icons.person_add_rounded,
                  label: 'Agregar',
                  onPressed: () => _agregarEmpleado(),
                  color: const Color(0xFF8B5CF6),
                  isMobile: isMobile,
                ),
              ],
            ),
            const SizedBox(height: 10),
            empleadosAsync.when(
              data: (empleados) {
                if (empleados.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No hay empleados asignados a este local.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 120),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: empleados.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = empleados[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_outline_rounded, size: 18),
                        title: Text(
                          u.nombre,
                          style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          'Rol: ${u.rol}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                          onPressed: () => _desasignarEmpleado(u),
                          tooltip: 'Desasignar',
                          padding: isMobile ? const EdgeInsets.all(8) : EdgeInsets.zero,
                          constraints: isMobile
                              ? const BoxConstraints(minWidth: 44, minHeight: 44)
                              : const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 16),

            // ========== DEPARTAMENTOS ==========
            Row(
              children: [
                Icon(Icons.business_center_rounded, color: const Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Departamentos asociados',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                _buildAdaptiveButton(
                  context,
                  icon: Icons.add_rounded,
                  label: 'Agregar',
                  onPressed: () => _agregarDepartamento(),
                  color: const Color(0xFF8B5CF6),
                  isMobile: isMobile,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: departamentosAsync.when(
                data: (departamentos) {
                  if (departamentos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sin departamentos',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Agrega un departamento a este local',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: departamentos.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = departamentos[index];
                      final usuarioAsync = d.usuarioId != null
                          ? ref.watch(usuarioPorIdProvider(d.usuarioId!))
                          : const AsyncValue<UsuarioEntity?>.data(null);

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            child: Icon(
                              Icons.business_center_rounded,
                              size: 16,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          title: Text(
                            d.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              fontSize: isMobile ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: d.descripcion != null && d.descripcion!.isNotEmpty
                              ? Text(
                                  d.descripcion!,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: isMobile ? 12 : 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              usuarioAsync.when(
                                data: (usuario) {
                                  if (usuario != null) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Tooltip(
                                        message: 'Encargado: ${usuario.nombre} (${usuario.rol})',
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          size: 16,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                loading: () => const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: d.activo ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: d.activo ? Colors.green : Colors.red,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  d.activo ? 'Activo' : 'Inactivo',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: d.activo ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.visibility_rounded, size: 18),
                                onPressed: () => _mostrarDetalleDepartamento(d),
                                tooltip: 'Ver detalles',
                                padding: isMobile ? const EdgeInsets.all(8) : EdgeInsets.zero,
                                constraints: isMobile
                                    ? const BoxConstraints(minWidth: 44, minHeight: 44)
                                    : const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ],
                          ),
                          onTap: () => _mostrarDetalleDepartamento(d),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== WIDGETS AUXILIARES ==========

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        SizedBox(
          width: isMobile ? 60 : 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 12 : 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isMobile ? 12 : 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required bool isMobile,
  }) {
    if (isMobile) {
      return IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        tooltip: label,
        splashRadius: 24,
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(80, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // ========== ACCIONES ==========

  void _mostrarEmpleadosPorDepartamento() {
    showDialog(
      context: context,
      builder: (_) => EmpleadosPorDepartamentoDialog(localId: widget.local.id),
    );
  }

  Future<void> _agregarEmpleado() async {
    // ✅ Forzar sincronización de usuarios desde Supabase para asegurar datos actualizados
    try {
      await SyncService().sincronizarUsuariosDesdeSupabase();
      ref.invalidate(usuariosProvider);
    } catch (e) {
      debugPrint('⚠️ Error al sincronizar usuarios: $e');
    }

    final isar = IsarService();
    final todos = await isar.obtenerUsuariosActivos();

    // Obtener IDs de locales existentes (incluyendo inactivos)
    final locales = await isar.obtenerLocales(soloActivos: false);
    final localesIds = locales.map((l) => l.id).toSet();

    // Filtrar empleados sin local asignado o con localId que ya no existe
    final disponibles = todos.where((u) {
      return u.localId == null ||
          u.localId == 0 ||
          !localesIds.contains(u.localId);
    }).toList();

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay empleados disponibles para asignar.'),
        ),
      );
      return;
    }

    final selected = await showDialog<UsuarioEntity>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Asignar empleado'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: disponibles.length,
              itemBuilder: (context, index) {
                final u = disponibles[index];
                return ListTile(
                  title: Text(u.nombre),
                  subtitle: Text('Rol: ${u.rol}'),
                  onTap: () => Navigator.pop(context, u),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      selected.localId = widget.local.id;
      await isar.guardarUsuario(selected);
      ref.invalidate(empleadosPorLocalProvider(widget.local.id));
      setState(() {});
    }
  }

  Future<void> _desasignarEmpleado(UsuarioEntity usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Desasignar empleado',
        content: '¿Quitar a "${usuario.nombre}" de este local?',
        confirmText: 'Desasignar',
        confirmColor: Colors.orange, onConfirm: () {  },
      ),
    );

    if (confirm == true) {
      usuario.localId = null;
      await IsarService().guardarUsuario(usuario);
      ref.invalidate(empleadosPorLocalProvider(widget.local.id));
      setState(() {});
    }
  }

  Future<void> _agregarDepartamento() async {
    final result = await showDialog<DepartamentoEntity>(
      context: context,
      builder: (context) => SeleccionarDepartamentoDialog(
        localId: widget.local.id,
      ),
    );

    if (result != null) {
      ref.invalidate(departamentosActivosProvider(widget.local.id));
      setState(() {});
    }
  }

  void _mostrarDetalleDepartamento(DepartamentoEntity departamento) {
    showDialog(
      context: context,
      builder: (_) => DetalleDepartamentoDialog(departamento: departamento),
    );
  }
}