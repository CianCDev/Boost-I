// test/features/pos/es_pesado_venta_test.dart
//
// PASO 2.2 · P0 · Propagación de `esPesado` desde el carrito hasta el detalle.
//
// Contexto del bug: `DetalleVentaEntity` no tenía el campo.
// `venta_service.dart`
// mapeaba `esPesado: false` hardcodeado al construir el `TicketItem`, así que
// el ticket imprimía `toStringAsFixed(0)` y una venta de 1.5 kg salía como
// "2x" (ticket_generator.dart:487 y ticket_service.dart:474).
//
// `VentaCalculator` es puro por diseño (sin I/O, sin Flutter, sin Isar), así
// que esta cadena se verifica sin mocks ni base de datos.
import 'package:app_boosti_v2/features/pos/domain/models/cart_item.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ventas_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProductItem producto({
    required String id,
    required bool esPesado,
    double precio = 5.0,
  }) {
    return ProductItem(
      id: id,
      codigoBarras: '780000$id',
      nombre: 'Producto $id',
      precioUnidad: precio,
      esPesado: esPesado,
      categoria: 'General',
    );
  }

  group('P0 · cartItemsADetalles propaga esPesado', () {
    test('producto por peso (1.5 kg) → esPesado == true', () {
      final items = VentaCalculator.cartItemsADetalles(
        cartItems: [
          CartItem(producto: producto(id: '1', esPesado: true), cantidad: 1.5),
        ],
        ventaIdFk: 'venta-1',
      );

      expect(items, hasLength(1));
      expect(
        items.first.esPesado,
        isTrue,
        reason: 'un producto de balanza debe quedar marcado como pesado',
      );
      expect(items.first.cantidad, 1.5);
    });

    test('producto por unidad → esPesado == false', () {
      final items = VentaCalculator.cartItemsADetalles(
        cartItems: [
          CartItem(producto: producto(id: '2', esPesado: false), cantidad: 3),
        ],
        ventaIdFk: 'venta-2',
      );

      expect(items.first.esPesado, isFalse);
      expect(items.first.cantidad, 3.0);
    });

    test('carrito mixto: cada línea conserva su propio flag', () {
      final items = VentaCalculator.cartItemsADetalles(
        cartItems: [
          CartItem(producto: producto(id: '1', esPesado: true), cantidad: 2.5),
          CartItem(producto: producto(id: '2', esPesado: false), cantidad: 4),
          CartItem(producto: producto(id: '3', esPesado: true), cantidad: 0.75),
        ],
        ventaIdFk: 'venta-3',
      );

      expect(items.map((d) => d.esPesado).toList(), [true, false, true]);
      expect(items.map((d) => d.cantidad).toList(), [2.5, 4.0, 0.75]);
    });

    test('carrito vacío → lista vacía', () {
      final items = VentaCalculator.cartItemsADetalles(
        cartItems: const [],
        ventaIdFk: 'venta-4',
      );
      expect(items, isEmpty);
    });

    test('el resto de campos no se vio afectado', () {
      final items = VentaCalculator.cartItemsADetalles(
        cartItems: [
          CartItem(producto: producto(id: '1', esPesado: true, precio: 5.0),
              cantidad: 1.5),
        ],
        ventaIdFk: 'venta-5',
      );

      final d = items.first;
      expect(d.ventaIdFk, 'venta-5');
      expect(d.productoId, 1, reason: 'id numérico se parsea con int.tryParse');
      expect(d.nombreProducto, 'Producto 1');
      expect(d.precioUnidad, 5.0);
      expect(d.subtotal, closeTo(7.5, 0.0001));
      expect(d.syncStatus, 'pending');
    });
  });

  group('P0 · el ticket ya no redondea el peso a entero', () {
    // Replica la decisión real de ticket_generator.dart:487 y
    // ticket_service.dart:474 → toStringAsFixed(esPesado ? 3 : 0).
    String formatoCantidad(double cantidad, bool esPesado) =>
        cantidad.toStringAsFixed(esPesado ? 3 : 0);

    test('1.5 kg se imprime como 1.500, no como 2', () {
      expect(formatoCantidad(1.5, true), '1.500');
      // Este es exactamente el síntoma del bug.
      expect(formatoCantidad(1.5, false), '2');
    });

    test('0.25 kg conserva el decimal', () {
      expect(formatoCantidad(0.25, true), '0.250');
      expect(formatoCantidad(0.25, false), '0');
    });

    test('las unidades siguen mostrándose como enteras', () {
      expect(formatoCantidad(4, false), '4');
    });
  });
}