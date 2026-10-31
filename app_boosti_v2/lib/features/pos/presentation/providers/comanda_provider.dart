// lib/features/pos/presentation/providers/comanda_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/descuento_lote_plan.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_inventario_entity.dart';

import '../controllers/cart_controller.dart';
import '../services/conversion_unidades.dart';
import '../services/ticket_cocina_service.dart';
import '../../domain/models/cart_item.dart';
import 'esc_pos_provider.dart';
import 'local_actual_provider.dart';
import 'kds_ticket.dart';
import 'departamentos_provider.dart';
import 'usuario_provider.dart';

// ══════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════
// RESULTADO DEL DESCUENTO DE RECETA (R.4 · G.3)
// ══════════════════════════════════════════════════════════════════

/// Qué pasó al descontar la receta de un plato entregado.
///
/// Es puro: no toca Isar, no es async y no muta nada. Existe para que el
/// KDS pueda pintar el aviso sin volver a preguntar por el stock.
class ResultadoDescuento {
  /// Nombres de los ingredientes que quedaron sin stock (pueden repetirse
  /// si el mismo ingrediente se quedó corto en varios lotes).
  final List<String> faltantes;

  /// Ingredientes no opcionales que sí se descontaron completos.
  final int descritos;

  const ResultadoDescuento({
    this.faltantes = const [],
    this.descritos = 0,
  });

  /// Lo que se devuelve cuando no había nada que descontar: producto sin
  /// receta, receta vacía, local sin id, producto aún no sincronizado…
  static const vacio = ResultadoDescuento();

  /// `true` si no faltó nada (incluye el caso [vacio]).
  bool get completo => faltantes.isEmpty;

  /// `true` si este resultado no aporta nada: niraven ni avisa.
  bool get esVacio => completo && descritos == 0;
}

// ══════════════════════════════════════════════════════════════════
// ESTADO
// ══════════════════════════════════════════════════════════════════

class ComandasState {
  /// Comandas vivas del local activo (abiertas + enviadas).
  final List<CartSessionEntity> comandas;

  /// Id (Isar) de la comanda con la que se está trabajando ahora.
  final int? comandaActivaId;

  final bool isLoading;
  final String? error;

  /// Último aviso de stock insuficiente al entregar un plato (G.3).
  ///
  /// Viaja en el ESTADO y no en un provider aparte a propósito: el KDS ya
  /// escucha `comandasProvider` con `ref.listenManual`, así que reutilizar
  /// ese canal no cuesta una suscripción más.
  ///
  /// Es `null` cuando no hay nada que avisar. El KDS solo pinta SnackBar
  /// cuando pasa de un valor a otro **distinto**: cada entrega produce una
  /// instancia nueva, así que dos avisos idénticos seguidos también entran.
  final ResultadoDescuento? avisoReceta;

  const ComandasState({
    this.comandas = const [],
    this.comandaActivaId,
    this.isLoading = true,
    this.error,
    this.avisoReceta,
  });

  ComandasState copyWith({
    List<CartSessionEntity>? comandas,
    int? comandaActivaId,
    bool limpiarActiva = false,
    bool? isLoading,
    String? error,
    bool limpiarError = false,
    ResultadoDescuento? avisoReceta,
    bool limpiarAvisoReceta = false,
  }) {
    return ComandasState(
      comandas: comandas ?? this.comandas,
      comandaActivaId:
          limpiarActiva ? null : (comandaActivaId ?? this.comandaActivaId),
      isLoading: isLoading ?? this.isLoading,
      error: limpiarError ? null : (error ?? this.error),
      avisoReceta: limpiarAvisoReceta
          ? null
          : (avisoReceta ?? this.avisoReceta),
    );
  }

  CartSessionEntity? get comandaActiva {
    if (comandaActivaId == null) return null;
    for (final c in comandas) {
      if (c.id == comandaActivaId) return c;
    }
    return null;
  }

  /// Comandas que siguen abiertas (ni enviadas ni cerradas ni canceladas).
  List<CartSessionEntity> get abiertas =>
      comandas.where((c) => c.comandaEstado == ComandaEstado.abierta).toList();

  List<CartSessionEntity> get enviadas =>
      comandas.where((c) => c.comandaEstado == ComandaEstado.enviada).toList();

  /// Comandas vivas = abiertas + enviadas (D2a).
  ///
  /// Es lo que refleja las mesas REALMENTE ocupadas: una comanda enviada a
  /// cocina sigue viva y su mesa sigue tomada.
  List<CartSessionEntity> get activas => [...abiertas, ...enviadas];

  // ══════════════════════════════════════════════════════════════
  // KDS · Derivados para la pantalla de cocina (R.3.2)
  //
  // Todos son PUROS: no tocan Isar, no son async y no mutan nada.
  // Eso es lo que permite que la pantalla use
  // `ref.watch(comandasProvider.select((s) => s.<algo>))`.
  // ══════════════════════════════════════════════════════════════

  /// Tickets del KDS, agrupados por comanda y ordenados FIFO.
  ///
  /// INCLUYE los items pausados (con su flag intacto): el KDS tiene que
  /// mostrarlos, solo que con otro visual. Lo que se excluye son los
  /// estados que ya no están en cocina (`pendiente`, `entregado`,
  /// `cancelado`).
  ///
  /// Incluye items con `estacionId == null`: van a la columna "Sin
  /// estación" del selector (ajuste 1 del usuario), nunca se descartan.
  List<KdsTicket> get ticketsEnCola {
    final tickets = <KdsTicket>[];

    for (final comanda in comandas) {
      final visibles = <KdsTicketItem>[];

      // `indexed` es lo que garantiza el `itemIndex` REAL: recorremos
      // `comanda.items` completo y solo FILTRAMOS qué entra al ticket.
      for (final entrada in comanda.items.indexed) {
        final item = entrada.$2;
        if (!IsarService.estadosVisiblesEnKds.contains(item.estadoPlato)) {
          continue;
        }
        visibles.add(KdsTicketItem(
          comandaId: comanda.id,
          itemIndex: entrada.$1,
          item: item,
        ));
      }

      if (visibles.isEmpty) continue;

      // Pausados primero: bloquean el pedido (ver `KdsTicket.pausados`).
      visibles.sort((a, b) {
        if (a.item.pausado == b.item.pausado) {
          final ta = a.entradaEn;
          final tb = b.entradaEn;
          if (ta == null && tb == null) return a.itemIndex - b.itemIndex;
          if (ta == null) return 1;
          if (tb == null) return -1;
          final cmp = ta.compareTo(tb);
          return cmp != 0 ? cmp : a.itemIndex - b.itemIndex;
        }
        return a.item.pausado ? -1 : 1;
      });

      tickets.add(KdsTicket(
        comandaId: comanda.id,
        mesaId: comanda.mesaId,
        mesaNombre: comanda.mesaNombre ?? 'Para llevar',
        items: visibles,
        pausados: visibles.where((i) => i.item.pausado).length,
      ));
    }

    tickets.sort(compararTicketsPorAntiguedad);
    return tickets;
  }

  /// Ítems en cola SIN contar los pausados. Es lo que muestra el badge
  /// del menú: un plato pausado no es trabajo pendiente de cocina, es un
  /// bloqueo que alguien tiene que resolver, y ensuciaría el contador.
  ///
  /// ⚠️ Devuelve un `int` A PROPÓSITO, no un `List`. Riverpod compara el
  /// resultado de `select()` con `==`, y dos listas nuevas nunca son
  /// iguales: devolver una lista haría que el menú se reconstruyera en
  /// bucle en cada frame.
  int get totalItemsEnKds {
    var total = 0;
    for (final comanda in comandas) {
      for (final item in comanda.items) {
        if (item.pausado) continue;
        if (IsarService.estadosVisiblesEnKds.contains(item.estadoPlato)) {
          total++;
        }
      }
    }
    return total;
  }
}

// ══════════════════════════════════════════════════════════════════
// NOTIFIER
// ══════════════════════════════════════════════════════════════════

class ComandasNotifier extends StateNotifier<ComandasState> {
  final IsarService _isar;
  final Ref _ref;

  /// Recarga al cambiar de local (patrón `mesasProvider`).
  late final ProviderSubscription<int?> _localSubscription;

  /// Persistencia continua: el carrito es la fuente de verdad (Fase 1).
  late final ProviderSubscription<CartState> _cartSubscription;

  Timer? _debounce;
  bool _persistiendo = false;

  /// Carga inicial en vuelo. Solo la consume [esperarCargaInicial].
  Future<void>? _cargaEnProgreso;

  /// Espera a que termine la carga que arranca en el constructor.
  ///
  /// Existe para los tests: el constructor llama a `cargar()` sin `await`,
  /// así que sin esto un test podría assertar sobre `state.comandas` antes
  /// de que se haya llenado. En producción no hace falta: la UI reacciona
  /// al provider, no al Future.
  Future<void> get esperarCargaInicial =>
      _cargaEnProgreso ?? Future<void>.value();

  /// Escribe el estado solo si el notifier sigue vivo.
  ///
  /// ⚠️POR QUÉ EXISTE ESTE WRAPPER (R.3.2):
  ///
  /// Hay 17 sitios que asignan `state`, casi todos dentro de métodos
  /// async que ya han hecho `await` sobre Isar. Si el notifier se dispone
  /// mientras tanto — un `container.dispose()` al final de un test, un
  /// logout, un hot-switch encadenado — la asignación directa lanza
  /// *"Bad state: Tried to use ComandasNotifier after dispose was called"*.
  ///
  /// Se podría poner `if (!mounted) return;` en cada uno, pero varios de
  /// esos métodos retornan `bool` / `String?` / `int?`, donde un `return;`
  /// desnudo no compila y haría falta un `return false;` o `return null;`
  /// que hay que acertar en 17 sitios. El wrapper devuelve `void`, así que
  /// el resto del método sigue su curso normal y compila en todos los casos.
  void _setState(ComandasState nuevo) {
    if (!mounted) return;
    state = nuevo;
  }

  /// `isar` es INYECTABLE (R.3.2) para que los tests puedan pasar un doble.
  ///
  /// Antes era `final IsarService _isar = IsarService()`, que dejaba al
  /// notifier imposible de testear: no había forma de sustituir la base de
  /// datos sin montar además `localActualProvider`, `authProvider` y
  /// `cartProvider`. Es el mismo patrón que `LocalActualNotifier` ya usaba
  /// desde R.2.
  ///
  /// El factory de abajo NO cambia: sigue sin pasar `isar` y usa el real.
  ComandasNotifier(this._ref, {IsarService? isar})
      : _isar = isar ?? IsarService(),
        super(const ComandasState()) {
    _localSubscription = _ref.listen(localActualProvider, (previous, next) {
      debugPrint('📍 [Comandas] Local cambiado: $previous → $next');
      cargar();
    });

    // ── R.2 Fase 1 · carrito → comanda ──
    //
    // El carrito manda. Cada vez que cambian sus items se volca a la
    // comanda activa, así que los productos sobreviven a la navegación por
    // el menú (que era el bug original).
    _cartSubscription = _ref.listen(cartProvider, (previous, next) {
      _alCambiarCarrito(next);
    });

    // Se guarda el Future para que `esperarCargaInicial` pueda.awaitar.
    _cargaEnProgreso = cargar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _localSubscription.close();
    _cartSubscription.close();
    super.dispose();
  }

  /// Reacción a cambios del carrito vivo.
  void _alCambiarCarrito(CartState cart) {
    // Retail o sin mesa asignada: nada que hacer. Early return explícito
    // para no ejecutar código de restaurante en el POS de retail.
    if (state.comandaActivaId == null) return;

    // Evita la reentrada: `guardarDesdeCarrito` limpia el carrito al
    // final, lo que dispararía este mismo listener otra vez.
    if (_persistiendo) return;

    // Carrito vacío = cobro completado. La mesa se libera sola.
    if (cart.items.isEmpty) {
      _debounce?.cancel();
      _desasignarPorCarritoVacio();
      return;
    }

    _programarPersistencia(cart);
  }

  /// Colapsa ráfagas de cambios en una sola escritura a Isar.
  void _programarPersistencia(CartState cart) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _volcarCarritoEnComanda(cart);
    });
  }

  /// Vuelca el carrito en la comanda activa. Sin snackbar ni UI.
  Future<void> _volcarCarritoEnComanda(CartState cart) async {
    if (cart.items.isEmpty) return;
    _persistiendo = true;
    try {
      // El debounce puede sobrevivir a un dispose si el timer ya disparó.
      if (!mounted) return;
      await guardarDesdeCarrito(
        items: await _mapearItems(cart.items),
        silencioso: true,
      );
    } finally {
      _persistiendo = false;
    }
  }

  /// El carrito se vació sin pasar por `cerrarComanda`: liberamos la mesa.
  Future<void> _desasignarPorCarritoVacio() async {
    final activa = state.comandaActiva;
    if (activa == null) return;
    try {
      if (!mounted) return;
      activa.comandaEstado = ComandaEstado.cerrada;
      activa.cerradaAt = DateTime.now();
      await _isar.guardarComanda(activa);
      await _liberarMesa(activa.mesaId);
      _setState(state.copyWith(limpiarActiva: true));
      await cargar();
    } catch (e) {
      debugPrint('⚠️ [Comandas] Error liberando mesa tras cobro: $e');
    }
  }

  /// `CartItem` → `CartSessionItem` (mapeo equivalente al de retail).
  ///
  /// ⚠️ ES `async` por el lookup de G.3, no por el mapeo en sí. Hace falta
  /// ir a la BD (`obtenerProductoPorSupabaseId`) porque `item.producto.id`
  /// es el UUID de **Supabase** y `RecetaEntity.productoId` es un id de
  /// **Isar**: sin el id local no hay forma de encontrar la receta de un
  /// item de comanda, y sin receta el plato no descuenta stock al
  /// entregarse.
  ///
  /// Se prefiere el lookup en BD a leer `productosProvider` porque ese state
  /// puede estar vacío (no se ha abierto el catálogo, arranque en frío) y
  /// entonces `productoIdLocal` quedaría `null` EN SILENCIO.
  Future<CartSessionItem> _cartItemToSessionItem(CartItem item) async {
    final productoLocal =
        await _isar.obtenerProductoPorSupabaseId(item.producto.id);

    return CartSessionItem()
      ..productoId = item.producto.id
      // G.3: id LOCAL de Isar. `null` si el producto no está en Isar
      // todavía; en ese caso no hay receta y no se descuenta nada.
      ..productoIdLocal = productoLocal?.id
      ..productoNombre = item.producto.nombre
      ..productoCodigoBarras = item.producto.codigoBarras
      ..productoCategoria = item.producto.categoria
      ..precioUnidad = item.producto.precioUnidad
      ..precioOriginal = item.precioOriginal
      ..cantidad = item.cantidad
      ..esPesado = item.producto.esPesado
      ..esDescuentoEspecial = item.esDescuentoEspecial
      // R.3: el KDS lee `estacionId` para saber a qué estación pertenece
      // este plato. Viene de `ProductoEntity.departamentoId` a través de
      // `CartItem.estacionId`. `null` en retail.
      ..estacionId = item.estacionId
      // R.3.2: snapshot de la imagen del producto.
      ..imagenUrl = item.imagenUrl;
  }

  /// Mapea una lista de `CartItem` a `CartSessionItem` en paralelo.
  ///
  /// Existe porque `_cartItemToSessionItem` es `async` (G.3) y ya no vale
  /// un `cart.items.map(...)`. `Future.wait` devuelve los resultados **en el
  /// orden de entrada**, así que el orden de los platos de la comanda se
  /// respeta igual que antes.
  Future<List<CartSessionItem>> _mapearItems(List<CartItem> items) async {
    if (items.isEmpty) return <CartSessionItem>[];
    return await Future.wait(items.map(_cartItemToSessionItem));
  }

  /// Copia a [nuevo] la trazabilidad de cocina de [previo].
  ///
  /// Se usa al re-volcar el carrito sobre una comanda ya enviada. Si el
  /// plato previo seguía en `pendiente` no hay nada que conservar (el
  /// `pendiente` es justo el valor por defecto del item nuevo), así que
  /// el método sale sin tocar nada.
  static void _conservarTrazabilidadCocina(
    CartSessionItem nuevo,
    CartSessionItem previo,
  ) {
    // La nota no viaja en el carrito (`CartItem` no la tiene): si el mesero
    // ya la escribió en la comanda, se conserva.
    nuevo.nota ??= previo.nota;
    nuevo.productoIdLocal ??= previo.productoIdLocal;
    nuevo.estacionId ??= previo.estacionId;
    nuevo.estacionNombre ??= previo.estacionNombre;

    if (previo.estadoPlato == EstadoPlato.pendiente && !previo.pausado) {
      return;
    }

    nuevo
      ..estadoPlato = previo.estadoPlato
      ..enviadoACocinaAt = previo.enviadoACocinaAt
      ..preparacionIniciadaAt = previo.preparacionIniciadaAt
      ..listoAt = previo.listoAt
      ..entregadoAt = previo.entregadoAt
      ..pausado = previo.pausado
      ..pausadoEn = previo.pausadoEn
      ..motivoPausa = previo.motivoPausa;
  }

  /// `sessionId` determinístico de una mesa.
  ///
  /// Delega en la entidad: `SyncService` usa el mismo builder al bajar
  /// comandas creadas en otro dispositivo (R.1c).
  static String sessionIdDeMesa(int mesaId) =>
      CartSessionEntity.sessionIdDeMesa(mesaId);

  // ── Carga ───────────────────────────────────────────────────────

  Future<void> cargar() async {
    _setState(state.copyWith(isLoading: true));
    try {
      final localId = _ref.read(localActualProvider);
      if (localId == null) {
        _setState(const ComandasState(isLoading: false));
        return;
      }
      final comandas = await _isar.obtenerComandasDeLocal(localId);
      _setState(state.copyWith(
            comandas: comandas,
            isLoading: false,
            limpiarError: true,
          ));
    } catch (e) {
      debugPrint('❌ [Comandas] Error cargando: $e');
      _setState(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
   /// Refresca UNA comanda del state sin recargar el resto.
  ///
  /// Versión eficiente de [cargar] para mutaciones que solo cambian items
  /// DENTRO de una comanda existente y viva (pausar, avanzar estado, editar
  /// cantidad/nota, volcar carrito, enviar a cocina).
  ///
  /// ⚠️ NO usar para cambios ESTRUCTURALES. Si la comanda se crea, se
  /// cierra, se cancela o se mueve a otra mesa, hay que llamar a [cargar]
  /// completo: la lista de "vivas del local" cambia de composición y la
  /// comanda puede tener que salir de `state.comandas`.
  ///
  /// 🎯 Por qué existe (perf del KDS):
  /// `cargar()` dispara `obtenerComandasDeLocal` (2 queries + filtro de
  /// 30-100 comandas) y hace DOS `_setState` (`isLoading: true` y
  /// `isLoading: false`). Eso reconstruye todo el árbol del KDS aunque
  /// solo haya cambiado UN item de UNA comanda. Con 100 items en pantalla,
  /// tocar [Preparar] se siente lento.
  ///
  /// Este método:
  ///  · hace UNA sola query (por id, indexada),
  ///  · NO toca `isLoading` (sin flicker de spinner),
  ///  · actualiza in-place (los demás elementos de la lista son los
  ///    MISMOS objetos, así que los widgets que usen `select` sobre su
  ///    comanda no se re-renderizan).
  Future<void> _refrescarComandaEnState(int comandaId) async {
    try {
      final fresca = await _isar.obtenerComandaPorId(comandaId);
      if (!mounted) return;

      // Caso 1: la comanda ya no existe (borrada o purgada desde otro
      // dispositivo). La quitamos si estaba en la lista.
      // Caso 2: existe pero ya no está viva (cerrada/cancelada por otra
      // vía, p. ej. `_desasignarPorCarritoVacio` disparado por el carrito
      // vacío). La quitamos: `state.comandas` es la lista de VIVAS.
      final debeSalir = fresca == null ||
          fresca.comandaEstado == ComandaEstado.cerrada ||
          fresca.comandaEstado == ComandaEstado.cancelada;

      if (debeSalir) {
        final lista = state.comandas
            .where((c) => c.id != comandaId)
            .toList(growable: false);
        _setState(state.copyWith(comandas: lista));
        return;
      }

      // Actualización in-place: preserva el orden de la lista y evita
      // reconstruir el widget tree entero si Riverpod compara por
      // identidad (los demás elementos de la lista son los MISMOS objetos,
      // así que sus widgets no se re-renderizan si usan `select`).
      final lista = [...state.comandas];
      final idx = lista.indexWhere((c) => c.id == comandaId);
      if (idx >= 0) {
        lista[idx] = fresca;
      } else {
        lista.add(fresca);
      }
      _setState(state.copyWith(comandas: lista));
    } catch (e) {
      // Ante duda, no ensuciamos el state: la próxima llamada a `cargar()`
      // (local cambiado, o `onDataChanged` de sync) reconcilia.
      debugPrint('❌ [Comandas] Error refrescando comanda $comandaId: $e');
    }
  }

  // ── Abrir / retomar ──────────────────────────────────────────────

  /// Abre (o retoma) la comanda de una mesa.
  ///
  /// Idempotente: si ya existe una comanda viva para esa mesa, la retorna
  /// sin duplicar. Devuelve el id de la sesión, o null si falló.
  Future<int?> abrirComanda(
    int mesaId, {
    ClienteEntity? cliente,
  }) async {
    try {
      final sessionId = sessionIdDeMesa(mesaId);

      // 1. ¿Ya existe una comanda viva para esta mesa?
      final existente = await _isar.obtenerComandaPorSessionId(sessionId);
      if (existente != null) {
        _setState(state.copyWith(comandaActivaId: existente.id));
        await _marcarMesaOcupada(mesaId);
        await cargar();
        return existente.id;
      }

      // 2. Crear una nueva.
      final localId = _ref.read(localActualProvider);
      if (localId == null) {
        return _fallar(
            'No hay local activo. No se puede abrir una comanda.');
      }

      final mesa = await _isar.obtenerMesaPorId(mesaId);
      if (mesa == null) {
        return _fallar('La mesa ya no existe.');
      }

      final usuario = _ref.read(usuarioActualProvider);
      final ahora = DateTime.now();

      final comanda = CartSessionEntity()
        ..sessionId = sessionId
        ..usuarioId = usuario?.id ?? 0
        ..nombre = 'Comanda ${mesa.nombre}'
        ..mesaId = mesaId
        ..mesaNombre = mesa.nombre
        ..comandaEstado = ComandaEstado.abierta
        ..meseroId = usuario?.id
        ..meseroNombre = usuario?.nombre
        ..comensales = 1
        ..clienteIsarId = cliente?.id
        ..clienteNombre = cliente?.nombre
        ..items = <CartSessionItem>[]
        ..itemsNombres = <String>[]
        ..createdAt = ahora
        ..updatedAt = ahora;

      final id = await _isar.guardarComanda(comanda);
      await _marcarMesaOcupada(mesaId);
      await cargar();
      _setState(state.copyWith(comandaActivaId: id));
      return id;
    } catch (e) {
      debugPrint('❌ [Comandas] Error abriendo: $e');
      _setState(state.copyWith(error: e.toString()));
      return null;
    }
  }

  /// Vuelca el carrito vivo dentro de la comanda activa y lo vacía.
  ///
  /// Flujo: ComandaScreen empuja `InventoryCatalogScreen`, el usuario añade
  /// productos al `cartProvider`, y al volver llamamos a esto.
  Future<bool> guardarDesdeCarrito({
    required List<CartSessionItem> items,
    bool silencioso = false,
  }) async {
    try {
      final activa = state.comandaActiva;
      if (activa == null) {
        return _fallarBool('No hay ninguna comanda abierta.');
      }
      if (!activa.comandaEditable) {
        return _fallarBool('Esta comanda ya no admite cambios.');
      }

      // ⚠️ No pisar lo que la cocina ya avanzó.
      //
      // `_cartItemToSessionItem` siempre construye items en `pendiente`.
      // Si la comanda ya se envió y el mesero vuelve a tocar el carrito
      // (agrega una bebida), un volcado a ciegas devolvería a `pendiente`
      // los platos que ya están en cola, en preparación o entregados:
      // reaparecerían en el KDS como nuevos y se cocinarían dos veces.
      final previos = <String, CartSessionItem>{
        for (final p in activa.items) p.productoId: p,
      };
      for (final item in items) {
        final previo = previos[item.productoId];
        if (previo != null) _conservarTrazabilidadCocina(item, previo);
      }

      activa.items = items;
      activa.itemsNombres = items.map((i) => i.productoNombre).toList();

      // Congelar el IVA del carrito vivo, igual que hace el parkear de retail.
      final cart = _ref.read(cartProvider);
      activa.configIvaPais = cart.configIva.codigoPais;
      activa.configIvaPorcentaje = cart.configIva.porcentajeIva;
      activa.configIvaPreciosIncluyenIva = cart.configIva.preciosIncluyenIva;
      activa.ivaHabilitado = cart.ivaHabilitado;

      await _isar.guardarComanda(activa);

      // ⚠️ En modo continuo (`silencioso: true`) NO se vacía el carrito:
      // el carrito es la fuente de verdad y la comanda solo lo espeja.
      // Vaciarlo aquí borraría los productos del POS, que es justo el bug
      // que R.2 Fase 1 vino a arreglar.
      if (!silencioso) {
        _ref.read(cartProvider.notifier).limpiarCarrito();
      }
      // Si `silencioso == false`, `limpiarCarrito()` dispara
      // `_desasignarPorCarritoVacio` (async, fire-and-forget). Esa ruta
      // cierra la comanda y hace su propio `cargar()`. Aquí usamos el
      // refresh puntual: si `_desasignarPorCarritoVacio` ya cerró la
      // comanda, `_refrescarComandaEnState` la quita del listado; si aún
      // no, la actualiza. Ambos caminos son correctos.
      await _refrescarComandaEnState(activa.id);
      return true;
    } catch (e) {
      debugPrint('❌ [Comandas] Error guardando desde carrito: $e');
      _setState(state.copyWith(error: e.toString()));
      return false;
    }
  }

  // ── Asignación de mesa (Fase 1) ───────────────────────────────────

  /// Asigna el carrito vivo a una mesa.
  ///
  /// UX-1: si la mesa ya tiene comanda, los items del carrito se AÑADEN a
  /// esa comanda en vez de crear una nueva.
  ///
  /// Devuelve un mensaje para el snackbar, o null si todo fue bien.
  Future<String?> asignarMesa(int mesaId) async {
    try {
      if (_ref.read(localActualProvider) == null) {
        return 'No hay local activo.';
      }

      final mesa = await _isar.obtenerMesaPorId(mesaId);
      if (mesa == null) return 'La mesa ya no existe.';

      final cart = _ref.read(cartProvider);
      final sessionId = sessionIdDeMesa(mesaId);
      final esRetoma =
          await _isar.obtenerComandaPorSessionId(sessionId) != null;

      // Crear o retomar la comanda. `abrirComanda` ya es idempotente,
      // marca la mesa como ocupada y apunta `comandaActivaId`.
      if (await abrirComanda(mesaId) == null) {
        return 'No se pudo abrir la comanda.';
      }

      if (cart.items.isEmpty) {
        return esRetoma ? 'Continuando la comanda de ${mesa.nombre}' : null;
      }

      final nuevos = await _mapearItems(cart.items);

      if (esRetoma) {
        final ok = await _agregarItemsAComanda(nuevos);
        if (!ok) {
          return 'La comanda de ${mesa.nombre} ya no admite cambios.';
        }
        return 'Se añadieron ${cart.items.length} producto(s) '
            'a ${mesa.nombre}';
      }

      // Comanda nueva: volcado completo con el IVA del carrito congelado.
      final ok = await guardarDesdeCarrito(items: nuevos, silencioso: true);
      return ok ? null : 'No se pudo guardar la comanda.';
    } catch (e) {
      debugPrint('❌ [Comandas] Error asignando mesa: $e');
      _setState(state.copyWith(error: e.toString()));
      return 'No se pudo asignar la mesa.';
    }
  }

  /// UX-1: AÑADE los items del carrito a la comanda activa, fusionando por
  /// producto (misma lógica que `agregarProducto` del carrito vivo).
  ///
  /// No reemplaza: lo ya añadido se conserva.
  Future<bool> _agregarItemsAComanda(List<CartSessionItem> nuevos) async {
    final activa = state.comandaActiva;
    if (activa == null) return false;
    if (!activa.comandaEditable) return false;
    if (nuevos.isEmpty) return true;

    final items = List<CartSessionItem>.from(activa.items);

    for (final nuevo in nuevos) {
      final idx = items.indexWhere((x) => x.productoId == nuevo.productoId);
      if (idx >= 0) {
        items[idx].cantidad += nuevo.cantidad;
      } else {
        items.add(nuevo);
      }
    }

    activa.items = items;
    activa.itemsNombres = items.map((i) => i.productoNombre).toList();
    await _isar.guardarComanda(activa);
    await _refrescarComandaEnState(activa.id);
    return true;
  }

  /// UX-2: mueve la comanda activa a otra mesa. Los items van intactos.
  ///
  /// Si no hay comanda activa, se comporta como `asignarMesa`.
  Future<String?> cambiarMesa(int nuevoMesaId) async {
    if (state.comandaActivaId == null) {
      return asignarMesa(nuevoMesaId);
    }

    try {
      final activa = state.comandaActiva;
      if (activa == null) return 'No hay ninguna comanda activa.';

      final nueva = await _isar.obtenerMesaPorId(nuevoMesaId);
      if (nueva == null) return 'La mesa ya no existe.';

      final mesaViejaId = activa.mesaId;
      final nombreViejo = activa.mesaNombre;

      // ⚠️ `sessionId` es determinístico (`mesa:<id>`) y tiene índice
      // ÚNICO. Si se mueve la comanda sin recalcularlo, queda una comanda
      // "fantasma" ligada a la mesa vieja (abrir esa mesa entonces retoma
      // una comanda que pertenece a otra). Y si el destino ya tiene una
      // comanda viva, el índice único con `replace: true` borraría una de
      // las dos en silencio al guardar, así que se rechaza el destino
      // ocupado antes de tocar nada.
      if (nuevoMesaId != mesaViejaId) {
        final enDestino =
            await _isar.obtenerComandaPorSessionId(sessionIdDeMesa(nuevoMesaId));
        if (enDestino != null && enDestino.id != activa.id) {
          return '${nueva.nombre} ya tiene una comanda abierta.';
        }
      }

      // La comanda se mueve: actualizamos el destino y su sessionId.
      // Se relee de Isar antes de escribir: si la cocina avanzó algún plato
      // mientras el diálogo estaba abierto, guardar la copia del estado lo
      // devolvería a `pendiente`.
      final fresca = await _isar.obtenerComandaPorId(activa.id) ?? activa;
      fresca.mesaId = nuevoMesaId;
      fresca.mesaNombre = nueva.nombre;
      fresca.nombre = 'Comanda ${nueva.nombre}';
      fresca.sessionId = sessionIdDeMesa(nuevoMesaId);
      await _isar.guardarComanda(fresca);

      await _marcarMesaOcupada(nuevoMesaId);
      if (mesaViejaId != null && mesaViejaId != nuevoMesaId) {
        await _liberarMesa(mesaViejaId);
      }

      await cargar();
      _setState(state.copyWith(comandaActivaId: activa.id));

      final movida = mesaViejaId != null &&
          mesaViejaId != nuevoMesaId &&
          nombreViejo != null;
      if (movida) {
        return 'Comanda movida de $nombreViejo a ${nueva.nombre}';
      }
      return 'Comanda asignada a ${nueva.nombre}';
    } catch (e) {
      debugPrint('❌ [Comandas] Error cambiando de mesa: $e');
      _setState(state.copyWith(error: e.toString()));
      return 'No se pudo cambiar de mesa.';
    }
  }

  /// Quita la mesa. La comanda se cancela y la mesa queda libre.
  ///
  /// D3a: el carrito NO se toca. Pasa a ser una venta directa.
  Future<bool> desasignarMesa() async {
    try {
      final activa = state.comandaActiva;
      if (activa == null) {
        _setState(state.copyWith(limpiarActiva: true));
        return true;
      }

      activa.comandaEstado = ComandaEstado.cancelada;
      activa.cerradaAt = DateTime.now();
      await _isar.guardarComanda(activa);
      await _liberarMesa(activa.mesaId);

      _setState(state.copyWith(limpiarActiva: true));
      await cargar();
      return true;
    } catch (e) {
      debugPrint('⚠️ [Comandas] Error desasignando mesa: $e');
      return false;
    }
  }

  /// D1 · Cancela la comanda activa (usado por el dialog de mesa).
  Future<bool> cancelarComandaActiva() async {
    final activa = state.comandaActiva;
    if (activa == null) return false;
    return cancelarComanda();
  }

  // ── KDS · Ciclo de estados de los platos (R.3) ──────────────────

  /// Transiciones VÁLIDAS del ciclo de cocina.
  ///
  /// `entregado` y `cancelado` son terminales: un plato que ya salió de
  /// cocina o fue cancelado no puede volver atrás. Sin esta matriz, un
  /// doble toque en el KDS podría resucitar un plato entregado.
  static const transicionesValidas = <EstadoPlato, Set<EstadoPlato>>{
    EstadoPlato.pendiente: <EstadoPlato>{
      EstadoPlato.enCola,
      EstadoPlato.cancelado,
    },
    EstadoPlato.enCola: <EstadoPlato>{
      EstadoPlato.enPreparacion,
      EstadoPlato.cancelado,
    },
    EstadoPlato.enPreparacion: <EstadoPlato>{
      EstadoPlato.listo,
      EstadoPlato.cancelado,
    },
    EstadoPlato.listo: <EstadoPlato>{
      EstadoPlato.entregado,
      EstadoPlato.cancelado,
    },
    EstadoPlato.entregado: <EstadoPlato>{},
    EstadoPlato.cancelado: <EstadoPlato>{},
  };

  /// ¿Se puede pasar de `actual` a `nuevo`?
  ///
  /// Puro, sin Isar. Lo usan los 3 métodos de advancement y los tests.
  static bool transicionValida(EstadoPlato actual, EstadoPlato nuevo) {
    return transicionesValidas[actual]?.contains(nuevo) ?? false;
  }

  /// Envía a cocina los platos que siguen `pendiente`.
  ///
  /// D3b: la firma cambió de `Future<bool>` a
  /// `Future<List<CartSessionItem>?>`. Devuelve los platos que ENTRARON
  /// a la cola, para que R.3.3 pueda imprimir el ticket de cocina. `null`
  /// = error (ya mostrado vía `_fallarBool`).
  ///
  /// Idempotente: si no queda ningún `pendiente`, devuelve `null` sin
  /// tocar nada, así que un doble toque no duplica la cola.
  Future<List<CartSessionItem>?> enviarACocina() async {
    final activa = state.comandaActiva;
    if (activa == null) {
      _fallarBool('No hay ninguna comanda abierta.');
      return null;
    }
    if (activa.items.isEmpty) {
      _fallarBool('La comanda está vacía.');
      return null;
    }

    // Copia ANTES de mutar: son los platos que entran a la cola.
    final enviada = activa.items
        .where((i) => i.estadoPlato == EstadoPlato.pendiente)
        .toList();

    if (enviada.isEmpty) {
      _fallarBool('No hay platos pendientes de enviar.');
      return null;
    }

    final usuario = _ref.read(usuarioActualProvider);
    final ahora = DateTime.now();

    // Marca los items en la cola (lectura + put de la comanda entera,
    // porque `CartSessionItem` es `@embedded`).
    final marcados = await _isar.marcarPendientesComoEnCola(activa.id, ahora);
    if (marcados == 0) {
      _fallarBool('No hay platos pendientes de enviar.');
      return null;
    }

    // ⚠️ RELEER antes de volver a guardar.
    //
    // `marcarPendientesComoEnCola` escribió sobre OTRA instancia (la que
    // leyó dentro de su `writeTxn`), no sobre `activa`. Si guardáramos
    // `activa` aquí, su lista de items —todavía en `pendiente`— pisaría
    // el `enCola` recién escrito y el KDS nunca vería el pedido. Es el
    // bug "envío a cocina, se imprime el ticket, pero el preparador
    // sigue vacío".
    final actualizada = await _isar.obtenerComandaPorId(activa.id);
    if (actualizada == null) {
      _fallarBool('La comanda ya no existe.');
      return null;
    }

    actualizada.comandaEstado = ComandaEstado.enviada;
    actualizada.enviadaCocinaAt = ahora;
    // Q10: snapshot del mesero al enviar.
    actualizada.meseroId = usuario?.id ?? actualizada.meseroId;
    actualizada.meseroNombre = usuario?.nombre ?? actualizada.meseroNombre;

     await _isar.guardarComanda(actualizada);
    await _refrescarComandaEnState(activa.id);


    // ── R.3.3 · Ticket de cocina ──
    //
    // Va DESPUÉS de `cargar()` a propósito: si la impresión fuera antes y
    // `cargar()` fallara, la comanda ya se habría marcado en Isar y el
    // mesero vería "no se pudo enviar" con los platos realmente en cola.
    // Aquí el estado ya está commiteado y la impresión es un extra.
    _imprimirTicketCocina(activa, enviada);

    return enviada;
  }

  /// Imprime el ticket de cocina de lo recién enviado. Nunca falla.
  ///
  /// ⚠️ `unawaited` + `try/catch` a propósito: la comanda YA está en la
  /// cola de Isar en este punto. Si la impresora no tiene papel, está
  /// apagada o no hay ninguna configurada, el mesero tiene que poder
  /// seguir trabajando igual — el ticket en papel es una comodidad, no un
  /// paso del flujo.
  ///
  /// Devuelve `void` a propósito: el único caller (`enviarACocina`) no
  /// puede actuar sobre el resultado, así que devolverlo solo tentaría a
  /// alguien a esperarlo.
  void _imprimirTicketCocina(
    CartSessionEntity comanda,
    List<CartSessionItem> enviados,
  ) {
    if (enviados.isEmpty) return;

    // El índice REAL de cada item dentro de `comanda.items`. No puede
    // usarse la posición dentro de `enviados`: si la comanda tenía
    // platos ya enviados antes, esos van delante y un índice 0 aquí
    // apuntaría al plato equivocado.
    final items = <KdsTicketItem>[];
    for (final item in enviados) {
      final indice = comanda.items.indexOf(item);
      // -1 = el item ya no está en la comanda (carrera con un cobro
      // concurrente). Se salta en vez de imprimir un índice inválido.
      if (indice < 0) continue;
      items.add(KdsTicketItem(
        comandaId: comanda.id,
        itemIndex: indice,
        item: item,
      ));
    }

    if (items.isEmpty) return;

    final ticket = KdsTicket(
      comandaId: comanda.id,
      mesaId: comanda.mesaId,
      mesaNombre: comanda.mesaNombre ?? 'Sin mesa',
      items: items,
      // Recién enviados: no hay pausas que contar. Es `0` explícito y no
      // un `items.where(...)` porque el KDS solo pinta este ticket en
      // papel, nunca en pantalla.
      pausados: 0,
      meseroNombre: comanda.meseroNombre,
    );

    try {
      final impresora = _ref.read(printerProvider)?.device;

      unawaited(
        TicketCocinaService.procesarEnvio(
          ticket,
          impresora: impresora,
        ).then((resultado) {
          if (!resultado.impreso && impresora != null) {
            debugPrint('[Cocina] No se pudo imprimir: ${resultado.error}');
          }
          if (resultado.rutaPdf != null) {
            debugPrint('[Cocina] PDF: ${resultado.rutaPdf}');
          }
        }),
      );
    } catch (e) {
      // Sin impresora configurada, `procesarEnvio` no lanza: devuelve
      // impreso=false. Este try/catch es para el resto (provider caído).
      debugPrint('⚠️ [Cocina] No se pudo lanzar la impresión: $e');
    }
  }

  /// El cocinero toma el plato.
  Future<bool> marcarEnPreparacion(int comandaId, int itemIndex) {
    return _avanzarEstado(comandaId, itemIndex, EstadoPlato.enPreparacion);
  }

  /// El cocinero terminó el plato.
  Future<bool> marcarListo(int comandaId, int itemIndex) {
    return _avanzarEstado(comandaId, itemIndex, EstadoPlato.listo);
  }

  // ── R.3.2 · Pausa ────────────────────────────────────────────────

  /// Tope del motivo de pausa.
  ///
  /// Va aquí y no en la vista a propósito: si el KDS truncara al
  /// escribir, dos motivos distintos ("falta pescado" / "falta pescado
  /// fresco") acabarían guardando el mismo texto, y el cocinero no
  /// podría distinguirlos al retomar el plato.
  static const maxCharsMotivoPausa = 60;

  /// Pausa un plato: falta ingrediente, hay que esperar, error de equipo.
  ///
  /// Solo se puede pausar lo que está EN MARCHA. Un plato ya `listo` o
  /// `entregado` no se pausa: ya no hay nada que detener. Y uno `pendiente`
  /// tampoco, porque aún no ha salido de la barra.
  Future<bool> pausarItem(
    int comandaId,
    int itemIndex,
    String? motivo,
  ) async {
    final comanda = await _isar.obtenerComandaPorId(comandaId);
    if (comanda == null) {
      return _fallarBool('La comanda ya no existe.');
    }
    if (itemIndex < 0 || itemIndex >= comanda.items.length) {
      return _fallarBool('Ese plato no existe en la comanda.');
    }

    final item = comanda.items[itemIndex];

    if (!estadoPlatoPausable(item.estadoPlato)) {
      return _fallarBool(
        'No se puede pausar un plato en estado ${item.estadoPlato.name}.',
      );
    }

    final id = await _isar.actualizarPausaItem(
      comandaId,
      itemIndex,
      pausado: true,
      motivo: normalizarMotivoPausa(motivo),
    );
     if (id == -1) {
      return _fallarBool('No se pudo pausar el plato.');
    }

    await _refrescarComandaEnState(comandaId);
    return true;
  }


  /// Reanuda un plato pausado. Limpia `pausado`, `pausadoEn` y
  /// `motivoPausa`, y NO toca el `estadoPlato` (un plato pausado en
  /// preparación sigue en preparación al reanudarse).
  Future<bool> reanudarItem(int comandaId, int itemIndex) async {
    final comanda = await _isar.obtenerComandaPorId(comandaId);
    if (comanda == null) {
      return _fallarBool('La comanda ya no existe.');
    }
    if (itemIndex < 0 || itemIndex >= comanda.items.length) {
      return _fallarBool('Ese plato no existe en la comanda.');
    }

    if (!comanda.items[itemIndex].pausado) {
      return _fallarBool('Ese plato no está pausado.');
    }

    final id = await _isar.actualizarPausaItem(
      comandaId,
      itemIndex,
      pausado: false,
    );
     if (id == -1) {
      return _fallarBool('No se pudo reanudar el plato.');
    }

    await _refrescarComandaEnState(comandaId);
    return true;
  }

  /// ¿Un plato en este estado se puede pausar?
  ///
  /// Puro, para los tests. `listo` y `entregado` quedan fuera a
  /// propósito: ya salieron (o están a punto de salir) de cocina.
  static bool estadoPlatoPausable(EstadoPlato estado) {
    return estado == EstadoPlato.enCola ||
        estado == EstadoPlato.enPreparacion;
  }

  /// Limpia el motivo: recorta espacios y corta al tope.
  ///
  /// Vacío o solo espacios se convierte en `null`, que es lo que
  /// `actualizarPausaItem` guarda para un plato pausado sin motivo.
  ///
  /// Es público y estático a propósito: es lógica pura y el diálogo de
  /// pausa del KDS necesita el mismo recorte para no dejar al usuario
  /// escribir 300 caracteres que luego se cortan solos.
  static String? normalizarMotivoPausa(String? motivo) {
    if (motivo == null) return null;
    final limpio = motivo.trim();
    if (limpio.isEmpty) return null;
    if (limpio.length <= maxCharsMotivoPausa) return limpio;
    return limpio.substring(0, maxCharsMotivoPausa);
  }

  /// El plato salió de cocina hacia la mesa (P7: lo marca el cocinero).
  Future<bool> marcarEntregado(int comandaId, int itemIndex) {
    return _avanzarEstado(comandaId, itemIndex, EstadoPlato.entregado);
  }

  // ── R.3.2 · Edición del pedido desde ComandaScreen ───────────────

  /// ¿Este item se puede editar (cantidad, nota)?
  ///
  /// Regla de P1 ("las comandas son modificables solo si el pedido no está
  /// en listo"), aplicada **por fila**, no por comanda: un plato ya `listo`
  /// bloquea solo su propia línea, y el resto del pedido sigue editable.
  ///
  /// Los tres estados excluidos:
  ///   · `listo`     → ya está cocinado; cambiar la cantidad ya no sirve.
  ///   · `entregado` → salió hacia la mesa.
  ///   · `cancelado` → el mesero lo quitó de la barra.
  ///
  /// Puro y estático: lo usan los tests y la UI para decidir si pinta los
  /// controles habilitados, sin necesidad de una llamada async.
  static bool puedeEditarItem(CartSessionItem item) {
    return item.estadoPlato != EstadoPlato.listo &&
        item.estadoPlato != EstadoPlato.entregado &&
        item.estadoPlato != EstadoPlato.cancelado;
  }

  /// Cantidad mínima de un item: 1 para productos normales, 0.001 kg
  /// para los que se venden por peso.
  static double minimoCantidadItem(bool esPesado) =>
      esPesado ? 0.001 : 1.0;

  /// Tope de la nota por ítem. Distinto del de la pausa (60) a propósito:
  /// una nota es texto para el cocinero ("sin cebolla,servir caliente"),
  /// un motivo de pausa es una causa corta ("falta pescado").
  static const maxCharsNotaItem = 100;

  /// Cambia la cantidad de un item editable.
  ///
  /// Clampea al mínimo en vez de eliminar la línea (decisión D2a): borrar
  /// un item desplaza los índices de todos los siguientes, y si el cocinero
  /// tiene el KDS abierto le cambia el plato que tenía bajo el dedo.
  ///
  /// `delta` puede ser negativo para restar.
  Future<bool> cambiarCantidadItem(
    int comandaId,
    int itemIndex,
    double delta,
  ) async {
    final comanda = await _isar.obtenerComandaPorId(comandaId);
    if (comanda == null) {
      return _fallarBool('La comanda ya no existe.');
    }
    if (comanda.comandaEstado == ComandaEstado.cerrada ||
        comanda.comandaEstado == ComandaEstado.cancelada) {
      return _fallarBool('La comanda ya no admite cambios.');
    }
    if (itemIndex < 0 || itemIndex >= comanda.items.length) {
      return _fallarBool('Ese plato no existe en la comanda.');
    }

    final item = comanda.items[itemIndex];
    if (!puedeEditarItem(item)) {
      return _fallarBool(
        'No se puede modificar un plato en estado ${item.estadoPlato.name}.',
      );
    }

    final minimo = minimoCantidadItem(item.esPesado);
    var nueva = item.cantidad + delta;
    if (nueva < minimo) nueva = minimo;

    // Un delta de 0 (o que solo empuja contra el mínimo) no escribe nada:
    // evita un `put()` inútil en cada toque en el límite.
    if (nueva == item.cantidad) return true;

    item.cantidad = nueva;

    // El subtotal es precioUnitidad × cantidad, se recalcula solo al leer.
    // Lo que sí hay que refrescar es el snapshot de nombres y el sello de
    // la comanda, que es lo que lee el KDS.
    comanda.itemsNombres =
        comanda.items.map((i) => i.productoNombre).toList();

    await _isar.guardarComanda(comanda);
    await _refrescarComandaEnState(comandaId);
    return true;
  }

  /// Actualiza o borra la nota de un item.
  ///
  /// Si el texto queda vacío tras el `trim`, la nota pasa a `null` (no a
  /// `""`): una cadena vacía haría que la UI mostrara el ícono de editar
  /// como si no hubiera nota, pero el campo existiría.
  Future<bool> actualizarNotaItem(
    int comandaId,
    int itemIndex,
    String? nota,
  ) async {
    final comanda = await _isar.obtenerComandaPorId(comandaId);
    if (comanda == null) {
      return _fallarBool('La comanda ya no existe.');
    }
    if (comanda.comandaEstado == ComandaEstado.cerrada ||
        comanda.comandaEstado == ComandaEstado.cancelada) {
      return _fallarBool('La comanda ya no admite cambios.');
    }
    if (itemIndex < 0 || itemIndex >= comanda.items.length) {
      return _fallarBool('Ese plato no existe en la comanda.');
    }

    final item = comanda.items[itemIndex];
    if (!puedeEditarItem(item)) {
      return _fallarBool(
        'No se puede modificar un plato en estado ${item.estadoPlato.name}.',
      );
    }

    item.nota = _normalizarNota(nota);

    await _isar.guardarComanda(comanda);
    await _refrescarComandaEnState(comandaId);
    return true;
  }

  /// Recorta, y convierte vacío en `null`.
  static String? _normalizarNota(String? nota) {
    if (nota == null) return null;
    final limpio = nota.trim();
    if (limpio.isEmpty) return null;
    if (limpio.length <= maxCharsNotaItem) return limpio;
    return limpio.substring(0, maxCharsNotaItem);
  }

  /// Núcleo de los 3 métodos de advancement: valida y ejecuta.
  Future<bool> _avanzarEstado(
    int comandaId,
    int itemIndex,
    EstadoPlato nuevo,
  ) async {
    final comanda = await _isar.obtenerComandaPorId(comandaId);
    if (comanda == null) {
      return _fallarBool('La comanda ya no existe.');
    }
    if (comanda.comandaEstado == ComandaEstado.cerrada ||
        comanda.comandaEstado == ComandaEstado.cancelada) {
      return _fallarBool('La comanda ya no admite cambios.');
    }
    if (itemIndex < 0 || itemIndex >= comanda.items.length) {
      return _fallarBool('Ese plato no existe en la comanda.');
    }

    final actual = comanda.items[itemIndex].estadoPlato;
    if (!transicionValida(actual, nuevo)) {
      return _fallarBool(
        'Transición inválida: ${actual.name} → ${nuevo.name}.',
      );
    }

    final id = await _isar.actualizarItemDeComanda(
      comandaId,
      itemIndex,
      nuevo,
    );
    if (id == -1) {
      return _fallarBool('No se pudo actualizar el plato.');
    }

    // ════════════════════════════════════════════════════════════════
    // G.3 · DESCUENTO DE RECETA AL ENTREGAR
    // ════════════════════════════════════════════════════════════════
    //
    // Va DESPUÉS de confirmar la escritura y ANTES de `_setState` para que
    // el KDS ya tenga el estado nuevo cuando llegue el aviso.
    //
    // La idempotencia la da la matriz de transiciones de arriba, sin campos
    // extra: `transicionesValidas[entregado]` es un conjunto VACÍO, así que
    // un doble toque muere en `:1145` y nunca llega aquí.
    //
    // ⚠️ `comanda` es la copia leída en `:1132`, ANTES de que
    // `actualizarItemDeComanda` mutara su propia instancia. Da igual: de
    // este item solo se leen `cantidad` y `productoIdLocal`, y ninguno de
    // los dos los toca la transición de estado.
    //
    // ⚠️ En `try/catch` a propósito: el plato YA está entregado y eso no
    // se puede deshacer. Si el descuento revienta, el estado se queda y se
    // avisa por `debugPrint`; propagar el error dejaría al cocinero creyendo
    // que el toque falló e insistiría, cuando lo que falló fue el stock.
     if (nuevo == EstadoPlato.entregado) {
      // ⚠️ ORDEN: refrescar la comanda en `state` ANTES de setear el
      // aviso. Si el aviso se pusiera primero, la UI mostraría "falta
      // ingrediente X" mientras el plato todavía se ve `enPreparacion`
      // (state viejo), y el cocinero pensaría que el toque no funcionó.
      //
      // Con `cargar()` este mismo orden era incorrecto, pero el bug
      // quedaba tapado por los ~200ms que tardaba la recarga. Con
      // `_refrescarComandaEnState` es ~30ms, así que hay que corregir
      // el orden o el aviso se adelanta visiblemente al estado.
      await _refrescarComandaEnState(comandaId);

      // El descuento va en try/catch a propósito: el plato YA está
      // entregado y eso no se puede deshacer. Si revienta, se avisa por
      // debugPrint; propagar el error dejaría al cocinero creyendo que
      // el toque falló e insistiría, cuando lo que falló fue el stock.
      try {
        final resultado = await _descontarRecetaDeItem(
          comanda.items[itemIndex],
        );
        if (!resultado.completo) {
          _setState(state.copyWith(avisoReceta: resultado));
        }
      } catch (e) {
        debugPrint('⚠️ [Comandas] Error descontando receta: $e');
      }
      return true;
    }

    await _refrescarComandaEnState(comandaId);
    return true;
  }

  /// Platos visibles en el KDS de una estación, orden FIFO.
  ///
  /// Usa `state.comandas` (las vivas del local activo). R.3.2 lo consume
  /// para pintar la pantalla del KDS y para los badges del selector de
  /// estación. `estacionId == null` = todas las estaciones.
  ///
  /// Puro sobre el estado ya cargado: no toca Isar.
  /// Ítems en cola de una estación (o de todas si `estacionId` es null).
  ///
  /// Orden FIFO por `enviadoACocinaAt`.
  ///
  /// `excluirPausados: true` es para el contador del badge del menú. La
  /// pantalla del KDS usa el valor por defecto (`false`) porque sí tiene
  /// que mostrar los pausados.
  ///
  /// ⚠️ Devuelve items SUELTOS, sin comanda ni índice. Para pintar
  /// tickets usa `ComandasState.ticketsEnCola`, que sí lleva el
  /// `itemIndex` real.
  List<CartSessionItem> itemsEnColaPorEstacion(
    int? estacionId, {
    bool excluirPausados = false,
  }) {
    final resultado = <CartSessionItem>[];

    for (final comanda in state.comandas) {
      for (final item in comanda.items) {
        if (!IsarService.estadosVisiblesEnKds.contains(item.estadoPlato)) {
          continue;
        }
        if (excluirPausados && item.pausado) continue;
        if (estacionId != null && item.estacionId != estacionId) continue;
        resultado.add(item);
      }
    }

    resultado.sort((a, b) {
      final ta = a.enviadoACocinaAt;
      final tb = b.enviadoACocinaAt;
      // Sin timestamp (nunca enviado) al final.
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return ta.compareTo(tb);
    });

    return resultado;
  }

  // ── Estados ─────────────────────────────────────────────────────


  /// Cierra la comanda (tras cobrar) y libera la mesa.
  Future<bool> cerrarComanda() async {
    final activa = state.comandaActiva;
    if (activa == null) {
      return _fallarBool('No hay ninguna comanda abierta.');
    }
    activa.comandaEstado = ComandaEstado.cerrada;
    activa.cerradaAt = DateTime.now();
    await _isar.guardarComanda(activa);
    await _liberarMesa(activa.mesaId);
    await cargar();
    _setState(state.copyWith(limpiarActiva: true));
    return true;
  }

  /// Cancela la comanda. La CONSERVA como histórico; la mesa queda libre.
  Future<bool> cancelarComanda() async {
    final activa = state.comandaActiva;
    if (activa == null) {
      return _fallarBool('No hay ninguna comanda abierta.');
    }
    activa.comandaEstado = ComandaEstado.cancelada;
    activa.cerradaAt = DateTime.now();
    await _isar.guardarComanda(activa);
    await _liberarMesa(activa.mesaId);
    await cargar();
    _setState(state.copyWith(limpiarActiva: true));
    return true;
  }

  /// Marca cuál es la comanda activa (al navegar a la pantalla).
  void seleccionarComanda(int? id) {
    if (id == null) {
      _setState(state.copyWith(limpiarActiva: true));
    } else {
      _setState(state.copyWith(comandaActivaId: id));
    }
  }

  void limpiarError() => state = state.copyWith(limpiarError: true);

  // ── Mesas ────────────────────────────────────────────────────────

  Future<void> _marcarMesaOcupada(int mesaId) async {
    final mesa = await _isar.obtenerMesaPorId(mesaId);
    if (mesa == null) return;
    if (mesa.estado != MesaEstado.ocupada) {
      mesa.estado = MesaEstado.ocupada;
    }
    mesa.ocupadaDesde ??= DateTime.now();
    // R.1c: la ocupación se deriva de las comandas vivas y NO se sube.
    await _isar.guardarMesa(mesa, marcarPendiente: false);
  }

  /// Libera la mesa y desune cualquier unión pendiente.
  Future<void> _liberarMesa(int? mesaId) async {
    if (mesaId == null) return;
    final mesa = await _isar.obtenerMesaPorId(mesaId);
    if (mesa == null) return;
    mesa.estado = MesaEstado.libre;
    mesa.ocupadaDesde = null;
    // R.1c: la ocupación se deriva de las comandas vivas y NO se sube.
    await _isar.guardarMesa(mesa, marcarPendiente: false);
  }

  // ════════════════════════════════════════════════════════════════
  // R.4 · G.3 · DESCUENTO DE RECETA AL ENTREGAR
  // ════════════════════════════════════════════════════════════════

  /// Descuenta del inventario los ingredientes de la receta de un item.
  ///
  /// Cantidad real de cada ingrediente:
  /// `item.cantidad × recetaItem.cantidad × factor(unidad receta → unidad
  /// stock) ÷ receta.rindePorciones`. El factor vive en
  /// [ConversionUnidades] y es 1 cuando ambos lados usan la misma unidad.
  /// Los no opcionales (`esOpcional`) NO se descuentan: son extras que el
  /// cocinero puede no poner.
  ///
  /// Reusa el mismo plan FEFO que la venta retail
  /// (`planificarDescuentoLotes`), pero con la política contraria: NO
  /// cancela ni revierte (Q3). Si un ingrediente se queda corto se
  /// descuenta lo que había, se anota el faltante en
  /// [ResultadoDescuento.faltantes] y se sigue. El plato ya está entregado
  /// y la cocina no puede deshacerlo.
  ///
  /// ⚠️ ATÓMICO a diferencia de antes: el plan completo del item (todos
  /// los ingredientes, lote por lote) + los movimientos de auditoría se
  /// aplican en UNA transacción de `aplicarDescuentosLotes`. Antes eran N
  /// `writeTxn` independientes y si el 3.er ingrediente fallaba, los 2
  /// primeros quedaban descontados sin forma de deshacerlo. Si la
  /// transacción entera aborta, quedan los faltantes enteros y el estado
  /// del plato (que ya estaba entregado y no se toca aquí).
  Future<ResultadoDescuento> _descontarRecetaDeItem(
    CartSessionItem item,
  ) async {
    // 1. Sin id local no hay forma de buscar la receta (el `productoId` del
    //    item es el UUID de Supabase, no el id de Isar).
    final productoIdLocal = item.productoIdLocal;
    if (productoIdLocal == null) return ResultadoDescuento.vacio;

    // 2. Sin local activo la receta no sería coherente.
    final localId = _ref.read(localActualProvider);
    if (localId == null) return ResultadoDescuento.vacio;

    // 3. `vacia` y no `items.isEmpty`: una receta con SOLO opcionales tiene
    //    items pero no hay nada que descontar (`receta_entity.dart:96`).
    final receta = await _isar.obtenerRecetaPorProducto(
      localId,
      productoIdLocal,
    );
    if (receta == null || receta.vacia) return ResultadoDescuento.vacio;

    // 4. Guarda contra `rindePorciones <= 0` (que es editable en la UI de
    //    G.2.2): dividir por cero daría Infinity y el bucle de FEFO no
    //    terminaría nunca.
    final rinde = receta.rindePorciones;
    final divisor = rinde > 0 ? rinde : 1.0;

    final faltantes = <String>[];
    final descritos = <String>[];

    // Plan completo del item + movimientos de auditoría. Todo viaja a
    // `aplicarDescuentosLotes` al final, que es la ÚNICA escritura de este
    // flujo: una transacción, no N.
    final planItem = <DescuentoLotePlan>[];
    final movimientos = <MovimientoInventarioEntity>[];

    for (final recItem in receta.items) {
      if (recItem.esOpcional) continue;

      // Unidad de la RECETA → unidad del INVENTARIO.
      //
      // Sin esto, "150 g de queso" con el stock en kg descontaba 150 kg.
      // `ConversionUnidades` devuelve null cuando las dimensiones no
      // coinciden (p. ej. receta en 'unidad' y stock en 'kg'): ahí se cae al
      // 1:1 de antes y se deja rastro en el log, porque bloquear la entrega
      // de un plato ya cocinado está descartado (Q3).
      final ingrediente =
          await _isar.obtenerProductoPorId(recItem.ingredienteId);
      final factorUnidad = ConversionUnidades.factor(
        recItem.unidad,
        ingrediente?.unidad,
      );
      double cantidadEnStock;
      if (factorUnidad == null) {
        debugPrint(
          '⚠️ Receta "${receta.nombrePlato}": no se puede convertir '
          '"${recItem.unidad}" a "${ingrediente?.unidad}" '
          '(${recItem.ingredienteNombre}). Se descuenta 1:1.',
        );
        cantidadEnStock = recItem.cantidad;
      } else {
        cantidadEnStock = recItem.cantidad * factorUnidad;
      }

      final cantidadReal = (item.cantidad * cantidadEnStock) / divisor;

      // FEFO con el MISMO planificador que usa la caja (`venta_service`):
      // solo LECTURA. `planificarDescuentoLotes` dejó el faltante en
      // `PlanificacionLote.faltante`; aquí solo se anota, el plato ya está
      // entregado (Q3).
      final planificacion = await _isar.planificarDescuentoLotes(
        productoId: recItem.ingredienteId,
        cantidad: cantidadReal,
        localId: localId,
      );
      if (!planificacion.completo) {
        faltantes.add(recItem.ingredienteNombre);
      }
      planItem.addAll(planificacion.plan);

      final descontado = cantidadReal - planificacion.faltante;
      if (descontado > 0) {
        descritos.add(recItem.ingredienteNombre);
      }

      // Auditoría: un movimiento por ingrediente consumido, aunque haya
      // faltado parte. Con `cantidad = 0` NO se registra nada, para no
      // ensuciar el historial con ingredientes que ni se tocaron.
      //
      // `stockResultante` lo sella `aplicarDescuentosLotes` DENTRO de la
      // transacción, con el stock real ya recalculado: antes se leía
      // entre `writeTxn` separados, con la carrera que eso implica.
      if (descontado <= 0) continue;

      movimientos.add(
        MovimientoInventarioEntity()
          ..productoId = recItem.ingredienteId
          ..nombreProducto = recItem.ingredienteNombre
          ..tipoMovimiento = 'Consumo receta'
          ..cantidad = descontado
          ..stockResultante = 0.0
          ..fecha = DateTime.now()
          // El movimiento no sabe QUIÉN lo hizo si no hay sesión (tests,
          // kiosco sin login). `0` es el mismo "desconocido" que usa
          // `MovimientoInventarioEntity.localId` para los legacy.
          ..usuarioId = _ref.read(usuarioActualProvider)?.id ?? 0
          ..localId = localId
          ..syncStatus = 'pending',
      );
    }

    // El item completo en UNA transacción: descuento del plan + recálculo
    // de stock + movimientos. Si revienta, no queda nada a medio camino.
    // Antes cada `descontarLote` era su propia `writeTxn`: el punto
    // exacto de la deuda no atómica.
    await _isar.aplicarDescuentosLotes(
      plan: planItem,
      movimientos: movimientos,
    );

    return ResultadoDescuento(
      faltantes: faltantes,
      descritos: descritos.length,
    );
  }

  // (Alias `_recalcularStockDe` retirado: el recálculo de stock vive hoy
  // dentro de la transacción de `aplicarDescuentosLotes`. Para recalcular
  // desde fuera del flujo de entrega, usar `IsarService.recalcularStockDe`).

  // ── Utilidades ───────────────────────────────────────────────────

  int? _fallar(String mensaje) {
    debugPrint('⚠️ [Comandas] $mensaje');
    _setState(state.copyWith(error: mensaje));
    return null;
  }

  bool _fallarBool(String mensaje) {
    debugPrint('⚠️ [Comandas] $mensaje');
    _setState(state.copyWith(error: mensaje));
    return false;
  }
}

// ══════════════════════════════════════════════════════════════════
// PROVIDER
// ══════════════════════════════════════════════════════════════════

final comandasProvider =
    StateNotifierProvider<ComandasNotifier, ComandasState>((ref) {
  return ComandasNotifier(ref);
});

/// Mismo provider, pero con la base de datos inyectada.
///
/// Existe SOLO para tests. En producción usa siempre `comandasProvider`.
/// Aísla al notifier de `localActualProvider`, `authProvider` y
/// `cartProvider`, que si no obligan a montar el árbol entero para probar
/// un `pausarItem`.
final comandasProviderConIsar = StateNotifierProvider<ComandasNotifier,
    ComandasState>((ref) {
  return ComandasNotifier(ref, isar: ref.watch(isarServiceProvider));
});

/// Etiqueta legible del estado de comanda.
String etiquetaComandaEstado(ComandaEstado estado) {
  switch (estado) {
    case ComandaEstado.abierta:
      return 'Abierta';
    case ComandaEstado.enviada:
      return 'En cocina';
    case ComandaEstado.enPreparacion:
      return 'En preparación';
    case ComandaEstado.entregada:
      return 'Entregada';
    case ComandaEstado.cerrada:
      return 'Cerrada';
    case ComandaEstado.cancelada:
      return 'Cancelada';
  }
}
