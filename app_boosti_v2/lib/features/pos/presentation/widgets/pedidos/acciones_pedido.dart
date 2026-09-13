import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'registrar_recepcion_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class AccionesPedido extends ConsumerWidget {
  final PedidoEntity pedido;
  final VoidCallback onActualizar;

  const AccionesPedido({
    super.key,
    required this.pedido,
    required this.onActualizar,
  });

  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Estado final
    if (pedido.estado == EstadoPedido.recibido ||
        pedido.estado == EstadoPedido.cancelado) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Center(
          child: Text(
            'Este pedido ya está finalizado',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (_) =>
                        RegistrarRecepcionDialog(pedidoId: pedido.id),
                  );
                  if (result == true) onActualizar();
                },
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(
                  isMobile ? 'Recibir' : 'Registrar Recepción',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorSuccess,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Cancelar Pedido'),
                      content: const Text(
                          '¿Estás seguro de cancelar este pedido?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colorDanger,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Sí, cancelar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await ref
                          .read(cancelarPedidoProvider(pedido.id).future);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('Pedido cancelado'),
                            backgroundColor: _colorSuccess,
                          ),
                        );
                      }
                      onActualizar();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('Error: $e'),
                            backgroundColor: _colorDanger,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.cancel_rounded, size: 18),
                label: Text(
                  isMobile ? 'Cancelar' : 'Cancelar Pedido',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _colorDanger,
                  side: BorderSide(
                    color: _colorDanger.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  backgroundColor: _colorDanger.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}