import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../../utils/responsive_helper.dart';

class InventoryCategoryChips extends ConsumerWidget {
  const InventoryCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryProvider);
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
          return InventoryCategoryButton(
            categoria: cat,
            esSeleccionada: state.categoriaSeleccionada == cat,
            onTap: () => ref.read(inventoryProvider.notifier).setCategoria(cat),
          );
        },
      ),
    );
  }
}

// Widget interno con el mismo estilo que CategoryButton del catálogo
class InventoryCategoryButton extends StatefulWidget {
  final String categoria;
  final bool esSeleccionada;
  final VoidCallback onTap;

  const InventoryCategoryButton({
    super.key,
    required this.categoria,
    required this.esSeleccionada,
    required this.onTap,
  });

  @override
  State<InventoryCategoryButton> createState() => _InventoryCategoryButtonState();
}

class _InventoryCategoryButtonState extends State<InventoryCategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool esStockBajo = widget.categoria == 'Stock Bajo';
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (widget.esSeleccionada) {
      backgroundColor = esStockBajo ? colorScheme.error : colorScheme.primary;
      borderColor = backgroundColor;
      textColor = colorScheme.onPrimary;
    } else {
      backgroundColor = _isHovered ? colorScheme.surfaceContainerHighest : Colors.transparent;
      borderColor = _isHovered ? colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent;
      textColor = colorScheme.onSurfaceVariant;
    }

    final double fontSize = isTablet ? 16.0 : 13.0;
    final padding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 6);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.esSeleccionada
                  ? Colors.transparent
                  : borderColor,
              width: 1.5,
            ),
            boxShadow: widget.esSeleccionada
                ? [
                    BoxShadow(
                      color: (esStockBajo ? colorScheme.error : colorScheme.primary)
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : (_isHovered
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esStockBajo) ...[
                Icon(Icons.warning_amber_rounded,
                    size: 16,
                    color: widget.esSeleccionada ? colorScheme.onPrimary : colorScheme.error),
                const SizedBox(width: 4),
              ] else if (widget.esSeleccionada) ...[
                Icon(Icons.check_circle, size: 16, color: colorScheme.onPrimary),
                const SizedBox(width: 4),
              ],
              Text(
                widget.categoria,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: widget.esSeleccionada ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}