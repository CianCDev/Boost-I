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

  // Soft-delete & sync metadata
  /// Indica si el producto fue marcado como eliminado (soft-delete). Los productos eliminados
  /// no se muestran en el inventario local pero se mantienen en la DB para poder sincronizarlos
  /// y ofrecer la opción de deshacer.
  bool eliminado = false;

  /// Fecha (UTC) en la que se marcó como eliminado, si aplica
  DateTime? eliminadoEn;

  /// Indica si los cambios locales ya fueron sincronizados con Supabase
  bool sincronizado = false;
}
