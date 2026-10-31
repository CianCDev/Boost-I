import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/offline_stock_provider.dart';

class OfflineStockBanner extends ConsumerWidget {
  const OfflineStockBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(offlineStockProvider);
    if (stock.isOnline) return const SizedBox.shrink();

    final riesgos = stock.riesgoPorProducto.values;
    final (String, Color)? alerta = riesgos.contains(NivelRiesgoStock.rojo)
        ? ('Stock local agotado. Conéctate para vender.', Colors.red.shade700)
        : riesgos.contains(NivelRiesgoStock.naranja)
            ? ('Poco stock local disponible sin conexión.', Colors.deepOrange)
            : riesgos.contains(NivelRiesgoStock.ambar)
                ? ('Stock local limitado sin conexión.', Colors.amber.shade800)
                : null;

    if (alerta == null) return const SizedBox.shrink();

    final (mensaje, color) = alerta;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
