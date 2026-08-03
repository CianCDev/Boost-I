import 'package:isar/isar.dart';

part 'log_entity.g.dart';

@Collection()
class LogEntity {
  Id id = Isar.autoIncrement;

  late String usuarioNombre;    // Quién ejecutó la acción
  late String usuarioRol;       // Ej: 'admin', 'cajero'
  late String accion;           // Ej: 'CAMBIO_PIN', 'ELIMINAR_PRODUCTO'
  String? detalles;             // Ej: 'Producto eliminado: Manzana Roja'
  late DateTime fecha;          // Cuándo ocurrió
  bool sincronizado = false;    // Para sincronización futura con la nube
}