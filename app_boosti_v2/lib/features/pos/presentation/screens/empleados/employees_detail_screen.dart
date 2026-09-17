// lib/features/pos/presentation/screens/empleados/employee_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/horario_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/log_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/models/empleado_view_model.dart';
import '../../../domain/permissions/roles.dart';
import '../../providers/empleados/empleados_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/empleado/empleado_form_dialog.dart';


/// Pantalla de ficha completa de un empleado.
class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final int empleadoId;

  const EmployeeDetailScreen({super.key, required this.empleadoId});

  static Future<void> push(BuildContext context, int empleadoId) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeDetailScreen(empleadoId: empleadoId),
      ),
    );
  }

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState
    extends ConsumerState<EmployeeDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _colorPrimary = Color(0xFF10B981);

  late final TabController _tabController;
  HorarioEntity? _horario;
  UsuarioEntity? _supervisor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════

  EmpleadoViewModel? _buscarEmpleado(List<EmpleadoViewModel> lista) {
    try {
      return lista.firstWhere((e) => e.id == widget.empleadoId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cargarDatosRelacionados(EmpleadoViewModel empleado) async {
    if (empleado.horarioId != null && _horario == null) {
      final isar = await IsarService().db;
      final h = await isar.horarioEntitys.get(empleado.horarioId!);
      if (mounted) setState(() => _horario = h);
    }
    if (empleado.supervisorId != null && _supervisor == null) {
      final isar = IsarService();
      final s = await isar.obtenerUsuarioPorId(empleado.supervisorId!);
      if (mounted) setState(() => _supervisor = s);
    }
  }

  Future<void> _editar(EmpleadoViewModel empleado) async {
    final guardado = await EmployeeFormDialog.show(
      context,
      empleado: empleado,
    );
    if (guardado == true) {
      ref.invalidate(empleadosProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Empleado actualizado'),
          backgroundColor: _colorPrimary,
        ),
      );
    }
  }

  Future<void> _toggleActivo(EmpleadoViewModel empleado) async {
    final usuario = empleado.usuario;
    final usuarioActual = ref.read(usuarioActualProvider);

    // Si está activo → desactivar (con confirmación)
    if (usuario.activo) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Desactivar empleado'),
          content: Text(
            '${usuario.nombre} no podrá iniciar sesión, pero sus datos se conservan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Desactivar'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    usuario.activo = !usuario.activo;
    usuario.updatedAt = DateTime.now();
    usuario.sincronizado = false;

    await IsarService().guardarUsuario(usuario);
    await IsarService().guardarLog(
      LogEntity()
        ..accion = usuario.activo ? 'EMPLEADO_ACTIVADO' : 'EMPLEADO_DESACTIVADO'
        ..usuarioNombre = usuarioActual?.nombre ?? 'Sistema'
        ..usuarioRol = usuarioActual?.rol ?? '-'
        ..detalles = '${usuario.nombre} (ID: ${usuario.id})'
        ..fecha = DateTime.now()
        ..sincronizado = false,
    );

    ref.invalidate(empleadosProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          usuario.activo ? 'Empleado activado' : 'Empleado desactivado',
        ),
        backgroundColor: usuario.activo
            ? _colorPrimary
            : const Color(0xFFEF4444),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final empleadosAsync = ref.watch(empleadosProvider);
    final usuarioActual = ref.watch(usuarioActualProvider);
    final role = UserRole.fromString(usuarioActual?.rol);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return empleadosAsync.when(
      loading: () => Scaffold(
        appBar: CustomAppBar(
          title: 'Empleado',
          showBackButton: true,
          gradient: const LinearGradient(
            colors: [_colorPrimary, Color(0xFF059669)],
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: _colorPrimary),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: CustomAppBar(
          title: 'Empleado',
          showBackButton: true,
          gradient: const LinearGradient(
            colors: [_colorPrimary, Color(0xFF059669)],
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $e'),
          ),
        ),
      ),
      data: (lista) {
        final empleado = _buscarEmpleado(lista);
        if (empleado == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Empleado',
              showBackButton: true,
              gradient: const LinearGradient(
                colors: [_colorPrimary, Color(0xFF059669)],
              ),
            ),
            body: const Center(child: Text('Empleado no encontrado')),
          );
        }

        // Cargar horario y supervisor en background
        _cargarDatosRelacionados(empleado);

        final puedeEditar = Permissions.canEditEmployeeBasicInfo(role);
        final esAdmin = role == UserRole.admin;

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLow,
          appBar: CustomAppBar(
            title: empleado.nombre,
            showBackButton: true,
            gradient: const LinearGradient(
              colors: [_colorPrimary, Color(0xFF059669)],
            ),
            actions: [
              if (puedeEditar)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Editar',
                  onPressed: () => _editar(empleado),
                ),
              if (esAdmin)
                IconButton(
                  icon: Icon(
                    empleado.activo
                        ? Icons.person_off_outlined
                        : Icons.person_outline,
                    color: Colors.white,
                  ),
                  tooltip: empleado.activo ? 'Desactivar' : 'Activar',
                  onPressed: () => _toggleActivo(empleado),
                ),
            ],
          ),
          body: Column(
            children: [
              _buildHero(empleado, colorScheme),
              _buildTabs(colorScheme, role),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _tabResumen(empleado, colorScheme, isMobile),
                    _tabLaboral(empleado, colorScheme, isMobile),
                    _tabHorario(empleado, colorScheme, isMobile),
                    _tabPlaceholder(
                      'Ventas',
                      'Estadísticas de ventas del empleado',
                      Icons.receipt_long_rounded,
                      colorScheme,
                    ),
                    _tabPlaceholder(
                      'Nómina',
                      'Historial de pagos y comisiones',
                      Icons.payments_outlined,
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HERO
  // ══════════════════════════════════════════════════════════════

  Widget _buildHero(EmpleadoViewModel empleado, ColorScheme colorScheme) {
    final accent = _roleColor(empleado.rol);
    final isMobile = ResponsiveHelper.isMobile(context);
    final size = isMobile ? 72.0 : 88.0;
    final tieneFoto =
        empleado.fotoUrl != null && empleado.fotoUrl!.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 16 : 22,
        isMobile ? 16 : 24,
        isMobile ? 20 : 26,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: tieneFoto
                  ? null
                  : LinearGradient(
                      colors: [accent, Color.lerp(accent, Colors.black, 0.2)!],
                    ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: tieneFoto
                  ? Image.network(
                      empleado.fotoUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: (size * 2).toInt(),
                      errorBuilder: (_, __, ___) =>
                          _heroInitials(empleado.inicial),
                    )
                  : _heroInitials(empleado.inicial),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empleado.nombre,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusBadge(
                      label: empleado.rol.label,
                      color: accent,
                      size: StatusBadgeSize.small,
                    ),
                    StatusBadge(
                      label: empleado.activo ? 'Activo' : 'Inactivo',
                      color: empleado.activo
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: StatusBadgeSize.small,
                    ),
                  ],
                ),
                if (empleado.documentoCompleto != 'Sin documento') ...[
                  const SizedBox(height: 6),
                  Text(
                    empleado.documentoCompleto,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroInitials(String inicial) {
    return Center(
      child: Text(
        inicial,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TABS
  // ══════════════════════════════════════════════════════════════

  Widget _buildTabs(ColorScheme colorScheme, UserRole role) {
    return Container(
      color: colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: _colorPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: _colorPrimary,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Resumen'),
          Tab(text: 'Laboral'),
          Tab(text: 'Horario'),
          Tab(text: 'Ventas'),
          Tab(text: 'Nómina'),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB: RESUMEN
  // ══════════════════════════════════════════════════════════════

  Widget _tabResumen(
    EmpleadoViewModel empleado,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Métricas rápidas
              if (empleado.antiguedad != null)
                _metricCard(
                  icon: Icons.schedule_rounded,
                  label: 'Antigüedad',
                  value: empleado.antiguedad!,
                  color: _colorPrimary,
                  colorScheme: colorScheme,
                ),
              const SizedBox(height: 12),
              if (empleado.cargo != null && empleado.cargo!.isNotEmpty)
                _metricCard(
                  icon: Icons.work_outline_rounded,
                  label: 'Cargo',
                  value: empleado.cargo!,
                  color: const Color(0xFF3B82F6),
                  colorScheme: colorScheme,
                ),
              const SizedBox(height: 12),
              if (empleado.email != null && empleado.email!.isNotEmpty)
                _metricCard(
                  icon: Icons.email_outlined,
                  label: 'Correo',
                  value: empleado.email!,
                  color: const Color(0xFF8B5CF6),
                  colorScheme: colorScheme,
                ),
              const SizedBox(height: 12),
              if (empleado.telefono != null &&
                  empleado.telefono!.isNotEmpty)
                _metricCard(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: empleado.telefono!,
                  color: const Color(0xFF14B8A6),
                  colorScheme: colorScheme,
                ),
              const SizedBox(height: 12),
              if (empleado.usuario.cajaAsignada.isNotEmpty)
                _metricCard(
                  icon: Icons.point_of_sale_rounded,
                  label: 'Caja asignada',
                  value: empleado.usuario.cajaAsignada,
                  color: const Color(0xFFF59E0B),
                  colorScheme: colorScheme,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB: LABORAL
  // ══════════════════════════════════════════════════════════════

  Widget _tabLaboral(
    EmpleadoViewModel empleado,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _seccionHeader('CONTRATO', colorScheme),
              const SizedBox(height: 10),
              _infoTile(
                'Tipo de contrato',
                _formatearTipoContrato(empleado.tipoContrato),
                colorScheme,
              ),
              _infoTile(
                'Fecha de ingreso',
                empleado.fechaIngreso != null
                    ? _formatearFecha(empleado.fechaIngreso!)
                    : '—',
                colorScheme,
              ),
              _infoTile(
                'Número de empleado',
                empleado.numeroEmpleado?.toString() ?? '—',
                colorScheme,
              ),
              _infoTile(
                'Supervisor',
                _supervisor?.nombre ?? '—',
                colorScheme,
              ),
              const SizedBox(height: 20),
              _seccionHeader('COMPENSACIÓN', colorScheme),
              const SizedBox(height: 10),
              _infoTile(
                'Salario base',
                empleado.tieneSalarioConfigurado
                    ? '${empleado.monedaSalario ?? "USD"} '
                        '${empleado.salarioBase!.toStringAsFixed(2)}'
                    : '—',
                colorScheme,
              ),
              _infoTile(
                'Frecuencia de pago',
                _formatearFrecuencia(empleado.frecuenciaPago),
                colorScheme,
              ),
              _infoTile(
                'Comisión por ventas',
                empleado.comisionPorcentaje != null
                    ? '${empleado.comisionPorcentaje!.toStringAsFixed(1)} %'
                    : '—',
                colorScheme,
              ),
              _infoTile(
                'Bono fijo',
                empleado.bonoFijo != null
                    ? '\$${empleado.bonoFijo!.toStringAsFixed(2)}'
                    : '—',
                colorScheme,
              ),
              _infoTile(
                'Recibe propinas',
                empleado.recibePropinas ? 'Sí' : 'No',
                colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccionHeader(String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _colorPrimary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: _colorPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearTipoContrato(String? tipo) {
    switch (tipo) {
      case 'tiempo_completo':
        return 'Tiempo completo';
      case 'medio_tiempo':
        return 'Medio tiempo';
      case 'pasante':
        return 'Pasante';
      case 'por_horas':
        return 'Por horas';
      case 'temporal':
        return 'Temporal';
      default:
        return '—';
    }
  }

  String _formatearFrecuencia(String? f) {
    switch (f) {
      case 'mensual':
        return 'Mensual';
      case 'quincenal':
        return 'Quincenal';
      case 'semanal':
        return 'Semanal';
      case 'diario':
        return 'Diario';
      default:
        return '—';
    }
  }

  String _formatearFecha(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // ══════════════════════════════════════════════════════════════
  // TAB: HORARIO
  // ══════════════════════════════════════════════════════════════

  Widget _tabHorario(
    EmpleadoViewModel empleado,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    final diasLibres = empleado.diasLibres;
    const diasNombres = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _seccionHeader('HORARIO ASIGNADO', colorScheme),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _colorPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: _colorPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _horario?.nombre ?? 'Sin horario asignado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (_horario?.descripcion != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _horario!.descripcion!,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _seccionHeader('DÍAS LIBRES', colorScheme),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (i) {
                  final weekday = i + 1;
                  final esLibre = diasLibres.contains(weekday);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: esLibre
                          ? _colorPrimary.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: esLibre
                            ? _colorPrimary.withValues(alpha: 0.4)
                            : colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      diasNombres[i],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: esLibre
                            ? _colorPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB PLACEHOLDER
  // ══════════════════════════════════════════════════════════════

  Widget _tabPlaceholder(
    String title,
    String subtitle,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _colorPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: _colorPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Disponible próximamente',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _roleColor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return const Color(0xFF3B82F6);
    case UserRole.supervisor:
      return const Color(0xFF8B5CF6);
    case UserRole.rrhh:
      return const Color(0xFF10B981);
    case UserRole.cajero:
      return const Color(0xFF14B8A6);
    case UserRole.auditor:
      return const Color(0xFF64748B);
    case UserRole.almacen:
      return const Color(0xFFF59E0B);
    case UserRole.dev:
      return const Color(0xFF06B6D4);
    case UserRole.soporte:
      return const Color(0xFF6366F1);
  }
}