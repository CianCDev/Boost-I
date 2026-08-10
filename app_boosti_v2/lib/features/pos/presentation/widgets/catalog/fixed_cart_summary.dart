import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../utils/responsive_helper.dart';

class FixedCartSummary extends ConsumerWidget {
  final VoidCallback onCobrar;

  const FixedCartSummary({super.key, required this.onCobrar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final bcvTasa = ref.watch(bcvProvider).tasa;
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      height: isTablet ? 140.0 : 120.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: isTablet ? 2 : 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total: \$${cartState.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 28 : 17,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bs. ${(cartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 13,
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (cartState.items.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                ),
                child: Text(
                  '${cartState.items.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFDC2626)),
                ),
              ),
            SizedBox(
              height: isTablet ? 66 : 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 12, vertical: 12),
                ),
                onPressed: cartState.items.isEmpty ? null : () => _openCartBottomSheet(context, ref, onCobrar),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Ver Carrito',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCartBottomSheet(BuildContext context, WidgetRef ref, VoidCallback onCobrar) {
    final isTablet = ResponsiveHelper.isTablet(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Consumer(
              builder: (context, ref, child) {
                final currentCartState = ref.watch(cartProvider);
                final bcvTasa = ref.watch(bcvProvider).tasa;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mi Carrito',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          children: [
                            if (currentCartState.items.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.refresh_outlined, color: Color(0xFFEF4444), size: 28),
                                tooltip: 'Reiniciar Venta',
                                splashRadius: 28,
                                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                onPressed: () {
                                  // Aquí puedes llamar a un diálogo de confirmación
                                  ref.read(cartProvider.notifier).limpiarCarrito();
                                  Navigator.of(context).pop();
                                },
                              ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 28),
                              splashRadius: 28,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    Expanded(
                      child: currentCartState.items.isEmpty
                          ? const Center(
                              child: Text(
                                'El carrito está vacío',
                                style: TextStyle(fontSize: 18, color: Color(0xFF94A3B8)),
                              ),
                            )
                          : ListView.separated(
                              itemCount: currentCartState.items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = currentCartState.items[index];
                                final subtotal = item.producto.precioUnidad * item.cantidad;
                                return Container(
                                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                      width: isTablet ? 2 : 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.producto.nombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isTablet ? 20 : 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${item.cantidad.toStringAsFixed(item.producto.esPesado ? 3 : 0)} x \$${item.producto.precioUnidad.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: const Color(0xFF64748B),
                                                fontSize: isTablet ? 16 : 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\$${subtotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 20 : 17,
                                          color: const Color(0xFF059669),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      InkWell(
                                        onTap: () {
                                          ref.read(cartProvider.notifier).eliminarItem(index);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: EdgeInsets.all(isTablet ? 12 : 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.red.shade200),
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: Colors.redAccent,
                                            size: isTablet ? 28 : 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(thickness: 2),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL USD',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 20 : 14,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '\$${currentCartState.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 30 : 20,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL BOLÍVARES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 18 : 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              'Bs. ${(currentCartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 22 : 14,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 76 : 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              side: const BorderSide(color: Color(0xFF059669), width: 1.5),
                            ),
                            onPressed: currentCartState.items.isEmpty
                                ? null
                                : () {
                                    // ✅ CERRAR BOTTOM SHEET Y LLAMAR AL COBRO
                                    Navigator.of(context).pop();
                                    onCobrar();
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payments_outlined, size: isTablet ? 32 : 24),
                                const SizedBox(width: 16),
                                Text(
                                  'COBRAR ORDEN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 24 : 18,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}