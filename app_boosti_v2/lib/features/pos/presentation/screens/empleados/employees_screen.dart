// lib/features/pos/presentation/screens/empleados/employees_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../data/Local/entities/empleado_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/models/empleado_view_model.dart';
import '../../../domain/permissions/roles.dart';
import '../../providers/empleados/monitor_empleados_provider.dart';
import '../../providers/isar_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/active_toggle.dart';
import '../../widgets/common/card_action_button.dart';
import '../../widgets/common/dialog_header.dart';
import '../../widgets/common/filtro_chip_template.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/glass_dialog.dart';
import '../../widgets/common/glass_search_bar.dart';
import '../../widgets/common/metric_pedido.dart';
import '../../widgets/common/segmented_toggle.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/empleado/empleado_form_dialog.dart';

// ═══════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════

enum _EmployeeView { grid, list }
enum _EmployeeTab { empleados, monitor }

enum _EmployeeFilter {
  todos,
  activos,
  inactivos,
  descanso,
  admin,
  cajero,
  supervisor,
  almacen,
}

extension _EmployeeFilterX on _EmployeeFilter {
  String get label => switch (this) {
        _EmployeeFilter.todos => 'Todos',
        _EmployeeFilter.activos => 'Activos',
        _EmployeeFilter.inactivos => 'Inactivos',
        _EmployeeFilter.descanso => 'En descanso',
        _EmployeeFilter.admin => 'Admins',
        _EmployeeFilter.cajero => 'Cajeros',
        _EmployeeFilter.supervisor => 'Supervisores',
        _EmployeeFilter.almacen => 'Almacén',
      };

  IconData get icon => switch (this) {
        _EmployeeFilter.todos => Icons.groups_rounded,
        _EmployeeFilter.activos => Icons.check_circle_rounded,
        _EmployeeFilter.inactivos => Icons.block_rounded,
        _EmployeeFilter.descanso => Icons.free_breakfast_rounded,
        _EmployeeFilter.admin => Icons.admin_panel_settings_rounded,
        _EmployeeFilter.cajero => Icons.point_of_sale_rounded,
        _EmployeeFilter.supervisor => Icons.shield_rounded,
        _EmployeeFilter.almacen => Icons.inventory_2_rounded,
      };

  Color get color => switch (this) {
        _EmployeeFilter.todos => const Color(0xFF3B82F6),
        _EmployeeFilter.activos => const Color(0xFF10B981),
        _EmployeeFilter.inactivos => const Color(0xFFEF4444),
        _EmployeeFilter.descanso => const Color(0xFFF59E0B),
        _EmployeeFilter.admin => const Color(0xFF8B5CF6),
        _EmployeeFilter.cajero => const Color(0xFF06B6D4),
        _EmployeeFilter.supervisor => const Color(0xFF6366F1),
        _EmployeeFilter.almacen => const Color(0xFFEC4899),
      };
}

// ═══════════════════════════════════════════════════════════════════════
// PANTALLA
// ═══════════════════════════════════════════════════════════════════════

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();

  late final AnimationController _fabController;

  String _searchQuery = '';
  _EmployeeView _view = _EmployeeView.grid;
  _EmployeeTab _tab = _EmployeeTab.empleados;
  _EmployeeFilter _filter = _EmployeeFilter.todos;

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
  // ESTADO EFECTIVO — `estado` manda, `activo` es respaldo
  // ════════════════════════════════════════════════════════════════

  String _estadoEfectivo(UsuarioEntity u) {
    final estado = u.estado.toLowerCase().trim();
    if (estado == 'descanso') return 'descanso';
    if (estado == 'inactivo') return 'inactivo';
    if (estado == 'desconectado') return 'inactivo';
    if (!u.activo) return 'inactivo';
    return 'activo';
  }

  // ════════════════════════════════════════════════════════════════
  // FILTRADO
  // ════════════════════════════════════════════════════════════════

  bool _pasaFiltro(UsuarioEntity u, _EmployeeFilter f) {
    final estado = _estadoEfectivo(u);
    switch (f) {
      case _EmployeeFilter.todos:
        return true;
      case _EmployeeFilter.activos:
        return estado == 'activo';
      case _EmployeeFilter.inactivos:
        return estado == 'inactivo';
      case _EmployeeFilter.descanso:
        return estado == 'descanso';
      case _EmployeeFilter.admin:
        return u.rol.toLowerCase().contains('admin');
      case _EmployeeFilter.cajero:
        return u.rol.toLowerCase().contains('cajer');
      case _EmployeeFilter.supervisor:
        return u.rol.toLowerCase().contains('super');
      case _EmployeeFilter.almacen:
        return u.rol.toLowerCase().contains('almac');
    }
  }

  bool _coincideBusqueda(UsuarioEntity u, String q) {
    if (q.isEmpty) return true;
    return u.nombre.toLowerCase().contains(q) ||
        (u.email ?? '').toLowerCase().contains(q) ||
        u.pin.toLowerCase().contains(q) ||
        u.rol.toLowerCase().contains(q);
  }

  List<UsuarioEntity> _aplicarFiltros(List<UsuarioEntity> usuarios) {
    final q = _searchQuery.trim().toLowerCase();
    return usuarios
        .where((u) => _coincideBusqueda(u, q) && _pasaFiltro(u, _filter))
        .toList();
  }

  int _contarPorFiltro(List<UsuarioEntity> usuarios, _EmployeeFilter f) {
    final q = _searchQuery.trim().toLowerCase();
    return usuarios
        .where((u) => _coincideBusqueda(u, q) && _pasaFiltro(u, f))
        .length;
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS DE PRESENTACIÓN
  // ════════════════════════════════════════════════════════════════

  Color _colorRol(String rol) {
    final r = rol.toLowerCase();
    if (r.contains('admin')) return const Color(0xFF8B5CF6);
    if (r.contains('super')) return const Color(0xFF6366F1);
    if (r.contains('cajer')) return const Color(0xFF06B6D4);
    if (r.contains('almac')) return const Color(0xFFEC4899);
    if (r.contains('rrhh')) return const Color(0xFF10B981);
    return const Color(0xFF64748B);
  }

  IconData _iconoRol(String rol) {
    final r = rol.toLowerCase();
    if (r.contains('admin')) return Icons.admin_panel_settings_rounded;
    if (r.contains('super')) return Icons.shield_rounded;
    if (r.contains('cajer')) return Icons.point_of_sale_rounded;
    if (r.contains('almac')) return Icons.inventory_2_rounded;
    if (r.contains('rrhh')) return Icons.badge_rounded;
    return Icons.person_rounded;
  }

  Color _colorEstado(UsuarioEntity u) {
    switch (_estadoEfectivo(u)) {
      case 'inactivo':
        return const Color(0xFFEF4444);
      case 'descanso':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  String _labelEstado(UsuarioEntity u) {
    switch (_estadoEfectivo(u)) {
      case 'inactivo':
        return 'Inactivo';
      case 'descanso':
        return 'En descanso';
      default:
        return 'Activo';
    }
  }

  String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // 👇 Consumimos el provider compartido con el monitor
    final monitorState = ref.watch(monitorEmpleadosProvider);
    final usuarios = monitorState.usuarios;

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final usuariosFiltrados = _aplicarFiltros(usuarios);

    final activos =
        usuarios.where((u) => _estadoEfectivo(u) == 'activo').length;
    final descanso =
        usuarios.where((u) => _estadoEfectivo(u) == 'descanso').length;
    final inactivos =
        usuarios.where((u) => _estadoEfectivo(u) == 'inactivo').length;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Empleados',
        showBackButton: true,
        actions: [
          if (!isMobile) _buildTabSelector(),
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
          usuariosFiltrados,
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
  // SYNC BUTTON
  // ════════════════════════════════════════════════════════════════

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
        tooltip: 'Sincronizar',
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CUERPO
  // ════════════════════════════════════════════════════════════════

  Widget _buildBody(
    List<UsuarioEntity> todos,
    List<UsuarioEntity> filtrados,
    int activos,
    int descanso,
    int inactivos,
    bool isMobile,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMobile) ...[
                _buildTabSelector(),
                const SizedBox(height: 14),
              ],

              GlassSearchBar(
                hint: 'Buscar por nombre, email, PIN o rol…',
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                accentColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),

              if (_tab == _EmployeeTab.empleados) ...[
                _buildMetricas(activos, descanso, inactivos),
                const SizedBox(height: 16),
                _buildFiltrosYToggle(todos, isMobile, isTablet),
                const SizedBox(height: 18),
                _buildAnimatedResults(
                  filtrados,
                  isMobile,
                  isTablet,
                  colorScheme,
                ),
              ] else
                _buildMonitorView(todos, isMobile, isTablet, colorScheme),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // TABS
  // ════════════════════════════════════════════════════════════════

  Widget _buildTabSelector() {
    return SegmentedToggle<_EmployeeTab>(
      selected: _tab,
      accentColor: const Color(0xFF10B981),
      onChanged: (v) => setState(() => _tab = v),
      items: const [
        SegmentedToggleItem(
          value: _EmployeeTab.empleados,
          label: 'Empleados',
          icon: Icons.people_alt_rounded,
        ),
        SegmentedToggleItem(
          value: _EmployeeTab.monitor,
          label: 'Monitor',
          icon: Icons.visibility_rounded,
        ),
      ],
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
  // FILTROS + TOGGLE VISTA
  // ════════════════════════════════════════════════════════════════

  Widget _buildFiltrosYToggle(
    List<UsuarioEntity> todos,
    bool isMobile,
    bool isTablet,
  ) {
    final filtros = _EmployeeFilter.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final f in filtros) ...[
                FiltroChip(
                  label: f.label,
                  icon: f.icon,
                  color: f.color,
                  selected: _filter == f,
                  size: FiltroChipSize.small,
                  count: _contarPorFiltro(todos, f),
                  onTap: () => setState(() => _filter = f),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedToggle<_EmployeeView>(
            selected: _view,
            accentColor: const Color(0xFF3B82F6),
            compact: isMobile,
            onChanged: (v) => setState(() => _view = v),
            items: const [
              SegmentedToggleItem(
                value: _EmployeeView.grid,
                label: 'Grid',
                icon: Icons.grid_view_rounded,
              ),
              SegmentedToggleItem(
                value: _EmployeeView.list,
                label: 'Lista',
                icon: Icons.view_list_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // RESULTADOS ANIMADOS
  // ════════════════════════════════════════════════════════════════

  Widget _buildAnimatedResults(
    List<UsuarioEntity> filtrados,
    bool isMobile,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    final key = ValueKey<String>(
      'emp::${_searchQuery.trim().toLowerCase()}::${_filter.name}::${_view.name}::${filtrados.length}',
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: key,
        child: filtrados.isEmpty
            ? _buildEmptyState(colorScheme)
            : (_view == _EmployeeView.grid
                ? _buildGrid(filtrados, isMobile, isTablet)
                : _buildList(filtrados)),
      ),
    );
  }

  Widget _buildGrid(
    List<UsuarioEntity> items,
    bool isMobile,
    bool isTablet,
  ) {
    final crossAxisCount = isMobile
        ? 1
        : isTablet
            ? 2
            : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 3.4 : 2.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildEmployeeCard(items[i], compact: false),
    );
  }

  Widget _buildList(List<UsuarioEntity> items) {
    return Column(
      children: [
        for (final u in items) _buildEmployeeCard(u, compact: true),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // TARJETA DE EMPLEADO
  // ════════════════════════════════════════════════════════════════

  Widget _buildEmployeeCard(UsuarioEntity u, {required bool compact}) {
    final rolColor = _colorRol(u.rol);
    final estadoColor = _colorEstado(u);
    final rolIcon = _iconoRol(u.rol);
    final estadoLabel = _labelEstado(u);

    final initials = u.nombre
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((s) => s.isEmpty ? '' : s[0].toUpperCase())
        .join();

    return GlassCard(
      onTap: () => _mostrarDetalle(u),
      showStatusBar: true,
      statusColor: estadoColor,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: compact ? 44 : 50,
            height: compact ? 44 : 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  rolColor,
                  Color.lerp(rolColor, Colors.black, 0.25)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rolColor.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        u.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildPulseDot(estadoColor),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(
                      label: u.rol.toUpperCase(),
                      color: rolColor,
                      icon: rolIcon,
                      size: StatusBadgeSize.small,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        estadoLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: estadoColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!compact && (u.email ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    u.email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CardActionButton(
                icon: Icons.edit_rounded,
                color: const Color(0xFF3B82F6),
                tooltip: 'Editar',
                padding: const EdgeInsets.all(6),
                iconSize: 16,
                onPressed: () => _abrirFormulario(u),
              ),
              const SizedBox(height: 6),
              CardActionButton(
                icon: u.activo
                    ? Icons.pause_circle_rounded
                    : Icons.play_circle_rounded,
                color: u.activo
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
                tooltip: u.activo ? 'Desactivar' : 'Activar',
                padding: const EdgeInsets.all(6),
                iconSize: 16,
                onPressed: () => _toggleActivo(u),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulseDot(Color color) {
    final isActive = color == const Color(0xFF10B981);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: Duration(milliseconds: isActive ? 900 : 0),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Transform.scale(
        scale: isActive ? v : 1.0,
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 6 * (isActive ? v : 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // MONITOR VIEW
  // ════════════════════════════════════════════════════════════════

  Widget _buildMonitorView(
    List<UsuarioEntity> todos,
    bool isMobile,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    final activos = <UsuarioEntity>[];
    final descanso = <UsuarioEntity>[];
    final inactivos = <UsuarioEntity>[];

    for (final u in todos) {
      switch (_estadoEfectivo(u)) {
        case 'activo':
          activos.add(u);
          break;
        case 'descanso':
          descanso.add(u);
          break;
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
        ),
        const SizedBox(height: 16),
        _buildMonitorSeccion(
          'En descanso',
          descanso,
          const Color(0xFFF59E0B),
          Icons.free_breakfast_rounded,
        ),
        const SizedBox(height: 16),
        _buildMonitorSeccion(
          'Inactivos',
          inactivos,
          const Color(0xFFEF4444),
          Icons.block_rounded,
        ),
      ],
    );
  }

  Widget _buildMonitorSeccion(
    String titulo,
    List<UsuarioEntity> usuarios,
    Color color,
    IconData icon,
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
          ...usuarios.map((u) => _buildEmployeeCard(u, compact: true)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(
              Icons.person_search_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
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
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FAB
  // ════════════════════════════════════════════════════════════════

  Widget _buildFab() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabController,
        curve: Curves.easeOutBack,
      ),
      child: FadeTransition(
        opacity: _fabController,
        child: FloatingActionButton.extended(
          onPressed: () => _abrirFormulario(null),
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
    // Refrescamos el provider compartido para que la UI reaccione
    await ref.read(monitorEmpleadosProvider.notifier).sincronizar(
          silencioso: true,
        );
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

  Future<void> _mostrarDetalle(UsuarioEntity u) async {
    await showDialog(
      context: context,
      builder: (_) => _EmployeeDetailDialog(
        usuario: u,
        onToggleActivo: () => _toggleActivo(u),
      ),
    );
  }

  Future<void> _abrirFormulario(UsuarioEntity? usuario) async {
    EmpleadoViewModel? vm;

    if (usuario != null) {
      try {
        final isarService = ref.read(isarServiceProvider);
        final db = await isarService.db;

        final info = await db.empleadoInfoEntitys
            .filter()
            .usuarioIdEqualTo(usuario.id)
            .findFirst();

        vm = EmpleadoViewModel(usuario: usuario, info: info);
      } catch (e) {
        debugPrint('Error construyendo EmpleadoViewModel: $e');
      }
    }

    if (!mounted) return;
    final result = await EmployeeFormDialog.show(context, empleado: vm);

    if (result == true && mounted) {
      await ref.read(monitorEmpleadosProvider.notifier).sincronizar(
            silencioso: true,
          );
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
}

// ═══════════════════════════════════════════════════════════════════════
// DIÁLOGO DE DETALLE
// ═══════════════════════════════════════════════════════════════════════

class _EmployeeDetailDialog extends StatefulWidget {
  final UsuarioEntity usuario;
  final VoidCallback onToggleActivo;

  const _EmployeeDetailDialog({
    required this.usuario,
    required this.onToggleActivo,
  });

  @override
  State<_EmployeeDetailDialog> createState() => _EmployeeDetailDialogState();
}

class _EmployeeDetailDialogState extends State<_EmployeeDetailDialog> {
  late UsuarioEntity _u;

  @override
  void initState() {
    super.initState();
    _u = widget.usuario;
  }

  Color _rolColor(String rol) {
    final r = rol.toLowerCase();
    if (r.contains('admin')) return const Color(0xFF8B5CF6);
    if (r.contains('super')) return const Color(0xFF6366F1);
    if (r.contains('cajer')) return const Color(0xFF06B6D4);
    if (r.contains('almac')) return const Color(0xFFEC4899);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final color = _rolColor(_u.rol);

    return GlassDialog(
      maxWidth: 520,
      accentColor: color,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.person_rounded,
              title: _u.nombre,
              subtitle: _u.email ?? 'Sin correo',
              color: color,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),

            _InfoRow(label: 'Rol', value: _u.rol),
            _InfoRow(label: 'Caja asignada', value: _u.cajaAsignada ?? '—'),
            _InfoRow(label: 'Departamento', value: _u.departamento ?? '—'),
            _InfoRow(label: 'PIN', value: _u.pin),
            _InfoRow(
              label: 'Estado',
              value: !_u.activo
                  ? 'Inactivo'
                  : (_u.estado == 'descanso' ? 'En descanso' : 'Activo'),
            ),

            const SizedBox(height: 18),
            ActiveToggle(
              value: _u.activo,
              onChanged: (v) {
                setState(() => _u.activo = v);
                widget.onToggleActivo();
              },
              activeLabel: 'Empleado activo',
              inactiveLabel: 'Empleado inactivo',
              activeSubtitle: 'Puede iniciar sesión y operar',
              inactiveSubtitle: 'No podrá iniciar sesión',
              activeColor: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}