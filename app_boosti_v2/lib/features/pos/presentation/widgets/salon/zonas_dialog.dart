// lib/features/pos/presentation/widgets/salon/zonas_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/zona_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/mesas_provider.dart';

import '../common/glass_dialog.dart';

/// Gestión de zonas del local (R.1b): crear, renombrar, reordenar y
/// eliminar.
///
/// El renombre hace cascada sobre las mesas en `MesasNotifier`; acá solo
/// se pide el nombre nuevo.
class ZonasDialog extends ConsumerStatefulWidget {
  const ZonasDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const ZonasDialog(),
    );
  }

  @override
  ConsumerState<ZonasDialog> createState() => _ZonasDialogState();
}

class _ZonasDialogState extends ConsumerState<ZonasDialog> {
  bool _ocupado = false;

  Future<void> _crear() async {
    final nombre = await _pedirNombre(titulo: 'Nueva zona');
    if (nombre == null) return;

    setState(() => _ocupado = true);
    final id = await ref.read(mesasProvider.notifier).crearZona(nombre: nombre);
    if (!mounted) return;
    setState(() => _ocupado = false);
    if (id == null) _mostrarError();
  }

  Future<void> _renombrar(ZonaEntity zona) async {
    final nombre = await _pedirNombre(
      titulo: 'Renombrar zona',
      inicial: zona.nombre,
    );
    if (nombre == null || nombre == zona.nombre) return;

    setState(() => _ocupado = true);
    final ok = await ref
        .read(mesasProvider.notifier)
        .renombrarZona(zona.id, nombre);
    if (!mounted) return;
    setState(() => _ocupado = false);
    if (!ok) _mostrarError();
  }

  Future<void> _eliminar(ZonaEntity zona) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar zona'),
        content: Text('¿Eliminar "${zona.nombre}"? '
            'Solo se puede si no tiene mesas asignadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _ocupado = true);
    final ok = await ref.read(mesasProvider.notifier).eliminarZona(zona.id);
    if (!mounted) return;
    setState(() => _ocupado = false);
    if (!ok) _mostrarError();
  }

  Future<void> _mover(List<ZonaEntity> zonas, int indice, int delta) async {
    final destino = indice + delta;
    if (destino < 0 || destino >= zonas.length) return;

    final ids = zonas.map((z) => z.id).toList();
    final movido = ids.removeAt(indice);
    ids.insert(destino, movido);

    setState(() => _ocupado = true);
    final ok = await ref.read(mesasProvider.notifier).reordenarZonas(ids);
    if (!mounted) return;
    setState(() => _ocupado = false);
    if (!ok) _mostrarError();
  }

  void _mostrarError() {
    final error = ref.read(mesasProvider).error;
    if (error == null || error.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<String?> _pedirNombre({
    required String titulo,
    String inicial = '',
  }) {
    final ctrl = TextEditingController(text: inicial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Patio',
          ),
          onSubmitted: (v) {
            final t = v.trim();
            if (t.isEmpty) return;
            Navigator.of(ctx).pop(t);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              Navigator.of(ctx).pop(t);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mesasProvider);
    final zonas = state.zonas;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 460,
      accentColor: colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_location_alt_outlined,
                    color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Zonas del local',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _ocupado ? null : _crear,
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Nueva zona',
                ),
              ],
            ),
            Text(
              'Se usan para filtrar el salón y la caja. El orden define '
              'cómo aparecen.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            if (zonas.isEmpty)
              Text(
                'Todavía no hay zonas.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < zonas.length; i++)
                        _FilaZona(
                          zona: zonas[i],
                          esPrimera: i == 0,
                          esUltima: i == zonas.length - 1,
                          habilitado: !_ocupado,
                          onSubir: () => _mover(zonas, i, -1),
                          onBajar: () => _mover(zonas, i, 1),
                          onRenombrar: () => _renombrar(zonas[i]),
                          onEliminar: () => _eliminar(zonas[i]),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _ocupado ? null : () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaZona extends StatelessWidget {
  final ZonaEntity zona;
  final bool esPrimera;
  final bool esUltima;
  final bool habilitado;
  final VoidCallback onSubir;
  final VoidCallback onBajar;
  final VoidCallback onRenombrar;
  final VoidCallback onEliminar;

  const _FilaZona({
    required this.zona,
    required this.esPrimera,
    required this.esUltima,
    required this.habilitado,
    required this.onSubir,
    required this.onBajar,
    required this.onRenombrar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.place_outlined,
              size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              zona.nombre,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: habilitado && !esPrimera ? onSubir : null,
            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
            tooltip: 'Subir',
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: habilitado && !esUltima ? onBajar : null,
            icon: const Icon(Icons.arrow_downward_rounded, size: 18),
            tooltip: 'Bajar',
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: habilitado ? onRenombrar : null,
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Renombrar',
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: habilitado ? onEliminar : null,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}
