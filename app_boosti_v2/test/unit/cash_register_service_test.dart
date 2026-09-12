import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/cash_register_service.dart';

// ============================================================
// HELPERS
// ============================================================

VentaEntity crearVenta({
  double total = 10.0,
  String metodoPago = 'Efectivo',
  DateTime? fecha,
}) {
  return VentaEntity()
    ..total = total
    ..subtotal = total
    ..metodoPago = metodoPago
    ..fecha = fecha ?? DateTime.now();
}

// ============================================================

void main() {
  group('CashRegisterService — Carrito vacío', () {
    test('lista vacía devuelve todos los contadores en 0', () {
      final resumen = CashRegisterService.calcularDesdeVentas([]);

      expect(resumen.totalVentas, 0.0);
      expect(resumen.cantidadTransacciones, 0);
      expect(resumen.totalesPorMetodo['Efectivo'], 0.0);
      expect(resumen.totalesPorMetodo['Tarjeta'], 0.0);
      expect(resumen.totalesPorMetodo['Pago Móvil'], 0.0);
      expect(resumen.totalesPorMetodo['Divisas'], 0.0);
      expect(resumen.conteoPorMetodo['Efectivo'], 0);
    });

    test('los 4 métodos base siempre están presentes', () {
      final resumen = CashRegisterService.calcularDesdeVentas([]);
      expect(resumen.totalesPorMetodo.keys.toSet(),
          {'Efectivo', 'Tarjeta', 'Pago Móvil', 'Divisas'});
      expect(resumen.conteoPorMetodo.keys.toSet(),
          {'Efectivo', 'Tarjeta', 'Pago Móvil', 'Divisas'});
    });
  });

  group('CashRegisterService — Un solo método', () {
    test('1 venta en efectivo', () {
      final ventas = [crearVenta(total: 50.0, metodoPago: 'Efectivo')];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 50.0);
      expect(resumen.cantidadTransacciones, 1);
      expect(resumen.totalesPorMetodo['Efectivo'], 50.0);
      expect(resumen.conteoPorMetodo['Efectivo'], 1);
      expect(resumen.totalesPorMetodo['Tarjeta'], 0.0);
      expect(resumen.conteoPorMetodo['Tarjeta'], 0);
    });

    test('3 ventas en efectivo suman correctamente', () {
      final ventas = [
        crearVenta(total: 10.0, metodoPago: 'Efectivo'),
        crearVenta(total: 25.5, metodoPago: 'Efectivo'),
        crearVenta(total: 4.5, metodoPago: 'Efectivo'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 40.0);
      expect(resumen.cantidadTransacciones, 3);
      expect(resumen.totalesPorMetodo['Efectivo'], 40.0);
      expect(resumen.conteoPorMetodo['Efectivo'], 3);
    });
  });

  group('CashRegisterService — Múltiples métodos', () {
    test('ventas repartidas entre 4 métodos', () {
      final ventas = [
        crearVenta(total: 100.0, metodoPago: 'Efectivo'),
        crearVenta(total: 50.0, metodoPago: 'Tarjeta'),
        crearVenta(total: 30.0, metodoPago: 'Pago Móvil'),
        crearVenta(total: 20.0, metodoPago: 'Divisas'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 200.0);
      expect(resumen.cantidadTransacciones, 4);
      expect(resumen.totalesPorMetodo['Efectivo'], 100.0);
      expect(resumen.totalesPorMetodo['Tarjeta'], 50.0);
      expect(resumen.totalesPorMetodo['Pago Móvil'], 30.0);
      expect(resumen.totalesPorMetodo['Divisas'], 20.0);
    });

    test('múltiples ventas del mismo método', () {
      final ventas = [
        crearVenta(total: 100.0, metodoPago: 'Efectivo'),
        crearVenta(total: 50.0, metodoPago: 'Efectivo'),
        crearVenta(total: 30.0, metodoPago: 'Tarjeta'),
        crearVenta(total: 20.0, metodoPago: 'Tarjeta'),
        crearVenta(total: 15.0, metodoPago: 'Tarjeta'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 215.0);
      expect(resumen.totalesPorMetodo['Efectivo'], 150.0);
      expect(resumen.conteoPorMetodo['Efectivo'], 2);
      expect(resumen.totalesPorMetodo['Tarjeta'], 65.0);
      expect(resumen.conteoPorMetodo['Tarjeta'], 3);
    });

    test('suma con decimales preserva precisión', () {
      final ventas = [
        crearVenta(total: 3.33, metodoPago: 'Efectivo'),
        crearVenta(total: 6.67, metodoPago: 'Efectivo'),
        crearVenta(total: 10.01, metodoPago: 'Tarjeta'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalesPorMetodo['Efectivo'], closeTo(10.0, 0.001));
      expect(resumen.totalesPorMetodo['Tarjeta'], 10.01);
    });
  });

  group('CashRegisterService — Métodos dinámicos', () {
    test('método no base se agrega dinámicamente', () {
      final ventas = [
        crearVenta(total: 100.0, metodoPago: 'Efectivo'),
        crearVenta(total: 50.0, metodoPago: 'Zelle'),
        crearVenta(total: 30.0, metodoPago: 'Cripto'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 180.0);
      expect(resumen.totalesPorMetodo['Zelle'], 50.0);
      expect(resumen.conteoPorMetodo['Zelle'], 1);
      expect(resumen.totalesPorMetodo['Cripto'], 30.0);
      expect(resumen.conteoPorMetodo['Cripto'], 1);
    });

    test('método vacío se trata como uno más', () {
      final ventas = [
        crearVenta(total: 10.0, metodoPago: ''),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalesPorMetodo[''], 10.0);
      expect(resumen.conteoPorMetodo[''], 1);
    });
  });

  group('CashRegisterService — Casos borde', () {
    test('venta con total 0 se cuenta pero no suma', () {
      final ventas = [
        crearVenta(total: 0.0, metodoPago: 'Efectivo'),
        crearVenta(total: 50.0, metodoPago: 'Efectivo'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 50.0);
      expect(resumen.cantidadTransacciones, 2);
      expect(resumen.totalesPorMetodo['Efectivo'], 50.0);
      expect(resumen.conteoPorMetodo['Efectivo'], 2);
    });

    test('muchas ventas (100) se agregan correctamente', () {
      final ventas = List.generate(
        100,
        (i) => crearVenta(total: 1.0, metodoPago: 'Efectivo'),
      );
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 100.0);
      expect(resumen.cantidadTransacciones, 100);
      expect(resumen.totalesPorMetodo['Efectivo'], 100.0);
      expect(resumen.conteoPorMetodo['Efectivo'], 100);
    });

    test('montos altos no pierden precisión', () {
      final ventas = [
        crearVenta(total: 999999.99, metodoPago: 'Efectivo'),
        crearVenta(total: 0.01, metodoPago: 'Efectivo'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.totalVentas, 1000000.0);
    });
  });

  group('CashRegisterService — Consistencia', () {
    test('la suma de totales por método equivale al total general', () {
      final ventas = [
        crearVenta(total: 100.0, metodoPago: 'Efectivo'),
        crearVenta(total: 50.0, metodoPago: 'Tarjeta'),
        crearVenta(total: 30.0, metodoPago: 'Pago Móvil'),
        crearVenta(total: 20.0, metodoPago: 'Divisas'),
        crearVenta(total: 5.0, metodoPago: 'Zelle'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      final sumaPorMetodo = resumen.totalesPorMetodo.values
          .fold<double>(0.0, (a, b) => a + b);

      expect(sumaPorMetodo, closeTo(resumen.totalVentas, 0.001));
    });

    test('la suma de conteos por método equivale al total de transacciones',
        () {
      final ventas = [
        crearVenta(total: 100.0, metodoPago: 'Efectivo'),
        crearVenta(total: 50.0, metodoPago: 'Tarjeta'),
        crearVenta(total: 30.0, metodoPago: 'Efectivo'),
        crearVenta(total: 20.0, metodoPago: 'Pago Móvil'),
      ];
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      final sumaConteos = resumen.conteoPorMetodo.values
          .fold<int>(0, (a, b) => a + b);

      expect(sumaConteos, resumen.cantidadTransacciones);
    });

    test('cantidadTransacciones coincide con el largo de la lista', () {
      final ventas = List.generate(
        7,
        (i) => crearVenta(total: 10.0, metodoPago: 'Efectivo'),
      );
      final resumen = CashRegisterService.calcularDesdeVentas(ventas);

      expect(resumen.cantidadTransacciones, 7);
      expect(resumen.cantidadTransacciones, ventas.length);
    });
  });

  group('ResumenCorteCaja — Modelo', () {
    test('constructor asigna todos los campos', () {
      final resumen = ResumenCorteCaja(
        totalVentas: 100.0,
        cantidadTransacciones: 5,
        totalesPorMetodo: {'Efectivo': 100.0},
        conteoPorMetodo: {'Efectivo': 5},
      );

      expect(resumen.totalVentas, 100.0);
      expect(resumen.cantidadTransacciones, 5);
      expect(resumen.totalesPorMetodo['Efectivo'], 100.0);
      expect(resumen.conteoPorMetodo['Efectivo'], 5);
    });

    test('los mapas pueden estar vacíos', () {
      final resumen = ResumenCorteCaja(
        totalVentas: 0.0,
        cantidadTransacciones: 0,
        totalesPorMetodo: {},
        conteoPorMetodo: {},
      );

      expect(resumen.totalesPorMetodo, isEmpty);
      expect(resumen.conteoPorMetodo, isEmpty);
    });
  });
}