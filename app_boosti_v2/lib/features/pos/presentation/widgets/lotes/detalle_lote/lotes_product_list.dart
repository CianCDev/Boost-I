// lib/features/pos/presentation/widgets/lotes/lotes_product_list.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/lotes_group_card.dart';

class LotesProductList extends StatelessWidget {
  final List<LoteEntity> lotes;
  final String estado;
  final Function(LoteEntity) onLoteTap;
  final bool initiallyExpanded;

  const LotesProductList({
    super.key,
    required this.lotes,
    required this.estado,
    required this.onLoteTap,
    this.initiallyExpanded = false, // ✅ Por defecto cerradas
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Agrupar lotes por producto
    final Map<int, List<LoteEntity>> agrupados = {};
    for (var lote in lotes) {
      agrupados.putIfAbsent(lote.productoId, () => []).add(lote);
    }

    final keys = agrupados.keys.toList()..sort();

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: keys.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final productoId = keys[index];
        final lotesProducto = agrupados[productoId]!;
        return LotesGroupCard(
          productoId: productoId,
          lotes: lotesProducto,
          estado: estado,
          onLoteTap: onLoteTap,
          initiallyExpanded: initiallyExpanded, // ✅ Pasamos el parámetro
        );
      },
    );
  }
}