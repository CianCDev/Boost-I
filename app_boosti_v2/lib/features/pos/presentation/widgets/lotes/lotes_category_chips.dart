// lib/features/pos/presentation/widgets/lotes/lotes_category_chips.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/categorias_provider.dart';
import '../../providers/lotes_provider.dart';
import '../catalog/category_button.dart';
import '../../utils/responsive_helper.dart';

class LotesCategoryChips extends ConsumerWidget {
  const LotesCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final categoriaSeleccionada = ref.watch(lotesProvider.select((s) => s.categoriaFiltro));
    final isTablet = ResponsiveHelper.isTablet(context);

    return categoriasAsync.when(
      data: (categorias) {
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
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final nombre = items[index];
              final esSeleccionada = nombre == categoriaSeleccionada;
              return CategoryButton(
                key: ValueKey(nombre),
                categoria: nombre,
                esSeleccionada: esSeleccionada,
                onTap: () {
                  ref.read(lotesProvider.notifier).setCategoriaFiltro(nombre);
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