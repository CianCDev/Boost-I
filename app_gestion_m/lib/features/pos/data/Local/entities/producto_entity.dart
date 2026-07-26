import 'package:isar/isar.dart';

part 'producto_entity.g.dart';

@collection
class ProductoEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String codigoBarras;

  late String nombre;

  late double precioUnidad;

  late double stock;

  late bool esPesado;

  late String categoria;

  // Nuevos campos para Proveedor y Control de Alertas
  String proveedorNombre = '';
  String proveedorTelefono = '';
  double stockMinimo = 5.0; // Límite por defecto para activar alerta de stock bajo
}