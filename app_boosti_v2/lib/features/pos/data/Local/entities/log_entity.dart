import 'package:isar/isar.dart';

part 'log_entity.g.dart';

@Collection()
class LogEntity {
  Id id = Isar.autoIncrement;

  String usuarioNombre = '';
  String usuarioRol = '';
  String accion = '';
  DateTime fecha = DateTime.now();       // Ej: 'CAMBIO_PIN', 'ELIMINAR_PRODUCTO'
  String? detalles;             // Ej: 'Producto eliminado: Manzana Roja'        // Cuándo ocurrió
  bool sincronizado = false;    // Para sincronización futura con la nube
}