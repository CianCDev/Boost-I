// lib/features/pos/presentation/widgets/lotes/editar_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

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

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _codigoController.text = widget.lote.codigoLoteProveedor ?? '';
    _cargarProductoNombre();

    if (widget.lote.fechaVencimiento != null) {
      _vencimientoController.text =
          _formatDate(widget.lote.fechaVencimiento!);
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
    final producto =
        await _isar.obtenerProductoPorId(widget.lote.productoId);
    if (mounted) {
      setState(() {
        _productoNombre =
            producto?.nombre ?? 'Producto #${widget.lote.productoId}';
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  DateTime? _parseDate(String text) {
    final parts = text.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
      return null;
    }
    return DateTime(year, month, day);
  }

  void _applyDateMask(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = '';
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digits[i];
    }
    if (digits.length >= 8) {
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

    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      setState(() {
        _errorMessage = 'El código de barras es obligatorio';
        _isLoading = false;
      });
      return;
    }

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
      if (nuevaFecha
          .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        setState(() {
          _errorMessage =
              'La fecha de vencimiento no puede ser en el pasado';
          _isLoading = false;
        });
        return;
      }
    }

    try {
      final lote = widget.lote;
      lote.codigoLoteProveedor = codigo;
      lote.fechaVencimiento = nuevaFecha;
      lote.sincronizado = false;
      await _isar.guardarLote(lote);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Lote actualizado correctamente'),
          backgroundColor: _colorSuccess,
        ),
      );
      Navigator.pop(context, true);
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
      maxWidth: 480,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.edit_rounded,
              title: 'Editar Lote',
              subtitle: 'Modifica código y fecha de vencimiento',
            ),
            const SizedBox(height: 20),

            // ===== PRODUCTO =====
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_rounded,
                      color: _colorPrimary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _productoNombre ?? 'Cargando...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== CÓDIGO =====
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Código de barras *',
                      labelStyle:
                          TextStyle(color: colorScheme.onSurfaceVariant),
                      prefixIcon:
                          const Icon(Icons.qr_code, color: _colorPrimary),
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
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: _colorPrimary, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    onPressed: _escanearCodigo,
                    icon: const Icon(Icons.qr_code_scanner_rounded,
                        color: _colorSuccess, size: 28),
                    tooltip: 'Escanear código',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ===== FECHA =====
            TextField(
              controller: _vencimientoController,
              focusNode: _vencimientoFocus,
              keyboardType: TextInputType.number,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Fecha de vencimiento (DD/MM/AAAA)',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon:
                    const Icon(Icons.calendar_today, color: _colorPrimary),
                hintText: '__/__/____',
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
                  borderSide:
                      const BorderSide(color: _colorPrimary, width: 2),
                ),
                errorText: _errorMessage,
              ),
              onChanged: (value) {
                _applyDateMask(value);
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 6),
            Text(
              'Formato: DD/MM/AAAA. Ej: 31/12/2025',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
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
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
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
                      onPressed: _isLoading ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorPrimary,
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
                          : const Text('Guardar',
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
}