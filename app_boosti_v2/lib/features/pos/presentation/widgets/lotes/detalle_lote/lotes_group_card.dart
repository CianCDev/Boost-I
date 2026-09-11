// lib/features/pos/presentation/widgets/lotes/detalle_lote/lotes_group_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/themes/app_colors.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/asignar_codigo_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';

class LotesGroupCard extends ConsumerStatefulWidget {
  final int productoId;
  final List<LoteEntity> lotes;
  final String estado;
  final Function(LoteEntity) onLoteTap;
  final bool initiallyExpanded;

  const LotesGroupCard({
    super.key,
    required this.productoId,
    required this.lotes,
    required this.estado,
    required this.onLoteTap,
    this.initiallyExpanded = false,
  });

  @override
  ConsumerState<LotesGroupCard> createState() => _LotesGroupCardState();
}

class _LotesGroupCardState extends ConsumerState<LotesGroupCard> {
  String? _productoNombre;
  double _stockTotal = 0;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _cargarProducto();
  }

  Future<void> _cargarProducto() async {
    final isar = IsarService();
    final producto = await isar.obtenerProductoPorId(widget.productoId);
    if (producto != null) {
      setState(() {
        _productoNombre = producto.nombre;
        _stockTotal = producto.stock;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estadoColor = _getEstadoColor(widget.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del producto
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.inventory_2_rounded, color: primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _productoNombre ?? 'Producto #${widget.productoId}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: estadoColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getEstadoLabel(widget.estado),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: estadoColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.lotes.length} lotes • Stock: ${_stockTotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.lotes.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: isDark ? Colors.white54 : Colors.black54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          // Lista de lotes (expandible)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              children: widget.lotes.map((lote) {
                return _buildLoteTile(context, lote);
              }).toList(),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoteTile(BuildContext context, LoteEntity lote) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estadoLoteColor = _getEstadoLoteColor(lote.estado);

    // Calcular días restantes para vencimiento
    String diasTexto = '';
    Color diasColor = Colors.green;
    bool proximoAVencer = false;
    if (lote.fechaVencimiento != null) {
      final dias = lote.fechaVencimiento!.difference(DateTime.now()).inDays;
      if (dias < 0) {
        diasTexto = 'VENCIDO';
        diasColor = Colors.red;
        proximoAVencer = false;
      } else if (dias <= 3) {
        diasTexto = '¡$dias días!';
        diasColor = Colors.red.shade700;
        proximoAVencer = true;
      } else if (dias <= 7) {
        diasTexto = '¡$dias días!';
        diasColor = Colors.orange.shade600;
        proximoAVencer = true;
      } else if (dias <= 15) {
        diasTexto = '$dias días';
        diasColor = Colors.amber.shade600;
        proximoAVencer = false;
      } else {
        diasTexto = '$dias días';
        diasColor = Colors.green.shade600;
        proximoAVencer = false;
      }
    }

    return GestureDetector(
      onTap: () => widget.onLoteTap(lote),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: proximoAVencer ? Colors.orange.withValues(alpha: 0.5) : estadoLoteColor.withValues(alpha: 0.15),
            width: proximoAVencer ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Indicador de estado (barra lateral)
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: estadoLoteColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: estadoLoteColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Información del lote
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lote #${lote.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: estadoLoteColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lote.estado.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: estadoLoteColor,
                          ),
                        ),
                      ),
                      if (lote.fechaVencimiento != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: diasColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                size: 10,
                                color: diasColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                diasTexto,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: diasColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.qr_code, size: 12, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lote.codigoLoteProveedor ?? 'Sin asignar',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 12, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${lote.cantidadRestante} kg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: estadoLoteColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today, size: 12, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${lote.fechaIngreso.day}/${lote.fechaIngreso.month}/${lote.fechaIngreso.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      if (lote.proveedorNombre != null && lote.proveedorNombre!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.business_center_rounded, size: 12, color: isDark ? Colors.white54 : Colors.black54),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lote.proveedorNombre!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Botón de acción según estado
            if (lote.estado == 'pendiente') ...[
              Tooltip(
                message: 'Activar lote (asignar código y vencimiento)',
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (_) => AsignarCodigoLoteDialog(lote: lote),
                    );
                    if (result == true && mounted) {
                      ref.read(lotesProvider.notifier).recargar();
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                  label: const Text('Activar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Flecha de navegación (solo para lotes activos o historial)
            if (lote.estado != 'pendiente')
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange;
      case 'activo': return Colors.green;
      case 'historial': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente': return '⏳ Pendiente';
      case 'activo': return '✅ Activo';
      case 'historial': return '📋 Historial';
      default: return estado;
    }
  }

  Color _getEstadoLoteColor(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange.shade600;
      case 'activo': return Colors.green.shade600;
      case 'agotado': return Colors.red.shade600;
      case 'vencido': return Colors.purple.shade600;
      default: return Colors.grey;
    }
  }
}