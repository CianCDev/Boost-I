import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/categorias_provider.dart';
import '../../utils/responsive_helper.dart';
import '../catalog/category_button.dart';

/// Valor centinela del filtro "Stock Bajo".
///
/// NO es una categoría de `categorias`: es un filtro transversal por
/// `p.stock <= p.stockMinimo`. Comparar contra una categoría real con
/// este mismo nombre haría que el filtro la tapara.
const String _kStockBajo = 'Stock Bajo';

/// Widget que muestra los chips de categorías para el inventario.
/// Ahora usa "Todas" como valor especial en lugar de null.
class InventoryCategoryChips extends ConsumerWidget {
  const InventoryCategoryChips({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final categoriaSeleccionadaNombre =
        ref.watch(inventoryProvider.select((s) => s.categoriaSeleccionadaNombre));
    final isTablet = ResponsiveHelper.isTablet(context);

    return categoriasAsync.when(
      data: (categorias) {
        // Construimos la lista: "Todas" + nombres de categorías activas +
        // "Stock Bajo".
        //
        // ⚠️ 'Stock Bajo' NO es una categoría: es un filtro por
        // `p.stock <= p.stockMinimo` que `InventoryState.soloStockBajo`
        // ya implementa (`inventory_provider.dart:130-131`) y que
        // `setSoloStockBajo` ya expone (`:158`). Faltaba el interruptor.
        // `CatalogState` lo tenía desde el principio
        // (`catalog_provider.dart:113`), por eso el catálogo sí lo
        // muestra y este no.
        //
        // Va AL FINAL, nunca antes: una categoría real podría llamarse
        // "Stock Bajo" y el filtro la taparía.
        final items = <String>[
          'Todas',
          ...categorias.map((cat) => cat.nombre),
          _kStockBajo,
        ];

        return Container(
          height: isTablet ? 60 : 48,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final nombre = items[index];
              final esStockBajo = nombre == _kStockBajo;
              final esSeleccionada = esStockBajo
                  ? ref.watch(inventoryProvider.select((s) => s.soloStockBajo))
                  : nombre == categoriaSeleccionadaNombre;

              return CategoryButton(
                key: ValueKey(nombre),
                categoria: nombre,
                esSeleccionada: esSeleccionada,
                onTap: () {
                  final notifier = ref.read(inventoryProvider.notifier);
                  if (esStockBajo) {
                    // Es un filtro transversal: se apaga solo, sin
                    // tocar la categoría seleccionada.
                    final activo = ref.read(
                      inventoryProvider.select((s) => s.soloStockBajo),
                    );
                    notifier.setSoloStockBajo(!activo);
                  } else {
                    // Cambiar de categoría implica apagar el filtro: si
                    // no, "Bebidas" + stock bajo se leería como AND y el
                    // usuario vería una lista recortada sin saber por qué.
                    notifier.setSoloStockBajo(false);
                    notifier.setCategoria(nombre);
                  }
                },
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: isTablet ? 60 : 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(
        height: isTablet ? 60 : 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: Text('Error al cargar categorías')),
      ),
    );
  }
}