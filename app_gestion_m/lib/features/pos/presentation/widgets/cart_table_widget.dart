import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/cart_item.dart';

class CartTableWidget extends StatefulWidget {
  final List<CartItem> items;
  final Function(int index, double nuevaCantidad) onCantidadChanged;
  final Function(int index) onEliminarItem;

  const CartTableWidget({
    super.key,
    required this.items,
    required this.onCantidadChanged,
    required this.onEliminarItem,
  });

  @override
  State<CartTableWidget> createState() => _CartTableWidgetState();
}

class _CartTableWidgetState extends State<CartTableWidget> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(int index, double cantidad, bool esPesado) {
    final text = cantidad.toStringAsFixed(esPesado ? 3 : 0);
    if (!_controllers.containsKey(index)) {
      _controllers[index] = TextEditingController(text: text);
    } else {
      // Actualiza el texto solo si no coincide (ej: producto re-escaneado)
      if (_controllers[index]!.text != text &&
          double.tryParse(_controllers[index]!.text) != cantidad) {
        _controllers[index]!.text = text;
      }
    }
    return _controllers[index]!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No hay productos en el carrito',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        itemCount: widget.items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final esPesado = item.producto.esPesado;
          final controller = _getController(index, item.cantidad, esPesado);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              item.producto.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${item.producto.codigoBarras} • \$${item.producto.precioUnidad.toStringAsFixed(2)} / ${esPesado ? 'KG' : 'Unid'}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✏️ CAMPO DE CANTIDAD EDITABLE Y RESTRINGIDO
                SizedBox(
                  width: 80,
                  height: 38,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.numberWithOptions(decimal: esPesado),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    // 🔒 RESTRICCIÓN: Solo enteros para unidad, decimales para peso
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        esPesado
                            ? RegExp(r'^\d*\.?\d{0,3}')
                            : RegExp(r'^\d*'),
                      ),
                    ],
                    // ⚡ ACCESIBILIDAD: Auto-seleccionar texto al presionar
                    onTap: () {
                      controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controller.text.length,
                      );
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      suffixText: esPesado ? 'kg' : 'u',
                      suffixStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      final nuevaCant = double.tryParse(val) ?? 0.0;
                      if (nuevaCant > 0) {
                        widget.onCantidadChanged(index, nuevaCant);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    _controllers.remove(index)?.dispose();
                    widget.onEliminarItem(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}