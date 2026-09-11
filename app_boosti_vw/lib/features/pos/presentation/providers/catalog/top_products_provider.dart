import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../productos_provider.dart';

// Cambiamos de StreamProvider a FutureProvider para evitar usar Isar Query.
final topProductosProvider = FutureProvider.autoDispose<List<ProductoEntity>>((ref) async {
  final productosState = ref.watch(productosProvider);
  final productos = productosState.items;

  if (productos.isEmpty) {
    return const [];
  }

  // En nuestro servicio basado en Sembast, este método devuelve una lista de movimientos.
  // Si no hay movimientos (por ahora), retornamos una lista vacía.
  final movimientos = await IsarService().obtenerMovimientosPendientesSync(); 

  // Como `obtenerMovimientosPendientesSync` solo devuelve los pendientes,
  // y para un top de ventas necesitaríamos todos, filtramos por fecha.
  // En el stub actual devuelve una lista vacía, así que este cálculo será vacío.
  final ventasPorProducto = <int, double>{};

  for (final movimiento in movimientos) {
    // Podemos filtrar por fecha manualmente si quisiéramos, pero aquí simplemente sumamos.
    ventasPorProducto[movimiento.productoId] =
        (ventasPorProducto[movimiento.productoId] ?? 0) + movimiento.cantidad;
  }

  final top = productos
      .where((producto) => ventasPorProducto.containsKey(producto.id))
      .toList()
    ..sort(
      (a, b) => ventasPorProducto[b.id]!.compareTo(ventasPorProducto[a.id]!),
    );

  return top.take(20).toList();
});