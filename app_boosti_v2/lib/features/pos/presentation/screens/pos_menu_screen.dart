// lib/features/pos/presentation/screens/pos_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../../domain/permissions/roles.dart';
import '../config/menu_config.dart';
import '../providers/auth_provider.dart';
import '../providers/isar_provider.dart';
import '../providers/lock_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/usuario_provider.dart';
import '../services/backup_service.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/appbar.dart';
import '../widgets/menu/pos_menu_card.dart';
import '../widgets/menu/turno_closing_dialog.dart';
import '../widgets/menu/turno_status_banner.dart';
import 'empleados/employees_screen.dart';
import 'login_screen.dart';

class PosMenuScreen extends ConsumerStatefulWidget {
  const PosMenuScreen({super.key});

  @override
  ConsumerState<PosMenuScreen> createState() => _PosMenuScreenState();
}

class _PosMenuScreenState extends ConsumerState<PosMenuScreen>
    with TickerProviderStateMixin {
  // ── Animación de entrada de secciones ──
  late final AnimationController _animationController;

  // ── Animación del buscador (independiente) ──
  late final AnimationController _searchBarController;
  late final FocusNode _searchFocusNode;
  bool _isSearchFocused = false;

  final TextEditingController _searchController = TextEditingController();

  late final IsarService _isarService;
  late final SyncService _syncService;
  final BackupService _backupService = BackupService();

  bool _sincronizando = false;
  TurnoEntity? _turnoAbierto;
  int _ventasPendientesSync = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Animación de entrada de secciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Animación de entrada del buscador
    _searchBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    // FocusNode para reaccionar al foco del buscador
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() {
      if (!mounted) return;
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });

    _isarService = ref.read(isarServiceProvider);
    _syncService = ref.read(syncServiceProvider);

    _cargarEstadoInicial();
    _cargarEstadoSync();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchBarController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // CARGA DE ESTADO
  // ════════════════════════════════════════════════════════════════

  Future<void> _cargarEstadoInicial() async {
    await _cargarEstadoTurno();
  }

  Future<void> _cargarEstadoTurno() async {
    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) return;

      final turno =
          await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
      if (mounted) setState(() => _turnoAbierto = turno);
    } catch (e) {
      debugPrint('Error cargando turno: $e');
    }
  }

  Future<void> _cargarEstadoSync() async {
    try {
      final pendientes = await _isarService.obtenerVentasPendientesSync();
      if (mounted) setState(() => _ventasPendientesSync = pendientes.length);
    } catch (e) {
      debugPrint('Error cargando estado sync: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════

  static String? _formatearHora(DateTime? fecha) {
    if (fecha == null) return null;
    final local = fecha.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  /// Filtra las secciones y opciones por el texto de búsqueda.
  List<MenuSection> _filtrarSecciones(
    List<MenuSection> secciones,
    String query,
  ) {
    if (query.trim().isEmpty) return secciones;

    final q = query.toLowerCase().trim();

    return secciones
        .map((s) {
          final opcionesFiltradas = s.options.where((o) {
            return o.title.toLowerCase().contains(q) ||
                o.subtitle.toLowerCase().contains(q);
          }).toList();

          if (opcionesFiltradas.isEmpty) return null;

          return s.copyWith(options: opcionesFiltradas);
        })
        .whereType<MenuSection>()
        .toList();
  }

  // ════════════════════════════════════════════════════════════════
  // ACCIONES DE TURNO
  // ════════════════════════════════════════════════════════════════

  Future<void> _abrirTurno() async {
    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null || !mounted) return;

    final montoController = TextEditingController(text: '0.00');

    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Abrir turno'),
          content: TextField(
            controller: montoController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto inicial',
              prefixText: '\$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Abrir'),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      final monto = double.tryParse(montoController.text) ?? 0.0;
      final nuevoTurno = TurnoEntity()
        ..turnoId = DateTime.now().millisecondsSinceEpoch.toString()
        ..usuarioId = usuario.id
        ..usuarioNombre = usuario.nombre
        ..cajaId = usuario.cajaAsignada
        ..cajaNombre = usuario.cajaAsignada
        ..montoInicial = monto
        ..fechaApertura = DateTime.now()
        ..estado = 'abierto'
        ..syncStatus = 'pending';

      await _isarService.guardarTurno(nuevoTurno);
      await _cargarEstadoTurno();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno abierto correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } finally {
      montoController.dispose();
    }
  }

  Future<void> _cerrarTurno() async {
    if (_turnoAbierto == null || !mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => TurnoClosingDialog(
        fechaApertura: _turnoAbierto!.fechaApertura,
        montoInicial: _turnoAbierto!.montoInicial,
        montoFinal: 0.0,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirm != true || !mounted) return;

    await _isarService.cerrarTurno(_turnoAbierto!.id, 0.0);
    await _cargarEstadoTurno();
  }

  // ════════════════════════════════════════════════════════════════
  // SINCRONIZACIÓN
  // ════════════════════════════════════════════════════════════════

  Future<void> _sincronizarConProgreso() async {
    if (_sincronizando) return;
    if (mounted) setState(() => _sincronizando = true);

    try {
      final resumen = await _syncService.sincronizarTodoConResumen();
      if (!mounted) return;

      setState(() => _sincronizando = false);
      await _cargarEstadoSync();

      if (!mounted) return;
      final total = resumen.values.fold<int>(0, (s, v) => s + v);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            total > 0
                ? '✅ $total registros sincronizados'
                : '✅ Todo al día — sin cambios pendientes',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sincronizando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sincronizando: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _crearBackup() async {
    try {
      await _backupService.crearBackupYCompartir();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Backup creado'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // LOGOUT
  // ════════════════════════════════════════════════════════════════

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_user_id');

    if (!mounted) return;
    ref.read(authProvider.notifier).logout();
    ref.read(lockProvider.notifier).unlock();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final role = UserRole.fromString(usuario.rol);

    // Guard para roles RRHH
    if (Permissions.isEmployeesOnlyRole(role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EmployeesScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Construir secciones desde el config
    final todasLasSecciones = MenuBuilder.buildSections(
      usuario: usuario,
      context: context,
      onCrearBackup: _crearBackup,
      onSincronizar: _sincronizarConProgreso,
      ventasPendientesSync: _ventasPendientesSync,
    );

    // Filtrar por permisos
    final seccionesConPermisos = todasLasSecciones
        .map((s) => s.copyWith(
              options: s.options
                  .where((o) => MenuBuilder.puedeVerOpcion(role, o.id))
                  .toList(),
            ))
        .where((s) => s.options.isNotEmpty)
        .toList();

    // Filtrar por búsqueda
    final secciones = _filtrarSecciones(seccionesConPermisos, _searchQuery);

    final gradient = isDark
        ? LinearGradient(
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.8),
              const Color(0xFF059669),
            ],
          )
        : const LinearGradient(
            colors: [Color(0xFF5352ED), Color(0xFF4840E8)],
          );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: isMobile ? 'Menú' : 'Menú Principal',
        showBackButton: false,
        gradient: gradient,
        actions: [
          if (_sincronizando)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _sincronizarConProgreso,
        child: _buildBody(secciones, isMobile, isTablet, colorScheme),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CUERPO PRINCIPAL
  // ════════════════════════════════════════════════════════════════

  Widget _buildBody(
    List<MenuSection> secciones,
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
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Buscador con animación de entrada ──
              _buildSearchBar(colorScheme, isMobile),
              const SizedBox(height: 16),

              TurnoStatusBanner(
                tieneTurno: _turnoAbierto != null,
                horaApertura: _formatearHora(_turnoAbierto?.fechaApertura),
                onAbrirTurno: _abrirTurno,
                onCerrarTurno: _cerrarTurno,
              ),
              const SizedBox(height: 20),

              // ── Resultados con animación de búsqueda en tiempo real ──
              _buildAnimatedResults(secciones, isMobile, isTablet, colorScheme),

              const SizedBox(height: 30),

              // ── Botón de Cerrar Sesión (mismo ancho que los demás) ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.4),
                    ),
                    minimumSize: const Size(0, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // RESULTADOS ANIMADOS
  // ════════════════════════════════════════════════════════════════

  Widget _buildAnimatedResults(
    List<MenuSection> secciones,
    bool isMobile,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    // Clave estable que cambia cuando cambia la búsqueda o el número de secciones
    final resultsKey = ValueKey<String>(
      'results::${_searchQuery.trim().toLowerCase()}::${secciones.length}',
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // Apilamos para que el contenido anterior se desvanezca sin saltar el layout
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
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
        key: resultsKey,
        child: secciones.isEmpty
            ? _buildEmptyState(colorScheme)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: secciones.asMap().entries.map((entry) {
                  return _buildSection(
                    section: entry.value,
                    index: entry.key,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  );
                }).toList(),
              ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUSCADOR ANIMADO
  // ════════════════════════════════════════════════════════════════

  Widget _buildSearchBar(ColorScheme colorScheme, bool isMobile) {
    final primary = colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores que combinan con el tema
    final unfocusedFill = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : colorScheme.surfaceContainerHighest;
    final focusedFill = isDark
        ? primary.withValues(alpha: 0.14)
        : primary.withValues(alpha: 0.08);

    final unfocusedBorder =
        colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.6);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _searchBarController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.35),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _searchBarController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isSearchFocused
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.30 : 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) => setState(() => _searchQuery = value),
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: colorScheme.onSurface,
            ),
            cursorColor: primary,
            decoration: InputDecoration(
              hintText: 'Buscar opción...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: isMobile ? 14 : 15,
              ),
              // Icono de búsqueda que rota sutilmente al enfocar
              prefixIcon: AnimatedRotation(
                turns: _isSearchFocused ? 0.05 : 0.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: _isSearchFocused
                        ? primary
                        : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              ),
              // Botón "limpiar" con animación de escala
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _searchQuery.isEmpty
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : IconButton(
                        key: const ValueKey('clear'),
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        color: colorScheme.onSurfaceVariant,
                        tooltip: 'Limpiar',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          // Devolvemos el foco al buscador tras limpiar
                          _searchFocusNode.requestFocus();
                        },
                      ),
              ),
              filled: true,
              fillColor: _isSearchFocused ? focusedFill : unfocusedFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: unfocusedBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary, width: 1.5),
              ),
            ),
          ),
        ),
      ),
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
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron opciones para "$_searchQuery"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SECCIÓN Y GRID
  // ════════════════════════════════════════════════════════════════

  Widget _buildSection({
    required MenuSection section,
    required int index,
    required bool isMobile,
    required bool isTablet,
  }) {
    final intervalStart = (index * 0.15).clamp(0.0, 0.7);
    final intervalEnd = (intervalStart + 0.4).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve:
              Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(section.title, section.color),
            const SizedBox(height: 12),
            _buildOptionsGrid(section.options, isMobile, isTablet),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsGrid(
    List<MenuOption> options,
    bool isMobile,
    bool isTablet,
  ) {
    if (options.isEmpty) return const SizedBox.shrink();

    // ── Opción única: card horizontal ancha ──
    if (options.length == 1) {
      final singleOpt = options.first;
      return PosMenuCard(
        title: singleOpt.title,
        subtitle: singleOpt.subtitle,
        icon: singleOpt.icon,
        color: singleOpt.color,
        onTap: singleOpt.onTap,
        compactMode: isMobile,
      );
    }

    // ── Grid responsive ──
    //   mobile: 2 columnas → cards cuadradas, sin subtitle
    //   tablet: 2 columnas
    //   desktop: 3 columnas
    final crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 3);

    // ✅ Altura FIJA por breakpoint:
    //   - mobile (2 cols, compacto sin subtitle): ~135px
    //   - tablet/desktop (horizontal): ~105px
    final double itemHeight = isMobile ? 135 : 105;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: itemHeight,
        crossAxisSpacing: isMobile ? 10 : 12,
        mainAxisSpacing: isMobile ? 10 : 12,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) {
        final opt = options[i];
        return PosMenuCard(
          title: opt.title,
          subtitle: opt.subtitle,
          icon: opt.icon,
          color: opt.color,
          onTap: opt.onTap,
          // ✅ En mobile no mostramos subtitle (cards limpias)
          compactMode: isMobile,
        );
      },
    );
  }
}