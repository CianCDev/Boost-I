// lib/features/pos/presentation/widgets/common/animated_appbar_icon.dart
import 'dart:async';

import 'package:flutter/material.dart';

/// Botón de icono para el `actions` del `CustomAppBar` del POS.
///
/// Hace dos cosas:
///
/// 1. **Fuerza el icono a blanco.** `CustomAppBar` ya pone
///    `iconTheme: IconThemeData(color: Colors.white)` (`appbar.dart:93`), así
///    que hoy los iconos ya salen claros. Esto es un seguro: si alguien
///    cambia el `iconTheme` o mete un `Icon` con color explícito, el botón no
///    se vuelve invisible sobre el gradiente oscuro.
/// 2. **Pulsa con una animación corta** (escala 1.0 → 0.85 → 1.0 en
///    [duracionPulso]). El `InkWell` de Material se ve muy tenue sobre un
///    gradiente oscuro con iconos claros, y en una tablet de cocina donde se
///    toca a ciegas el feedback visual es la diferencia entre "no me oyó" y
///    "sí me oyó".
///
/// ⚠️ El callback se dispara ANTES de la animación, no después. Es lo que
/// permite tocar dos veces seguidas: si la animación bloquease, el segundo
/// toque se perdería, y en un toggle (sonido on/off) el usuario "pierde" el
/// toque. La animación se reinicia desde el principio si ya está corriendo.
class AnimatedAppBarIcon extends StatefulWidget {
  /// Icono del estado principal.
  final IconData icon;

  /// Acción al tocar. `null` deshabilita el botón: se pinta atenuado y no
  /// reacciona, igual que un `IconButton` normal.
  final VoidCallback? onPressed;

  final String tooltip;

  /// Segundo icono, para toggles de dos estados (sonido on/off).
  ///
  /// ⚠️ No sirve para más de dos estados: si hacen falta tres o más, un
  /// `PopupMenuButton` ya resuelve mejor el caso.
  final IconData? iconoAlternativo;

  /// Cuál de los dos iconos pintar.
  final bool usarAlternativo;

  /// Tamaño del icono. `null` = el que ponga el tema.
  final double? tamanoIcono;

  /// Color del icono. `null` = blanco puro (el valor por defecto).
  ///
  /// Existe para los toggles que necesitan una segunda señal visual: el
  /// 🔔/🔕 del KDS baja a `onSurfaceVariant` cuando está silenciado, y sin
  /// esta salida el estado "apagado" se perdería al forzar blanco.
  ///
  /// ⚠️ Los iconos deshabilitados los pinta el propio `IconButton` (atenuados
  /// según `Theme.disabledColor`). Un color explícito lo pisa, así que no lo
  /// pases si esperas ver el gris de "desactivado".
  final Color? colorIcono;

  final Duration duracionPulso;

  const AnimatedAppBarIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconoAlternativo,
    this.usarAlternativo = false,
    this.tamanoIcono,
    this.colorIcono,
    this.duracionPulso = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedAppBarIcon> createState() => _AnimatedAppBarIconState();
}

class _AnimatedAppBarIconState extends State<AnimatedAppBarIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duracionPulso);
    // Se devuelve con `reverse`: sin él, un toque que acaba antes que la
    // animación deja el icono congelado en 0.85 hasta el siguiente rebuild.
    _escala = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedAppBarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duracionPulso != widget.duracionPulso) {
      _ctrl.duration = widget.duracionPulso;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// El pulso visual. No bloquea la acción: [_alTocar] la dispara antes.
  Future<void> _pulso() async {
    if (_ctrl.isAnimating) _ctrl.stop();
    try {
      await _ctrl.forward().orCancel;
      await _ctrl.reverse().orCancel;
    } catch (_) {
      // `TickerFuture` lanza si el Ticker se cancela, y eso pasa cuando el
      // widget se desmonta a mitad del pulso. No queda nada que limpiar:
      // `dispose()` ya se encarga.
    }
  }

  void _alTocar() {
    widget.onPressed?.call();
    unawaited(_pulso());
  }

  @override
  Widget build(BuildContext context) {
    final usarAlt =
        widget.usarAlternativo && widget.iconoAlternativo != null;

    return IconButton(
      onPressed: widget.onPressed == null ? null : _alTocar,
      tooltip: widget.tooltip,
      icon: ScaleTransition(
        scale: _escala,
        child: Icon(
          usarAlt ? widget.iconoAlternativo! : widget.icon,
          color: widget.colorIcono ?? Colors.white,
          size: widget.tamanoIcono,
        ),
      ),
    );
  }
}
