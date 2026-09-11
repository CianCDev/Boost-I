// lib/features/pos/presentation/widgets/lotes/lote_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

class LoteCard extends StatelessWidget {
  final LoteEntity lote;
  final bool esAdmin;
  final VoidCallback onTap;
  final VoidCallback? onVerificar;
  final VoidCallback? onReponer;
  final bool isProximoAVencer;

  const LoteCard({
    super.key,
    required this.lote,
    required this.esAdmin,
    required this.onTap,
    this.onVerificar,
    this.onReponer,
    this.isProximoAVencer = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Theme.of(context).brightness == Brightness.dark;

    final estadoColor = _getEstadoColor(lote.estado);
    final estadoTexto = _getEstadoTexto(lote.estado);
    final estadoIcon = _getEstadoIcon(lote.estado);

    final fechaIngreso = DateFormat('dd/MM/yyyy HH:mm').format(lote.fechaIngreso);
    final fechaVencimiento = lote.fechaVencimiento != null
        ? DateFormat('dd/MM/yyyy').format(lote.fechaVencimiento!)
        : 'Sin vencimiento';

    // Calcular días hasta vencimiento (para mostrar advertencia)
    String? diasRestantes;
    Color? diasColor;
    if (lote.fechaVencimiento != null) {
      final dias = lote.fechaVencimiento!.difference(DateTime.now()).inDays;
      if (dias <= 0) {
        diasRestantes = 'VENCIDO';
        diasColor = Colors.red;
      } else if (dias <= 7) {
        diasRestantes = '¡$dias días!';
        diasColor = Colors.orange;
      } else if (dias <= 30) {
        diasRestantes = '$dias días';
        diasColor = Colors.blue;
      } else {
        diasRestantes = '$dias días';
        diasColor = colorScheme.onSurfaceVariant;
      }
    }

    return FutureBuilder<ProductoEntity?>(
      future: IsarService().obtenerProductoPorId(lote.productoId),
      builder: (context, snapshot) {
        final productoNombre = snapshot.data?.nombre ?? 'Producto #${lote.productoId}';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isProximoAVencer
                  ? Colors.orange.shade400
                  : lote.estado == 'pendiente'
                      ? Colors.orange.shade200
                      : estadoColor,
              width: isProximoAVencer ? 2 : 1,
            ),
          ),
          color: colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Producto + Estado
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          productoNombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: estadoColor, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(estadoIcon, size: 14, color: estadoColor),
                            const SizedBox(width: 4),
                            Text(
                              estadoTexto,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: estadoColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Código de barras del lote
                  if (lote.codigoBarrasLote != null && lote.codigoBarrasLote!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.qr_code, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Código: ${lote.codigoBarrasLote}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                  // Cantidades
                  Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Inicial: ${lote.cantidadInicial} | Restante: ${lote.cantidadRestante}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // Fechas
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Ingreso: $fechaIngreso',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.event_available_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Vence: $fechaVencimiento',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Badge de días restantes (si aplica)
                      if (diasRestantes != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (diasColor ?? colorScheme.primary).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (diasColor ?? colorScheme.primary).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            diasRestantes,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: diasColor ?? colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Botones de acción
                  if (onVerificar != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onVerificar,
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                        label: const Text('Verificar y Activar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  if (onVerificar == null && (onReponer != null || isProximoAVencer))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onTap,
                          child: Text(
                            'Ver Detalle',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                        if (onReponer != null) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: onReponer,
                            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                            label: const Text('Reponer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        if (isProximoAVencer && onReponer == null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Próximo a vencer',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange.shade600;
      case 'activo':
        return Colors.green.shade600;
      case 'agotado':
        return Colors.red.shade600;
      case 'vencido':
        return Colors.purple.shade600;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'activo':
        return 'Activo';
      case 'agotado':
        return 'Agotado';
      case 'vencido':
        return 'Vencido';
      default:
        return estado;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.hourglass_top_rounded;
      case 'activo':
        return Icons.check_circle_rounded;
      case 'agotado':
        return Icons.cancel_rounded;
      case 'vencido':
        return Icons.warning_amber_rounded;
      default:
        return Icons.circle_rounded;
    }
  }
}