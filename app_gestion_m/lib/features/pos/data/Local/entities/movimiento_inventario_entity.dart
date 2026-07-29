import 'package:isar/isar.dart';

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