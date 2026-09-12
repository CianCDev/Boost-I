// lib/features/pos/presentation/widgets/catalog/bcv_moneda_selector.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/bcv_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/themes/app_colors.dart';

/// Dialog estilizado que muestra las tasas de cambio actuales.
///
/// Incluye:
/// - USD BCV y EUR BCV (si el país lo maneja)
/// - Tipo de cambio cruzado USD ↔ EUR
/// - Botón para refrescar con animación de rueda giratoria
/// - AnimatedSwitcher en los precios: cuando cambian, hacen fade+slide
/// - Glassmorphism con doble capa de blur
class BcvMonedaSelectorDialog extends ConsumerStatefulWidget {
  const BcvMonedaSelectorDialog({super.key});

  /// Helper para abrir el dialog.
  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const BcvMonedaSelectorDialog(),
    );
  }

  @override
  ConsumerState<BcvMonedaSelectorDialog> createState() =>
      _BcvMonedaSelectorDialogState();
}

class _BcvMonedaSelectorDialogState
    extends ConsumerState<BcvMonedaSelectorDialog>
    with TickerProviderStateMixin {
  // ─── Animación de rotación para el ícono de refresh ───
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _actualizarTasas() async {
    // Iniciar animación de rotación (infinita mientras carga)
    _rotationController.repeat();

    await ref.read(bcvProvider).actualizarTasa();

    // Detener rotación al terminar
    if (mounted) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bcv = ref.watch(bcvProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          // ✅ Doble capa de blur para un glass más profundo
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              // ✅ Gradiente sutil con transparencia
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0F1729).withValues(alpha: 0.88),
                        const Color(0xFF1E293B).withValues(alpha: 0.78),
                        const Color(0xFF0F1729).withValues(alpha: 0.85),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.94),
                        const Color(0xFFF8FAFC).withValues(alpha: 0.88),
                        Colors.white.withValues(alpha: 0.92),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : primaryGreen.withValues(alpha: 0.18),
                width: 1.2,
              ),
              boxShadow: [
                // Sombra exterior
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
                  blurRadius: 48,
                  spreadRadius: -8,
                  offset: const Offset(0, 16),
                ),
                // Glow sutil verde
                BoxShadow(
                  color: primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 40,
                  spreadRadius: -12,
                ),
              ],
            ),
            child: Stack(
              children: [
                // ✅ Glow radial interno (esquina superior izquierda)
                Positioned(
                  top: -60,
                  left: -60,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          primaryGreen.withValues(alpha: isDark ? 0.15 : 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // ✅ Glow radial morado (esquina inferior derecha)
                Positioned(
                  bottom: -80,
                  right: -80,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6366F1)
                              .withValues(alpha: isDark ? 0.15 : 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // ─── Contenido ───
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context, bcv, isDark, colorScheme),
                    _buildGlassDivider(isDark),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tasa USD
                          _MonedaTile(
                            icon: Icons.attach_money,
                            iconColor: primaryGreen,
                            label: 'Dólar BCV',
                            sublabel: 'USD → ${bcv.config.simboloMoneda}',
                            value: bcv.tasa.toStringAsFixed(2),
                            simbolo: bcv.config.simboloMoneda,
                            isDark: isDark,
                          ),

                          // Tasa EUR (solo si aplica)
                          if (bcv.config.manejaEuro && bcv.tasaEuro > 0) ...[
                            const SizedBox(height: 12),
                            _MonedaTile(
                              icon: Icons.euro_symbol,
                              iconColor: const Color(0xFF6366F1),
                              label: 'Euro BCV',
                              sublabel: 'EUR → ${bcv.config.simboloMoneda}',
                              value: bcv.tasaEuro.toStringAsFixed(2),
                              simbolo: bcv.config.simboloMoneda,
                              isDark: isDark,
                            ),
                          ],

                          // Tipo de cambio cruzado
                          if (bcv.tasaEuro > 0) ...[
                            const SizedBox(height: 16),
                            _buildCrossRate(bcv, isDark),
                          ],

                          const SizedBox(height: 16),
                          _buildPaisInfo(bcv, isDark, colorScheme),

                          // Indicador de caché
                          if (bcv.desdeCache) ...[
                            const SizedBox(height: 12),
                            _buildCacheWarning(),
                          ],
                        ],
                      ),
                    ),
                    _buildFooter(context, bcv, isDark, colorScheme),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────── HEADER ───────────────
  Widget _buildHeader(
    BuildContext context,
    BcvController bcv,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          // Ícono con glass
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryGreen.withValues(alpha: 0.20),
                      primaryGreen.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryGreen.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.currency_exchange,
                  color: primaryGreen,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasas de cambio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : textDark,
                  ),
                ),
                Text(
                  bcv.desdeCache
                      ? 'Última actualización: ${bcv.ultimaActualizacion}'
                      : 'Actualizado: ${bcv.ultimaActualizacion}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ─────────────── DIVISOR CON GLASS ───────────────
  Widget _buildGlassDivider(bool isDark) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ─────────────── INFO DEL PAÍS ───────────────
  Widget _buildPaisInfo(
    BcvController bcv,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest
                .withValues(alpha: isDark ? 0.35 : 0.45),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'País: ${bcv.config.codigoPais} · ${bcv.config.nombreMoneda}',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────── TIPO DE CAMBIO CRUZADO ───────────────
  Widget _buildCrossRate(BcvController bcv, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.12),
                const Color(0xFF8B5CF6).withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.swap_horiz_rounded,
                size: 16,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '1 EUR = ${bcv.formatearUsd(bcv.eurAUsd(1))}  ·  '
                  '1 USD = ${bcv.formatearEur(bcv.usdAEur(1))}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────── CACHE WARNING ───────────────
  Widget _buildCacheWarning() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 14,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sin conexión. Mostrando los últimos valores guardados.',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────── FOOTER ───────────────
  Widget _buildFooter(
    BuildContext context,
    BcvController bcv,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: _GlassRefreshButton(
              isLoading: bcv.cargando,
              rotationController: _rotationController,
              onPressed: _actualizarTasas,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          _PrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TILE DE MONEDA (con AnimatedSwitcher en el valor)
// ══════════════════════════════════════════════════════════════════
class _MonedaTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final String value;
  final String simbolo;
  final bool isDark;

  const _MonedaTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.simbolo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor.withValues(alpha: isDark ? 0.15 : 0.10),
                iconColor.withValues(alpha: isDark ? 0.05 : 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Ícono con glass
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ✅ AnimatedSwitcher: cuando el valor cambia,
                  // hace fade + slide vertical
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.4),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Text(
                      value,
                      key: ValueKey<String>(value), // ✅ Fuerza rebuild al cambiar
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    simbolo,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white60 : textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// BOTÓN REFRESH CON RUEDA GIRATORIA
// ══════════════════════════════════════════════════════════════════
class _GlassRefreshButton extends StatelessWidget {
  final bool isLoading;
  final AnimationController rotationController;
  final VoidCallback onPressed;
  final bool isDark;

  const _GlassRefreshButton({
    required this.isLoading,
    required this.rotationController,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: isDark ? 0.05 : 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Animación de rueda giratoria mientras carga
                  AnimatedBuilder(
                    animation: rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: rotationController.value * 6.283185, // 2π
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: isLoading
                          ? primaryGreen
                          : (isDark ? Colors.white : textDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLoading ? 'Actualizando...' : 'Actualizar tasas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLoading
                          ? primaryGreen
                          : (isDark ? Colors.white : textDark),
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
}

// ══════════════════════════════════════════════════════════════════
// BOTÓN PRIMARIO (LISTO)
// ══════════════════════════════════════════════════════════════════
class _PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _PrimaryButton({
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryGreen,
                primaryGreen.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Text(
              'Listo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}