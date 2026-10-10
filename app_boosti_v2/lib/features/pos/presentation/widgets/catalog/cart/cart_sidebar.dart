// lib/features/pos/presentation/widgets/catalog/cart_sidebar.dart
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
import '../iva_toggle_button.dart';
import '../cart/parked_carts_dialog.dart';
import '../cart/save_cart_dialog.dart';
import 'cart_dialogs.dart';
import 'cart_header_action.dart';
import 'cart_item_tile.dart';
import 'cart_quantity_sheet.dart';
import 'mesa_chip.dart';


class CartSidebar extends ConsumerWidget {
  final VoidCallback onCobrar;
  final VoidCallback onLimpiar;

  const CartSidebar({
    super.key,
    required this.onCobrar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final bcvController = ref.watch(bcvProvider);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : textDark;
    final textSecondaryColor = isDark ? Colors.white70 : textMuted;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : primaryGreen.withValues(alpha: 0.30);
    final itemBgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : textMuted.withValues(alpha: 0.05);

    final Color glassBackground = isDark
        ? const Color(0xFF091120).withValues(alpha: 0.72)
        : cardLight.withValues(alpha: 0.82);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF091120).withValues(alpha: 0.80),
                      const Color(0xFF1E293B).withValues(alpha: 0.65),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.88),
                      const Color(0xFFF8FAFC).withValues(alpha: 0.75),
                    ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            border: Border(
              left: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : primaryGreen.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(-6, 0),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            color: glassBackground.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // ═══════════════════════════════════════════════════════
              // HEADER
              // ═══════════════════════════════════════════════════════
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: textSecondaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Carrito',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),

                    // Botón "Poner en espera"
                    if (cartState.items.isNotEmpty)
                      Consumer(
                        builder: (context, ref, _) {
                          final count = ref.watch(cartSessionsProvider).count;
                          final bloqueado = count >= kMaxCarritosEnEspera;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: CartHeaderAction(
                              icon: Icons.pause_circle_outline_rounded,
                              tooltip: bloqueado
                                  ? 'Límite alcanzado ($kMaxCarritosEnEspera)'
                                  : 'Poner en espera',
                              color: pumpkinSpice,
                              compact: true,
                              onPressed: bloqueado
                                  ? null
                                  : () => SaveCartDialog.mostrar(context),
                            ),
                          );
                        },
                      ),

                    // Botón "Ver carritos en espera" con badge
                    Consumer(
                      builder: (context, ref, _) {
                        final count = ref.watch(cartSessionsProvider).count;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: CartHeaderAction(
                            icon: Icons.playlist_play_rounded,
                            tooltip: 'Carritos en espera ($count)',
                            color: const Color(0xFF8B5CF6),
                            compact: true,
                            badge: count,
                            onPressed: () =>
                                ParkedCartsDialog.mostrar(context),
                          ),
                        );
                      },
                    ),

                    // Botón "Limpiar"
                    if (cartState.items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: CartHeaderAction(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Limpiar carrito',
                          color: redError,
                          compact: true,
                          onPressed: () async {
                            // Confirmación explícita antes de vaciar. Antes
                            // el botón llamaba `onLimpiar` directo, así que
                            // en desktop (sidebar) se borraba sin preguntar.
                            // El bottom sheet sí confirmaba.
                            final confirmado =
                                await confirmarLimpiarCarrito(context);
                            if (confirmado == true) onLimpiar();
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // ── R.2 Fase 1 · chip de mesa ──
              // En retail devuelve SizedBox.shrink() y no altera nada.
              const MesaChip(margin: EdgeInsets.fromLTRB(14, 2, 14, 8)),

              // ═══════════════════════════════════════════════════════
              // LISTA DE ITEMS
              // ═══════════════════════════════════════════════════════
              Expanded(
                child: cartState.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 48,
                              color:
                                  textSecondaryColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Carrito vacío',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondaryColor
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: cartState.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return CartItemTile(
                            item: item,
                            isTablet: isTablet,
                            textColor: textColor,
                            textSecondaryColor: textSecondaryColor,
                            borderColor: borderColor,
                            itemBgColor: itemBgColor,
                            onTap: () =>
                                CartQuantitySheet.mostrar(context, ref, item),
                            onDelete: () => ref
                                .read(cartProvider.notifier)
                                .eliminarItemPorId(item.producto.id),
                          );
                        },
                      ),
              ),

              // ═══════════════════════════════════════════════════════
              // TOTALES Y BOTÓN PAGAR
              // ═══════════════════════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const IvaToggleButton(),
                        const Spacer(),
                        Text(
                          cartState.configIva.codigoPais,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: textSecondaryColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total USD',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: textSecondaryColor,
                          ),
                        ),
                        Text(
                          bcvController.formatearUsd(cartState.total),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 16,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total ${bcvController.config.simboloMoneda}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: textSecondaryColor,
                          ),
                        ),
                        Text(
                          bcvController.formatearLocal(
                            bcvController.usdALocal(cartState.total),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 14,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    if (bcvController.config.manejaEuro &&
                        bcvController.tasaEuro > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total EUR',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: textSecondaryColor,
                            ),
                          ),
                          Text(
                            bcvController.formatearEur(
                              bcvController.usdAEur(cartState.total),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 16 : 14,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (cartState.ivaHabilitado &&
                        cartState.configIva.porcentajeIva > 0 &&
                        cartState.items.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: textSecondaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Base imponible',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                Text(
                                  '\$${cartState.subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'IVA ${(cartState.configIva.porcentajeIva * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                Text(
                                  '\$${cartState.impuesto.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // ═══════════════════════════════════════════════════
                    // BOTÓN COBRAR (con validación de items sin stock)
                    // ═══════════════════════════════════════════════════
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 48 : 40,
                      child: ElevatedButton(
                        onPressed: cartState.items.isEmpty
                            ? null
                            : () {
                                // 🎯 FIX: bloquear cobro si hay items sin stock
                                // `ref.read` (no `watch`): esto corre al
                                // hacer tap, fuera del build. `watch` solo
                                // es válido durante el build.
                                final productos =
                                    ref.read(productosProvider).items;
                                if (cartState.hayItemsSinStock(productos)) {
                                  _mostrarDialogoCarritoConProblemas(
                                    context,
                                    cartState,
                                    productos,
                                  );
                                  return;
                                }
                                onCobrar();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payments_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'COBRAR ORDEN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 16 : 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DIÁLOGO: CARRITO CON PROBLEMAS
  // ═══════════════════════════════════════════════════════════════════

  /// Diálogo que bloquea el cobro cuando hay items sin stock.
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
                                    color:
                                        Theme.of(ctx).colorScheme.onSurface,
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
}
