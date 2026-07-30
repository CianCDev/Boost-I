import 'package:isar/isar.dart';

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