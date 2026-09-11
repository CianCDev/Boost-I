// lib/features/pos/presentation/widgets/locales/detalle_local_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final Color estadoColor = local.activo ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                _buildHeader(isDark, isMobile, estadoColor, local),
                const SizedBox(height: 16),
                // TABS
                _buildTabs(isDark, isMobile),
                const SizedBox(height: 12),
                // CONTENIDO DE TABS
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(isDark, local),
                      _buildEmpleadosTab(isDark, isMobile, local),
                      _buildDepartamentosTab(isDark, isMobile, local),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // NOTA INFORMATIVA (fuera de las pestañas, pero reducida)
                _buildNote(isDark),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(bool isDark, bool isMobile, Color estadoColor, LocalEntity local) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 24,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      local.activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 11,
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
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABS
  // ============================================================
  Widget _buildTabs(bool isDark, bool isMobile) {
    final textStyle = TextStyle(
      fontSize: isMobile ? 13 : 15,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white70 : Colors.black54,
    );
    final selectedStyle = TextStyle(
      fontSize: isMobile ? 13 : 15,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF8B5CF6),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: const Color(0xFF8B5CF6),
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
        labelStyle: selectedStyle,
        unselectedLabelStyle: textStyle,
        tabs: const [
          Tab(icon: Icon(Icons.info_rounded, size: 20), text: 'Información'),
          Tab(icon: Icon(Icons.people_rounded, size: 20), text: 'Empleados'),
          Tab(icon: Icon(Icons.business_center_rounded, size: 20), text: 'Departamentos'),
        ],
      ),
    );
  }

  // ============================================================
  // PESTAÑA: INFORMACIÓN
  // ============================================================
  Widget _buildInfoTab(bool isDark, LocalEntity local) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildInfoTile(Icons.location_on_rounded, 'Dirección', local.direccion ?? 'No registrada', isDark),
          _buildDivider(isDark),
          _buildInfoTile(Icons.phone_rounded, 'Teléfono', local.telefono ?? 'No registrado', isDark),
          _buildDivider(isDark),
          _buildInfoTile(Icons.email_rounded, 'Correo', local.email ?? 'No registrado', isDark),
          if (local.rif != null && local.rif!.isNotEmpty) ...[
            _buildDivider(isDark),
            _buildInfoTile(Icons.assignment_rounded, 'RIF', local.rif!, isDark),
          ],
          if (local.createdAt != null) ...[
            _buildDivider(isDark),
            _buildInfoTile(Icons.calendar_today_rounded, 'Creado',
                '${local.createdAt!.day}/${local.createdAt!.month}/${local.createdAt!.year}', isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
      indent: 60,
      endIndent: 16,
    );
  }

  // ============================================================
  // PESTAÑA: EMPLEADOS
  // ============================================================
  Widget _buildEmpleadosTab(bool isDark, bool isMobile, LocalEntity local) {
    final empleadosAsync = ref.watch(empleadosPorLocalProvider(local.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón agregar (siempre visible)
        Align(
          alignment: Alignment.centerRight,
          child: _buildActionButton(
            icon: Icons.person_add_rounded,
            label: isMobile ? '' : 'Agregar',
            onPressed: () => _agregarEmpleado(local),
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            isMobile: isMobile,
            iconOnly: isMobile,
          ),
        ),
        const SizedBox(height: 8),
        // Lista de empleados
        Expanded(
          child: empleadosAsync.when(
            data: (empleados) {
              if (empleados.isEmpty) {
                return Center(
                  child: Text(
                    'No hay empleados asignados.',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  ),
                );
              }
              return ListView.separated(
                itemCount: empleados.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
                ),
                itemBuilder: (context, index) {
                  final u = empleados[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      child: Text(
                        u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
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
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      'Rol: ${u.rol}',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444)),
                      onPressed: () => _desasignarEmpleado(u),
                      tooltip: 'Desasignar',
                      padding: isMobile ? const EdgeInsets.all(8) : EdgeInsets.zero,
                      constraints: isMobile
                          ? const BoxConstraints(minWidth: 44, minHeight: 44)
                          : const BoxConstraints(minWidth: 32, minHeight: 32),
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
    );
  }

  // ============================================================
  // PESTAÑA: DEPARTAMENTOS
  // ============================================================
  Widget _buildDepartamentosTab(bool isDark, bool isMobile, LocalEntity local) {
    final departamentosAsync = ref.watch(departamentosActivosProvider(local.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón agregar (siempre visible)
        Align(
          alignment: Alignment.centerRight,
          child: _buildActionButton(
            icon: Icons.add_rounded,
            label: isMobile ? '' : 'Agregar',
            onPressed: () => _agregarDepartamento(local),
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            isMobile: isMobile,
            iconOnly: isMobile,
          ),
        ),
        const SizedBox(height: 8),
        // Lista de departamentos
        Expanded(
          child: departamentosAsync.when(
            data: (departamentos) {
              if (departamentos.isEmpty) {
                return Center(
                  child: Text(
                    'Sin departamentos asociados.',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  ),
                );
              }
              return ListView.separated(
                itemCount: departamentos.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
                ),
                itemBuilder: (context, index) {
                  final d = departamentos[index];
                  final usuarioAsync = d.usuarioId != null
                      ? ref.watch(usuarioPorIdProvider(d.usuarioId!))
                      : const AsyncValue<UsuarioEntity?>.data(null);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
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
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: isMobile ? 14 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: d.descripcion != null && d.descripcion!.isNotEmpty
                        ? Text(
                            d.descripcion!,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
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
                                    color: isDark ? Colors.white54 : Colors.black54,
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
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NOTA INFORMATIVA (reducida)
  // ============================================================
  Widget _buildNote(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: const Color(0xFF8B5CF6), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gestiona empleados y departamentos desde las pestañas.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTÓN DE ACCIÓN (estilo departamentos)
  // ============================================================
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required bool isDark,
    required bool isMobile,
    bool iconOnly = false,
  }) {
    if (isMobile || iconOnly) {
      return IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        tooltip: label.isNotEmpty ? label : null,
        splashRadius: 24,
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(80, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  // ============================================================
  // ACCIONES (sin cambios)
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

    final disponibles = todos.where((u) {
      return u.localId == null || u.localId == 0 || !localesIds.contains(u.localId);
    }).toList();

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay empleados disponibles.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final seleccionados = await showDialog<List<int>>(
      context: context,
      builder: (context) => SeleccionarEmpleadosDialog(
        localId: local.id,
        empleadosDisponibles: disponibles,
      ),
    );

    if (seleccionados != null && seleccionados.isNotEmpty) {
      for (final empleadoId in seleccionados) {
        final empleado = await isar.obtenerUsuarioPorId(empleadoId);
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
          SnackBar(content: Text('${seleccionados.length} empleados asignados.'), backgroundColor: Colors.green),
        );
        setState(() {});
      }
    }
  }

  Future<void> _desasignarEmpleado(UsuarioEntity usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
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
      setState(() {});
    }
  }

  Future<void> _agregarDepartamento(LocalEntity local) async {
    final result = await showDialog<DepartamentoEntity>(
      context: context,
      builder: (context) => SeleccionarDepartamentoDialog(localId: local.id),
    );
    if (result != null) {
      ref.invalidate(departamentosActivosProvider(local.id));
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