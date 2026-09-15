// test/domain/venta_calculator_test.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/domain/models/cart_item.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ventas_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProductItem buildProducto({
    String id = '1',
    String nombre = 'Producto',
    double precio = 10.0,
  }) {
    return ProductItem(
      id: id,
      nombre: nombre,
      precioUnidad: precio,
      codigoBarras: 'cod-$id',
      categoria: 'General',
      esPesado: false,
    );
  }

  CartItem buildCartItem({
    required ProductItem producto,
    required double cantidad,
    double? precioOriginal,
    bool esDescuentoEspecial = false,
  }) {
    return CartItem(
      producto: producto,
      cantidad: cantidad,
      precioOriginal: precioOriginal ?? producto.precioUnidad,
      esDescuentoEspecial: esDescuentoEspecial,
    );
  }

  group('VentaCalculator.cartItemsADetalles', () {
    test('convierte 1 CartItem en 1 DetalleVentaEntity', () {
      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: [
          buildCartItem(producto: buildProducto(precio: 5.0), cantidad: 3),
        ],
        ventaIdFk: 'uuid-venta',
      );

      expect(detalles.length, 1);
      expect(detalles.first.productoId, 1);
      expect(detalles.first.cantidad, 3.0);
      expect(detalles.first.precioUnidad, 5.0);
      expect(detalles.first.subtotal, 15.0);
      expect(detalles.first.ventaIdFk, 'uuid-venta');
      expect(detalles.first.syncStatus, 'pending');
    });

    test('convierte N CartItems correctamente', () {
      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: [
          buildCartItem(producto: buildProducto(id: '1', precio: 5.0), cantidad: 2),
          buildCartItem(producto: buildProducto(id: '2', precio: 8.0), cantidad: 1),
        ],
        ventaIdFk: 'uuid-venta',
      );

      expect(detalles.length, 2);
      expect(detalles[0].subtotal, 10.0);
      expect(detalles[1].subtotal, 8.0);
    });

    test('id no numérico → productoId null', () {
      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: [
          buildCartItem(producto: buildProducto(id: 'abc'), cantidad: 1),
        ],
        ventaIdFk: 'uuid-venta',
      );

      expect(detalles.first.productoId, isNull);
    });
  });

  group('VentaCalculator.calcularDescuentos', () {
    DetalleVentaEntity buildDetalle({
      double precioUnidad = 10.0,
      double? precioOriginal,
      double cantidad = 1.0,
      bool esDescuentoEspecial = false,
    }) {
      return DetalleVentaEntity()
        ..productoId = 1
        ..nombreProducto = 'X'
        ..precioUnidad = precioUnidad
        ..precioOriginal = precioOriginal
        ..cantidad = cantidad
        ..subtotal = precioUnidad * cantidad
        ..esDescuentoEspecial = esDescuentoEspecial
        ..ventaIdFk = 'uuid';
    }

    test('sin descuentos → tieneDescuento false, monto 0', () {
      final r = VentaCalculator.calcularDescuentos([
        buildDetalle(precioUnidad: 10.0),
      ]);
      expect(r.tieneDescuento, isFalse);
      expect(r.montoDescuentoTotal, 0.0);
    });

    test('con descuento → calcula (original - actual) * cantidad', () {
      final r = VentaCalculator.calcularDescuentos([
        buildDetalle(
          precioUnidad: 80.0,
          precioOriginal: 100.0,
          cantidad: 2.0,
          esDescuentoEspecial: true,
        ),
      ]);
      expect(r.tieneDescuento, isTrue);
      expect(r.montoDescuentoTotal, closeTo(40.0, 0.001));
    });

    test('descuento sin precioOriginal → ignorado', () {
      final r = VentaCalculator.calcularDescuentos([
        buildDetalle(
          precioUnidad: 80.0,
          precioOriginal: null,
          esDescuentoEspecial: true,
        ),
      ]);
      expect(r.tieneDescuento, isFalse);
      expect(r.montoDescuentoTotal, 0.0);
    });

    test('múltiples descuentos se suman', () {
      final r = VentaCalculator.calcularDescuentos([
        buildDetalle(
            precioUnidad: 80.0,
            precioOriginal: 100.0,
            cantidad: 1.0,
            esDescuentoEspecial: true),
        buildDetalle(
            precioUnidad: 45.0,
            precioOriginal: 50.0,
            cantidad: 2.0,
            esDescuentoEspecial: true),
      ]);
      expect(r.montoDescuentoTotal, closeTo(20.0 + 10.0, 0.001));
    });
  });

  group('VentaCalculator.calcularDescuentoDeLote', () {
    test('necesario < disponible → devuelve necesario', () {
      expect(
        VentaCalculator.calcularDescuentoDeLote(
          cantidadNecesaria: 3,
          cantidadDisponible: 10,
        ),
        3,
      );
    });

    test('necesario > disponible → devuelve disponible', () {
      expect(
        VentaCalculator.calcularDescuentoDeLote(
          cantidadNecesaria: 15,
          cantidadDisponible: 10,
        ),
        10,
      );
    });

    test('necesario == disponible → devuelve igual', () {
      expect(
        VentaCalculator.calcularDescuentoDeLote(
          cantidadNecesaria: 5,
          cantidadDisponible: 5,
        ),
        5,
      );
    });
  });

  group('VentaCalculator.cantidadEsCero', () {
    test('0 → true', () => expect(VentaCalculator.cantidadEsCero(0), isTrue));
    test('0.0005 → true (tolerancia)', () {
      expect(VentaCalculator.cantidadEsCero(0.0005), isTrue);
    });
    test('0.01 → false', () {
      expect(VentaCalculator.cantidadEsCero(0.01), isFalse);
    });
    test('-5 → true', () {
      expect(VentaCalculator.cantidadEsCero(-5), isTrue);
    });
  });
}