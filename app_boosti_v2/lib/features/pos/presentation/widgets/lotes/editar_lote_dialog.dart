// lib/features/pos/presentation/widgets/lotes/editar_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

class EditarLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const EditarLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<EditarLoteDialog> createState() => _EditarLoteDialogState();
}

class _EditarLoteDialogState extends ConsumerState<EditarLoteDialog> {
  final IsarService _isar = IsarService();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _vencimientoController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _codigoController.text = widget.lote.codigoBarrasLote ?? '';
    if (widget.lote.fechaVencimiento != null) {
      final date = widget.lote.fechaVencimiento!;
      _vencimientoController.text = '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _vencimientoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);
    try {
      // Validar fecha
      DateTime? nuevaFecha;
      if (_vencimientoController.text.isNotEmpty) {
        final parts = _vencimientoController.text.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            nuevaFecha = DateTime(year, month, day);
          }
        }
      }

      // Actualizar lote
      final lote = widget.lote;
      lote.codigoBarrasLote = _codigoController.text.trim().isNotEmpty
          ? _codigoController.text.trim()
          : null;
      lote.fechaVencimiento = nuevaFecha;
      lote.sincronizado = false;

      await _isar.guardarLote(lote);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Lote actualizado'), backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context, true);
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
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Editar Lote',
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
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código de barras del lote',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vencimientoController,
              decoration: const InputDecoration(
                labelText: 'Fecha de vencimiento (dd/mm/aaaa)',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                hintText: 'Ej: 31/12/2025',
              ),
              keyboardType: TextInputType.datetime,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
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
                    onPressed: _isLoading ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar'),
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