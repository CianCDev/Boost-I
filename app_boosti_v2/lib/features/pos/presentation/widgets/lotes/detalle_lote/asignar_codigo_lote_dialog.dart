// lib/features/pos/presentation/widgets/lotes/asignar_codigo_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart';

class AsignarCodigoLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;

  const AsignarCodigoLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<AsignarCodigoLoteDialog> createState() => _AsignarCodigoLoteDialogState();
}

class _AsignarCodigoLoteDialogState extends ConsumerState<AsignarCodigoLoteDialog> {
  final IsarService _isar = IsarService();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _vencimientoController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cantidadController.text = widget.lote.cantidadInicial.toString();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _cantidadController.dispose();
    _vencimientoController.dispose();
    super.dispose();
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
    final codigo = _codigoController.text.trim();
    final cantidad = double.tryParse(_cantidadController.text);

    if (codigo.isEmpty) {
      setState(() => _errorMessage = 'El código de barras es obligatorio');
      return;
    }

    if (cantidad == null || cantidad <= 0) {
      setState(() => _errorMessage = 'Ingresa una cantidad válida');
      return;
    }

    // Validar fecha
    DateTime? fechaVencimiento;
    if (_vencimientoController.text.isNotEmpty) {
      final parts = _vencimientoController.text.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          fechaVencimiento = DateTime(year, month, day);
        }
      }
      if (fechaVencimiento == null) {
        setState(() => _errorMessage = 'Formato de fecha inválido (DD/MM/AAAA)');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) throw Exception('Usuario no autenticado');

      final lote = widget.lote;
      lote.codigoLoteProveedor = codigo;
      lote.fechaVencimiento = fechaVencimiento;
      lote.cantidadRestante = cantidad;
      lote.estado = 'activo';
      lote.sincronizado = false;

      await _isar.guardarLote(lote);

      // Registrar movimiento
      await _isar.guardarMovimientoLote(
        MovimientoLoteEntity()
          ..loteId = lote.id
          ..tipo = 'activacion'
          ..cantidad = cantidad
          ..fecha = DateTime.now()
          ..usuarioId = usuario.id
          ..observaciones = 'Lote activado con código: $codigo'
          ..sincronizado = false,
      );

      // Actualizar stock del producto
      final producto = await _isar.obtenerProductoPorId(lote.productoId);
      if (producto != null) {
        producto.stock += cantidad;
        await _isar.guardarProducto(producto);
      }

      // Invalidar providers para refrescar UI
      ref.read(invalidationProvider).invalidarStock();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Lote activado correctamente'),
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Activar Lote #${widget.lote.id}',
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

            // Código de barras con botón de escaneo
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código de barras *',
                      prefixIcon: const Icon(Icons.qr_code),
                      errorText: _errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _escanearCodigo,
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF10B981), size: 28),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cantidad recibida
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad recibida *',
                prefixIcon: const Icon(Icons.inventory_2_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Fecha de vencimiento con formato automático
            TextField(
              controller: _vencimientoController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: 'Fecha de vencimiento (DD/MM/AAAA)',
                prefixIcon: const Icon(Icons.calendar_today),
                hintText: 'Ej: 31/12/2025',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Formatear automáticamente
                final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                String formatted = '';
                for (int i = 0; i < digits.length && i < 8; i++) {
                  if (i == 2 || i == 4) formatted += '/';
                  formatted += digits[i];
                }
                if (_vencimientoController.text != formatted) {
                  _vencimientoController.text = formatted;
                  _vencimientoController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _vencimientoController.text.length),
                  );
                }
              },
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
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Activar Lote'),
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