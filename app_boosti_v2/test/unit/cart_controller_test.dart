import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart';
import 'package:app_boosti_v2/features/pos/domain/models/cart_item.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';

// ============================================================
// HELPERS
// ============================================================

ProductItem crearProducto({
  String id = '1',
  String nombre = 'Producto Test',
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

CartNotifier crearCarrito({ConfiguracionIva? configIva}) {
  return CartNotifier(configIva: configIva);
}

// ============================================================

void main() {
  // ============================================================
  // GRUPO 1: CartState — Cálculos matemáticos
  // ============================================================
  group('CartState — Cálculos', () {
    test('carrito vacío tiene total 0 y sin items', () {
      const state = CartState();
      expect(state.items, isEmpty);
      expect(state.total, 0.0);
      expect(state.subtotal, 0.0);
      expect(state.impuesto, 0.0);
      expect(state.cantidadItems, 0);
    });

    test('total con precios INCLUYEN impuesto = suma directa', () {
      final state = CartState(
        items: [
          CartItem(
            producto: crearProducto(precio: 11.60),
            cantidad: 1,
            precioOriginal: 11.60,
            esDescuentoEspecial: false,
          ),
          CartItem(
            producto: crearProducto(id: '2', precio: 23.20),
            cantidad: 1,
            precioOriginal: 23.20,
            esDescuentoEspecial: false,
          ),
        ],
        configIva: const ConfiguracionIva(codigoPais: 'VE', porcentajeIva: 0.16),
        ivaHabilitado: true,
      );

      expect(state.total, 34.80);
      expect(state.subtotal, 30.00);
      expect(state.impuesto, 4.80);
    });

    test('total con precios NO incluyen impuesto = suma + IVA', () {
      final state = CartState(
        items: [
          CartItem(
            producto: crearProducto(precio: 10.0),
            cantidad: 1,
            precioOriginal: 10.0,
            esDescuentoEspecial: false,
          ),
          CartItem(
            producto: crearProducto(id: '2', precio: 20.0),
            cantidad: 1,
            precioOriginal: 20.0,
            esDescuentoEspecial: false,
          ),
        ],
        configIva: const ConfiguracionIva(
          codigoPais: 'VE',
          porcentajeIva: 0.16,
          preciosIncluyenIva: false,
        ),
        ivaHabilitado: true,
      );

      expect(state.subtotal, 30.00);
      expect(state.impuesto, 4.80);
      expect(state.total, 34.80);
    });

    test('porcentajeImpuesto 0 hace que impuesto sea 0', () {
      final state = CartState(
        items: [
          CartItem(
            producto: crearProducto(precio: 50.0),
            cantidad: 2,
            precioOriginal: 50.0,
            esDescuentoEspecial: false,
          ),
        ],
        configIva: const ConfiguracionIva(
          codigoPais: 'VE',
          porcentajeIva: 0.0,
          preciosIncluyenIva: false,
        ),
        ivaHabilitado: true,
      );

      expect(state.subtotal, 100.00);
      expect(state.impuesto, 0.00);
      expect(state.total, 100.00);
    });

    test('cantidadItems cuenta el número de líneas, no de unidades', () {
      final state = CartState(
        items: [
          CartItem(
            producto: crearProducto(),
            cantidad: 5,
            precioOriginal: 10.0,
            esDescuentoEspecial: false,
          ),
          CartItem(
            producto: crearProducto(id: '2'),
            cantidad: 3,
            precioOriginal: 10.0,
            esDescuentoEspecial: false,
          ),
        ],
      );

      expect(state.cantidadItems, 2);
    });

    test('redondeo a 2 decimales en subtotal', () {
      final state = CartState(
        items: [
          CartItem(
            producto: crearProducto(precio: 3.33),
            cantidad: 3,
            precioOriginal: 3.33,
            esDescuentoEspecial: false,
          ),
        ],
        configIva: const ConfiguracionIva(
          codigoPais: 'VE',
          porcentajeIva: 0.0,
          preciosIncluyenIva: false,
        ),
      );

      expect(state.subtotal, 9.99);
    });
  });

  // ============================================================
  // GRUPO 2: CartNotifier — Agregar productos
  // ============================================================
  group('CartNotifier — Agregar productos', () {
    test('agregar producto nuevo al carrito vacío', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(precio: 10.0), cantidad: 1);

      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.cantidad, 1.0);
      expect(notifier.state.items.first.producto.precioUnidad, 10.0);
    });

    test('agregar mismo producto SUMA cantidades', () {
      final notifier = crearCarrito();
      final producto = crearProducto(id: '1', precio: 10.0);

      notifier.agregarProducto(producto, cantidad: 2);
      notifier.agregarProducto(producto, cantidad: 3);

      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.cantidad, 5.0);
    });

    test('agregar producto con cantidad 0 se IGNORA', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(), cantidad: 0);

      expect(notifier.state.items, isEmpty);
    });

    test('agregar producto con cantidad negativa se IGNORA', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(), cantidad: -5);

      expect(notifier.state.items, isEmpty);
    });

    test('respeta stockMaximo al agregar nuevo', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(
        crearProducto(precio: 10.0),
        cantidad: 100,
        stockMaximo: 10,
      );

      expect(notifier.state.items.first.cantidad, 10.0);
    });

    test('respeta stockMaximo al sumar a existente', () {
      final notifier = crearCarrito();
      final producto = crearProducto(id: '1', precio: 10.0);

      notifier.agregarProducto(producto, cantidad: 5);
      notifier.agregarProducto(producto, cantidad: 10, stockMaximo: 8);

      expect(notifier.state.items.first.cantidad, 8.0);
    });

    test('guarda precioOriginal en el item nuevo', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(precio: 15.0), cantidad: 1);

      expect(notifier.state.items.first.precioOriginal, 15.0);
      expect(notifier.state.items.first.esDescuentoEspecial, false);
    });

    test('productos con distinto ID van a líneas separadas', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 10.0));
      notifier.agregarProducto(crearProducto(id: 'B', precio: 20.0));

      expect(notifier.state.items.length, 2);
    });
  });

  // ============================================================
  // GRUPO 3: Redondeo de cantidades
  // ============================================================
  group('CartNotifier — Redondeo de cantidades', () {
    test('producto NO pesado redondea al entero más cercano', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(esPesado: false), cantidad: 1.4);
      expect(notifier.state.items.first.cantidad, 1.0);

      notifier.limpiarCarrito();
      notifier.agregarProducto(crearProducto(esPesado: false), cantidad: 1.5);
      expect(notifier.state.items.first.cantidad, 2.0);

      notifier.limpiarCarrito();
      notifier.agregarProducto(crearProducto(esPesado: false), cantidad: 2.5);
      expect(notifier.state.items.first.cantidad, 3.0);
    });

    test('producto PESADO redondea a 3 decimales', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(
        crearProducto(esPesado: true),
        cantidad: 1.2345,
      );

      final cantidad = notifier.state.items.first.cantidad;
      expect(cantidad, closeTo(1.2345, 0.001));
    });

    test('producto pesado conserva precisión de 3 decimales', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(
        crearProducto(esPesado: true),
        cantidad: 0.555,
      );

      expect(notifier.state.items.first.cantidad, 0.555);
    });
  });

  // ============================================================
  // GRUPO 4: Actualizar cantidades
  // ============================================================
  group('CartNotifier — Actualizar cantidades', () {
    test('actualizarCantidad cambia la cantidad del item', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto());
      notifier.actualizarCantidad(0, 5.0);

      expect(notifier.state.items.first.cantidad, 5.0);
    });

    test('actualizarCantidad con 0 ELIMINA el item', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto());
      notifier.actualizarCantidad(0, 0);

      expect(notifier.state.items, isEmpty);
    });

    test('actualizarCantidad con negativo ELIMINA el item', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto());
      notifier.actualizarCantidad(0, -3);

      expect(notifier.state.items, isEmpty);
    });

    test('actualizarCantidad con índice inválido no hace nada', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto());

      notifier.actualizarCantidad(99, 5.0);
      expect(notifier.state.items.first.cantidad, 1.0);
    });

    test('actualizarCantidad respeta stockMaximo', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto());
      notifier.actualizarCantidad(0, 100, stockMaximo: 5);

      expect(notifier.state.items.first.cantidad, 5.0);
    });

    test('sumarCantidad suma al valor existente', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(), cantidad: 2);
      notifier.sumarCantidad(0, 3);

      expect(notifier.state.items.first.cantidad, 5.0);
    });

    test('sumarCantidad con índice inválido no hace nada', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(), cantidad: 2);
      notifier.sumarCantidad(99, 3);

      expect(notifier.state.items.first.cantidad, 2.0);
    });
  });

  // ============================================================
  // GRUPO 5: Eliminar items
  // ============================================================
  group('CartNotifier — Eliminar items', () {
    test('eliminarItem borra por índice', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A'));
      notifier.agregarProducto(crearProducto(id: 'B'));
      notifier.eliminarItem(0);

      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.producto.id, 'B');
    });

    test('eliminarItem con índice inválido no hace nada', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto());

      notifier.eliminarItem(99);
      expect(notifier.state.items.length, 1);
    });

    test('eliminarItemPorId borra por ID', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A'));
      notifier.agregarProducto(crearProducto(id: 'B'));
      notifier.eliminarItemPorId('A');

      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.producto.id, 'B');
    });

    test('eliminarItemPorId con ID inexistente no hace nada', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A'));
      notifier.eliminarItemPorId('XYZ');

      expect(notifier.state.items.length, 1);
    });
  });

  // ============================================================
  // GRUPO 6: Descuentos especiales
  // ============================================================
  group('CartNotifier — Descuentos especiales', () {
    test('aplicarDescuentoEspecial cambia el precio del producto', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 100.0));

      notifier.aplicarDescuentoEspecial('A', 80.0);

      expect(notifier.state.items.first.producto.precioUnidad, 80.0);
      expect(notifier.state.items.first.esDescuentoEspecial, true);
      expect(notifier.state.items.first.precioOriginal, 100.0);
    });

    test('aplicarDescuentoEspecial con precio <= 0 no hace nada', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 100.0));

      notifier.aplicarDescuentoEspecial('A', 0);
      expect(notifier.state.items.first.producto.precioUnidad, 100.0);

      notifier.aplicarDescuentoEspecial('A', -10);
      expect(notifier.state.items.first.producto.precioUnidad, 100.0);
    });

    test('aplicarDescuentoEspecial con producto inexistente no hace nada', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 100.0));

      notifier.aplicarDescuentoEspecial('XYZ', 50.0);
      expect(notifier.state.items.first.producto.precioUnidad, 100.0);
    });

    test('restaurarPrecioOriginal devuelve al precio original', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 100.0));
      notifier.aplicarDescuentoEspecial('A', 80.0);

      notifier.restaurarPrecioOriginal('A');

      expect(notifier.state.items.first.producto.precioUnidad, 100.0);
      expect(notifier.state.items.first.esDescuentoEspecial, false);
    });

    test('restaurarPrecioOriginal sin descuento no hace nada', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 100.0));

      notifier.restaurarPrecioOriginal('A');
      expect(notifier.state.items.first.producto.precioUnidad, 100.0);
    });

    test('el total refleja el precio con descuento', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 100.0), cantidad: 2);
      notifier.aplicarDescuentoEspecial('A', 50.0);

      expect(notifier.state.totalBrutoItems, 100.0);
    });
  });

  // ============================================================
  // GRUPO 7: Reset y configuración
  // ============================================================
  group('CartNotifier — Reset y configuración', () {
    test('limpiarCarrito vacía items', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A'));
      notifier.agregarProducto(crearProducto(id: 'B'));

      notifier.limpiarCarrito();

      expect(notifier.state.items, isEmpty);
      expect(notifier.state.total, 0.0);
    });

    test('limpiarCarrito PRESERVA el toggle de IVA', () {
      final notifier = crearCarrito();
      notifier.setIvaHabilitado(false);
      notifier.agregarProducto(crearProducto());
      notifier.limpiarCarrito();

      expect(notifier.state.ivaHabilitado, false);
    });

    test('limpiarCarrito PRESERVA la configuración de país', () {
      final notifier = crearCarrito(
        configIva: ConfiguracionIva.porPais['CO']!,
      );
      notifier.agregarProducto(crearProducto());
      notifier.limpiarCarrito();

      expect(notifier.state.configIva.codigoPais, 'CO');
    });

    test('copyWith preserva valores no especificados', () {
      const original = CartState(
        configIva: ConfiguracionIva(codigoPais: 'VE', porcentajeIva: 0.16),
        ivaHabilitado: false,
      );
      final copia = original.copyWith(items: []);

      expect(copia.configIva.porcentajeIva, 0.16);
      expect(copia.ivaHabilitado, false);
    });
  });

  // ============================================================
  // GRUPO 8: Escenarios integrados
  // ============================================================
  group('Escenarios integrados', () {
    test('venta típica: 2 productos normales + 1 pesado', () {
      final notifier = crearCarrito();

      notifier.agregarProducto(crearProducto(id: 'A', precio: 10.0), cantidad: 3);
      notifier.agregarProducto(crearProducto(id: 'B', precio: 5.0), cantidad: 2);
      notifier.agregarProducto(
        crearProducto(id: 'C', precio: 8.0, esPesado: true),
        cantidad: 1.5,
      );

      expect(notifier.state.items.length, 3);
      expect(notifier.state.items[0].cantidad, 3.0);
      expect(notifier.state.items[1].cantidad, 2.0);
      expect(notifier.state.items[2].cantidad, 1.5);
    });

    test('carrito con descuento aplicado y luego restaurado', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(id: 'A', precio: 100.0), cantidad: 2);

      notifier.aplicarDescuentoEspecial('A', 75.0);
      expect(notifier.state.totalBrutoItems, 150.0);

      notifier.restaurarPrecioOriginal('A');
      expect(notifier.state.totalBrutoItems, 200.0);
    });

    test('agregar producto ya con descuento NO pierde el descuento', () {
      final notifier = crearCarrito();
      final producto = crearProducto(id: 'A', precio: 100.0);

      notifier.agregarProducto(producto, cantidad: 1);
      notifier.aplicarDescuentoEspecial('A', 80.0);

      notifier.agregarProducto(producto, cantidad: 1);

      expect(notifier.state.items.first.producto.precioUnidad, 80.0);
      expect(notifier.state.items.first.esDescuentoEspecial, true);
      expect(notifier.state.items.first.cantidad, 2.0);
    });
  });

  // ============================================================
  // GRUPO 9: Configuración de IVA multi-país
  // ============================================================
  group('CartNotifier — Configuración de IVA multi-país', () {
    test('por defecto usa Venezuela con 16%', () {
      final notifier = crearCarrito();
      expect(notifier.state.configIva.codigoPais, 'VE');
      expect(notifier.state.configIva.porcentajeIva, 0.16);
      expect(notifier.state.ivaHabilitado, true);
    });

    test('Colombia usa 19%', () {
      final notifier = crearCarrito(
        configIva: ConfiguracionIva.porPais['CO']!,
      );
      expect(notifier.state.configIva.porcentajeIva, 0.19);
    });

    test('Chile usa 19%', () {
      final notifier = crearCarrito(
        configIva: ConfiguracionIva.porPais['CL']!,
      );
      expect(notifier.state.configIva.porcentajeIva, 0.19);
    });

    test('Argentina usa 21%', () {
      final notifier = crearCarrito(
        configIva: ConfiguracionIva.porPais['AR']!,
      );
      expect(notifier.state.configIva.porcentajeIva, 0.21);
    });

    test('todos los países tienen preciosIncluyenIva = true', () {
      for (final config in ConfiguracionIva.porPais.values) {
        expect(config.preciosIncluyenIva, isTrue,
            reason: '${config.codigoPais} debería incluir IVA en precios');
      }
    });

    test('el IVA NO se suma al total (VE)', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(precio: 116.0));

      expect(notifier.state.total, 116.0);
      expect(notifier.state.subtotal, 100.0);
      expect(notifier.state.impuesto, 16.0);
    });

    test('el IVA NO se suma al total (CO)', () {
      final notifier = crearCarrito(
        configIva: ConfiguracionIva.porPais['CO']!,
      );
      notifier.agregarProducto(crearProducto(precio: 119.0));

      expect(notifier.state.total, 119.0);
      expect(notifier.state.subtotal, 100.0);
      expect(notifier.state.impuesto, 19.0);
    });

    test('el IVA NO se suma al total (AR)', () {
      final notifier = crearCarrito(
        configIva: ConfiguracionIva.porPais['AR']!,
      );
      notifier.agregarProducto(crearProducto(precio: 121.0));

      expect(notifier.state.total, 121.0);
      expect(notifier.state.subtotal, 100.0);
      expect(notifier.state.impuesto, 21.0);
    });
  });

  // ============================================================
  // GRUPO 10: Toggle de IVA
  // ============================================================
  group('CartNotifier — Toggle de IVA', () {
    test('setIvaHabilitado(false) pone impuesto en 0', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(precio: 116.0));

      notifier.setIvaHabilitado(false);

      expect(notifier.state.impuesto, 0.0);
      expect(notifier.state.subtotal, 116.0);
      expect(notifier.state.total, 116.0);
    });

    test('toggleIva alterna el estado', () {
      final notifier = crearCarrito();
      expect(notifier.state.ivaHabilitado, true);

      notifier.toggleIva();
      expect(notifier.state.ivaHabilitado, false);

      notifier.toggleIva();
      expect(notifier.state.ivaHabilitado, true);
    });

    test('el toggle NO cambia el total', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(precio: 116.0));

      final totalConIva = notifier.state.total;
      notifier.setIvaHabilitado(false);
      final totalSinIva = notifier.state.total;

      expect(totalConIva, totalSinIva);
      expect(totalConIva, 116.0);
    });

    test('porcentajeIvaEfectivo devuelve 0 si está deshabilitado', () {
      final notifier = crearCarrito();
      notifier.setIvaHabilitado(false);

      expect(notifier.state.porcentajeIvaEfectivo, 0.0);
    });

    test('porcentajeIvaEfectivo devuelve 16% si está habilitado en VE', () {
      final notifier = crearCarrito();
      expect(notifier.state.porcentajeIvaEfectivo, 0.16);
    });

    test('resetearTodo SÍ resetea el toggle pero preserva configIva', () {
      final notifier = crearCarrito(
        configIva: ConfiguracionIva.porPais['AR']!,
      );
      notifier.setIvaHabilitado(false);
      notifier.agregarProducto(crearProducto());
      notifier.resetearTodo();

      expect(notifier.state.ivaHabilitado, true);
      expect(notifier.state.configIva.codigoPais, 'AR');
      expect(notifier.state.items, isEmpty);
    });

    test('cambiar país con setConfigIva recalcula el desglose', () {
      final notifier = crearCarrito();
      notifier.agregarProducto(crearProducto(precio: 100.0));

      final impuestoVE = notifier.state.impuesto;

      notifier.setConfigIva(ConfiguracionIva.porPais['AR']!);
      final impuestoAR = notifier.state.impuesto;

      expect(impuestoVE, isNot(impuestoAR));
    });
  });
}