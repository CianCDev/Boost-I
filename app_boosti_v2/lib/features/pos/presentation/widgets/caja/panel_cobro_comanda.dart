// lib/features/pos/presentation/widgets/caja/panel_cobro_comanda.dart
//
// Detalle de una comanda desde la caja del cajero.
//
// ⚠️ El panel NO cobra. Solo enseña el consumo y devuelve `true` si el
// cajero quiere cobrar. La ejecución vive en `CajaScreen`, que es la única
// que conoce el carrito, el provider de comandas y el modal de cobro. Si el
// panel cobrara, habría dos sitios abriendo `mostrarModalCobro` con estados
// distintos del carrito.
import 'package:flutter/material.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';

import '../../utils/comanda_cobro_utils.dart';
import '../../utils/duracion_utils.dart';

/// Diálogo con el consumo de una comanda y el botón "Cobrar".
class PanelCobroComanda {
  PanelCobroComanda._();

  /// Devuelve `true` si el cajero pulsa "Cobrar".
  static Future<bool?> mostrar(
    BuildContext context, {
    required CartSessionEntity comanda,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => _PanelCobro(comanda: comanda),
    );
  }
}

class _PanelCobro extends StatelessWidget {
  final CartSessionEntity comanda;

  const _PanelCobro({required this.comanda});

  static const _verde = Color(0xFF10B981);
  static const _ambar = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final enCocina = ComandaCobroUtils.enCocina(comanda);
    final listos = ComandaCobroUtils.listos(comanda);
    final sinEnviar = ComandaCobroUtils.sinEnviar(comanda);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cabecera ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _ambar.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_restaurant_rounded,
                      color: _ambar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comanda.mesaNombre ?? 'Para llevar',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _subtitulo(comanda, listos),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Avisos de cocina ──
            if (enCocina > 0 || sinEnviar > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    if (sinEnviar > 0)
                      _Aviso(
                        color: theme.colorScheme.outline,
                        icon: Icons.outbox_outlined,
                        texto: sinEnviar == 1
                            ? '1 plato todavía no se envió a cocina.'
                            : '$sinEnviar platos todavía no se enviaron '
                                'a cocina.',
                      ),
                    if (enCocina > 0) ...[
                      if (sinEnviar > 0) const SizedBox(height: 6),
                      _Aviso(
                        color: _ambar,
                        icon: Icons.soup_kitchen_outlined,
                        texto: enCocina == 1
                            ? '1 plato sigue en cocina.'
                            : '$enCocina platos siguen en cocina.',
                      ),
                    ],
                  ],
                ),
              ),

            // ── Platos ──
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                itemCount: comanda.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (_, i) => _FilaPlato(item: comanda.items[i]),
              ),
            ),

            const Divider(height: 1),

            // ── Total + acciones ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$${comanda.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Volver'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _verde),
                    onPressed: comanda.items.isEmpty
                        ? null
                        : () => Navigator.pop(context, true),
                    icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                    label: const Text('Cobrar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _subtitulo(CartSessionEntity comanda, int listos) {
    final partes = <String>[];
    if (comanda.meseroNombre != null && comanda.meseroNombre!.isNotEmpty) {
      partes.add(comanda.meseroNombre!);
    }
    partes.add(DuracionUtils.hace(comanda.createdAt));
    if (listos > 0) {
      partes.add(listos == 1 ? '1 listo' : '$listos listos');
    }
    return partes.join(' · ');
  }
}

class _FilaPlato extends StatelessWidget {
  final CartSessionItem item;

  const _FilaPlato({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorEstado(item.estadoPlato, item.pausado);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Text(
              _cantidad(item.cantidad),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productoNombre),
                if (item.nota != null && item.nota!.isNotEmpty)
                  Text(
                    item.nota!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _etiquetaEstado(item.estadoPlato, item.pausado),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 66,
            child: Text(
              '\$${(item.precioUnidad * item.cantidad).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static String _cantidad(double valor) {
    if (valor == valor.roundToDouble()) return valor.toInt().toString();
    return valor.toStringAsFixed(3);
  }

  static Color _colorEstado(EstadoPlato estado, bool pausado) {
    if (pausado) return const Color(0xFFEF4444);
    switch (estado) {
      case EstadoPlato.pendiente:
        return const Color(0xFF94A3B8);
      case EstadoPlato.enCola:
        return const Color(0xFFF59E0B);
      case EstadoPlato.enPreparacion:
        return const Color(0xFFF97316);
      case EstadoPlato.listo:
        return const Color(0xFF10B981);
      case EstadoPlato.entregado:
        return const Color(0xFF3B82F6);
      case EstadoPlato.cancelado:
        return const Color(0xFFEF4444);
    }
  }

  static String _etiquetaEstado(EstadoPlato estado, bool pausado) {
    if (pausado) return 'Pausado';
    switch (estado) {
      case EstadoPlato.pendiente:
        return 'Sin enviar';
      case EstadoPlato.enCola:
        return 'En cola';
      case EstadoPlato.enPreparacion:
        return 'Preparando';
      case EstadoPlato.listo:
        return 'Listo';
      case EstadoPlato.entregado:
        return 'Entregado';
      case EstadoPlato.cancelado:
        return 'Cancelado';
    }
  }
}

class _Aviso extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String texto;

  const _Aviso({
    required this.color,
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }
}
