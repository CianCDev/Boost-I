// lib/features/pos/presentation/widgets/wholesale/wholesale_authorization_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../providers/usuario_provider.dart';
import '../../providers/wholesale/wholesale_cart_provider.dart';
import '../admin_validation_dialog.dart';

/// Banner que aparece cuando hay descuentos pendientes de autorización.
///
/// Permite autorizar todos los descuentos con un solo PIN de admin.
class WholesaleAuthorizationBanner extends ConsumerWidget {
  const WholesaleAuthorizationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(wholesaleCartProvider);
    if (!cartState.requiereAutorizacion) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    // Contadores
    final itemsPendientes = cartState.itemsConDescuentoPendiente.length;
    final globalPendiente =
        cartState.descuentoGlobalPorcentaje > 0 &&
            !cartState.descuentoGlobalAutorizado;

    final totalPendientes = itemsPendientes + (globalPendiente ? 1 : 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 20,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descuentos pendientes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF59E0B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalPendientes descuento${totalPendientes == 1 ? '' : 's'} '
                      'requiere${totalPendientes == 1 ? '' : 'n'} autorización',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => _autorizarTodo(context, ref),
              icon: const Icon(Icons.verified_user_rounded, size: 18),
              label: const Text(
                'Autorizar todos',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _autorizarTodo(BuildContext context, WidgetRef ref) async {
    final autorizado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AdminValidationDialog(
        onSuccess: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );

    if (autorizado != true || !context.mounted) return;

    // Aplicar autorización a todos los descuentos
    ref.read(wholesaleCartProvider.notifier).autorizarTodosLosDescuentos(
          autorizadoPor: 'Administrador',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Descuentos autorizados'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}