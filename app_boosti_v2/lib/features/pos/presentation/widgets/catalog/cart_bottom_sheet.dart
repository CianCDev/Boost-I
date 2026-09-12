// lib/features/pos/presentation/widgets/catalog/cart_bottom_sheet.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';
import '../../controllers/bcv_controller.dart';
import 'iva_toggle_button.dart';

class CartBottomSheet extends ConsumerWidget {
  final VoidCallback onCobrar;

  const CartBottomSheet({super.key, required this.onCobrar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    // ✅ NUEVO: controller completo en lugar de solo tasa
    final bcvController = ref.watch(bcvProvider);
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasItems = cartState.items.isNotEmpty;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF091120).withValues(alpha: 0.85),
                        const Color(0xFF1E293B).withValues(alpha: 0.75),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.92),
                        const Color(0xFFF8FAFC).withValues(alpha: 0.85),
                      ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : primaryGreen.withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    _buildHeader(
                        context, ref, hasItems, isTablet, colorScheme),
                    const Divider(thickness: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: cartState.items.isEmpty
                          ? _buildEmptyState(colorScheme)
                          : _buildProductList(cartState.items, isTablet,
                              colorScheme, ref, context),
                    ),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),
                    // ✅ Firma actualizada
                    _buildTotals(cartState, bcvController, hasItems, isTablet,
                        colorScheme, context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool hasItems,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Mi Carrito',
            style: TextStyle(
              fontSize: isTablet ? 28 : 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasItems)
              IconButton(
                icon: Icon(Icons.refresh_outlined, size: isTablet ? 28 : 24),
                color: redError,
                hoverColor: Colors.red.withValues(alpha: 0.1),
                splashColor: Colors.red.withValues(alpha: 0.2),
                tooltip: 'Limpiar carrito',
                onPressed: () => _confirmarLimpiar(context, ref),
              ),
            IconButton(
              icon: Icon(Icons.close_rounded, size: isTablet ? 28 : 24),
              color: colorScheme.onSurfaceVariant,
              hoverColor: Colors.grey.withValues(alpha: 0.1),
              splashColor: Colors.grey.withValues(alpha: 0.2),
              tooltip: 'Cerrar',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- ESTADO VACÍO ----------
  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 60, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'El carrito está vacío',
            style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ---------- LISTA DE PRODUCTOS ----------
  Widget _buildProductList(
    List cartItems,
    bool isTablet,
    ColorScheme colorScheme,
    WidgetRef ref,
    BuildContext context,
  ) {
    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        final subtotal = item.producto.precioUnidad * item.cantidad;
        final tieneDescuento = item.esDescuentoEspecial;

        return Dismissible(
          key: ValueKey(item.producto.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: redError,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          confirmDismiss: (direction) async {
            HapticFeedback.lightImpact();
            return await _confirmarEliminarProducto(
              context,
              item.producto.nombre,
            );
          },
          onDismissed: (direction) {
            ref
                .read(cartProvider.notifier)
                .eliminarItemPorId(item.producto.id.toString());
            _mostrarDialogoEliminado(context, item.producto.nombre);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(isTablet ? 20 : 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.producto.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 20 : 15,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tieneDescuento) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Dscto.',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (tieneDescuento) ...[
                            Text(
                              '\$${item.precioOriginal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '${item.cantidad.toStringAsFixed(item.producto.esPesado ? 3 : 0)} x \$${item.producto.precioUnidad.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: tieneDescuento
                                  ? const Color(0xFFF59E0B)
                                  : colorScheme.onSurfaceVariant,
                              fontSize: isTablet ? 16 : 13,
                              fontWeight: tieneDescuento
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 20 : 16,
                        color: tieneDescuento
                            ? const Color(0xFFF59E0B)
                            : primaryGreen,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: isTablet ? 28 : 22),
                  color: redError,
                  hoverColor: Colors.red.withValues(alpha: 0.1),
                  splashColor: Colors.red.withValues(alpha: 0.2),
                  tooltip: 'Eliminar producto',
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final confirmado = await _confirmarEliminarProducto(
                      context,
                      item.producto.nombre,
                    );
                    if (confirmado == true) {
                      ref
                          .read(cartProvider.notifier)
                          .eliminarItemPorId(item.producto.id.toString());
                      if (context.mounted) {
                        _mostrarDialogoEliminado(
                            context, item.producto.nombre);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- TOTALES Y BOTÓN COBRAR ----------
  Widget _buildTotals(
    CartState cartState,
    BcvController bcvController, // ✅ Firma cambiada
    bool hasItems,
    bool isTablet,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    return Column(
      children: [
        // ✅ Botón IVA
        Row(
          children: [
            IvaToggleButton(expandido: false),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                cartState.configIva.codigoPais,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ══════════════════════════════════════════════════════════════
        // TOTAL USD
        // ══════════════════════════════════════════════════════════════
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'TOTAL USD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 20 : 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              bcvController.formatearUsd(cartState.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 30 : 20,
                color: primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // ══════════════════════════════════════════════════════════════
        // TOTAL EN MONEDA LOCAL
        // ══════════════════════════════════════════════════════════════
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'TOTAL ${bcvController.config.nombreMoneda.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              bcvController.formatearLocal(
                bcvController.usdALocal(cartState.total),
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 22 : 14,
                color: primaryGreen,
              ),
            ),
          ],
        ),

        // ══════════════════════════════════════════════════════════════
        // TOTAL EUR (si aplica)
        // ══════════════════════════════════════════════════════════════
        if (bcvController.config.manejaEuro &&
            bcvController.tasaEuro > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TOTAL EUR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                bcvController.formatearEur(
                  bcvController.usdAEur(cartState.total),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 13,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],

        // ══════════════════════════════════════════════════════════════
        // DESGLOSE DE IVA
        // ══════════════════════════════════════════════════════════════
        if (cartState.ivaHabilitado &&
            cartState.configIva.porcentajeIva > 0 &&
            cartState.items.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Base imponible',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$${cartState.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'IVA ${(cartState.configIva.porcentajeIva * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$${cartState.impuesto.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: isTablet ? 76 : 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              enabledMouseCursor: SystemMouseCursors.click,
              disabledMouseCursor: SystemMouseCursors.basic,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withValues(alpha: 0.2);
                }
                return null;
              }),
            ),
            onPressed: hasItems
                ? () {
                    Navigator.of(context).pop();
                    onCobrar();
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_outlined, size: isTablet ? 32 : 24),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'COBRAR ORDEN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 24 : 18,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- DIÁLOGOS ----------
  void _confirmarLimpiar(BuildContext parentContext, WidgetRef ref) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Limpiar carrito'),
          content:
              const Text('¿Seguro que deseas eliminar todos los productos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).limpiarCarrito();
                Navigator.of(dialogContext).pop();
                if (parentContext.mounted) {
                  Navigator.of(parentContext).pop();
                }
              },
              style: TextButton.styleFrom(foregroundColor: redError),
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmarEliminarProducto(
    BuildContext parentContext,
    String nombre,
  ) {
    return showDialog<bool>(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que deseas eliminar "$nombre" del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: redError),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminado(BuildContext context, String nombre) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Producto eliminado'),
          content: Text('Se ha eliminado "$nombre" del carrito.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(dialogContext).colorScheme.primary,
              ),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}