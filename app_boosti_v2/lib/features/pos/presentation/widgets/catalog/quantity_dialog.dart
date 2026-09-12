// features/pos/presentation/widgets/quantity_dialog.dart
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

  final FocusNode _cantidadFocus = FocusNode();
  final FocusNode _precioFocus = FocusNode();

  bool _adminValidoParaEstaVenta = false;
  bool _usandoPesoAutomatico = true;
  bool _procesando = false;
  bool _formValido = true;

  /// Guard de re-entrada SIN setState.
  /// Previene que el botón se presione múltiples veces bloqueando la ejecución.
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

    if (widget.producto.esPesado) {
      _weightSubscription = _scaleService.weightStream.listen((peso) {
        if (peso > 0 && mounted && _usandoPesoAutomatico) {
          setState(() {
            _cantidadController.text = peso.toStringAsFixed(3);
          });
          _revalidarFormulario();
        }
      });
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

  /// Verifica si hay datos mayores a cero para habilitar/deshabilitar el botón
  void _revalidarFormulario() {
    final c = double.tryParse(_cantidadController.text) ?? 0;
    final p = double.tryParse(_precioController.text) ?? 0;
    final valido = c > 0 && p > 0;
    if (valido != _formValido) {
      setState(() => _formValido = valido);
    }
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
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
                  _buildHeader(isDark),
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
                  _buildCantidadField(isDark),
                  const SizedBox(height: 12),
                  _buildPrecioField(isDark),
                  const SizedBox(height: 28),
                  _buildBotones(isDark, colorScheme),
                ],
              ),
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
      onChanged: (_) => _revalidarFormulario(),
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
      onChanged: (_) => _revalidarFormulario(),
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildBotones(bool isDark, ColorScheme colorScheme) {
    final habilitado = !_procesando && _formValido;
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: habilitado
                ? const Color(0xFF10B981)
                : colorScheme.surfaceContainerHighest,
            foregroundColor:
                habilitado ? Colors.white : colorScheme.onSurfaceVariant,
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: habilitado ? 4 : 0,
            shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
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
              : const Text(
                  'Agregar al Carrito',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
        ),
      ],
    );
  }

  Future<void> _agregar() async {
    // 1. Guard contra doble ejecución en el mismo ciclo.
    if (_cerrando) return;
    _cerrando = true;

    final cantidad = double.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      _cerrando = false;
      _mostrarSnack('Ingrese una cantidad válida');
      return;
    }

    final precioIngresado = double.tryParse(_precioController.text);
    if (precioIngresado == null || precioIngresado <= 0) {
      _cerrando = false;
      _mostrarSnack('Ingrese un precio válido');
      return;
    }

    try {
      final precioOriginal = widget.producto.precioUnidad;
      final topeDescuento = precioOriginal * 0.80;

      // 2. Validación asíncrona (si requiere admin)
      if (!_adminValidoParaEstaVenta && precioIngresado < topeDescuento) {
        setState(() => _procesando = true);

        final validado = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AdminValidationDialog(
            onSuccess: () => Navigator.of(dialogContext).pop(true),
            onCancel: () {
              _precioController.text =
                  widget.producto.precioUnidad.toStringAsFixed(2);
              Navigator.of(dialogContext).pop(false);
            },
          ),
        );

        if (!mounted) return;

        if (validado != true) {
          setState(() => _procesando = false);
          _revalidarFormulario();
          _cerrando = false;
          return;
        }

        _adminValidoParaEstaVenta = true;
        setState(() => _procesando = false);
      }

      // 3. Detener escuchas
      _weightSubscription?.cancel();
      _weightSubscription = null;

      // 4. Bajar el teclado para evitar saltos y tirones visuales al hacer pop
      FocusManager.instance.primaryFocus?.unfocus();

      // 5. Preparar la instancia final
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

      final callback = widget.onAgregar;

      // 6. Cerrar el diálogo ANTES de ejecutar el Riverpod y el redibujado de la UI principal
      if (mounted) Navigator.of(context).pop();

      // 7. Retrasar el cálculo del carrito 150ms 
      // Esto libera el hilo principal permitiendo que Navigator.pop renderice sus 60 FPS sin tirones.
      Future.delayed(const Duration(milliseconds: 150), () {
        callback(productoConPrecio, cantidad);
      });
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      _revalidarFormulario();
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
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}