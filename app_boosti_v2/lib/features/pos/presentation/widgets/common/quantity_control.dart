// lib/features/pos/presentation/widgets/common/quantity_control.dart
import 'package:flutter/material.dart';

/// Control `[-] cantidad [+]` de 36 px, pensado para tocar con el dedo.
///
/// Sin lógica de negocio: no sabe de stock, ni de mínimo de venta, ni de
/// redondeo. Solo formatea y avisa. El `[-]` se apaga cuando la cantidad
/// llega al mínimo, y ese mínimo lo fija el padre.
///
/// Los targets táctiles miden 36 px, por debajo de los 48 px que Material
/// recomienda. Es una decisión consciente: en el KDS cada fila ya ocupa
/// bastante alto y un control de 48 px × N platos descuadra la pantalla
/// en un teléfono. Quien necesite el target grande, usa `compacto: false`.
class QuantityControl extends StatelessWidget {
  final double cantidad;

  final VoidCallback? onIncrementar;
  final VoidCallback? onDecrementar;

  /// `true` → 3 decimales (productos por peso).
  final bool esPesado;

  /// Apaga ambos botones.
  final bool habilitado;

  /// `false` → 44 px, más cómodo pero más alto.
  final bool compacto;

  /// Por debajo de este valor el `[-]` se desactiva.
  final double minimo;

  const QuantityControl({
    super.key,
    required this.cantidad,
    this.onIncrementar,
    this.onDecrementar,
    this.esPesado = false,
    this.habilitado = true,
    this.compacto = true,
    this.minimo = 1,
  });

  bool get _puedeRestar => habilitado && cantidad > minimo;

  /// "1.250" si es pesado, "1" si no.
  String get _texto {
    if (esPesado) return cantidad.toStringAsFixed(3);
    final entero = cantidad.round();
    return '$entero';
  }

  @override
  Widget build(BuildContext context) {
    final size = compacto ? 36.0 : 44.0;
    final iconSize = compacto ? 18.0 : 22.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _boton(
          context,
          size: size,
          iconSize: iconSize,
          icon: Icons.remove_rounded,
          onTap: _puedeRestar ? onDecrementar : null,
          tooltip: 'Quitar',
        ),
        Container(
          constraints: BoxConstraints(minWidth: compacto ? 40 : 52),
          alignment: Alignment.center,
          child: Text(
            _texto,
            // ⚠️ Sin `fontFeatures: tabularFigures()`. `FontFeature` vive en
            // `dart:ui` y Flutter NO lo re-exporta por `material.dart`
            // (verificado: 0 apariciones en todo `packages/flutter/lib`).
            // Habría que añadir `import 'dart:ui';` a un widget, que es
            // fuentes de conflicto de nombres (`Image`, `Color`,
            // `TextStyle`...). No compensa alinear los digitos. El
            // `minWidth` ya reserva el hueco y el texto va centrado.
            style: TextStyle(
              fontSize: compacto ? 15 : 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _boton(
          context,
          size: size,
          iconSize: iconSize,
          icon: Icons.add_rounded,
          onTap: habilitado ? onIncrementar : null,
          tooltip: 'Añadir',
        ),
      ],
    );
  }

  Widget _boton(
    BuildContext context, {
    required double size,
    required double iconSize,
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    final activo = onTap != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: activo
            ? colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color: activo ? colorScheme.primary : theme.disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
