// lib/features/pos/presentation/widgets/salon/mesa_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/zona_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/mesas_provider.dart';

import '../common/glass_card.dart';
import '../common/glass_dialog.dart';
import 'mesa_card.dart';

/// Formulario de alta / edición de una mesa.
///
/// Devuelve `true` si guardó, `false` si canceló.
class MesaFormDialog extends ConsumerStatefulWidget {
  /// `null` = crear. Con valor = editar.
  final MesaEntity? mesa;

  const MesaFormDialog({super.key, this.mesa});

  /// Abre el diálogo y devuelve si se guardó.
  static Future<bool?> mostrar(BuildContext context, {MesaEntity? mesa}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => MesaFormDialog(mesa: mesa),
    );
  }

  @override
  ConsumerState<MesaFormDialog> createState() => _MesaFormDialogState();
}

class _MesaFormDialogState extends ConsumerState<MesaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _capacidadCtrl;

  late String? _zonaNombre;
  late MesaEstado _estado;
  bool _isSaving = false;

  bool get _esEdicion => widget.mesa != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mesa;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _capacidadCtrl =
        TextEditingController(text: '${m?.capacidad ?? 4}');
    _zonaNombre = m?.zonaNombre ?? m?.zonaEfectiva;
    _estado = m?.estado ?? MesaEstado.libre;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _capacidadCtrl.dispose();
    super.dispose();
  }

  /// Nombre de zona que debe mostrar el dropdown.
  String? _nombreZonaEfectivo(List<ZonaEntity> zonas) {
    final actual = _zonaNombre?.trim() ?? '';
    if (zonas.any((z) => z.nombre == actual)) return actual;
    return zonas.isEmpty ? null : zonas.first.nombre;
  }

  ZonaEntity? _zonaSeleccionada() {
    final zonas = ref.read(mesasProvider).zonas;
    if (zonas.isEmpty) return null;
    final actual = _zonaNombre?.trim() ?? '';
    for (final zona in zonas) {
      if (zona.nombre == actual) return zona;
    }
    return zonas.first;
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    final notifier = ref.read(mesasProvider.notifier);

    bool ok;
    if (_esEdicion) {
      final mesa = widget.mesa!
        ..nombre = _nombreCtrl.text.trim()
        ..capacidad = int.parse(_capacidadCtrl.text.trim())
        ..estado = _estado;
      final zona = _zonaSeleccionada();
      if (zona != null) {
        mesa
          ..zonaNombre = zona.nombre
          ..zonaSupabaseId = zona.supabaseId;
      }
      ok = await notifier.actualizarMesa(mesa);
    } else {
      final id = await notifier.crearMesa(
        nombre: _nombreCtrl.text.trim(),
        zonaNombre: _zonaSeleccionada()?.nombre,
        capacidad: int.parse(_capacidadCtrl.text.trim()),
        estado: _estado,
      );
      ok = id != null;
    }

    if (!mounted) return;

    // El provider guarda el motivo en state.error.
    final error = ref.read(mesasProvider).error;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'No se pudo guardar la mesa.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final zonas = ref.watch(mesasProvider).zonas;

    return GlassDialog(
      maxWidth: 440,
      accentColor: MesaCard.colorDeEstado(_estado),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ──
              Text(
                _esEdicion ? 'Editar mesa' : 'Nueva mesa',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // ── Nombre ──
              TextFormField(
                controller: _nombreCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Mesa 1',
                  prefixIcon: Icon(Icons.table_restaurant_rounded),
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Escribe un nombre.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Zona (R.1b: zonas editables del local) ──
              if (zonas.isEmpty)
                Text(
                  'Este local no tiene zonas todavía.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _nombreZonaEfectivo(zonas),
                  decoration: const InputDecoration(
                    labelText: 'Zona',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  items: zonas
                      .map(
                        (z) => DropdownMenuItem<String>(
                          value: z.nombre,
                          child: Text(z.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (z) => setState(() => _zonaNombre = z),
                ),
              const SizedBox(height: 16),

              // ── Capacidad ──
              TextFormField(
                controller: _capacidadCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(
                  labelText: 'Capacidad',
                  hintText: '4',
                  suffixText: 'pax',
                  prefixIcon: Icon(Icons.people_alt_outlined),
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Escribe un número.';
                  if (n < 1 || n > 50) return 'Debe estar entre 1 y 50.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Estado ──
              DropdownButtonFormField<MesaEstado>(
                initialValue: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.circle),
                ),
                items: MesaEstado.values
                    .map(
                      (e) => DropdownMenuItem<MesaEstado>(
                        value: e,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: MesaCard.colorDeEstado(e),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(MesasNotifier.etiquetaEstado(e)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (e) =>
                    setState(() => _estado = e ?? MesaEstado.libre),
              ),
              const SizedBox(height: 8),

              // ── Aviso si la mesa está unida ──
              if (_esEdicion && (widget.mesa?.estaUnida ?? false)) ...[
                GlassCard(
                  nestedGlass: true,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(Icons.link_rounded,
                          size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta mesa está unida a otra. Desúnela antes de '
                          'cambiar su capacidad.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Acciones ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _guardar,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_esEdicion ? 'Guardar' : 'Crear mesa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}