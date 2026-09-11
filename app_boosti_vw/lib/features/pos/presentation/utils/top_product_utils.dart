// utils/top_product_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/catalog/top_products_widget.dart';

void showTopProducts(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => TopProductsWidget(
      onClose: () => Navigator.pop(context),
    ),
  );
}