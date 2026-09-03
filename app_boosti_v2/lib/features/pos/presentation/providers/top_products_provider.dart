import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/producto_entity.dart';
import 'productos_provider.dart';

final topProductosProvider = Provider<List<ProductoEntity>>((ref) {
  final productos = ref
      .watch(productosProvider)
      .items
      .where((producto) => producto.ventasAcumuladas > 0)
      .toList()
    ..sort((a, b) => b.ventasAcumuladas.compareTo(a.ventasAcumuladas));

  return productos.take(20).toList();
});
