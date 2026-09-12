// lib/features/pos/presentation/widgets/catalog/iva_toggle_button.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/themes/app_colors.dart';

/// Botón para activar/desactivar el desglose de IVA en el carrito.
///
/// ⚠️ NO cambia precios. Solo controla si el IVA se discrimina en factura.
/// El total a cobrar es siempre la suma de precios de venta.
class IvaToggleButton extends ConsumerWidget {
  /// Si `true`, ocupa todo el ancho del contenedor padre.
  final bool expandido;

  const IvaToggleButton({super.key, this.expandido = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ivaActivo = cartState.ivaHabilitado;
    final porcentaje = cartState.configIva.porcentajeIva;
    final pais = cartState.configIva.codigoPais;
    final porcentajeTexto = (porcentaje * 100).toStringAsFixed(0);

    // Colores según estado
    final Color acento = ivaActivo ? primaryGreen : Colors.grey;
    final Color texto = ivaActivo
        ? primaryGreen
        : (isDark ? Colors.white70 : Colors.black54);

    return Tooltip(
      message: ivaActivo
          ? 'Desactivar IVA ($pais $porcentajeTexto%)'
          : 'Activar IVA ($pais $porcentajeTexto%)',
      child: InkWell(
        onTap: () => notifier.toggleIva(),
        borderRadius: BorderRadius.circular(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: expandido ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                // ✅ Glassmorphism
                color: acento.withValues(alpha: isDark ? 0.12 : 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: acento.withValues(alpha: ivaActivo ? 0.45 : 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: acento.withValues(alpha: ivaActivo ? 0.15 : 0.05),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: expandido ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: expandido
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    ivaActivo
                        ? Icons.receipt_long
                        : Icons.receipt_long_outlined,
                    size: 16,
                    color: texto,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ivaActivo ? 'IVA $porcentajeTexto%' : 'Sin IVA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: texto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}