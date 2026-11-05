// features/pos/presentation/widgets/quantity_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/scale_provider.dart';
import '../admin_validation_dialog.dart';

class QuantityDialog extends ConsumerStatefulWidget {
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
  ConsumerState<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends ConsumerState<QuantityDialog> {
  late final _scaleService = ref.read(scaleServiceProvider);
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  final FocusNode _cantidadFocus = FocusNode();
  final FocusNode _precioFocus = FocusNode();

  bool _adminValidoParaEstaVenta = false;
  bool _usandoPesoAutomatico = true;
  bool _procesando = false;
  bool _formValido = true;
  double _cantidadActual = 0;
  double _precioUnitario = 0;

  /// Guard de re-entrada SIN setState.
  bool _cerrando = false;

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
    _cantidadActual = double.tryParse(_cantidadController.text) ?? 0;
    _precioUnitario = double.tryParse(_precioController.text) ?? 0;
    _formValido = _cantidadActual > 0 && _precioUnitario > 0;

    if (widget.producto.esPesado) {
      _weightSubscription = _scaleService.weightStream.listen((peso) {
        if (peso > 0 && mounted && _usandoPesoAutomatico) {
          final nuevoPeso = peso.toStringAsFixed(3);
          if (_cantidadController.text != nuevoPeso) {
            _cantidadController.value = TextEditingValue(
              text: nuevoPeso,
              selection: TextSelection.collapsed(offset: nuevoPeso.length),
            );
            _actualizarCalculo();
          }
        }
      });
      unawaited(_scaleService.connect());
    }

    _cantidadFocus.addListener(() {
      if (_cantidadFocus.hasFocus) _seleccionarTodo(_cantidadController);
    });
    _precioFocus.addListener(() {
      if (_precioFocus.hasFocus) _seleccionarTodo(_precioController);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.producto.esPesado) {
        _precioFocus.requestFocus();
      } else {
        _cantidadFocus.requestFocus();
      }
    });
  }

  void _seleccionarTodo(TextEditingController controller) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  void _actualizarCalculo() {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final precio = double.tryParse(_precioController.text) ?? 0;
    setState(() {
      _cantidadActual = cantidad;
      _precioUnitario = precio;
      _formValido = cantidad > 0 && precio > 0;
    });
  }

  @override
  void dispose() {
    _weightSubscription?.cancel();
    _cantidadController.dispose();
    _precioController.dispose();
    _cantidadFocus.dispose();
    _precioFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 20),
                _buildCantidadField(isDark),
                const SizedBox(height: 16),
                _buildPrecioField(isDark),
                const SizedBox(height: 16),
                _buildTotal(isDark),
                const SizedBox(height: 24),
                _buildBotones(isDark, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar al carrito',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.producto.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
    );
  }

  Widget _buildCantidadField(bool isDark) {
    return TextField(
      controller: _cantidadController,
      focusNode: _cantidadFocus,
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
      onChanged: (_) => _actualizarCalculo(),
      onTap: () {
        if (widget.producto.esPesado && _usandoPesoAutomatico) {
          setState(() => _usandoPesoAutomatico = false);
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
      },
      onSubmitted: (_) => _precioFocus.requestFocus(),
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
                _usandoPesoAutomatico ? Icons.wifi_tethering : Icons.edit,
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPrecioField(bool isDark) {
    return TextField(
      controller: _precioController,
      focusNode: _precioFocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (_) => _actualizarCalculo(),
      onSubmitted: (_) => _agregar(),
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildTotal(bool isDark) {
    const accent = Color(0xFF10B981);
    final total = _cantidadActual * _precioUnitario;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sell_rounded, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                'Precio por unidad',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '\$${_precioUnitario.toStringAsFixed(2)} / ${widget.producto.esPesado ? 'kg' : 'unid'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: accent.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),
          _resumenRow('Subtotal', '\$${total.toStringAsFixed(2)}', isDark),
          const SizedBox(height: 12),
          Divider(color: accent.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumenRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBotones(bool isDark, ColorScheme colorScheme) {
    final habilitado = !_procesando && _formValido;
    return Row(
      children: [
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: isDark ? Colors.white70 : Colors.black54,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            onPressed: () {
              _weightSubscription?.cancel();
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: habilitado
                  ? const Color(0xFF10B981)
                  : colorScheme.surfaceContainerHighest,
              foregroundColor:
                  habilitado ? Colors.white : colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: habilitado ? 3 : 0,
            ),
            onPressed: habilitado ? _agregar : null,
            child: _procesando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart_rounded, size: 18),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Agregar al Carrito',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _agregar() async {
    if (_cerrando) return;

    final cantidad = _cantidadActual;
    if (cantidad <= 0) {
      _mostrarSnack('Ingrese una cantidad válida');
      return;
    }

    final precioIngresado = _precioUnitario;
    if (precioIngresado <= 0) {
      _mostrarSnack('Ingrese un precio válido');
      return;
    }

    try {
      final precioOriginal = widget.producto.precioUnidad;
      final topeDescuento = precioOriginal * 0.80;

      if (!_adminValidoParaEstaVenta && precioIngresado < topeDescuento) {
        setState(() => _procesando = true);

        final validado = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AdminValidationDialog(
            onSuccess: () => Navigator.of(dialogContext).pop(true),
            onCancel: () {
              _precioController.text =
                  widget.producto.precioUnidad.toStringAsFixed(2);
              _actualizarCalculo();
              Navigator.of(dialogContext).pop(false);
            },
          ),
        );

        if (!mounted) return;

        if (validado != true) {
          setState(() => _procesando = false);
          _actualizarCalculo();
          return;
        }

        _adminValidoParaEstaVenta = true;
        setState(() => _procesando = false);
      }

      // Marcamos el estado de cierre definitivo
      _cerrando = true;
      _weightSubscription?.cancel();
      _weightSubscription = null;

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

      // 1. Ocultar teclado y quitar el diálogo de la pantalla INMEDIATAMENTE
      FocusManager.instance.primaryFocus?.unfocus();
      if (mounted) Navigator.of(context).pop();

      // 2. Diferimos la actualización de Riverpod (carrito).
      // Esto evita que la carga masiva en memoria ocurra exactamente en el
      // mismo frame en el que el teclado baja y el diálogo se cierra,
      // eliminando los parpadeos y "tirones" de pantalla.
      Future.delayed(const Duration(milliseconds: 50), () {
        widget.onAgregar(productoConPrecio, cantidad);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      _actualizarCalculo();
      _cerrando = false;
      _mostrarSnack('Error: $e');
    }
  }

  void _mostrarSnack(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
