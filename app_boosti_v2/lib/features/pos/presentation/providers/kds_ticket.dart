// lib/features/pos/presentation/providers/kds_ticket.dart
//
// R.3.2 · Modelo de presentación del KDS.
//
// ⚠️ POR QUÉ EXISTEN ESTAS CLASES
//
// En R.3.1, `ComandasNotifier.itemsEnColaPorEstacion()` devuelve
// `List<CartSessionItem>`: items SUELTOS, sin saber de qué comanda
// vienen. El KDS necesitagroupar por mesa y, sobre todo, necesita el
// `itemIndex` REAL (la posición dentro de `comanda.items`) para llamar a
// `marcarEnPreparacion(comandaId, itemIndex)`.
//
// Si el índice fuera la posición dentro de la lista filtrada, un toque
// avanzaría el plato equivocado. Por eso aquí se lleva el índice real
// calculado en el mismísimo bucle que recorre `comanda.items`.
import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';

/// Un plato dentro de un ticket, con su posicionamiento real en Isar.
class KdsTicketItem {
  /// Id de la comanda dueña. Se repite por item para que los botones no
  /// tengan que recibirlo aparte.
  final int comandaId;

  /// ⚠️ Índice REAL dentro de `comanda.items`. Es lo que aceptan
  /// `marcarEnPreparacion` / `marcarListo` / `marcarEntregado` /
  /// `pausarItem` / `reanudarItem`. NO es la posición en la lista filtrada.
  final int itemIndex;

  /// El item vivo. Se pasa por referencia al `CartSessionEntity` del
  /// estado, así que mutarlo sin `put()` no persistiría nada.
  final CartSessionItem item;

  const KdsTicketItem({
    required this.comandaId,
    required this.itemIndex,
    required this.item,
  });

  /// Minuto en el que este plato entró a la cola.
  ///
  /// `null` si nunca se envió, lo que en la práctica no debería pasar
  /// (solo llegan aquí items en `enCola`/`enPreparacion`/`listo`, y los 3
  /// se alcanzan siempre tras `enviarACocina`, que sella el timestamp).
  DateTime? get entradaEn => item.enviadoACocinaAt;

  /// Minutos que lleva en cola.
  int get minutosEnCola {
    final entrada = item.enviadoACocinaAt;
    if (entrada == null) return 0;
    return DateTime.now().difference(entrada).inMinutes;
  }

  /// A qué comanda de la lista de estados pertenece. Útil para evitar
  /// guardar el `comandaId` en el `Key` del widget.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KdsTicketItem &&
          other.comandaId == comandaId &&
          other.itemIndex == itemIndex);

  @override
  int get hashCode => Object.hash(comandaId, itemIndex);
}

/// Un ticket = una comanda = una mesa.
///
/// Agrupa todos los platos visibles en el KDS que pertenecen a la misma
/// comanda, para que el cocinero lea "Mesa 3" una vez y vea su pedido
/// completo debajo.
class KdsTicket {
  final int comandaId;
  final int? mesaId;

  /// Nombre de la mesa, o `"Para llevar"` si la comanda no está anclada a
  /// ninguna mesa (R.5, ventas directas).
  final String mesaNombre;

  /// Ítems visibles en cola de esta comanda, EN ORDEN DE COLA (FIFO).
  final List<KdsTicketItem> items;

  /// Los pausados van primero dentro del ticket.
  ///
  /// Razón: un plato pausado es el que está BLOQUEANDO el pedido. Si queda
  /// debajo de tres platos normales, se pierde de vista, y un plato
  /// parado es exactamente lo que hay que resolver ya.
  final int pausados;

  /// R.3.3 · Quién envió la comanda a cocina.
  ///
  /// Snapshot de `CartSessionEntity.meseroNombre` en el momento del envío
  /// (Q10). Va en el ticket IMPRESO ("Servicio: ian") para que, si un
  /// plato vuelve con una queja, el cocinero sepa a quién preguntar sin
  /// tener que abrir el salón.
  ///
  /// ⚠️ Opcional a propósito: los tickets que arma `ticketsEnCola` sobre
  /// comandas antiguas (R.2) pueden no tener mesero, y la pantalla del KDS
  /// no lo necesita para nada. Solo lo usa el ticket de papel.
  final String? meseroNombre;

  const KdsTicket({
    required this.comandaId,
    required this.mesaId,
    required this.mesaNombre,
    required this.items,
    required this.pausados,
    this.meseroNombre,
  });

  /// El item más viejo del ticket: el que define la urgencia del badge.
  DateTime? get entradaEn {
    DateTime? mejor;
    for (final i in items) {
      final t = i.entradaEn;
      if (t == null) continue;
      if (mejor == null || t.isBefore(mejor)) mejor = t;
    }
    return mejor;
  }

  /// Minutos que lleva el plato MÁS VIEJO de este ticket.
  int get minutosEnCola {
    final entrada = entradaEn;
    if (entrada == null) return 0;
    return DateTime.now().difference(entrada).inMinutes;
  }

  bool get tienePausados => pausados > 0;

  /// R.3.4 · Platos sin servir, partidos por estado.
  ///
  /// · `enCocina` cuenta `enCola` + `enPreparacion`: lo que la cocina tiene
  ///   entre manos, ya sea que empiece o que esté a medias.
  /// · `listos` cuenta `listo`: emplatado, esperando que alguien lo lleve.
  ///
  /// NO cuenta `pendiente` (nunca se envió), `entregado` (ya salió) ni
  /// `cancelado`. Aunque esos tres no deberían aparecer en `items` —los
  /// filtra `ticketsEnCola`—, se listan explícitamente para que el getter
  /// siga siendo correcto si alguien construye un `KdsTicket` a mano.
  ///
  /// ⚠️ Los PAUSADOS con estado `enCola`/`enPreparacion` **sí** cuentan
  /// como `enCocina`: no están fuera de la cola, están bloqueados. Por eso
  /// el diálogo de cobro avisa antes de cobrar una comanda con ellos.
  ({int enCocina, int listos}) get pendientesPorEstado {
    var enCocina = 0;
    var listos = 0;

    for (final entrada in items) {
      final estado = entrada.item.estadoPlato;
      if (estado == EstadoPlato.enCola ||
          estado == EstadoPlato.enPreparacion) {
        enCocina++;
      } else if (estado == EstadoPlato.listo) {
        listos++;
      }
    }

    return (enCocina: enCocina, listos: listos);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KdsTicket && other.comandaId == comandaId);

  @override
  int get hashCode => comandaId;
}

/// Orden FIFO: el ticket cuya cola es más antigua primero.
///
/// Un ticket sin `enviadoACocinaAt` (nunca enviado) va al final. A igual
/// timestamp, desempata la más antigua por `createdAt` implícito en el
/// orden estable de la entrada.
int compararTicketsPorAntiguedad(KdsTicket a, KdsTicket b) {
  final ta = a.entradaEn;
  final tb = b.entradaEn;

  if (ta == null && tb == null) return 0;
  if (ta == null) return 1;
  if (tb == null) return -1;

  return ta.compareTo(tb);
}
