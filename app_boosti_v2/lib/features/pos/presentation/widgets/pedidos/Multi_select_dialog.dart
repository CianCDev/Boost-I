// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<ProductoEntity> items;
  final String title;
  final String confirmText;
  final String cancelText;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.title,
    this.confirmText = 'Asignar',
    this.cancelText = 'Cancelar',
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  final Set<int> _selectedIds = {};

  static const _colorPrimary = Color(0xFF8B5CF6);

  void _toggle(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassDialog(
      maxWidth: 520,
      maxHeightFactor: 0.85,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.checklist_rounded,
              title: widget.title,
              subtitle: '${widget.items.length} disponibles',
              color: _colorPrimary,
            ),
            const SizedBox(height: 16),

            // ===== LISTA =====
            Flexible(
              child: widget.items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No hay productos disponibles',
                          style:
                              TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final producto = widget.items[index];
                        final selected =
                            _selectedIds.contains(producto.id);
                        return _ProductoTile(
                          producto: producto,
                          selected: selected,
                          onTap: () => _toggle(producto.id),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // ===== BOTONES =====
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
                        child: Text(widget.cancelText,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: MouseRegion(
                    cursor: _selectedIds.isEmpty
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : () {
                                final seleccionados = widget.items
                                    .where((p) => _selectedIds.contains(p.id))
                                    .toList();
                                Navigator.pop(context, seleccionados);
                              },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          '${widget.confirmText} (${_selectedIds.length})',
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
}

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? const Color(0xFF8B5CF6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.selected
                        ? const Color(0xFF8B5CF6)
                        : colorScheme.outlineVariant,
                    width: 1.6,
                  ),
                ),
                child: widget.selected
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Color(0xFF8B5CF6), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.producto.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Código: ${widget.producto.codigoBarras}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}