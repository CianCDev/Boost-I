// lib/features/pos/presentation/screens/caja/caja_screen.dart
//
// FASE 1 · Tablero de cobro del cajero (modo restaurante).
//
// ⚠️ POR QUÉ UNA PANTALLA APARTE Y NO UN MODO DENTRO DEL POS
//
// El POS de retail es catálogo + carrito: el cajero arma una venta desde
// cero. En restaurante el consumo ya existe en la comanda de la mesa; lo
// que falta es VERLO y COBRARLO. Meter eso en el POS obligaría a que el
// catálogo conviviera con un panel de mesas y a decidir qué pasa cuando el
// cajero toca un producto teniendo una comanda seleccionada.
//
// ⚠️ NO HAY PROVIDER NUEVO DE ESTADO
//
// Las dos fuentes ya existen y son la verdad: `mesasProvider` (estado de la
// mesa) y `comandasProvider` (consumo, estados de cocina y tickets). Crear
// un `CajaNotifier` que copiara esas listas sería un tercer sitio que hay
// que acordarse de refrescar. Aquí solo se DERIVA un índice `mesaId →
// comanda` en cada build.
//
// ⚠️ EL COBRO REUTILIZA EL FLUJO DEL POS
//
// `mostrarModalCobro` + `procesarVenta` son los mismos del mesero. La caja
// vuelca la comanda en el carrito con `ComandaCobroUtils.aCarrito` y, si el
// cajero cancela el cobro, restaura el carrito que hubiera antes.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';

import '../../controllers/cart_controller.dart';
import '../../providers/catalog/catalog_actions.dart';
import '../../providers/comanda_provider.dart';
import '../../providers/kds_ticket.dart';
import '../../providers/mesas_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/comanda_cobro_utils.dart';
import '../../utils/duracion_utils.dart';
import '../../widgets/appbar.dart';
import '../../widgets/caja/panel_cobro_comanda.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/segmented_toggle.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/time_badge.dart';
import '../../widgets/restaurante/confirmar_cobro_pendientes_dialog.dart';

enum _VistaCaja { mesas, porCobrar, cocina }

class CajaScreen extends ConsumerStatefulWidget {
  const CajaScreen({super.key});

  @override
  ConsumerState<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends ConsumerState<CajaScreen> {
  _VistaCaja _vista = _VistaCaja.mesas;
  MesaZona? _zona;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refrescar());
    // Solo para repintar las duraciones ("hace 42 min") y traer comandas
    // nuevas si el mesero envió desde otra ruta de la misma app.
    _tick = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted) return;
      setState(() {});
      ref.read(comandasProvider.notifier).cargar();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _refrescar() async {
    await Future.wait([
      ref.read(mesasProvider.notifier).cargar(),
      ref.read(comandasProvider.notifier).cargar(),
    ]);
  }

  // ── Índices derivados ────────────────────────────────────────────

  Map<int, CartSessionEntity> _comandasPorMesa(
    List<CartSessionEntity> comandas,
  ) {
    final mapa = <int, CartSessionEntity>{};
    for (final c in comandas) {
      final mesaId = c.mesaId;
      if (mesaId == null) continue;
      if (c.comandaEstado == ComandaEstado.cerrada ||
          c.comandaEstado == ComandaEstado.cancelada) {
        continue;
      }
      mapa[mesaId] = c;
    }
    return mapa;
  }

  // ── Aviso de mesa sin comanda ────────────────────────────────────

  void _avisarMesaSinComanda(MesaEntity mesa) {
    final detalle = switch (mesa.estado) {
      MesaEstado.libre => 'No hay ninguna comanda abierta en esta mesa.',
      MesaEstado.reservada => 'La mesa está reservada.',
      MesaEstado.porLimpiar => 'La mesa está pendiente de limpieza.',
      MesaEstado.ocupada =>
        'La mesa figura ocupada pero no tiene comanda viva. '
            'Revisá el salón.',
    };

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.table_restaurant_rounded),
            const SizedBox(width: 8),
            Expanded(child: Text(mesa.nombre)),
          ],
        ),
        content: Text(detalle, style: const TextStyle(height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ── Cobro ────────────────────────────────────────────────────────

  Future<void> _abrirCobro(CartSessionEntity comanda) async {
    final quiereCobrar = await PanelCobroComanda.mostrar(
      context,
      comanda: comanda,
    );
    if (quiereCobrar != true || !mounted) return;

    // 1. ¿Quedan platos en cocina? Mismo diálogo que usa el mesero.
    final enCocina = ComandaCobroUtils.enCocina(comanda);
    final listos = ComandaCobroUtils.listos(comanda);
    final proceder = await ConfirmarCobroPendientesDialog.mostrar(
      context,
      enCocina: enCocina,
      listos: listos,
    );
    if (!proceder || !mounted) return;

    // 2. ¿Hay platos que nunca salieron de la comanda? El aviso de arriba
    //    no los cuenta (no están en cocina), y cobrarlos deja al cliente
    //    pagando algo que no se preparó.
    final sinEnviar = ComandaCobroUtils.sinEnviar(comanda);
    if (sinEnviar > 0) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Platos sin enviar'),
          content: Text(
            sinEnviar == 1
                ? 'Hay 1 plato que todavía no se envió a cocina. '
                    '¿Cobrar igual?'
                : 'Hay $sinEnviar platos que todavía no se enviaron a '
                    'cocina. ¿Cobrar igual?',
            style: const TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cobrar igual'),
            ),
          ],
        ),
      );
      if (confirmar != true || !mounted) return;
    }

    await _ejecutarCobro(comanda);
  }

  Future<void> _ejecutarCobro(CartSessionEntity comanda) async {
    final comandas = ref.read(comandasProvider.notifier);

    // Guardar el carrito de retail, si había uno: volcar la comanda lo
    // pisa. Si el cajero cancela el cobro se restaura tal cual estaba.
    final carritoAntes = ref.read(cartProvider);
    final habiaCarrito = carritoAntes.items.isNotEmpty;

    comandas.seleccionarComanda(comanda.id);
    ref.read(cartProvider.notifier).reemplazarItems(
          ComandaCobroUtils.aCarrito(comanda),
          configIva: ConfiguracionIva(
            codigoPais: comanda.configIvaPais,
            porcentajeIva: comanda.configIvaPorcentaje,
            preciosIncluyenIva: comanda.configIvaPreciosIncluyenIva,
          ),
          ivaHabilitado: comanda.ivaHabilitado,
        );

    final cobrado = await ref
        .read(catalogActionsProvider)
        .mostrarModalCobro(
          context,
          ref.read(usuarioActualProvider),
          comanda: comanda,
        );

    if (!mounted) return;

    if (cobrado) {
      // `procesarVenta` vacía el carrito y el listener del provider cierra
      // la comanda y libera la mesa por su cuenta. Se llama igual: si el
      // listener todavía no corrió, esto lo remata; si ya corrió, devuelve
      // false con un error que aquí no interesa mostrar.
      await comandas.cerrarComanda();
      comandas.limpiarError();
      await _refrescar();
      return;
    }

    // Cobro cancelado: devolver el carrito como estaba.
    comandas.seleccionarComanda(null);
    if (habiaCarrito) {
      ref.read(cartProvider.notifier).reemplazarItems(
            carritoAntes.items,
            configIva: carritoAntes.configIva,
            ivaHabilitado: carritoAntes.ivaHabilitado,
          );
    } else {
      ref.read(cartProvider.notifier).limpiarCarrito();
    }
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mesasState = ref.watch(mesasProvider);
    final comandas = ref.watch(comandasProvider.select((s) => s.comandas));
    final tickets = ref.watch(comandasProvider.select((s) => s.ticketsEnCola));

    final porMesa = _comandasPorMesa(comandas);
    final porCobrar = comandas
        .where((c) => ComandaCobroUtils.listaParaCobrar(c))
        .toList()
      // `createdAt` NO es nullable en la entidad: el `?? DateTime.now()`
      // anterior era código muerto que el analyzer marcaba.
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final libres =
        mesasState.mesas.where((m) => m.estado == MesaEstado.libre).length;
    final ocupadas =
        mesasState.mesas.where((m) => m.estado == MesaEstado.ocupada).length;
    final platosEnCocina = comandas.fold<int>(
      0,
      (suma, c) => suma + ComandaCobroUtils.enCocina(c),
    );

    final mesasFiltradas = _zona == null
        ? mesasState.mesas
        : mesasState.mesas.where((m) => m.zona == _zona).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Caja',
        showBackButton: Navigator.of(context).canPop(),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _refrescar,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
          // El cajero aterriza AQUÍ al iniciar sesión (`home_por_rol.dart`),
          // así que la ruta no tiene nada debajo y `canPop` es `false`: sin
          // esta salida quedaría encerrado en la caja. Con `canPop` (llegó
          // desde el menú) el botón atrás ya cumple esa función.
          if (!Navigator.of(context).canPop())
            IconButton(
              tooltip: 'Menú principal',
              onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
              icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            ),
        ],
      ),
      body: Column(
        children: [
          _ResumenCaja(
            libres: libres,
            ocupadas: ocupadas,
            porCobrar: porCobrar.length,
            enCocina: platosEnCocina,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedToggle<_VistaCaja>(
              selected: _vista,
              onChanged: (v) => setState(() => _vista = v),
              items: const [
                SegmentedToggleItem(
                  value: _VistaCaja.mesas,
                  label: 'Mesas',
                  icon: Icons.table_restaurant_rounded,
                ),
                SegmentedToggleItem(
                  value: _VistaCaja.porCobrar,
                  label: 'Por cobrar',
                  icon: Icons.point_of_sale_rounded,
                ),
                SegmentedToggleItem(
                  value: _VistaCaja.cocina,
                  label: 'Cocina',
                  icon: Icons.soup_kitchen_rounded,
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _vista.index,
              children: [
                _MesasTab(
                  mesas: mesasFiltradas,
                  zonas: mesasState.zonasDisponibles,
                  zona: _zona,
                  onZona: (z) => setState(() => _zona = z),
                  comandasPorMesa: porMesa,
                  isLoading: mesasState.isLoading,
                  onMesa: (mesa) {
                    final comanda = porMesa[mesa.id];
                    if (comanda == null) {
                      _avisarMesaSinComanda(mesa);
                    } else {
                      _abrirCobro(comanda);
                    }
                  },
                ),
                _PorCobrarTab(
                  comandas: porCobrar,
                  onCobrar: _abrirCobro,
                ),
                _CocinaTab(tickets: tickets),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// RESUMEN
// ══════════════════════════════════════════════════════════════════

class _ResumenCaja extends StatelessWidget {
  final int libres;
  final int ocupadas;
  final int porCobrar;
  final int enCocina;

  const _ResumenCaja({
    required this.libres,
    required this.ocupadas,
    required this.porCobrar,
    required this.enCocina,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Metrica(
              label: 'Libres',
              valor: libres,
              color: const Color(0xFF10B981),
              icon: Icons.event_available_rounded,
            ),
            const SizedBox(width: 8),
            _Metrica(
              label: 'Ocupadas',
              valor: ocupadas,
              color: const Color(0xFFF59E0B),
              icon: Icons.people_alt_rounded,
            ),
            const SizedBox(width: 8),
            _Metrica(
              label: 'Por cobrar',
              valor: porCobrar,
              color: const Color(0xFF3B82F6),
              icon: Icons.receipt_long_rounded,
            ),
            const SizedBox(width: 8),
            _Metrica(
              label: 'En cocina',
              valor: enCocina,
              color: const Color(0xFFF97316),
              icon: Icons.soup_kitchen_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final String label;
  final int valor;
  final Color color;
  final IconData icon;

  const _Metrica({
    required this.label,
    required this.valor,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$valor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// MESAS
// ══════════════════════════════════════════════════════════════════

class _MesasTab extends StatelessWidget {
  final List<MesaEntity> mesas;
  final List<MesaZona> zonas;
  final MesaZona? zona;
  final ValueChanged<MesaZona?> onZona;
  final Map<int, CartSessionEntity> comandasPorMesa;
  final bool isLoading;
  final ValueChanged<MesaEntity> onMesa;

  const _MesasTab({
    required this.mesas,
    required this.zonas,
    required this.zona,
    required this.onZona,
    required this.comandasPorMesa,
    required this.isLoading,
    required this.onMesa,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && mesas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mesas.isEmpty) {
      return const _Vacio(
        icon: Icons.table_restaurant_outlined,
        titulo: 'Sin mesas configuradas',
        detalle: 'Creá las mesas del salón para empezar a cobrar.',
      );
    }

    return Column(
      children: [
        if (zonas.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _ChipZona(
                  label: 'Todas',
                  activo: zona == null,
                  onTap: () => onZona(null),
                ),
                for (final z in zonas)
                  _ChipZona(
                    label: etiquetaZona(z),
                    activo: zona == z,
                    onTap: () => onZona(z),
                  ),
              ],
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columnas = (constraints.maxWidth / 280).floor().clamp(1, 6);
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  mainAxisExtent: 176,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: mesas.length,
                itemBuilder: (_, i) {
                  final mesa = mesas[i];
                  return _MesaCajaCard(
                    mesa: mesa,
                    comanda: comandasPorMesa[mesa.id],
                    onTap: () => onMesa(mesa),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MesaCajaCard extends StatelessWidget {
  final MesaEntity mesa;
  final CartSessionEntity? comanda;
  final VoidCallback onTap;

  const _MesaCajaCard({
    required this.mesa,
    required this.comanda,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = switch (mesa.estado) {
      MesaEstado.libre => const Color(0xFF10B981),
      MesaEstado.ocupada => const Color(0xFFF59E0B),
      MesaEstado.reservada => const Color(0xFF3B82F6),
      MesaEstado.porLimpiar => const Color(0xFF94A3B8),
    };

    final c = comanda;
    final porCobrar = c != null && ComandaCobroUtils.listaParaCobrar(c);

    return GlassCard(
      onTap: onTap,
      showStatusBar: true,
      statusColor: porCobrar ? const Color(0xFF10B981) : colorEstado,
      isHighlighted: porCobrar,
      highlightColor: const Color(0xFF10B981),
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mesa.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                label: MesasNotifier.etiquetaEstado(mesa.estado),
                color: colorEstado,
                size: StatusBadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${etiquetaZona(mesa.zona)} · ${mesa.capacidad} pax',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (c == null)
            Text(
              'Sin comanda',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Text(
              '\$${c.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (porCobrar)
                  const _MiniChip(
                    label: 'Por cobrar',
                    color: Color(0xFF10B981),
                  ),
                if (ComandaCobroUtils.enCocina(c) > 0)
                  _MiniChip(
                    label: '${ComandaCobroUtils.enCocina(c)} en cocina',
                    color: const Color(0xFFF59E0B),
                  ),
                if (ComandaCobroUtils.sinEnviar(c) > 0)
                  _MiniChip(
                    label: '${ComandaCobroUtils.sinEnviar(c)} sin enviar',
                    color: const Color(0xFF94A3B8),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// POR COBRAR
// ══════════════════════════════════════════════════════════════════

class _PorCobrarTab extends StatelessWidget {
  final List<CartSessionEntity> comandas;
  final ValueChanged<CartSessionEntity> onCobrar;

  const _PorCobrarTab({required this.comandas, required this.onCobrar});

  @override
  Widget build(BuildContext context) {
    if (comandas.isEmpty) {
      return const _Vacio(
        icon: Icons.check_circle_outline_rounded,
        titulo: 'Nada por cobrar',
        detalle: 'Cuando la cocina termine una comanda, aparece aquí.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: comandas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final c = comandas[i];
        return GlassCard(
          margin: EdgeInsets.zero,
          showStatusBar: true,
          statusColor: const Color(0xFF10B981),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.table_restaurant_rounded,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.mesaNombre ?? 'Para llevar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${c.items.length} plato(s) · '
                      '${DuracionUtils.hace(c.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${c.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                ),
                onPressed: () => onCobrar(c),
                child: const Text('Cobrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// COCINA (solo lectura)
// ══════════════════════════════════════════════════════════════════

class _CocinaTab extends StatelessWidget {
  final List<KdsTicket> tickets;

  const _CocinaTab({required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const _Vacio(
        icon: Icons.soup_kitchen_outlined,
        titulo: 'Cocina al día',
        detalle: 'No hay platos en cola ni en preparación.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final t = tickets[i];
        final minutos = DuracionUtils.minutosDesde(t.entradaEn);
        final color = TimeBadge.colorPorMinutos(minutos);

        return GlassCard(
          margin: EdgeInsets.zero,
          showStatusBar: true,
          statusColor: color,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.mesaNombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _MiniChip(
                    label: '$minutos min',
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final entrada in t.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 34,
                        child: Text(
                          _cantidad(entrada.item.cantidad),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(entrada.item.productoNombre),
                      ),
                      _MiniChip(
                        label: _etiqueta(entrada.item.estadoPlato.name),
                        color: color,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _cantidad(double valor) {
    if (valor == valor.roundToDouble()) return valor.toInt().toString();
    return valor.toStringAsFixed(3);
  }

  static String _etiqueta(String estado) {
    switch (estado) {
      case 'enCola':
        return 'En cola';
      case 'enPreparacion':
        return 'Preparando';
      case 'listo':
        return 'Listo';
      default:
        return estado;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// COMPONENTES COMPARTIDOS
// ══════════════════════════════════════════════════════════════════

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ChipZona extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _ChipZona({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo
        ? const Color(0xFF5352ED)
        : Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: activo ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activo ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String detalle;

  const _Vacio({
    required this.icon,
    required this.titulo,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: muted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              detalle,
              style: TextStyle(fontSize: 13, color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
