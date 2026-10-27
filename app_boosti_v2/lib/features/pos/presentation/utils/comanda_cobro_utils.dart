// lib/features/pos/presentation/utils/comanda_cobro_utils.dart
//
// Lógica pura de la comanda orientada al COBRO.
//
// Vive aquí y no en `ComandaScreen` porque ahora hay dos pantallas que
// cobran una comanda: la del mesero (`ComandaScreen._cobrar`) y la del
// cajero (`CajaScreen`). Duplicar el volcado de items o el criterio de
// "está lista para cobrar" garantiza que las dos se desincronicen a la
// primera regla nueva (por ejemplo, cuando aparezcan las reservas).
import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';

import '../../domain/models/cart_item.dart';
import '../../domain/models/product_item.dart';

/// Operaciones de lectura sobre una comanda, sin Isar ni Riverpod.
class ComandaCobroUtils {
  ComandaCobroUtils._();

  /// Platos que la cocina todavía no terminó: en cola o en preparación.
  ///
  /// Los pausados cuentan aquí a propósito: están bloqueados, no fuera de
  /// la cocina. Cobrar una mesa con un plato pausado es justo lo que el
  /// aviso de `ConfirmarCobroPendientesDialog` intenta evitar.
  static int enCocina(CartSessionEntity comanda) {
    return comanda.items.where((i) {
      if (i.pausado) return true;
      return i.estadoPlato == EstadoPlato.enCola ||
          i.estadoPlato == EstadoPlato.enPreparacion;
    }).length;
  }

  /// Platos terminados que nadie llevó a la mesa.
  static int listos(CartSessionEntity comanda) {
    return comanda.items
        .where((i) => !i.pausado && i.estadoPlato == EstadoPlato.listo)
        .length;
  }

  /// Platos que nunca salieron de la comanda (no están en cocina).
  static int sinEnviar(CartSessionEntity comanda) {
    return comanda.items
        .where((i) => i.estadoPlato == EstadoPlato.pendiente)
        .length;
  }

  /// `true` si no queda nada por servir.
  ///
  /// Es el criterio de la columna "Por cobrar" de la caja: todo `listo` o
  /// `entregado`, sin pausados. Una comanda con platos `pendiente` NO es
  /// cobrable sin avisar: esos platos ni siquiera llegaron a la cocina.
  static bool listaParaCobrar(CartSessionEntity comanda) {
    if (comanda.items.isEmpty) return false;
    for (final item in comanda.items) {
      if (item.pausado) return false;
      final estado = item.estadoPlato;
      if (estado != EstadoPlato.listo && estado != EstadoPlato.entregado) {
        return false;
      }
    }
    return true;
  }

  /// `true` si la comanda tiene algo que cobrar.
  static bool tieneConsumo(CartSessionEntity comanda) =>
      comanda.items.isNotEmpty;

  /// Convierte la comanda en items del carrito vivo del POS.
  ///
  /// Se preservan la estación y el descuento especial para que el cobro no
  /// pierda el destino de preparación ni el precio negociado. El IVA NO
  /// viaja en cada item: lo aplica el carrito con la configuración que se
  /// pasa a `reemplazarItems`.
  static List<CartItem> aCarrito(CartSessionEntity comanda) {
    return comanda.items
        .map(
          (s) => CartItem(
            producto: ProductItem(
              id: s.productoId,
              nombre: s.productoNombre,
              codigoBarras: s.productoCodigoBarras,
              categoria: s.productoCategoria,
              precioUnidad: s.precioUnidad,
              esPesado: s.esPesado,
            ),
            cantidad: s.cantidad,
            precioOriginal: s.precioOriginal,
            esDescuentoEspecial: s.esDescuentoEspecial,
            estacionId: s.estacionId,
          ),
        )
        .toList();
  }
}
