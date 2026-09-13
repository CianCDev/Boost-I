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
import '../../common/glass_dialog.dart';
import '../../common/dialog_header.dart';
import '../../common/status_badge.dart';

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
  ConsumerState<AsignarCodigoLoteDialog> createState() =>
      _AsignarCodigoLoteDialogState();
}

class _AsignarCodigoLoteDialogState
    extends ConsumerState<AsignarCodigoLoteDialog> {
  final IsarService _isar = IsarService();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _vencimientoController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  LoteEntity? _loteExistente;
  bool _codigoValido = false;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorInfo = Color(0xFF3B82F6);

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

    if (widget.lote.codigoLoteProveedor == codigoLimpio) {
      setState(() {
        _errorMessage = null;
        _loteExistente = null;
        _codigoValido = true;
      });
      return;
    }

    final aliasExistente = await _isar.obtenerAliasPorCodigo(codigoLimpio);
    if (aliasExistente != null &&
        aliasExistente.productoId != widget.lote.productoId) {
      setState(() {
        _errorMessage =
            'Este código está asignado como alias a otro producto';
        _loteExistente = null;
        _codigoValido = false;
      });
      return;
    }

    if (codigoLimpio.length >= 4) {
      final productos = await _isar.obtenerProductos();
      final productoConCodigo = productos.firstWhere(
        (p) =>
            p.codigoBarras == codigoLimpio &&
            p.id != widget.lote.productoId,
        orElse: () => ProductoEntity(),
      );
      if (productoConCodigo.id != 0) {
        if (productoConCodigo.nombre.isNotEmpty) {
          setState(() {
            _errorMessage =
                'Este código pertenece al producto "${productoConCodigo.nombre}"';
            _loteExistente = null;
            _codigoValido = false;
          });
          return;
        } else {
          setState(() {
            _errorMessage =
                'Código asignado a un producto sin nombre. Puedes usarlo.';
            _loteExistente = null;
            _codigoValido = true;
          });
          return;
        }
      }
    } else {
      setState(() {
        _errorMessage =
            'Código corto (${codigoLimpio.length} dígitos). Verifica que sea correcto.';
        _loteExistente = null;
        _codigoValido = true;
      });
      return;
    }

    final todosLosLotes = await _isar.obtenerTodosLosLotes();
    final loteEncontrado = todosLosLotes.firstWhere(
      (l) =>
          l.codigoLoteProveedor == codigoLimpio &&
          l.id != widget.lote.id,
      orElse: () => LoteEntity(),
    );

    if (loteEncontrado.id != 0) {
      if (loteEncontrado.estado == 'agotado' ||
          loteEncontrado.cantidadRestante == 0) {
        setState(() {
          _errorMessage =
              'Este código se usó en el Lote #${loteEncontrado.id} (agotado). Puedes reutilizarlo.';
          _loteExistente = loteEncontrado;
          _codigoValido = true;
        });
        return;
      }
      if (loteEncontrado.estado == 'activo' &&
          loteEncontrado.cantidadRestante > 0) {
        setState(() {
          _errorMessage =
              'Este código ya está en uso en el Lote #${loteEncontrado.id} (${loteEncontrado.cantidadRestante} kg restantes)';
          _loteExistente = loteEncontrado;
          _codigoValido = false;
        });
        return;
      }
      setState(() {
        _errorMessage =
            'Este código ya está asignado al Lote #${loteEncontrado.id} (estado: ${loteEncontrado.estado})';
        _loteExistente = loteEncontrado;
        _codigoValido = false;
      });
      return;
    }

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
    if (day < 1 ||
        day > 31 ||
        month < 1 ||
        month > 12 ||
        year < 1900 ||
        year > 2100) {
      return null;
    }
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  void _mostrarDetalleLoteExistente() {
    if (_loteExistente == null) return;
    final lote = _loteExistente!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Lote existente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: #${lote.id}'),
            Text('Estado: ${lote.estado.toUpperCase()}'),
            Text('Código: ${lote.codigoLoteProveedor ?? 'Sin asignar'}'),
            Text('Cantidad restante: ${lote.cantidadRestante} kg'),
            Text(
                'Ingreso: ${lote.fechaIngreso.day}/${lote.fechaIngreso.month}/${lote.fechaIngreso.year}'),
            if (lote.fechaVencimiento != null)
              Text(
                  'Vence: ${lote.fechaVencimiento!.day}/${lote.fechaVencimiento!.month}/${lote.fechaVencimiento!.year}'),
            if (lote.proveedorNombre != null &&
                lote.proveedorNombre!.isNotEmpty)
              Text('Proveedor: ${lote.proveedorNombre}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    final codigo = _codigoController.text.trim();
    final cantidad = double.tryParse(_cantidadController.text);

    if (codigo.isEmpty) {
      setState(() => _errorMessage = 'El código de barras es obligatorio');
      return;
    }
    if (!_codigoValido) {
      setState(() => _errorMessage = 'El código no es válido');
      return;
    }
    if (cantidad == null || cantidad <= 0) {
      setState(() => _errorMessage = 'Ingresa una cantidad válida');
      return;
    }

    DateTime? fechaVencimiento;
    final fechaTexto = _vencimientoController.text.trim();
    if (fechaTexto.isNotEmpty) {
      fechaVencimiento = _parseFechaConFormato(fechaTexto);
      if (fechaVencimiento == null) {
        setState(() => _errorMessage =
            'Fecha inválida. Usa el formato DD/MM/AAAA (ej: 31/12/2025)');
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Lote activado correctamente'),
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
      maxWidth: 520,
      maxHeightFactor: 0.9,
      scrollable: true,
      accentColor: _colorWarning,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Activar Lote #${widget.lote.id}',
              subtitle: 'Escanea el código y confirma los datos',
              color: _colorWarning,
            ),
            const SizedBox(height: 18),

            // ===== CÓDIGO =====
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _inputDecor(
                      label: 'Código de barras *',
                      icon: Icons.qr_code,
                      colorScheme: colorScheme,
                      isDark: isDark,
                      errorText: _errorMessage,
                      suffixIcon: _loteExistente != null
                          ? MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: IconButton(
                                icon: const Icon(Icons.info_outline,
                                    color: _colorInfo),
                                onPressed: _mostrarDetalleLoteExistente,
                                tooltip: 'Ver lote existente',
                              ),
                            )
                          : null,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== CANTIDAD =====
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: _inputDecor(
                label: 'Cantidad recibida *',
                icon: Icons.inventory_2_rounded,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 12),

            // ===== VENCIMIENTO =====
            TextField(
              controller: _vencimientoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FechaInputFormatter(),
              ],
              style: TextStyle(color: colorScheme.onSurface),
              decoration: _inputDecor(
                label: 'Fecha de vencimiento (DD/MM/AAAA)',
                icon: Icons.calendar_today,
                colorScheme: colorScheme,
                isDark: isDark,
                hint: '__/__/____',
              ),
              onChanged: (_) {
                if (_errorMessage != null &&
                    _errorMessage!.toLowerCase().contains('fecha')) {
                  setState(() => _errorMessage = null);
                }
              },
            ),

            // ===== BADGE DE ESTADO DEL CÓDIGO =====
            if (_errorMessage == null && _codigoValido && _codigoController.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: const StatusBadge(
                  label: 'Código válido',
                  color: _colorSuccess,
                  icon: Icons.check_circle_rounded,
                  size: StatusBadgeSize.medium,
                ),
              ),
            ],

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
                    cursor: (_isLoading || !_codigoValido)
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed:
                          (_isLoading || !_codigoValido) ? null : _guardar,
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
                          : const Text('Activar Lote',
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

  InputDecoration _inputDecor({
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    String? errorText,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: _colorPrimary),
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: _colorPrimary, width: 2),
      ),
    );
  }
}