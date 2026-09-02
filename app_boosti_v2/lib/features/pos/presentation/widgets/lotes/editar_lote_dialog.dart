// lib/features/pos/presentation/widgets/lotes/editar_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart';

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
  final FocusNode _vencimientoFocus = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  String? _productoNombre;

  @override
  void initState() {
    super.initState();
    _codigoController.text = widget.lote.codigoBarrasLote ?? '';
    _cargarProductoNombre();

    if (widget.lote.fechaVencimiento != null) {
      final date = widget.lote.fechaVencimiento!;
      _vencimientoController.text = _formatDate(date);
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _vencimientoController.dispose();
    _vencimientoFocus.dispose();
    super.dispose();
  }

  Future<void> _cargarProductoNombre() async {
    final producto = await _isar.obtenerProductoPorId(widget.lote.productoId);
    if (mounted) {
      setState(() {
        _productoNombre = producto?.nombre ?? 'Producto #${widget.lote.productoId}';
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DateTime? _parseDate(String text) {
    final parts = text.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) return null;
    return DateTime(year, month, day);
  }

  // ✅ MÁSCARA DE FECHA AUTOMÁTICA
  void _applyDateMask(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = '';
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digits[i];
    }
    if (digits.length >= 8) {
      // Asegurar que los últimos 4 dígitos sean el año
      final day = digits.substring(0, 2);
      final month = digits.substring(2, 4);
      final year = digits.substring(4, 8);
      formatted = '$day/$month/$year';
    }
    if (_vencimientoController.text != formatted) {
      _vencimientoController.text = formatted;
      _vencimientoController.selection = TextSelection.fromPosition(
        TextPosition(offset: _vencimientoController.text.length),
      );
    }
  }

  Future<void> _escanearCodigo() async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo != null && codigo.isNotEmpty) {
      _codigoController.text = codigo;
    }
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);

    // Validar código (opcional)
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      setState(() {
        _errorMessage = 'El código de barras es obligatorio';
        _isLoading = false;
      });
      return;
    }

    // Validar fecha
    DateTime? nuevaFecha;
    if (_vencimientoController.text.isNotEmpty) {
      nuevaFecha = _parseDate(_vencimientoController.text);
      if (nuevaFecha == null) {
        setState(() {
          _errorMessage = 'Formato de fecha inválido. Usa DD/MM/AAAA';
          _isLoading = false;
        });
        return;
      }
      // Validar que la fecha no sea en el pasado
      if (nuevaFecha.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        setState(() {
          _errorMessage = 'La fecha de vencimiento no puede ser en el pasado';
          _isLoading = false;
        });
        return;
      }
    }

    try {
      final lote = widget.lote;
      lote.codigoBarrasLote = codigo;
      lote.fechaVencimiento = nuevaFecha;
      lote.sincronizado = false;

      await _isar.guardarLote(lote);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Lote actualizado correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
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
            const SizedBox(height: 8),
            // Mostrar nombre del producto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_rounded, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _productoNombre ?? 'Cargando...',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Código de barras con botón de escaneo
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código de barras *',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _escanearCodigo,
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF10B981)),
                  tooltip: 'Escanear código',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fecha de vencimiento con máscara automática
            TextField(
              controller: _vencimientoController,
              focusNode: _vencimientoFocus,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fecha de vencimiento (DD/MM/AAAA)',
                prefixIcon: const Icon(Icons.calendar_today),
                hintText: '__/__/____',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _errorMessage,
              ),
              onChanged: (value) {
                _applyDateMask(value);
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              inputFormatters: [
                // Solo permitir dígitos y barras (la máscara se encarga)
              ],
            ),
            const SizedBox(height: 8),

            // Mensaje de ayuda para la fecha
            Text(
              'Formato: DD/MM/AAAA. Ej: 31/12/2025',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Botones
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