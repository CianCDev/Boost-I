import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';

class RegistrarRecepcionDialog extends ConsumerStatefulWidget {
  final int pedidoId;

  const RegistrarRecepcionDialog({super.key, required this.pedidoId});

  @override
  ConsumerState<RegistrarRecepcionDialog> createState() => _RegistrarRecepcionDialogState();
}

class _RegistrarRecepcionDialogState extends ConsumerState<RegistrarRecepcionDialog> {
  final _observacionesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Recepción'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2, size: 50, color: Colors.green),
          const SizedBox(height: 8),
          const Text(
            'Confirmar recepción de todos los productos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _observacionesController,
            decoration: const InputDecoration(
              labelText: 'Observaciones (opcional)',
              border: OutlineInputBorder(),
              hintText: 'Ej: Productos en buen estado',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  try {
                    // TODO: obtener usuario actual
                    final userId = 1;
                    await ref.read(registrarRecepcionProvider(
                      (pedidoId: widget.pedidoId, usuarioId: userId, observaciones: _observacionesController.text),
                    ).future);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Recepción registrada correctamente')),
                      );
                    }
                    Navigator.pop(context, true);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error: $e')),
                      );
                    }
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirmar Recepción'),
        ),
      ],
    );
  }
}