import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/categorias_provider.dart';
import '../../utils/responsive_helper.dart';
import '../catalog/category_button.dart';

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
        // Construimos la lista: "Todas" + nombres de categorías activas
        final items = <String>[
          'Todas',
          ...categorias.map((cat) => cat.nombre),
        ];

        return Container(
          height: isTablet ? 60 : 48,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final nombre = items[index];
              final esSeleccionada = nombre == categoriaSeleccionadaNombre;

              return CategoryButton(
                key: ValueKey(nombre),
                categoria: nombre,
                esSeleccionada: esSeleccionada,
                onTap: () {
                  ref.read(inventoryProvider.notifier).setCategoria(nombre);
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
      error: (_, _) => Container(
        height: isTablet ? 60 : 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: Text('Error al cargar categorías')),
      ),
    );
  }
}