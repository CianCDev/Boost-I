// lib/features/pos/presentation/screens/restaurante/comanda_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/catalog/catalog_actions.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';

import '../../controllers/cart_controller.dart';
import '../../../domain/models/cart_item.dart';
import '../../../domain/models/product_item.dart';
import '../../providers/kds_ticket.dart';
import '../../utils/duracion_utils.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/animated_appbar_icon.dart';
import '../../widgets/common/fila_botones_responsive.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/glass_dialog.dart';
import '../../widgets/common/item_card.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../widgets/common/quantity_control.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/time_badge.dart';
import '../../widgets/restaurante/confirmar_cobro_pendientes_dialog.dart';
import '../../widgets/salon/mesa_card.dart';

/// Pantalla de comanda de una mesa.
///
/// R.2: enviar a cocina y cobrar. El cobro reusa el flujo del POS: se vuelca
/// la comanda en el carrito vivo y se llama a `mostrarModalCobro`, que a su
/// vez invoca `procesarVenta` sin tocarlo.
///
/// R.3.2: los ítems se pintan con los componentes compartidos de PASO B
/// (`ItemCard` + `ProductThumbnail` + `QuantityControl` + `TimeBadge` +
/// `StickyNote`). Antes había un `_itemCard` local de 97 líneas que solo
/// mostraba cantidad, nombre, precio y nota en solo lectura.
class ComandaScreen extends ConsumerStatefulWidget {
  /// Id de la sesión de la comanda (`'mesa:<id>'`).
  final String sessionId;

  final int mesaId;

  const ComandaScreen({
    super.key,
    required this.sessionId,
    required this.mesaId,
  });

  @override
  ConsumerState<ComandaScreen> createState() => _ComandaScreenState();
}

class _ComandaScreenState extends ConsumerState<ComandaScreen> {
  static const _colorCancelar = Color(0xFFEF4444);
  static const _colorEnviar = Color(0xFFF59E0B);

  /// Verde de marca del bloque del total y del botón de cobrar.
  ///
  /// ⚠️ Sustituye a la antigua `_colorCobrar` (emerald 500, `0xFF10B981`),
  /// que quedó sin uso al pintar el total con fondo lleno. Ahora ambos
  /// comparten color a propósito: se leen como un solo bloque "esto es lo
  /// que se cobra".
  static const _colorTotal = Color(0xFF059669);

  /// Ancho máximo del contenido en desktop.
  ///
  /// Sin tope, en un monitor de 1920 px los `ItemCard` miden 1900 px de
  /// lado a lado y el precio queda a 900 px del nombre: se vuelve
  /// ilegible. 1000 px es lo que cabe cómodo leyendo.
  ///
  /// ⚠️ El mismo valor se aplica a [_cuerpo] y a [_barraAcciones] aunque
  /// sean ramas distintas del árbol (una está en `body` y la otra en
  /// `bottomNavigationBar`). Si divergieran, el header y los botones no
  /// quedarían alineados verticalmente.
  static const _anchoMaxContenido = 1000.0;

  /// Padding horizontal del contenido. Header, lista y barra usan el mismo
  /// para que las tres columnas coincidan.
  static const _padH = 16.0;

  /// Verde del item bloqueado, atenuado para que se lea "no editable"
  /// sin perder su código de estado.
  static const _colorBloqueado = Color(0xFF10B981);

  bool _procesando = false;

  /// Reloj compartido por todos los `TimeBadge` de la pantalla.
  ///
  /// Lo repinta un `Timer.periodic` para que la antigüedad de los platos
  /// envejezca sola. Solo hace `setState`: no lee Isar ni vuelve a cargar,
  /// así que no es polling de datos. Se cancela en `dispose`.
  ///
  /// ⚠️ El mismo patrón usará el KDS en PASO E.
  Timer? _reloj;
  DateTime _ahora = DateTime.now();

  @override
  void initState() {
    super.initState();
    _reloj = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _ahora = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _preparar());
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  Future<void> _preparar() async {
    final notifier = ref.read(comandasProvider.notifier);
    await notifier.cargar();

    // Seleccionar la comanda de esta pantalla. Si aún no existe (el
    // usuario entró directo sin abrirla desde el salón), se queda en null
    // y la pantalla muestra el estado vacío.
    CartSessionEntity? encontrada;
    for (final c in ref.read(comandasProvider).comandas) {
      if (c.sessionId == widget.sessionId) {
        encontrada = c;
        break;
      }
    }
    notifier.seleccionarComanda(encontrada?.id);
  }

  // ── R.3.2 · Cantidad y nota por ítem ─────────────────────────────

  /// Cambia la cantidad de un ítem. El `delta` viene del `QuantityControl`.
  Future<void> _cambiarCantidad(
    CartSessionEntity comanda,
    int index,
    double delta,
  ) async {
    if (!ComandasNotifier.puedeEditarItem(comanda.items[index])) return;

    await ref
        .read(comandasProvider.notifier)
        .cambiarCantidadItem(comanda.id, index, delta);

    if (!mounted) return;
    _avisoErrorSiHay();
  }

  /// Abre el diálogo de nota y guarda el resultado.
  Future<void> _editarNota(CartSessionEntity comanda, int index) async {
    final item = comanda.items[index];
    if (!ComandasNotifier.puedeEditarItem(item)) return;

    final resultado = await _NotaItemDialog.mostrar(context, nota: item.nota);
    if (resultado == null || !mounted) return;

    await ref
        .read(comandasProvider.notifier)
        .actualizarNotaItem(comanda.id, index, resultado);

    if (!mounted) return;
    _avisoErrorSiHay();
  }

  /// El provider deja el motivo en `state.error`; lo muestra y lo limpia.
  void _avisoErrorSiHay() {
    final error = ref.read(comandasProvider).error;
    if (error == null) return;
    _aviso(error);
    ref.read(comandasProvider.notifier).limpiarError();
  }

  /// Color del borde lateral según el estado del plato.
  ///
  /// Reutiliza la escala de urgencia de `TimeBadge` para que el item y su
  /// badge hablen el mismo idioma: verde recién enviado, ámbar que empieza
  /// a tardar, naranja, rojo pasado de tiempo.
  Color? _colorPorEstado(CartSessionItem item) {
    if (item.pausado) return _colorCancelar;

    if (!ComandasNotifier.puedeEditarItem(item)) {
      return _colorBloqueado;
    }

    if (item.estadoPlato == EstadoPlato.pendiente) {
      return null; // Sin borde: todavía no está en cocina.
    }

    final minutos = item.enviadoACocinaAt == null
        ? 0
        : DuracionUtils.minutosDesde(item.enviadoACocinaAt, ahora: _ahora);
    return TimeBadge.colorPorMinutos(minutos);
  }

  /// Detecta si el pedido ya tiene platos que no admiten cambios.
  bool _tieneItemsBloqueados(CartSessionEntity comanda) {
    return comanda.items.any((i) => !ComandasNotifier.puedeEditarItem(i));
  }

  // ── Enviar a cocina ─────────────────────────────────────────────

  Future<void> _enviar() async {
    // R.3 (D3b): ahora devuelve la lista de platos que entraron a la
    // cola, no un bool. `null` = error, ya mostrado por el provider vía
    // `_fallarBool` → `_errorActual()`.
    //
    // R.3.3: la impresión del ticket de cocina NO es de aquí. Ocurre dentro
    // de `ComandasNotifier.enviarACocina()` (ver `comanda_provider.dart`),
    // que llama a `TicketCocinaService.procesarEnvio` en modo fire-and-
    // forget. Esta pantalla solo recibe la lista para el Snackbar.
    final enviados =
        await ref.read(comandasProvider.notifier).enviarACocina();
    if (!mounted) return;

    final ok = enviados != null;
    final mensaje = ok
        ? '${enviados.length} plato(s) enviado(s) a cocina'
        : _errorActual();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: ok ? _colorEnviar : _colorCancelar,
      ),
    );
  }

  // ── Cobrar ──────────────────────────────────────────────────────

  /// R.3.4 · Ticket de cocina de esta comanda, o `null` si no tiene nada
  /// en la cola.
  ///
  /// ⚠️ Se busca por `comanda.id` (Isar de la `CartSessionEntity`), NO por
  /// `widget.mesaId`: `KdsTicket.comandaId` es el id de la comanda, que no
  /// es el de la mesa. Es fácil confundirlos y acabar sin encontrar
  /// nunca el ticket.
  ///
  /// Bucle con `break` en vez de `firstWhere`: sin `orElse` `firstWhere`
  /// lanza `StateError` cuando no hay ticket —que es el caso normal si
  /// nada se ha enviado a cocina—, y con `orElse: () => null` no compila
  /// porque `KdsTicket` no es nullable.
  KdsTicket? _buscarTicket(int comandaId) {
    final tickets = ref.read(comandasProvider).ticketsEnCola;
    for (final t in tickets) {
      if (t.comandaId == comandaId) return t;
    }
    return null;
  }

  /// R.3.4 · Avisa de que hay platos sin servir antes de cobrar.
  ///
  /// Desglose en dos porque al mesero le importan cosas distintas: lo que
  /// está **en cocina** va en camino, lo que está **listo** espera que
  /// alguien lo lleve. Mezclado en un número único, "hay 3 pendientes"
  /// suena igual si son 3 platos a medio hacer o 3 ya emplatados.
  ///
  /// ⚠️ Los PAUSADOS cuentan como "en cocina": no están fuera de la cola,
  /// están bloqueados, y cobrarlos sin saberlo es exactamente lo que este
  /// diálogo evita. `ticketsEnCola` ya los incluye.
  ///
  /// ⚠️ Aquí NO se pregunta: se delega en
  /// [ConfirmarCobroPendientesDialog.mostrar], que además decide no abrir
  /// nada si no hay pendientes. Esa guarda vive con el diálogo a propósito:
  /// puesta aquí, el siguiente caller se la saltaría sin querer.
  Future<bool> _confirmarCobroConPendientes(KdsTicket ticket) async {
    // El conteo vive en `KdsTicket.pendientesPorEstado`, no aquí: es una
    // propiedad del ticket y tiene sus propios tests. Esta pantalla solo
    // decide si preguntar y lo pinta.
    final p = ticket.pendientesPorEstado;

    return ConfirmarCobroPendientesDialog.mostrar(
      context,
      enCocina: p.enCocina,
      listos: p.listos,
    );
  }

  Future<void> _cobrar() async {
    final comanda = ref.read(comandasProvider).comandaActiva;
    if (comanda == null || comanda.items.isEmpty) {
      _aviso('La comanda está vacía.');
      return;
    }

    // R.3.4: la pregunta va ANTES de `setState(_procesando = true)`. Si
    // fuera después, el pulsador de [Esperar] saldría del `return` con el
    // botón en estado "procesando" y la pantalla quedaría bloqueada
    // hasta que se cerrara.
    final ticket = _buscarTicket(comanda.id);
    if (ticket != null && ticket.items.isNotEmpty) {
      final proceder = await _confirmarCobroConPendientes(ticket);
      if (!proceder) return;
      if (!mounted) return;
    }

    setState(() => _procesando = true);

    // 1. Volcar la comanda en el carrito vivo.
    final items = comanda.items
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
            // R.3: rehidrata la estación para que el cobro no pierda el
            // destino de preparación del plato.
            estacionId: s.estacionId,
          ),
        )
        .toList();

    ref.read(cartProvider.notifier).reemplazarItems(
          items,
          configIva: ConfiguracionIva(
            codigoPais: comanda.configIvaPais,
            porcentajeIva: comanda.configIvaPorcentaje,
            preciosIncluyenIva: comanda.configIvaPreciosIncluyenIva,
          ),
          ivaHabilitado: comanda.ivaHabilitado,
        );

    // 2. Cobrar con el flujo del POS. `mostrarModalCobro` devuelve true si
    //    `procesarVenta` no lanzó.
    final usuario = ref.read(usuarioActualProvider);
    final cobrado = await ref
        .read(catalogActionsProvider)
        .mostrarModalCobro(context, usuario);

    if (!mounted) return;
    setState(() => _procesando = false);

    if (!cobrado) {
      _aviso('No se completó el cobro. La comanda sigue abierta.');
      return;
    }

    // 3. Cerrar la comanda y liberar la mesa.
    await ref.read(comandasProvider.notifier).cerrarComanda();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ── Cancelar ────────────────────────────────────────────────────

  Future<void> _cancelar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar comanda'),
        content: const Text(
          'Se descartará todo lo pedido en esta mesa. '
          'La comanda se conserva como histórico.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _colorCancelar),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar comanda'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await ref.read(comandasProvider.notifier).cancelarComanda();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ── Utilidades ──────────────────────────────────────────────────

  void _aviso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _colorCancelar,
      ),
    );
  }

  String _errorActual() {
    final e = ref.read(comandasProvider).error;
    return e ?? 'No se pudo completar la operación.';
  }

  /// `_duracion()` se sustituyó por `DuracionUtils.hace` en R.3.2. Era el
  /// séptimo helper privado de antigüedad del proyecto; los otros seis
  /// viven en pantallas fuera de alcance (ver `docs/TODO.md`).

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comandasProvider);
    final esMobile = ResponsiveHelper.isMobile(context);

    CartSessionEntity? comanda;
    for (final c in state.comandas) {
      if (c.sessionId == widget.sessionId) {
        comanda = c;
        break;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: comanda?.mesaNombre != null
            ? 'Comanda · ${comanda!.mesaNombre}'
            : 'Comanda',
        showBackButton: true,
        actions: [
          AnimatedAppBarIcon(
            icon: Icons.refresh_rounded,
            tooltip: 'Actualizar',
            onPressed: () => ref.read(comandasProvider.notifier).cargar(),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : comanda == null
                ? _vacio(
                    mensaje: 'No se encontró la comanda.',
                    detalle: 'Vuelve al salón y ábrela de nuevo.',
                  )
                : _cuerpo(context, comanda, esMobile),
      ),

      bottomNavigationBar: comanda == null || state.isLoading
          ? null
          : _barraAcciones(context, comanda),
    );
  }

  Widget _cuerpo(
    BuildContext context,
    CartSessionEntity comanda,
    bool esMobile,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.isDesktop(context)
              ? _anchoMaxContenido
              : double.infinity,
        ),
        child: Column(
          children: [
            _header(context, comanda),
            Expanded(
              child: comanda.items.isEmpty
                  ? _vacio(
                      mensaje: 'Esta comanda aún no tiene productos',
                      detalle: 'Los platos se agregan desde el punto de '
                          'venta: elige esta mesa en el catálogo y añádelos.',
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        _padH,
                        8,
                        _padH,
                        esMobile ? 8 : 16,
                      ),
                      itemCount: comanda.items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          _itemCard(context, comanda, i),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, CartSessionEntity comanda) {
    final colorEstado = comanda.comandaEstado == ComandaEstado.enviada
        ? const Color(0xFFF59E0B)
        : MesaCard.colorLibre;

    return Padding(
      padding: const EdgeInsets.fromLTRB(_padH, 12, _padH, 8),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        showStatusBar: true,
        statusColor: colorEstado,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jerarquía: el nombre de la mesa es el dato que identifica esta
            // pantalla, así que va en 22 bold. Antes iba en 17 y competía de
            // tú a tú con los metadatos de abajo.
            Row(
              children: [
                Icon(Icons.table_restaurant_rounded,
                    size: 24, color: colorEstado),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    comanda.mesaNombre ?? 'Mesa',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      height: 1.1,
                    ),
                  ),
                ),
                StatusBadge(
                  label: etiquetaComandaEstado(comanda.comandaEstado),
                  color: colorEstado,
                  size: StatusBadgeSize.small,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _meta(Icons.people_alt_outlined,
                    '${comanda.comensales} comensal(es)'),
                _meta(Icons.person_outline_rounded,
                    comanda.meseroNombre ?? 'Sin mesero'),
                // El reloj se pinta con la escala de urgencia del KDS: es
                // el mismo dato que el `TimeBadge` de cada plato, y que los
                // dos hablen el mismo idioma evita tener que aprender dos.
                _meta(
                  Icons.schedule_rounded,
                  DuracionUtils.hace(comanda.createdAt, ahora: _ahora),
                  color: TimeBadge.colorPorMinutos(
                    DuracionUtils.minutosDesde(
                      comanda.createdAt,
                      ahora: _ahora,
                    ),
                  ),
                ),
                if (_tieneItemsBloqueados(comanda))
                  StatusBadge(
                    label: 'Servida parcialmente',
                    color: _colorEnviar,
                    icon: Icons.lock_clock_rounded,
                    size: StatusBadgeSize.small,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Metadato del header: icono pequeño + texto atenuado.
  ///
  /// [color] es opcional a propósito: los dos primeros (comensales,
  /// mesero) son datos neutros y se quedan en `onSurfaceVariant`, y solo
  /// el reloj lleva color de urgencia. Así los tres se leen como una sola
  /// línea en vez de tres bloques de distinto peso.
  Widget _meta(IconData icon, String texto, {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    final tono = color ?? colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: tono),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(fontSize: 12, color: tono),
        ),
      ],
    );
  }

  /// Un ítem de la comanda, pintado con los componentes de PASO B.
  ///
  /// Sustituye al `_itemCard` local de 97 líneas que había antes: aquel solo
  /// mostraba cantidad, nombre, precio, subtotal y la nota en solo lectura.
  /// Ahora además hay miniatura, antigüedad, nota editable y cantidad
  /// editable cuando el estado del plato lo permite.
  Widget _itemCard(
    BuildContext context,
    CartSessionEntity comanda,
    int index,
  ) {
    final item = comanda.items[index];
    final editable = ComandasNotifier.puedeEditarItem(item);
    final colorScheme = Theme.of(context).colorScheme;

    final subtotal = item.precioUnidad * item.cantidad;

    // El badge de antigüedad solo aparece si el plato ya entró a cocina.
    // Un ítem `pendiente` no tiene `enviadoACocinaAt` y mostraría "—".
    final Widget? badge = item.estadoPlato == EstadoPlato.pendiente
        ? null
        : TimeBadge(desde: item.enviadoACocinaAt, ahora: _ahora);

    return ItemCard(
      thumbnail: ProductThumbnail(imageUrl: item.imagenUrl),
      nombre: item.productoNombre,
      detalle: '${item.cantidad} × \$${item.precioUnidad.toStringAsFixed(2)}'
          '${item.esPesado ? ' / kg' : ''}',
      precio: '\$${subtotal.toStringAsFixed(2)}',
      badgeEstado: badge,
      nota: (item.nota?.isNotEmpty ?? false)
          ? StickyNote(
              texto: item.nota!,
              onEdit: () => _editarNota(comanda, index),
            )
          : null,
      cantidad: QuantityControl(
        cantidad: item.cantidad,
        esPesado: item.esPesado,
        habilitado: editable,
        minimo: ComandasNotifier.minimoCantidadItem(item.esPesado),
        onIncrementar: () => _cambiarCantidad(comanda, index, 1),
        onDecrementar: () => _cambiarCantidad(comanda, index, -1),
      ),
      colorBorde: _colorPorEstado(item),
      trailing: _accionesItem(context, comanda, index, editable, colorScheme),
    );
  }

  /// Candado para los ítems bloqueados y botón de nota para el resto.
  Widget _accionesItem(
    BuildContext context,
    CartSessionEntity comanda,
    int index,
    bool editable,
    ColorScheme colorScheme,
  ) {
    final item = comanda.items[index];

    if (!editable) {
      // El candado explica POR QUÉ el QuantityControl está gris. Sin él, el
      // mesero toca "+" y no pasa nada, y parece un bug.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Editar nota',
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            onPressed: null,
            icon: Icon(
              Icons.edit_note_rounded,
              size: 14,
              color: colorScheme.outline,
            ),
          ),
        ],
      );
    }

    return IconButton(
      tooltip: (item.nota?.isNotEmpty ?? false)
          ? 'Editar nota'
          : 'Agregar nota',
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      onPressed: () => _editarNota(comanda, index),
      icon: Icon(
        (item.nota?.isNotEmpty ?? false)
            ? Icons.edit_note_rounded
            : Icons.note_add_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _barraAcciones(BuildContext context, CartSessionEntity comanda) {
    final editable = comanda.comandaEditable;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_padH, 8, _padH, 12),
        child: Center(
          // Mismo tope que `_cuerpo`. Es otra rama del árbol
          // (`bottomNavigationBar`, no `body`), pero si solo se limitara
          // una de las dos el header y los botones no caerían en la misma
          // columna vertical.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context)
                  ? _anchoMaxContenido
                  : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _totalChip(context, comanda),
                const SizedBox(height: 10),
                // 2:3 a propósito, NO partes iguales: cobrar es la acción
                // principal de esta pantalla. `flexes` es lo que conserva
                // esa proporción dentro de `FilaBotonesResponsive`.
                FilaBotonesResponsive(
                  flexes: const [2, 3],
                  // ⚠️ El default del widget es 420. Aquí se sube al ancho
                  // del contenido: si no, los botones medirían 420 px
                  // centrados DENTRO de los 1000 px del badge del total y
                  // de las tarjetas, y la barra se vería con tres anchos
                  // distintos apilados. Lo que queda ya no es "no estirado"
                  // (lo da el contenedor de arriba), sino el reparto 2:3
                  // dentro de la columna.
                  maxWidthDesktop: _anchoMaxContenido,
                  // 8, no el default de 12: es lo que había entre estos
                  // dos botones y en móvil la fila tiene que quedar igual
                  // píxel a píxel.
                  spacing: 8,
                  children: [
                    // 40% del ancho: enviar es secundario frente a cobrar.
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: editable && !_procesando
                          ? () => _enviar()
                          : null,
                      icon: const Icon(Icons.outbox_rounded, size: 20),
                      // "Enviar" y no "Cocina"/"Estaciones": el botón
                      // ejecuta `_enviar()`, no navega a las estaciones.
                      // Ponerle el nombre del destino sugiere que abre
                      // otra pantalla.
                      label: const Text('Enviar'),
                    ),
                    // 60% del ancho: cobrar es la acción principal.
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: _colorTotal,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed:
                          comanda.items.isEmpty || _procesando
                              ? null
                              : _cobrar,
                      icon: _procesando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.point_of_sale_rounded, size: 20),
                      label: const Text('Cobrar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // R.2 Fase 1 (B1): el mesero ve la comanda en solo lectura.
                // Los productos se cargan desde el POS (chip de mesa), no
                // desde aquí.
                //
                // `estirar: false`: en desktop el botón se ajusta a su texto
                // y queda centrado, en vez de un `TextButton` de 1900 px. En
                // móvil sigue ocupando todo el ancho, igual que ahora:
                // `estirar` solo cambia lo que pasa en pantallas anchas.
                FilaBotonesResponsive(
                  estirar: false,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        foregroundColor: _colorCancelar,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _procesando ? null : () => _cancelar(),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Cancelar comanda'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bloque del total: fondo verde lleno y cifra en grande.
  ///
  /// ⚠️ Antes era el verde de marca al 10 % con borde y texto negro: se leía
  /// como un chip informativo, no como el número que el mesero viene a ver.
  /// Ahora es un bloque de color con la cifra en blanco de 20 px.
  Widget _totalChip(BuildContext context, CartSessionEntity comanda) {
    final total = comanda.items.fold<double>(
      0.0,
      (sum, i) => sum + i.precioUnidad * i.cantidad,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        color: _colorTotal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _colorTotal.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vacío de la lista de platos.
  ///
  /// ⚠️ **SIN BOTÓN DE "AÑADIR PLATO", a propósito.** En R.2 Fase 1 (B1) se
  /// decidió que la comanda es de solo lectura para el mesero: los productos
  /// entran desde el POS, con el chip de mesa. Un botón aquí que empuje a
  /// `InventoryCatalogScreen` metería los productos en el **carrito de
  /// retail**, no en esta comanda: el botón prometería una cosa y haría otra,
  /// y el mesero descubriría el error al cobrar.
  ///
  /// Lo que sí cabe es decir EN VOZ ALTA de dónde se agrega. Antes el texto
  /// Deadaba al usuario adivinar dónde ir.
  Widget _vacio({required String mensaje, required String detalle}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de nota por ítem ("sin cebolla", "servir caliente").
///
/// Devuelve el texto nuevo, o `null` si el usuario cancela (en ese caso no
/// se toca la nota, ni siquiera para borrarla). Un texto vacío SÍ se
/// propaga: `ComandasNotifier.actualizarNotaItem` lo convierte en `null`.
///
/// El tope de 100 caracteres lo aplica el provider
/// (`ComandasNotifier.maxCharsNotaItem`); aquí solo se pinta el contador y
/// se avisa de que el campo se recorta, para no copiar la regla.
class _NotaItemDialog extends StatefulWidget {
  final String? nota;

  const _NotaItemDialog({this.nota});

  /// `null` = cancelado. `''` = borrar la nota.
  static Future<String?> mostrar(BuildContext context, {String? nota}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _NotaItemDialog(nota: nota),
    );
  }

  @override
  State<_NotaItemDialog> createState() => _NotaItemDialogState();
}

class _NotaItemDialogState extends State<_NotaItemDialog> {
  /// `_colorCancelar` es `static const` de `_ComandaScreenState`, y las dos
  /// clases son hermanas, no anidadas: no se ve desde aquí. Se repite el
  /// valor en vez de subirlo a un helper compartido, porque un color de
  /// "se pasó el límite de caracteres" no merece una constante global.
  static const _colorExcedido = Color(0xFFEF4444);

  late final TextEditingController _controller;
  late int _restantes;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nota ?? '');
    _restantes = ComandasNotifier.maxCharsNotaItem - _controller.text.length;
    _controller.addListener(_alEscribir);
  }

  void _alEscribir() {
    final restante =
        ComandasNotifier.maxCharsNotaItem - _controller.text.length;
    if (restante == _restantes) return;
    setState(() => _restantes = restante);
  }

  @override
  void dispose() {
    _controller.removeListener(_alEscribir);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final excedido = _restantes < 0;

    return GlassDialog(
      maxWidth: 440,
      accentColor: const Color(0xFFF59E0B),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nota del plato',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'El cocinero la ve en el KDS. Sin cebolla, alergias, cómo '
              'servirlo…',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              minLines: 2,
              maxLength: ComandasNotifier.maxCharsNotaItem,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ej: sin cebolla, extra queso, alergias…',
                errorText: excedido
                    ? 'Se recortará a '
                        '${ComandasNotifier.maxCharsNotaItem} caracteres'
                    : null,
                counterStyle: TextStyle(
                  fontSize: 11,
                  color: excedido ? _colorExcedido : colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(_controller.text),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
