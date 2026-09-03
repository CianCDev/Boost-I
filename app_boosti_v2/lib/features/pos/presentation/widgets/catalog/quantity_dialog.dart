// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../services/scale_service.dart';
import '../admin_validation_dialog.dart';

class QuantityDialog extends StatefulWidget {
  final ProductoEntity producto;
  final Function(ProductoEntity, double) onAgregar;
  final double cantidadInicial;

  const QuantityDialog({
    super.key,
    required this.producto,
    required this.onAgregar,
    this.cantidadInicial = 1.0,
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
  bool _procesando = false;
  StreamSubscription<double>? _weightSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.producto.esPesado) {
      _cantidadController.text = '0.000';
    } else {
      final double inicial = widget.cantidadInicial;
      if (inicial % 1 == 0) {
        _cantidadController.text = inicial.toInt().toString();
      } else {
        _cantidadController.text = inicial.toStringAsFixed(2);
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Fondo neutral translúcido coherente con el panel lateral
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
              // Sombra neutral para dar profundidad sin teñir de verde
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.producto.esPesado
                              ? Icons.monitor_weight_rounded
                              : Icons.shopping_cart_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Agregar ${widget.producto.nombre}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.producto.esPesado && _weightSubscription != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wifi_tethering_rounded,
                                  size: 14, color: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text(
                                'Balanza',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
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
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cantidad
                  TextField(
                    controller: _cantidadController,
                    autofocus: true,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: widget.producto.esPesado,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        widget.producto.esPesado
                            ? RegExp(r'^\d*\.?\d{0,3}')
                            : RegExp(r'^\d*\.?\d{0,2}'),
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
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                      _cantidadController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _cantidadController.text.length,
                      );
                    },
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      prefixIcon: widget.producto.esPesado
                          ? Icon(
                              _usandoPesoAutomatico
                                  ? Icons.wifi_tethering
                                  : Icons.edit,
                              color: isDark ? Colors.white70 : Colors.black54,
                            )
                          : null,
                      suffixText: widget.producto.esPesado ? 'kg' : 'unid',
                      suffixStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF10B981),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
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

                  // Precio
                  TextField(
                    controller: _precioController,
                    enableInteractiveSelection: false,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Precio por unidad (\$)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF10B981)),
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF10B981),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          foregroundColor: isDark ? Colors.white70 : Colors.black54,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        onPressed: () {
                          _weightSubscription?.cancel();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                        onPressed: _procesando ? null : _agregar,
                        child: _procesando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Agregar al Carrito',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _agregar() async {
    if (_procesando) return;
    setState(() => _procesando = true);

    try {
      final double? cantidad = double.tryParse(_cantidadController.text);
      if (cantidad == null || cantidad <= 0) {
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ingrese una cantidad válida'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final double precioIngresado =
          double.tryParse(_precioController.text) ?? widget.producto.precioUnidad;
      final double precioOriginal = widget.producto.precioUnidad;
      final double topeDescuento = precioOriginal * 0.80;

      if (!_adminValidoParaEstaVenta && precioIngresado < topeDescuento) {
        final validado = await showDialog<bool>(
          context: context,
          builder: (context) => AdminValidationDialog(
            onSuccess: () {
              Navigator.of(context).pop(true);
            },
            onCancel: () {
              _precioController.text = widget.producto.precioUnidad.toStringAsFixed(2);
              Navigator.of(context).pop(false);
            },
          ),
        );
        if (validado != true) {
          setState(() => _procesando = false);
          return;
        }
        _adminValidoParaEstaVenta = true;
      }

      _weightSubscription?.cancel();

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

      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAgregar(productoConPrecio, cantidad);
      });
    } catch (e) {
      setState(() => _procesando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}