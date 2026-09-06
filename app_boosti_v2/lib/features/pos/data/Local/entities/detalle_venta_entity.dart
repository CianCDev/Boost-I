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

  // Llave foránea para relacionarlo con la venta localmente y en Supabase
  String? ventaIdFk; 
  
  String? syncStatus = 'pending';
}