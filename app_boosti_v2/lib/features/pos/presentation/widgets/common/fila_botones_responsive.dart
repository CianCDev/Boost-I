// lib/features/pos/presentation/widgets/common/fila_botones_responsive.dart
import 'package:flutter/material.dart';

import '../../utils/responsive_helper.dart';

/// Fila de botones de acción que no se estira en pantallas anchas.
///
/// En desktop (>=[ResponsiveHelper.desktopBreakpoint], 1200 px) la fila se
/// limita a [maxWidthDesktop] y se centra. Es el arreglo para el efecto
/// "botón gigante": en un monitor de 1920 px un `TextButton` con
/// `width: double.infinity` mide 1500 px de lado a lado, con el texto
/// perdido en el centro.
///
/// En móvil y tablet la fila se comporta EXACTAMENTE como hoy: ocupa todo el
/// ancho disponible. Ahí `maxWidth` es [double.infinity], que equivale a no
/// poner límite.
///
/// ## Cuándo usar [estirar]
///
/// ⚠️ Solo si los hijos hoy se reparten el 100 % del ancho (normalmente
/// porque van dentro de un `Expanded`, con su `flex`). Si los hijos ya se
/// ajustan a su contenido, déjalos con `estirar: false`: meterlos en un
/// `Expanded` los haría más anchos de lo que son hoy, que es justo lo
/// contrario de lo que se busca.
///
/// El nombre NO lleva "restaurante" a propósito: el patrón sirve para
/// cualquier pantalla con una fila de acciones, así que quien lo use en otro
/// módulo no tiene que preguntarse si está en el sitio correcto.
class FilaBotonesResponsive extends StatelessWidget {
  final List<Widget> children;

  /// Ancho máximo de la fila en desktop.
  final double maxWidthDesktop;

  /// Separación entre botones.
  final double spacing;

  /// ¿En DESKTOP los hijos se reparten el ancho disponible?
  ///
  /// `true` (por defecto) los envuelve en `Expanded`. `false` los deja a su
  /// tamaño natural y centra la fila, que es lo que quiere un botón suelto
  /// como "Cancelar comanda".
  ///
  /// ⚠️ Solo si los hijos hoy se reparten el 100 % del ancho (normalmente
  /// porque van dentro de un `Expanded`, con su `flex`). Si los hijos ya se
  /// ajustan a su contenido, déjalos con `estirar: false`: meterlos en un
  /// `Expanded` los haría más anchos de lo que son hoy.
  ///
  /// ⚠️ **En móvil y tablet esta opción se ignora**: la fila siempre ocupa
  /// todo el ancho, porque es como se ve hoy y cambiarlo sería una
  /// regresión en móvil. Es decir: `estirar` decide solo lo que pasa en
  /// pantallas anchas.
  final bool estirar;

  /// Reparto en `flex` por botón, para preservar proporciones.
  ///
  /// `null` = todos a 1 (reparto en partes iguales). Una lista más corta que
  /// [children] usa `1` a partir del punto en que se acaba.
  ///
  /// Existe por un caso concreto: `[Enviar][Cobrar]` se reparte 2:3 porque
  /// cobrar es la acción principal. Sin esto, [estirar] lo aplanaría a 1:1 y
  /// dos botones con pesos distintos quedarían con el mismo ancho.
  final List<int>? flexes;

  /// Ancho mínimo por botón, solo cuando [estirar] es `true`.
  ///
  /// Sin esto, una fila de 3 botones en 420 px reparte 140 px cada uno y un
  /// `Iniciar` que mide 100 px se estira de más. Con el mínimo, la fila
  /// crece hasta el ancho que los botones necesitan de verdad (siempre
  /// dentro del máximo), en vez de repartir la fila a lo tonto.
  ///
  /// ⚠️ Si se pasan valores que chocan (mínimo × nº de botones + huecos >
  /// [maxWidthDesktop]), gana [maxWidthDesktop]: es un tope duro, y un
  /// mínimo mayor rompería el layout en pantallas medianas.
  final double anchoMinBotonDesktop;

  const FilaBotonesResponsive({
    super.key,
    required this.children,
    this.maxWidthDesktop = 420,
    this.spacing = 12,
    this.estirar = true,
    this.anchoMinBotonDesktop = 120,
    this.flexes,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final desktop = ResponsiveHelper.isDesktop(context);
    final anchoMax = desktop ? maxWidthDesktop : double.infinity;

    // ⚠️ En móvil SIEMPRE se reparte, aunque `estirar` valga false: es como
    // está hoy la fila en móvil y no se toca ese comportamiento. `estirar`
    // solo decide qué pasa en pantallas anchas.
    final repartir = estirar || !desktop;

    final separaciones = spacing * (children.length - 1);
    final anchoQueNecesitan =
        (anchoMinBotonDesktop * children.length) + separaciones;
    // Solo se ensancha si de verdad hace falta Y hay hueco dentro del tope.
    final ensanchar = desktop &&
        repartir &&
        anchoQueNecesitan > anchoMax &&
        anchoQueNecesitan <= maxWidthDesktop;

    final fila = Row(
      mainAxisAlignment:
          repartir ? MainAxisAlignment.start : MainAxisAlignment.center,
      mainAxisSize: repartir ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          if (!repartir)
            children[i]
          else
            Expanded(
              flex: (flexes != null && i < flexes!.length) ? flexes![i] : 1,
              child: ensanchar
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: anchoMinBotonDesktop,
                      ),
                      child: children[i],
                    )
                  : children[i],
            ),
        ],
      ],
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMax),
        child: fila,
      ),
    );
  }
}
