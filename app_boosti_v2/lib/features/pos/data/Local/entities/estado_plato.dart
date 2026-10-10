// lib/features/pos/data/Local/entities/estado_plato.dart

/// Estado de una línea de comanda dentro del flujo de cocina (KDS).
///
/// ⚠️ Se guarda dentro de `CartSessionItem`, que es `@embedded`. Convive con
/// `ComandaEstado` (estado de la COMANDA) y con `MesaEstado` (estado de la
/// MESA). Son tres ejes distintos:
///
///   · `MesaEstado`    → la mesa (libre / ocupada / reservada / ...)
///   · `ComandaEstado` → la comanda (abierta / enviada / cerrada / ...)
///   · `EstadoPlato`   → CADA plato por separado (este enum)
///
/// R.3.2 (KDS) es el primer consumidor real de `enPreparacion` y
/// `entregada`, que quedaron reservados desde R.2.
enum EstadoPlato {
  /// R.3 · Aún NO enviado a cocina.
  ///
  /// El mesero no ha pulsado "Enviar a cocina", así que NO aparece en el
  /// KDS. El contador de "pendientes de enviar" cuenta este estado.
  pendiente,

  /// Enviado a cocina, esperando que el cocinero lo tome.
  ///
  /// YA es visible en el KDS. Es el estado inicial de todo lo que sale de
  /// `ComandasNotifier.enviarACocina()`.
  enCola,

  /// El cocinero lo está haciendo.
  enPreparacion,

  /// Terminado, esperando que alguien lo saque de la barra.
  listo,

  /// Salió de cocina hacia la mesa. Lo marca el COCINERO (P7), no el mesero.
  entregado,

  /// El mesero lo canceló antes de empezar la preparación.
  cancelado,
}
