import 'package:flutter/material.dart';

class GastosSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategorySelected;
  final bool isMobile;
  final bool isTablet;

  const GastosSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de búsqueda
          SizedBox(
            height: isTablet ? 58 : 44,
            child: TextField(
              onChanged: onSearchChanged,
              enableInteractiveSelection: false,
              enableIMEPersonalizedLearning: false,
              autofillHints: const <String>[],
              enableSuggestions: false,
              autocorrect: false,
              autofocus: false,
              style: TextStyle(
                fontSize: isTablet ? 18 : 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por descripción...',
                hintStyle: TextStyle(
                  fontSize: isTablet ? 16 : 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: isTablet ? 30 : 22,
                  color: colorScheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Chips de categorías (con hover y escala)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((categoria) {
                final bool esSeleccionado = selectedCategory == categoria;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _CategoryChip(
                    label: categoria,
                    selected: esSeleccionado,
                    onTap: () => onCategorySelected(categoria),
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget separado con hover y animación
class _CategoryChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isTablet;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double fontSize = widget.isTablet ? 17 : 13;
    final double verticalPadding = widget.isTablet ? 12 : 8;
    final double horizontalPadding = widget.isTablet ? 22 : 14;
    final double borderRadius = widget.isTablet ? 26 : 20;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: isHovering
              ? Matrix4.diagonal3Values(1.04, 1.04, 1.0)
              : Matrix4.identity(),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: widget.selected ? const Color(0xFFEF4444) : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFFEF4444)
                  : (isHovering
                      ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                      : colorScheme.outline.withValues(alpha: 0.25)),
              width: widget.selected ? 2.0 : 1.5,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : (isHovering
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
              color: widget.selected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}