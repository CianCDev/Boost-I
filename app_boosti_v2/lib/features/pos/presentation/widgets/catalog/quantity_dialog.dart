import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';
import '../../services/scale_service.dart';
import '../admin_validation_dialog.dart'; // Ajusta la ruta según tu estructura

class QuantityDialog extends StatefulWidget {
  final ProductoEntity producto;
  final Function(ProductoEntity, double) onAgregar;

  const QuantityDialog({
    super.key,
    required this.producto,
    required this.onAgregar,
  });

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  final ScaleService _scaleService = ScaleService();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  bool _adminValidoParaEstaVenta = false;
  bool _usandoPesoAutomatico = true;
  StreamSubscription<double>? _weightSubscription;

  @override
  void initState() {
    super.initState();
    _cantidadController.text = widget.producto.esPesado ? '0.000' : '1';
    _precioController.text = widget.producto.precioUnidad.toStringAsFixed(2);

    if (widget.producto.esPesado) {
      _weightSubscription = _scaleService.weightStream.listen((peso) {
        if (peso > 0 && mounted) {
          setState(() {
            _cantidadController.text = peso.toStringAsFixed(3);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _weightSubscription?.cancel();
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = !isTablet && !ResponsiveHelper.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet || isDesktop ? 40.0 : 16.0,
        vertical: 24.0,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet || isDesktop ? 550.0 : double.infinity,
        ),
        padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.producto.esPesado ? Icons.monitor_weight : Icons.shopping_cart_outlined,
                      color: const Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agregar ${widget.producto.nombre}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.producto.esPesado && _weightSubscription != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_tethering_rounded,
                              size: 14, color: const Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            'Balanza',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.producto.esPesado
                    ? 'El peso se actualiza automáticamente desde la balanza:'
                    : 'Ingresa la cantidad deseada (unidades):',
                style: TextStyle(
                  fontSize: isTablet || isDesktop ? 16 : 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Campo de cantidad
              TextField(
                controller: _cantidadController,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(decimal: widget.producto.esPesado),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    widget.producto.esPesado
                        ? RegExp(r'^\d*\.?\d{0,3}')
                        : RegExp(r'^\d*'),
                  ),
                ],
                onTap: () {
                  if (widget.producto.esPesado && _usandoPesoAutomatico) {
                    _usandoPesoAutomatico = false;
                    _weightSubscription?.cancel();
                    _weightSubscription = null;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✏️ Edición manual activada'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                  _cantidadController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _cantidadController.text.length,
                  );
                },
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  labelStyle: TextStyle(
                    fontSize: isTablet || isDesktop ? 16 : 14,
                    color: Colors.grey.shade600,
                  ),
                  suffixText: widget.producto.esPesado ? 'kg' : 'unid',
                  suffixStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(97, 97, 97, 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet || isDesktop ? 20 : 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
                  ),
                  prefixIcon: widget.producto.esPesado
                      ? Icon(
                          _usandoPesoAutomatico ? Icons.wifi_tethering : Icons.edit,
                          color: _usandoPesoAutomatico
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade500,
                          size: 20,
                        )
                      : null,
                ),
                onSubmitted: (val) {
                  final double? cantidad = double.tryParse(val);
                  if (cantidad != null && cantidad > 0) {
                    widget.onAgregar(widget.producto, cantidad);
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 12),
              // Campo de precio
              TextField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Precio por unidad (\$)',
                  prefixText: '\$ ',
                  labelStyle: TextStyle(
                    fontSize: isTablet || isDesktop ? 16 : 14,
                    color: Colors.grey.shade600,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet || isDesktop ? 20 : 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Botones
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      foregroundColor: Colors.grey.shade700,
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _weightSubscription?.cancel();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      final double? cantidad = double.tryParse(_cantidadController.text);
                      if (cantidad == null || cantidad <= 0) return;

                      final double precioIngresado =
                          double.tryParse(_precioController.text) ?? widget.producto.precioUnidad;
                      final double precioOriginal = widget.producto.precioUnidad;
                      final double topeDescuento = precioOriginal * 0.80;

                      if (!_adminValidoParaEstaVenta && precioIngresado < topeDescuento) {
                        await showDialog(
                          context: context,
                          builder: (context) => AdminValidationDialog(
                            onSuccess: () {
                              setState(() => _adminValidoParaEstaVenta = true);
                            },
                            onCancel: () {
                              _precioController.text = widget.producto.precioUnidad.toStringAsFixed(2);
                            },
                          ),
                        );
                        if (!_adminValidoParaEstaVenta) return;
                      }

                      _weightSubscription?.cancel();

                      // Crear una copia del producto con el precio modificado
                      final productoConPrecio = ProductoEntity()
                        ..id = widget.producto.id
                        ..codigoBarras = widget.producto.codigoBarras
                        ..nombre = widget.producto.nombre
                        ..precioUnidad = precioIngresado
                        ..esPesado = widget.producto.esPesado
                        ..categoria = widget.producto.categoria
                        ..stock = widget.producto.stock
                        ..stockMinimo = widget.producto.stockMinimo
                        ..proveedorNombre = widget.producto.proveedorNombre
                        ..proveedorTelefono = widget.producto.proveedorTelefono;

                      widget.onAgregar(productoConPrecio, cantidad);
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Agregar al Carrito',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}