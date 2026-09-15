// test/controllers/cart_controller_test.dart
import 'package:app_boosti_v2/features/pos/domain/models/cart_item.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  ProductItem product({
    String id = '1',
    String nombre = 'Coca-Cola',
    double precio = 2.0,
    bool esPesado = false,
    String categoria = 'Bebidas',
  }) {
    return ProductItem(
      id: id,
      codigoBarras: '750$id',
      nombre: nombre,
      precioUnidad: precio,
      esPesado: esPesado,
      categoria: categoria,
    );
  }

  CartNotifier buildNotifier({ConfiguracionIva? config}) {
    return CartNotifier(configIva: config);
  }

  // ════════════════════════════════════════════════════════════
  // ESTADO INICIAL
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — estado inicial', () {
    test('arranca vacío con IVA VE habilitado', () {
      final n = buildNotifier();
      expect(n.state.items, isEmpty);
      expect(n.state.cantidadItems, 0);
      expect(n.state.total, 0);
      expect(n.state.ivaHabilitado, isTrue);
      expect(n.state.configIva.codigoPais, 'VE');
      expect(n.state.configIva.porcentajeIva, 0.16);
      expect(n.state.configIva.preciosIncluyenIva, isTrue);
    });

    test('respeta ConfiguracionIva custom', () {
      final n = buildNotifier(
        config: const ConfiguracionIva(
          codigoPais: 'CO',
          porcentajeIva: 0.19,
        ),
      );
      expect(n.state.configIva.codigoPais, 'CO');
      expect(n.state.configIva.porcentajeIva, 0.19);
    });
  });

  // ════════════════════════════════════════════════════════════
  // AGREGAR PRODUCTO
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — agregarProducto', () {
    test('agrega un item nuevo', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 2);

      expect(n.state.items.length, 1);
      expect(n.state.items.first.cantidad, 2.0);
      expect(n.state.items.first.producto.nombre, 'Coca-Cola');
    });

    test('cantidad <= 0 no agrega nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 0);
      n.agregarProducto(product(), cantidad: -5);
      expect(n.state.items, isEmpty);
    });

    test('agregar el mismo producto suma cantidades', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 2);
      n.agregarProducto(product(), cantidad: 3);

      expect(n.state.items.length, 1);
      expect(n.state.items.first.cantidad, 5.0);
    });

    test('respeta stockMaximo al agregar item nuevo', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 10, stockMaximo: 5);
      expect(n.state.items.first.cantidad, 5.0);
    });

    test('respeta stockMaximo al sumar a uno existente', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 3);
      n.agregarProducto(product(), cantidad: 5, stockMaximo: 4);
      expect(n.state.items.first.cantidad, 4.0);
    });

    test('redondea a 3 decimales en producto pesado', () {
      final n = buildNotifier();
      n.agregarProducto(product(esPesado: true), cantidad: 1.23456);
      expect(n.state.items.first.cantidad, 1.235);
    });

    test('redondea a entero en producto unitario', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 1.7);
      expect(n.state.items.first.cantidad, 2.0);
    });
  });

  // ════════════════════════════════════════════════════════════
  // ACTUALIZAR / SUMAR CANTIDAD
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — actualizarCantidad / sumarCantidad', () {
    test('actualizarCantidad cambia el valor', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 1);
      n.actualizarCantidad(0, 5);
      expect(n.state.items.first.cantidad, 5.0);
    });

    test('actualizarCantidad a 0 elimina el item', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 1);
      n.actualizarCantidad(0, 0);
      expect(n.state.items, isEmpty);
    });

    test('actualizarCantidad negativa elimina el item', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 3);
      n.actualizarCantidad(0, -2);
      expect(n.state.items, isEmpty);
    });

    test('actualizarCantidad respeta stockMaximo', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 1);
      n.actualizarCantidad(0, 100, stockMaximo: 7);
      expect(n.state.items.first.cantidad, 7.0);
    });

    test('actualizarCantidad con index inválido no hace nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 1);
      n.actualizarCantidad(99, 5);
      expect(n.state.items.first.cantidad, 1.0);
    });

    test('sumarCantidad incrementa la cantidad existente', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 2);
      n.sumarCantidad(0, 3);
      expect(n.state.items.first.cantidad, 5.0);
    });

    test('sumarCantidad con cantidad <= 0 no hace nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 2);
      n.sumarCantidad(0, 0);
      n.sumarCantidad(0, -5);
      expect(n.state.items.first.cantidad, 2.0);
    });
  });

  // ════════════════════════════════════════════════════════════
  // ELIMINAR
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — eliminar', () {
    test('eliminarItem elimina por índice', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', nombre: 'A'), cantidad: 1);
      n.agregarProducto(product(id: '2', nombre: 'B'), cantidad: 1);
      n.eliminarItem(0);

      expect(n.state.items.length, 1);
      expect(n.state.items.first.producto.nombre, 'B');
    });

    test('eliminarItem con index inválido no hace nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 1);
      n.eliminarItem(99);
      expect(n.state.items.length, 1);
    });

    test('eliminarItemPorId elimina por id (String)', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', nombre: 'A'), cantidad: 1);
      n.agregarProducto(product(id: '2', nombre: 'B'), cantidad: 1);
      n.eliminarItemPorId('1');

      expect(n.state.items.length, 1);
      expect(n.state.items.first.producto.nombre, 'B');
    });

    test('eliminarItemPorId con id inexistente no cambia nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1'), cantidad: 1);
      n.eliminarItemPorId('999');
      expect(n.state.items.length, 1);
    });
  });

  // ════════════════════════════════════════════════════════════
  // DESCUENTOS ESPECIALES
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — descuentos especiales', () {
    test('aplicarDescuentoEspecial cambia precio y marca flag', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', precio: 5.0), cantidad: 1);
      n.aplicarDescuentoEspecial('1', 3.0);

      final item = n.state.items.first;
      expect(item.producto.precioUnidad, 3.0);
      expect(item.precioOriginal, 5.0);
      expect(item.esDescuentoEspecial, isTrue);
    });

    test('aplicarDescuentoEspecial con precio <= 0 no hace nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', precio: 5.0), cantidad: 1);
      n.aplicarDescuentoEspecial('1', 0);

      expect(n.state.items.first.producto.precioUnidad, 5.0);
      expect(n.state.items.first.esDescuentoEspecial, isFalse);
    });

    test('aplicarDescuentoEspecial con id inexistente no hace nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', precio: 5.0), cantidad: 1);
      n.aplicarDescuentoEspecial('999', 3.0);
      expect(n.state.items.first.producto.precioUnidad, 5.0);
    });

    test('restaurarPrecioOriginal revierte el descuento', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', precio: 5.0), cantidad: 1);
      n.aplicarDescuentoEspecial('1', 3.0);
      n.restaurarPrecioOriginal('1');

      final item = n.state.items.first;
      expect(item.producto.precioUnidad, 5.0);
      expect(item.esDescuentoEspecial, isFalse);
    });

    test('restaurarPrecioOriginal sin descuento no hace nada', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', precio: 5.0), cantidad: 1);
      n.restaurarPrecioOriginal('1');
      expect(n.state.items.first.producto.precioUnidad, 5.0);
    });
  });

  // ════════════════════════════════════════════════════════════
  // LIMPIEZA
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — limpieza', () {
    test('limpiarCarrito vacía items pero conserva IVA', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 5);
      n.toggleIva(); // desactiva IVA
      n.limpiarCarrito();

      expect(n.state.items, isEmpty);
      expect(n.state.ivaHabilitado, isFalse);
    });

    test('resetearTodo vuelve a estado limpio', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 5);
      n.toggleIva();
      n.resetearTodo();

      expect(n.state.items, isEmpty);
      expect(n.state.ivaHabilitado, isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════
  // TOGGLE / SET IVA
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — IVA toggle', () {
    test('toggleIva alterna el flag', () {
      final n = buildNotifier();
      expect(n.state.ivaHabilitado, isTrue);
      n.toggleIva();
      expect(n.state.ivaHabilitado, isFalse);
      n.toggleIva();
      expect(n.state.ivaHabilitado, isTrue);
    });

    test('setIvaHabilitado fuerza el valor', () {
      final n = buildNotifier();
      n.setIvaHabilitado(false);
      expect(n.state.ivaHabilitado, isFalse);
      n.setIvaHabilitado(true);
      expect(n.state.ivaHabilitado, isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════
  // CÁLCULOS — IVA INCLUIDO (VE)
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — totales con IVA incluido (VE)', () {
    test('total = suma de subtotales', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: '1', precio: 2.0), cantidad: 3); // 6
      n.agregarProducto(product(id: '2', precio: 1.5), cantidad: 2); // 3

      expect(n.state.total, 9.0);
      expect(n.state.totalBrutoItems, 9.0);
    });

    test('subtotal se calcula despejando IVA del total', () {
      final n = buildNotifier();
      // Total 116 → subtotal 100, impuesto 16
      n.agregarProducto(product(precio: 116.0), cantidad: 1);

      expect(n.state.total, 116.0);
      expect(n.state.subtotal, 100.0);
      expect(n.state.impuesto, 16.0);
    });

    test('con IVA deshabilitado, subtotal = total e impuesto = 0', () {
      final n = buildNotifier();
      n.agregarProducto(product(precio: 100.0), cantidad: 1);
      n.setIvaHabilitado(false);

      expect(n.state.total, 100.0);
      expect(n.state.subtotal, 100.0);
      expect(n.state.impuesto, 0.0);
      expect(n.state.porcentajeIvaEfectivo, 0.0);
    });

    test('porcentajeIvaEfectivo refleja el toggle', () {
      final n = buildNotifier();
      expect(n.state.porcentajeIvaEfectivo, 0.16);
      n.toggleIva();
      expect(n.state.porcentajeIvaEfectivo, 0.0);
    });
  });

  // ════════════════════════════════════════════════════════════
  // CÁLCULOS — IVA NO INCLUIDO
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — totales con IVA NO incluido', () {
    test('total = subtotal + impuesto', () {
      final n = buildNotifier(
        config: const ConfiguracionIva(
          codigoPais: 'VE',
          porcentajeIva: 0.16,
          preciosIncluyenIva: false,
        ),
      );
      // Precio sin IVA: 100 → subtotal 100, impuesto 16, total 116
      n.agregarProducto(product(precio: 100.0), cantidad: 1);

      expect(n.state.subtotal, 100.0);
      expect(n.state.impuesto, 16.0);
      expect(n.state.total, 116.0);
    });

    test('con IVA deshabilitado, no se suma impuesto', () {
      final n = buildNotifier(
        config: const ConfiguracionIva(
          codigoPais: 'VE',
          porcentajeIva: 0.16,
          preciosIncluyenIva: false,
        ),
      );
      n.agregarProducto(product(precio: 100.0), cantidad: 1);
      n.setIvaHabilitado(false);

      expect(n.state.subtotal, 100.0);
      expect(n.state.impuesto, 0.0);
      expect(n.state.total, 100.0);
    });
  });

  // ════════════════════════════════════════════════════════════
  // REEMPLAZAR ITEMS (para sesiones parkeadas)
  // ════════════════════════════════════════════════════════════
  group('CartNotifier — reemplazarItems (sesiones)', () {
    test('reemplaza los items completamente', () {
      final n = buildNotifier();
      n.agregarProducto(product(id: 'viejo'), cantidad: 1);

      final nuevos = [
        CartItem(
          producto: product(id: 'nuevo', nombre: 'Nuevo'),
          cantidad: 3,
        ),
      ];
      n.reemplazarItems(nuevos);

      expect(n.state.items.length, 1);
      expect(n.state.items.first.producto.nombre, 'Nuevo');
      expect(n.state.items.first.cantidad, 3.0);
    });

    test('reemplazarItems puede cambiar la config de IVA', () {
      final n = buildNotifier();
      n.reemplazarItems(
        const [],
        configIva: const ConfiguracionIva(
          codigoPais: 'CO',
          porcentajeIva: 0.19,
        ),
        ivaHabilitado: false,
      );

      expect(n.state.configIva.codigoPais, 'CO');
      expect(n.state.configIva.porcentajeIva, 0.19);
      expect(n.state.ivaHabilitado, isFalse);
    });

    test('reemplazarItems con lista vacía limpia el carrito', () {
      final n = buildNotifier();
      n.agregarProducto(product(), cantidad: 5);
      n.reemplazarItems(const []);
      expect(n.state.items, isEmpty);
    });

    test('reemplazarItems conserva el IVA actual si no se pasa config', () {
      final n = buildNotifier();
      n.toggleIva(); // desactiva IVA
      n.reemplazarItems([
        CartItem(producto: product(id: 'x'), cantidad: 1),
      ]);

      expect(n.state.ivaHabilitado, isFalse);
    });

    test('round-trip: agregar → reemplazar → mantiene items', () {
      final n = buildNotifier();

      // 1. Agregar
      n.agregarProducto(product(id: 'a', nombre: 'A', precio: 5.0), cantidad: 2);
      n.agregarProducto(product(id: 'b', nombre: 'B', precio: 3.0), cantidad: 1);
      expect(n.state.items.length, 2);
      expect(n.state.total, 13.0); // 5*2 + 3*1

      // 2. Capturar snapshot y reemplazar con vacío
      final snapshot = List<CartItem>.from(n.state.items);
      n.reemplazarItems(const []);
      expect(n.state.items, isEmpty);

      // 3. Restaurar snapshot
      n.reemplazarItems(snapshot);
      expect(n.state.items.length, 2);
      expect(n.state.total, 13.0);
    });
  });
}