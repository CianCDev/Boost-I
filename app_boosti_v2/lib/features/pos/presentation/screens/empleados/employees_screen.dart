// lib/features/pos/presentation/screens/empleados/employees_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:app_boosti_v2/features/pos/presentation/widgets/empleado/empleado_detail_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/empleado/employees_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/Local/entities/empleado_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/models/empleado_view_model.dart';
import '../../providers/empleados/monitor_empleados_provider.dart';
import '../../providers/isar_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/glass_search_bar.dart';
import '../../widgets/common/metric_pedido.dart';
import '../../widgets/common/segmented_toggle.dart';
import '../../widgets/empleado/empleado_card.dart';
import '../../widgets/empleado/empleado_form_dialog.dart';
import 'employees_enums.dart';


// ═══════════════════════════════════════════════════════════════
// PROVIDERS LOCALES
// ═══════════════════════════════════════════════════════════════

/// Mapa `usuarioId → EmpleadoInfoEntity`.
final empleadosInfoProvider =
    FutureProvider.autoDispose<Map<int, EmpleadoInfoEntity>>((ref) async {
  final isar = await IsarService().db;
  final infos = await isar.empleadoInfoEntitys.where().findAll();
  return {for (final i in infos) i.usuarioId: i};
});

// ═══════════════════════════════════════════════════════════════
// PANTALLA
// ═══════════════════════════════════════════════════════════════

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final AnimationController _fabController;

  String _searchQuery = '';
  EmployeeView _view = EmployeeView.detailed;
  EmployeeTab _tab = EmployeeTab.empleados;
  EmployeeFilter _filter = EmployeeFilter.todos;
  EmployeeSort _sort = EmployeeSort.nombre;
  String? _departamentoFiltro;
  bool _agruparPorDepartamento = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // FILTROS Y ORDEN
  // ════════════════════════════════════════════════════════════════

  bool _pasaFiltro(UsuarioEntity u, EmployeeFilter f) {
    final estado = estadoEfectivo(u);
    return switch (f) {
      EmployeeFilter.todos => true,
      EmployeeFilter.activos => estado == 'activo',
      EmployeeFilter.inactivos => estado == 'inactivo',
      EmployeeFilter.descanso => estado == 'descanso',
      EmployeeFilter.sinPin => u.pin.isEmpty,
    };
  }

  bool _coincideBusqueda(UsuarioEntity u, String q) {
    if (q.isEmpty) return true;
    return u.nombre.toLowerCase().contains(q) ||
        (u.email ?? '').toLowerCase().contains(q) ||
        (u.numeroDocumento ?? '').toLowerCase().contains(q) ||
        (u.telefono ?? '').toLowerCase().contains(q) ||
        u.rol.toLowerCase().contains(q);
  }

  bool _pasaDepartamento(UsuarioEntity u) {
    if (_departamentoFiltro == null) return true;
    final dept = (u.departamento ?? '').trim();
    if (_departamentoFiltro == '__none__') return dept.isEmpty;
    return dept == _departamentoFiltro;
  }

  List<UsuarioEntity> _aplicarFiltros(List<UsuarioEntity> usuarios) {
    final q = _searchQuery.trim().toLowerCase();
    return usuarios
        .where((u) =>
            _coincideBusqueda(u, q) &&
            _pasaDepartamento(u) &&
            _pasaFiltro(u, _filter))
        .toList();
  }

  List<UsuarioEntity> _ordenar(List<UsuarioEntity> usuarios) {
    final list = [...usuarios];
    switch (_sort) {
      case EmployeeSort.nombre:
        list.sort((a, b) =>
            a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      case EmployeeSort.estado:
        list.sort((a, b) {
          final ea = estadoOrden(a);
          final eb = estadoOrden(b);
          if (ea != eb) return ea.compareTo(eb);
          return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
        });
    }
    return list;
  }

  Map<String, List<UsuarioEntity>> _agrupar(List<UsuarioEntity> usuarios) {
    final map = <String, List<UsuarioEntity>>{};
    for (final u in usuarios) {
      final d = (u.departamento ?? '').trim();
      final key = d.isEmpty ? 'Sin departamento' : d;
      map.putIfAbsent(key, () => []).add(u);
    }
    return map;
  }

  String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final monitorState = ref.watch(monitorEmpleadosProvider);
    final infosAsync = ref.watch(empleadosInfoProvider);
    final infos = infosAsync.maybeWhen(
      data: (v) => v,
      orElse: () => <int, EmpleadoInfoEntity>{},
    );

    final usuarios = monitorState.usuarios;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    final filtrados = _ordenar(_aplicarFiltros(usuarios));

    final activos =
        usuarios.where((u) => estadoEfectivo(u) == 'activo').length;
    final descanso =
        usuarios.where((u) => estadoEfectivo(u) == 'descanso').length;
    final inactivos =
        usuarios.where((u) => estadoEfectivo(u) == 'inactivo').length;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Empleados',
        showBackButton: true,
        actions: [
          if (!isMobile) _buildTabSelector(),
          const SizedBox(width: 4),
          _buildExportButton(usuarios),
          const SizedBox(width: 4),
          _buildSyncButton(monitorState),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(monitorEmpleadosProvider.notifier).sincronizar(),
        child: _buildBody(
          usuarios,
          filtrados,
          infos,
          activos,
          descanso,
          inactivos,
          isMobile,
          isTablet,
          colorScheme,
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // APPBAR ACTIONS
  // ════════════════════════════════════════════════════════════════

  Widget _buildTabSelector() {
    return SegmentedToggle<EmployeeTab>(
      selected: _tab,
      accentColor: const Color(0xFF10B981),
      onChanged: (v) => setState(() => _tab = v),
      items: const [
        SegmentedToggleItem(
          value: EmployeeTab.empleados,
          label: 'Empleados',
          icon: Icons.people_alt_rounded,
        ),
        SegmentedToggleItem(
          value: EmployeeTab.monitor,
          label: 'Monitor',
          icon: Icons.visibility_rounded,
        ),
      ],
    );
  }

  Widget _buildExportButton(List<UsuarioEntity> usuarios) {
    return Tooltip(
      message: 'Exportar a CSV',
      child: IconButton(
        onPressed: usuarios.isEmpty ? null : () => _exportarCSV(usuarios),
        icon: const Icon(Icons.download_rounded, size: 22),
        color: Colors.white,
      ),
    );
  }

  Widget _buildSyncButton(MonitorEmpleadosState state) {
    final isSyncing = state.isLoading && state.lastSync != null;
    return Tooltip(
      message: state.lastSync == null
          ? 'Sincronizar con Supabase'
          : 'Última: ${_hora(state.lastSync!)}',
      child: IconButton(
        onPressed: isSyncing
            ? null
            : () => ref.read(monitorEmpleadosProvider.notifier).sincronizar(),
        icon: isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.cloud_sync_rounded, size: 22),
        color: Colors.white,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CUERPO
  // ════════════════════════════════════════════════════════════════

 Widget _buildBody(
  List<UsuarioEntity> todos,
  List<UsuarioEntity> filtrados,
  Map<int, EmpleadoInfoEntity> infos,
  int activos,
  int descanso,
  int inactivos,
  bool isMobile,
  bool isTablet,
  ColorScheme colorScheme,
) {
  final monitorState = ref.watch(monitorEmpleadosProvider);

  return SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 12 : 24,
      vertical: 16,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMobile) ...[
              _buildTabSelector(),
              const SizedBox(height: 14),
            ],

            // Búsqueda
            GlassSearchBar(
              hint: 'Buscar por nombre, email, documento, teléfono o rol…',
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              accentColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),

            if (_tab == EmployeeTab.empleados) ...[
              // 🎯 FIX UX: ocultar métricas en móvil.
              //    Los chips de filtro ya muestran los conteos y ahorramos
              //    ~120px de espacio vertical antes de las cards.
              if (!isMobile) ...[
                _buildMetricas(activos, descanso, inactivos),
                const SizedBox(height: 14),
              ],
              EmployeesToolbar(
                departamentos: monitorState.departamentos,
                filter: _filter,
                sort: _sort,
                view: _view,
                departamentoFiltro: _departamentoFiltro,
                agruparPorDepartamento: _agruparPorDepartamento,
                contarPorFiltro: (f) => todos
                    .where((u) =>
                        _coincideBusqueda(
                            u, _searchQuery.trim().toLowerCase()) &&
                        _pasaDepartamento(u) &&
                        _pasaFiltro(u, f))
                    .length,
                onFilterChanged: (v) => setState(() => _filter = v),
                onSortChanged: (v) => setState(() => _sort = v),
                onViewChanged: (v) => setState(() => _view = v),
                onDepartamentoChanged: (v) =>
                    setState(() => _departamentoFiltro = v),
                onAgruparChanged: (v) =>
                    setState(() => _agruparPorDepartamento = v),
              ),
              const SizedBox(height: 18),
              _buildContenido(filtrados, infos, isMobile, isTablet),
            ] else
              _buildMonitorView(todos, infos, isMobile),

            const SizedBox(height: 80),
          ],
        ),
      ),
    ),
  );
}

  // ════════════════════════════════════════════════════════════════
  // MÉTRICAS
  // ════════════════════════════════════════════════════════════════

  Widget _buildMetricas(int activos, int descanso, int inactivos) {
    return Row(
      children: [
        MetricPedido(
          label: 'Activos',
          value: activos,
          color: const Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: 10),
        MetricPedido(
          label: 'Descanso',
          value: descanso,
          color: const Color(0xFFF59E0B),
          icon: Icons.free_breakfast_rounded,
        ),
        const SizedBox(width: 10),
        MetricPedido(
          label: 'Inactivos',
          value: inactivos,
          color: const Color(0xFFEF4444),
          icon: Icons.block_rounded,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CONTENIDO
  // ════════════════════════════════════════════════════════════════

  Widget _buildContenido(
    List<UsuarioEntity> filtrados,
    Map<int, EmpleadoInfoEntity> infos,
    bool isMobile,
    bool isTablet,
  ) {
    if (filtrados.isEmpty) {
      return _buildEmptyState(Theme.of(context).colorScheme);
    }

    if (_agruparPorDepartamento) {
      final grupos = _agrupar(filtrados);
      final keys = grupos.keys.toList()..sort();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final key in keys) ...[
            _buildGrupoHeader(key, grupos[key]!.length),
            const SizedBox(height: 10),
            _buildGrid(grupos[key]!, infos, isMobile, isTablet),
            const SizedBox(height: 24),
          ],
        ],
      );
    }

    return _buildGrid(filtrados, infos, isMobile, isTablet);
  }

  Widget _buildGrupoHeader(String nombre, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          nombre.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 1,
          width: 60,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }

 Widget _buildGrid(
  List<UsuarioEntity> items,
  Map<int, EmpleadoInfoEntity> infos,
  bool isMobile,
  bool isTablet,
) {
  final isCompact = _view == EmployeeView.compact;

  // 🎯 FIX: 1 columna en móvil para vista detallada.
  //    Antes eran 2 columnas → las cards se apretaban y overflow.
  final crossAxisCount = isCompact
      ? (isMobile ? 2 : (isTablet ? 4 : 5))
      : (isMobile ? 1 : (isTablet ? 3 : 4));

  // 🎯 FIX: altura adecuada según modo y dispositivo.
  final extent = isCompact
      ? (isMobile ? 220.0 : 200.0)
      : (isMobile ? 270.0 : 300.0);
  final spacing = isCompact ? 10.0 : 12.0;

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisExtent: extent,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
    ),
    itemCount: items.length,
    itemBuilder: (_, i) {
      final u = items[i];
      final info = infos[u.id];
      return EmployeeCard(
        key: ValueKey('emp-${u.id}-${u.fotoUrl}-${_view.name}'),
        usuario: u,
        info: info,
        mode: isCompact
            ? EmployeeCardMode.compact
            : EmployeeCardMode.detailed,
        showEmail: !isCompact,
        showActivity: !isCompact,
        onTap: () => _mostrarDetalle(u, info),
        onEdit: () => _abrirFormulario(u, info),
        onToggleActive: () => _toggleActivo(u),
        onDelete: _esAdmin ? () => _confirmarEliminar(u) : null,
      );
    },
  );
}

  // ════════════════════════════════════════════════════════════════
  // MONITOR
  // ════════════════════════════════════════════════════════════════

  Widget _buildMonitorView(
    List<UsuarioEntity> todos,
    Map<int, EmpleadoInfoEntity> infos,
    bool isMobile,
  ) {
    final activos = <UsuarioEntity>[];
    final descanso = <UsuarioEntity>[];
    final inactivos = <UsuarioEntity>[];

    for (final u in todos) {
      switch (estadoEfectivo(u)) {
        case 'activo':
          activos.add(u);
        case 'descanso':
          descanso.add(u);
        default:
          inactivos.add(u);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMonitorSeccion(
          'En línea',
          activos,
          const Color(0xFF10B981),
          Icons.bolt_rounded,
          infos,
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildMonitorSeccion(
          'En descanso',
          descanso,
          const Color(0xFFF59E0B),
          Icons.free_breakfast_rounded,
          infos,
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildMonitorSeccion(
          'Inactivos',
          inactivos,
          const Color(0xFFEF4444),
          Icons.block_rounded,
          infos,
          isMobile,
        ),
      ],
    );
  }

  Widget _buildMonitorSeccion(
    String titulo,
    List<UsuarioEntity> usuarios,
    Color color,
    IconData icon,
    Map<int, EmpleadoInfoEntity> infos,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${usuarios.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (usuarios.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Sin empleados en esta sección',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          _buildGrid(usuarios, infos, isMobile, false),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // EMPTY / FAB
  // ════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin empleados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _searchQuery.isEmpty
                  ? 'Aún no hay empleados que coincidan con el filtro.'
                  : 'No se encontraron coincidencias para "$_searchQuery".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _abrirFormulario(null, null),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Crear el primero'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabController,
        curve: Curves.easeOutBack,
      ),
      child: FadeTransition(
        opacity: _fabController,
        child: FloatingActionButton.extended(
          onPressed: () => _abrirFormulario(null, null),
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text(
            'Nuevo empleado',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ACCIONES
  // ════════════════════════════════════════════════════════════════

  bool get _esAdmin {
    final actual = ref.read(usuarioActualProvider);
    return actual?.rol.toLowerCase() == 'admin';
  }

  Future<void> _toggleActivo(UsuarioEntity u) async {
    final isarService = ref.read(isarServiceProvider);
    final nuevoActivo = !u.activo;

    u.activo = nuevoActivo;
    if (nuevoActivo) {
      if (u.estado != 'descanso') u.estado = 'activo';
    } else {
      u.estado = 'inactivo';
    }
    u.updatedAt = DateTime.now();
    u.sincronizado = false;

    await isarService.guardarUsuario(u);

    if (!mounted) return;
    await ref
        .read(monitorEmpleadosProvider.notifier)
        .sincronizar(silencioso: true);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nuevoActivo
              ? '✅ ${u.nombre} activado'
              : '⏸ ${u.nombre} desactivado',
        ),
        backgroundColor:
            nuevoActivo ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
      ),
    );
  }

  Future<void> _confirmarEliminar(UsuarioEntity u) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar empleado'),
        content: Text(
          '¿Estás seguro de eliminar a "${u.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(isarServiceProvider).eliminarUsuario(u.id);
      await ref
          .read(monitorEmpleadosProvider.notifier)
          .sincronizar(silencioso: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑 ${u.nombre} eliminado'),
          backgroundColor: colorScheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _mostrarDetalle(
    UsuarioEntity u,
    EmpleadoInfoEntity? info,
  ) async {
    await EmpleadoDetailDialog.show(
      context,
      usuario: u,
      info: info,
      onToggleActivo: () => _toggleActivo(u),
    );
  }

  Future<void> _abrirFormulario(
    UsuarioEntity? usuario,
    EmpleadoInfoEntity? info,
  ) async {
    if (!mounted) return;
    final result = await EmployeeFormDialog.show(
      context,
      empleado: usuario != null
          ? EmpleadoViewModel(usuario: usuario, info: info)
          : null,
    );

    if (result == true && mounted) {
      ref.invalidate(empleadosInfoProvider);
      await ref
          .read(monitorEmpleadosProvider.notifier)
          .sincronizar(silencioso: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usuario == null
                ? '✅ Empleado creado correctamente'
                : '✅ Empleado actualizado correctamente',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // EXPORTAR CSV
  // ════════════════════════════════════════════════════════════════

  Future<void> _exportarCSV(List<UsuarioEntity> usuarios) async {
    try {
      final infosAsync = ref.read(empleadosInfoProvider);
      final infos = infosAsync.maybeWhen(
        data: (v) => v,
        orElse: () => <int, EmpleadoInfoEntity>{},
      );

      final buffer = StringBuffer();
      buffer.writeln(
        'Nombre,Documento,Email,Rol,Estado,Caja,Cargo,Telefono,Departamento',
      );

      for (final u in usuarios) {
        final info = infos[u.id];
        final doc = u.numeroDocumento != null
            ? '${u.tipoDocumento?.codigo ?? ''}-${u.numeroDocumento}'
            : '';
        buffer.writeln([
          _csvEscape(u.nombre),
          _csvEscape(doc),
          _csvEscape(u.email ?? ''),
          _csvEscape(u.rol),
          _csvEscape(labelEstado(u)),
          _csvEscape(u.cajaAsignada),
          _csvEscape(info?.cargo ?? ''),
          _csvEscape(u.telefono ?? ''),
          _csvEscape(u.departamento ?? ''),
        ].join(','));
      }

      final dir = await getTemporaryDirectory();
      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[:.]'), '-');
      final file = File('${dir.path}/empleados_$ts.csv');
      await file.writeAsString(
        '\uFEFF${buffer.toString()}',
        encoding: utf8,
      );

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Empleados — BoostI POS',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _csvEscape(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}