// lib/features/pos/domain/models/cart_item.dart
import 'product_item.dart';

class CartItem {
  final ProductItem producto;
  final double cantidad;
  final double precioOriginal;
  final bool esDescuentoEspecial;

  /// R.3 · Estación de preparación (solo KDS de restaurante).
  ///
  /// Se copia de `ProductoEntity.departamentoId` al añadir el producto al
  /// carrito (`CatalogActions.agregarProducto`) y viaja así hasta
  /// `CartSessionItem.estacionId`, que es lo que el KDS lee.
  ///
  /// `null` en retail y en productos que no requieren preparación. No
  /// afecta a `procesarVenta`: ni `ProductItem` ni `DetalleVentaEntity`
  /// lo conocen.
  final int? estacionId;

  /// R.3.2 · URL de la imagen del producto, como SNAPSHOT.
  ///
  /// Viene de `ProductoEntity.imagenUrl` y viaja hasta
  /// `CartSessionItem.imagenUrl` para que `ComandaScreen` pueda pintar la
  /// miniatura sin hacer un lookup a `ProductoEntity` por cada fila.
  ///
  /// Es un snapshot a propósito (igual que `productoNombre`): si el
  /// usuario cambia la foto del producto mientras la comanda está abierta,
  /// la comanda conserva lo que se pidió. Y evita el problema gordo: el
  /// producto puede estar ya borrado de Isar, y una comanda de hace dos
  /// horas se quedaría sin imagen.
  ///
  /// `null` si el producto no tiene foto.
  final String? imagenUrl;

  // 🔥 Quitamos 'const' para permitir el inicializador condicional
  CartItem({
    required this.producto,
    required this.cantidad,
    double? precioOriginal,
    this.esDescuentoEspecial = false,
    this.estacionId,
    this.imagenUrl,
  }) : precioOriginal = precioOriginal ?? producto.precioUnidad;

  double get subtotal => producto.precioUnidad * cantidad;

  CartItem copyWith({
    ProductItem? producto,
    double? cantidad,
    double? precioOriginal,
    bool? esDescuentoEspecial,
    int? estacionId,
    String? imagenUrl,
  }) {
    return CartItem(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      precioOriginal: precioOriginal ?? this.precioOriginal,
      esDescuentoEspecial: esDescuentoEspecial ?? this.esDescuentoEspecial,
      estacionId: estacionId ?? this.estacionId,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto': producto.toJson(),
      'cantidad': cantidad,
      'precioOriginal': precioOriginal,
      'esDescuentoEspecial': esDescuentoEspecial,
      'subtotal': subtotal,
      'estacionId': estacionId,
      'imagenUrl': imagenUrl,
    };
  }
}