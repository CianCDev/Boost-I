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
}