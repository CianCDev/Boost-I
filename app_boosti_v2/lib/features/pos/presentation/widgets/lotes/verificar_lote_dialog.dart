// lib/features/pos/presentation/widgets/lotes/verificar_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';

class VerificarLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const VerificarLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<VerificarLoteDialog> createState() =>
      _VerificarLoteDialogState();
}

class _VerificarLoteDialogState extends ConsumerState<VerificarLoteDialog> {
  final IsarService _isar = IsarService();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _codigoValidado = false;
  String? _codigoValidadoTexto;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _cantidadController.text = widget.lote.cantidadInicial.toString();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _escanearCodigo() async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo != null && codigo.isNotEmpty) {
      _codigoController.text = codigo;
      await _validarCodigo(codigo);
    }
  }

  Future<void> _validarCodigo(String codigo) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _codigoValidado = false;
    });

    try {
      final producto =
          await _isar.obtenerProductoPorId(widget.lote.productoId);
      if (producto == null) {
        setState(() {
          _errorMessage = 'Producto no encontrado';
          _isLoading = false;
        });
        return;
      }

      if (producto.codigoBarras == codigo) {
        setState(() {
          _codigoValidado = true;
          _codigoValidadoTexto = codigo;
          _isLoading = false;
        });
        return;
      }

      final alias = await _isar.obtenerAliasPorCodigo(codigo);
      if (alias != null && alias.productoId == widget.lote.productoId) {
        setState(() {
          _codigoValidado = true;
          _codigoValidadoTexto = codigo;
          _isLoading = false;
        });
        return;
      }

      if (alias == null) {
        final crearAlias = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Nuevo código de barras'),
            content: Text(
              'El código "$codigo" no está registrado.\n'
              '¿Deseas asociarlo a "${producto.nombre}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorSuccess,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Asociar'),
              ),
            ],
          ),
        );
        if (crearAlias == true) {
          await _isar.guardarCodigoAlias(
            CodigoBarrasAliasEntity()
              ..codigo = codigo
              ..productoId = widget.lote.productoId
              ..factor = 1.0
              ..activo = true
              ..fechaAsignacion = DateTime.now()
              ..observaciones = 'Creado desde verificación de lote'
              ..sincronizado = false,
          );
          if (!mounted) return;
          setState(() {
            _codigoValidado = true;
            _codigoValidadoTexto = codigo;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código asociado al producto'),
              backgroundColor: _colorSuccess,
            ),
          );
          return;
        } else {
          setState(() {
            _errorMessage = 'Código no validado';
            _isLoading = false;
          });
          return;
        }
      }

      if (alias.productoId != widget.lote.productoId) {
        final otroProducto =
            await _isar.obtenerProductoPorId(alias.productoId);
        setState(() {
          _errorMessage =
              'Pertenece a "${otroProducto?.nombre ?? 'otro producto'}"';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _errorMessage = 'Error inesperado';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmarVerificacion() async {
    if (!_codigoValidado) {
      setState(() => _errorMessage = 'Escanea o ingresa un código válido');
      return;
    }
    final cantidad = double.tryParse(_cantidadController.text);
    if (cantidad == null ||
        cantidad <= 0 ||
        cantidad > widget.lote.cantidadInicial) {
      setState(() => _errorMessage = 'Cantidad inválida');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) throw Exception('Usuario no autenticado');

      final exito = await _isar.verificarLote(
        loteId: widget.lote.id,
        codigoBarras: _codigoValidadoTexto!,
        cantidadRecibida: cantidad,
        usuarioId: usuario.id,
      );

      if (!mounted) return;
      if (exito) {
        ref.read(invalidationProvider).invalidarStock();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Lote activado correctamente'),
            backgroundColor: _colorSuccess,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = 'Error al activar el lote';
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
      maxWidth: 500,
      maxHeightFactor: 0.85,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Verificar Lote',
              subtitle: 'Escanea el código y confirma la cantidad',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto ID: ${widget.lote.productoId}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantidad esperada: ${widget.lote.cantidadInicial} kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (widget.lote.fechaVencimiento != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Vence: ${widget.lote.fechaVencimiento!.day}/${widget.lote.fechaVencimiento!.month}/${widget.lote.fechaVencimiento!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
                    onChanged: (value) {
                      if (_codigoValidado) {
                        setState(() {
                          _codigoValidado = false;
                          _codigoValidadoTexto = null;
                        });
                      }
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    onPressed: _isLoading ? null : _escanearCodigo,
                    icon: const Icon(Icons.qr_code_scanner_rounded,
                        size: 32, color: _colorSuccess),
                  ),
                ),
              ],
            ),

            // ===== VALIDACIÓN =====
            if (_codigoValidado) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(
                  label: 'Código validado: $_codigoValidadoTexto',
                  color: _colorSuccess,
                  icon: Icons.check_circle_rounded,
                  size: StatusBadgeSize.medium,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // ===== CANTIDAD =====
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Cantidad recibida *',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon:
                    const Icon(Icons.numbers, color: _colorPrimary),
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
                  borderSide: const BorderSide(color: _colorPrimary, width: 2),
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
                      onPressed:
                          _isLoading ? null : _confirmarVerificacion,
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
}