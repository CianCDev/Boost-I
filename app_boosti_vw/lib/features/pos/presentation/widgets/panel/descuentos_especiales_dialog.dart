// lib/features/pos/presentation/widgets/dialogos_genericos/descuento_especial_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/cart_item.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../admin_validation_dialog.dart';
import '../dialogos_genericos/confirm_dialog.dart';
import '../dialogos_genericos/error_dialog.dart';
import '../dialogos_genericos/succes_dialog.dart';


class DescuentoEspecialDialog extends ConsumerStatefulWidget {
  const DescuentoEspecialDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const DescuentoEspecialDialog(),
    );
  }

  @override
  ConsumerState<DescuentoEspecialDialog> createState() =>
      _DescuentoEspecialDialogState();
}

class _DescuentoEspecialDialogState
    extends ConsumerState<DescuentoEspecialDialog> {
  String? _selectedProductId;
  final TextEditingController _precioController = TextEditingController();
  bool _isLoading = false;

  List<CartItem> get _items => ref.watch(cartProvider).items;
  double get _tasaBcv => ref.watch(bcvProvider).tasa;

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  bool get _isPrecioValido {
    final precio = double.tryParse(_precioController.text);
    return precio != null && precio > 0;
  }

  CartItem? get _selectedItem {
    try {
      return _items.firstWhere((i) => i.producto.id == _selectedProductId);
    } catch (_) {
      return null;
    }
  }

  double? get _precioOriginal => _selectedItem?.precioOriginal;
  double? get _precioActual => _selectedItem?.producto.precioUnidad;

  bool get _tieneDescuento => _selectedItem?.esDescuentoEspecial ?? false;

  String get _ahorro => _precioOriginal != null && _precioActual != null
      ? (_precioOriginal! - _precioActual!).toStringAsFixed(2)
      : '0.00';

  String get _porcentajeAhorro {
    if (_precioOriginal == null || _precioActual == null) return '0%';
    final ahorro = _precioOriginal! - _precioActual!;
    if (ahorro <= 0) return '0%';
    return '${((ahorro / _precioOriginal!) * 100).toStringAsFixed(1)}%';
  }

  void _seleccionarProducto(String id) {
    setState(() {
      _selectedProductId = id;
      final item = _items.firstWhere((i) => i.producto.id == id);
      _precioController.text =
          item.producto.precioUnidad.toStringAsFixed(2);
    });
  }

  Future<void> _restaurarPrecioOriginal() async {
    if (_selectedProductId == null) return;
    if (!_tieneDescuento) {
      _mostrarError('Este producto no tiene descuento aplicado.');
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: 'Restaurar precio original',
        content:
            '¿Restaurar el precio original de este producto?\n\n'
            'Producto: ${_selectedItem!.producto.nombre}\n'
            'Precio con descuento: \$${_precioActual!.toStringAsFixed(2)}\n'
            'Precio original: \$${_precioOriginal!.toStringAsFixed(2)}',
        confirmText: 'Restaurar',
        confirmColor: const Color(0xFF10B981),
        onConfirm: () {},
      ),
    );

    if (confirmado != true) return;

    try {
      ref
          .read(cartProvider.notifier)
          .restaurarPrecioOriginal(_selectedProductId!);

      if (mounted) {
        // Actualizar el campo con el precio original
        _precioController.text = _precioOriginal!.toStringAsFixed(2);
        setState(() {}); // Refrescar UI
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => const SuccessDialog(
            title: 'Precio restaurado',
            content: 'El producto ha vuelto a su precio original.',
          ),
        );
      }
    } catch (e) {
      if (mounted) _mostrarError('Error al restaurar: $e');
    }
  }

  Future<void> _aplicarDescuento() async {
    if (_selectedProductId == null) {
      _mostrarError('Selecciona un producto.');
      return;
    }
    if (!_isPrecioValido) {
      _mostrarError('Ingresa un precio válido (mayor a 0).');
      return;
    }

    final nuevoPrecio = double.parse(_precioController.text);
    final original = _precioOriginal!;

    // Validación opcional: no permitir precio mayor al original
    if (nuevoPrecio > original) {
      final continuar = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => ConfirmDialog(
          title: 'Precio mayor al original',
          content:
              'El nuevo precio (\$${nuevoPrecio.toStringAsFixed(2)}) es mayor al precio original (\$${original.toStringAsFixed(2)}).\n\n'
              '¿Deseas continuar de todas formas?',
          confirmText: 'Continuar',
          confirmColor: Colors.orange,
          onConfirm: () {},
        ),
      );
      if (continuar != true) return;
    }

    // Confirmar con el usuario
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: 'Aplicar descuento especial',
        content:
            '¿Estás seguro de aplicar este descuento?\n\n'
            'Producto: ${_selectedItem!.producto.nombre}\n'
            'Precio original: \$${original.toStringAsFixed(2)}\n'
            'Nuevo precio: \$${nuevoPrecio.toStringAsFixed(2)}\n'
            'Ahorro: \$$_ahorro ($_porcentajeAhorro)',
        confirmText: 'Aplicar descuento',
        confirmColor: const Color(0xFFF59E0B),
        onConfirm: () {},
      ),
    );

    if (confirmado != true) return;

    // Validar administrador
    final adminValidado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdminValidationDialog(
        onSuccess: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );

    if (adminValidado != true) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => const ErrorDialog(
            title: 'Acceso denegado',
            content: 'Solo los administradores pueden aplicar descuentos especiales.',
          ),
        );
      }
      return;
    }

    // Aplicar descuento
    setState(() => _isLoading = true);

    try {
      ref
          .read(cartProvider.notifier)
          .aplicarDescuentoEspecial(_selectedProductId!, nuevoPrecio);

      if (mounted) {
        final ahorro = original - nuevoPrecio;
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => SuccessDialog(
            title: '✅ Descuento aplicado',
            content:
                'Producto: ${_selectedItem!.producto.nombre}\n'
                'Nuevo precio: \$${nuevoPrecio.toStringAsFixed(2)}\n'
                'Ahorro: \$${ahorro.toStringAsFixed(2)} ($_porcentajeAhorro)',
          ),
        );
        // Cerrar el diálogo principal
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _mostrarError('Error al aplicar descuento: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ErrorDialog(title: 'Error', content: mensaje),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    if (_items.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 8,
      child: Container(
        width: isMobile ? double.infinity : 560,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(isDark, isMobile),
                    const SizedBox(height: 16),
                    _buildProductList(isDark, isMobile),
                    const SizedBox(height: 16),
                    _buildPriceField(isDark, isMobile),
                    const SizedBox(height: 12),
                    _buildActions(isDark, isMobile),
                    const SizedBox(height: 8),
                    _buildFooter(isDark, isMobile),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: isDark ? Colors.white30 : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'El carrito está vacío',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega productos para aplicar descuentos especiales.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.local_offer_rounded,
            color: Color(0xFFF59E0B),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Descuento especial',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  Widget _buildProductList(bool isDark, bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _items.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final item = _items[index];
          final isSelected = _selectedProductId == item.producto.id;
          final hasDescuento = item.esDescuentoEspecial;
          final precio = item.producto.precioUnidad;
          final original = item.precioOriginal;

          return InkWell(
            onTap: () => _seleccionarProducto(item.producto.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.08))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFFF59E0B),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Radio button
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : (isDark ? Colors.white54 : Colors.grey.shade400),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                          )
                        : null,
                  ),
                  // Info del producto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.producto.nombre,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: isMobile ? 14 : 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasDescuento) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Dscto.',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (hasDescuento) ...[
                              Text(
                                '\$${original.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '\$${precio.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ] else ...[
                              Text(
                                '\$${precio.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            Text(
                              '${item.cantidad.toStringAsFixed(item.producto.esPesado ? 3 : 0)} ${item.producto.esPesado ? 'kg' : 'und'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Botón restaurar (si tiene descuento)
                  if (hasDescuento)
                    IconButton(
                      icon: Icon(
                        Icons.restore_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                      tooltip: 'Restaurar precio original',
                      onPressed: () async {
                        _seleccionarProducto(item.producto.id);
                        _restaurarPrecioOriginal();
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceField(bool isDark, bool isMobile) {
    final precio = double.tryParse(_precioController.text) ?? 0;
    final totalBs = precio * _tasaBcv;
    final precioOriginal = _precioOriginal;
    final tieneDescuento = _tieneDescuento;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Nuevo precio unitario (USD)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            if (precioOriginal != null)
              TextButton.icon(
                onPressed: () {
                  _precioController.text = precioOriginal.toStringAsFixed(2);
                  setState(() {});
                },
                icon: Icon(
                  Icons.restore_rounded,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
                label: Text(
                  'Original \$${precioOriginal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF8B5CF6),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            // Conversión a Bs con 2 decimales
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Bs. ${totalBs.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Tasa: ${_tasaBcv.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                  if (tieneDescuento && precioOriginal != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Original: \$${precioOriginal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(bool isDark, bool isMobile) {
    final hasItems = _items.isNotEmpty;
    final selected = _selectedProductId != null;
    final priceValid = _isPrecioValido;
    final hasDiscount = _tieneDescuento;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white54 : Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 8),
        if (hasDiscount)
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? _restaurarPrecioOriginal : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Restaurar original'),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: (!hasItems || !selected || !priceValid || _isLoading)
                ? null
                : _aplicarDescuento,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_offer_rounded, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Aplicar descuento',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark, bool isMobile) {
    // ignore: unused_local_variable
    final total = ref.watch(cartProvider).total;
    final totalConDescuento = _items.fold(0.0, (sum, item) => sum + item.subtotal);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total carrito:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          Text(
            '\$${totalConDescuento.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}