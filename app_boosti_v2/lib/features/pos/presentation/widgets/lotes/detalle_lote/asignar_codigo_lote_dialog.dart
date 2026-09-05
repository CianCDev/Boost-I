// lib/features/pos/presentation/widgets/lotes/detalle_lote/asignar_codigo_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart';

// ✅ Formateador de fecha con máscara DD/MM/AAAA
class FechaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) return oldValue;
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += text[i];
    }
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
  LoteEntity? _loteExistente;
  bool _codigoValido = false;

  @override
  void initState() {
    super.initState();
    _cantidadController.text = widget.lote.cantidadInicial.toString();
    _codigoController.addListener(() {
      _validarCodigoEnTiempoReal(_codigoController.text);
    });
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
      _codigoController.text = codigo.trim();
      await _validarCodigoEnTiempoReal(codigo.trim());
    }
  }

  // ✅ VALIDACIÓN FINAL (profesional y escalable)
  Future<void> _validarCodigoEnTiempoReal(String codigo) async {
    final codigoLimpio = codigo.trim();
    if (codigoLimpio.isEmpty) {
      setState(() {
        _errorMessage = null;
        _loteExistente = null;
        _codigoValido = false;
      });
      return;
    }

    // 1. Verificar si el código es el mismo que ya tiene el lote (permitir)
    if (widget.lote.codigoLoteProveedor == codigoLimpio) {
      setState(() {
        _errorMessage = null;
        _loteExistente = null;
        _codigoValido = true;
      });
      return;
    }

    // 2. Verificar alias
    final aliasExistente = await _isar.obtenerAliasPorCodigo(codigoLimpio);
    if (aliasExistente != null && aliasExistente.productoId != widget.lote.productoId) {
      setState(() {
        _errorMessage = '❌ Este código está asignado como alias a otro producto';
        _loteExistente = null;
        _codigoValido = false;
      });
      return;
    }

    // 3. Verificar si el código es el código PRINCIPAL de otro producto
    //    Solo si el código tiene al menos 4 dígitos (para evitar códigos de prueba)
    if (codigoLimpio.length >= 4) {
      final productos = await _isar.obtenerProductos();
      final productoConCodigo = productos.firstWhere(
        (p) => p.codigoBarras == codigoLimpio && p.id != widget.lote.productoId,
        orElse: () => ProductoEntity(),
      );
      
      if (productoConCodigo.id != 0) {
        // ✅ Si el producto tiene nombre, bloquear
        if (productoConCodigo.nombre.isNotEmpty) {
          setState(() {
            _errorMessage = '❌ Este código pertenece al producto "${productoConCodigo.nombre}"';
            _loteExistente = null;
            _codigoValido = false;
          });
          return;
        } else {
          // ✅ Si el producto NO tiene nombre, permitir (es un producto mal creado)
          setState(() {
            _errorMessage = '⚠️ Código asignado a un producto sin nombre. Puedes usarlo.';
            _loteExistente = null;
            _codigoValido = true;
          });
          return;
        }
      }
    } else {
      // Código muy corto (< 4 dígitos): permitir con advertencia
      setState(() {
        _errorMessage = '⚠️ Código corto (${codigoLimpio.length} dígitos). Verifica que sea correcto.';
        _loteExistente = null;
        _codigoValido = true;
      });
      return;
    }

    // 4. Verificar lotes (todos, no solo activos)
    final todosLosLotes = await _isar.obtenerTodosLosLotes();
    final loteEncontrado = todosLosLotes.firstWhere(
      (l) => l.codigoLoteProveedor == codigoLimpio && l.id != widget.lote.id,
      orElse: () => LoteEntity(),
    );

    if (loteEncontrado.id != 0) {
      // ✅ Si el lote está agotado (stock = 0) o vencido, permitir reutilizar
      if (loteEncontrado.estado == 'agotado' || loteEncontrado.cantidadRestante == 0) {
        setState(() {
          _errorMessage = '⚠️ Este código se usó en el Lote #${loteEncontrado.id} (agotado). Puedes reutilizarlo.';
          _loteExistente = loteEncontrado;
          _codigoValido = true;
        });
        return;
      }
      
      // ✅ Si el lote está activo con stock, bloquear
      if (loteEncontrado.estado == 'activo' && loteEncontrado.cantidadRestante > 0) {
        setState(() {
          _errorMessage = '❌ Este código ya está en uso en el Lote #${loteEncontrado.id} (${loteEncontrado.cantidadRestante} kg restantes)';
          _loteExistente = loteEncontrado;
          _codigoValido = false;
        });
        return;
      }
      
      // Otros estados (pendiente, etc.) - bloquear
      setState(() {
        _errorMessage = '❌ Este código ya está asignado al Lote #${loteEncontrado.id} (estado: ${loteEncontrado.estado})';
        _loteExistente = loteEncontrado;
        _codigoValido = false;
      });
      return;
    }

    // ✅ Código completamente libre
    setState(() {
      _errorMessage = null;
      _loteExistente = null;
      _codigoValido = true;
    });
  }

  DateTime? _parseFechaConFormato(String texto) {
    final digits = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 8) return null;
    
    final day = int.tryParse(digits.substring(0, 2));
    final month = int.tryParse(digits.substring(2, 4));
    final year = int.tryParse(digits.substring(4, 8));
    
    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1900 || year > 2100) return null;
    
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  Future<void> _guardar() async {
    final codigo = _codigoController.text.trim();
    final cantidad = double.tryParse(_cantidadController.text);

    if (codigo.isEmpty) {
      setState(() => _errorMessage = 'El código de barras es obligatorio');
      return;
    }

    if (!_codigoValido) {
      setState(() => _errorMessage = '⚠️ El código no es válido. Verifica el mensaje de error.');
      return;
    }

    if (cantidad == null || cantidad <= 0) {
      setState(() => _errorMessage = 'Ingresa una cantidad válida');
      return;
    }

    // Validar fecha
    DateTime? fechaVencimiento;
    final fechaTexto = _vencimientoController.text.trim();
    if (fechaTexto.isNotEmpty) {
      fechaVencimiento = _parseFechaConFormato(fechaTexto);
      if (fechaVencimiento == null) {
        setState(() => _errorMessage = 'Fecha inválida. Usa el formato DD/MM/AAAA (ej: 31/12/2025)');
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

      final producto = await _isar.obtenerProductoPorId(lote.productoId);
      if (producto != null) {
        producto.stock += cantidad;
        await _isar.guardarProducto(producto);
      }

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

  void _mostrarDetalleLoteExistente() {
    if (_loteExistente == null) return;
    final lote = _loteExistente!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lote existente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: #${lote.id}'),
            Text('Estado: ${lote.estado.toUpperCase()}'),
            Text('Código: ${lote.codigoLoteProveedor ?? 'Sin asignar'}'),
            Text('Cantidad restante: ${lote.cantidadRestante} kg'),
            Text('Ingreso: ${lote.fechaIngreso.day}/${lote.fechaIngreso.month}/${lote.fechaIngreso.year}'),
            if (lote.fechaVencimiento != null)
              Text('Vence: ${lote.fechaVencimiento!.day}/${lote.fechaVencimiento!.month}/${lote.fechaVencimiento!.year}'),
            if (lote.proveedorNombre != null && lote.proveedorNombre!.isNotEmpty)
              Text('Proveedor: ${lote.proveedorNombre}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
                      suffixIcon: _loteExistente != null
                          ? IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.blue),
                              onPressed: _mostrarDetalleLoteExistente,
                              tooltip: 'Ver lote existente',
                            )
                          : null,
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

            // Fecha de vencimiento con máscara
            TextField(
              controller: _vencimientoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FechaInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Fecha de vencimiento (DD/MM/AAAA)',
                hintText: '__/__/____',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                if (_errorMessage != null && _errorMessage!.contains('fecha')) {
                  setState(() => _errorMessage = null);
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
                    onPressed: (_isLoading || !_codigoValido) ? null : _guardar,
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