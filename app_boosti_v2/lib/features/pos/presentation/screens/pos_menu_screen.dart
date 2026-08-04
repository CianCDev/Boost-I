import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/isar_service.dart';
import '../widgets/admin_validation_dialog.dart';
import 'cash_closing_screen.dart';
import 'sales_history_screen.dart';
import '../widgets/monitor_empleado_widget.dart';
import '../widgets/gestion_personal_dialog.dart';
import '../widgets/cambiar_pin_dialog.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../services/backup_service.dart'; // Nuevo servicio
import 'login_screen.dart'; // Para navegar al login
import 'gastos_screen.dart';

class PosMenuScreen extends ConsumerStatefulWidget {
  const PosMenuScreen({super.key});

  @override
  ConsumerState<PosMenuScreen> createState() => _PosMenuScreenState();
}

class _PosMenuScreenState extends ConsumerState<PosMenuScreen> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();
  int _ventasPendientesSync = 0;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _cargarEstadoSync();
  }

  Future<void> _cargarEstadoSync() async {
    final pendientes = await _isarService.obtenerVentasPendientesSync();
    if (mounted) {
      setState(() => _ventasPendientesSync = pendientes.length);
    }
  }

  Future<void> _sincronizarVentas() async {
    if (_ventasPendientesSync == 0 || _sincronizando) return;
    setState(() => _sincronizando = true);
    try {
      final sincronizadas = await _syncService.sincronizarVentasPendientes();
      await _cargarEstadoSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡$sincronizadas ventas sincronizadas! 🎉'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al sincronizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  /// Cierra sesión y navega al LoginScreen
  Future<void> _logout() async {
    // Mostrar diálogo de confirmación
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

    // Cerrar sesión en el provider
    await ref.read(authProvider.notifier).logout();

    // Limpiar el usuario actual
    ref.read(usuarioActualProvider.notifier).clearUsuario();

    if (mounted) {
      // Navegar al LoginScreen y eliminar todo el stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Ejecuta el backup y muestra feedback
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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final usuarioLogueado = ref.read(usuarioActualProvider);
    final bool esAdmin = usuarioLogueado?.rol == 'admin';

    // ==========================================
    // LISTA DE OPCIONES DEL MENÚ (ORDENADA)
    // ==========================================
    final List<Map<String, dynamic>> menuOptions = [
      // 1. Siempre visible
      {
        'title': 'Volver al Catálogo',
        'subtitle': 'Pantalla de ventas y cobro',
        'icon': Icons.point_of_sale_rounded,
        'color': const Color(0xFF10B981),
        'onTap': () => Navigator.pop(context),
      },
      {
        'title': 'Sincronizar Datos',
        'subtitle': _sincronizando
            ? 'Enviando datos a la nube...'
            : '$_ventasPendientesSync pendientes',
        'icon': Icons.sync_rounded,
        'color': _ventasPendientesSync > 0
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981),
        'onTap': _sincronizarVentas,
      },

      // 2. Opciones solo para Administradores
      if (esAdmin) ...[
        {
          'title': 'Monitor de Empleados',
          'subtitle': 'Estado de cajeros conectados',
          'icon': Icons.people_alt_rounded,
          'color': const Color(0xFF3B82F6),
          'onTap': () => showDialog(
            context: context,
            builder: (context) => const EmployeeMonitorDialog(),
          ),
        },
        {
          'title': 'Gestión de Personal',
          'subtitle': 'Crear y administrar admins y cajeros',
          'icon': Icons.admin_panel_settings_rounded,
          'color': const Color(0xFF8B5CF6),
          'onTap': () => showDialog(
            context: context,
            builder: (context) => const PersonnelManagementDialog(),
          ),
        },

        {
        'title': 'Registrar Gasto',
        'subtitle': 'Agregar egresos del día',
        'icon': Icons.money_off_rounded,
        'color': const Color(0xFFEF4444),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GastosScreen()),
        ),
      },
        {
          'title': 'Cambiar mi Clave',
          'subtitle': 'Actualizar PIN de acceso',
          'icon': Icons.lock_reset_rounded,
          'color': const Color(0xFF0EA5E9),
          'onTap': () {
            final usuarioActual = ref.read(usuarioActualProvider);
            if (usuarioActual == null) return;

            if (usuarioActual.rol == 'admin') {
              showDialog(
                context: context,
                builder: (context) => AdminPinChangeDialog(
                  admin: usuarioActual,
                  isarService: _isarService,
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => AdminValidationDialog(
                  onSuccess: () {
                    showDialog(
                      context: context,
                      builder: (context) => CashierPinChangeDialog(
                        cajero: usuarioActual,
                        isarService: _isarService,
                      ),
                    );
                  },
                  onCancel: () => Navigator.of(context).pop(),
                ),
              );
            }
          },
        },
        {
          'title': 'Historial de Ventas',
          'subtitle': 'Ventas del día y turnos',
          'icon': Icons.receipt_long_rounded,
          'color': const Color(0xFF8B5CF6),
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalesHistoryScreen()),
          ),
        },
        {
          'title': 'Backup de Datos', // 🔥 NUEVO
          'subtitle': 'Crear y compartir copia de seguridad',
          'icon': Icons.backup_rounded,
          'color': const Color(0xFFF59E0B),
          'onTap': _crearBackup,
        },
        {
          'title': 'Cierre de Caja',
          'subtitle': 'Arqueo y balance del día',
          'icon': Icons.money_off_csred_rounded,
          'color': const Color(0xFFF59E0B),
          'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CashClosingScreen()),
          ),
        },
      ],

      // 3. Opciones para ambos roles (siempre visibles)
      {
        'title': 'Salir del POS',
        'subtitle': 'Cerrar sesión y volver al login',
        'icon': Icons.logout_rounded,
        'color': const Color(0xFFEF4444),
        'onTap': _logout, // 🔥 Ahora usa el método que cierra sesión
      },
      {
        'title': 'Modo Oscuro',
        'subtitle': 'Activar o desactivar tema oscuro',
        'icon': Icons.dark_mode,
        'color': Colors.amber,
        'onTap': null,
        'isSwitch': true,
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Panel de Control POS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColorDark,
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            childAspectRatio: isMobile ? 1.6 : 1.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: menuOptions.length,
          itemBuilder: (context, index) {
            final option = menuOptions[index];
            if (option['isSwitch'] == true) {
              return _buildThemeSwitch(context);
            }
            return _buildMenuCard(
              context,
              title: option['title'],
              subtitle: option['subtitle'],
              icon: option['icon'],
              color: option['color'],
              onTap: option['onTap'],
              isMobile: isMobile,
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET DE SWITCH DE TEMA (mejorado)
  // ==========================================
  Widget _buildThemeSwitch(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeModeProvider);
        final isDark = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        final theme = Theme.of(context);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 48,
                  color: isDark ? Colors.amber : Colors.orange,
                ),
                const SizedBox(height: 8),
                Text(
                  isDark ? 'Modo Oscuro' : 'Modo Claro',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Switch(
                  value: isDark,
                  onChanged: (_) {
                    final nuevoModo = isDark ? ThemeMode.light : ThemeMode.dark;
                    ref.read(themeModeProvider.notifier).state = nuevoModo;
                  },
                  activeThumbColor: Colors.amber,
                ),
                Text(
                  isDark ? 'Activado' : 'Desactivado',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TARJETA DE MENÚ (con tema oscuro)
  // ==========================================
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required bool isMobile,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: isMobile ? 32 : 48, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isMobile ? 12 : 14,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}