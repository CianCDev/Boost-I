// lib/features/pos/data/Local/entities/movimiento_inventario_entity.dart

class MovimientoInventarioEntity {
  int id = 0; // 0 = nuevo

  int productoId = 0;
  String nombreProducto = '';
  String tipoMovimiento = '';
  double cantidad = 0.0;
  double stockResultante = 0.0;
  DateTime fecha = DateTime.now();
  int usuarioId = 0;
  String syncStatus = 'pending';

  MovimientoInventarioEntity();

  // ✅ Para Sembast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'tipoMovimiento': tipoMovimiento,
      'cantidad': cantidad,
      'stockResultante': stockResultante,
      'fecha': fecha.toIso8601String(),
      'usuarioId': usuarioId,
      'syncStatus': syncStatus,
    };
  }

  // ✅ Desde Sembast
  factory MovimientoInventarioEntity.fromMap(Map<String, dynamic> map) {
    return MovimientoInventarioEntity()
      ..id = (map['id'] as int?) ?? 0
      ..productoId = (map['productoId'] as int?) ?? 0
      ..nombreProducto = (map['nombreProducto'] as String?) ?? ''
      ..tipoMovimiento = (map['tipoMovimiento'] as String?) ?? ''
      ..cantidad = (map['cantidad'] as num?)?.toDouble() ?? 0.0
      ..stockResultante = (map['stockResultante'] as num?)?.toDouble() ?? 0.0
      ..fecha = DateTime.tryParse(map['fecha'] as String? ?? '') ?? DateTime.now()
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..syncStatus = (map['syncStatus'] as String?) ?? 'pending';
  }
}