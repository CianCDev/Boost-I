// lib/features/pos/presentation/widgets/common/departamento_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/departamento_entity.dart';
import '../../providers/departamentos_provider.dart';
import '../../providers/local_actual_provider.dart';
import 'glass_dialog.dart';

/// Selector de estación de preparación (departamento) del KDS.
///
/// Se crea en R.3.2 PASO B, antes que la pantalla que lo va a usar, porque
/// `ProductoEntity.departamentoId` no tenía ninguna forma de asignarse y
/// sin esto el KDS nacía con todos los platos en "Sin estación".
///
/// Consumidor previsto:
///   · PASO D → formulario de producto (asignar `departamentoId`).
///   · PASO E → filtro por estación de la cola.
///
/// A diferencia del resto de componentes de `common/`, este SÍ es un
/// `ConsumerWidget`: tiene que leer `localActualProvider` y los
/// departamentos. Los demás son presentacionales puros.
class DepartamentoSelector extends ConsumerWidget {
  final int? value;
  final ValueChanged<int?>? onChanged;
  final bool includeSinEstacion;
  final String label;

  /// Abre el diálogo de crear estaciones cuando el local no tiene ninguna.
  ///
  /// Si es `null` y no hay departamentos, solo se muestra el aviso.
  /// PASO E inyecta aquí su seed de "Cocina / Barra / Postres".
  final VoidCallback? onConfigurar;

  const DepartamentoSelector({
    super.key,
    this.value,
    this.onChanged,
    this.includeSinEstacion = true,
    this.label = 'Estación de preparación',
    this.onConfigurar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localId = ref.watch(localActualProvider);

    if (localId == null) {
      return _aviso(
        context,
        Icons.storefront_rounded,
        'Selecciona un local para ver sus estaciones',
      );
    }

    final departamentosAsync = ref.watch(
      departamentosActivosProvider(localId),
    );

    return departamentosAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, stack) => _aviso(
        context,
        Icons.error_outline_rounded,
        'No se pudieron cargar las estaciones',
      ),
      data: (departamentos) {
        if (departamentos.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _aviso(
                context,
                Icons.kitchen_rounded,
                'Este local no tiene estaciones de cocina',
              ),
              if (onConfigurar != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onConfigurar,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Configurar estaciones'),
                ),
              ],
            ],
          );
        }

        // Orden explícito por `orden` (R.3.2): el que quiera ver Cocina,
        // Barra y Postres en ese orden, no en orden de inserción.
        final ordenados = [...departamentos]
          ..sort((a, b) {
            final cmp = a.orden.compareTo(b.orden);
            return cmp != 0 ? cmp : a.nombre.compareTo(b.nombre);
          });

        final items = <DropdownMenuItem<int?>>[
          if (includeSinEstacion)
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Sin estación (venta directa)'),
            ),
          ...ordenados.map(
            (d) => DropdownMenuItem<int?>(
              value: d.id,
              child: Text(d.nombre, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];

        // Si el `value` recibido ya no existe (departamento borrado o de
        // otro local tras un hot-switch), se cae a null en vez de dejar el
        // dropdown con un valor fantasma que no aparece en la lista.
        final seleccionado = items.any((i) => i.value == value) ? value : null;

        return DropdownButtonFormField<int?>(
          initialValue: seleccionado,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            helperText: 'Determina a qué estación va el plato en el KDS',
            prefixIcon: const Icon(Icons.kitchen_rounded, size: 20),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget _aviso(BuildContext context, IconData icon, String texto) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Diálogo de creación rápida de UNA estación de cocina.
///
/// R.3.2 deja el seed de "Cocina / Barra / Postres" para PASO E. Aquí solo
/// se crea la estación que escriba el usuario, lo justo para desbloquear la
/// prueba manual del KDS.
///
/// Delega la escritura en `guardarDepartamentoProvider`, que ya valida
/// duplicados (ignorando mayúsculas) e invalida los providers de
/// departamentos. Escribir por `IsarService` directo saltaría esa
/// validación y el dropdown llegaría a mostrar dos "Cocina".
Future<void> mostrarDialogoCrearEstacion(
  BuildContext context, {
  required WidgetRef ref,
  required int localId,
}) async {
  final controller = TextEditingController();
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  try {
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) => _DialogoCrearEstacion(controller: controller),
    );

    if (nombre == null || nombre.isEmpty) return;

    // `orden` = cuántas estaciones hay ya, para que la nueva quede al
    // final en vez de empatar en 0 con todas las demás.
    final existentes = await ref
        .read(departamentosActivosProvider(localId).future);

    try {
      // `DepartamentoEntity()` es un constructor SIN parámetros nombrados
      // (a diferencia de `ProductoEntity`, que sí los tiene): los campos
      // se asignan en cascada.
      final nueva = DepartamentoEntity()
        ..nombre = nombre
        ..localId = localId
        ..activo = true
        ..orden = existentes.length;

      await ref.read(guardarDepartamentoProvider(nueva).future);

      messenger.showSnackBar(
        SnackBar(content: Text('Estación "$nombre" creada')),
      );
    } on Exception catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  } finally {
    controller.dispose();
    if (navigator.mounted) navigator.pop();
  }
}

class _DialogoCrearEstacion extends StatelessWidget {
  final TextEditingController controller;

  const _DialogoCrearEstacion({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 420,
      accentColor: const Color(0xFFF59E0B),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.kitchen_rounded, color: Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nueva estación',
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
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Cocina, Barra, Postres...',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) Navigator.of(context).pop(v.trim());
              },
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
                  onPressed: () {
                    final v = controller.text.trim();
                    if (v.isNotEmpty) Navigator.of(context).pop(v);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Crear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
