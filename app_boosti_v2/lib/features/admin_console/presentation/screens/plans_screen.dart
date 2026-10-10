import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pos/presentation/utils/responsive_helper.dart';
import '../../../pos/presentation/widgets/common/active_toggle.dart';
import '../../../pos/presentation/widgets/common/dialog_header.dart';
import '../../../pos/presentation/widgets/common/glass_dialog.dart';
import '../../../pos/presentation/widgets/common/persona_form_template.dart';
import '../../../pos/presentation/widgets/common/segmented_toggle.dart';
import '../../data/models/plan.dart';
import '../../providers/plans_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/plan_card.dart';

/// Filtro local de la lista de planes.
enum _FiltroPlanes { todos, activos, inactivos }

/// Pantalla de gestión de planes comerciales.
///
/// No declara `Scaffold` propio: vive dentro del body de
/// `ControlCenterScreen`, que ya aporta el contenedor y el `CustomAppBar`.
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  _FiltroPlanes _filtro = _FiltroPlanes.todos;

  static const Color _violeta = Color(0xFF8B5CF6);
  static const double _anchoMaximo = 1400;

  @override
  Widget build(BuildContext context) {
    final planesAsync = ref.watch(planesTodosProvider);
    final accion = ref.watch(planesActionsProvider);

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
              _header(planesAsync.valueOrNull?.length),
              const SizedBox(height: 16),
              _filtroToggle(),
              const SizedBox(height: 16),
              Expanded(
                child: planesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => EmptyState(
                    icon: Icons.error_outline_rounded,
                    titulo: 'Error al cargar los planes',
                    subtitulo: '$e',
                    color: const Color(0xFFEF4444),
                    accion: ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(planesTodosProvider),
                      child: const Text('Reintentar'),
                    ),
                  ),
                  data: (planes) => _lista(planes, accion),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // HEADER Y FILTRO
  // ═════════════════════════════════════════════════════════════

  Widget _header(int? total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Planes',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                total == null
                    ? 'Cargando...'
                    : '$total ${total == 1 ? 'plan' : 'planes'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _abrirFormulario(null),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Nuevo plan'),
          style: ElevatedButton.styleFrom(backgroundColor: _violeta),
        ),
      ],
    );
  }

  Widget _filtroToggle() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedToggle<_FiltroPlanes>(
        items: const [
          SegmentedToggleItem(
            value: _FiltroPlanes.todos,
            label: 'Todos',
            icon: Icons.list_rounded,
          ),
          SegmentedToggleItem(
            value: _FiltroPlanes.activos,
            label: 'Activos',
            icon: Icons.check_circle_rounded,
          ),
          SegmentedToggleItem(
            value: _FiltroPlanes.inactivos,
            label: 'Inactivos',
            icon: Icons.block_rounded,
          ),
        ],
        selected: _filtro,
        onChanged: (f) => setState(() => _filtro = f),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // LISTA
  // ═════════════════════════════════════════════════════════════

  Widget _lista(List<Plan> planes, PlanesActionState accion) {
    final filtrados = switch (_filtro) {
      _FiltroPlanes.todos => planes,
      _FiltroPlanes.activos => planes.where((p) => p.activo).toList(),
      _FiltroPlanes.inactivos => planes.where((p) => !p.activo).toList(),
    };

    if (filtrados.isEmpty) {
      return EmptyState(
        icon: Icons.credit_card_off_rounded,
        titulo: 'Sin planes',
        subtitulo: _filtro == _FiltroPlanes.todos
            ? 'Crea el primero con el botón de arriba'
            : 'No hay planes en este filtro',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: filtrados.length,
      itemBuilder: (context, i) {
        final plan = filtrados[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlanCard(
            plan: plan,
            cargando: accion.estado == PlanAccionEstado.cargando,
            onEditar: () => _abrirFormulario(plan),
            onToggleActivo: () => _toggleActivo(plan),
            onEliminar: () => _confirmarEliminar(plan),
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // ACCIONES
  // ═════════════════════════════════════════════════════════════

  /// Abre el formulario. [plan] `null` = crear uno nuevo.
  void _abrirFormulario(Plan? plan) {
    final notifier = ref.read(planesActionsProvider.notifier);

    showDialog<void>(
      context: context,
      builder: (ctx) => _PlanFormDialog(plan: plan, notifier: notifier),
    );
  }

  Future<void> _toggleActivo(Plan plan) async {
    final notifier = ref.read(planesActionsProvider.notifier);
    final ok = await notifier.toggleActivo(plan.id, !plan.activo);
    if (!mounted) return;
    _snack(
      ok
          ? 'Plan ${plan.activo ? "desactivado" : "activado"}'
          : 'No se pudo cambiar el estado',
    );
  }

  /// Pide confirmación, comprobando antes que no tenga suscripciones.
  Future<void> _confirmarEliminar(Plan plan) async {
    final notifier = ref.read(planesActionsProvider.notifier);
    final puede = await notifier.sePuedeEliminar(plan.id);
    if (!mounted) return;

    if (!puede) {
      _snack('No se puede eliminar: tiene suscripciones asociadas');
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => GlassDialog(
        maxWidth: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.delete_rounded,
              title: 'Eliminar plan',
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 18),
            Text(
              '¿Eliminar el plan "${plan.nombre}"? '
              'Esta acción no se puede deshacer.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 18),
            FormActions(
              isSaving: false,
              confirmLabel: 'Eliminar',
              accentColor: const Color(0xFFEF4444),
              onCancel: () => Navigator.pop(ctx, false),
              onConfirm: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );

    if (confirmado != true) return;

    final ok = await notifier.eliminar(plan.id);
    if (!mounted) return;
    _snack(ok ? 'Plan eliminado' : 'No se pudo eliminar el plan');
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
      );
  }
}

// ═══════════════════════════════════════════════════════════════
// FORMULARIO (crear / editar)
// ═══════════════════════════════════════════════════════════════

/// Formulario de alta y edición de un plan.
///
/// Es su propio `ConsumerStatefulWidget` para poder escuchar
/// [planesActionsProvider] y cerrarse solo al terminar con éxito.
class _PlanFormDialog extends ConsumerStatefulWidget {
  final Plan? plan;
  final PlanesActionsNotifier notifier;

  const _PlanFormDialog({required this.plan, required this.notifier});

  @override
  ConsumerState<_PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends ConsumerState<_PlanFormDialog> {
  static const Color _violeta = Color(0xFF8B5CF6);

  /// Valor que la base usa para "sin límite" en `max_locales` /
  /// `max_usuarios`.
  static const int _ilimitado = 999999;

  static const List<String> _modos = [
    'restaurante',
    'retail',
    'servicios',
  ];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _id;
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precioMensual;
  late final TextEditingController _precioAnual;
  late final TextEditingController _moneda;
  late final TextEditingController _maxLocales;
  late final TextEditingController _maxUsuarios;
  late final TextEditingController _orden;

  late final Set<String> _modosSel;
  late bool _activo;
  late bool _maxLocalesIlimitado;
  late bool _maxUsuariosIlimitado;
  bool _guardando = false;

  bool get _esEdicion => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _id = TextEditingController(text: p?.id ?? '');
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _precioMensual = TextEditingController(
      text: p == null ? '' : _num(p.precioMensual),
    );
    _precioAnual = TextEditingController(
      text: p == null ? '' : _num(p.precioAnual),
    );
    _moneda = TextEditingController(text: p?.moneda ?? 'USD');
    _maxLocales = TextEditingController(
      text: p == null ? '999999' : '${p.maxLocales}',
    );
    _maxUsuarios = TextEditingController(
      text: p == null ? '999999' : '${p.maxUsuarios}',
    );
    _orden = TextEditingController(text: p == null ? '0' : '${p.orden}');
    _modosSel = {...?p?.modosHabilitados};
    _activo = p?.activo ?? true;
    _maxLocalesIlimitado = (p?.maxLocales ?? 999999) >= 999999;
    _maxUsuariosIlimitado = (p?.maxUsuarios ?? 999999) >= 999999;
  }

  @override
  void dispose() {
    _id.dispose();
    _nombre.dispose();
    _descripcion.dispose();
    _precioMensual.dispose();
    _precioAnual.dispose();
    _moneda.dispose();
    _maxLocales.dispose();
    _maxUsuarios.dispose();
    _orden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escucha la acción: cierra el diálogo al.exit, avisa al fallar.
    ref.listen<PlanesActionState>(planesActionsProvider, (prev, next) {
      if (!mounted) return;

      if (next.estado == PlanAccionEstado.exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(_esEdicion ? 'Plan actualizado' : 'Plan creado'),
              duration: const Duration(seconds: 2),
            ),
          );
        return;
      }

      if (next.estado == PlanAccionEstado.error) {
        // No se cierra: el usuario puede corregir y reintentar.
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.mensajeError ?? 'Error desconocido'),
              backgroundColor: const Color(0xFFEF4444),
              duration: const Duration(seconds: 3),
            ),
          );
      }
    });

    return GlassDialog(
      maxWidth: 560,
      maxHeightFactor: 0.9,
      // Sin `scrollable: true`: el scroll va aquí, solo sobre el
      // formulario, para que cabecera y botones nunca se corten.
      child: Form(
        key: _formKey,
        // `GlassDialog` no aporta padding interno, así que se aplica
        // aquí para separar el contenido de los bordes del panel.
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            // `min` + `Flexible`: el diálogo se ajusta al contenido y
            // solo scrollea si el formulario no cabe. Es seguro porque
            // cabecera + botones (~150px) siempre son menores que el
            // `maxHeightFactor` de GlassDialog.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(
                icon: _esEdicion ? Icons.edit_rounded : Icons.add_card_rounded,
                title: _esEdicion ? 'Editar plan' : 'Nuevo plan',
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(child: _formulario()),
              ),
              const SizedBox(height: 12),
              FormActions(
                isSaving: _guardando,
                confirmLabel: _esEdicion ? 'Guardar' : 'Crear plan',
                accentColor: _violeta,
                onCancel: () => Navigator.pop(context),
                onConfirm: _enviar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          title: 'Identificación',
          icon: Icons.badge_outlined,
          accentColor: _violeta,
          children: [
            PersonaTextField(
              controller: _id,
              label: 'ID (slug) — ej: basico, pro',
              icon: Icons.tag_rounded,
              accentColor: _violeta,
              enabled: !_esEdicion,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-z0-9-]')),
              ],
              validator: _validarSlug,
            ),
            if (_esEdicion)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  'El ID no se puede cambiar después de crear el plan',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            PersonaTextField(
              controller: _nombre,
              label: 'Nombre',
              icon: Icons.label_rounded,
              accentColor: _violeta,
              validator: _requerido,
            ),
            const SizedBox(height: 10),
            PersonaTextField(
              controller: _descripcion,
              label: 'Descripción (opcional)',
              icon: Icons.notes_rounded,
              accentColor: _violeta,
              maxLines: 2,
            ),
          ],
        ),
        FormSection(
          title: 'Precios',
          icon: Icons.payments_rounded,
          accentColor: _violeta,
          children: [
            Row(
              children: [
                Expanded(
                  child: PersonaTextField(
                    controller: _precioMensual,
                    label: 'Precio mensual',
                    icon: Icons.attach_money_rounded,
                    accentColor: _violeta,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _numero,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PersonaTextField(
                    controller: _precioAnual,
                    label: 'Precio anual',
                    icon: Icons.calendar_today_rounded,
                    accentColor: _violeta,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _numero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PersonaTextField(
              controller: _moneda,
              label: 'Moneda',
              icon: Icons.currency_exchange_rounded,
              accentColor: _violeta,
            ),
          ],
        ),
        FormSection(
          title: 'Límites',
          icon: Icons.vertical_align_top_rounded,
          accentColor: _violeta,
          children: [
            // Apilados: el campo numérico es condicional y en dos
            // columnas los switches no quedarían alineados.
            _LimiteField(
              label: 'Máx. locales',
              labelIlimitado: 'Ilimitado locales',
              icon: Icons.store_rounded,
              controller: _maxLocales,
              ilimitado: _maxLocalesIlimitado,
              onCambiarIlimitado: (v) =>
                  _setIlimitado(esLocales: true, ilimitado: v),
              validator: _enteroNoIlimitado,
              accentColor: _violeta,
            ),
            const SizedBox(height: 12),
            _LimiteField(
              label: 'Máx. usuarios',
              labelIlimitado: 'Ilimitado usuarios',
              icon: Icons.people_rounded,
              controller: _maxUsuarios,
              ilimitado: _maxUsuariosIlimitado,
              onCambiarIlimitado: (v) =>
                  _setIlimitado(esLocales: false, ilimitado: v),
              validator: _enteroNoIlimitado,
              accentColor: _violeta,
            ),
          ],
        ),
        FormSection(
          title: 'Modos habilitados',
          icon: Icons.tune_rounded,
          accentColor: _violeta,
          showDivider: false,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final modo in _modos)
                  FilterChip(
                    label: Text(modo),
                    selected: _modosSel.contains(modo),
                    // El FilterChip estándar hereda `colorScheme.primary`
                    // (verde en este tema), así que se fija la paleta del
                    // diálogo explícitamente en ambos estados.
                    selectedColor: _violeta,
                    backgroundColor:
                        colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                    checkmarkColor: Colors.white,
                    showCheckmark: true,
                    side: BorderSide(
                      color: _modosSel.contains(modo)
                          ? _violeta
                          : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _modosSel.contains(modo)
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        _modosSel.add(modo);
                      } else {
                        _modosSel.remove(modo);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ActiveToggle(
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
              activeLabel: 'Activo',
              inactiveLabel: 'Inactivo',
              activeColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            PersonaTextField(
              controller: _orden,
              label: 'Orden de visualización',
              icon: Icons.low_priority_rounded,
              accentColor: _violeta,
              keyboardType: TextInputType.number,
              validator: _entero,
            ),
          ],
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // ENVÍO Y VALIDACIÓN
  // ═════════════════════════════════════════════════════════════

  /// Sincroniza el switch de "ilimitado" con su campo numérico.
  ///
  /// Al activar, fuerza el valor a 999999. Al desactivar deja el texto
  /// tal cual para que el usuario ajuste la cantidad.
  void _setIlimitado({
    required bool esLocales,
    required bool ilimitado,
  }) {
    setState(() {
      if (esLocales) {
        _maxLocalesIlimitado = ilimitado;
        if (ilimitado) _maxLocales.text = '$_ilimitado';
      } else {
        _maxUsuariosIlimitado = ilimitado;
        if (ilimitado) _maxUsuarios.text = '$_ilimitado';
      }
    });
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _guardando = true);

    final id = _id.text.trim();
    final nombre = _nombre.text.trim();
    final descripcion = _descripcion.text.trim();
    final precioMensual = double.tryParse(_precioMensual.text.trim()) ?? 0;
    final precioAnual = double.tryParse(_precioAnual.text.trim()) ?? 0;
    final moneda = _moneda.text.trim();
    final maxLocales = _maxLocalesIlimitado
        ? _ilimitado
        : (int.tryParse(_maxLocales.text.trim()) ?? 1);
    final maxUsuarios = _maxUsuariosIlimitado
        ? _ilimitado
        : (int.tryParse(_maxUsuarios.text.trim()) ?? 1);
    final orden = int.tryParse(_orden.text.trim()) ?? 0;
    final modos = _modosSel.toList();

    if (_esEdicion) {
      // En edición no se reenvía `id` (es la PK) ni `descripcion` vacía,
      // porque `actualizar` ignora los nulls.
      await widget.notifier.actualizar(
        id: id,
        nombre: nombre,
        descripcion: descripcion.isEmpty ? null : descripcion,
        precioMensual: precioMensual,
        precioAnual: precioAnual,
        moneda: moneda,
        maxLocales: maxLocales,
        maxUsuarios: maxUsuarios,
        modosHabilitados: modos,
        activo: _activo,
        orden: orden,
      );
    } else {
      await widget.notifier.crear(
        id: id,
        nombre: nombre,
        descripcion: descripcion.isEmpty ? null : descripcion,
        precioMensual: precioMensual,
        precioAnual: precioAnual,
        moneda: moneda,
        maxLocales: maxLocales,
        maxUsuarios: maxUsuarios,
        modosHabilitados: modos,
        activo: _activo,
        orden: orden,
      );
    }
  }

  String? _validarSlug(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El id es obligatorio';
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(v)) {
      return 'Solo minúsculas, números y guiones';
    }
    return null;
  }

  String? _requerido(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Obligatorio';
    return null;
  }

  String? _numero(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '0';
    if (double.tryParse(v) == null) return 'Número inválido';
    if (double.parse(v) < 0) return 'No puede ser negativo';
    return null;
  }

  String? _entero(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '0';
    final n = int.tryParse(v);
    if (n == null) return 'Entero inválido';
    if (n < 0) return 'No puede ser negativo';
    return null;
  }

  /// Valida un límite cuando NO está en modo ilimitado: 1..999998.
  String? _enteroNoIlimitado(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Obligatorio';
    final n = int.tryParse(v);
    if (n == null) return 'Entero inválido';
    if (n < 1 || n >= _ilimitado) return 'Entre 1 y ${_ilimitado - 1}';
    return null;
  }

  /// "60.0" → "60" para no mostrar decimales inútiles en los campos.
  String _num(double v) {
    if (v == v.roundToDouble()) return '${v.round()}';
    return '$v';
  }
}

// ═══════════════════════════════════════════════════════════════
// CAMPO DE LÍMITE
// ═══════════════════════════════════════════════════════════════

/// Campo de un límite con switch "ilimitado".
///
/// Cuando el switch está activo el campo numérico **desaparece** y el
/// valor se fuerza a 999999, que es la convención de la base de datos
/// para "sin límite".
class _LimiteField extends StatelessWidget {
  final String label;
  final String labelIlimitado;
  final IconData icon;
  final TextEditingController controller;
  final bool ilimitado;
  final ValueChanged<bool> onCambiarIlimitado;
  final String? Function(String?)? validator;
  final Color accentColor;

  const _LimiteField({
    required this.label,
    required this.labelIlimitado,
    required this.icon,
    required this.controller,
    required this.ilimitado,
    required this.onCambiarIlimitado,
    required this.validator,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: ilimitado,
              onChanged: onCambiarIlimitado,
              // `activeColor` está deprecado desde 3.31; la thumb es el
              // control que cambia de color, la pista lleva el acento.
              activeThumbColor: Colors.white,
              activeTrackColor: accentColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            // El texto también es clickeable: área táctil más cómoda.
            GestureDetector(
              onTap: () => onCambiarIlimitado(!ilimitado),
              child: Text(
                ilimitado ? labelIlimitado : label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ilimitado ? accentColor : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (!ilimitado) ...[
          const SizedBox(height: 6),
          Padding(
            // Alinea el campo con el texto del switch.
            padding: const EdgeInsets.only(left: 48),
            child: PersonaTextField(
              controller: controller,
              label: 'Cantidad',
              icon: icon,
              accentColor: accentColor,
              keyboardType: TextInputType.number,
              validator: validator,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ],
      ],
    );
  }
}
