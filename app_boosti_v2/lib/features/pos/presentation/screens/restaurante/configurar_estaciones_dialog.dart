// lib/features/pos/presentation/screens/restaurante/configurar_estaciones_dialog.dart
//
// R.3.2 PASO E.3 · Onboarding de estaciones de cocina.
//
// ⚠️ POR QUÉ UN DIÁLOGO NUEVO Y NO `mostrarDialogoCrearEstacion`
//
// `DepartamentoSelector.mostrarDialogoCrearEstacion` (paso D) resuelve un
// problema DISTINTO: dar de alta una estación a mano, con nombre libre, una
// cada vez. Este resuelve el arranque en frío: un local que acaba de
// instalarse no tiene ninguna, y sin ninguna el KDS muestra su columna
// "Sin estación" con todos los platos amontonados.
//
// Reutilizarlo habría significado meterle 3 checkboxes a un diálogo que hoy
// es un `TextField`, y romper su contrato de "una sola estación con el
// nombre que escriba el usuario". Se comparte lo de abajo, que es lo que
// de verdad importa:
//
//   · `construirEstacionesIniciales` → las entidades con su `orden`.
//   · `sembrarEstaciones` → la escritura, que va contra
//     `guardarDepartamentoProvider` (el mismo que valida duplicados).
//
// ⚠️ `sembrarEstaciones` recibe `escribir` como parámetro con valor `null`
// por defecto. No es una abstracción gratuita: sin él, probar que
// "3 marcadas crean 3 departamentos" exigiría Isar real dentro de un
// `testWidgets`, y eso se cuelga (ver la nota de `kds_pantalla_test.dart`).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/departamento_entity.dart';
import '../../providers/departamentos_provider.dart';

/// Stations suggested on a cold start, in display order.
///
/// The `orden` of each one is its position in THIS list, so the kitchen
/// always reads Cocina, Barra, Postres in that order regardless of the
/// order Isar returns them in (see `DepartamentoEntity.orden`).
const kEstacionesIniciales = <String>['Cocina', 'Barra', 'Postres'];

/// Builds the entities for [names], in order.
List<DepartamentoEntity> construirEstacionesIniciales(
  List<String> nombres, {
  required int localId,
}) {
  return [
    for (var i = 0; i < nombres.length; i++)
      DepartamentoEntity()
        ..nombre = nombres[i]
        ..localId = localId
        ..orden = i
        ..activo = true,
  ];
}

/// Outcome of [sembrarEstaciones].
class ResultadoSiembra {
  /// How many were written without error.
  final int creadas;

  /// Names that failed, with the reason already stripped of the
  /// `Exception: ` prefix that `guardarDepartamentoProvider` adds.
  final List<String> fallos;

  const ResultadoSiembra({
    required this.creadas,
    this.fallos = const [],
  });

  bool get completo => fallos.isEmpty;
}

/// Writes the [names] stations into [localId].
///
/// Returns how many landed. It does NOT abort on the first failure: a
/// duplicate `Cocina` should not prevent `Barra` from being created.
Future<ResultadoSiembra> sembrarEstaciones(
  WidgetRef ref, {
  required int localId,
  required List<String> nombres,
  Future<void> Function(DepartamentoEntity)? escribir,
}) async {
  final entidades = construirEstacionesIniciales(
    nombres,
    localId: localId,
  );

  var creadas = 0;
  final fallos = <String>[];

  for (final entidad in entidades) {
    try {
      if (escribir != null) {
        await escribir(entidad);
      } else {
        await ref.read(guardarDepartamentoProvider(entidad).future);
      }
      creadas++;
    } on Exception catch (e) {
      // `guardarDepartamentoProvider` lanza `Exception('Ya existe...')`.
      // Se quita el prefijo que mete `Exception.toString()`.
      final motivo = e.toString().replaceFirst('Exception: ', '');
      fallos.add('${entidad.nombre}: $motivo');
    }
  }

  // Even if everything failed, invalidate: `guardarDepartamentoProvider`
  // already does it per save, but the injected `escribir` in tests does
  // not, and a stale list would leave the KDS showing the empty state.
  ref.invalidate(departamentosActivosProvider(localId));

  return ResultadoSiembra(creadas: creadas, fallos: fallos);
}

// ══════════════════════════════════════════════════════════════════
// DIÁLOGO
// ══════════════════════════════════════════════════════════════════

/// Returns the selected station names, or `null` if cancelled.
///
/// ⚠️ An EMPTY list is NOT the same as `null`: it means "accepted, but I
/// unchecked everything", which must close the dialog without creating
/// anything. Collapsing both would leave the dialog open (or make the
/// caller treat a cancel as a success).
class ConfigurarEstacionesDialog extends StatefulWidget {
  static Future<List<String>?> mostrar(
    BuildContext context, {
    List<String> nombres = kEstacionesIniciales,
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (_) => ConfigurarEstacionesDialog(nombres: nombres),
    );
  }

  final List<String> nombres;

  const ConfigurarEstacionesDialog({
    super.key,
    this.nombres = kEstacionesIniciales,
  });

  @override
  State<ConfigurarEstacionesDialog> createState() =>
      _ConfigurarEstacionesDialogState();
}

class _ConfigurarEstacionesDialogState
    extends State<ConfigurarEstacionesDialog> {
  /// ⚠️ Empieza con TODO marcado. Un local nuevo quiere las tres; tener
  /// que marcar tres casillas para desbloquear el botón es el tipo de
  /// fricción que hace que el usuario busque la pantalla de Departamentos.
  late final Set<String> _elegidas = {...widget.nombres};

  void _alternar(String nombre, bool valor) {
    setState(() {
      if (valor) {
        _elegidas.add(nombre);
      } else {
        _elegidas.remove(nombre);
      }
    });
  }

  /// Devuelve en el ORDEN DE `widget.nombres`, no en el de un `Set`, que
  /// en Dart preserva inserción y no garantiza nada al filtrar.
  List<String> _seleccionOrdenada() {
    return widget.nombres.where(_elegidas.contains).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Configurar estaciones de cocina'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona las áreas de preparación de este local',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final nombre in widget.nombres)
            CheckboxListTile(
              key: ValueKey('estacion-$nombre'),
              value: _elegidas.contains(nombre),
              onChanged: (v) => _alternar(nombre, v ?? false),
              title: Text(nombre),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          const SizedBox(height: 8),
          Text(
            'Podrás cambiarlas luego desde Departamentos.',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_seleccionOrdenada()),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
