// lib/features/pos/presentation/screens/restaurante/kds_screen.dart
//
// R.3.2 PASO E · Pantalla de cocina (KDS).
//
// ⚠️ QUÉ ES Y QUÉ NO ES
//
// Es un VIZLOR de `ComandasState.ticketsEnCola`. No consulta Isar, no
// muta comandas y no guarda filtros: toda la verdad vive en el provider
// (`comanda_provider.dart:96`), que es quien sabe qué items están
// visibles en cocina (`IsarService.estadosVisiblesEnKds`).
//
// La pantalla solo añade dos cosas que el provider no sabe:
//   · el filtro de estación, que es de VISTA, no de datos.
//   · el reloj, que no está en ningún sitio porque la antigüedad hay que
//     recalcularla.
//
// ⚠️ POR QUÉ EL RELOJ LO MANTIENE LA PANTALLA Y NO LOS WIDGETS
//
// `TimeBadge` exige `ahora` inyectado (time_badge.dart:15). Si cada badge
// llamara a `DateTime.now()` por su cuenta, dos hermanos del mismo frame
// podrían caer en minutos distintos y se verían dos urgencias
// incompatibles en la misma pantalla. Aquí un `Timer.periodic` de 30 s
// produce UN `_ahora` y toda la pantalla lo comparte.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/departamento_entity.dart';
import '../../providers/comanda_provider.dart';
import '../../providers/departamentos_provider.dart';
import '../../providers/kds_ticket.dart';
import '../../providers/local_actual_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/animated_appbar_icon.dart';
import '../../widgets/common/filtro_chip_template.dart';
import '../../widgets/restaurante/aviso_stock_receta_dialog.dart';
import 'configurar_estaciones_dialog.dart';
import 'kds_ticket_card.dart';

/// Cada cuánto se recalcula la antigüedad de los tickets.
///
/// 30 s es el grano que usan `ComandaScreen` (PASO C) y los umbrales de
/// `UmbralesUrgencia`: refrescar más a menudo solo gastaría batería sin
/// cambiar ni un solo color.
const _kPeriodoReloj = Duration(seconds: 30);

const _colorTodas = Color(0xFF3B82F6);
const _colorSinEstacion = Color(0xFF64748B);
const _colorAviso = Color(0xFFF59E0B);
const _colorError = Color(0xFFEF4444);

/// Ancho máximo del contenido en desktop.
///
/// Coincide con el de `ComandaScreen` a propósito: las dos pantallas del
/// módulo restaurante comparten la misma columna, así que un mesero que
/// salta de una a otra no ve un salto de ancho.
const _anchoMaxContenido = 1000.0;

/// Pantalla de cocina.
class KdsScreen extends ConsumerStatefulWidget {
  const KdsScreen({super.key});

  @override
  ConsumerState<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends ConsumerState<KdsScreen> {
  /// Estación seleccionada. `null` = todas.
  int? _estacion;

  /// Columna "Sin estación" seleccionada.
  ///
  /// ⚠️ No se puede codificar dentro de [_estacion] con un centinela
  /// entero: el mapa de conteos se indexa por `estacionId`, y para los
  /// platos sin clasificar esa clave ES `null`, que ya significa
  /// "todas". Un `-1` de mentira acabaría mezclándose con una estación
  /// real de id negativo. Por eso son dos campos.
  bool _soloSinEstacion = false;

  /// Reloj compartido por toda la pantalla (ver cabecera del archivo).
  DateTime _ahora = DateTime.now();

  Timer? _timer;

  /// R.3.4 · Aviso sonoro activo. Toggle en el AppBar.
  ///
  /// Silencia el `SystemSound` y la vibración, NO el Snackbar: el pedido
  /// nuevo tiene que verse pase lo que pase.
  ///
  /// ⚠️ NO se persiste (D3-B): al reabrir el KDS vuelve a `true`. En una
  /// cocina el silencio se elige para el momento —una hora punta ruidosa,
  /// un servicio lento—, no como preferencia permanente. Persistirlo
  /// haría que un silenciado de hace tres días siguiera callando pedidos
  /// sin que nadie lo hubiera pedido hoy.
  bool _sonidoActivo = true;

  /// Evita apilar diálogos de stock si llegan dos entregas seguidas con
  /// faltantes mientras el primero sigue abierto.
  bool _avisoStockVisible = false;

  @override
  void initState() {
    super.initState();

    // ⚠️ `listenManual`, no `listen`: dentro de `initState` de un
    // `ConsumerState` es el único válido (Riverpod lanza si usas `listen`
    // ahí), y se cierra solo al destruirse la pantalla, sin necesidad de
    // guardar el `ProviderSubscription` a mano en `dispose`.
    // Patrón copiado de `inventory_screen.dart:67`.
    //
    // ⚠️ NO hace falta sembrar ningún "total anterior": `listenManual` no
    // dispara con el valor inicial, solo cuando cambia, así que el primer
    // callback ya trae `anterior` = valor en el momento de suscribirse.
    //
    // ⚠️ Solo reacciona a CRECIMIENTOS. Si el total baja (un hot-switch de
    // local recarga la cola de golpe) no avisa: si no, al volver a subir
    // avisaría de platos que en realidad ya estaban.
    ref.listenManual<int>(
      comandasProvider.select((s) => s.totalItemsEnKds),
      (anterior, nuevo) {
        // ⚠️ El callback de Riverpod tipa el PREVIO como nullable
        // (`T? previous`), aunque `totalItemsEnKds` sea un `int` getter no
        // null. Sin normalizar, `nuevo <= anterior` da `int?` y el
        // operador `<=` no compila.
        final a = anterior ?? 0;
        final n = nuevo;
        if (n <= a) return;
        _avisarPedidoNuevo(n - a);
      },
    );

    ref.listenManual<ResultadoDescuento?>(
      comandasProvider.select((s) => s.avisoReceta),
      (anterior, nuevo) {
        // `listenManual` no dispara con el valor inicial, así que si el KDS
        // se abre con un aviso viejo pendiente no lo repite.
        if (nuevo == null || nuevo.completo) return;
        unawaited(_avisarStockInsuficiente(nuevo));
      },
    );

    _timer = Timer.periodic(_kPeriodoReloj, (_) {
      if (!mounted) return;
      setState(() => _ahora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // R.3.4 · AVISO DE PEDIDO NUEVO
  // ════════════════════════════════════════════════════════════════

  /// Avisa de que han entrado [nuevos] platos en la cola.
  ///
  /// Suena, vibra y enseña un Snackbar con 🍳.
  ///
  /// ⚠️ LIMITE CONOCIDO Y ACEPTADO (D2-A): el aviso vive atado al ciclo
  /// de vida de esta pantalla. Si el KDS está cerrado no suena nada, que
  /// es justo el caso de uso previsto (un dispositivo apoyado en la barra
  /// con el KDS a la vista). Hacerlo global exigiría un provider con su
  /// propio timer y audio en background: otra arquitectura.
  ///
  /// ⚠️ `SystemSound` es el pitido del SISTEMA (D1-C), no un timbre de
  /// cocina. En Android es corto y HIG, y hay operadores que lo filtran.
  /// Se acepta para no añadir `audioplayers`.
  void _avisarPedidoNuevo(int nuevos) {
    if (nuevos <= 0) return;

    if (_sonidoActivo) {
      // `play` es fire-and-forget: no devuelve Future, no puede fallar de
      // forma que interese, y no hace falta esperar para mostrar el
      // Snackbar.
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.mediumImpact();
    }

    // El Snackbar va SIEMPRE, mudo o no: el pedido nuevo tiene que verse
    // aunque el cocinero haya silenciado el sonido a propósito.
    if (!mounted) return;

    final plural = nuevos == 1 ? 'plato' : 'platos';
    final sufijo = nuevos == 1 ? '' : 's';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🍳 $nuevos $plural nuevo$sufijo'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // R.4 · G.3 · AVISO DE STOCK INSUFICIENTE
  // ════════════════════════════════════════════════════════════════

  /// Avisa de que a un plato entregado le faltó stock de algún ingrediente.
  ///
  /// ⚠️ **NO bloquea nada.** El plato ya está entregado: el texto dice
  /// explícitamente que se descontó lo que había. Cocinar y cobrar van por
  /// delante del inventario, y avisar es lo único sensato que queda.
  ///
  /// No suena ni vibra a propósito: `_sonidoActivo` es el interruptor del
  /// PITIDO DE PEDIDO NUEVO, y este aviso es un problema de almacén, no
  /// algo que deba interrumpir al Cocinero cada vez que entra un plato.
  ///
  /// ⚠️ Es un DIÁLOGO, no un Snackbar. Antes compartía `ScaffoldMessenger`
  /// con el aviso de pedido nuevo y, si llegaban casi juntos, el segundo
  /// mensaje pisaba al primero: el faltante se perdía. El diálogo no se
  /// cierra solo y no compite con nada. Ver
  /// `widgets/restaurante/aviso_stock_receta_dialog.dart`.
  Future<void> _avisarStockInsuficiente(ResultadoDescuento resultado) async {
    if (!mounted || _avisoStockVisible) return;

    _avisoStockVisible = true;
    try {
      await AvisoStockRecetaDialog.mostrar(
        context,
        faltantes: resultado.faltantes,
      );
    } finally {
      _avisoStockVisible = false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CONTEO POR ESTACIÓN
  // ════════════════════════════════════════════════════════════════

  /// Cuenta los platos del KDS agrupados por `estacionId`.
  ///
  /// Se cuenta desde `ticketsEnCola` y NO con
  /// `ComandasNotifier.itemsEnColaPorEstacion()`: aquel es un método del
  /// NOTIFIER, se lee con `ref.read` y por lo tanto no es reactivo. Aquí
  /// hace falta que el chip se mueva solo cuando llega un plato.
  ///
  /// ⚠️ Se devuelven DOS cuentas a propósito:
  ///   · `total`     = platos visibles, pausados incluidos. Decide si
  ///                   la estación aparece en el selector.
  ///   · `pendientes` = platos sin pausar. Es el número que se pinta,
  ///                   porque un plato pausado no es trabajo pendiente,
  ///                   es un bloqueo.
  ///
  /// Si solo se contara lo pendiente, una estación con todos sus platos
  /// pausados desaparecería del selector y no habría forma de llegar a
  /// ellos.
  Map<int?, _ConteoEstacion> _contar(List<KdsTicket> tickets) {
    final mapa = <int?, _ConteoEstacion>{};

    for (final ticket in tickets) {
      for (final ti in ticket.items) {
        final conteo = mapa.putIfAbsent(
          ti.item.estacionId,
          _ConteoEstacion.new,
        );
        conteo.total++;
        if (!ti.item.pausado) conteo.pendientes++;
      }
    }

    return mapa;
  }

  /// Recorta la cola al filtro activo.
  ///
  /// Devuelve tickets NUEVOS con los items recortados: no se muta
  /// `KdsTicket` (es inmutable) ni se toca el estado del provider, que
  /// es compartido con el resto de la app.
  ///
  /// Se conserva el orden que ya venía de `ticketsEnCola` (FIFO), así
  /// que filtrar por estación no reordena la cola: la cocina sigue
  /// viendo primero lo más viejo, también cuando mira "Barra".
  ///
  /// ⚠️ [estacion] y [soloSinEstacion] viajan POR SEPARADO a propósito.
  /// Con un único `int?` no se podría expresar "todo" y "sin estación",
  /// porque `null` significa ambas cosas: el `null` de "no filtrar" y el
  /// `null` de `estacionId == null`. El llamante ya ha resuelto esa
  /// ambigüedad en `build` y pasa los dos valores ya sanados.
  List<KdsTicket> _filtrar(
    List<KdsTicket> tickets,
    int? estacion,
    bool soloSinEstacion,
  ) {
    if (estacion == null && !soloSinEstacion) return tickets;

    final salida = <KdsTicket>[];
    for (final ticket in tickets) {
      final items = ticket.items.where((i) {
        return soloSinEstacion
            ? i.item.estacionId == null
            : i.item.estacionId == estacion;
      }).toList();

      if (items.isEmpty) continue;

      salida.add(KdsTicket(
        comandaId: ticket.comandaId,
        mesaId: ticket.mesaId,
        mesaNombre: ticket.mesaNombre,
        items: items,
        pausados: items.where((i) => i.item.pausado).length,
      ));
    }
    return salida;
  }

  // ════════════════════════════════════════════════════════════════
  // SELECTOR DE ESTACIONES
  // ════════════════════════════════════════════════════════════════

  Widget _selector(
    List<DepartamentoEntity> departamentos,
    Map<int?, _ConteoEstacion> conteos,
  ) {
    var totalPendientes = 0;
    for (final conteo in conteos.values) {
      totalPendientes += conteo.pendientes;
    }

    final chips = <Widget>[
      _chip(
        label: 'Todas',
        icon: Icons.all_inclusive_rounded,
        color: _colorTodas,
        count: totalPendientes,
        seleccionado: _estacion == null && !_soloSinEstacion,
        onTap: () => setState(() {
          _estacion = null;
          _soloSinEstacion = false;
        }),
      ),
    ];

    for (final dep in departamentos) {
      final conteo = conteos[dep.id];
      if (conteo == null || conteo.total == 0) continue;
      chips.add(_chip(
        label: dep.nombre,
        icon: Icons.countertops_rounded,
        color: _colorTodas,
        count: conteo.pendientes,
        seleccionado: _estacion == dep.id && !_soloSinEstacion,
        onTap: () => setState(() {
          _estacion = dep.id;
          _soloSinEstacion = false;
        }),
      ));
    }

    // "Sin estación" aparece siempre que EXISTAN platos sin clasificar,
    // aunque su contador de pendientes sea 0: ese 0 ya está avisando de
    // que hay algo bloqueado, y esconderlo lo volvería inalcanzable.
    final sinEstacion = conteos[null];
    if (sinEstacion != null && sinEstacion.total > 0) {
      chips.add(_chip(
        label: 'Sin estación',
        icon: Icons.help_outline_rounded,
        color: _colorSinEstacion,
        count: sinEstacion.pendientes,
        seleccionado: _soloSinEstacion,
        onTap: () => setState(() {
          _estacion = null;
          _soloSinEstacion = true;
        }),
      ));
    }

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Center(child: chips[i]),
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required Color color,
    required int count,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return FiltroChip(
      label: label,
      icon: icon,
      color: color,
      count: count,
      selected: seleccionado,
      onTap: onTap,
      size: FiltroChipSize.small,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ESTADOS VACÍOS
  // ════════════════════════════════════════════════════════════════

  Widget _vacio({
    required IconData icono,
    required String titulo,
    required String detalle,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tono = color ?? colorScheme.primary;

    // ⚠️ POR QUÉ `LayoutBuilder` + `SingleChildScrollView`
    //
    // Un `Center` a secas no sobrevive a un viewport pequeño: es un
    // `Align`, y `Align` ni recorta ni encoge al hijo, lo deja desbordar.
    // Con el icono a 64 px, dos líneas de texto y `Padding.all(32)` el
    // bloque pide ~206 px; en cuanto le dan menos, salta el
    // "RenderFlex overflowed by N pixels" — y el N depende de lo que haya
    //riba, así que el mismo empty state cabe en una pantalla y no en otra.
    //
    // El patrón es el estándar para esto:
    //   · `minHeight: maxHeight` → si HAY sitio, el `Center` centra.
    //   · si NO hay sitio, el `ConstrainedBox` se queda con la altura
    //     natural del contenido y el `SingleChildScrollView` deja
    //     scrollear en vez de reventar.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Guarda por si algún día [_vacio] se usa con altura sin acotar:
        // un `minHeight` infinito en `ConstrainedBox` no compila bien.
        final alto = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 0.0;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: alto),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icono, size: 56, color: tono.withValues(alpha: 0.35)),
                    const SizedBox(height: 14),
                    Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
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
            ),
          ),
        );
      },
    );
  }

  Widget _sinEstaciones() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: _vacio(
            icono: Icons.countertops_rounded,
            titulo: 'Este local no tiene estaciones',
            detalle: 'Separa quién prepara qué. Sin estaciones, todos los '
                'platos caen en la columna "Sin estación".',
            color: _colorAviso,
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                FilledButton.icon(
                  key: const Key('btn-configurar-estaciones'),
                  onPressed: _configurarEstaciones,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Configurar estaciones'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Se crearán Cocina, Barra y Postres. '
                  'Podrás ajustarlas luego en Departamentos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// CTA cuando HAY pedidos pero ninguna estación.
  ///
  /// Va en barra, no como empty state a pantalla completa: los platos
  /// encolados ya se ven justo debajo y son lo que el cocinero necesita
  /// ahora. Tapar la cola con un "configura esto primero" obligaría a
  /// esperar a un alta para poder trabajar.
  Widget _barraConfigurarEstaciones() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _colorAviso.withValues(alpha: 0.10),
        border: Border(
          bottom: BorderSide(
            color: _colorAviso.withValues(alpha: 0.30),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.countertops_rounded,
              size: 18, color: _colorAviso),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sin estaciones. Todos los platos caen en '
              '"Sin estación".',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            key: const Key('btn-configurar-estaciones'),
            onPressed: _configurarEstaciones,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Configurar'),
          ),
        ],
      ),
    );
  }

  /// Abre el diálogo de estaciones y siembra las elegidas.
  ///
  /// Solo se llega aquí cuando el local no tiene NINGUNA: si ya hay
  /// alguna, la pantalla va a `_selector` y el alta manual se hace en
  /// Departamentos.
  Future<void> _configurarEstaciones() async {
    final localId = ref.read(localActualProvider);
    if (localId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final nombres = await ConfigurarEstacionesDialog.mostrar(context);

    // `null` = canceló. `[]` = aceptó sin marcar nada: no se crea nada y
    // no se avisa, porque no pasó nada.
    if (nombres == null || nombres.isEmpty) return;

    final resultado = await sembrarEstaciones(
      ref,
      localId: localId,
      nombres: nombres,
    );

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          resultado.completo
              ? '${resultado.creadas} estaciones creadas'
              : '${resultado.creadas} creadas · ${resultado.fallos.join(', ')}',
        ),
        backgroundColor: resultado.completo ? null : _colorError,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final localId = ref.watch(localActualProvider);

    final tickets = ref.watch(
      comandasProvider.select((s) => s.ticketsEnCola),
    );

    final conteos = _contar(tickets);

    // Si la estación seleccionada se queda vacía (porque el último plato
    // se entregó), el filtro deja de tener sentido y se vuelve a
    // "Todas". NO se resuelve escribiendo en los campos desde `build`
    // (eso provocaría un `setState` implícito en medio del render): se
    // calcula aquí una variable local, de modo que el chip marcado y la
    // lista siempre coinciden, y el estado real se limpia en el siguiente
    // tap.
    final sinEstacionVacia =
        (conteos[null]?.total ?? 0) == 0 && _soloSinEstacion;
    final estacionVacia =
        _estacion != null && (conteos[_estacion]?.total ?? 0) == 0;
    final filtroVivo = !sinEstacionVacia && !estacionVacia;

    final visibles = _filtrar(
      tickets,
      filtroVivo ? _estacion : null,
      filtroVivo && _soloSinEstacion,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Estaciones',
        showBackButton: true,
        actions: [
          if (visibles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  '${visibles.length} '
                  '${visibles.length == 1 ? 'ticket' : 'tickets'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    // ⚠️ NO `onSurfaceVariant`: es un gris pensado para
                    // fondos CLAROS, y el gradiente del `CustomAppBar` es
                    // azul. Ahí el contador quedaba ilegible.
                    //
                    // Blanco al 75 %, más que el 55 % del icono muteado
                    // porque esto es TEXTO y no un icono: a 12 px necesita
                    // más contraste para leerse de un vistazo.
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          // ⚠️ El toggle va SIEMPRE, incluso con la cola vacía: es un
          // control del dispositivo (silenciar el timbre mientras se
          // limpia la barra), no de los pedidos. Si se ocultara cuando no
          // hay nada en cola, el cocinero no podría silenciar el aviso
          // del PRIMER pedido, que es justo cuando más lo querría.
          //
          // ⚠️ El color apagado NO puede ser `onSurfaceVariant`: es un gris
          // pensado para fondos CLAROS y el gradiente del `CustomAppBar` es
          // azul. Sobre ese azul el icono muteado quedaba ilegible, que es
          // justo cuando más falta hace verlo.
          //
          // Blanco translúcido al 55% sigue comunicando "menos intenso que el
          // activo" (el activo va a blanco puro) y se ve sobre cualquier
          // punto del gradiente. No se usa `Colors.white54` porque es el
          // mismo color con otro número y no deja claro el porqué.
          AnimatedAppBarIcon(
            icon: Icons.volume_up_outlined,
            iconoAlternativo: Icons.volume_off_outlined,
            usarAlternativo: !_sonidoActivo,
            colorIcono: _sonidoActivo
                ? null
                : Colors.white.withValues(alpha: 0.55),
            tooltip: _sonidoActivo ? 'Silenciar avisos' : 'Activar avisos',
            onPressed: () => setState(() {
              _sonidoActivo = !_sonidoActivo;
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          // Tope de ancho en desktop. En un monitor de 1920 px las
          // `KdsTicketCard` se separaban 1900 px entre el nombre del plato y
          // el precio, y el chip de estación quedaba en la otra punta.
          // Mismo valor que usa `ComandaScreen` para que las dos pantallas
          // del módulo restaurante tengan la misma columna.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context)
                  ? _anchoMaxContenido
                  : double.infinity,
            ),
            child: Column(
              children: [
                if (localId == null)
                  Expanded(
                    child: _vacio(
                      icono: Icons.storefront_rounded,
                      titulo: 'Selecciona un local',
                      detalle: 'El KDS muestra la cola de un solo local.',
                    ),
                  )
                else
                  ..._cuerpo(localId, conteos, visibles, tickets, filtroVivo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cuerpo cuando YA hay local seleccionado.
  ///
  /// Devuelve `List<Widget>` porque se reparte dentro de un `Column`:
  /// separarlo del `build` evita que el `if (localId == null)` anide
  /// sesenta líneas de más.
  List<Widget> _cuerpo(
    int localId,
    Map<int?, _ConteoEstacion> conteos,
    List<KdsTicket> visibles,
    List<KdsTicket> todos,
    bool filtroVivo,
  ) {
    final departamentosAsync = ref.watch(
      departamentosActivosProvider(localId),
    );

    return departamentosAsync.when(
      loading: () => const [
        Expanded(child: Center(child: CircularProgressIndicator())),
      ],
      error: (e, st) => [
        Expanded(
          child: _vacio(
            icono: Icons.error_outline_rounded,
            titulo: 'No se pudieron cargar las estaciones',
            detalle: '$e',
            color: _colorError,
          ),
        ),
      ],
      data: (deps) {
        // ⚠️ El CTA de "Configurar estaciones" se muestra SIEMPRE que
        // haya 0 departamentos, y no solo cuando la cola está vacía: un
        // local recién migrado puede tener comandas encoladas y ninguna
        // estación, y sin este botón el cocinero se queda sin forma de
        // clasificar sus platos.
        if (deps.isEmpty) {
          // ⚠️ SIN estaciones Y SIN pedidos se muestra UNA sola pantalla.
          //
          // Antes se apilaban las dos: `Expanded(_sinEstaciones())` y
          // `Expanded(_lista(...))`. Como esta devuelve a su vez el
          // `_vacio` de "No hay pedidos en cola", el viewport se partía
          // en dos mitades y `_vacio` (icono 64 + textos + padding) se
          // quedaba sin sitio. `Center` no lo evita: es un `Align`, y
          // `Align` ni recorta ni encoge al hijo, solo lo desborda.
          if (todos.isEmpty) {
            return [Expanded(child: _sinEstaciones())];
          }
          return [
            _barraConfigurarEstaciones(),
            Expanded(child: _lista(visibles, todos)),
          ];
        }

        final ordenadas = [...deps]
          ..sort((a, b) => a.orden.compareTo(b.orden));

        return [
          _selector(ordenadas, conteos),
          Expanded(child: _lista(visibles, todos)),
        ];
      },
    );
  }

  Widget _lista(List<KdsTicket> visibles, List<KdsTicket> todos) {
    if (todos.isEmpty) {
      return _vacio(
        icono: Icons.check_circle_outline_rounded,
        titulo: 'No hay pedidos en cola',
        detalle: 'Aquí aparecerán en cuanto el mesero envíe a cocina.',
      );
    }

    // `todos` no vacío pero `visibles` vacío solo puede pasar con un
    // filtro activo: `build` ya garantiza que un filtro inválido no
    // recorta nada.
    if (visibles.isEmpty) {
      return _vacio(
        icono: Icons.filter_alt_off_rounded,
        titulo: 'Nada en esta estación',
        detalle: 'Hay ${todos.length} tickets, pero ninguno es de aquí.',
        color: _colorSinEstacion,
      );
    }

    return ListView.builder(
      // El offset de scroll sobrevive a las actualizaciones del provider
      // mientras el árbol conserve este key: sin él, cada plato nuevo
      // saltaría al principio y el cocinero perdería dónde estaba.
      key: const PageStorageKey('kds-lista-tickets'),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      itemCount: visibles.length,
      itemBuilder: (_, i) => KdsTicketCard(
        key: ValueKey('ticket-${visibles[i].comandaId}'),
        ticket: visibles[i],
        ahora: _ahora,
      ),
    );
  }
}

/// Conteo de una estación dentro de la cola del KDS.
class _ConteoEstacion {
  /// Platos visibles, pausados incluidos.
  int total = 0;

  /// Platos sin pausar: el trabajo realmente pendiente.
  int pendientes = 0;
}
