// lib/features/pos/data/Local/entities/detalle_venta_entity.dart

class DetalleVentaEntity {
  int id = 0; // 0 = nuevo

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

  DetalleVentaEntity();

  // ✅ Convertir a Mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'precioUnidad': precioUnidad,
      'precioOriginal': precioOriginal,
      'esDescuentoEspecial': esDescuentoEspecial,
      'cantidad': cantidad,
      'subtotal': subtotal,
      'ventaIdFk': ventaIdFk,
      'syncStatus': syncStatus,
    };
  }

  // ✅ Crear desde Mapa
  factory DetalleVentaEntity.fromMap(Map<String, dynamic> map) {
    return DetalleVentaEntity()
      ..id = (map['id'] as int?) ?? 0
      ..productoId = map['productoId'] as int?
      ..nombreProducto = (map['nombreProducto'] as String?) ?? ''
      ..precioUnidad = (map['precioUnidad'] as num?)?.toDouble() ?? 0.0
      ..precioOriginal = (map['precioOriginal'] as num?)?.toDouble()
      ..esDescuentoEspecial = map['esDescuentoEspecial'] as bool? ?? false
      ..cantidad = (map['cantidad'] as num?)?.toDouble() ?? 0.0
      ..subtotal = (map['subtotal'] as num?)?.toDouble() ?? 0.0
      ..ventaIdFk = map['ventaIdFk'] as String?
      ..syncStatus = map['syncStatus'] as String? ?? 'pending';
  }
}