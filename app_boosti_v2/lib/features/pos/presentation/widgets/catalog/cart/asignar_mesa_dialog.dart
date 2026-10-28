// lib/features/pos/presentation/widgets/catalog/cart/asignar_mesa_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/mesas_provider.dart';

import '../../common/glass_card.dart';
import '../../common/glass_dialog.dart';
import '../../common/status_badge.dart';
import '../../salon/mesa_card.dart';

/// Diálogo para asignar el carrito a una mesa.
///
/// C1: NO permite crear mesas desde aquí (solo desde el Salón).
/// D1: "Cancelar comanda" solo aparece si ya hay una asignada.
class AsignarMesaDialog extends ConsumerStatefulWidget {
  const AsignarMesaDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const AsignarMesaDialog(),
    );
  }

  @override
  ConsumerState<AsignarMesaDialog> createState() => _AsignarMesaDialogState();
}

class _AsignarMesaDialogState extends ConsumerState<AsignarMesaDialog> {
  final _buscadorCtrl = TextEditingController();
  String _query = '';

  static const _colorOcupada = Color(0xFFF59E0B);
  static const _colorPeligro = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mesasProvider.notifier).cargar();
    });
  }

  @override
  void dispose() {
    _buscadorCtrl.dispose();
    super.dispose();
  }

  bool _coincide(MesaEntity m) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return m.nombre.toLowerCase().contains(q) ||
        m.zonaEfectiva.toLowerCase().contains(q);
  }

  /// Agrupa por nombre de zona respetando el orden de las zonas del local.
  Map<String, List<MesaEntity>> _porZona(List<MesaEntity> mesas) {
    final mapa = <String, List<MesaEntity>>{};
    for (final m in mesas) {
      mapa.putIfAbsent(m.zonaEfectiva, () => []).add(m);
    }
    return mapa;
  }

  Future<void> _asignar(MesaEntity mesa) async {
    final notifier = ref.read(comandasProvider.notifier);
    final hayActiva = ref.read(comandasProvider).comandaActivaId != null;

    final msg = hayActiva
        ? await notifier.cambiarMesa(mesa.id)
        : await notifier.asignarMesa(mesa.id);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Asignado a ${mesa.nombre}'),
        backgroundColor: msg == null ? const Color(0xFF10B981) : _colorPeligro,
      ),
    );
  }

  Future<void> _quitarMesa() async {
    await ref.read(comandasProvider.notifier).desasignarMesa();
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mesa quitada. El carrito queda como venta directa.'),
      ),
    );
  }

  Future<void> _cancelarComanda() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar comanda'),
        content: const Text(
          'Se cancela la comanda y la mesa queda libre. '
          'Los productos del carrito NO se borran.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _colorPeligro),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar comanda'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    await ref.read(comandasProvider.notifier).cancelarComandaActiva();
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comanda cancelada. Mesa liberada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mesasState = ref.watch(mesasProvider);
    final comandaState = ref.watch(comandasProvider);
    final tieneMesa = comandaState.comandaActivaId != null;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 460,
      accentColor: _colorOcupada,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.table_restaurant_rounded,
                    color: _colorOcupada),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Asignar a mesa',
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
            const SizedBox(height: 12),

            // ── Buscador ──
            TextField(
              controller: _buscadorCtrl,
              autofocus: false,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: const InputDecoration(
                hintText: 'Buscar mesa o zona...',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),

            // ── Acciones sobre la comanda activa ──
            if (tieneMesa) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _quitarMesa,
                      icon: const Icon(Icons.link_off_rounded, size: 18),
                      label: const Text('Quitar mesa'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _colorPeligro,
                      ),
                      onPressed: _cancelarComanda,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 10),
            ],

            // ── Lista ──
            Flexible(
              child: mesasState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _lista(context, mesasState),
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lista(BuildContext context, MesasState state) {
    final colorScheme = Theme.of(context).colorScheme;

    final filtradas = state.mesas.where(_coincide).toList();

    if (filtradas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Icon(Icons.table_restaurant_outlined,
                size: 44, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              state.mesas.isEmpty
                  ? 'No hay mesas en este local.'
                  : 'Ninguna mesa coincide.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (state.mesas.isEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Crea mesas desde el Salón.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Ocupadas primero: son las relevantes para adjuntar.
    final ocupadas = filtradas
        .where((m) => m.estado == MesaEstado.ocupada)
        .toList();
    final libres = filtradas
        .where((m) => m.estado == MesaEstado.libre)
        .toList();
    final otras = filtradas
        .where((m) =>
            m.estado != MesaEstado.ocupada && m.estado != MesaEstado.libre)
        .toList();

    return ListView(
      shrinkWrap: true,
      children: [
        if (ocupadas.isNotEmpty) ...[
          _seccion(context, 'Ocupadas', ocupadas.length),
          ..._porZona(ocupadas).entries.map((e) => _grupo(
                context,
                e.key,
                e.value,
              )),
        ],
        if (libres.isNotEmpty) ...[
          _seccion(context, 'Libres', libres.length),
          ..._porZona(libres).entries.map((e) => _grupo(
                context,
                e.key,
                e.value,
              )),
        ],
        if (otras.isNotEmpty) ...[
          _seccion(context, 'No disponibles', otras.length),
          ...otras.map((m) => _fila(context, m, false)),
        ],
      ],
    );
  }

  Widget _seccion(BuildContext context, String titulo, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          Text(
            titulo.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grupo(BuildContext context, String zona, List<MesaEntity> mesas) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, top: 4, bottom: 4),
          child: Text(
            zona,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ),
        ...mesas.map((m) => _fila(context, m, true)),
      ],
    );
  }

  Widget _fila(BuildContext context, MesaEntity mesa, bool seleccionable) {
    final colorScheme = Theme.of(context).colorScheme;
    final ocupada = mesa.estado == MesaEstado.ocupada;
    final colorEstado = MesaCard.colorDeEstado(mesa.estado);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(12),
        nestedGlass: true,
        onTap: seleccionable ? () => _asignar(mesa) : null,
        showStatusBar: true,
        statusColor: colorEstado,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mesa.nombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mesa.zonaEfectiva} · ${mesa.capacidad} pax',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (ocupada && mesa.ocupadaDesde != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Abierta hace ${_duracion(mesa.ocupadaDesde!)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _colorOcupada,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: _etiquetaEstado(mesa.estado),
              color: colorEstado,
              size: StatusBadgeSize.small,
            ),
          ],
        ),
      ),
    );
  }

  static String _etiquetaEstado(MesaEstado e) {
    switch (e) {
      case MesaEstado.libre:
        return 'Libre';
      case MesaEstado.ocupada:
        return 'Ocupada';
      case MesaEstado.reservada:
        return 'Reservada';
      case MesaEstado.porLimpiar:
        return 'Por limpiar';
    }
  }

  static String _duracion(DateTime desde) {
    final d = DateTime.now().difference(desde);
    if (d.inHours < 1) return '${d.inMinutes} min';
    if (d.inDays < 1) return '${d.inHours} h';
    return '${d.inDays} d';
  }
}