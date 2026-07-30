import 'package:isar/isar.dart';

<<<<<<< HEAD
// Esta línea marcará error hasta que corras el comando de generación de código (build_runner)
part 'movimiento_inventario_entity.g.dart';

@collection
class MovimientoInventarioEntity {
  Id id = Isar.autoIncrement; // ID autogenerado por Isar

  String? productoId; // Aquí guardaremos el código de barras o ID del producto
  String? nombreProducto;
  
  /// Tipos comunes: 'ENTRADA_INICIAL', 'AJUSTE_MANUAL', 'VENTA', 'DEVOLUCION'
  String? tipoMovimiento; 
  
  /// Cantidad que se sumó (positivo) o se restó (negativo)
  double cantidad = 0.0;
  
  /// Cuánto quedó el stock después de este movimiento
  double stockResultante = 0.0;
  
  DateTime fecha = DateTime.now();
  
  String? usuarioId; // Para saber qué cajero/admin hizo el movimiento

  /// Este índice es vital para buscar rápido cuáles faltan por subir a Supabase
  @Index()
  bool sincronizado = false; 
}
=======
part 'movimiento_inventario_entity.g.dart';

@Collection()
class MovimientoInventarioEntity {
  Id id = Isar.autoIncrement;

  // Referencia al producto (puede ser codigoBarras o id según uso en la app)
  String productoId = '';

  late String nombreProducto;

  /// Tipo de movimiento: 'ENTRADA_INICIAL', 'AJUSTE_MANUAL', 'SALIDA', etc.
  late String tipoMovimiento;

  late double cantidad;

  /// Stock resultante después del movimiento
  late double stockResultante;

  late DateTime fecha;

  /// Identificador del usuario que realizó el movimiento (nombre o id)
  String usuarioId = '';

  /// Si ya fue sincronizado hacia el backend remoto
  bool sincronizado = false;
}
>>>>>>> origin/feature/Diegodevelop
