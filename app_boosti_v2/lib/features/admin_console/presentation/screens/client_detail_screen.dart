import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pos/presentation/controllers/bcv_controller.dart';
import '../../../pos/presentation/providers/bcv_provider.dart';
import '../../../pos/presentation/utils/responsive_helper.dart';
import '../../../pos/presentation/widgets/appbar.dart';
import '../../../pos/presentation/widgets/common/card_action_button.dart';
import '../../../pos/presentation/widgets/common/dialog_header.dart';
import '../../../pos/presentation/widgets/common/glass_card.dart';
import '../../../pos/presentation/widgets/common/glass_dialog.dart';
import '../../../pos/presentation/widgets/common/persona_form_template.dart';
import '../../../pos/presentation/widgets/common/segmented_toggle.dart';
import '../../../pos/presentation/widgets/common/status_badge.dart';
import '../../data/models/client_note.dart';
import '../../data/models/payment.dart';
import '../../data/models/plan.dart';
import '../../data/models/suscripcion.dart';
import '../../data/models/tenant.dart';
import '../../providers/client_detail_provider.dart';
import '../../providers/plans_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/kpi_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge_tenant.dart';

/// Tabs de la ficha de cliente.
enum _TabFicha { resumen, suscripcion, pagos, notas }

/// Formato venezolano con separador de miles: `51.600,00`.
///
/// Deliberadamente **no** reutiliza `BcvController.formatearLocal()`:
/// ese no pone separador de miles, y el Control Center es una sección
/// administrativa donde la legibilidad prima.
String _formatoMiles(double n, {int decimales = 2}) {
  final partes = n.toStringAsFixed(decimales).split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return decimales > 0 ? '$entero,${partes[1]}' : entero;
}

/// Marca gris para pagos anteriores a la Subfase 5.3, que no guardan
/// tasa de conversión.
class _ChipLegacy extends StatelessWidget {
  const _ChipLegacy();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        'legacy',
        style: TextStyle(
          fontSize: 9,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Ficha de un cliente del Control Center.
///
/// Muestra los datos del tenant, su suscripción y plan, y los pagos y
/// notas asociados, repartidos en 4 tabs.
///
/// No declara `Scaffold` propio porque vive dentro del body de
/// `ControlCenterScreen`, que ya aporta el contenedor y el `CustomAppBar`.
class ClientDetailScreen extends ConsumerStatefulWidget {
  final String tenantId;

  const ClientDetailScreen({super.key, required this.tenantId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  _TabFicha _tab = _TabFicha.resumen;

  static const Color _verde = Color(0xFF10B981);
  static const Color _ambar = Color(0xFFF59E0B);
  static const Color _rojo = Color(0xFFEF4444);
  static const Color _violeta = Color(0xFF8B5CF6);
  static const Color _gris = Colors.grey;

  static const double _anchoMaximo = 1400;

  static const List<SegmentedToggleItem<_TabFicha>> _tabs = [
    SegmentedToggleItem(
      value: _TabFicha.resumen,
      label: 'Resumen',
      icon: Icons.info_outline_rounded,
    ),
    SegmentedToggleItem(
      value: _TabFicha.suscripcion,
      label: 'Suscripción',
      icon: Icons.card_membership_rounded,
    ),
    SegmentedToggleItem(
      value: _TabFicha.pagos,
      label: 'Pagos',
      icon: Icons.payments_rounded,
    ),
    SegmentedToggleItem(
      value: _TabFicha.notas,
      label: 'Notas',
      icon: Icons.sticky_note_2_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // `clientDetailProvider` NO dispara `cargar()` al construirse, así que
    // hay que pedir los datos aquí. Si se añade la carga automática al
    // provider, esta línea se puede quitar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(clientDetailProvider(widget.tenantId).notifier).cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientDetailProvider(widget.tenantId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: state.tenant?.nombre ?? 'Cliente',
        showBackButton: true,
      ),
      body: _cuerpo(state, colorScheme),
    );
  }

  /// Estados de carga/error y, con datos, el contenido con tabs.
  Widget _cuerpo(ClientDetailState state, ColorScheme colorScheme) {
    // 1) Primera carga.
    if (state.cargando && state.tenant == null) return _cargando();

    // 2) Error sin datos.
    if (state.error != null && state.tenant == null) {
      return _error(state.error!, colorScheme);
    }

    return _contenido(state, colorScheme);
  }

  // ═════════════════════════════════════════════════════════════
  // ESTADOS
  // ═════════════════════════════════════════════════════════════

  Widget _cargando() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando cliente...'),
        ],
      ),
    );
  }

  Widget _error(String error, ColorScheme colorScheme) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      titulo: 'Error',
      subtitulo: error,
      color: _rojo,
      accion: ElevatedButton(
        onPressed: () =>
            ref.read(clientDetailProvider(widget.tenantId).notifier).cargar(),
        child: const Text('Reintentar'),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // CONTENIDO
  // ═════════════════════════════════════════════════════════════

  Widget _contenido(ClientDetailState state, ColorScheme colorScheme) {
    final esMobile = ResponsiveHelper.isMobile(context);
    final paddingH = esMobile
        ? 16.0
        : (ResponsiveHelper.isDesktop(context) ? 32.0 : 24.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(paddingH, 20, paddingH, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _anchoMaximo),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(state, colorScheme),
              const SizedBox(height: 16),
              // El toggle no scrollea solo; lo envuelvo para que en
              // pantallas angostas los 4 tabs no desborden.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedToggle<_TabFicha>(
                  items: _tabs,
                  selected: _tab,
                  onChanged: (t) => setState(() => _tab = t),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _tabActual(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabActual(ClientDetailState state) {
    return switch (_tab) {
      _TabFicha.resumen => _tabResumen(state),
      _TabFicha.suscripcion => _tabSuscripcion(state),
      _TabFicha.pagos => _tabPagos(state),
      _TabFicha.notas => _tabNotas(state),
    };
  }

  // ═════════════════════════════════════════════════════════════
  // HERO
  // ═════════════════════════════════════════════════════════════

  Widget _hero(ClientDetailState state, ColorScheme colorScheme) {
    final tenant = state.tenant;
    if (tenant == null) return const SizedBox.shrink();

    final sub = state.suscripcion;
    final colorEstado = _colorEstado(sub?.estado);

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(tenant, colorEstado),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tenant.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (sub != null) StatusBadgeTenant(estado: sub.estado),
                        Text(
                          'Cliente desde ${_fecha(tenant.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (sub != null) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _precio(state.plan),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorEstado,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.plan?.nombre ?? 'Sin plan',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (tenant.tieneContacto) ...[
            const SizedBox(height: 12),
            _contacto(tenant, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _avatar(Tenant tenant, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Text(
        tenant.iniciales,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _contacto(Tenant tenant, ColorScheme colorScheme) {
    final estilo = TextStyle(
      fontSize: 12,
      color: colorScheme.onSurfaceVariant,
    );

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        if ((tenant.emailContacto ?? '').isNotEmpty)
          _dato(Icons.mail_outline_rounded, tenant.emailContacto!, estilo),
        if ((tenant.telefono ?? '').isNotEmpty)
          _dato(Icons.phone_outlined, tenant.telefono!, estilo),
        if ((tenant.rif ?? '').isNotEmpty)
          _dato(Icons.badge_outlined, tenant.rif!, estilo),
      ],
    );
  }

  Widget _dato(IconData icon, String texto, TextStyle estilo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: estilo.color),
        const SizedBox(width: 5),
        Text(texto, style: estilo),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // TAB 1 — RESUMEN
  // ═════════════════════════════════════════════════════════════

  Widget _tabResumen(ClientDetailState state) {
    final tenant = state.tenant;
    if (tenant == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            titulo: 'Información del negocio',
            icono: Icons.storefront_rounded,
          ),
          const SizedBox(height: 12),
          GlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _filaInfo('Nombre comercial', tenant.nombre),
                if ((tenant.rif ?? '').isNotEmpty)
                  _filaInfo('RIF', tenant.rif!),
                if ((tenant.emailContacto ?? '').isNotEmpty)
                  _filaInfo('Email', tenant.emailContacto!),
                if ((tenant.telefono ?? '').isNotEmpty)
                  _filaInfo('Teléfono', tenant.telefono!),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            titulo: 'Estadísticas',
            icono: Icons.insights_rounded,
          ),
          const SizedBox(height: 12),
          _gridEstadisticas(state),
          const SizedBox(height: 24),
          const SectionHeader(
            titulo: 'Acciones rápidas',
            icono: Icons.bolt_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _tab = _TabFicha.pagos);
                    // Tras un frame, para que el tab esté montado antes
                    // de que `showDialog` busque su `context`.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _dialogoNuevoPago();
                    });
                  },
                  icon: const Icon(Icons.add_card_rounded, size: 18),
                  label: const Text('Registrar pago'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _tab = _TabFicha.notas);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _dialogoNuevaNota();
                    });
                  },
                  icon: const Icon(Icons.note_add_rounded, size: 18),
                  label: const Text('Añadir nota'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _tab = _TabFicha.suscripcion),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Cambiar plan'),
                ),
              ),
            ],
          ),
          if (state.suscripcion != null) ...[
            const SizedBox(height: 12),
            Text(
              'Rif, locales y usuarios no están disponibles en esta versión.',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filaInfo(String etiqueta, String valor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              etiqueta,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridEstadisticas(ClientDetailState state) {
    final tenant = state.tenant;
    final dias = tenant == null
        ? 0
        : DateTime.now().difference(tenant.createdAt).inDays;

    // TODO Subfase 3.3.3: locales, usuarios y última actividad requieren
    // consultas que hoy no expone ClientDetailState.
    final kpis = <({String label, String value, IconData icon, Color color})>[
      (
        label: 'Días como cliente',
        value: '$dias',
        icon: Icons.event_available_rounded,
        color: _violeta
      ),
      (
        label: 'Locales',
        value: '—',
        icon: Icons.storefront_rounded,
        color: _ambar
      ),
      (
        label: 'Usuarios',
        value: '—',
        icon: Icons.group_rounded,
        color: _ambar
      ),
      (
        label: 'Última actividad',
        value: '—',
        icon: Icons.history_rounded,
        color: _gris
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth < 600 ? 1 : 2;
        const spacing = 12.0;
        final anchoItem =
            (constraints.maxWidth - spacing * (columnas - 1)) / columnas;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final k in kpis)
              SizedBox(
                width: anchoItem,
                child: KpiCard(
                  label: k.label,
                  value: k.value,
                  icon: k.icon,
                  color: k.color,
                ),
              ),
          ],
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // TAB 2 — SUSCRIPCIÓN
  // ═════════════════════════════════════════════════════════════

  Widget _tabSuscripcion(ClientDetailState state) {
    final sub = state.suscripcion;
    final colorScheme = Theme.of(context).colorScheme;

    if (sub == null) {
      return const EmptyState(
        icon: Icons.card_membership_rounded,
        titulo: 'Sin suscripción',
        subtitulo: 'Este cliente no tiene suscripción asociada',
      );
    }

    final colorEstado = _colorEstado(sub.estado);
    final esTrial = sub.estado == EstadoSuscripcion.trial;
    final estaCancelada = sub.estado == EstadoSuscripcion.cancelado;
    final esExpirada = sub.estado == EstadoSuscripcion.expirado;

    // Qué fecha es la relevante cambia según el estado (ver
    // `_etiquetaPeriodo`).
    final etiquetaPeriodo = _etiquetaPeriodo(sub, state.plan);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            titulo: 'Plan actual',
            icono: Icons.workspace_premium_rounded,
          ),
          const SizedBox(height: 12),
          GlassCard(
            margin: EdgeInsets.zero,
            showStatusBar: true,
            statusColor: colorEstado,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.plan?.nombre ?? 'Sin plan',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _precio(state.plan),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _datoLinea('Estado', sub.estado.label, colorEstado),
                _datoLinea(
                  'Período actual',
                  '${_fecha(sub.periodoActualInicio)} → '
                      '${_fecha(sub.periodoActualFin)}',
                  colorScheme.onSurface,
                ),
                _datoLinea(
                  etiquetaPeriodo.label,
                  etiquetaPeriodo.valor,
                  colorScheme.onSurface,
                ),
                _datoLinea(
                  'Auto-renovar',
                  // Una suscripción cancelada no se renueva aunque el
                  // flag en BD siga a `true` (filas anteriores a que
                  // `cancelar` lo forzara a `false`).
                  estaCancelada ? 'No' : (sub.autoRenovar ? 'Sí' : 'No'),
                  colorScheme.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Qué acciones existen depende del estado: reactivar solo
          // tiene sentido sobre una suscripción caída, y extender el
          // trial solo mientras siga en trial.
          Row(
            children: [
              if (esTrial && state.plan?.id == 'trial') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _dialogoExtenderTrial(sub),
                    icon: const Icon(Icons.more_time_rounded, size: 18),
                    label: const Text('Extender trial 7d'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _dialogoCambiarPlan(state),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Cambiar plan'),
                ),
              ),
              const SizedBox(width: 10),
              if (!estaCancelada && !esExpirada)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _dialogoCancelar(sub),
                    icon: const Icon(Icons.cancel_rounded, size: 18),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(foregroundColor: _rojo),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _dialogoReactivar(sub),
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Reactivar'),
                    style: OutlinedButton.styleFrom(foregroundColor: _verde),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            titulo: 'Historial de cambios',
            icono: Icons.history_rounded,
          ),
          const SizedBox(height: 12),
          // TODO Subfase 3.3.3: leer `suscripcion_historial`; hoy no está
          // en ClientDetailState.
          const EmptyState(
            icon: Icons.history_toggle_off_rounded,
            titulo: 'Sin cambios registrados',
            subtitulo: 'El historial de plan y estado estará disponible '
                'próximamente',
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // ACCIONES DE SUSCRIPCIÓN
  // ═════════════════════════════════════════════════════════════

  /// Días que extiende el botón de trial.
  static const int _diasTrial = 7;

  /// Confirma y extiende el trial [dias] días.
  Future<void> _dialogoExtenderTrial(Suscripcion sub) async {
    // El repo suma a `trialVenceEn`, o a hoy si la fecha ya pasó.
    final base = sub.trialVenceEn ?? DateTime.now();
    final nueva = base.add(Duration(days: _diasTrial));

    final ok = await _confirmarAccion(
      titulo: 'Extender trial',
      icono: Icons.more_time_rounded,
      color: _ambar,
      maxWidth: 420,
      mensaje:
          '¿Extender $_diasTrial días el trial? El nuevo vencimiento '
          'será el ${_fecha(nueva)}.',
      confirmar: 'Extender',
      onConfirmar: () => ref
          .read(clientDetailProvider(widget.tenantId).notifier)
          .extenderTrial(_diasTrial),
    );
    if (!mounted || ok == null) return;
    _aviso(
      ok ? 'Trial extendido $_diasTrial días' : 'No se pudo extender el trial',
      ok ? _verde : _rojo,
    );
  }

  /// Abre el selector de plan y aplica el cambio.
  Future<void> _dialogoCambiarPlan(ClientDetailState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _CambiarPlanDialog(
        tenantId: widget.tenantId,
        planActual: state.plan,
        suscripcion: state.suscripcion,
      ),
    );
    if (!mounted || ok == null) return;
    _aviso(
      ok ? 'Plan actualizado' : 'No se pudo cambiar el plan',
      ok ? _verde : _rojo,
    );
  }

  /// Confirma y cancela la suscripción.
  Future<void> _dialogoCancelar(Suscripcion sub) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CancelarSuscripcionDialog(
        tenantId: widget.tenantId,
        finPeriodo: sub.periodoActualFin,
      ),
    );
    if (!mounted || ok == null) return;
    _aviso(
      ok ? 'Suscripción cancelada' : 'No se pudo cancelar la suscripción',
      ok ? _verde : _rojo,
    );
  }

  /// Confirma y reactiva la suscripción.
  Future<void> _dialogoReactivar(Suscripcion sub) async {
    final ok = await _confirmarAccion(
      titulo: 'Reactivar suscripción',
      icono: Icons.restart_alt_rounded,
      color: _verde,
      maxWidth: 420,
      mensaje: '¿Reactivar la suscripción? Se reanudará inmediatamente '
          'como activa por $_diasReactivacion días.',
      confirmar: 'Reactivar',
      onConfirmar: () =>
          ref.read(clientDetailProvider(widget.tenantId).notifier).reactivar(),
    );
    if (!mounted || ok == null) return;
    _aviso(
      ok ? 'Suscripción reactivada' : 'No se pudo reactivar la suscripción',
      ok ? _verde : _rojo,
    );
  }

  /// Días que concede `SubscriptionsRepository.reactivar`.
  static const int _diasReactivacion = 30;

  /// Diálogo de confirmación genérico: devuelve `null` si se canceló.
  Future<bool?> _confirmarAccion({
    required String titulo,
    required IconData icono,
    required Color color,
    required double maxWidth,
    required String mensaje,
    required String confirmar,
    required Future<bool> Function() onConfirmar,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => GlassDialog(
        maxWidth: maxWidth,
        // `GlassDialog` no aplica padding interno.
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(icon: icono, title: titulo, color: color),
              const SizedBox(height: 16),
              Text(
                mensaje,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FormActions(
                isSaving: false,
                confirmLabel: confirmar,
                accentColor: color,
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () async {
                  final ok = await onConfirmar();
                  if (ctx.mounted) Navigator.pop(ctx, ok);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datoLinea(String etiqueta, String valor, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              etiqueta,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // TAB 3 — PAGOS
  // ═════════════════════════════════════════════════════════════

  Widget _tabPagos(ClientDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pagos (${state.pagos.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CardActionButton(
              icon: Icons.add_rounded,
              color: _violeta,
              tooltip: 'Nuevo pago',
              onPressed: _dialogoNuevoPago,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: state.pagos.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_rounded,
                  titulo: 'Sin pagos registrados',
                  subtitulo: 'Añade el primer pago con el botón de arriba',
                )
              : ListView.builder(
                  itemCount: state.pagos.length,
                  itemBuilder: (context, i) => _cardPago(state.pagos[i]),
                ),
        ),
      ],
    );
  }

  Widget _cardPago(Payment pago) {
    final colorPago = _colorPago(pago.estado);
    final colorScheme = Theme.of(context).colorScheme;
    final referencia = (pago.referencia ?? '').trim();
    final metodo = (pago.metodo ?? '').trim();
    final notas = (pago.notas ?? '').trim();

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      showStatusBar: true,
      statusColor: colorPago,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila superior: fecha a la izquierda, monto destacado a la
          // derecha.
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fecha(pago.pagadoEn ?? pago.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (metodo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Vía $metodo',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pago.montoFormateado} ${pago.moneda}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorPago,
                ),
              ),
            ],
          ),
          // Monto original + tasa, cuando el pago se ingresó en una
          // moneda distinta a la normalizada.
          if (pago.tieneConversion || pago.esLegacy)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _detalleConversion(pago),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (pago.esLegacy) ...[
                    const SizedBox(width: 6),
                    _ChipLegacy(),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 10),
          // Fila de estado + referencia + acción de pago rápido.
          Row(
            children: [
              StatusBadge(
                label: pago.estado.label,
                color: colorPago,
                icon: _iconoEstadoPago(pago.estado),
                size: StatusBadgeSize.small,
              ),
              if (referencia.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ref: $referencia',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ] else
                const Spacer(),
              if (pago.estado == EstadoPago.pendiente) ...[
                const SizedBox(width: 8),
                CardActionButton(
                  icon: Icons.check_circle_outline_rounded,
                  color: _verde,
                  tooltip: 'Marcar como pagado',
                  iconSize: 16,
                  padding: const EdgeInsets.all(6),
                  onPressed: () => _marcarComoPagado(pago),
                ),
              ],
            ],
          ),
          if (notas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              notas,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // TAB 4 — NOTAS
  // ═════════════════════════════════════════════════════════════

  Widget _tabNotas(ClientDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Notas (${state.notas.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CardActionButton(
              icon: Icons.add_rounded,
              color: _violeta,
              tooltip: 'Nueva nota',
              onPressed: () => _dialogoNuevaNota(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: state.notas.isEmpty
              ? const EmptyState(
                  icon: Icons.sticky_note_2_outlined,
                  titulo: 'Sin notas',
                  subtitulo: 'Añade la primera nota',
                )
              : ListView.builder(
                  itemCount: state.notas.length,
                  itemBuilder: (context, i) => _cardNota(state.notas[i]),
                ),
        ),
      ],
    );
  }

  Widget _cardNota(ClientNote nota) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      isHighlighted: nota.fijada,
      highlightColor: _ambar,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (nota.fijada) ...[
                const Icon(Icons.push_pin_rounded, size: 14, color: _ambar),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  _fechaHora(nota.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              CardActionButton(
                icon: nota.fijada
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                color: _violeta,
                tooltip: nota.fijada ? 'Desfijar' : 'Fijar',
                iconSize: 16,
                padding: const EdgeInsets.all(6),
                onPressed: () => _toggleFijada(nota),
              ),
              CardActionButton(
                icon: Icons.delete_outline_rounded,
                color: _rojo,
                tooltip: 'Eliminar',
                iconSize: 16,
                padding: const EdgeInsets.all(6),
                onPressed: () => _confirmarEliminarNota(nota),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nota.contenido,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          if (nota.tieneTags) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in nota.tags) _chipTag(tag),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chipTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _violeta.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _violeta.withValues(alpha: 0.3)),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 10, color: _violeta),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // DIÁLOGOS (stubs)
  // ═════════════════════════════════════════════════════════════

  /// Abre el formulario de registro de pago y avisa del resultado.
  Future<void> _dialogoNuevoPago() async {
    final registrado = await showDialog<bool>(
      context: context,
      builder: (_) => _NuevoPagoDialog(tenantId: widget.tenantId),
    );
    if (!mounted || registrado == null) return;
    _aviso(
      registrado ? 'Pago registrado' : 'No se pudo registrar el pago',
      registrado ? _verde : _rojo,
    );
  }

  /// Pide confirmación y marca un pago pendiente como pagado.
  Future<void> _marcarComoPagado(Payment pago) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => GlassDialog(
        maxWidth: 420,
        // `GlassDialog` no aplica padding interno.
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DialogHeader(
                icon: Icons.check_circle_rounded,
                title: 'Marcar como pagado',
                color: Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Marcar el pago de ${pago.montoFormateado} '
                '${pago.moneda} como pagado?',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FormActions(
                isSaving: false,
                confirmLabel: 'Marcar pagado',
                accentColor: _verde,
                onCancel: () => Navigator.pop(ctx, false),
                onConfirm: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmado != true || !mounted) return;

    final ok = await ref
        .read(clientDetailProvider(widget.tenantId).notifier)
        .actualizarEstadoPago(pago.id, EstadoPago.pagado.name);
    if (!mounted) return;
    _aviso(
      ok ? 'Pago marcado como pagado' : 'No se pudo actualizar el pago',
      ok ? _verde : _rojo,
    );
  }

  /// Abre el editor de nota nueva y avisa del resultado.
  Future<void> _dialogoNuevaNota() async {
    final guardada = await showDialog<bool>(
      context: context,
      builder: (_) => _NuevaNotaDialog(tenantId: widget.tenantId),
    );
    if (!mounted || guardada == null) return;
    if (guardada) {
      _aviso('Nota añadida', _verde);
    } else {
      _aviso('No se pudo añadir la nota', _rojo);
    }
  }

  /// Fija o desfija una nota.
  Future<void> _toggleFijada(ClientNote nota) async {
    final ok = await ref
        .read(clientDetailProvider(widget.tenantId).notifier)
        .toggleFijadaNota(nota.id, !nota.fijada);
    if (!mounted) return;
    _aviso(
      ok
          ? (nota.fijada ? 'Nota desfijada' : 'Nota fijada')
          : 'No se pudo actualizar la nota',
      ok ? _verde : _rojo,
    );
  }

  /// Pide confirmación y luego elimina la nota.
  Future<void> _confirmarEliminarNota(ClientNote nota) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => GlassDialog(
        maxWidth: 420,
        // `GlassDialog` no aplica padding interno: sin esto el texto
        // queda pegado al borde del diálogo.
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DialogHeader(
                icon: Icons.delete_rounded,
                title: 'Eliminar nota',
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Eliminar esta nota? Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FormActions(
                isSaving: false,
                confirmLabel: 'Eliminar',
                accentColor: _rojo,
                onCancel: () => Navigator.pop(ctx, false),
                onConfirm: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmado != true || !mounted) return;

    final ok = await ref
        .read(clientDetailProvider(widget.tenantId).notifier)
        .eliminarNota(nota.id);
    if (!mounted) return;
    _aviso(ok ? 'Nota eliminada' : 'No se pudo eliminar la nota',
        ok ? _verde : _rojo);
  }

  /// Muestra un `SnackBar` de un solo tono, reemplazando el anterior.
  void _aviso(String mensaje, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ═════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═════════════════════════════════════════════════════════════

  static const List<String> _meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', //
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  /// "15 Sep 2026".
  String _fecha(DateTime? d) {
    if (d == null) return '—';
    return '${d.day} ${_meses[d.month - 1]} ${d.year}';
  }

  /// "15 Sep · 14:30".
  String _fechaHora(DateTime? d) {
    if (d == null) return '—';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_meses[d.month - 1]} · $h:$m';
  }

  /// "Gratis" si el plan no tiene coste, "—" si no hay plan.
  String _precio(Plan? plan) {
    if (plan == null) return '—';
    if (plan.precioMensual == 0) return 'Gratis';
    return plan.precioMensualFormateado;
  }

  /// "1 día" / "N días" / "—" si no hay fecha o ya pasó.
  String _dias(int? cantidad) {
    if (cantidad == null || cantidad <= 0) return '—';
    return cantidad == 1 ? '1 día' : '$cantidad días';
  }

  int? _diasHasta(DateTime? fin) {
    if (fin == null) return null;
    return fin.difference(DateTime.now()).inDays;
  }

  /// Etiqueta y valor de la fila de fecha según el estado.
  ///
  /// El orden importa: primero los estados terminales (cancelado /
  /// vencido / expirado), porque en ellos la fecha relevante es un
  /// límite, no una cuenta regresiva.
  ///
  /// El trial se reconoce por **plan o estado**, no solo por uno de los
  /// dos, porque los datos reales necesitan las dos señales:
  ///   - `SubscriptionsRepository.actualizarPlan` solo cambia `plan_id` y
  ///     no toca `estado`, así que existe `plan_id = 'trial'` con
  ///     `estado = 'activo'` (sigue siendo trial).
  ///   - `trial_vence_en` queda **poblado** en suscripciones que ya
  ///     pagando, así que un plan `pro` puede tener una fecha de trial
  ///     futura. Mirar solo la fecha mostraría «Trial vence en» en un
  ///     plan de pago.
  ({String label, String valor}) _etiquetaPeriodo(Suscripcion sub, Plan? plan) {
    // Cancelado: hay que decir hasta cuándo conserva acceso.
    if (sub.estado == EstadoSuscripcion.cancelado) {
      return (label: 'Acceso hasta', valor: _fecha(sub.periodoActualFin));
    }

    // Vencido / expirado: fecha de caída, no cuenta regresiva.
    if (sub.estado == EstadoSuscripcion.vencido ||
        sub.estado == EstadoSuscripcion.expirado) {
      return (
        label: 'Expiró el',
        valor: _fecha(sub.periodoActualFin ?? sub.canceladoEn),
      );
    }

    final diasTrial = sub.diasRestantesTrial;
    final hayTrialVigente = diasTrial != null && diasTrial >= 0;
    final esPlanTrial = plan?.id == 'trial';

    if (hayTrialVigente &&
        (esPlanTrial || sub.estado == EstadoSuscripcion.trial)) {
      return (label: 'Trial vence en', valor: _dias(diasTrial));
    }

    if (sub.estado == EstadoSuscripcion.activo) {
      return (
        label: 'Renueva en',
        valor: _dias(_diasHasta(sub.periodoActualFin)),
      );
    }

    // Estado raro con una fecha de trial aún por delante: mejor mostrarla
    // que caer en un «Estado» que repite la fila de arriba.
    if (hayTrialVigente) {
      return (label: 'Trial vence en', valor: _dias(diasTrial));
    }

    return (label: 'Estado', valor: sub.estado.label);
  }

  /// Color de la barra y del badge según el estado de la suscripción.
  Color _colorEstado(EstadoSuscripcion? e) {
    return switch (e) {
      EstadoSuscripcion.activo => _verde,
      EstadoSuscripcion.trial => _ambar,
      EstadoSuscripcion.vencido => _rojo,
      EstadoSuscripcion.expirado => _rojo,
      EstadoSuscripcion.cancelado => _gris,
      EstadoSuscripcion.desconocido => _violeta,
      null => Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }

  /// Color del badge según el estado del pago.
  Color _colorPago(EstadoPago e) {
    return switch (e) {
      EstadoPago.pagado => _verde,
      EstadoPago.pendiente => _ambar,
      EstadoPago.fallido => _rojo,
      EstadoPago.reembolsado => _gris,
      EstadoPago.desconocido =>
        Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }

  /// "51.600,00 VES · tasa 0.0012" para pagos con conversión.
  ///
  /// Los pagos anteriores a la Subfase 5.3 no tienen tasa guardada, así
  /// que se muestra solo el monto tal cual.
  String _detalleConversion(Payment pago) {
    final original = pago.montoOriginal;
    final moneda = pago.monedaOriginal ?? pago.moneda;

    // Pago anterior a la Subfase 5.3: no hay monto original guardado.
    if (original == null) {
      return 'Monto original: ${_formatoMiles(pago.monto)} $moneda';
    }

    final montoTexto = '${_formatoMiles(original)} $moneda';
    final tasa = pago.tasaConversion;

    // Sin tasa, o en USD (factor 1): el monto original ya es el final.
    if (tasa == null || pago.monedaOriginal == 'USD') {
      return 'Original: $montoTexto';
    }

    // Se muestra la tasa inversa (`1 / factor`): multiplicar un factor
    // de 0,0012 es ilegible, mientras que «860,1753 Bs/USD» se entiende
    // de un vistazo.
    return 'Original: $montoTexto · '
        'Tasa ${_formatoMiles(1 / tasa, decimales: 4)}';
  }

  /// Icono del badge según el estado del pago.
  IconData _iconoEstadoPago(EstadoPago e) {
    return switch (e) {
      EstadoPago.pagado => Icons.check_circle_rounded,
      EstadoPago.pendiente => Icons.hourglass_top_rounded,
      EstadoPago.fallido => Icons.error_rounded,
      EstadoPago.reembolsado => Icons.undo_rounded,
      EstadoPago.desconocido => Icons.help_outline_rounded,
    };
  }
}

// ═════════════════════════════════════════════════════════════
// DIÁLOGO — NUEVA NOTA
// ═════════════════════════════════════════════════════════════

/// Editor de nota nueva.
///
/// Es un `ConsumerStatefulWidget` aparte para que los controllers y el
/// flag de guardado mueran con el diálogo y no queden vivos en la ficha.
///
/// Devuelve `true` con `Navigator.pop` si la nota se guardó, `false` si
/// falló y `null` si el usuario canceló.
class _NuevaNotaDialog extends ConsumerStatefulWidget {
  final String tenantId;

  const _NuevaNotaDialog({required this.tenantId});

  @override
  ConsumerState<_NuevaNotaDialog> createState() => _NuevaNotaDialogState();
}

class _NuevaNotaDialogState extends ConsumerState<_NuevaNotaDialog> {
  static const Color _violeta = Color(0xFF8B5CF6);

  final _notaController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _notaController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// Convierte "urgente, Cliente VIP" en `['urgente', 'cliente vip']`.
  List<String> _parseTags(String crudo) {
    return crudo
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Future<void> _guardar() async {
    final contenido = _notaController.text.trim();
    if (contenido.isEmpty) return;

    setState(() => _guardando = true);

    final ok = await ref
        .read(clientDetailProvider(widget.tenantId).notifier)
        .agregarNota(
          contenido: contenido,
          tags: _parseTags(_tagsController.text),
        );

    if (!mounted) return;
    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      maxWidth: 500,
      maxHeightFactor: 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DialogHeader(
                  icon: Icons.sticky_note_2_rounded,
                  title: 'Nueva nota',
                ),
                const SizedBox(height: 16),
                PersonaTextField(
                  controller: _notaController,
                  label: 'Contenido',
                  icon: Icons.notes_rounded,
                  accentColor: _violeta,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                PersonaTextField(
                  controller: _tagsController,
                  label: 'Tags (separados por coma)',
                  icon: Icons.tag_rounded,
                  accentColor: _violeta,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: FormActions(
              isSaving: _guardando,
              confirmLabel: 'Guardar',
              accentColor: _violeta,
              onCancel: () => Navigator.pop(context),
              onConfirm: _guardar,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// DIÁLOGO — NUEVO PAGO
// ═════════════════════════════════════════════════════════════

/// Formulario de registro de pago.
///
/// Devuelve `true` con `Navigator.pop` si se registró, `false` si falló y
/// `null` si el usuario canceló.
class _NuevoPagoDialog extends ConsumerStatefulWidget {
  final String tenantId;

  const _NuevoPagoDialog({required this.tenantId});

  @override
  ConsumerState<_NuevoPagoDialog> createState() => _NuevoPagoDialogState();
}

class _NuevoPagoDialogState extends ConsumerState<_NuevoPagoDialog> {
  static const Color _violeta = Color(0xFF8B5CF6);

  static const List<String> _meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', //
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  /// Métodos ofrecidos en el desplegable. El valor es el texto libre que
  /// se guarda en `pagos.metodo`.
  static const List<String> _metodos = [
    'Efectivo',
    'Transferencia',
    'Pago Móvil',
    'Zelle',
    'Binance',
    'Otro',
  ];

  /// Código ISO 4217 de la moneda local, derivado del país.
  ///
  /// [BcvController.config] no expone el código de moneda (solo
  /// `codigoPais` y `simboloMoneda`), así que se traduce aquí. Es lo que
  /// se persiste en `pagos.moneda_original`.
  static const Map<String, String> _isoPorPais = {
    'VE': 'VES',
    'CO': 'COP',
    'CL': 'CLP',
    'AR': 'ARS',
  };

  static String _codigoLocal(String codigoPais) =>
      _isoPorPais[codigoPais] ?? codigoPais;

  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _notasController = TextEditingController();

  /// Solo refleja la fecha elegida: el campo es de solo lectura y la
  /// fecha se introduce con el `showDatePicker`.
  final _fechaController = TextEditingController();

  String _moneda = 'USD';
  String _metodo = _metodos.first;
  DateTime? _pagadoEn;
  bool _guardando = false;

  /// Mensaje de conversión no posible (falta la tasa BCV).
  String? _errorConversion;

  @override
  void initState() {
    super.initState();
    // La conversión en vivo se recalcula en cada tecla.
    _montoController.addListener(_alCambiarMonto);
  }

  void _alCambiarMonto() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _montoController.dispose();
    _referenciaController.dispose();
    _notasController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  /// Acepta "25", "25.5" y "25,50" (coma decimal).
  double? _parseMonto(String texto) {
    final normalizado = texto.trim().replaceAll(',', '.');
    return double.tryParse(normalizado);
  }

  /// Factor multiplicativo de la moneda elegida a USD.
  ///
  /// - USD → `1.0`
  /// - Moneda local → `1 / bcv.tasa`
  /// - EUR → `bcv.tasaEuro / bcv.tasa` (cruzado)
  ///
  /// Devuelve `null` si falta la tasa necesaria para convertir.
  double? _factorAUsd(BcvController bcv, String codigoLocal) {
    if (_moneda == 'USD') return 1.0;
    if (!bcv.tieneTasa || bcv.tasa <= 0) return null;
    if (_moneda == codigoLocal) return 1.0 / bcv.tasa;
    if (_moneda == 'EUR') {
      if (!bcv.manejaEuro || bcv.tasaEuro <= 0) return null;
      return bcv.tasaEuro / bcv.tasa;
    }
    return null;
  }

  /// "15 Sep 2026".
  String _formatearFecha(DateTime d) {
    return '${d.day} ${_meses[d.month - 1]} ${d.year}';
  }

  /// Fija (o limpia con `null`) la fecha de pago y su reflejo en el
  /// campo de solo lectura.
  void _setFecha(DateTime? fecha) {
    setState(() {
      _pagadoEn = fecha;
      _fechaController.text = fecha == null ? '' : _formatearFecha(fecha);
    });
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _pagadoEn ?? ahora,
      // No se pueden inventar pagos futuros.
      firstDate: DateTime(ahora.year - 5),
      lastDate: ahora,
      helpText: 'Fecha de pago',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (elegida == null || !mounted) return;
    _setFecha(elegida);
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final monto = _parseMonto(_montoController.text);
    if (monto == null || monto <= 0) return;

    final bcv = ref.read(bcvProvider);
    final codigoLocal = _codigoLocal(bcv.config.codigoPais);
    final factor = _factorAUsd(bcv, codigoLocal);
    if (factor == null || factor <= 0) {
      setState(() => _errorConversion = 'Esperando tasa BCV, no se puede '
          'convertir');
      return;
    }

    setState(() {
      _guardando = true;
      _errorConversion = null;
    });

    // `monto` y `moneda` quedan normalizados a USD para los cálculos
    // internos (Dashboard MRR, reportes). Lo que el usuario escribió se
    // conserva en `monto_original` / `moneda_original`.
    final ok = await ref
        .read(clientDetailProvider(widget.tenantId).notifier)
        .registrarPago(
          monto: monto * factor,
          moneda: 'USD',
          // Sin fecha de pago el registro queda pendiente: es lo que
          // espera el flujo de cobranza.
          estado: _pagadoEn == null
              ? EstadoPago.pendiente.name
              : EstadoPago.pagado.name,
          metodo: _metodo,
          referencia: _referenciaController.text.trim().isEmpty
              ? null
              : _referenciaController.text.trim(),
          pagadoEn: _pagadoEn,
          notas: _notasController.text.trim().isEmpty
              ? null
              : _notasController.text.trim(),
          tasaConversion: factor,
          montoOriginal: monto,
          monedaOriginal: _moneda,
        );

    if (!mounted) return;
    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bcv = ref.watch(bcvProvider);

    // Sin tasa utilizable no se puede convertir ni guardar.
    final factor = _factorAUsd(bcv, _codigoLocal(bcv.config.codigoPais));

    return GlassDialog(
      maxWidth: 560,
      maxHeightFactor: 0.9,
      // Sin `scrollable: true`: el scroll va aquí, solo sobre el
      // formulario, para que cabecera y botones nunca se corten.
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.payments_rounded,
              title: 'Registrar pago',
              color: _violeta,
            ),
            const SizedBox(height: 18),
            // `min` + `Flexible`: el diálogo se ajusta al contenido y
            // solo scrollea si el formulario no cabe.
            Flexible(
              child: SingleChildScrollView(
                child: _formulario(colorScheme, bcv),
              ),
            ),
            const SizedBox(height: 18),
            FormActions(
              isSaving: _guardando,
              confirmLabel: 'Guardar',
              accentColor: _violeta,
              onCancel: () => Navigator.pop(context),
              // Sin tasa BCV el botón queda inactivo (sin spinner).
              onConfirm: factor == null ? null : _guardar,
            ),
          ],
        ),
      ),
    );
  }

  /// Secciones del formulario, dentro del área con scroll.
  Widget _formulario(ColorScheme colorScheme, BcvController bcv) {
    final codigoLocal = _codigoLocal(bcv.config.codigoPais);
    final simboloLocal = bcv.config.simboloMoneda;

    // Moneda local siempre, USD siempre, EUR solo si el país lo maneja y
    // hay tasa cargada.
    final monedas = <String>[codigoLocal, 'USD'];
    if (bcv.manejaEuro && bcv.tasaEuro > 0) monedas.add('EUR');

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormSection(
            title: 'Monto',
            icon: Icons.attach_money_rounded,
            accentColor: _violeta,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: PersonaTextField(
                      controller: _montoController,
                      label: 'Monto',
                      icon: Icons.attach_money_rounded,
                      accentColor: _violeta,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final n = _parseMonto(v ?? '');
                        if (n == null) return 'Escribe un número';
                        if (n <= 0) return 'Debe ser mayor que 0';
                        if (_factorAUsd(bcv, codigoLocal) == null) {
                          return 'Esperando tasa BCV, no se puede convertir';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CampoSelect<String>(
                      label: 'Moneda',
                      icon: Icons.currency_exchange_rounded,
                      valor: _moneda,
                      opciones: monedas,
                      onChanged: (v) {
                        setState(() {
                          _moneda = v!;
                          _errorConversion = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _lineaConversion(bcv, codigoLocal, simboloLocal),
            ],
          ),
          const SizedBox(height: 16),
          FormSection(
            title: 'Método y referencia',
            icon: Icons.point_of_sale_rounded,
            accentColor: _violeta,
            children: [
              _CampoSelect<String>(
                label: 'Método de pago',
                icon: Icons.credit_card_rounded,
                valor: _metodo,
                opciones: _metodos,
                onChanged: (v) => setState(() => _metodo = v!),
              ),
              const SizedBox(height: 12),
              PersonaTextField(
                controller: _referenciaController,
                label: 'Referencia (opcional)',
                icon: Icons.tag_rounded,
                accentColor: _violeta,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormSection(
            title: 'Fecha de pago',
            icon: Icons.event_rounded,
            accentColor: _violeta,
            children: [
              Row(
                children: [
                  Expanded(
                    child: IgnorePointer(
                      // El campo es de solo lectura: la fecha se elige
                      // en el `showDatePicker`.
                      child: PersonaTextField(
                        controller: _fechaController,
                        label: _pagadoEn == null
                            ? 'Sin fecha (queda pendiente)'
                            : _formatearFecha(_pagadoEn!),
                        icon: Icons.calendar_today_rounded,
                        accentColor: _violeta,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _BotonFecha(
                    icon: Icons.event_rounded,
                    onPressed: _elegirFecha,
                  ),
                  if (_pagadoEn != null) ...[
                    const SizedBox(width: 4),
                    _BotonFecha(
                      icon: Icons.close_rounded,
                      onPressed: () => _setFecha(null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sin fecha de pago el registro se guarda como Pendiente.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormSection(
            title: 'Notas',
            icon: Icons.notes_rounded,
            accentColor: _violeta,
            children: [
              PersonaTextField(
                controller: _notasController,
                label: 'Notas (opcional)',
                icon: Icons.sticky_note_2_outlined,
                accentColor: _violeta,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Texto de conversión en vivo bajo el campo de monto.
  ///
  /// El equivalente se calcula con los conversores de [BcvController],
  /// no con aritmética propia.
  Widget _lineaConversion(
    BcvController bcv,
    String codigoLocal,
    String simboloLocal,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final monto = _parseMonto(_montoController.text);

    // 1) Estado de espera de la tasa.
    final faltaTasa = _factorAUsd(bcv, codigoLocal) == null;
    if (faltaTasa) {
      return Text(
        bcv.cargando && !bcv.tieneTasa
            ? 'Cargando tasa BCV...'
            : 'Esperando tasa BCV...',
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (_errorConversion != null) {
      return Text(
        _errorConversion!,
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.error,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // 2) Sin monto escrito todavía.
    if (monto == null || monto <= 0) {
      return Text(
        'El monto se guarda normalizado a USD.',
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final tasaBs = _formatoMiles(bcv.tasa, decimales: 4);

    // 3) Equivalente según la moneda elegida.
    final String equivalente;
    switch (_moneda) {
      case 'USD':
        equivalente = '≈ ${_formatoMiles(bcv.usdALocal(monto))} '
            '$simboloLocal al cambio BCV ($tasaBs $simboloLocal/USD)';
      case 'EUR':
        final local = bcv.eurALocal(monto);
        final usd = bcv.eurAUsd(monto);
        final tasaEur = _formatoMiles(bcv.tasaEuro, decimales: 4);
        equivalente = '≈ ${_formatoMiles(local)} $simboloLocal al '
            'cambio BCV ($tasaEur $simboloLocal/EUR)\n'
            '≈ \$${_formatoMiles(usd)} al cambio cruzado EUR/USD';
      default:
        equivalente = '≈ \$${_formatoMiles(bcv.localAUsd(monto))} al '
            'cambio BCV ($tasaBs $simboloLocal/USD)';
    }

    return Text(
      equivalente,
      style: TextStyle(
        fontSize: 11,
        color: colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// Desplegable con la misma piel que [PersonaTextField].
class _CampoSelect<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T valor;
  final List<T> opciones;
  final ValueChanged<T?> onChanged;

  /// Texto visible de una opción. Por defecto se usa `'$o'`, que sirve
  /// para listas de cadenas; los desplegables de objetos pasan aquí su
  /// propio `toString`.
  final String Function(T)? etiquetaDe;

  const _CampoSelect({
    required this.label,
    required this.icon,
    required this.valor,
    required this.opciones,
    required this.onChanged,
    this.etiquetaDe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      initialValue: valor,
      isExpanded: true,
      icon: const Icon(Icons.expand_more_rounded, size: 18),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          ),
        ),
        isDense: true,
      ),
      items: [
        for (final o in opciones)
          DropdownMenuItem<T>(
            value: o,
            child: Text(etiquetaDe?.call(o) ?? '$o'),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// Botón cuadrado que acompaña a un campo de solo lectura.
class _BotonFecha extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _BotonFecha({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// DIÁLOGOS — CAMBIAR PLAN
// ═════════════════════════════════════════════════════════════

/// Selector de plan para cambiar la suscripción del cliente.
///
/// Devuelve `true` si el plan se cambió, `false` si falló y `null` si
/// el usuario canceló.
class _CambiarPlanDialog extends ConsumerStatefulWidget {
  final String tenantId;
  final Plan? planActual;

  /// Necesario para el prorrateo: sin suscripción no hay ciclo sobre el
  /// que calcular los días restantes ni el estado para eximir de cobro.
  final Suscripcion? suscripcion;

  const _CambiarPlanDialog({
    required this.tenantId,
    required this.planActual,
    required this.suscripcion,
  });

  @override
  ConsumerState<_CambiarPlanDialog> createState() => _CambiarPlanDialogState();
}

class _CambiarPlanDialogState extends ConsumerState<_CambiarPlanDialog> {
  static const Color _violeta = Color(0xFF8B5CF6);
  static const Color _ambar = Color(0xFFF59E0B);

  /// Paleta semántica del Control Center, autorizada dentro del banner
  /// por ser superficie oscura (misma excepción que `cobrar_dialog.dart`).
  static const Color _verde = Color(0xFF10B981);
  static const Color _rojo = Color(0xFFEF4444);

  /// Umbral para considerar un ajuste nulo: evita el ruido de los
  /// centavos por redondeo en punto flotante.
  static const double _epsilon = 0.01;

  /// Días que se asume en un ciclo mensual, según las reglas de negocio.
  static const int _diasCiclo = 30;

  final _motivoController = TextEditingController();
  String? _nuevoPlanId;
  bool _guardando = false;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nuevoId = _nuevoPlanId;
    if (nuevoId == null ||
        nuevoId == widget.planActual?.id ||
        widget.suscripcion == null) {
      return;
    }

    setState(() => _guardando = true);

    final motivo = _motivoController.text.trim();
    final ok = await ref
        .read(clientDetailProvider(widget.tenantId).notifier)
        .cambiarPlan(nuevoId, motivo: motivo.isEmpty ? null : motivo);

    if (!mounted) return;
    Navigator.pop(context, ok);
  }

  // ═════════════════════════════════════════════════════════════
  // PRORRATEO
  //
  // Es **informativo**: cambiar de plan no registra ningún pago. El
  // superadmin ve el desglose y, si aplica, lo registra a mano en el
  // tab Pagos.
  // ═════════════════════════════════════════════════════════════

  /// Días restantes del ciclo actual, acotados a [0, 30].
  int get _diasRestantesCiclo {
    final fin = widget.suscripcion?.periodoActualFin;
    if (fin == null) return 0;
    return fin.difference(DateTime.now()).inDays.clamp(0, _diasCiclo);
  }

  /// Precio diario del plan.
  double _precioDiario(Plan? plan) {
    if (plan == null) return 0;
    return plan.precioMensual / _diasCiclo;
  }

  /// Crédito por los días restantes del plan actual.
  double get _creditoPlanActual =>
      _diasRestantesCiclo * _precioDiario(widget.planActual);

  /// Cargo por los días restantes del nuevo plan.
  double _cargoNuevoPlan(Plan? nuevoPlan) =>
      _diasRestantesCiclo * _precioDiario(nuevoPlan);

  /// Ajuste final (cargo menos crédito). Positivo es cobro.
  double _ajusteTotal(Plan? nuevoPlan) =>
      _cargoNuevoPlan(nuevoPlan) - _creditoPlanActual;

  /// `true` si la suscripción está en trial: el plan trial no se
  /// factura, así que no hay prorrateo que aplicar.
  bool get _esTrial => widget.suscripcion?.estado == EstadoSuscripcion.trial;

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final planesAsync = ref.watch(planesActivosProvider);
    final planes = planesAsync.valueOrNull;
    final actual = widget.planActual;
    final sub = widget.suscripcion;

    // Lista sin el plan actual. Se calcula UNA vez y se comparte entre el
    // desplegable y el banner: si cada uno derivara su propio "primer
    // plan", el desplegable podría mostrar "Básico" mientras el banner
    // calcula con `trial` (que es el primero por `orden`).
    final otros = planes?.where((p) => p.id != actual?.id).toList() ?? [];

    // Id efectivo: lo elegido por el usuario, o el primero disponible.
    final idSeleccionado = otros.isEmpty
        ? null
        : (otros.any((p) => p.id == _nuevoPlanId)
            ? _nuevoPlanId!
            : otros.first.id);

    final nuevoPlan = idSeleccionado == null
        ? null
        : otros.firstWhere((p) => p.id == idSeleccionado);

    return GlassDialog(
      maxWidth: 560,
      maxHeightFactor: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.swap_horiz_rounded,
              title: 'Cambiar plan',
              color: _violeta,
            ),
            const SizedBox(height: 18),

            // Sin suscripción no hay ciclo que prorratear ni sobre el que
            // aplicar el cambio.
            if (sub == null)
              const EmptyState(
                icon: Icons.card_membership_rounded,
                titulo: 'Sin suscripción activa',
                subtitulo:
                    'No se puede cambiar el plan sin una suscripción asociada',
              )
            else ...[
              FormSection(
                title: 'Plan actual',
                icon: Icons.workspace_premium_rounded,
                accentColor: _violeta,
                children: [_cardPlanActual(actual)],
              ),
              const SizedBox(height: 16),
              FormSection(
                title: 'Nuevo plan',
                icon: Icons.swap_horiz_rounded,
                accentColor: _violeta,
                children: [_selectorPlan(planesAsync, otros, idSeleccionado)],
              ),
              const SizedBox(height: 16),
              if (nuevoPlan != null && actual != null)
                _bannerProrrateo(nuevoPlan, actual),
              if (nuevoPlan?.id == 'trial' && actual?.id != 'trial') ...[
                const SizedBox(height: 12),
                _avisoLinea(
                  Icons.warning_amber_rounded,
                  _ambar,
                  'Al cambiar a Trial, el cliente perderá acceso al plan de '
                      'pago inmediatamente.',
                ),
              ],
              const SizedBox(height: 16),
              FormSection(
                title: 'Motivo',
                icon: Icons.notes_rounded,
                accentColor: _violeta,
                children: [
                  PersonaTextField(
                    controller: _motivoController,
                    label: 'Motivo (opcional)',
                    icon: Icons.notes_rounded,
                    accentColor: _violeta,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            FormActions(
              isSaving: _guardando,
              confirmLabel: 'Cambiar plan',
              accentColor: _violeta,
              onCancel: () => Navigator.pop(context),
              // Sin suscripción, sin planes cargados o sin cambio real:
              // el botón queda inactivo (sin spinner).
              onConfirm: sub == null ||
                      _nuevoPlanId == null ||
                      _nuevoPlanId == actual?.id
                  ? null
                  : _guardar,
            ),
          ],
        ),
      ),
    );
  }

  /// Desplegable de planes activos, excluyendo el actual.
  ///
  /// [otros] e [idSeleccionado] llegan calculados desde `build` para que
  /// el desplegable y el banner no puedan discrepar.
  Widget _selectorPlan(
    AsyncValue<List<Plan>> planesAsync,
    List<Plan> otros,
    String? idSeleccionado,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Se usa `isLoading`/`hasError` en vez de `.when(...)` porque la
    // lista efectiva llega en [otros]: con `.when` el `data:` recibía un
    // `lista` que no se usaba.
    if (planesAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    if (planesAsync.hasError) {
      return Text(
        'No se pudieron cargar los planos: ${planesAsync.error}',
        style: TextStyle(fontSize: 12, color: colorScheme.error),
      );
    }

    if (otros.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No hay otros planes activos disponibles.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return _CampoSelect<String>(
      label: 'Seleccionar plan',
      icon: Icons.workspace_premium_rounded,
      // `idSeleccionado` solo es `null` si [otros] está vacío, que ya se
      // resolvió arriba; el `??` evita el `!` por si acaso.
      valor: idSeleccionado ?? otros.first.id,
      opciones: otros.map((p) => p.id).toList(),
      etiquetaDe: (id) {
        final p = otros.firstWhere((p) => p.id == id);
        return '${p.nombre} · ${p.precioMensualFormateado}/mes';
      },
      onChanged: (v) => setState(() => _nuevoPlanId = v),
    );
  }

  /// Card de solo lectura con el plan vigente.
  Widget _cardPlanActual(Plan? plan) {
    final colorScheme = Theme.of(context).colorScheme;

    if (plan == null) {
      return Text(
        'Sin plan',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _violeta.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _violeta.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: _violeta,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if ((plan.descripcion ?? '').isNotEmpty)
                  Text(
                    plan.descripcion!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${plan.precioMensualFormateado}/mes',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _violeta,
            ),
          ),
        ],
      ),
    );
  }

  /// Banner oscuro con el desglose del prorrateo.
  ///
  /// No registra nada: solo informa. El estilo viene de
  /// `cobrar_dialog._buildTotalesBanner` (rama de tema claro, el mismo
  /// gradiente `0F172A → 1E293B`), pero en lista de filas porque aquí
  /// las magnitudes son tres y una de ellas es un separador.
  Widget _bannerProrrateo(Plan nuevoPlan, Plan planActual) {
    final dias = _diasRestantesCiclo;
    final credito = _creditoPlanActual;
    final cargo = _cargoNuevoPlan(nuevoPlan);
    final ajuste = _ajusteTotal(nuevoPlan);
    final sinAjuste = ajuste.abs() < _epsilon;

    // Filas a mostrar: se oculta la que aporte 0.
    final mostrarCredito = credito.abs() > _epsilon;
    final mostrarCargo = cargo.abs() > _epsilon;

    // Crédito es verde, cobro es rojo, sin cambio es violeta.
    final colorAjuste =
        sinAjuste ? _violeta : (ajuste > 0 ? _rojo : _verde);

    final textoAjuste = sinAjuste
        ? 'Sin ajuste'
        : '${ajuste > 0 ? '+' : '-'}\$${_formatoMiles(ajuste.abs())}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _esTrial
                      ? 'PRORRATEO (trial activo)'
                      : 'PRORRATEO (día $dias de $_diasCiclo)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_esTrial) ...[
            const Text(
              'Sin cargo — el plan trial no se factura',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              'El cambio de plan aplica de inmediato.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            // Cada fila se oculta si su monto es ~0: mostrar
            // "Cargo Básico +$0,00" al bajar al trial es ruido.
            if (mostrarCredito) ...[
              _filaProrrateo(
                'Crédito ${planActual.nombre} ($dias días)',
                -credito,
                _verde,
              ),
              if (mostrarCargo) const SizedBox(height: 6),
            ],
            if (mostrarCargo)
              _filaProrrateo(
                'Cargo ${nuevoPlan.nombre} ($dias días)',
                cargo,
                _rojo,
              ),
            if (mostrarCredito || mostrarCargo) ...[
              const SizedBox(height: 10),
              Container(height: 1, color: Colors.white24),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ajuste al próximo ciclo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  textoAjuste,
                  style: TextStyle(
                    color: colorAjuste,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              sinAjuste
                  ? 'No se aplica cobro ni crédito'
                  : (ajuste > 0
                      ? '→ Cobrar \$${_formatoMiles(ajuste.abs())} al cliente'
                      : '→ Acreditar \$${_formatoMiles(ajuste.abs())} '
                          'al cliente'),
              style: TextStyle(
                color: colorAjuste.withValues(alpha: 0.85),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Informativo: este cambio no registra ningún pago.',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  /// Fila etiqueta/valor del banner.
  ///
  /// El signo va a mano para que un negativo salga como `-$17,50` y no
  /// como `$-17,50`.
  Widget _filaProrrateo(String label, double monto, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${monto >= 0 ? '+' : '-'}\$${_formatoMiles(monto.abs())}',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Aviso ámbar de una línea.
  Widget _avisoLinea(IconData icon, Color color, String mensaje) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            mensaje,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// DIÁLOGOS — CANCELAR SUSCRIPCIÓN
// ═════════════════════════════════════════════════════════════

/// Pide el motivo y confirma la cancelación.
///
/// Devuelve `true` si se canceló, `false` si falló y `null` si el
/// usuario se echó atrás.
class _CancelarSuscripcionDialog extends ConsumerStatefulWidget {
  final String tenantId;
  final DateTime? finPeriodo;

  const _CancelarSuscripcionDialog({
    required this.tenantId,
    required this.finPeriodo,
  });

  @override
  ConsumerState<_CancelarSuscripcionDialog> createState() =>
      _CancelarSuscripcionDialogState();
}

class _CancelarSuscripcionDialogState
    extends ConsumerState<_CancelarSuscripcionDialog> {
  static const Color _rojo = Color(0xFFEF4444);

  final _motivoController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);

    final motivo = _motivoController.text.trim();
    final ok = await ref
        .read(clientDetailProvider(widget.tenantId).notifier)
        .cancelar(motivo.isEmpty ? 'Sin motivo indicado' : motivo);

    if (!mounted) return;
    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fin = widget.finPeriodo;

    return GlassDialog(
      maxWidth: 420,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.cancel_rounded,
              title: 'Cancelar suscripción',
              color: _rojo,
            ),
            const SizedBox(height: 16),
            Text(
              'El cliente seguirá con acceso hasta el fin del período '
              'actual${fin == null ? '' : ' (${_fechaLegible(fin)})'}. '
              'Después, la cuenta quedará bloqueada.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            PersonaTextField(
              controller: _motivoController,
              label: 'Motivo (opcional)',
              icon: Icons.notes_rounded,
              accentColor: _rojo,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            FormActions(
              isSaving: _guardando,
              confirmLabel: 'Cancelar suscripción',
              cancelLabel: 'Volver',
              accentColor: _rojo,
              onCancel: () => Navigator.pop(context),
              onConfirm: _guardar,
            ),
          ],
        ),
      ),
    );
  }

  /// "15 Sep 2026".
  String _fechaLegible(DateTime d) {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', //
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }
}
