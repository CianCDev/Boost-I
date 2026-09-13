import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class RegistrarRecepcionDialog extends ConsumerStatefulWidget {
  final int pedidoId;

  const RegistrarRecepcionDialog({super.key, required this.pedidoId});

  @override
  ConsumerState<RegistrarRecepcionDialog> createState() =>
      _RegistrarRecepcionDialogState();
}

class _RegistrarRecepcionDialogState
    extends ConsumerState<RegistrarRecepcionDialog> {
  final _observacionesController = TextEditingController();
  bool _isLoading = false;

  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    setState(() => _isLoading = true);
    try {
      const userId = 1;
      await ref.read(registrarRecepcionProvider((
        pedidoId: widget.pedidoId,
        usuarioId: userId,
        observaciones: _observacionesController.text,
        fechasVencimiento: null,
        costosUnitarios: null,
      )).future);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Recepción registrada correctamente'),
          backgroundColor: _colorSuccess,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Error: $e'),
          backgroundColor: _colorDanger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GlassDialog(
      maxWidth: 480,
      accentColor: _colorSuccess,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.inventory_2_rounded,
              title: 'Registrar Recepción',
              subtitle: 'Confirma la recepción de los productos',
              color: _colorSuccess,
            ),
            const SizedBox(height: 18),

            // ===== AVISO =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _colorSuccess.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _colorSuccess.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _colorSuccess.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: _colorSuccess, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Se confirmará la recepción de todos los productos del pedido.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== OBSERVACIONES =====
            TextField(
              controller: _observacionesController,
              maxLines: 3,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Observaciones (opcional)',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                hintText: 'Ej: Productos en buen estado',
                prefixIcon:
                    const Icon(Icons.note_add_rounded, color: _colorSuccess),
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
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _colorSuccess, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== BOTONES =====
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: MouseRegion(
                    cursor: _isLoading
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _confirmar,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          _isLoading ? 'Procesando...' : 'Confirmar Recepción',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}