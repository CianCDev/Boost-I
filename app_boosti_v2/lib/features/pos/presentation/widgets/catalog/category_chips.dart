import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_provider.dart';
import 'category_button.dart';
import '../../utils/responsive_helper.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      height: isTablet ? 60 : 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = state.categorias[index];
          return CategoryButton(
            categoria: cat,
            esSeleccionada: state.categoriaSeleccionada == cat,
            onTap: () => ref.read(catalogProvider.notifier).setCategoria(cat),
          );
        },
      ),
    );
  }
}