import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/isar_service.dart';
import '../widgets/admin_validation_dialog.dart';
import 'cash_closing_screen.dart';
import 'configuracion_empresa_screen.dart';
import 'sales_history_screen.dart';
import '../widgets/monitor_empleado_widget.dart';
import '../widgets/gestion_personal_dialog.dart';
import '../widgets/cambiar_pin_dialog.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../services/backup_service.dart';
import 'login_screen.dart';
import 'gastos_screen.dart';
import '../../data/Local/entities/turno_entity.dart';

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
  TurnoEntity? _turnoAbierto;

  @override
  void initState() {
    super.initState();
    _cargarEstadoSync();
    _cargarEstadoTurno();
  }

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

    final montoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Turno'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monto inicial: \$${turnoAbierto.montoInicial.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              TextFormField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto final (USD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Número válido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Cerrar Turno'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final montoFinal = double.parse(montoController.text);
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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final usuarioLogueado = ref.read(usuarioActualProvider);
    final bool esAdmin = usuarioLogueado?.rol == 'admin';
    final bool tieneTurno = _turnoAbierto != null;

    // ==========================================
    // LISTA DE OPCIONES DEL MENÚ
    // ==========================================
    final List<Map<String, dynamic>> menuOptions = [
      // 1. Siempre visibles
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
        'onTap': _sincronizarTodo,
      },

      // ✅ 2. ÚNICO BOTÓN DINÁMICO PARA TURNOS
      {
        'title': tieneTurno ? 'Cerrar Turno' : 'Abrir Turno',
        'subtitle': tieneTurno ? 'Finalizar jornada' : 'Iniciar jornada laboral',
        'icon': tieneTurno ? Icons.stop_rounded : Icons.play_arrow_rounded,
        'color': tieneTurno ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        'onTap': tieneTurno ? _cerrarTurno : _abrirTurno,
      },

      // 3. Opciones solo para Administradores
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
          'title': 'Cambiar de Empresa',
          'subtitle': 'Seleccionar otra organización',
          'icon': Icons.business_center,
          'color': const Color(0xFF8B5CF6),
          'onTap': () async {
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
          'title': 'Backup de Datos',
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

      // 4. Opciones para ambos roles (siempre visibles)
      {
        'title': 'Salir del POS',
        'subtitle': 'Cerrar sesión y volver al login',
        'icon': Icons.logout_rounded,
        'color': const Color(0xFFEF4444),
        'onTap': _logout,
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
      body: Column(
        children: [
          // ==========================================
          // BANNER DE ESTADO DE TURNO
          // ==========================================
          if (!tieneTurno)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ No tienes un turno abierto. Abre un turno para comenzar a vender.',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _abrirTurno,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                    ),
                    child: const Text('Abrir Turno'),
                  ),
                ],
              ),
            ),
          if (tieneTurno)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.shade100,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ Turno abierto (iniciado: ${_formatearHora(_turnoAbierto!.fechaApertura)})',
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                ],
              ),
            ),

          // ==========================================
          // GRID DE OPCIONES
          // ==========================================
          Expanded(
            child: Padding(
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
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TARJETA DE MENÚ
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