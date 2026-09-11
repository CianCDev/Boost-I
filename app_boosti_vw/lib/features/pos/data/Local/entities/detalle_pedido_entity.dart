// lib/features/pos/data/Local/entities/detalle_pedido_entity.dart

class DetallePedidoEntity {
  int id = 0; // 0 = nuevo
  int? supabaseId; // UUID de Supabase (opcional)
  int pedidoId = 0;
  int productoId = 0;
  String nombreProducto = '';
  double cantidad = 0.0;
  double precioUnidad = 0.0;
  double subtotal = 0.0;

  DetallePedidoEntity();

  // ✅ Convertir a Mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'pedidoId': pedidoId,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'precioUnidad': precioUnidad,
      'subtotal': subtotal,
    };
  }

  // ✅ Crear desde Mapa
  factory DetallePedidoEntity.fromMap(Map<String, dynamic> map) {
    return DetallePedidoEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as int?
      ..pedidoId = (map['pedidoId'] as int?) ?? 0
      ..productoId = (map['productoId'] as int?) ?? 0
      ..nombreProducto = (map['nombreProducto'] as String?) ?? ''
      ..cantidad = (map['cantidad'] as num?)?.toDouble() ?? 0.0
      ..precioUnidad = (map['precioUnidad'] as num?)?.toDouble() ?? 0.0
      ..subtotal = (map['subtotal'] as num?)?.toDouble() ?? 0.0;
  }
}