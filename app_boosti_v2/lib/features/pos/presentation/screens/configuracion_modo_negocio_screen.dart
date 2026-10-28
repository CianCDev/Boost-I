// lib/features/pos/presentation/screens/settings/configuracion_modo_negocio_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/departamento_entity.dart';
import '../../data/Local/entities/plan_entity.dart';
import '../../data/Local/entities/suscripcion_entity.dart';
import '../providers/business_mode_provider.dart';
import '../providers/departamentos_provider.dart';
import '../providers/suscripcion_provider.dart';
import '../providers/usuario_provider.dart';
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/business_mode/modo_negocio_card.dart';
import '../widgets/common/dialog_header.dart';
import '../widgets/common/glass_dialog.dart';
import '../widgets/common/persona_form_template.dart' show FormActions;

/// Pantalla de Settings para cambiar el modo de negocio del local activo.
///
/// Reglas:
///   - Solo admin puede entrar (se valida en `UserSettingsScreen`).
///   - Modos bloqueados por el plan aparecen con candado.
///   - El modo actual viene marcado como "Actual".
///   - Doble confirmación antes de guardar.
class ConfiguracionModoNegocioScreen extends ConsumerStatefulWidget {
  const ConfiguracionModoNegocioScreen({super.key});

  @override
  ConsumerState<ConfiguracionModoNegocioScreen> createState() =>
      _ConfiguracionModoNegocioScreenState();
}

class _ConfiguracionModoNegocioScreenState
    extends ConsumerState<ConfiguracionModoNegocioScreen> {
  BusinessMode? _seleccionado;
  bool _guardando = false;
  bool _inicializado = false;

  @override
  Widget build(BuildContext context) {
    final suscripcionAsync = ref.watch(suscripcionProvider);
    final planesAsync = ref.watch(planesProvider);
    final modoActual = ref.watch(businessModeProvider);
    final isMobile = ResponsiveHelper.isMobile(context);

    // Autoseleccionar el modo actual la primera vez.
    if (!_inicializado) {
      _seleccionado = modoActual;
      _inicializado = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E27), Color(0xFF2D1B69)],
            ),
          ),
        ),
        title: const Text(
          'Modo de negocio',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF1A1A4E),
                  Color(0xFF2D1B69),
                  Color(0xFF4C2B8C),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -150,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: modoActual.color.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: _buildCard(
                    suscripcionAsync,
                    planesAsync,
                    modoActual,
                    isMobile,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    AsyncValue<SuscripcionEntity?> suscripcionAsync,
    AsyncValue<List<PlanEntity>> planesAsync,
    BusinessMode modoActual,
    bool isMobile,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(modoActual, isMobile, suscripcion: suscripcionAsync.valueOrNull),
              const SizedBox(height: 24),
              _buildBody(
                suscripcionAsync,
                planesAsync,
                modoActual,
                isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BusinessMode modoActual, bool isMobile, {SuscripcionEntity? suscripcion}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                modoActual.color,
                Color.lerp(modoActual.color, Colors.black, 0.20)!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: modoActual.color.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            modoActual.icon,
            color: Colors.white,
            size: isMobile ? 24 : 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo actual: ${modoActual.label}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cambia el tipo de operación de este local. '
                'Los datos actuales no se eliminarán.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: isMobile ? 12.5 : 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        // 🎯 NUEVO: badge del plan actual
        if (suscripcion != null) ...[
          const SizedBox(width: 12),
          _buildPlanBadge(suscripcion),
        ],
      ],
    );
  }

  Widget _buildPlanBadge(SuscripcionEntity s) {
    final esTrial = s.estado == 'trial';
    final esActiva = s.estado == 'activa';
    final color = esActiva
        ? const Color(0xFF10B981)
        : esTrial
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    final label = esTrial
        ? '${s.planId.toUpperCase()} · Trial'
        : esActiva
            ? s.planId.toUpperCase()
            : s.estado.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<SuscripcionEntity?> suscripcionAsync,
    AsyncValue<List<PlanEntity>> planesAsync,
    BusinessMode modoActual,
    bool isMobile,
  ) {
    if (suscripcionAsync.isLoading || planesAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final suscripcion = suscripcionAsync.valueOrNull;
    final planes = planesAsync.valueOrNull ?? const <PlanEntity>[];

    final modosDisponibles = <String>{};
    if (suscripcion != null && suscripcion.activa) {
      final planActual =
          planes.where((p) => p.planId == suscripcion.planId).firstOrNull;
      if (planActual != null) {
        modosDisponibles.addAll(planActual.modosHabilitados);
      }
    } else {
      // Sin suscripción activa se permite únicamente el modo minorista.
      modosDisponibles.add('retail');
    }

    final hayCambio = _seleccionado != null && _seleccionado != modoActual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Selecciona el modo', isMobile),
        const SizedBox(height: 14),
        _buildGrid(modosDisponibles, planes, isMobile),
        const SizedBox(height: 20),
        _buildInfoNote(),
        const SizedBox(height: 22),
        _buildBotonGuardar(hayCambio, modoActual, isMobile),
      ],
    );
  }

  Widget _buildSectionLabel(String label, bool isMobile) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(
    Set<String> modosDisponibles,
    List<PlanEntity> planes,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        children: [
          for (final m in BusinessMode.values) ...[
            ModoNegocioCard(
              modo: m,
              seleccionado: _seleccionado == m,
              bloqueado: !modosDisponibles.contains(m.id),
              planRequerido: _planMinimoPara(m, planes),
              badgeSeleccionado: 'Actual',
              onTap: () => setState(() => _seleccionado = m),
            ),
            if (m != BusinessMode.values.last) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final m in BusinessMode.values) ...[
            Expanded(
              child: ModoNegocioCard(
                modo: m,
                seleccionado: _seleccionado == m,
                bloqueado: !modosDisponibles.contains(m.id),
                planRequerido: _planMinimoPara(m, planes),
                badgeSeleccionado: 'Actual',
                onTap: () => setState(() => _seleccionado = m),
              ),
            ),
            if (m != BusinessMode.values.last) const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }

  String _planMinimoPara(BusinessMode modo, List<PlanEntity> planes) {
    final ordenados = [...planes]..sort((a, b) => a.orden.compareTo(b.orden));
    for (final p in ordenados) {
      if (p.modosHabilitados.contains(modo.id)) return p.nombre;
    }
    return 'Plan superior';
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Al cambiar de modo, las funciones específicas del modo anterior '
              'quedarán ocultas. Los datos se conservan y pueden recuperarse '
              'si vuelves al modo original.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonGuardar(
    bool hayCambio,
    BusinessMode modoActual,
    bool isMobile,
  ) {
    final puede = hayCambio && !_guardando;
    final color = _seleccionado?.color ?? const Color(0xFF10B981);

    return SizedBox(
      height: isMobile ? 56 : 60,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: puede ? _guardar : null,
          borderRadius: BorderRadius.circular(16),
          mouseCursor: puede
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Ink(
            decoration: BoxDecoration(
              gradient: puede
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [color, Color.lerp(color, Colors.black, 0.18)!],
                    )
                  : null,
              color: puede ? null : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              boxShadow: puede
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: _guardando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hayCambio
                              ? Icons.check_rounded
                              : Icons.check_circle_rounded,
                          size: 20,
                          color: puede
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          hayCambio
                              ? 'Guardar cambio a ${_seleccionado?.label}'
                              : 'Sin cambios pendientes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: puede
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // GUARDAR
  // ══════════════════════════════════════════════════════════════════

  Future<void> _guardar() async {
    if (_seleccionado == null || _guardando) return;

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ConfirmarCambioDialog(modo: _seleccionado!),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);

    final ok = await ref
        .read(businessModeProvider.notifier)
        .cambiarModo(_seleccionado!);

    if (!mounted) return;

    if (ok) {
      // PASO E · Seed de estaciones de cocina (TODO.md "Seed de
      // estaciones"): un local que entra a restaurante sin NINGUNA
      // estación queda con el bulk en "Este local no tiene estaciones" y
      // el KDS sin columnas. Se siembran SOLO esa primera vez; a partir
      // de ahí son departamentos normales, editables en la pantalla de
      // departamentos.
      if (_seleccionado == BusinessMode.restaurante) {
        await _seedEstaciones();
      }
      // El seed es un `await` nuevo en el medio: re-verifica el `mounted`
      // antes de tocar `context` (el lint `use_build_context_synchronously`
      // señala un solo gap por línea y no ve el de `cambiarModo`).
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Modo cambiado a ${_seleccionado!.label}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el modo. Intenta de nuevo.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  /// SEED de estaciones de cocina (PASO E).
  ///
  /// Si el local pasa a `restaurante` estando sin NINGUNA estación, el
  /// bulk muestra "Este local no tiene estaciones" y el KDS no tiene a
  /// dónde mandar líneas. Se siembran las 3 de fábrica (orden 0/1/2).
  ///
  /// Va por `guardarDepartamentoProvider` (departamentos_provider.dart:63)
  /// y no directo contra Isar: así hereda la validación de duplicados y
  /// los `invalidate` de los providers derivados.
  ///
  /// Disparo: SOLO si el local no llega a tener UNA sola estación (ver el
  /// check del principio): si ya tiene —aunque sea una— es un local que
  /// se configuró a su manera; sembrar encima sería escribir de más.
  ///
  /// Best-effort a propósito: si el seed falla el modo ya se registró y
  /// el local puede crear las estaciones a mano; se anota y se sigue.
  Future<void> _seedEstaciones() async {
    try {
      final localActivo = await IsarService().obtenerLocalActivo();
      final existentes = await IsarService()
          .obtenerDepartamentos(localId: localActivo?.id);
      if (existentes.isNotEmpty) return;

      final usuarioId = ref.read(usuarioActualProvider)?.id ?? 0;
      final estaciones = <(String nombre, int orden)>[
        ('Cocina', 0),
        ('Barra', 1),
        ('Postres', 2),
      ];
      for (final (nombre, orden) in estaciones) {
        await ref.read(guardarDepartamentoProvider(DepartamentoEntity()
          ..nombre = nombre
          ..descripcion = 'Estación de fábrica (seed)'
          ..orden = orden
          ..localId = localActivo?.id
          ..usuarioId = usuarioId
          ..activo = true
          ..sincronizado = false).future);
      }
      debugPrint('🍳 [estaciones] seed aplicado '
          '(${estaciones.length} estaciones, local ${localActivo?.id})');
    } catch (e) {
      debugPrint('⚠️ [estaciones] seed falló (best-effort): $e');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DIÁLOGO DE CONFIRMACIÓN
// ═══════════════════════════════════════════════════════════════════════

class _ConfirmarCambioDialog extends StatelessWidget {
  final BusinessMode modo;

  const _ConfirmarCambioDialog({required this.modo});

  @override
  Widget build(BuildContext context) {
    final color = modo.color;

    return Theme(
      data: ThemeData.dark(),
      child: GlassDialog(
        maxWidth: 480,
        accentColor: color,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(
                icon: Icons.warning_amber_rounded,
                title: 'Cambiar modo',
                subtitle: 'Esta acción afecta toda la operación',
                color: color,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.18),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Icon(modo.icon, color: color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            modo.label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: color,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            modo.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Las funciones del modo anterior quedarán ocultas. '
                        'Los datos se conservan por si quieres volver.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FormActions(
                isSaving: false,
                confirmLabel: 'Confirmar cambio',
                cancelLabel: 'Cancelar',
                accentColor: color,
                onCancel: () => Navigator.pop(context, false),
                onConfirm: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}