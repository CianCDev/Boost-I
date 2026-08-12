// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../data/Local/entities/usuario_entity.dart';
import '../providers/auth_provider.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/isar_service.dart';

import '../widgets/admin_validation_dialog.dart';
import '../widgets/menu/turno_status_banner.dart';
import 'cash_closing_screen.dart';
import 'configuracion_empresa_screen.dart';
import 'sales_history_screen.dart';
import '../widgets/monitor_empleado_widget.dart' as monitor;
import '../widgets/gestion_personal_dialog.dart';
import '../widgets/cambiar_pin_dialog.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../services/backup_service.dart';
import 'login_screen.dart';
import 'gastos_screen.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../widgets/printer_selection_widget.dart';
import 'user_settings_screen.dart';
import '../screens/dashboard_screen.dart';

// Modelo para cada opción del menú
class MenuOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isAdminOnly;

  const MenuOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isAdminOnly = false,
  });
}

// Modelo para una sección del menú
class MenuSection {
  final String title;
  final IconData? icon;
  final List<MenuOption> options;

  const MenuSection({
    required this.title,
    this.icon,
    required this.options,
  });
}

class PosMenuScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  const PosMenuScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<PosMenuScreen> createState() => _PosMenuScreenState();
}

class _PosMenuScreenState extends ConsumerState<PosMenuScreen>
    with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();
  int _ventasPendientesSync = 0;
  bool _sincronizando = false;
  TurnoEntity? _turnoAbierto;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cargarEstadoSync();
    _cargarEstadoTurno();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // MÉTODOS DE NEGOCIO
  // ============================================================
  Future<void> _cargarEstadoSync() async {
    final pendientes = await _isarService.obtenerVentasPendientesSync();
    if (mounted) {
      setState(() => _ventasPendientesSync = pendientes.length);
    }
  }

  Future<void> _cargarEstadoTurno() async {
    final usuario = ref.read(usuarioActualProvider);
    if (usuario != null) {
      final turno = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
      if (mounted) {
        setState(() => _turnoAbierto = turno);
      }
    }
  }

  Future<void> _sincronizarTodo() async {
    if (_sincronizando) return;
    setState(() => _sincronizando = true);

    try {
      await _syncService.sincronizarTodo();
      await _cargarEstadoSync();
      await _cargarEstadoTurno();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Datos sincronizados correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al sincronizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _abrirTurno() async {
    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado.')),
      );
      return;
    }

    final turnoExistente = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
    if (turnoExistente != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya tienes un turno abierto.')),
      );
      return;
    }

    final nuevoTurno = TurnoEntity()
      ..usuarioId = usuario.id
      ..usuarioNombre = usuario.nombre
      ..cajaId = ''
      ..cajaNombre = usuario.cajaAsignada
      ..montoInicial = 0.0
      ..fechaApertura = DateTime.now()
      ..estado = 'abierto'
      ..syncStatus = 'pending';

    await _isarService.guardarTurno(nuevoTurno);
    await _isarService.actualizarEstadoUsuario(usuario.id, 'activo');
    await _syncService.actualizarEstadoUsuarioEnSupabase(usuario.id, 'activo');

    await _cargarEstadoTurno();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Turno abierto correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _cerrarTurno() async {
    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado.')),
      );
      return;
    }

    final turnoAbierto = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
    if (turnoAbierto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay turno abierto para este usuario.')),
      );
      return;
    }

    try {
      await _syncService.descargarVentasDesdeSupabase();
    } catch (e) {
      debugPrint('⚠️ Error descargando ventas para el turno: $e');
    }

    final double montoFinal = await _isarService.obtenerTotalVentasPorEmpleadoYRango(
      usuario.nombre,
      turnoAbierto.fechaApertura,
      DateTime.now(),
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Turno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monto inicial: \$${turnoAbierto.montoInicial.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Total de ventas del turno: \$${montoFinal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('¿Deseas cerrar el turno con este monto?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Turno'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      turnoAbierto.montoFinal = montoFinal;
      turnoAbierto.fechaCierre = DateTime.now();
      turnoAbierto.estado = 'cerrado';
      turnoAbierto.syncStatus = 'pending';

      await _isarService.guardarTurno(turnoAbierto);
      await _isarService.actualizarEstadoUsuario(usuario.id, 'inactivo');
      await _syncService.sincronizarTurnos();

      await _cargarEstadoTurno();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Turno cerrado correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final usuario = ref.read(usuarioActualProvider);
    TurnoEntity? turnoAbierto;
    if (usuario != null) {
      turnoAbierto = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
    }

    if (turnoAbierto != null) {
      final cerrarTurno = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Turno abierto'),
          content: Text(
            'Tienes un turno abierto (iniciado a las ${_formatearHora(turnoAbierto!.fechaApertura)}).\n'
            '¿Quieres cerrarlo antes de salir?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Salir sin cerrar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar turno'),
            ),
          ],
        ),
      );

      if (cerrarTurno == true) {
        await _cerrarTurno();
      }
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(authProvider.notifier).logout();
    ref.read(usuarioActualProvider.notifier).clearUsuario();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _formatearHora(DateTime fecha) {
    final local = fecha.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _crearBackup() async {
    final backupService = BackupService();
    final exito = await backupService.crearBackupYCompartir();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exito
              ? '✅ Backup creado y compartido'
              : '❌ Error al crear el backup'),
          backgroundColor: exito ? const Color(0xFF10B981) : Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CONFIGURACIÓN DE SECCIONES DEL MENÚ
  // ============================================================
  List<MenuSection> _getMenuSections() {
    final usuario = ref.read(usuarioActualProvider);
    final bool esAdmin = usuario?.rol == 'admin';
    final bool tieneTurno = _turnoAbierto != null;

    final opcionesPrincipales = [
      MenuOption(
        title: 'Panel de Control',
        subtitle: 'Estadísticas y métricas del negocio',
        icon: Icons.dashboard_rounded,
        color: const Color(0xFF3B82F6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
        title: 'Volver al Catálogo',
        subtitle: 'Pantalla de ventas y cobro',
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFF10B981),
        onTap: () => Navigator.pop(context),
      ),
      MenuOption(
        title: tieneTurno ? 'Cerrar Turno' : 'Abrir Turno',
        subtitle: tieneTurno ? 'Finalizar jornada' : 'Iniciar jornada laboral',
        icon: tieneTurno ? Icons.stop_rounded : Icons.play_arrow_rounded,
        color: tieneTurno ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        onTap: tieneTurno ? _cerrarTurno : _abrirTurno,
      ),
      MenuOption(
        title: 'Sincronizar Datos',
        subtitle: _sincronizando
            ? 'Enviando datos a la nube...'
            : '$_ventasPendientesSync pendientes',
        icon: Icons.sync_rounded,
        color: _ventasPendientesSync > 0
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981),
        onTap: _sincronizarTodo,
      ),
      MenuOption(
        title: 'Configurar Impresora',
        subtitle: 'Seleccionar y probar impresora POS',
        icon: Icons.print_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => showDialog(
          context: context,
          builder: (context) => const PrinterSelectionDialog(),
        ),
      ),
    ];

    final opcionesAdmin = [
      MenuOption(
        title: 'Monitor de Empleados',
        subtitle: 'Estado de cajeros conectados',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF3B82F6),
        onTap: () => showDialog(
          context: context,
          builder: (context) => const monitor.EmployeeMonitorDialog(),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
        title: 'Gestión de Personal',
        subtitle: 'Crear y administrar admins y cajeros',
        icon: Icons.admin_panel_settings_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => showDialog(
          context: context,
          builder: (context) => const PersonnelManagementDialog(),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
        title: 'Historial de Ventas',
        subtitle: 'Ventas del día y turnos',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SalesHistoryScreen()),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
        title: 'Registrar Gasto',
        subtitle: 'Agregar egresos del día',
        icon: Icons.money_off_rounded,
        color: const Color(0xFFEF4444),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GastosScreen()),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
        title: 'Cierre de Caja',
        subtitle: 'Arqueo y balance del día',
        icon: Icons.money_off_csred_rounded,
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CashClosingScreen()),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
        title: 'Backup de Datos',
        subtitle: 'Crear y compartir copia de seguridad',
        icon: Icons.backup_rounded,
        color: const Color(0xFFF59E0B),
        onTap: _crearBackup,
        isAdminOnly: true,
      ),
    ];

    final opcionesConfiguracion = [
      MenuOption(
        title: 'Ajustes de Usuario',
        subtitle: 'Nombre, PIN, tema y más',
        icon: Icons.settings_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserSettingsScreen(
              usuarioLogueado: usuario!,
            ),
          ),
        ),
      ),
      if (esAdmin)
        MenuOption(
          title: 'Cambiar de Empresa',
          subtitle: 'Seleccionar otra organización',
          icon: Icons.business_center,
          color: const Color(0xFF8B5CF6),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cambiar de Empresa'),
                content: const Text('Esto cerrará la sesión y reiniciará la aplicación. ¿Continuar?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            );
            if (confirm != true) return;

            await ref.read(authProvider.notifier).logout();
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('supabase_url');
            await prefs.remove('supabase_anon_key');
            await prefs.remove('empresa_id');

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ConfiguracionEmpresaScreen()),
              );
            }
          },
          isAdminOnly: true,
        ),
    ];

    final opcionSalir = MenuOption(
      title: 'Salir del POS',
      subtitle: 'Cerrar sesión y volver al login',
      icon: Icons.logout_rounded,
      color: const Color(0xFFEF4444),
      onTap: _logout,
    );

    final List<MenuSection> secciones = [];

    secciones.add(
      MenuSection(
        title: 'Acciones principales',
        icon: Icons.star_rounded,
        options: opcionesPrincipales,
      ),
    );

    if (esAdmin) {
      secciones.add(
        MenuSection(
          title: 'Administración y reportes',
          icon: Icons.analytics_rounded,
          options: opcionesAdmin,
        ),
      );
    }

    if (opcionesConfiguracion.isNotEmpty) {
      secciones.add(
        MenuSection(
          title: 'Configuración y utilidades',
          icon: Icons.tune_rounded,
          options: opcionesConfiguracion,
        ),
      );
    }

    secciones.add(
      MenuSection(
        title: 'Cerrar sesión',
        icon: Icons.exit_to_app_rounded,
        options: [opcionSalir],
      ),
    );

    return secciones;
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final tieneTurno = _turnoAbierto != null;
    final usuario = ref.read(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';

    final secciones = _getMenuSections()
        .map((section) {
          final opcionesFiltradas = section.options
              .where((opt) => !opt.isAdminOnly || esAdmin)
              .toList();
          return MenuSection(
            title: section.title,
            icon: section.icon,
            options: opcionesFiltradas,
          );
        })
        .where((section) => section.options.isNotEmpty)
        .toList();

    int crossAxisCount;
    double childAspectRatio;
    if (isMobile) {
      crossAxisCount = 1;
      childAspectRatio = 4.5;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 5.0;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 5.0;
    }

    final contenido = Column(
      children: [
        TurnoStatusBanner(
          tieneTurno: tieneTurno,
          horaApertura: tieneTurno ? _formatearHora(_turnoAbierto!.fechaApertura) : null,
          onAbrirTurno: _abrirTurno,
          onCerrarTurno: _cerrarTurno,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                for (var section in secciones) ...[
                  _buildSectionTitle(section.title, section.icon, isMobile),
                  const SizedBox(height: 8),
                  _buildOptionsGrid(
                    section.options,
                    crossAxisCount,
                    childAspectRatio,
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Panel de Control',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 2,
          actions: [
            if (usuario != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: theme.appBarTheme.foregroundColor?.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      usuario.nombre,
                      style: TextStyle(
                        color: theme.appBarTheme.foregroundColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: contenido,
      );
    } else {
      return contenido;
    }
  }

  // ==========================================
  // TÍTULO DE SECCIÓN CON ESTILO MEJORADO
  // ==========================================
  Widget _buildSectionTitle(String title, IconData? icon, bool isMobile) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isMobile ? 18 : 22,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            height: 1,
            width: isMobile ? 40 : 80,
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GRID DE OPCIONES CON ANIMACIÓN
  // ==========================================
  Widget _buildOptionsGrid(
    List<MenuOption> options,
    int crossAxisCount,
    double childAspectRatio,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
      child: AnimationLimiter(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: crossAxisCount,
              child: ScaleAnimation(
                scale: 0.8,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  curve: Curves.easeOutCubic,
                  child: _buildMenuCard(
                    context,
                    option: option,
                    isMobile: isMobile,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // TARJETA DE MENÚ
  // ==========================================
  Widget _buildMenuCard(BuildContext context, {
    required MenuOption option,
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder(
        valueListenable: isHovered,
        builder: (context, hovered, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: hovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  option.color.withValues(alpha: hovered ? 0.15 : 0.05),
                  option.color.withValues(alpha: hovered ? 0.25 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: option.color.withValues(alpha: hovered ? 0.6 : 0.15),
                width: hovered ? 2 : 1,
              ),
              boxShadow: hovered
                  ? [
                      BoxShadow(
                        color: option.color.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: option.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: option.color.withValues(alpha: hovered ? 0.2 : 0.12),
                          shape: BoxShape.circle,
                          boxShadow: hovered
                              ? [
                                  BoxShadow(
                                    color: option.color.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          option.icon,
                          size: isMobile ? 24 : 30,
                          color: option.color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              option.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 15 : 18,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: isMobile ? 11 : 13,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: isMobile ? 14 : 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}