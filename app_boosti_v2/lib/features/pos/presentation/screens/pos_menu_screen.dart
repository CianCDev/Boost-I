import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/isar_service.dart';
import 'cash_closing_screen.dart';
import 'sales_history_screen.dart';
import '../widgets/monitor_empleado_widget.dart';
import '../widgets/gestion_personal_dialog.dart';
import '../widgets/cambiar_pin_dialog.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../../presentation/providers/theme_provider.dart';

class PosMenuScreen extends ConsumerStatefulWidget {
  const PosMenuScreen({super.key});

  @override
  ConsumerState<PosMenuScreen> createState() => _PosMenuScreenState();
}

class _PosMenuScreenState extends ConsumerState<PosMenuScreen> {
  final IsarService _isarService = IsarService();
  int _ventasPendientesSync = 0;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _cargarEstadoSync();
  }

  Future<void> _cargarEstadoSync() async {
    final pendientes = await _isarService.contarVentasPendientesSync();
    if (mounted) setState(() => _ventasPendientesSync = pendientes);
  }

  Future<void> _sincronizarVentas() async {
    if (_ventasPendientesSync == 0 || _sincronizando) return;
    setState(() => _sincronizando = true);
    try {
      final sincronizadas = await _isarService.sincronizarVentasConServidor();
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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> menuOptions = [
      {
        'title': 'Volver al Catálogo',
        'subtitle': 'Pantalla de ventas y cobro',
        'icon': Icons.point_of_sale_rounded,
        'color': const Color(0xFF10B981),
        'onTap': () => Navigator.pop(context),
      },
      {
        'title': 'Sincronizar Datos',
        'subtitle': _sincronizando ? 'Enviando datos a la nube...' : '$_ventasPendientesSync pendientes',
        'icon': Icons.sync_rounded,
        'color': _ventasPendientesSync > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
        'onTap': _sincronizarVentas,
      },
      {
        'title': 'Monitor de Empleados',
        'subtitle': 'Estado de cajeros conectados',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF3B82F6),
        'onTap': () => showDialog(context: context, builder: (context) => const EmployeeMonitorDialog()),
      },
      {
        'title': 'Gestión de Personal',
        'subtitle': 'Crear y administrar admins y cajeros',
        'icon': Icons.admin_panel_settings_rounded,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => showDialog(context: context, builder: (context) => const PersonnelManagementDialog()),
      },
      {
        'title': 'Cambiar mi Clave',
        'subtitle': 'Actualizar PIN de acceso',
        'icon': Icons.lock_reset_rounded,
        'color': const Color(0xFF0EA5E9),
        'onTap': () {
          final usuarioActual = ref.read(usuarioActualProvider);
          if (usuarioActual != null) {
            showDialog(
              context: context,
              builder: (context) => ChangePinDialog(usuario: usuarioActual),
            );
          }
        },
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromRGBO(72, 111, 238, 1), Color.fromARGB(255, 85, 59, 235)],
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

  // Widget para el switch de tema (AHORA CON COLORES DINÁMICOS)
  Widget _buildThemeSwitch(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeModeProvider);
        final isDark = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: theme.cardColor, // ← Dinámico
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color, // ← Dinámico
                  ),
                ),
                const SizedBox(height: 4),
                Switch(
                  value: isDark,
                  onChanged: (_) {
                    final nuevoModo = isDark ? ThemeMode.light : ThemeMode.dark;
                    ref.read(themeModeProvider.notifier).state = nuevoModo;
                  },
                  activeColor: Colors.amber,
                ),
                Text(
                  isDark ? 'Activado' : 'Desactivado',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), // ← Dinámico
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
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
                  color: color.withOpacity(0.1),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 22,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
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