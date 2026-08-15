import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: widget.items.isEmpty
            ? const Center(child: Text('No hay productos disponibles'))
            : ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final producto = widget.items[index];
                  final isSelected = _selectedIds.contains(producto.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(producto.id);
                        } else {
                          _selectedIds.remove(producto.id);
                        }
                      });
                    },
                    title: Text(producto.nombre),
                    subtitle: Text('Código: ${producto.codigoBarras}'),
                    secondary: Text(
                      'Bs ${producto.precioUnidad.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(widget.cancelText),
        ),
        ElevatedButton(
          onPressed: _selectedIds.isEmpty
              ? null
              : () {
                  final seleccionados = widget.items
                      .where((p) => _selectedIds.contains(p.id))
                      .toList();
                  Navigator.pop(context, seleccionados);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}