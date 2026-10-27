// lib/features/pos/presentation/widgets/restaurante/aviso_stock_receta_dialog.dart
//
// Aviso de stock insuficiente al entregar un plato, como DIÁLOGO y no como
// SnackBar.
//
// ⚠️ POR QUÉ UN DIÁLOGO
//
// El KDS ya usa un Snackbar para "entró un pedido nuevo". Compartir el mismo
// `ScaffoldMessenger` hacía que, si se entregaba un plato con faltantes justo
// cuando entraba otro pedido, **el segundo mensaje pisara al primero**: el
// cocinero nunca se enteraba de que faltó mercancía. Y el de stock duraba 4
// segundos, en una pantalla que se mira de reojo.
//
// El diálogo no se cierra solo: el que entrega decide cuándo siguió. Es el
// mismo patrón que `ResultadoEnvioCocinaDialog` (AlertDialog plano, no
// `GlassDialog`: el vidrio compite con el texto bajo luz de cocina).
//
// ⚠️ NO BLOQUEA NADA. El plato ya está entregado y el stock ya se descontó
// (lo que había). Esto solo informa.
import 'package:flutter/material.dart';

/// Diálogo de `ResultadoDescuento.faltantes` al marcar un plato entregado.
class AvisoStockRecetaDialog {
  AvisoStockRecetaDialog._();

  /// Ámbar: es un aviso, no un error ni un éxito.
  static const _ambar = Color(0xFFF59E0B);

  /// Muestra los ingredientes que se quedaron cortos.
  ///
  /// [faltantes] viene con repetidos a propósito desde el provider: un mismo
  /// ingrediente puede quedarse corto en varios lotes seguidos y saldría dos
  /// veces. Aquí se deduplica y se ordena.
  static Future<void> mostrar(
    BuildContext context, {
    required List<String> faltantes,
  }) {
    final nombres = faltantes.toSet().toList()..sort();
    final plural = nombres.length == 1 ? 'ingrediente' : 'ingredientes';

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: _ambar),
            SizedBox(width: 8),
            Expanded(child: Text('Stock insuficiente')),
          ],
        ),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Se descontó lo que había en $plural:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: nombres.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: TextStyle(color: _ambar)),
                        Expanded(child: Text(nombres[i])),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'El plato ya salió: el stock quedó en lo que había. '
                'Revisá el inventario cuando puedas.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _ambar),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
