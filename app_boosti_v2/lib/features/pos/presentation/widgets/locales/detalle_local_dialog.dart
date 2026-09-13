// lib/features/pos/presentation/widgets/locales/detalle_local_dialog.dart
// ignore_for_file: use_build_context_synchronously

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
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';
import '../dialogos_genericos/dialogos_genericos.dart';
import 'seleccionar_departamento_dialog.dart';
import 'seleccionar_empleados_dialog.dart';

class DetalleLocalDialog extends ConsumerStatefulWidget {
  final LocalEntity local;

  const DetalleLocalDialog({super.key, required this.local});

  @override
  ConsumerState<DetalleLocalDialog> createState() => _DetalleLocalDialogState();
}

class _DetalleLocalDialogState extends ConsumerState<DetalleLocalDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = widget.local;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final estadoColor = local.activo ? _colorSuccess : _colorDanger;

    return GlassDialog(
      maxWidth: 600,
      maxHeightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.storefront_rounded,
              title: local.nombre,
              subtitle: local.supabaseId != null
                  ? 'ID: ${local.supabaseId!.substring(0, 8)}...'
                  : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: local.activo ? 'Activo' : 'Inactivo',
                color: estadoColor,
                size: StatusBadgeSize.medium,
              ),
            ),
            const SizedBox(height: 16),
            _buildTabs(colorScheme, isMobile),
            const SizedBox(height: 12),
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInfoTab(local, colorScheme),
                  _buildEmpleadosTab(isMobile, local, colorScheme),
                  _buildDepartamentosTab(isMobile, local, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================
  Widget _buildTabs(ColorScheme colorScheme, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _colorPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _colorPrimary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: _colorPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontSize: isMobile ? 12 : 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: isMobile ? 12 : 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.info_rounded, size: 18), text: 'Info'),
          Tab(icon: Icon(Icons.people_rounded, size: 18), text: 'Empleados'),
          Tab(
              icon: Icon(Icons.business_center_rounded, size: 18),
              text: 'Deptos'),
        ],
      ),
    );
  }

  // ============================================================
  // TAB: INFORMACIÓN
  // ============================================================
  Widget _buildInfoTab(LocalEntity local, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _infoTile(Icons.location_on_rounded, 'Dirección',
              local.direccion ?? 'No registrada', colorScheme),
          _divider(colorScheme),
          _infoTile(Icons.phone_rounded, 'Teléfono',
              local.telefono ?? 'No registrado', colorScheme),
          _divider(colorScheme),
          _infoTile(Icons.email_rounded, 'Correo',
              local.email ?? 'No registrado', colorScheme),
          if (local.rif?.isNotEmpty ?? false) ...[
            _divider(colorScheme),
            _infoTile(Icons.assignment_rounded, 'RIF', local.rif!, colorScheme),
          ],
          if (local.createdAt != null) ...[
            _divider(colorScheme),
            _infoTile(
              Icons.calendar_today_rounded,
              'Creado',
              '${local.createdAt!.day}/${local.createdAt!.month}/${local.createdAt!.year}',
              colorScheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
        ],
      ),
    );
  }

  Widget _divider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
      indent: 56,
    );
  }

  // ============================================================
  // TAB: EMPLEADOS
  // ============================================================
  Widget _buildEmpleadosTab(
      bool isMobile, LocalEntity local, ColorScheme colorScheme) {
    final empleadosAsync = ref.watch(empleadosPorLocalProvider(local.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _actionButton(
            icon: Icons.person_add_rounded,
            label: isMobile ? '' : 'Agregar',
            onPressed: () => _agregarEmpleado(local),
            iconOnly: isMobile,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: empleadosAsync.when(
            data: (empleados) {
              if (empleados.isEmpty) {
                return _emptyState(
                    'No hay empleados asignados', colorScheme);
              }
              return ListView.separated(
                itemCount: empleados.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final u = empleados[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: _colorPrimary.withValues(alpha: 0.1),
                      child: Text(
                        u.nombre.isNotEmpty
                            ? u.nombre[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: _colorPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      u.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      'Rol: ${u.rol}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded,
                            color: _colorDanger, size: 20),
                        onPressed: () => _desasignarEmpleado(u),
                        tooltip: 'Desasignar',
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAB: DEPARTAMENTOS
  // ============================================================
  Widget _buildDepartamentosTab(
      bool isMobile, LocalEntity local, ColorScheme colorScheme) {
    final departamentosAsync =
        ref.watch(departamentosActivosProvider(local.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _actionButton(
            icon: Icons.add_rounded,
            label: isMobile ? '' : 'Agregar',
            onPressed: () => _agregarDepartamento(local),
            iconOnly: isMobile,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: departamentosAsync.when(
            data: (departamentos) {
              if (departamentos.isEmpty) {
                return _emptyState(
                    'Sin departamentos asociados', colorScheme);
              }
              return ListView.separated(
                itemCount: departamentos.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final d = departamentos[index];
                  return _DepartamentoLocalTile(
                    departamento: d,
                    colorScheme: colorScheme,
                    onTap: () => _mostrarDetalleDepartamento(d),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String text, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool iconOnly = false,
  }) {
    if (iconOnly) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          icon: const Icon(Icons.add_circle_rounded,
              color: _colorPrimary, size: 32),
          onPressed: onPressed,
          tooltip: label,
        ),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================
  Future<void> _agregarEmpleado(LocalEntity local) async {
    try {
      await SyncService().sincronizarUsuariosDesdeSupabase();
      ref.invalidate(usuariosProvider);
    } catch (_) {}

    final isar = IsarService();
    final todos = await isar.obtenerUsuariosActivos();
    final locales = await isar.obtenerLocales(soloActivos: false);
    final localesIds = locales.map((l) => l.id).toSet();

    final disponibles = todos
        .where((u) =>
            u.localId == null ||
            u.localId == 0 ||
            !localesIds.contains(u.localId))
        .toList();

    if (disponibles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay empleados disponibles.'),
            backgroundColor: Color(0xFFF59E0B),
          ),
        );
      }
      return;
    }

    final seleccionados = await showDialog<List<int>>(
      context: context,
      builder: (_) => SeleccionarEmpleadosDialog(
        localId: local.id,
        empleadosDisponibles: disponibles,
      ),
    );

    if (seleccionados != null && seleccionados.isNotEmpty) {
      for (final id in seleccionados) {
        final empleado = await isar.obtenerUsuarioPorId(id);
        if (empleado != null) {
          empleado.localId = local.id;
          await isar.guardarUsuario(empleado);
        }
      }
      await SyncService().sincronizarUsuariosASupabase();
      ref.invalidate(empleadosPorLocalProvider(local.id));
      ref.invalidate(usuariosProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${seleccionados.length} empleados asignados.'),
            backgroundColor: _colorSuccess,
          ),
        );
        setState(() {});
      }
    }
  }

  Future<void> _desasignarEmpleado(UsuarioEntity usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Desasignar empleado',
        content: '¿Quitar a "${usuario.nombre}" de este local?',
        confirmText: 'Desasignar',
        confirmColor: const Color(0xFFF59E0B),
        onConfirm: () {},
      ),
    );

    if (confirm == true) {
      usuario.localId = null;
      await IsarService().guardarUsuario(usuario);
      ref.invalidate(empleadosPorLocalProvider(widget.local.id));
      if (mounted) setState(() {});
    }
  }

  Future<void> _agregarDepartamento(LocalEntity local) async {
    final result = await showDialog<DepartamentoEntity>(
      context: context,
      builder: (_) => SeleccionarDepartamentoDialog(localId: local.id),
    );
    if (result != null) {
      ref.invalidate(departamentosActivosProvider(local.id));
      if (mounted) setState(() {});
    }
  }

  void _mostrarDetalleDepartamento(DepartamentoEntity departamento) {
    showDialog(
      context: context,
      builder: (_) => DetalleDepartamentoDialog(departamento: departamento),
    );
  }
}

// ============================================================
// TILE DE DEPARTAMENTO DENTRO DEL LOCAL
// ============================================================
class _DepartamentoLocalTile extends ConsumerWidget {
  final DepartamentoEntity departamento;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _DepartamentoLocalTile({
    required this.departamento,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = departamento.usuarioId != null
        ? ref.watch(usuarioPorIdProvider(departamento.usuarioId!))
        : const AsyncValue<UsuarioEntity?>.data(null);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                child: const Icon(Icons.business_center_rounded,
                    size: 16, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departamento.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    usuarioAsync.when(
                      data: (u) => u != null
                          ? Text(
                              'Encargado: ${u.nombre}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}