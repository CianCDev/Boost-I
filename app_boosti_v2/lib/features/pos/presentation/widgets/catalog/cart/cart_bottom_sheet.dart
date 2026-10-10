// lib/features/pos/presentation/widgets/catalog/cart_bottom_sheet.dart
import 'dart:ui';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/cart_sessions_controller.dart';
import '../../../providers/bcv_provider.dart';
import '../../../providers/productos_provider.dart';
import '../../../providers/themes/app_colors.dart';
import '../../../utils/responsive_helper.dart';
import '../../../controllers/bcv_controller.dart';
import '../iva_toggle_button.dart';
import 'cart_dialogs.dart';
import 'cart_header_action.dart';
import 'cart_item_tile.dart';
import 'cart_quantity_sheet.dart';
import 'mesa_chip.dart';
import 'parked_carts_dialog.dart';
import 'save_cart_dialog.dart';

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
                    // ── R.2 Fase 1 · chip de mesa ──
                    // En retail devuelve SizedBox.shrink().
                    const MesaChip(),
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
                        colorScheme, context, ref),
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
        child: Row(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: colorScheme.onSurfaceVariant,
              size: isTablet ? 24 : 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Mi Carrito',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Pausar (si hay items)
          if (hasItems)
            Consumer(
              builder: (context, ref, _) {
                final count = ref.watch(cartSessionsProvider).count;
                final bloqueado = count >= kMaxCarritosEnEspera;
                return CartHeaderAction(
                  icon: Icons.pause_circle_outline_rounded,
                  label: 'Poner en espera',
                  tooltip: bloqueado
                      ? 'Límite alcanzado ($kMaxCarritosEnEspera)'
                      : 'Poner en espera',
                  color: const Color(0xFFF59E0B),
                  onPressed: bloqueado
                      ? null
                      : () => SaveCartDialog.mostrar(context),
                );
              },
            ),

          // Ver carritos en espera
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(cartSessionsProvider).count;
              return CartHeaderAction(
                icon: Icons.playlist_play_rounded,
                label: 'En espera',
                tooltip: 'Carritos en espera ($count)',
                color: const Color(0xFF8B5CF6),
                badge: count,
                onPressed: () => ParkedCartsDialog.mostrar(context),
              );
            },
          ),

          // Limpiar (si hay items)
          if (hasItems)
            CartHeaderAction(
              icon: Icons.delete_outline_rounded,
              label: 'Limpiar',
              tooltip: 'Limpiar carrito',
              color: redError,
              onPressed: () async {
                final confirmado = await confirmarLimpiarCarrito(context);
                if (confirmado != true) return;
                if (!context.mounted) return;
                ref.read(cartProvider.notifier).limpiarCarrito();
                // En el bottom sheet, además, cerramos el sheet.
                Navigator.of(context).pop();
              },
            ),

          // Cerrar
          CartHeaderAction(
            icon: Icons.close_rounded,
            tooltip: 'Cerrar',
            color: colorScheme.onSurfaceVariant,
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CartItemTile(
            item: item,
            isTablet: isTablet,
            textColor: colorScheme.onSurface,
            textSecondaryColor: colorScheme.onSurfaceVariant,
            borderColor:
                colorScheme.outlineVariant.withValues(alpha: 0.5),
            itemBgColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            onTap: () => CartQuantitySheet.mostrar(context, ref, item),
            onDelete: () => ref
                .read(cartProvider.notifier)
                .eliminarItemPorId(item.producto.id),
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
    WidgetRef ref,
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
        // ═══════════════════════════════════════════════════════════
        // 🎯 FIX: bloquear cobro si hay items sin stock
        // ═══════════════════════════════════════════════════════════
        // `ref.read` (no `watch`): esto corre al hacer tap, fuera del
        // build. `watch` solo es válido durante el build.
        final productos = ref.read(productosProvider).items;
        if (cartState.hayItemsSinStock(productos)) {
          _mostrarDialogoCarritoConProblemas(context, cartState, productos);
          return;
        }
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

}
/// Diálogo que bloquea el cobro cuando hay items sin stock en el carrito.
///
/// Lista los productos problemáticos y pide al usuario eliminarlos
/// manualmente antes de proceder al cobro.
void _mostrarDialogoCarritoConProblemas(
  BuildContext context,
  CartState cartState,
  List<ProductoEntity> productos,
) {
  final itemsConProblema = cartState.itemsSinStock(productos);

  showDialog<void>(
    context: context,
    builder: (ctx) => GlassDialog(
      maxWidth: 460,
      accentColor: redError,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: redError.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: redError,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Carrito con problemas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Mensaje ──
            Text(
              'Hay ${itemsConProblema.length} producto(s) sin stock '
              'en el carrito. Elimínalos para continuar con el cobro.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // ── Lista de items con problema ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: redError.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: redError.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: itemsConProblema
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              size: 16,
                              color: redError,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.producto.nombre,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(ctx)
                                      .colorScheme
                                      .onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '× ${item.cantidad.toStringAsFixed(item.producto.esPesado ? 3 : 0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: redError,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 22),

            // ── Botón cerrar ──
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: redError,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
