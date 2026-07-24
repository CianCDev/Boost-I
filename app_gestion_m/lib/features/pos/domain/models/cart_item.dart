import 'product_item.dart';

class CartItem {
  final ProductItem producto;
  final double cantidad; // Puede ser 2.0 (unidades) o 1.455 (kilos)

  const CartItem({
    required this.producto,
    required this.cantidad,
  });

  // Subtotal calculado automáticamente
  double get subtotal => producto.precioUnidad * cantidad;

  CartItem copyWith({
    ProductItem? producto,
    double? cantidad,
  }) {
    return CartItem(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto': producto.toJson(),
      'cantidad': cantidad,
      'subtotal': subtotal,
    };
  }
}