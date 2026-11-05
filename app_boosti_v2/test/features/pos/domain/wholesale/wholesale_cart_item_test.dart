import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/domain/wholesale/wholesale_cart_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/mayoreo/wholesale_pricing_service.dart';

void main() {
  group('WholesaleCartItem weighted quantities', () {
    test('calculates the subtotal for fractional weight', () {
      final producto = ProductoEntity()..precioUnidad = 20;
      final precio = WholesalePricingService.resolver(
        producto: producto,
        cantidad: 0.375,
      );
      final item = WholesaleCartItem.desdePrecioResuelto(
        producto: producto,
        cantidad: 0.375,
        precio: precio,
      );

      expect(item.cantidad, 0.375);
      expect(item.subtotalBruto, 7.5);
      expect(item.subtotalFinal, 7.5);
    });
  });
}
