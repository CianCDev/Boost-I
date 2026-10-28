// lib/features/pos/data/Local/entities/descuento_lote_plan.dart
//
// G.3 · Plan de descuento sobre lotes, con descuento ATÓMICO.
//
// El problema que resuelve: hasta 2026-10-28 el descuento de stock se
// hacía con N `writeTxn` independientes (uno por lote, uno por movimiento).
// Si el flujo fallaba a mitad — venta que no se inserta, movimiento que
// revienta — los lotes ya descontados quedaban así: stock consumido sin
// venta, o al revés. Es la misma pérdida silenciosa documentada en
// `docs/TODO.md` (`procesarVenta` no tiene transacción).
//
// El arreglo es de 2 pasos:
//
//   1. `planificarDescuentoLotes` (solo LECTURA) calcula el reparto FEFO y
//      devuelve el plan con el faltante, si lo hubo. No escribe nada.
//   2. `IsarService.aplicarDescuentosLotes` o `registrarVentaConDescuento`
//      ejecutan el plan COMPLETO en una sola transacción. Si un lote ya no
//      tiene lo que el plan prometió (otra venta lo tomó en el ínterin),
//      la excepción revienta la transacción y NADA se escribe.
//
// Es una clase de valor plano: NO es entidad Isar (`part 'xxx.g.dart'`).
// Vive solo mientras el flujo que la construye corre.

/// Un paso del plan: al lote [loteId] (del producto [productoId]) se le
/// descuentan [cantidad] unidades.
class DescuentoLotePlan {
  final int loteId;
  final int productoId;
  final double cantidad;

  const DescuentoLotePlan({
    required this.loteId,
    required this.productoId,
    required this.cantidad,
  });

  @override
  String toString() =>
      'DescuentoLotePlan(lote: $loteId, producto: $productoId, cantidad: $cantidad)';
}

/// Resultado de planificar el descuento de UN producto de solo lectura.
///
/// [plan] puede quedarse corto si no alcanzó el stock: el faltante queda
/// en [faltante], que es lo que la venta usa para abortar y lo que el KDS
/// usa para avisar (Q3: en el KDS un faltante no bloquea la entrega, se
/// avisa).
class PlanificacionLote {
  final int productoId;

  /// Cantidad que NO se pudo cubrir con los lotes activos.
  ///
  /// El tolerado es distinto en cada flujo: retail aborta si > 0, KDS
  /// descuenta lo que había y lo anota.
  final double faltante;

  final List<DescuentoLotePlan> plan;

  const PlanificacionLote({
    required this.productoId,
    required this.faltante,
    required this.plan,
  });

  bool get completo => faltante <= 0;
}

/// Revienta una transacción porque un lote ya no tiene lo que el plan
/// prometió.
///
/// El mensaje manda el motivo entero: el snapshot del plan se tomó contra
/// una lectura, y otra transacción (otra caja del mismo dispositivo, o el
/// ajuste de un editor) movió el lote entretanto. Abortar en vez de
/// aplicar lo que quedaba es lo que hace el descuento verificable.
class StockInsuficienteException implements Exception {
  final int loteId;
  final int productoId;
  final double disponible;
  final double requerido;

  const StockInsuficienteException({
    required this.loteId,
    required this.productoId,
    required this.disponible,
    required this.requerido,
  });

  @override
  String toString() =>
      'StockInsuficienteException: el lote $loteId (producto $productoId) '
      'tiene $disponible y se necesitaba $requerido.';
}
