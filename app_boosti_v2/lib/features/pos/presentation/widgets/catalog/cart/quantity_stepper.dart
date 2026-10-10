// lib/features/pos/presentation/widgets/catalog/cart/quantity_stepper.dart
import 'package:flutter/material.dart';

/// Control [−] N [+] para ajustar la cantidad de un item del carrito.
///
/// ## Diseño
/// - Botones circulares de 56px, ripple grande (`InkResponse.radius: 30`).
/// - Número central animado con [AnimatedSwitcher] (fade + slide 6px).
/// - Respeta `esPesado`: 3 decimales para pesados, 0 para unitarios.
///
/// ## No incluye
/// No toca el carrito ni el stock. Llama a `onIncrement` / `onDecrement` /
/// `onDelete` y el caller decide. El redondeo vive en `CartNotifier`.
///
/// ⚠️ `cantidad` es `double`, no `int`: un producto pesado necesita
/// 0.005 kg de granularidad. El paso lo elige el caller.
class QuantityStepper extends StatelessWidget {
  final double cantidad;
  final bool esPesado;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onDelete;
  final double? maximo;
  final double minimo;

  const QuantityStepper({
    super.key,
    required this.cantidad,
    required this.onIncrement,
    required this.onDecrement,
    this.onDelete,
    this.esPesado = false,
    this.maximo,
    this.minimo = 1.0,
  });

  /// Texto de la cantidad con formato según `esPesado`.
  String get _cantidadTexto => esPesado
      ? cantidad.toStringAsFixed(3)
      : cantidad.toStringAsFixed(0);

  bool get _puedeRestar => cantidad > minimo;
  bool get _puedeSumar => maximo == null || cantidad < maximo!;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = cs.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundIconButton(
          icon: Icons.remove_rounded,
          onPressed: _puedeRestar ? onDecrement : null,
          accent: accent,
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 96,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _cantidadTexto,
                  key: ValueKey<String>(_cantidadTexto),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                esPesado ? 'kg' : 'unidad(es)',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _RoundIconButton(
          icon: Icons.add_rounded,
          onPressed: _puedeSumar ? onIncrement : null,
          accent: accent,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color accent;

  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final borderColor = enabled
        ? accent.withValues(alpha: 0.35)
        : cs.outlineVariant.withValues(alpha: 0.4);
    final iconColor =
        enabled ? accent : cs.onSurfaceVariant.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onPressed,
        radius: 30,
        containedInkWell: true,
        highlightShape: BoxShape.circle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Icon(icon, size: 26, color: iconColor),
        ),
      ),
    );
  }
}