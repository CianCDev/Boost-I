// test/features/pos/comanda_cobro_utils_test.dart
//
// Criterios de cobro de una comanda. Son la base de la pestaña "Por cobrar"
// de la caja: si `listaParaCobrar` se equivoca, el cajero cobra una mesa
// que la cocina todavía no terminó (o deja de ver una que ya está lista).
import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/comanda_cobro_utils.dart';

CartSessionItem _item({
  EstadoPlato estado = EstadoPlato.listo,
  bool pausado = false,
  double cantidad = 1,
  String nombre = 'Plato',
}) {
  return CartSessionItem()
    ..productoId = 'uuid-$nombre'
    ..productoNombre = nombre
    ..productoCodigoBarras = '123'
    ..productoCategoria = 'Cocina'
    ..precioUnidad = 10
    ..precioOriginal = 12
    ..cantidad = cantidad
    ..estadoPlato = estado
    ..pausado = pausado;
}

CartSessionEntity _comanda(List<CartSessionItem> items) {
  final comanda = CartSessionEntity()..sessionId = 'mesa:1';
  comanda.items.addAll(items);
  return comanda;
}

void main() {
  group('conteos de cocina', () {
    test('enCocina cuenta enCola y enPreparacion', () {
      final comanda = _comanda([
        _item(estado: EstadoPlato.enCola),
        _item(estado: EstadoPlato.enPreparacion),
        _item(estado: EstadoPlato.listo),
        _item(estado: EstadoPlato.entregado),
        _item(estado: EstadoPlato.pendiente),
      ]);

      expect(ComandaCobroUtils.enCocina(comanda), 2);
    });

    test('enCocina cuenta los pausados aunque su estado sea pendiente', () {
      // Un plato pausado está BLOQUEADO, no fuera de cocina. Si no contara,
      // la caja dejaría cobrar una mesa con un plato detenido.
      final comanda = _comanda([
        _item(estado: EstadoPlato.pendiente, pausado: true),
      ]);

      expect(ComandaCobroUtils.enCocina(comanda), 1);
    });

    test('listos solo cuenta listo, nunca un pausado', () {
      final comanda = _comanda([
        _item(estado: EstadoPlato.listo),
        _item(estado: EstadoPlato.listo, pausado: true),
        _item(estado: EstadoPlato.entregado),
      ]);

      expect(ComandaCobroUtils.listos(comanda), 1);
    });

    test('sinEnviar cuenta solo pendiente', () {
      final comanda = _comanda([
        _item(estado: EstadoPlato.pendiente),
        _item(estado: EstadoPlato.pendiente),
        _item(estado: EstadoPlato.enCola),
      ]);

      expect(ComandaCobroUtils.sinEnviar(comanda), 2);
    });
  });

  group('listaParaCobrar', () {
    test('comanda vacía no está lista', () {
      expect(ComandaCobroUtils.listaParaCobrar(_comanda([])), isFalse);
    });

    test('todo listo o entregado está lista', () {
      final comanda = _comanda([
        _item(estado: EstadoPlato.listo),
        _item(estado: EstadoPlato.entregado),
      ]);

      expect(ComandaCobroUtils.listaParaCobrar(comanda), isTrue);
    });

    test('un plato en cocina la deja fuera', () {
      final comanda = _comanda([
        _item(estado: EstadoPlato.listo),
        _item(estado: EstadoPlato.enPreparacion),
      ]);

      expect(ComandaCobroUtils.listaParaCobrar(comanda), isFalse);
    });

    test('un plato sin enviar la deja fuera', () {
      final comanda = _comanda([
        _item(estado: EstadoPlato.entregado),
        _item(estado: EstadoPlato.pendiente),
      ]);

      expect(ComandaCobroUtils.listaParaCobrar(comanda), isFalse);
    });

    test('un pausado la deja fuera aunque el resto esté entregado', () {
      final comanda = _comanda([
        _item(estado: EstadoPlato.entregado),
        _item(estado: EstadoPlato.entregado, pausado: true),
      ]);

      expect(ComandaCobroUtils.listaParaCobrar(comanda), isFalse);
    });
  });

  group('aCarrito', () {
    test('preserva precio original, descuento, cantidad y estación', () {
      final item = _item(cantidad: 2.5, nombre: 'Lomo')
        ..esDescuentoEspecial = true
        ..esPesado = true
        ..estacionId = 7;

      final carrito = ComandaCobroUtils.aCarrito(_comanda([item]));

      expect(carrito, hasLength(1));
      final linea = carrito.single;
      expect(linea.producto.id, 'uuid-Lomo');
      expect(linea.producto.nombre, 'Lomo');
      expect(linea.producto.precioUnidad, 10);
      expect(linea.cantidad, 2.5);
      expect(linea.precioOriginal, 12);
      expect(linea.esDescuentoEspecial, isTrue);
      expect(linea.estacionId, 7);
    });

    test('no inventa líneas en una comanda vacía', () {
      expect(ComandaCobroUtils.aCarrito(_comanda([])), isEmpty);
    });
  });
}
