// lib/features/pos/presentation/providers/top_products_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../productos_provider.dart';

final topProductosProvider = StreamProvider.autoDispose<List<ProductoEntity>>((ref) async* {
  final productosState = ref.watch(productosProvider);
  final productos = productosState.items;

  if (productos.isEmpty) {
    yield const [];
    return;
  }

  final desde = DateTime.now().subtract(const Duration(days: 30));
  final query = await IsarService().queryMovimientosVentaRecientes(desde);

  await for (final _ in query.watchLazy(fireImmediately: true)) {
    final movimientos = await query.findAll();
    final ventasPorProducto = <int, double>{};

    for (final movimiento in movimientos) {
      ventasPorProducto[movimiento.productoId] =
          (ventasPorProducto[movimiento.productoId] ?? 0) +
              movimiento.cantidad;
    }

    final top = productos
        .where((producto) => ventasPorProducto.containsKey(producto.id))
        .toList()
      ..sort(
        (a, b) => ventasPorProducto[b.id]!.compareTo(ventasPorProducto[a.id]!),
      );

    yield top.take(20).toList();
  }
});