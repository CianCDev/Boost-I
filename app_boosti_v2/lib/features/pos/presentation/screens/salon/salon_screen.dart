// lib/features/pos/presentation/screens/salon/salon_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/mesas_provider.dart';

import '../restaurante/comanda_screen.dart';

import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/animated_appbar_icon.dart';
import '../../widgets/salon/mesa_card.dart';
import '../../widgets/salon/mesa_form_dialog.dart';

/// Salón: grid de mesas del local activo.
///
/// R.1: alta, edición, estado y unión. R.2: abrir comanda desde la mesa.
class SalonScreen extends ConsumerStatefulWidget {
  const SalonScreen({super.key});

  @override
  ConsumerState<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends ConsumerState<SalonScreen> {
  /// Evita apilar dos ComandaScreen con doble toque (R.2).
  bool _abriendoComanda = false;
  @override
  void initState() {
    super.initState();
    // El provider ya carga solo en su factory, pero refrescamos por si
    // el usuario llega desde otra pantalla con la lista desfasada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mesasProvider.notifier).cargar();
    });
  }

  int _columnasPara(double ancho) {
    if (ancho < 380) return 1;
    if (ResponsiveHelper.isMobile(context)) return 2;
    if (ResponsiveHelper.isTablet(context)) return 3;
    if (ancho < 1300) return 4;
    return 5;
  }

  Future<void> _abrirForm({MesaEntity? mesa}) async {
    final guardado = await MesaFormDialog.mostrar(context, mesa: mesa);
    if (guardado != true || !mounted) return;

    // ⚠️ Guard de ruta: si mientras el formulario estaba abierto se abrió
    // una ComandaScreen encima, NO queremos mostrar aquí el snackbar. El
    // `ScaffoldMessenger` es compartido por toda la app, así que sin este
    // check el mensaje de "Mesa creada/actualizada" aparecía encima de la
    // comanda, confundiendo.
    final esRutaActual = ModalRoute.of(context)?.isCurrent ?? false;
    if (!esRutaActual) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesa == null ? 'Mesa creada' : 'Mesa actualizada'),
        backgroundColor: MesaCard.colorLibre,
      ),
    );
  }

  /// R.2 · Comportamiento del tap en una mesa, según su estado.
  ///
  /// `libre` → muestra diálogo con opciones.
  /// `ocupada` → abre la comanda existente directamente.
  /// `reservada` / `porLimpiar` → solo avisan.
  Future<void> _tapMesa(MesaEntity mesa) async {
    switch (mesa.estado) {
      case MesaEstado.libre:
        await _mostrarDialogoMesaLibre(mesa);
        return;

      case MesaEstado.ocupada:
        await _abrirComanda(mesa);
        return;

      case MesaEstado.reservada:
        _info(
          '${mesa.nombre} está reservada. '
          'La reserva se gestiona en su pantalla (R.7).',
        );
        return;

      case MesaEstado.porLimpiar:
        _info(
          '${mesa.nombre} necesita limpieza. '
          'Cámbiala a "Libre" con una pulsación larga para abrir comanda.',
        );
        return;
    }
  }

  /// Diálogo que se muestra al tocar una mesa LIBRE.
  ///
  /// Permite elegir: nueva comanda, ver detalles, unir mesas o cancelar.
  Future<void> _mostrarDialogoMesaLibre(MesaEntity mesa) async {
    if (!mounted) return;

    final accion = await showModalBottomSheet<AccionMesaLibre>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DialogoMesaLibre(mesa: mesa),
    );

    if (!mounted) return;

    switch (accion) {
      case AccionMesaLibre.nuevaComanda:
        await _abrirComanda(mesa);
      case AccionMesaLibre.verDetalles:
        _mostrarDetallesMesa(mesa);
      case AccionMesaLibre.unirMesas:
        _abrirForm(mesa: mesa); // reutiliza el formulario para unir
      case AccionMesaLibre.cancelar:
      case null:
        return;
    }
  }

  void _mostrarDetallesMesa(MesaEntity mesa) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Detalles de ${mesa.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detalleFila('Zona', etiquetaZona(mesa.zona)),
            _detalleFila('Capacidad', '${mesa.capacidad} pax'),
            _detalleFila('Estado', MesasNotifier.etiquetaEstado(mesa.estado)),
            if (mesa.estaUnida) _detalleFila('Unida a', 'Mesa ID ${mesa.unidaConMesaId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detalleFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              etiqueta,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Abre (o retoma) la comanda de la mesa y navega a su pantalla.
  Future<void> _abrirComanda(MesaEntity mesa) async {
    // ⚠️ Guarda anti-doble-toque.
    //
    // Sin esto, dos taps seguidos en la misma mesa apilaban DOS
    // ComandaScreen: el segundo `abrirComanda` encontraba la comanda que el
    // primero acababa de crear y la empujaba otra vez. Se veía como un
    // "abre dos veces" y desincronizaba la UI.
    if (_abriendoComanda) return;
    _abriendoComanda = true;

    try {
      final notifier = ref.read(comandasProvider.notifier);
      final comandaId = await notifier.abrirComanda(mesa.id);

      if (!mounted) return;

      if (comandaId == null) {
        final error = ref.read(comandasProvider).error;
        _info(error ?? 'No se pudo abrir la comanda.');
        return;
      }

      // Reflejar el cambio de estado de la mesa en el grid sin recargar.
      ref.read(mesasProvider.notifier).cargar();

      final cerrada = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ComandaScreen(
            sessionId: ComandasNotifier.sessionIdDeMesa(mesa.id),
            mesaId: mesa.id,
          ),
        ),
      );

      if (!mounted) return;

      // Volvemos de la comanda: puede haberse cerrado o cancelado.
      ref.read(mesasProvider.notifier).cargar();
      ref.read(comandasProvider.notifier).cargar();

      if (cerrada == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comanda finalizada. Mesa liberada.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } finally {
      _abriendoComanda = false;
    }
  }

  void _info(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mesasProvider);
    final notifier = ref.read(mesasProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final esMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Salón',
        showBackButton: true,
        actions: [
          // Filtro por zona
          if (state.zonasDisponibles.isNotEmpty)
            PopupMenuButton<MesaZona?>(
              tooltip: 'Filtrar por zona',
              icon: Icon(
                state.zonaFiltro == null
                    ? Icons.filter_alt_outlined
                    : Icons.filter_alt_rounded,
                color: state.zonaFiltro == null
                    ? null
                    : MesaCard.colorLibre,
              ),
              onSelected: notifier.filtrarPorZona,
              itemBuilder: (_) => [
                const PopupMenuItem<MesaZona?>(
                  value: null,
                  child: Text('Todas las zonas'),
                ),
                ...state.zonasDisponibles.map(
                  (z) => PopupMenuItem<MesaZona?>(
                    value: z,
                    child: Text(etiquetaZona(z)),
                  ),
                ),
              ],
            ),
          AnimatedAppBarIcon(
            icon: Icons.refresh_rounded,
            tooltip: 'Refrescar',
            onPressed: () => notifier.cargar(),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(),
        icon: const Icon(Icons.add_rounded),
        label: Text(esMobile ? 'Mesa' : 'Nueva mesa'),
      ),

      // ── Cuerpo ──
      body: SafeArea(
        child: _cuerpo(context, state, notifier, colorScheme),
      ),
    );
  }

  Widget _cuerpo(
    BuildContext context,
    MesasState state,
    MesasNotifier notifier,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sin local activo no se pueden crear mesas: no tiene sentido mostrar
    // el botón de crear si `crearMesa` va a fallar.
    if (state.localId == null) {
      return _vacio(
        icon: Icons.storefront_outlined,
        titulo: 'No hay local seleccionado',
        mensaje: 'Selecciona un local para ver su salón.',
      );
    }

    final mesas = state.mesasVisibles;

    if (state.mesas.isEmpty) {
      return _vacio(
        icon: Icons.table_restaurant_outlined,
        titulo: 'No hay mesas configuradas',
        mensaje: 'Crea la primera mesa de este local.',
      );
    }

    if (mesas.isEmpty) {
      return _vacio(
        icon: Icons.filter_alt_off_outlined,
        titulo: 'Ninguna mesa en esa zona',
        mensaje: 'Cambia el filtro o crea una mesa en '
            '${etiquetaZona(state.zonaFiltro!)}.',
        accion: FilledButton.tonal(
          onPressed: () => notifier.filtrarPorZona(null),
          child: const Text('Ver todas las zonas'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = _columnasPara(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: mesas.length,
          itemBuilder: (context, i) {
            final mesa = mesas[i];
            return MesaCard(
              mesa: mesa,
              onTap: () => _tapMesa(mesa),
              onLongPress: () => _abrirForm(mesa: mesa),
            );
          },
        );
      },
    );
  }

  Widget _vacio({
    required IconData icon,
    required String titulo,
    required String mensaje,
    Widget? accion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (accion != null) ...[
              const SizedBox(height: 20),
              accion,
            ],
          ],
        ),
      ),
    );
  }
}

/// Qué hacer con una mesa libre.
enum AccionMesaLibre { nuevaComanda, verDetalles, unirMesas, cancelar }

/// Bottom sheet que aparece al tocar una mesa libre.
class _DialogoMesaLibre extends StatelessWidget {
  final MesaEntity mesa;

  const _DialogoMesaLibre({required this.mesa});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrastre
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              mesa.nombre,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mesa libre · ${mesa.capacidad} pax · ${etiquetaZona(mesa.zona)}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Opciones
            _OpcionMesaLibre(
              icon: Icons.add_rounded,
              iconColor: MesaCard.colorLibre,
              titulo: 'Nueva comanda',
              subtitulo: 'Abrir pedido para esta mesa',
              onTap: () => Navigator.pop(context, AccionMesaLibre.nuevaComanda),
            ),
            _OpcionMesaLibre(
              icon: Icons.info_outline_rounded,
              iconColor: colorScheme.primary,
              titulo: 'Ver detalles',
              subtitulo: 'Capacidad, zona, estado, uniones',
              onTap: () => Navigator.pop(context, AccionMesaLibre.verDetalles),
            ),
            _OpcionMesaLibre(
              icon: Icons.merge_rounded,
              iconColor: Colors.orange,
              titulo: 'Unir mesas',
              subtitulo: 'Combinar con otra mesa libre',
              onTap: () => Navigator.pop(context, AccionMesaLibre.unirMesas),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, AccionMesaLibre.cancelar),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionMesaLibre extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcionMesaLibre({
    required this.icon,
    required this.iconColor,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}