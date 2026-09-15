// lib/features/pos/presentation/providers/catalog/recent_products_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../data/Local/entities/detalle_venta_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/venta_entity.dart';
// ignore: unused_import
import 'catalog_actions.dart'; 

/// Se incrementa cuando se quiere forzar la recarga de "productos recientes".
/// Se incrementa tras cada venta exitosa.
final recentProductsRefreshProvider = StateProvider<int>((ref) => 0);

/// Devuelve los últimos 9 productos únicos vendidos, ordenados
/// del más reciente al más antiguo.
///
/// Se usa para los hotkeys 1-9 del catálogo.
final recentProductsProvider =
    FutureProvider<List<ProductoEntity>>((ref) async {
  // Depende del contador de refresh + del refresh del catálogo
  ref.watch(recentProductsRefreshProvider);

  try {
    final isar = IsarService();
    final db = await isar.db;

    // Traer las últimas ventas (suficientes para tener 9 productos únicos)
    final ventas = await db.ventaEntitys
        .where()
        .sortByFechaDesc()
        .limit(40)
        .findAll();

    if (ventas.isEmpty) return [];

    final Set<int> vistos = {};
    final List<ProductoEntity> resultado = [];

    for (final venta in ventas) {
      if (resultado.length >= 9) break;

      final ventaUuid = venta.idSupabase;
      if (ventaUuid == null || ventaUuid.isEmpty) continue;

      final detalles = await db.detalleVentaEntitys
          .filter()
          .ventaIdFkEqualTo(ventaUuid)
          .findAll();

      for (final d in detalles) {
        if (resultado.length >= 9) break;

        final pid = d.productoId;
        if (pid == null) continue;
        if (vistos.contains(pid)) continue;
        vistos.add(pid);

        final producto = await db.productoEntitys.get(pid);
        if (producto != null && producto.activo) {
          resultado.add(producto);
        }
      }
    }

    return resultado;
  } catch (e) {
    return [];
  }
});