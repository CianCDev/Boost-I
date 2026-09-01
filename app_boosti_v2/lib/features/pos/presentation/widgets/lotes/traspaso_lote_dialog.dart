// lib/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart';

class TraspasoLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const TraspasoLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<TraspasoLoteDialog> createState() => _TraspasoLoteDialogState();
}

class _TraspasoLoteDialogState extends ConsumerState<TraspasoLoteDialog> {
  final IsarService _isar = IsarService();
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cantidadController.text = widget.lote.cantidadRestante.toString();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final cantidad = double.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0 || cantidad > widget.lote.cantidadRestante) {
      setState(() => _errorMessage = 'Cantidad inválida');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) throw Exception('Usuario no autenticado');

      if (await _isar.descontarLote(widget.lote.id, cantidad)) {
        final producto = await _isar.obtenerProductoPorId(widget.lote.productoId);
        if (producto != null) {
          producto.stock += cantidad;
          await _isar.guardarProducto(producto);
        }
        await _isar.guardarMovimientoLote(
          MovimientoLoteEntity()
            ..loteId = widget.lote.id
            ..tipo = 'traspaso'
            ..cantidad = cantidad
            ..fecha = DateTime.now()
            ..usuarioId = usuario.id
            ..observaciones = 'Traspaso manual a inventario'
            ..sincronizado = false,
        );

        // 🔥 Invalidar todos los providers que dependen del stock
        ref.read(invalidationProvider).invalidarStock();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $cantidad unidades repuestas al inventario'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = 'Error al descontar del lote';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reponer inventario',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 100, child: Text('Producto ID')),
                      Expanded(
                        child: Text(
                          '${widget.lote.productoId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 100, child: Text('Disponible')),
                      Expanded(
                        child: Text(
                          '${widget.lote.cantidadRestante}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cantidadController,
              decoration: InputDecoration(
                labelText: 'Cantidad a reponer *',
                errorText: _errorMessage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Reponer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}