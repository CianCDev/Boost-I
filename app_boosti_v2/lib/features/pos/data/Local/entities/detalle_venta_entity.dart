import 'package:isar/isar.dart';

part 'detalle_venta_entity.g.dart';

@collection
class DetalleVentaEntity {
  Id id = Isar.autoIncrement;

  int? productoId;
  String nombreProducto = '';
  double precioUnidad = 0.0;
  double? precioOriginal;
  bool? esDescuentoEspecial = false;
  double cantidad = 0.0;
  double subtotal = 0.0;

  String? ventaIdFk;
  String? syncStatus = 'pending';

  // ──────────────── Ventas al Mayor (NUEVO) ────────────────

  /// Precio detal original antes de aplicar cualquier ajuste.
  double? precioDetalOriginal;

  /// Precio mayorista aplicado (si corresponde).
  double? precioMayorAplicado;

  /// 'detal' | 'medio_mayor' | 'mayor'
  String? tipoPrecio;

  /// % de descuento aplicado a esta línea específica.
  double descuentoPorcentajeLinea = 0.0;

  /// 'unidad' | 'bulto' | 'caja'
  String unidadEmpaque = 'unidad';

  /// Cantidad de unidades por empaque al momento de la venta.
  int unidadesPorEmpaque = 1;

  /// Nombre de quien autorizó el descuento de esta línea (si aplica).
  String? autorizadoPorLinea;

  /// Costo del lote FEFO usado (para reportes de margen).
  double? costoUnitarioSnapshot;

  /// ID local del lote principal (informativo).
  int? loteIdIsar;

  /// true si la línea se vendió por peso (kg).
  ///
  /// Sin este flag, el ticket imprimía la cantidad con 0 decimales y una
  /// venta de 1.5 kg aparecía como "2x" (ticket_generator.dart y
  /// ticket_service.dart hacen `toStringAsFixed(esPesado ? 3 : 0)`).
  ///
  /// ⚠️ MIGRACIÓN: las ventas anteriores al 2026-10-03 quedan en `false`
  /// aunque sí se vendieran por peso. El dato se perdía al construir el
  /// detalle desde el carrito, así que no es reconstruible a posteriori.
  /// Solo afecta a la presentación histórica del ticket, no a los totales:
  /// `cantidad` y `subtotal` siempre se guardaron bien.
  bool esPesado = false;
}