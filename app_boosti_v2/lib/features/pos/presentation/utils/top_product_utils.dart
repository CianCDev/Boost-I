// lib/features/pos/presentation/widgets/catalog/top_products_utils.dart
import 'package:flutter/material.dart';
import '../widgets/catalog/top_products_widget.dart';

void showTopProducts(BuildContext context) {
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (ctx) => TopProductsWidget(
      onClose: () {
        entry?.remove();
        entry = null;
      },
    ),
  );
  Overlay.of(context).insert(entry!);
}