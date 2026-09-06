import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/cart_item.dart';
import '../utils/responsive_helper.dart';

class CartTableWidget extends StatefulWidget {
  final List<CartItem> items;
  final Function(int index, double nuevaCantidad) onCantidadChanged;
  final Function(int index) onEliminarItem;
  final Function(int index, double? precio) onPrecioEspecialChanged;

  const CartTableWidget({
    super.key,
    required this.items,
    required this.onCantidadChanged,
    required this.onEliminarItem,
    required this.onPrecioEspecialChanged,
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
      if (_controllers[index]!.text != text &&
          double.tryParse(_controllers[index]!.text) != cantidad) {
        _controllers[index]!.text = text;
      }
    }
    return _controllers[index]!;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final fontSize = ResponsiveHelper.getFontSize(context, baseSize: 13);

    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: isMobile ? 48 : 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay productos en el carrito',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isMobile ? 1 : 2,
      margin: EdgeInsets.zero,
      child: isMobile || isTablet
          ? ListView.separated(
              itemCount: widget.items.length,
              padding: const EdgeInsets.all(4),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final esPesado = item.producto.esPesado;
                final controller = _getController(index, item.cantidad, esPesado);

                return _buildMobileItem(
                  context,
                  item,
                  index,
                  controller,
                  esPesado,
                  fontSize,
                );
              },
            )
          : _buildDesktopTable(fontSize),
    );
  }

  // ==========================================
  // VERSIÓN DESKTOP (Tabla completa)
  // ==========================================

  Widget _buildDesktopTable(double fontSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 16,
        headingRowHeight: 44,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final esPesado = item.producto.esPesado;
          final controller = _getController(index, item.cantidad, esPesado);

          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 180,
                  child: Text(
                    item.producto.nombre,
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '\$${item.precioUnitario.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 120,
                  height: 38,
                  child: _buildQuantityField(
                    controller: controller,
                    esPesado: esPesado,
                    onChanged: (val) {
                      final nuevaCant = double.tryParse(val) ?? 0.0;
                      if (nuevaCant > 0) {
                        widget.onCantidadChanged(index, nuevaCant);
                      }
                    },
                  ),
                ),
              ),
              DataCell(
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        item.esDescuentoEspecial ? Icons.discount : Icons.discount_outlined,
                        color: item.esDescuentoEspecial ? Colors.orange : Colors.blueGrey,
                        size: 20,
                      ),
                      tooltip: 'Descuento especial',
                      onPressed: () => _editarPrecioEspecial(context, index, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                      onPressed: () {
                        _controllers.remove(index)?.dispose();
                        widget.onEliminarItem(index);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // VERSIÓN MÓVIL (Lista compacta)
  // ==========================================

  Widget _buildMobileItem(
    BuildContext context,
    CartItem item,
    int index,
    TextEditingController controller,
    bool esPesado,
    double fontSize,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre del producto
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.producto.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${item.precioUnitario.toStringAsFixed(2)} / ${esPesado ? 'kg' : 'unid'}'
                  '${item.esDescuentoEspecial ? '  Dscto.' : ''}',
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Cantidad y subtotal
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón restar
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  onPressed: () {
                    final step = esPesado ? 0.1 : 1.0;
                    if (item.cantidad > step) {
                      final nuevaCant = item.cantidad - step;
                      widget.onCantidadChanged(index, nuevaCant);
                      _updateController(index, nuevaCant, esPesado);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),

                // Campo de cantidad
                SizedBox(
                  width: 50,
                  height: 34,
                  child: _buildQuantityField(
                    controller: controller,
                    esPesado: esPesado,
                    onChanged: (val) {
                      final nuevaCant = double.tryParse(val) ?? 0.0;
                      if (nuevaCant > 0) {
                        widget.onCantidadChanged(index, nuevaCant);
                      }
                    },
                    compact: true,
                  ),
                ),

                // Botón sumar
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: () {
                    final step = esPesado ? 0.1 : 1.0;
                    final nuevaCant = item.cantidad + step;
                    widget.onCantidadChanged(index, nuevaCant);
                    _updateController(index, nuevaCant, esPesado);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),

                // Subtotal
                const SizedBox(width: 8),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize * 1.1,
                    color: Colors.green.shade700,
                  ),
                ),

                // Botón eliminar
                IconButton(
                  icon: Icon(
                    item.esDescuentoEspecial ? Icons.discount : Icons.discount_outlined,
                    color: item.esDescuentoEspecial ? Colors.orange : Colors.blueGrey,
                    size: 20,
                  ),
                  tooltip: 'Descuento especial',
                  onPressed: () => _editarPrecioEspecial(context, index, item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    _controllers.remove(index)?.dispose();
                    widget.onEliminarItem(index);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editarPrecioEspecial(BuildContext context, int index, CartItem item) async {
    final controller = TextEditingController(
      text: item.esDescuentoEspecial ? item.precioUnitario.toStringAsFixed(2) : '',
    );
    final precio = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descuento especial'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Precio final',
            prefixText: '\$ ',
            hintText: item.producto.precioUnidad.toStringAsFixed(2),
          ),
        ),
        actions: [
          if (item.esDescuentoEspecial)
            TextButton(
              onPressed: () => Navigator.pop(context, 0.0),
              child: const Text('Quitar'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, double.tryParse(controller.text)),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (precio == 0.0) {
      widget.onPrecioEspecialChanged(index, null);
    } else if (precio != null) {
      widget.onPrecioEspecialChanged(index, precio);
    }
  }

  // ==========================================
  // CAMPO DE CANTIDAD COMPARTIDO
  // ==========================================

  Widget _buildQuantityField({
    required TextEditingController controller,
    required bool esPesado,
    required Function(String) onChanged,
    bool compact = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: esPesado),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: compact ? 12 : 13,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          esPesado
              ? RegExp(r'^\d*\.?\d{0,3}')
              : RegExp(r'^\d*'),
        ),
      ],
      onTap: () {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        suffixText: esPesado ? 'kg' : null,
        suffixStyle: TextStyle(
          fontSize: compact ? 9 : 11,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
        isDense: compact,
      ),
      onChanged: onChanged,
    );
  }

  // ==========================================
  // ACTUALIZAR CONTROLLER
  // ==========================================

  void _updateController(int index, double cantidad, bool esPesado) {
    final text = cantidad.toStringAsFixed(esPesado ? 3 : 0);
    if (_controllers.containsKey(index)) {
      _controllers[index]!.text = text;
    }
  }
}