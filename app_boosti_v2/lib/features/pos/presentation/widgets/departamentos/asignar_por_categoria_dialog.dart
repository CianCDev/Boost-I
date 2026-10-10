// lib/features/pos/presentation/widgets/departamentos/asignar_por_categoria_dialog.dart
//
// R.3.2 · Bulk "asignar estaciones por categoría".
//
// Sin esto, el onboarding del KDS obliga a editar 200 productos uno a uno:
// "cada Lomo saltado → Cocina", "cada Margarita → Barra". Con esto se
// declara una regla por categoría y se aplica de golpe.
//
// REGLA CLAVE: solo toca los productos con `departamentoId == null` (decisión
// Q2). Los que ya tienen estación son trabajo previo y no se pisan. El
// diálogo muestra el contador ANTES de aplicar, para que el usuario sepa
// exactamente cuántos van a cambiar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/categoria_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/categorias_provider.dart';
import '../../providers/local_actual_provider.dart';
import '../common/departamento_selector.dart';
import '../common/glass_dialog.dart';

class AsignarPorCategoriaDialog extends ConsumerStatefulWidget {
  const AsignarPorCategoriaDialog({super.key});

  @override
  ConsumerState<AsignarPorCategoriaDialog> createState() =>
      _AsignarPorCategoriaDialogState();
}

class _FilaCategoria {
  final CategoriaEntity categoria;
  final int totalProductos;
  final int sinEstacion;
  int? departamentoId;

  _FilaCategoria({
    required this.categoria,
    required this.totalProductos,
    required this.sinEstacion,
  });

  /// Hay algo que hacer en esta fila.
  bool get pendiente => departamentoId != null && sinEstacion > 0;

  /// Lo que se sobreescribiría si el usuario forzara.
  int get yaAsignados => totalProductos - sinEstacion;
}

class _AsignarPorCategoriaDialogState
    extends ConsumerState<AsignarPorCategoriaDialog> {
  List<_FilaCategoria> _filas = [];
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final localId = ref.read(localActualProvider);
    if (localId == null) {
      setState(() {
        _cargando = false;
        _error = 'Selecciona un local primero.';
      });
      return;
    }

    final categorias = await ref.read(categoriasProvider.future);
    final isar = IsarService();

    final filas = <_FilaCategoria>[];
    for (final c in categorias) {
      final productos = await isar.obtenerProductosPorCategoriaId(c.id);
      if (productos.isEmpty) continue;
      filas.add(_FilaCategoria(
        categoria: c,
        totalProductos: productos.length,
        sinEstacion:
            productos.where((p) => p.departamentoId == null).length,
      ));
    }

    if (!mounted) return;
    setState(() {
      _filas = filas;
      _cargando = false;
    });
  }

  int get _totalPendientes =>
      _filas.where((f) => f.pendiente).fold(0, (s, f) => s + f.sinEstacion);

  int get _totalRespetados => _filas
      .where((f) => f.pendiente)
      .fold(0, (s, f) => s + f.yaAsignados);

  Future<void> _aplicar() async {
    setState(() => _guardando = true);

    final isar = IsarService();
    var modificados = 0;
    var respetados = 0;

    for (final fila in _filas) {
      if (!fila.pendiente) continue;

      final productos =
          await isar.obtenerProductosPorCategoriaId(fila.categoria.id);
      final sinEstacion = productos
          .where((p) => p.departamentoId == null)
          .map((p) => p.id)
          .toList();

      modificados += await isar.asignarDepartamentoAProductos(
        sinEstacion,
        fila.departamentoId,
      );
      respetados += productos.length - sinEstacion.length;
    }

    if (!mounted) return;
    setState(() => _guardando = false);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          respetados == 0
              ? 'Se asignaron $modificados productos.'
              : 'Se asignaron $modificados productos. '
                  '$respetados ya tenían estación y no se tocaron.',
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    if (navigator.mounted) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 620,
      maxHeightFactor: 0.85,
      accentColor: const Color(0xFFF59E0B),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category_outlined, color: Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Asignar estaciones por categoría',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _guardando ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Los productos que YA tienen estación se respetan. '
              'Solo se asignan los que están sin configurar.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(child: _cuerpo(colorScheme)),
            const SizedBox(height: 12),
            _barraAcciones(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _cuerpo(ColorScheme colorScheme) {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }

    if (_filas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 40, color: colorScheme.outline),
            const SizedBox(height: 10),
            Text(
              'Ninguna categoría tiene productos.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _filas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _fila(context, _filas[i], colorScheme),
    );
  }

  Widget _fila(BuildContext context, _FilaCategoria fila, ColorScheme cs) {
    final pendiente = fila.sinEstacion > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fila.categoria.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                pendiente
                    ? '${fila.sinEstacion}/${fila.totalProductos} sin estación'
                    : 'Ya configurados (${fila.totalProductos})',
                style: TextStyle(
                  fontSize: 11,
                  color: pendiente
                      ? const Color(0xFFF59E0B)
                      : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DepartamentoSelector(
            value: fila.departamentoId,
            includeSinEstacion: false,
            label: 'Estación',
            onChanged: (id) => setState(() => fila.departamentoId = id),
          ),
        ],
      ),
    );
  }

  Widget _barraAcciones(ColorScheme cs) {
    final pendientes = _totalPendientes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pendientes > 0 && _totalRespetados > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Se asignarán $pendientes productos. '
              '$_totalRespetados ya tienen estación y no se tocarán.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _guardando ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: (_guardando || pendientes == 0) ? null : _aplicar,
              icon: _guardando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(
                pendientes == 0
                    ? 'Nada que asignar'
                    : 'Asignar $pendientes',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
