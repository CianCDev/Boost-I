import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart';

class SeleccionarDepartamentoDialog extends ConsumerStatefulWidget {
  final int? localId;

  const SeleccionarDepartamentoDialog({super.key, this.localId});

  @override
  ConsumerState<SeleccionarDepartamentoDialog> createState() => _SeleccionarDepartamentoDialogState();
}

class _SeleccionarDepartamentoDialogState extends ConsumerState<SeleccionarDepartamentoDialog> {
  @override
  Widget build(BuildContext context) {
    final departamentosAsync = ref.watch(todosDepartamentosProvider); // Necesitamos un provider que devuelva todos los departamentos
    // Si no existe, podemos usar departamentosProvider sin filtro

    return AlertDialog(
      title: const Text('Agregar Departamento'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: departamentosAsync.when(
          data: (departamentos) {
            // Filtrar los que no estén ya asociados a este local
            final disponibles = departamentos.where((d) => d.localId != widget.localId).toList();
            if (disponibles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No hay departamentos disponibles para agregar.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _crearNuevoDepartamento(),
                      child: const Text('Crear nuevo departamento'),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: disponibles.length,
                    itemBuilder: (context, index) {
                      final d = disponibles[index];
                      return ListTile(
                        title: Text(d.nombre),
                        subtitle: d.descripcion != null ? Text(d.descripcion!) : null,
                        onTap: () {
                          // Asociar este departamento al local
                          d.localId = widget.localId;
                          ref.read(guardarDepartamentoProvider(d).future).then((_) {
                            Navigator.pop(context, d);
                          });
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                TextButton.icon(
                  onPressed: _crearNuevoDepartamento,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Crear nuevo departamento'),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Future<void> _crearNuevoDepartamento() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CrearDepartamentoDialog(
        localIdPreseleccionado: widget.localId,
      ),
    );
    if (result == true) {
      ref.invalidate(todosDepartamentosProvider);
      setState(() {});
    }
  }
}