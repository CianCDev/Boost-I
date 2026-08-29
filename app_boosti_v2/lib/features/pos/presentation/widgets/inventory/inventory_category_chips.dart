import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/categorias_provider.dart';
import '../../utils/responsive_helper.dart';
import '../catalog/category_button.dart';

class InventoryCategoryChips extends ConsumerWidget {
  const InventoryCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final categoriaSeleccionadaId = ref.watch(inventoryProvider.select((s) => s.categoriaSeleccionadaId));
    final isTablet = ResponsiveHelper.isTablet(context);

    return categoriasAsync.when(
      data: (categorias) {
        final items = <({int? id, String nombre})>[
          (id: null, nombre: 'Todas'),
          ...categorias.map((cat) => (id: cat.id, nombre: cat.nombre)),
        ];

        return Container(
          height: isTablet ? 60 : 48,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final esSeleccionada = item.id == categoriaSeleccionadaId;
              return CategoryButton(
                key: ValueKey(item.id ?? 'todas'),
                categoria: item.nombre,
                esSeleccionada: esSeleccionada,
                onTap: () {
                  ref.read(inventoryProvider.notifier).setCategoria(item.id);
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
      error: (_, __) => Container(
        height: isTablet ? 60 : 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: Text('Error al cargar categorías')),
      ),
    );
  }
}