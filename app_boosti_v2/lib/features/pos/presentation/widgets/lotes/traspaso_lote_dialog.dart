// lib/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class TraspasoLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const TraspasoLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<TraspasoLoteDialog> createState() =>
      _TraspasoLoteDialogState();
}

class _TraspasoLoteDialogState extends ConsumerState<TraspasoLoteDialog> {
  final IsarService _isar = IsarService();
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  static const _colorSuccess = Color(0xFF10B981);
  static const _colorWarning = Color(0xFFF59E0B);

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
    if (cantidad == null ||
        cantidad <= 0 ||
        cantidad > widget.lote.cantidadRestante) {
      setState(() => _errorMessage = 'Cantidad inválida');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) throw Exception('Usuario no autenticado');

      if (await _isar.descontarLote(widget.lote.id, cantidad)) {
        final producto =
            await _isar.obtenerProductoPorId(widget.lote.productoId);
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

        ref.read(invalidationProvider).invalidarStock();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('$cantidad unidades repuestas al inventario'),
            backgroundColor: _colorSuccess,
          ),
        );
        Navigator.pop(context, true);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GlassDialog(
      maxWidth: 440,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.swap_horiz_rounded,
              title: 'Reponer inventario',
              subtitle: 'Mueve stock del lote al inventario general',
              color: _colorWarning,
            ),
            const SizedBox(height: 18),

            // ===== INFO =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  _infoRow('Producto ID', '${widget.lote.productoId}',
                      colorScheme),
                  const SizedBox(height: 6),
                  _infoRow('Disponible',
                      '${widget.lote.cantidadRestante} kg', colorScheme,
                      highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== CANTIDAD =====
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Cantidad a reponer *',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon:
                    const Icon(Icons.numbers, color: _colorSuccess),
                errorText: _errorMessage,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _colorSuccess, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== BOTONES =====
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MouseRegion(
                    cursor: _isLoading
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Reponer',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorScheme colorScheme,
      {bool highlight = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 15 : 13,
              color: highlight ? _colorSuccess : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}