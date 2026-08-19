import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'registrar_recepcion_dialog.dart';

class AccionesPedido extends ConsumerWidget {
  final PedidoEntity pedido;
  final VoidCallback onActualizar;

  const AccionesPedido({
    super.key,
    required this.pedido,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pedido.estado == EstadoPedido.recibido || pedido.estado == EstadoPedido.cancelado) {
      return const Center(
        child: Text('Este pedido ya está finalizado', style: TextStyle(color: Colors.grey)),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => RegistrarRecepcionDialog(pedidoId: pedido.id),
            );
            if (result == true) {
              onActualizar();
            }
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Registrar Recepción'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Cancelar Pedido'),
                content: const Text('¿Estás seguro de cancelar este pedido?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sí, cancelar'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              try {
                await ref.read(cancelarPedidoProvider(pedido.id).future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Pedido cancelado')),
                  );
                }
                onActualizar();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e')),
                  );
                }
              }
            }
          },
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelar Pedido'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}