import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/business_mode_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/responsive_helper.dart';
import 'category_button.dart';
import 'view_mode_toggle.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    // El filtro Todos / Productos / Platos solo tiene sentido en
    // restaurante: ahí conviven ingredientes y platos con receta.
    final esRestaurante =
        ref.watch(businessModeProvider) == BusinessMode.restaurante;
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriasNormales = state.categorias
        .where((categoria) => categoria != 'Stock Bajo')
        .toList();
    final tieneStockBajo = state.categorias.contains('Stock Bajo');

    // Al salir de restaurante el control desaparece, así que un filtro
    // 'platos' heredado dejaría el catálogo vacío sin forma de volver.
    if (!esRestaurante && state.filtroTipo != 'todos') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(catalogProvider.notifier).setFiltroTipo('todos');
      });
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (esRestaurante) ...[
                  Flexible(
                    // Alto fijo: en móvil el SegmentedButton se estiraba
                    // verticalmente. El scroll horizontal evita que los 3
                    // segmentos desborden en pantallas angostas.
                    child: SizedBox(
                      height: 40,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SegmentedButton<String>(
                            showSelectedIcon: false,
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 12,
                                  vertical: 8,
                                ),
                              ),
                              side: const WidgetStatePropertyAll(
                                BorderSide.none,
                              ),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Theme.of(context).colorScheme.primary;
                                }
                                return Colors.transparent;
                              }),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return isDark ? Colors.white70 : Colors.black54;
                              }),
                            ),
                            segments: const [
                              ButtonSegment(
                                value: 'todos',
                                label: Text('Todos'),
                              ),
                              ButtonSegment(
                                value: 'productos',
                                label: Text('Productos'),
                              ),
                              ButtonSegment(
                                value: 'platos',
                                label: Text('Platos'),
                              ),
                            ],
                            selected: {state.filtroTipo},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(catalogProvider.notifier)
                                  .setFiltroTipo(selection.first);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (isMobile || isTablet) const ViewModeSelector(),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categoriasNormales.length + (tieneStockBajo ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (tieneStockBajo && index == categoriasNormales.length) {
                  final isSelected =
                      state.categoriaSeleccionada == 'Stock Bajo';
                  return ActionChip(
                    avatar: const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Colors.orange,
                    ),
                    label: const Text('Stock Bajo'),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: isSelected
                        ? Colors.orange.shade800
                        : Colors.orange.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: Colors.orange.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () => ref
                        .read(catalogProvider.notifier)
                        .setCategoria('Stock Bajo'),
                  );
                }

                final categoria = categoriasNormales[index];
                return CategoryButton(
                  key: ValueKey(categoria),
                  categoria: categoria,
                  esSeleccionada: state.categoriaSeleccionada == categoria,
                  onTap: () => ref
                      .read(catalogProvider.notifier)
                      .setCategoria(categoria),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
