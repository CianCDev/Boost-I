// lib/features/pos/presentation/widgets/pedidos/multi_select_dialog.dart
// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/glass_search_bar.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<ProductoEntity> items;
  final String title;
  final String confirmText;
  final String cancelText;

  /// Categoría preseleccionada al abrir (opcional).
  final String? categoriaInicial;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.title,
    this.confirmText = 'Asignar',
    this.cancelText = 'Cancelar',
    this.categoriaInicial,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  final Set<int> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _categoriaSeleccionada;
  Timer? _debounce;

  static const _colorPrimary = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = widget.categoriaInicial;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // LISTAS DERIVADAS
  // ═══════════════════════════════════════════════════════════════

  /// Categorías únicas ordenadas alfabéticamente.
  List<String> get _categoriasDisponibles {
    final set = <String>{};
    for (final p in widget.items) {
      if (p.categoria.isNotEmpty) set.add(p.categoria);
    }
    return set.toList()..sort();
  }

  /// Items filtrados por categoría + búsqueda.
  /// Se calcula 1 vez por build (memoizado en el método build).
  List<ProductoEntity> _computeItemsFiltrados() {
    var result = widget.items;

    if (_categoriaSeleccionada != null) {
      result = result
          .where((p) => p.categoria == _categoriaSeleccionada)
          .toList();
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase().trim();
      result = result.where((p) {
        return p.nombre.toLowerCase().contains(q) ||
            p.codigoBarras.toLowerCase().contains(q) ||
            p.categoria.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  // ACCIONES
  // ═══════════════════════════════════════════════════════════════

  void _toggle(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _seleccionarVisibles(List<ProductoEntity> visibles) {
    setState(() {
      for (final p in visibles) {
        _selectedIds.add(p.id);
      }
    });
  }

  void _deseleccionarVisibles(List<ProductoEntity> visibles) {
    setState(() {
      for (final p in visibles) {
        _selectedIds.remove(p.id);
      }
    });
  }

  void _limpiarSeleccion() {
    setState(() => _selectedIds.clear());
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value);
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Cálculo 1 sola vez por build (evita re-filtrar 3-4 veces).
    final itemsFiltrados = _computeItemsFiltrados();
    final totalSeleccionados = _selectedIds.length;
    final visiblesSeleccionados = itemsFiltrados.isNotEmpty &&
        itemsFiltrados.every((p) => _selectedIds.contains(p.id));
    final hayFiltroActivo =
        _query.trim().isNotEmpty || _categoriaSeleccionada != null;

    return GlassDialog(
      maxWidth: 560,
      maxHeightFactor: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ HEADER ═══
            DialogHeader(
              icon: Icons.checklist_rounded,
              title: widget.title,
              subtitle: totalSeleccionados > 0
                  ? '$totalSeleccionados de ${widget.items.length} seleccionados'
                  : '${widget.items.length} disponibles',
              color: _colorPrimary,
            ),
            const SizedBox(height: 16),

            // ═══ BUSCADOR ═══
            GlassSearchBar(
              controller: _searchController,
              hint: 'Buscar por nombre o código...',
              onChanged: _onSearchChanged,
              accentColor: _colorPrimary,
              verticalPadding: 10,
            ),
            const SizedBox(height: 10),

            // ═══ FILTROS + ACCIONES RÁPIDAS ═══
            Row(
              children: [
                Expanded(child: _buildCategoriaDropdown(colorScheme, isDark)),
                const SizedBox(width: 8),
                _MiniIconButton(
                  icon: visiblesSeleccionados
                      ? Icons.deselect_rounded
                      : Icons.done_all_rounded,
                  tooltip: visiblesSeleccionados
                      ? 'Deseleccionar visibles'
                      : 'Seleccionar visibles',
                  enabled: itemsFiltrados.isNotEmpty,
                  onTap: () {
                    if (visiblesSeleccionados) {
                      _deseleccionarVisibles(itemsFiltrados);
                    } else {
                      _seleccionarVisibles(itemsFiltrados);
                    }
                  },
                  accentColor: _colorPrimary,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 6),
                _MiniIconButton(
                  icon: Icons.clear_all_rounded,
                  tooltip: 'Limpiar selección',
                  enabled: totalSeleccionados > 0,
                  onTap: _limpiarSeleccion,
                  accentColor: colorScheme.error,
                  colorScheme: colorScheme,
                ),
              ],
            ),

            // ═══ CONTADOR VISIBLE ═══
            if (totalSeleccionados > 0 || hayFiltroActivo) ...[
              const SizedBox(height: 10),
              _buildContadorLine(
                colorScheme,
                totalSeleccionados,
                itemsFiltrados.length,
                hayFiltroActivo,
              ),
            ],
            const SizedBox(height: 10),

            // ═══ LISTA ═══
            Flexible(
              child: itemsFiltrados.isEmpty
                  ? _buildEmptyState(colorScheme, hayFiltroActivo)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: itemsFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = itemsFiltrados[index];
                        return _ProductoTile(
                          producto: producto,
                          selected: _selectedIds.contains(producto.id),
                          onTap: () => _toggle(producto.id),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // ═══ BOTONES ═══
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, null),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.cancelText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: MouseRegion(
                    cursor: totalSeleccionados == 0
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: totalSeleccionados == 0
                            ? null
                            : () {
                                final seleccionados = widget.items
                                    .where(
                                        (p) => _selectedIds.contains(p.id))
                                    .toList();
                                Navigator.pop(context, seleccionados);
                              },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          '${widget.confirmText} ($totalSeleccionados)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGETS AUXILIARES
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCategoriaDropdown(ColorScheme colorScheme, bool isDark) {
    final categorias = _categoriasDisponibles;

    if (categorias.isEmpty) {
      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.category_outlined,
                size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Sin categorías',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<String?>(
        initialValue: _categoriaSeleccionada,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant, size: 20),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category_outlined,
              size: 18, color: _colorPrimary),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 38, minHeight: 0),
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _colorPrimary, width: 1.6),
          ),
        ),
        hint: Text(
          'Todas las categorías',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        style: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        dropdownColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              'Todas las categorías',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...categorias.map((cat) => DropdownMenuItem<String?>(
                value: cat,
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )),
        ],
        onChanged: (v) => setState(() => _categoriaSeleccionada = v),
      ),
    );
  }

  Widget _buildContadorLine(
    ColorScheme colorScheme,
    int totalSeleccionados,
    int visibles,
    bool hayFiltroActivo,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _colorPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _colorPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            totalSeleccionados > 0
                ? Icons.check_circle_rounded
                : Icons.filter_alt_rounded,
            size: 14,
            color: _colorPrimary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              totalSeleccionados > 0
                  ? '$totalSeleccionados seleccionado${totalSeleccionados == 1 ? '' : 's'}'
                  : 'Filtro activo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _colorPrimary,
              ),
            ),
          ),
          if (hayFiltroActivo)
            Text(
              '$visibles visibles',
              style: TextStyle(
                fontSize: 11.5,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, bool hayFiltroActivo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hayFiltroActivo
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: 32,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              hayFiltroActivo
                  ? 'Sin coincidencias'
                  : 'No hay productos disponibles',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hayFiltroActivo
                  ? 'Prueba con otro término o cambia de categoría.'
                  : 'Todos los productos ya tienen proveedor asignado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// BOTÓN MINI DE ICONO (con hover y estado disabled)
// ═══════════════════════════════════════════════════════════════════════

class _MiniIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;
  final Color accentColor;
  final ColorScheme colorScheme;

  const _MiniIconButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
    required this.accentColor,
    required this.colorScheme,
  });

  @override
  State<_MiniIconButton> createState() => _MiniIconButtonState();
}

class _MiniIconButtonState extends State<_MiniIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.enabled ? widget.accentColor : widget.colorScheme.outline;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.enabled && _hovered
                  ? effectiveColor.withValues(alpha: 0.15)
                  : (widget.enabled
                      ? effectiveColor.withValues(alpha: 0.08)
                      : widget.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.enabled
                    ? effectiveColor.withValues(alpha: 0.3)
                    : widget.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: effectiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TILE DE PRODUCTO
// ═══════════════════════════════════════════════════════════════════════

class _ProductoTile extends StatefulWidget {
  final ProductoEntity producto;
  final bool selected;
  final VoidCallback onTap;

  const _ProductoTile({
    required this.producto,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ProductoTile> createState() => _ProductoTileState();
}

class _ProductoTileState extends State<_ProductoTile> {
  bool _hovered = false;

  static const _colorPrimary = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.selected
                ? _colorPrimary.withValues(alpha: 0.10)
                : (_hovered
                    ? colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.selected
                  ? _colorPrimary.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              // ── Checkbox ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? _colorPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.selected
                        ? _colorPrimary
                        : colorScheme.outlineVariant,
                    width: 1.6,
                  ),
                ),
                child: widget.selected
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),

              // ── Caja del icono ──
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _colorPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: _colorPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // ── Nombre + código + categoría ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.producto.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (widget.producto.categoria.isNotEmpty) ...[
                          _categoryChip(
                            widget.producto.categoria,
                            colorScheme,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            'Cód: ${widget.producto.codigoBarras}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ── Precio ──
              Text(
                '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _colorPrimary,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String categoria, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        categoria,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}