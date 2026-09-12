import 'package:app_boosti_v2/features/pos/presentation/services/ventas_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/domain/models/cart_item.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';

// ============================================================
// HELPERS
// ============================================================

ProductItem crearProducto({
  String id = '1',
  String nombre = 'Producto',
  double precio = 10.0,
  bool esPesado = false,
}) {
  return ProductItem(
    id: id,
    nombre: nombre,
    precioUnidad: precio,
    esPesado: esPesado, codigoBarras: '', categoria: '',
  );
}

CartItem crearCartItem({
  String id = '1',
  String nombre = 'Producto',
  double precio = 10.0,
  double cantidad = 1.0,
  double? precioOriginal,
  bool esDescuentoEspecial = false,
  bool esPesado = false,
}) {
  return CartItem(
    producto: crearProducto(
      id: id,
      nombre: nombre,
      precio: precio,
      esPesado: esPesado,
    ),
    cantidad: cantidad,
    precioOriginal: precioOriginal ?? precio,
    esDescuentoEspecial: esDescuentoEspecial,
  );
}

DetalleVentaEntity crearDetalle({
  int productoId = 1,
  String nombreProducto = 'Producto',
  double precioUnidad = 10.0,
  double cantidad = 1.0,
  double? precioOriginal,
  bool esDescuentoEspecial = false,
}) {
  return DetalleVentaEntity()
    ..productoId = productoId
    ..nombreProducto = nombreProducto
    ..precioUnidad = precioUnidad
    ..cantidad = cantidad
    ..subtotal = precioUnidad * cantidad
    ..precioOriginal = precioOriginal
    ..esDescuentoEspecial = esDescuentoEspecial;
}

// ============================================================

void main() {
  // ══════════════════════════════════════════════════════════════
  // cartItemsADetalles
  // ══════════════════════════════════════════════════════════════
  group('VentaCalculator — cartItemsADetalles', () {
    test('convierte lista vacía a lista vacía', () {
      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: [],
        ventaIdFk: 'venta-1',
      );
      expect(detalles, isEmpty);
    });

    test('convierte un item correctamente', () {
      final cartItems = [
        crearCartItem(id: '5', nombre: 'Café', precio: 8.5, cantidad: 2),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'venta-abc',
      );

      expect(detalles.length, 1);
      final d = detalles.first;
      expect(d.productoId, 5);
      expect(d.nombreProducto, 'Café');
      expect(d.precioUnidad, 8.5);
      expect(d.cantidad, 2.0);
      expect(d.subtotal, 17.0);
      expect(d.ventaIdFk, 'venta-abc');
      expect(d.syncStatus, 'pending');
    });

    test('convierte varios items', () {
      final cartItems = [
        crearCartItem(id: '1', precio: 10.0, cantidad: 2),
        crearCartItem(id: '2', precio: 5.0, cantidad: 3),
        crearCartItem(id: '3', precio: 2.5, cantidad: 4),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'venta-x',
      );

      expect(detalles.length, 3);
      expect(detalles[0].subtotal, 20.0);
      expect(detalles[1].subtotal, 15.0);
      expect(detalles[2].subtotal, 10.0);
    });

    test('propaga descuento especial', () {
      final cartItems = [
        crearCartItem(
          id: '1',
          precio: 80.0,
          cantidad: 1,
          precioOriginal: 100.0,
          esDescuentoEspecial: true,
        ),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'v',
      );

      expect(detalles.first.precioOriginal, 100.0);
      expect(detalles.first.precioUnidad, 80.0);
      expect(detalles.first.esDescuentoEspecial, true);
    });

    test('productoId null si el id no es numérico', () {
      final cartItems = [
        crearCartItem(id: 'ABC-123', precio: 10.0),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'v',
      );

      expect(detalles.first.productoId, isNull);
    });

    test('todos los detalles reciben el mismo ventaIdFk', () {
      final cartItems = [
        crearCartItem(id: '1'),
        crearCartItem(id: '2'),
        crearCartItem(id: '3'),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'venta-unica',
      );

      for (final d in detalles) {
        expect(d.ventaIdFk, 'venta-unica');
      }
    });

    test('cantidad decimal se preserva', () {
      final cartItems = [
        crearCartItem(cantidad: 1.555, esPesado: true),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'v',
      );

      expect(detalles.first.cantidad, 1.555);
    });

    test('subtotal se calcula como cantidad * precio', () {
      final cartItems = [
        crearCartItem(precio: 3.33, cantidad: 3),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'v',
      );

      expect(detalles.first.subtotal, closeTo(9.99, 0.001));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // calcularDescuentos
  // ══════════════════════════════════════════════════════════════
  group('VentaCalculator — calcularDescuentos', () {
    test('lista vacía → sin descuento', () {
      final r = VentaCalculator.calcularDescuentos([]);
      expect(r.tieneDescuento, false);
      expect(r.montoDescuentoTotal, 0.0);
    });

    test('detalles sin descuento → sin descuento', () {
      final detalles = [
        crearDetalle(precioUnidad: 10.0, cantidad: 2),
        crearDetalle(precioUnidad: 5.0, cantidad: 3),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.tieneDescuento, false);
      expect(r.montoDescuentoTotal, 0.0);
    });

    test('un detalle con descuento', () {
      final detalles = [
        crearDetalle(
          precioUnidad: 80.0,
          cantidad: 1,
          precioOriginal: 100.0,
          esDescuentoEspecial: true,
        ),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.tieneDescuento, true);
      expect(r.montoDescuentoTotal, 20.0);
    });

    test('descuento se multiplica por cantidad', () {
      final detalles = [
        crearDetalle(
          precioUnidad: 80.0,
          cantidad: 3,
          precioOriginal: 100.0,
          esDescuentoEspecial: true,
        ),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.montoDescuentoTotal, 60.0); // (100-80)*3
    });

    test('múltiples descuentos se suman', () {
      final detalles = [
        crearDetalle(
          precioUnidad: 80.0,
          cantidad: 1,
          precioOriginal: 100.0,
          esDescuentoEspecial: true,
        ),
        crearDetalle(
          precioUnidad: 40.0,
          cantidad: 2,
          precioOriginal: 50.0,
          esDescuentoEspecial: true,
        ),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.tieneDescuento, true);
      expect(r.montoDescuentoTotal, 40.0); // 20 + 20
    });

    test('detalle con flag true pero sin precioOriginal se ignora', () {
      final detalles = [
        crearDetalle(
          precioUnidad: 80.0,
          cantidad: 1,
          precioOriginal: null,
          esDescuentoEspecial: true,
        ),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.tieneDescuento, false);
      expect(r.montoDescuentoTotal, 0.0);
    });

    test('detalle con precioOriginal pero flag false se ignora', () {
      final detalles = [
        crearDetalle(
          precioUnidad: 80.0,
          cantidad: 1,
          precioOriginal: 100.0,
          esDescuentoEspecial: false,
        ),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.tieneDescuento, false);
      expect(r.montoDescuentoTotal, 0.0);
    });

    test('mezcla de con y sin descuento', () {
      final detalles = [
        crearDetalle(precioUnidad: 10.0, cantidad: 5),
        crearDetalle(
          precioUnidad: 80.0,
          cantidad: 1,
          precioOriginal: 100.0,
          esDescuentoEspecial: true,
        ),
        crearDetalle(precioUnidad: 5.0, cantidad: 2),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.tieneDescuento, true);
      expect(r.montoDescuentoTotal, 20.0);
    });

    test('precioOriginal igual a precio → sin descuento real', () {
      final detalles = [
        crearDetalle(
          precioUnidad: 100.0,
          cantidad: 2,
          precioOriginal: 100.0,
          esDescuentoEspecial: true,
        ),
      ];
      final r = VentaCalculator.calcularDescuentos(detalles);
      expect(r.tieneDescuento, true); // el flag está puesto
      expect(r.montoDescuentoTotal, 0.0); // pero no hay descuento real
    });
  });

  // ══════════════════════════════════════════════════════════════
  // calcularDescuentoDeLote
  // ══════════════════════════════════════════════════════════════
  group('VentaCalculator — calcularDescuentoDeLote', () {
    test('lote con suficiente stock → descuenta todo lo necesario', () {
      final d = VentaCalculator.calcularDescuentoDeLote(
        cantidadNecesaria: 3.0,
        cantidadDisponible: 10.0,
      );
      expect(d, 3.0);
    });

    test('lote con stock justo → descuenta todo lo necesario', () {
      final d = VentaCalculator.calcularDescuentoDeLote(
        cantidadNecesaria: 5.0,
        cantidadDisponible: 5.0,
      );
      expect(d, 5.0);
    });

    test('lote con menos stock → descuenta lo disponible', () {
      final d = VentaCalculator.calcularDescuentoDeLote(
        cantidadNecesaria: 10.0,
        cantidadDisponible: 3.0,
      );
      expect(d, 3.0);
    });

    test('lote vacío → descuenta 0', () {
      final d = VentaCalculator.calcularDescuentoDeLote(
        cantidadNecesaria: 5.0,
        cantidadDisponible: 0.0,
      );
      expect(d, 0.0);
    });

    test('necesidad 0 → descuenta 0', () {
      final d = VentaCalculator.calcularDescuentoDeLote(
        cantidadNecesaria: 0.0,
        cantidadDisponible: 100.0,
      );
      expect(d, 0.0);
    });

    test('precisión decimal se preserva', () {
      final d = VentaCalculator.calcularDescuentoDeLote(
        cantidadNecesaria: 0.555,
        cantidadDisponible: 0.333,
      );
      expect(d, 0.333);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // cantidadEsCero
  // ══════════════════════════════════════════════════════════════
  group('VentaCalculator — cantidadEsCero', () {
    test('cero exacto → true', () {
      expect(VentaCalculator.cantidadEsCero(0.0), true);
    });

    test('valor menor a tolerancia → true', () {
      expect(VentaCalculator.cantidadEsCero(0.0005), true);
      expect(VentaCalculator.cantidadEsCero(0.001), true);
    });

    test('valor justo por encima de tolerancia → false', () {
      expect(VentaCalculator.cantidadEsCero(0.002), false);
      expect(VentaCalculator.cantidadEsCero(0.01), false);
    });

    test('valor negativo → true (no hay nada que descontar)', () {
      expect(VentaCalculator.cantidadEsCero(-0.5), true);
    });

    test('valor grande → false', () {
      expect(VentaCalculator.cantidadEsCero(100.0), false);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // Integración: simular un flujo completo de venta
  // ══════════════════════════════════════════════════════════════
  group('VentaCalculator — Flujo completo', () {
    test('venta con 2 productos y un descuento', () {
      final cartItems = [
        crearCartItem(id: '1', precio: 100.0, cantidad: 1),
        crearCartItem(
          id: '2',
          precio: 80.0,
          cantidad: 2,
          precioOriginal: 100.0,
          esDescuentoEspecial: true,
        ),
      ];

      // Paso 1: convertir
      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'venta-flujo',
      );

      // Paso 2: calcular descuentos
      final r = VentaCalculator.calcularDescuentos(detalles);

      // Verificaciones
      expect(detalles.length, 2);
      expect(r.tieneDescuento, true);
      expect(r.montoDescuentoTotal, 40.0); // (100-80)*2

      // Verificar subtotales
      final totalDetalles =
          detalles.fold<double>(0.0, (sum, d) => sum + d.subtotal);
      expect(totalDetalles, 260.0); // 100 + 160
    });

    test('venta sin descuentos', () {
      final cartItems = [
        crearCartItem(id: '1', precio: 10.0, cantidad: 5),
        crearCartItem(id: '2', precio: 20.0, cantidad: 2),
      ];

      final detalles = VentaCalculator.cartItemsADetalles(
        cartItems: cartItems,
        ventaIdFk: 'v-sin-desc',
      );
      final r = VentaCalculator.calcularDescuentos(detalles);

      expect(r.tieneDescuento, false);
      expect(r.montoDescuentoTotal, 0.0);
    });

    test('descontar de múltiples lotes hasta cubrir la cantidad', () {
      // Simulamos una venta de 7 unidades donde:
      // Lote 1: 3 disponibles
      // Lote 2: 2 disponibles
      // Lote 3: 5 disponibles

      double cantidadPorDescontar = 7.0;
      final lotes = [3.0, 2.0, 5.0];
      int loteIndex = 0;

      while (!VentaCalculator.cantidadEsCero(cantidadPorDescontar) &&
          loteIndex < lotes.length) {
        final descontar = VentaCalculator.calcularDescuentoDeLote(
          cantidadNecesaria: cantidadPorDescontar,
          cantidadDisponible: lotes[loteIndex],
        );
        cantidadPorDescontar -= descontar;
        loteIndex++;
      }

      expect(cantidadPorDescontar, closeTo(0.0, 0.001));
      expect(loteIndex, 3); // usó los 3 lotes
    });
  });
}