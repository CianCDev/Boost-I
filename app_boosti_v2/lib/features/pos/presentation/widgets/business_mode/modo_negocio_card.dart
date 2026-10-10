// lib/features/pos/presentation/widgets/business_mode/modo_negocio_card.dart
import 'package:flutter/material.dart';

import '../../providers/business_mode_provider.dart';

/// Card reutilizable de modo de negocio (Mercado / Restaurante / Servicios).
///
/// Usada en:
///   - `SeleccionarModoNegocioScreen` (onboarding)
///   - `ConfiguracionModoNegocioScreen` (Settings)
///
/// Estados visuales:
///   - `bloqueado: true`  → opacidad baja + badge "Pro" con candado.
///   - `seleccionado: true` → gradiente teñido + borde + glow.
///   - Hover (si seleccionable) → escala + glow suave + icono rota.
class ModoNegocioCard extends StatefulWidget {
  final BusinessMode modo;
  final bool seleccionado;
  final bool bloqueado;
  final String planRequerido;

  /// Etiqueta del badge cuando está seleccionado.
  /// En onboarding usamos "Elegido"; en Settings usamos "Actual".
  final String badgeSeleccionado;

  final VoidCallback onTap;

  const ModoNegocioCard({
    super.key,
    required this.modo,
    required this.seleccionado,
    required this.bloqueado,
    required this.planRequerido,
    required this.onTap,
    this.badgeSeleccionado = 'Elegido',
  });

  @override
  State<ModoNegocioCard> createState() => _ModoNegocioCardState();
}

class _ModoNegocioCardState extends State<ModoNegocioCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.modo.color;
    final activo = widget.seleccionado;
    final bloqueado = widget.bloqueado;
    final mostrarHover = _hovered && !bloqueado && !activo;

    // ── Fondo ──
    final Gradient? bgGradient;
    final Color? bgColor;

    if (activo) {
      bgGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.06),
        ],
      );
      bgColor = null;
    } else if (bloqueado) {
      bgGradient = null;
      bgColor = Colors.white.withValues(alpha: 0.03);
    } else {
      bgGradient = null;
      bgColor = Colors.white.withValues(alpha: mostrarHover ? 0.10 : 0.06);
    }

    // ── Borde ──
    final Color borderColor;
    final double borderWidth;
    if (activo) {
      borderColor = color.withValues(alpha: 0.70);
      borderWidth = 1.5;
    } else if (mostrarHover) {
      borderColor = color.withValues(alpha: 0.50);
      borderWidth = 1.3;
    } else {
      borderColor = Colors.white.withValues(alpha: 0.10);
      borderWidth = 1;
    }

    final scale = mostrarHover ? 1.015 : 1.0;

    return MouseRegion(
      cursor: bloqueado
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: bloqueado ? null : widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: bgGradient,
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: activo
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : mostrarHover
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
            ),
            child: Opacity(
              opacity: bloqueado ? 0.70 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: mostrarHover
                              ? color.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: mostrarHover
                                ? color.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.06),
                            width: 1,
                          ),
                        ),
                        child: AnimatedRotation(
                          turns: mostrarHover ? 0.02 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: Icon(widget.modo.icon, color: color, size: 22),
                        ),
                      ),
                      const Spacer(),
                      if (bloqueado)
                        _buildProBadge()
                      else if (activo)
                        _buildSeleccionadoBadge(color),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: mostrarHover ? color : Colors.white,
                      letterSpacing: -0.3,
                    ),
                    child: Text(widget.modo.label),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.modo.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._featuresDelModo(widget.modo).map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: mostrarHover
                                  ? color.withValues(alpha: 0.85)
                                  : Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.80),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_rounded,
            size: 10,
            color: const Color(0xFFF59E0B).withValues(alpha: 0.85),
          ),
          const SizedBox(width: 4),
          Text(
            widget.planRequerido,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.90),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeleccionadoBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            widget.badgeSeleccionado,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _featuresDelModo(BusinessMode modo) {
    switch (modo) {
      case BusinessMode.retail:
        return const [
          'Ventas rápidas con código de barras',
          'Inventario y stock en tiempo real',
          'Clientes, descuentos y promociones',
          'Cierre de caja y arqueo',
        ];
      case BusinessMode.restaurante:
        return const [
          'Mesas y control de salón',
          'Comandas a cocina (KDS)',
          'Modificadores de producto',
          'Propinas y división de cuenta',
        ];
      case BusinessMode.servicios:
        return const [
          'Agenda y citas por profesional',
          'Catálogo de servicios',
          'Comisiones por profesional',
          'Historial de clientes',
        ];
    }
  }
}