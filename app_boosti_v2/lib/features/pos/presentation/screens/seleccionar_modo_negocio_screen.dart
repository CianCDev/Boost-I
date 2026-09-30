// lib/features/pos/presentation/screens/onboarding/seleccionar_modo_negocio_screen.dart
import 'dart:ui';

import 'package:app_boosti_v2/features/pos/data/Local/entities/plan_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/suscripcion_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/suscripcion_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/main_pos_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/dialog_header.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_dialog.dart';
import '../widgets/business_mode/modo_negocio_card.dart';

import 'package:app_boosti_v2/features/pos/presentation/widgets/common/persona_form_template.dart' show FormActions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de onboarding: se muestra la primera vez que el usuario
/// entra a un local sin `businessMode` configurado.
class SeleccionarModoNegocioScreen extends ConsumerStatefulWidget {
  const SeleccionarModoNegocioScreen({super.key});

  @override
  ConsumerState<SeleccionarModoNegocioScreen> createState() =>
      _SeleccionarModoNegocioScreenState();
}

class _SeleccionarModoNegocioScreenState
    extends ConsumerState<SeleccionarModoNegocioScreen> {
  BusinessMode? _seleccionado;
  bool _guardando = false;

  static const Color _amarilloPro = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final suscripcionAsync = ref.watch(suscripcionProvider);
    final planesAsync = ref.watch(planesProvider);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: isMobile ? null : 960,
                  margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: -5,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        blurRadius: 60,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(
                              suscripcionAsync.valueOrNull,
                              isMobile,
                            ),
                            const SizedBox(height: 26),
                            _buildBody(
                              suscripcionAsync,
                              planesAsync,
                              isMobile,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════

  Widget _buildHeader(SuscripcionEntity? suscripcion, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.tune_rounded,
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
                'Configura tu negocio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona el tipo de operación de este local. '
                'Ajustaremos la app en consecuencia.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isMobile ? 12.5 : 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (suscripcion != null && suscripcion.estado == 'trial') ...[
          const SizedBox(width: 12),
          _buildTrialBadge(suscripcion),
        ],
      ],
    );
  }

  Widget _buildTrialBadge(SuscripcionEntity s) {
    final diasRestantes = s.trialHasta != null
        ? s.trialHasta!.difference(DateTime.now()).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _amarilloPro.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _amarilloPro.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 12,
            color: _amarilloPro.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 5),
          Text(
            'Trial: $diasRestantes días',
            style: TextStyle(
              color: _amarilloPro.withValues(alpha: 0.90),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════════════

  Widget _buildBody(
    AsyncValue<SuscripcionEntity?> suscripcionAsync,
    AsyncValue<List<PlanEntity>> planesAsync,
    bool isMobile,
  ) {
    if (suscripcionAsync.isLoading || planesAsync.isLoading) {
      return _buildLoading();
    }
    if (suscripcionAsync.hasError) {
      return _buildError(suscripcionAsync.error!);
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
      modosDisponibles.add('mercado');
    }

    _seleccionado ??= BusinessMode.values.firstWhere(
      (m) => modosDisponibles.contains(m.id),
      orElse: () => BusinessMode.mercado,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Selecciona el tipo de operación', isMobile),
        const SizedBox(height: 14),
        _buildModoGrid(modosDisponibles, planes, isMobile),
        const SizedBox(height: 20),
        _buildInfoNote(),
        const SizedBox(height: 22),
        _buildBotonContinuar(isMobile),
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

  Widget _buildModoGrid(
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
              'Podrás cambiar el modo más adelante desde Configuración. '
              'Los datos actuales no se eliminarán; solo se ocultarán las '
              'funciones que no apliquen al modo elegido.',
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

  Widget _buildBotonContinuar(bool isMobile) {
    final puede = _seleccionado != null && !_guardando;
    final color = _seleccionado?.color ?? const Color(0xFF10B981);

    return SizedBox(
      height: isMobile ? 56 : 60,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: puede ? _continuar : null,
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
                      colors: [
                        color,
                        Color.lerp(color, Colors.black, 0.18)!,
                      ],
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
                          _seleccionado?.icon ?? Icons.arrow_forward_rounded,
                          size: 20,
                          color: puede
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Continuar con ${_seleccionado?.label ?? "..."}',
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
  // LOADING / ERROR
  // ══════════════════════════════════════════════════════════════════

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 40),
          const SizedBox(height: 12),
          const Text(
            'Error cargando tu suscripción',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(suscripcionProvider);
              ref.invalidate(planesProvider);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // CONTINUAR + DIÁLOGO GENÉRICO
  // ══════════════════════════════════════════════════════════════════

  Future<void> _continuar() async {
    if (_seleccionado == null || _guardando) return;

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ConfirmarModoDialog(modo: _seleccionado!),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);

    final ok = await ref
        .read(businessModeProvider.notifier)
        .cambiarModo(_seleccionado!);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPosScreen()),
      );
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
}

// ═══════════════════════════════════════════════════════════════════════
// DIÁLOGO DE CONFIRMACIÓN (usa GlassDialog + DialogHeader + FormActions)
// ═══════════════════════════════════════════════════════════════════════

class _ConfirmarModoDialog extends StatefulWidget {
  final BusinessMode modo;

  const _ConfirmarModoDialog({required this.modo});

  @override
  State<_ConfirmarModoDialog> createState() => _ConfirmarModoDialogState();
}

class _ConfirmarModoDialogState extends State<_ConfirmarModoDialog> {
  @override
  Widget build(BuildContext context) {
    final modo = widget.modo;
    final color = modo.color;

    // 🎯 Forzamos tema oscuro: el onboarding vive sobre un gradiente
    //    púrpura fijo, así que el diálogo debe ser dark para mantener
    //    coherencia visual y contraste de texto.
    return Theme(
      data: darkTheme(),
      child: GlassDialog(
        maxWidth: 480,
        accentColor: color,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cabecera genérica ──
              DialogHeader(
                icon: Icons.check_circle_outline_rounded,
                title: 'Confirmar modo',
                subtitle: 'Vas a configurar este local',
                color: color,
              ),
              const SizedBox(height: 20),

              // ── Card del modo seleccionado ──
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
                  border: Border.all(
                    color: color.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
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
                          width: 1,
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

              // ── Nota informativa (contraste corregido) ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Los datos actuales no se eliminarán. Podrás cambiar '
                        'el modo desde Configuración en cualquier momento.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.82),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── Acciones genéricas ──
              FormActions(
                isSaving: false,
                confirmLabel: 'Confirmar',
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