import 'package:flutter/material.dart';
import 'top_products_widget.dart';

void showTopProducts(BuildContext context) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => TopProductsWidget(
      onClose: entry.remove,
    ),
  );
  overlay.insert(entry);
}
