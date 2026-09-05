import 'product_item.dart';

class CartItem {
  final ProductItem producto;
  final double cantidad; // Puede ser 2.0 (unidades) o 1.455 (kilos)
  final double? precioEspecial;

  const CartItem({
    required this.producto,
    required this.cantidad,
    this.precioEspecial,
  });

  double get precioUnitario => precioEspecial ?? producto.precioUnidad;
  bool get esDescuentoEspecial =>
      precioEspecial != null && precioEspecial! < producto.precioUnidad;
  double get descuentoUnitario =>
      esDescuentoEspecial ? producto.precioUnidad - precioEspecial! : 0.0;

  // Subtotal calculado automáticamente
  double get subtotal => precioUnitario * cantidad;

  CartItem copyWith({
    ProductItem? producto,
    double? cantidad,
    double? precioEspecial,
    bool quitarPrecioEspecial = false,
  }) {
    return CartItem(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      precioEspecial: quitarPrecioEspecial ? null : (precioEspecial ?? this.precioEspecial),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto': producto.toJson(),
      'cantidad': cantidad,
      'precioEspecial': precioEspecial,
      'subtotal': subtotal,
    };
  }
}