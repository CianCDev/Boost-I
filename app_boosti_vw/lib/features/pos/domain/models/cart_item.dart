// lib/features/pos/domain/models/cart_item.dart
import 'product_item.dart';

class CartItem {
  final ProductItem producto;
  final double cantidad;
  final double precioOriginal;
  final bool esDescuentoEspecial;

  // 🔥 Quitamos 'const' para permitir el inicializador condicional
  CartItem({
    required this.producto,
    required this.cantidad,
    double? precioOriginal,
    this.esDescuentoEspecial = false,
  }) : precioOriginal = precioOriginal ?? producto.precioUnidad;

  double get subtotal => producto.precioUnidad * cantidad;

  CartItem copyWith({
    ProductItem? producto,
    double? cantidad,
    double? precioOriginal,
    bool? esDescuentoEspecial,
  }) {
    return CartItem(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      precioOriginal: precioOriginal ?? this.precioOriginal,
      esDescuentoEspecial: esDescuentoEspecial ?? this.esDescuentoEspecial,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto': producto.toJson(),
      'cantidad': cantidad,
      'precioOriginal': precioOriginal,
      'esDescuentoEspecial': esDescuentoEspecial,
      'subtotal': subtotal,
    };
  }
}