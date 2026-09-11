import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/cart_item.dart';
import '../utils/responsive_helper.dart';

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
              size: isMobile ? 48 : 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay productos en el carrito',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: isMobile ? 14 : 18,
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
              padding: const EdgeInsets.all(8),
              // ignore: unnecessary_underscores
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final esPesado = item.producto.esPesado;
                final controller = _getController(index, item.cantidad, esPesado);

                return _buildResponsiveItem(
                  context,
                  item,
                  index,
                  controller,
                  esPesado,
                  fontSize,
                  isTablet,
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
        columnSpacing: 24,
        horizontalMargin: 16,
        headingRowHeight: 48,
        dataRowMinHeight: 64, 
        dataRowMaxHeight: 76,
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
                  width: 200,
                  child: Text(
                    item.producto.nombre,
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '\$${item.producto.precioUnidad.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 130,
                  height: 40,
                  child: _buildQuantityField(
                    controller: controller,
                    esPesado: esPesado,
                    onChanged: (val) {
                      final nuevaCant = double.tryParse(val) ?? 0.0;
                      if (nuevaCant > 0) {
                        widget.onCantidadChanged(index, nuevaCant);
                      }
                    },
                    isDesktop: true,
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
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
                  splashRadius: 24,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: () {
                    _controllers.remove(index)?.dispose();
                    widget.onEliminarItem(index);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // VERSIÓN RESPONSIVA (MÓVIL / TABLETA)
  // ==========================================

  Widget _buildResponsiveItem(
    BuildContext context,
    CartItem item,
    int index,
    TextEditingController controller,
    bool esPesado,
    double fontSize,
    bool isTablet,
  ) {
    final double paddingX = isTablet ? 20.0 : 10.0;
    final double paddingY = isTablet ? 16.0 : 10.0;
    final double iconSize = isTablet ? 30.0 : 24.0;
    final double inputWidth = isTablet ? 80.0 : 54.0;
    final double inputHeight = isTablet ? 48.0 : 36.0;
    final double nameFontSize = isTablet ? fontSize * 1.4 : fontSize;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingX, vertical: paddingY),
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
                    fontSize: nameFontSize,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.producto.precioUnidad.toStringAsFixed(2)} / ${esPesado ? 'kg' : 'unid'}',
                  style: TextStyle(
                    fontSize: isTablet ? fontSize : fontSize * 0.8,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Controles de Cantidad y Subtotal
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Control de Cantidad Personalizado
                _buildQuantityControl(
                  index: index,
                  cantidad: item.cantidad,
                  esPesado: esPesado,
                  controller: controller,
                  iconSize: iconSize,
                  inputWidth: inputWidth,
                  inputHeight: inputHeight,
                ),

                const SizedBox(width: 16),

                // Subtotal
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? fontSize * 1.5 : fontSize * 1.1,
                    color: Colors.green.shade700,
                  ),
                ),

                const SizedBox(width: 8),

                // Botón Eliminar (Grande y fácil de tocar)
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.redAccent, size: iconSize),
                  splashRadius: isTablet ? 30 : 24,
                  constraints: BoxConstraints(minWidth: isTablet ? 48 : 36, minHeight: isTablet ? 48 : 36),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _controllers.remove(index)?.dispose();
                    widget.onEliminarItem(index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CONTROL DE CANTIDAD (MEJORADO)
  // ==========================================

  Widget _buildQuantityControl({
    required int index,
    required double cantidad,
    required bool esPesado,
    required TextEditingController controller,
    required double iconSize,
    required double inputWidth,
    required double inputHeight,
  }) {
    final double step = esPesado ? 0.1 : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón Restar
          InkWell(
            onTap: () {
              if (cantidad > step) {
                final nuevaCant = cantidad - step;
                widget.onCantidadChanged(index, nuevaCant);
                _updateController(index, nuevaCant, esPesado);
              }
            },
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: inputHeight * 0.2, vertical: inputHeight * 0.2),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
              ),
              child: Icon(Icons.remove_rounded, size: iconSize * 0.8, color: Colors.grey.shade700),
            ),
          ),

          // Campo de Cantidad
          Container(
            width: inputWidth,
            height: inputHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: esPesado),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  esPesado ? RegExp(r'^\d*\.?\d{0,3}') : RegExp(r'^\d*'),
                ),
              ],
              onTap: () {
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                isDense: true,
              ),
              onChanged: (val) {
                final nuevaCant = double.tryParse(val) ?? 0.0;
                if (nuevaCant >= 0) {
                  widget.onCantidadChanged(index, nuevaCant);
                }
              },
            ),
          ),

          // Botón Sumar
          InkWell(
            onTap: () {
              final nuevaCant = cantidad + step;
              widget.onCantidadChanged(index, nuevaCant);
              _updateController(index, nuevaCant, esPesado);
            },
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: inputHeight * 0.2, vertical: inputHeight * 0.2),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
              ),
              child: Icon(Icons.add_rounded, size: iconSize * 0.8, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CAMPOS COMPARTIDOS
  // ==========================================

  Widget _buildQuantityField({
    required TextEditingController controller,
    required bool esPesado,
    required Function(String) onChanged,
    bool isDesktop = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: esPesado),
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          esPesado ? RegExp(r'^\d*\.?\d{0,3}') : RegExp(r'^\d*'),
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
        suffixStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        isDense: !isDesktop,
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