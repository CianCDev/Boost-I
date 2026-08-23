import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';
import '../../services/scale_service.dart';
import '../admin_validation_dialog.dart';
import '../../utils/input_decoration_helper.dart';

class QuantityDialog extends StatefulWidget {
  final ProductoEntity producto;
  final Function(ProductoEntity, double) onAgregar;

  /// Cantidad inicial sugerida (factor de alias, ej. 12 para caja)
  /// Por defecto 1.0 para mantener compatibilidad con código existente
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

    // ✅ Usar cantidadInicial para productos NO pesados
    if (widget.producto.esPesado) {
      _cantidadController.text = '0.000';
    } else {
      // Si el factor es entero, mostrarlo sin decimales; si no, con decimales
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
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = !isTablet && !ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.08),
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
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.producto.esPesado ? Icons.monitor_weight : Icons.shopping_cart_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agregar ${widget.producto.nombre}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.producto.esPesado && _weightSubscription != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_tethering_rounded,
                              size: 14, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Balanza',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
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
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ CAMPO DE CANTIDAD (con helper)
              TextField(
                controller: _cantidadController,
                autofocus: true,
                enableInteractiveSelection: false,
                keyboardType: TextInputType.numberWithOptions(decimal: widget.producto.esPesado),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    widget.producto.esPesado
                        ? RegExp(r'^\d*\.?\d{0,3}')
                        : RegExp(r'^\d*\.?\d{0,2}'), // Permitir decimales para productos no pesados
                  ),
                ],
                onTap: () {
                  if (widget.producto.esPesado && _usandoPesoAutomatico) {
                    _usandoPesoAutomatico = false;
                    _weightSubscription?.cancel();
                    _weightSubscription = null;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✏️ Edición manual activada'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: colorScheme.primary,
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
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecorationHelper.build(
                  context: context,
                  label: 'Cantidad',
                  prefixIcon: widget.producto.esPesado
                      ? (_usandoPesoAutomatico ? Icons.wifi_tethering : Icons.edit)
                      : null,
                  errorText: null,
                  isDark: isDark,
                ).copyWith(
                  suffixText: widget.producto.esPesado ? 'kg' : 'unid',
                  suffixStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
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

              // ✅ CAMPO DE PRECIO (con helper)
              TextField(
                controller: _precioController,
                enableInteractiveSelection: false,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecorationHelper.build(
                  context: context,
                  label: 'Precio por unidad (\$)',
                  prefixIcon: Icons.attach_money,
                  errorText: null,
                  isDark: isDark,
                ).copyWith(
                  prefixText: '\$ ',
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
                      foregroundColor: colorScheme.onSurfaceVariant,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _weightSubscription?.cancel();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      if (_procesando) return;
                      setState(() => _procesando = true);

                      try {
                        final double? cantidad = double.tryParse(_cantidadController.text);
                        if (cantidad == null || cantidad <= 0) {
                          setState(() => _procesando = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ingrese una cantidad válida'),
                              backgroundColor: colorScheme.error,
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

                        // Cerrar diálogo y agregar al carrito
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
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    child: _procesando
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(
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