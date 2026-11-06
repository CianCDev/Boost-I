// lib/features/pos/presentation/screens/pos_menu_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../../domain/permissions/roles.dart';
import '../config/menu_config.dart';
import '../providers/auth_provider.dart';
import '../providers/comanda_provider.dart';
import '../providers/isar_provider.dart';
import '../providers/lock_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/usuario_provider.dart';
import '../services/backup_service.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/appbar.dart';
import '../widgets/common/local_activo_chip.dart';
import '../widgets/menu/pos_menu_card.dart';
import '../widgets/menu/turno_closing_dialog.dart';
import '../widgets/menu/turno_status_banner.dart';
import 'empleados/employees_screen.dart';
import 'login_screen.dart';

class PosMenuScreen extends ConsumerStatefulWidget {
  final bool abrirCatalogoAlSeleccionar;

  const PosMenuScreen({
    super.key,
    this.abrirCatalogoAlSeleccionar = false,
  });

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

  // ── Carrusel de módulos destacados ──
  final PageController _modulePageController =
      PageController(viewportFraction: 0.85);
  int _modulePageIndex = 0;
  Timer? _moduleAutoPlayTimer;
  List<MenuOption> _modulosDestacadosCache = [];

  // ── Blobs de fondo premium ──
  late final AnimationController _blobController;

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

    // Animación de los blobs de fondo (20s → movimiento muy lento, "aurora")
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _isarService = ref.read(isarServiceProvider);
    _syncService = ref.read(syncServiceProvider);

    _cargarEstadoInicial();
    _cargarEstadoSync();

    // Auto-play del carrusel de módulos destacados
    _iniciarAutoPlay();
  }

  /// Inicia la rotación automática del carrusel cada 3 segundos.
  void _iniciarAutoPlay() {
    _moduleAutoPlayTimer?.cancel();
    _moduleAutoPlayTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted) return;
        final total = _modulosDestacadosCache.length;
        if (total <= 1) return;
        final siguiente = (_modulePageIndex + 1) % total;
        _modulePageController.animateToPage(
          siguiente,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  /// Reinicia el temporizador cuando el usuario o los botones cambian de página.
  void _reiniciarAutoPlay() {
    _iniciarAutoPlay();
  }

  @override
  void dispose() {
    _moduleAutoPlayTimer?.cancel();
    _blobController.dispose();
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    final flags = ref.watch(featureFlagsProvider);

    // R.3.2 · Badge del KDS.
    //
    // `select` con un `int` es lo que evita el bucle de reconstrucción:
    // `totalItemsEnKds` ya es `int` a propósito (comanda_provider.dart:153).
    final kdsBadge = ref.watch(
      comandasProvider.select((s) => s.totalItemsEnKds),
    );

    // Construir secciones desde el config
    final todasLasSecciones = MenuBuilder.buildSections(
      usuario: usuario,
      context: context,
      flags: flags, // 🎯 NUEVO
      onCrearBackup: _crearBackup,
      onSincronizar: _sincronizarConProgreso,
      ventasPendientesSync: _ventasPendientesSync,
      kdsBadge: kdsBadge,
      abrirCatalogoAlSeleccionar: widget.abrirCatalogoAlSeleccionar,
    );

    // Filtrar por permisos + feature flags
    final seccionesConPermisos = todasLasSecciones
        .map((s) => s.copyWith(
              options: s.options
                  .where((o) => MenuBuilder.puedeVerOpcion(
                      role, o.id, flags)) // 🎯 CAMBIO
                  .toList(),
            ))
        .where((s) => s.options.isNotEmpty)
        .toList();

    // 🔎 DIAGNÓSTICO (2026-10-15): el menú se armaba sin dejar rastro de
    // qué opción se cayó ni por qué. Con un gate de plan activo, "no
    // aparece" y "apareció y después se perdió" son indistinguibles.
    final ocultas = todasLasSecciones
        .expand((s) => s.options)
        .where((o) => !MenuBuilder.puedeVerOpcion(role, o.id, flags))
        .map((o) => o.id)
        .toList();
    debugPrint(
      '🔎 [menú] rol=${role.name} planActivo=${flags.planActivo} '
      'visibles=${seccionesConPermisos.expand((s) => s.options).length} '
      'ocultas=$ocultas',
    );

    // Filtrar por búsqueda
    final secciones = _filtrarSecciones(seccionesConPermisos, _searchQuery);

    // Módulos destacados para el carrusel
    final modulosDestacados = seccionesConPermisos
        .expand((seccion) => seccion.options)
        .where((opcion) => const {
              'punto_venta',
              'mesas',
              'caja_operativa',
              'inventario',
            }.contains(opcion.id))
        .toList(growable: false);
    _modulosDestacadosCache = modulosDestacados;

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        appBar: CustomAppBar(
          title: isMobile ? 'Menú' : 'Menú Principal',
          showBackButton: false,
          gradient: gradient,
          actions: [
            // Local activo. INFO only, no clickeable: el hot-switch vive en
            // el side panel. Va antes del spinner para que el nombre quede
            // en posición estable y el spinner no lo desplace al syncar.
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: LocalActivoChip(variante: LocalActivoVariante.appBar),
              ),
            ),
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Blobs de fondo premium (aurora suave) ──
            AnimatedBuilder(
              animation: _blobController,
              builder: (context, _) {
                final t = _blobController.value * 2 * math.pi;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final cMint = const Color(0xFF10B981);
                final cElectric = const Color(0xFF06B6D4);
                final cLilac = const Color(0xFF8B5CF6);
                final alphaStrong = isDark ? 0.20 : 0.14;
                final alphaSoft = isDark ? 0.14 : 0.10;
                final alphaFaint = isDark ? 0.08 : 0.06;

                return Stack(
                  children: [
                    // 1 · arriba-izquierda (mint, más fuerte)
                    Positioned(
                      top: -140 + 40 * math.sin(t),
                      left: -110 + 50 * math.cos(t * 0.9),
                      child: _MenuBlob(
                        size: 460,
                        color: cMint.withValues(alpha: alphaStrong),
                        blur: 100,
                      ),
                    ),
                    // 2 · arriba-derecha (electric)
                    Positioned(
                      top: -100 + 45 * math.cos(t * 0.8),
                      right: -140 + 55 * math.sin(t * 1.1),
                      child: _MenuBlob(
                        size: 520,
                        color: cElectric.withValues(alpha: alphaSoft),
                        blur: 110,
                      ),
                    ),
                    // 3 · abajo-centro (lilac)
                    Positioned(
                      bottom: -180 + 50 * math.sin(t * 1.3),
                      left: 140 + 80 * math.cos(t * 0.7),
                      child: _MenuBlob(
                        size: 440,
                        color: cLilac.withValues(alpha: alphaSoft),
                        blur: 100,
                      ),
                    ),
                    // 4 · medio-derecha (mint, tenue)
                    Positioned(
                      top: 260 + 50 * math.sin(t * 0.6),
                      right: -160 + 40 * math.cos(t * 1.2),
                      child: _MenuBlob(
                        size: 380,
                        color: cMint.withValues(alpha: alphaFaint),
                        blur: 90,
                      ),
                    ),
                    // 5 · medio-izquierda (electric, tenue)
                    Positioned(
                      top: 540 + 35 * math.cos(t * 0.9),
                      left: -180 + 60 * math.sin(t * 0.8),
                      child: _MenuBlob(
                        size: 340,
                        color: cElectric.withValues(alpha: alphaFaint),
                        blur: 90,
                      ),
                    ),
                  ],
                );
              },
            ),

            RefreshIndicator(
                onRefresh: _sincronizarConProgreso,
                child: _buildBody(
                  secciones,
                  modulosDestacados,
                  isMobile,
                  isTablet,
                  colorScheme,
                )),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CUERPO PRINCIPAL
  // ════════════════════════════════════════════════════════════════

  Widget _buildBody(
    List<MenuSection> secciones,
    List<MenuOption> modulosDestacados,
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

              // ── Carrusel de módulos destacados ──
              if (modulosDestacados.isNotEmpty) ...[
                _buildModuleCarousel(
                  modulosDestacados,
                  isMobile,
                  colorScheme,
                ),
                const SizedBox(height: 24),
              ],

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
  // TARJETA DE MÓDULO DESTACADO (carrusel)
  // ════════════════════════════════════════════════════════════════

  Widget _buildFeaturedModuleCard({
    required MenuOption option,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {},
      onExit: (_) {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isMobile ? 18 : 24),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? colors.surfaceContainerHigh.withValues(alpha: 0.78)
                      : Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: option.color.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 56 : 64,
                      height: isMobile ? 56 : 64,
                      decoration: BoxDecoration(
                        color: option.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        option.icon,
                        size: isMobile ? 30 : 34,
                        color: option.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MÓDULO DESTACADO',
                            style: TextStyle(
                              color: option.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            option.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: isMobile ? 19 : 23,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: option.color,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CARRUSEL DE MÓDULOS DESTACADOS (con botones de flecha)
  // ════════════════════════════════════════════════════════════════

  Widget _buildModuleCarousel(
    List<MenuOption> modules,
    bool isMobile,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Navegación del carrusel ──
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _modulePageIndex > 0
                  ? () {
                      _modulePageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _reiniciarAutoPlay();
                    }
                  : null,
              color: colorScheme.primary,
              tooltip: 'Anterior',
            ),
            Expanded(
              child: SizedBox(
                height: isMobile ? 176 : 194,
                child: AnimatedBuilder(
                  animation: _modulePageController,
                  builder: (context, child) {
                    return PageView.builder(
                      controller: _modulePageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: modules.length,
                      onPageChanged: (index) {
                        if (_modulePageIndex != index) {
                          setState(() => _modulePageIndex = index);
                        }
                        _reiniciarAutoPlay();
                      },
                      itemBuilder: (context, index) {
                        final currentPage = _modulePageController.hasClients
                            ? _modulePageController.page ??
                                _modulePageController.initialPage.toDouble()
                            : _modulePageController.initialPage.toDouble();
                        final delta = (index - currentPage).abs();
                        final progress = delta.clamp(0.0, 1.0);
                        final scale = 1 - 0.15 * progress;
                        final opacity = 1 - 0.5 * progress;
                        final option = modules[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(end: scale),
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            builder: (context, animatedScale, child) {
                              return Opacity(
                                opacity: opacity,
                                child: Transform.scale(
                                  scale: animatedScale,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildFeaturedModuleCard(
                              option: option,
                              onTap: option.onTap,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _modulePageIndex < modules.length - 1
                  ? () {
                      _modulePageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _reiniciarAutoPlay();
                    }
                  : null,
              color: colorScheme.primary,
              tooltip: 'Siguiente',
            ),
          ],
        ),

        // ── Dots indicadores ──
        if (modules.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              modules.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _modulePageIndex ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(
                    alpha: index == _modulePageIndex ? 0.9 : 0.3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
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
    //
    // ⚠️ El `SizedBox(width: double.infinity)` NO es cosmético.
    //
    // El padre es un `Column(crossAxisAlignment: CrossAxisAlignment.start)`
    // (`:810-818`), así que un hijo directo recibe restricciones FLOJAS en
    // el eje horizontal y se ajusta a su ancho intrínseco. Sin el
    // `SizedBox`, "Punto de venta" (rama de 1 opción) medía ~204px
    // mientras "Productos" (celda del grid de 2 columnas) medía ~331px en
    // la MISMA pantalla. En desktop no se notaba porque con título +
    // subtítulo + chevron el contenido llenaba el ancho de todos modos.
    if (options.length == 1) {
      final singleOpt = options.first;
      return SizedBox(
        width: double.infinity,
        child: PosMenuCard(
          title: singleOpt.title,
          subtitle: singleOpt.subtitle,
          icon: singleOpt.icon,
          color: singleOpt.color,
          onTap: singleOpt.onTap,
          badge: singleOpt.badge,
          badgeColor: singleOpt.badgeColor,
          compactMode: isMobile,
        ),
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
          badge: opt.badge,
          badgeColor: opt.badgeColor,
          // ✅ En mobile no mostramos subtitle (cards limpias)
          compactMode: isMobile,
        );
      },
    );
  }
}

/// Blob individual del menú principal: círculo con gradiente radial + blur.
///
/// Se usa `RepaintBoundary` para cachear el resultado del blur y que el
/// movimiento del blob no recalcule el filtro en cada frame.
class _MenuBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const _MenuBlob({
    required this.size,
    required this.color,
    this.blur = 60,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
