// test/features/pos/kds_pendientes_test.dart
//
// R.3.4 F.2.4 · `KdsTicket.pendientesPorEstado`.
//
// Tests 100% PUROS: sin Isar, sin Riverpod, sin widgets. `KdsTicket` y
// `KdsTicketItem` son clases de presentación inmutables, así que se
// construyen a mano y ya.
//
// ⚠️ POR QUÉ ESTA LÓGICA NO ESTÁ EN LA PANTALLA
//
// Estaba en `ComandaScreen._confirmarCobroConPendientes`, que es un método
// PRIVADO de un `ConsumerStatefulWidget`. Probarlo exigía montar la
// pantalla entera (con su `Timer.periodic`, su `addPostFrameCallback` y su
// I/O real contra Isar). Como propiedad del ticket, se prueba en 20 líneas
// y sin infraestructura.
//
// ⚠️ EL TEST QUE DE VERDAD IMPORTA
//
// 'mezcla de los 3 estados cuenta los dos a la vez'. La primera versión
// del conteo usaba un `switch` con `enCola`/`enPreparacion` en un `case` y
// `listo` en el siguiente **sin `break`**, copiando el patrón de un `switch`
// de C. En Dart un `switch` NO cae de un `case` al siguiente, así que
// `listos` salía 0 siempre que hubiera algo en cocina. Ese test es el que
// habría atrapado el bug.
import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/kds_ticket.dart';

/// Construye un item de ticket en un estado concreto.
///
/// El [indice] es el índice REAL dentro de la comanda; no lo usa el getter,
/// pero se fija para que los tests sean realistas.
KdsTicketItem item(
  EstadoPlato estado, {
  int indice = 0,
  bool pausado = false,
  String nombre = 'Plato',
}) {
  return KdsTicketItem(
    comandaId: 1,
    itemIndex: indice,
    item: CartSessionItem()
      ..productoNombre = nombre
      ..estadoPlato = estado
      ..pausado = pausado,
  );
}

/// Construye un ticket con los items dados, en orden.
KdsTicket ticket(List<KdsTicketItem> items) {
  return KdsTicket(
    comandaId: 1,
    mesaId: 1,
    mesaNombre: 'Mesa 1',
    items: items,
    pausados: items.where((i) => i.item.pausado).length,
  );
}

void main() {
  group('KdsTicket.pendientesPorEstado', () {
    // ── Un estado a la vez ──

    test('enCola cuenta como "en cocina"', () {
      final p = ticket([item(EstadoPlato.enCola)]).pendientesPorEstado;
      expect(p.enCocina, 1);
      expect(p.listos, 0);
    });

    test('enPreparacion cuenta como "en cocina"', () {
      final p = ticket([item(EstadoPlato.enPreparacion)]).pendientesPorEstado;
      expect(p.enCocina, 1);
      expect(p.listos, 0);
    });

    test('listo cuenta como "listo", NO como "en cocina"', () {
      final p = ticket([item(EstadoPlato.listo)]).pendientesPorEstado;
      expect(p.enCocina, 0);
      expect(p.listos, 1);
    });

    // ── El caso que caza el bug del switch sin break ──

    test('mezcla de los 3 estados cuenta los DOS a la vez', () {
      final p = ticket([
        item(EstadoPlato.enCola, indice: 0, nombre: 'Arroz'),
        item(EstadoPlato.enPreparacion, indice: 1, nombre: 'Sopa'),
        item(EstadoPlato.listo, indice: 2, nombre: 'Queso'),
      ]).pendientesPorEstado;

      // Sin este test, un `switch` sin `break` daría (2, 0) y pasaría
      // todos los casos de un estado a la vez.
      expect(p.enCocina, 2);
      expect(p.listos, 1);
    });

    test('varios enCola seguidos se acumulan', () {
      final p = ticket([
        item(EstadoPlato.enCola, indice: 0),
        item(EstadoPlato.enCola, indice: 1),
        item(EstadoPlato.enCola, indice: 2),
      ]).pendientesPorEstado;

      expect(p.enCocina, 3);
      expect(p.listos, 0);
    });

    // ── Pausados ──

    test('un pausado en enCola sigue contando como "en cocina"', () {
      // No está fuera de la cola: está BLOQUEADO. El diálogo de cobro tiene
      // que avisar de esto, que es justo lo que el getter habilita.
      final p = ticket([
        item(EstadoPlato.enCola, pausado: true, indice: 0),
      ]).pendientesPorEstado;

      expect(p.enCocina, 1);
      expect(p.listos, 0);
    });

    test('un pausado en listo cuenta como "listo"', () {
      final p = ticket([
        item(EstadoPlato.listo, pausado: true, indice: 0),
      ]).pendientesPorEstado;

      expect(p.enCocina, 0);
      expect(p.listos, 1);
    });

    // ── Estados que NO cuentan ──

    test('pendiente no cuenta (nunca se envió a cocina)', () {
      final p = ticket([item(EstadoPlato.pendiente)]).pendientesPorEstado;
      expect(p.enCocina, 0);
      expect(p.listos, 0);
    });

    test('entregado no cuenta', () {
      final p = ticket([item(EstadoPlato.entregado)]).pendientesPorEstado;
      expect(p.enCocina, 0);
      expect(p.listos, 0);
    });

    test('cancelado no cuenta', () {
      final p = ticket([item(EstadoPlato.cancelado)]).pendientesPorEstado;
      expect(p.enCocina, 0);
      expect(p.listos, 0);
    });

    test('un ticket vacío da (0, 0)', () {
      final p = ticket(const []).pendientesPorEstado;
      expect(p.enCocina, 0);
      expect(p.listos, 0);
    });

    test('solo los 3 estados invisibles no cuentan', () {
      final p = ticket([
        item(EstadoPlato.pendiente, indice: 0),
        item(EstadoPlato.entregado, indice: 1),
        item(EstadoPlato.cancelado, indice: 2),
      ]).pendientesPorEstado;

      expect(p.enCocina, 0);
      expect(p.listos, 0);
    });

    test('mezcla de visibles e invisibles solo cuenta los visibles', () {
      final p = ticket([
        item(EstadoPlato.entregado, indice: 0),
        item(EstadoPlato.enCola, indice: 1),
        item(EstadoPlato.cancelado, indice: 2),
        item(EstadoPlato.listo, indice: 3),
        item(EstadoPlato.pendiente, indice: 4),
        item(EstadoPlato.enPreparacion, indice: 5),
      ]).pendientesPorEstado;

      expect(p.enCocina, 2);
      expect(p.listos, 1);
    });

    // ── El getter no muta ni depende del orden ──

    test('el getter no depende del orden de los items', () {
      final a = ticket([
        item(EstadoPlato.enCola, indice: 0),
        item(EstadoPlato.listo, indice: 1),
      ]).pendientesPorEstado;

      final b = ticket([
        item(EstadoPlato.listo, indice: 1),
        item(EstadoPlato.enCola, indice: 0),
      ]).pendientesPorEstado;

      expect(a.enCocina, b.enCocina);
      expect(a.listos, b.listos);
    });

    test('el getter es idempotente: llamarlo dos veces da lo mismo', () {
      final t = ticket([
        item(EstadoPlato.enCola),
        item(EstadoPlato.listo),
      ]);

      expect(t.pendientesPorEstado.enCocina, 1);
      expect(t.pendientesPorEstado.enCocina, 1);
      expect(t.pendientesPorEstado.listos, 1);
      expect(t.pendientesPorEstado.listos, 1);
    });
  });
}
