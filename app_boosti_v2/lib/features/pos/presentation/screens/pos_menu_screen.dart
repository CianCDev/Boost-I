// ignore_for_file: use_build_context_synchronously

import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/pedido/pedidos_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/menu/diagnostico_lote_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

import '../providers/auth_provider.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/isar_service.dart';
import '../widgets/menu/turno_status_banner.dart';
import 'audit_log_screen.dart';
import 'cash_closing_screen.dart';
import 'configuracion_empresa_screen.dart';
import 'sales_history_screen.dart';
import '../widgets/monitor_empleado_widget.dart' as monitor;
import '../widgets/gestion_personal_dialog.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../services/backup_service.dart';
import 'login_screen.dart';
import 'gastos_screen.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../widgets/printer_selection_widget.dart';
import 'user_settings_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/proveedores/proveedores_screen.dart';
import '../screens/departamentos/departamentos_screen.dart';
import '../screens/locales/locales_screen.dart';
import '../screens/telegram/telegram_config_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/departamentos/departamentos_screen.dart';

// y usas DepartamentosScreen



// ✅ IMPORT DEL NUEVO DIÁLOGO DE DIAGNÓSTICO
import '../widgets/appbar.dart';
import '../widgets/menu/turno_closing_dialog.dart'; // Importar el nuevo diálogo

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

class MenuSection {
  final String title;
  final IconData? icon;
  final Color? sectionColor;
  final List<MenuOption> options;

  const MenuSection({
    required this.title,
    this.icon,
    this.sectionColor,
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

  // ============================================================
  // DIÁLOGO DE ÉXITO CON LOTTIE (AGRANDADO)
  // ============================================================
  void _mostrarDialogoExito(String titulo, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
        contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 32),
            const SizedBox(width: 12),
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie con fallback
            _buildLottieWithFallback('assets/animations/Clock Alarm Animation.json'),
            const SizedBox(height: 20),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Aceptar'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para cargar Lottie con fallback
  Widget _buildLottieWithFallback(String assetPath) {
    try {
      await _actualizarProgreso('Sincronizando ventas...');
      final result = await _syncService.sincronizarTodoConResumen();

      Navigator.pop(context);

    final mensaje = StringBuffer('✅ Sincronización completada\n');
if (result['ventas']! > 0) mensaje.writeln('• ${result['ventas']} ventas');
if (result['productos']! > 0) mensaje.writeln('• ${result['productos']} productos');
if (result['proveedores']! > 0) mensaje.writeln('• ${result['proveedores']} proveedores');
if (result['gastos']! > 0) mensaje.writeln('• ${result['gastos']} gastos');
if (result['pedidos']! > 0) mensaje.writeln('• ${result['pedidos']} pedidos');
if (result['lotes']! > 0) mensaje.writeln('• ${result['lotes']} lotes');
if (result['locales']! > 0) mensaje.writeln('• ${result['locales']} locales');
if (result['departamentos']! > 0) mensaje.writeln('• ${result['departamentos']} departamentos');
if (result['telegram']! > 0) mensaje.writeln('• ${result['telegram']} configuraciones de Telegram');
if (result.values.every((v) => v == 0)) mensaje.writeln('Todo estaba sincronizado ✅');
      if (!currentContext.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(mensaje.toString()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      return Lottie.asset(
        assetPath,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.timer,
            size: 100,
            color: const Color(0xFF10B981),
          );
        },
      );
    } catch (e) {
      return Icon(
        Icons.timer,
        size: 100,
        color: const Color(0xFF10B981),
      );
    }
  }

  // ============================================================
  // ABRIR TURNO
  // ============================================================
  Future<void> _abrirTurno() async {
    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay usuario autenticado.')),
        );
      }
      return;
    }

    final turnoExistente = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
    if (turnoExistente != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya tienes un turno abierto.')),
        );
      }
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
    await _isarService.guardarLog(
      LogEntity()
        ..accion = 'APERTURA_TURNO'
        ..usuarioNombre = usuario.nombre
        ..usuarioRol = usuario.rol
        ..detalles = 'Caja: ${usuario.cajaAsignada}'
        ..fecha = DateTime.now()
        ..sincronizado = false,
    );

    await _cargarEstadoTurno();

    if (mounted) {
      _mostrarDialogoExito('Turno abierto', 'El turno se ha iniciado correctamente.');
    }
  }

  // ============================================================
  // CERRAR TURNO
  // ============================================================
  Future<void> _cerrarTurno() async {
    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay usuario autenticado.')),
        );
      }
      return;
    }

    final turnoAbierto = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
    if (turnoAbierto == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay turno abierto para este usuario.')),
        );
      }
      return;
    }

    // Descargar ventas de Supabase para tener datos actualizados
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

    // ✅ Usar el diálogo personalizado moderno
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TurnoClosingDialog(
        montoInicial: turnoAbierto.montoInicial,
        montoFinal: montoFinal,
        fechaApertura: turnoAbierto.fechaApertura,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirm == true) {
      // Cerrar turno
      turnoAbierto.montoFinal = montoFinal;
      turnoAbierto.fechaCierre = DateTime.now();
      turnoAbierto.estado = 'cerrado';
      turnoAbierto.syncStatus = 'pending';

      await _isarService.guardarTurno(turnoAbierto);
      await _isarService.actualizarEstadoUsuario(usuario.id, 'inactivo');
      await _syncService.sincronizarTurnos();
      await _isarService.guardarLog(
        LogEntity()
          ..accion = 'CIERRE_TURNO'
          ..usuarioNombre = usuario.nombre
          ..usuarioRol = usuario.rol
          ..detalles = 'Monto final: \$${montoFinal.toStringAsFixed(2)}'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );

      await _cargarEstadoTurno();

      if (mounted) {
        _mostrarDialogoExito(
          'Turno cerrado',
          'El turno se ha cerrado correctamente.\nMonto final: \$${montoFinal.toStringAsFixed(2)}',
        );
      }
    }
  }

  // ============================================================
  // SINCRONIZAR CON PROGRESO
  // ============================================================
  Future<void> _sincronizarConProgreso() async {
    if (_sincronizando) return;
    setState(() => _sincronizando = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentContext = context;

    String mensajeProgreso = 'Iniciando sincronización...';
    bool sincronizacionActiva = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: const Text('Sincronizando...'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    mensajeProgreso,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    sincronizacionActiva = false;
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (!sincronizacionActiva) {
      setState(() => _sincronizando = false);
      return;
    }

    try {
      await _actualizarProgreso('Sincronizando ventas...');
      final result = await _syncService.sincronizarTodoConResumen();

      Navigator.pop(context);

      final mensaje = StringBuffer('✅ Sincronización completada\n');
      if (result['ventas']! > 0) mensaje.writeln('• ${result['ventas']} ventas');
      if (result['productos']! > 0) mensaje.writeln('• ${result['productos']} productos');
      if (result['proveedores']! > 0) mensaje.writeln('• ${result['proveedores']} proveedores');
      if (result['gastos']! > 0) mensaje.writeln('• ${result['gastos']} gastos');
      if (result['pedidos']! > 0) mensaje.writeln('• ${result['pedidos']} pedidos');
      if (result['lotes']! > 0) mensaje.writeln('• ${result['lotes']} lotes');
      if (result.values.every((v) => v == 0)) mensaje.writeln('Todo estaba sincronizado ✅');

      if (!currentContext.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(mensaje.toString()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      try {
        Navigator.pop(context);
      } catch (_) {}

      if (!currentContext.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al sincronizar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      debugPrint('❌ Error en sincronización: $e');
    } finally {
      if (mounted) {
        setState(() => _sincronizando = false);
        _cargarEstadoSync();
      }
    }
  }

  Future<void> _actualizarProgreso(String mensaje) async {
    debugPrint('📌 $mensaje');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ============================================================
  // OTRAS ACCIONES
  // ============================================================
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
        onTap: _sincronizarConProgreso,
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
        title: 'Auditoría',
        subtitle: 'Registro de eventos del sistema',
        icon: Icons.history_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuditLogScreen()),
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
        title: 'Pedidos a Proveedores',
        subtitle: 'Crear y gestionar pedidos',
        icon: Icons.local_shipping_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PedidosProveedorScreen(),
          ),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
  title: 'Gestión de Locales',
  subtitle: 'Crear y administrar sedes/tiendas',
  icon: Icons.storefront_rounded,
  color: const Color(0xFF3B82F6),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LocalesScreen()),
  ),
  isAdminOnly: true,
),
MenuOption(
  title: 'Gestión de Departamentos',
  subtitle: 'Crear y administrar departamentos',
  icon: Icons.business_center_rounded,
  color: const Color(0xFF8B5CF6),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DepartamentosScreen()),
  ),
  isAdminOnly: true,
),
      MenuOption(
        title: 'Proveedores',
        subtitle: 'Gestionar proveedores',
        icon: Icons.business_center_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProveedoresScreen(),
          ),
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
      MenuOption(
        title: 'Diagnóstico de Lotes',
        subtitle: 'Verificar estado del inventario por lotes',
        icon: Icons.analytics_rounded,
        color: const Color(0xFF3B82F6),
        onTap: () => showDialog(
          context: context,
          builder: (_) => const DiagnosticoLotesDialog(),
        ),
        isAdminOnly: true,
      ),
      MenuOption(
  title: 'Configurar Telegram',
  subtitle: 'Bot de notificaciones y comandos',
  icon: Icons.telegram,
  color: const Color(0xFF10B981),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const TelegramConfigScreen()),
  ),
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
        sectionColor: const Color(0xFF3B82F6),
        options: opcionesPrincipales,
      ),
    );

    if (esAdmin) {
      secciones.add(
        MenuSection(
          title: 'Administración y reportes',
          icon: Icons.analytics_rounded,
          sectionColor: const Color(0xFF8B5CF6),
          options: opcionesAdmin,
        ),
      );
    }

    if (opcionesConfiguracion.isNotEmpty) {
      secciones.add(
        MenuSection(
          title: 'Configuración y utilidades',
          icon: Icons.tune_rounded,
          sectionColor: const Color(0xFFF59E0B),
          options: opcionesConfiguracion,
        ),
      );
    }

    secciones.add(
      MenuSection(
        title: 'Cerrar sesión',
        icon: Icons.exit_to_app_rounded,
        sectionColor: const Color(0xFFEF4444),
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
            sectionColor: section.sectionColor,
            options: opcionesFiltradas,
          );
        })
        .where((section) => section.options.isNotEmpty)
        .toList();

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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (var section in secciones) ...[
                  _buildSectionTitle(section.title, section.icon, section.sectionColor, isMobile),
                  const SizedBox(height: 8),
                  _buildOptionsGrid(
                    section.options,
                    isMobile,
                    isTablet,
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
      final gradient = theme.brightness == Brightness.dark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5352ED), Color(0xFF4840E8), Color(0xFF5955EE)],
            );

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Panel de Control',
          logoAsset: 'assets/logo.svg',
          logoSize: 28,
          gradient: gradient,
          showBackButton: true,
          actions: [
            if (usuario != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      usuario.nombre,
                      style: const TextStyle(
                        color: Colors.white,
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
  // TÍTULO DE SECCIÓN
  // ==========================================
  Widget _buildSectionTitle(String title, IconData? icon, Color? color, bool isMobile) {
    final theme = Theme.of(context);
    final Color accentColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isMobile ? 16 : 20,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Container(
            height: 1.5,
            width: isMobile ? 30 : 60,
            color: accentColor.withValues(alpha: 0.2),
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
    bool isMobile,
    bool isTablet,
  ) {
    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 2;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
      child: AnimationLimiter(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 5.0 : 6.0,
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
                scale: 0.85,
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
  // TARJETA DE MENÚ CON CURSOR POINTER
  // ==========================================
  Widget _buildMenuCard(BuildContext context, {
    required MenuOption option,
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final isHovered = ValueNotifier<bool>(false);
    final bool isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click, // ✅ Cursor pointer
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder(
        valueListenable: isHovered,
        builder: (context, hovered, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            // ignore: deprecated_member_use
            transform: hovered ? (Matrix4.identity()..scale(1.01)) : Matrix4.identity(),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hovered
                    ? option.color.withValues(alpha: 0.6)
                    : isDark
                        ? Colors.grey.shade700.withValues(alpha: 0.4)
                        : Colors.grey.shade300.withValues(alpha: 0.6),
                width: hovered ? 1.5 : 1.0,
              ),
              boxShadow: hovered
                  ? [
                      BoxShadow(
                        color: option.color.withValues(alpha: 0.2),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: option.onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 20,
                    vertical: isMobile ? 10 : 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: option.color.withValues(alpha: hovered ? 0.2 : 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          option.icon,
                          size: isMobile ? 22 : 28,
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
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 15 : 17,
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
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
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