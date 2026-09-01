// lib/features/pos/presentation/widgets/lotes/verificar_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart';

class VerificarLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const VerificarLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<VerificarLoteDialog> createState() => _VerificarLoteDialogState();
}

class _VerificarLoteDialogState extends ConsumerState<VerificarLoteDialog> {
  final IsarService _isar = IsarService();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _codigoValidado = false;
  String? _codigoValidadoTexto;

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
      final producto = await _isar.obtenerProductoPorId(widget.lote.productoId);
      if (producto == null) {
        setState(() {
          _errorMessage = 'Producto no encontrado';
          _isLoading = false;
        });
        return;
      }

      // 1. Coincide con código principal
      if (producto.codigoBarras == codigo) {
        setState(() {
          _codigoValidado = true;
          _codigoValidadoTexto = codigo;
          _isLoading = false;
        });
        return;
      }

      // 2. Existe como alias para este producto
      final alias = await _isar.obtenerAliasPorCodigo(codigo);
      if (alias != null && alias.productoId == widget.lote.productoId) {
        setState(() {
          _codigoValidado = true;
          _codigoValidadoTexto = codigo;
          _isLoading = false;
        });
        return;
      }

      // 3. No existe, preguntar si crear alias
      if (alias == null) {
        final crearAlias = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Nuevo código de barras'),
            content: Text(
              'El código "$codigo" no está registrado.\n'
              '¿Deseas asociarlo a "${producto.nombre}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
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
          setState(() {
            _codigoValidado = true;
            _codigoValidadoTexto = codigo;
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Código asociado al producto'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
          return;
        } else {
          setState(() {
            _errorMessage = 'Código no validado';
            _isLoading = false;
          });
          return;
        }
      }

      // 4. Pertenece a otro producto
      if (alias != null && alias.productoId != widget.lote.productoId) {
        final otroProducto = await _isar.obtenerProductoPorId(alias.productoId);
        setState(() {
          _errorMessage = 'Pertenece a "${otroProducto?.nombre ?? 'otro producto'}"';
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
    if (cantidad == null || cantidad <= 0 || cantidad > widget.lote.cantidadInicial) {
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

      if (mounted) {
        if (exito) {
          // 🔥 Invalidar todos los providers que dependen del stock
          ref.read(invalidationProvider).invalidarStock();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Lote activado correctamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = 'Error al activar el lote';
            _isLoading = false;
          });
        }
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
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        color: colorScheme.surface,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verificar Lote',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Producto ID: ${widget.lote.productoId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Cantidad esperada: ${widget.lote.cantidadInicial}'),
                    if (widget.lote.fechaVencimiento != null)
                      Text(
                        'Vence: ${widget.lote.fechaVencimiento!.day}/${widget.lote.fechaVencimiento!.month}/${widget.lote.fechaVencimiento!.year}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codigoController,
                      decoration: InputDecorationHelper.build(
                        context: context,
                        label: 'Código de barras *',
                        prefixIcon: Icons.qr_code,
                        isDark: isDark,
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
                  IconButton(
                    onPressed: _isLoading ? null : _escanearCodigo,
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 32, color: Color(0xFF10B981)),
                  ),
                ],
              ),
              if (_codigoValidado)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '✅ Código validado: $_codigoValidadoTexto',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _cantidadController,
                decoration: InputDecorationHelper.build(
                  context: context,
                  label: 'Cantidad recibida *',
                  prefixIcon: Icons.numbers,
                  isDark: isDark,
                  errorText: _errorMessage,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmarVerificacion,
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
      ),
    );
  }
}