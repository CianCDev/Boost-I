import 'package:isar/isar.dart';

part 'producto_entity.g.dart';

@collection
class ProductoEntity {
  Id id = Isar.autoIncrement; // ✅ Mantén int

  @Index(unique: true, replace: true)
  late String codigoBarras;

  late String nombre;
  late double precioUnidad;
  late double stock;
  late bool esPesado;
  late String categoria;
  String proveedorNombre = '';
  String proveedorTelefono = '';
  double stockMinimo = 5.0;
  late String imagenUrl = ''; // Cambiado a String? para permitir null
  
}