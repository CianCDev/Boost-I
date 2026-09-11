// lib/features/pos/presentation/widgets/inventory/categorias_management_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/categorias_provider.dart';
import '../../providers/productos_provider.dart';
import '../../../data/Local/entities/isar_service.dart';
import 'categoria_form_dialog.dart';

class CategoriasManagementDialog extends ConsumerStatefulWidget {
  const CategoriasManagementDialog({super.key});

  @override
  ConsumerState<CategoriasManagementDialog> createState() => _CategoriasManagementDialogState();
}

class _CategoriasManagementDialogState extends ConsumerState<CategoriasManagementDialog> {
  final TextEditingController _newCategoryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _migrando = false;

  @override
  void dispose() {
    _newCategoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _migrarCategorias() async {
    if (_migrando) return;
    setState(() => _migrando = true);

    try {
      final isar = IsarService();
      final productos = await isar.obtenerProductos();
      final categorias = await isar.obtenerCategorias(soloActivas: false);
      final Map<String, int> mapaCategorias = {};
      for (var cat in categorias) {
        mapaCategorias[cat.nombre] = cat.id;
      }

      int actualizados = 0;
      int sinCategoria = 0;

      for (var p in productos) {
        if (p.categoriaId == null) {
          final nombreCat = p.categoria.trim();
          final idCat = mapaCategorias[nombreCat];
          if (idCat != null) {
            p.categoriaId = idCat;
            await isar.guardarProducto(p);
            actualizados++;
          } else {
            sinCategoria++;
          }
        }
      }

      // ✅ Solo imprimir en consola, sin SnackBar
      debugPrint('✅ Migración completada: $actualizados productos actualizados, $sinCategoria sin categoría asociada');

      if (mounted) {
        await ref.read(categoriasNotifierProvider.notifier).refrescar();
        await ref.read(productosProvider.notifier).cargarProductos();
      }
    } catch (e) {
      debugPrint('❌ Error al migrar: $e');
    } finally {
      if (mounted) setState(() => _migrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasNotifierProvider);
    final notifier = ref.read(categoriasNotifierProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colorScheme.surface,
      title: Row(
        children: [
          Icon(Icons.category_rounded, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Gestionar categorías',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Nueva categoría...',
                      prefixIcon: Icon(Icons.add_rounded, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        notifier.agregarCategoria(value.trim());
                        _newCategoryController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: colorScheme.primary),
                  onPressed: () {
                    final value = _newCategoryController.text.trim();
                    if (value.isNotEmpty) {
                      notifier.agregarCategoria(value);
                      _newCategoryController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _migrando ? null : _migrarCategorias,
              icon: _migrando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.autorenew_rounded),
              label: Text(_migrando ? 'Migrando...' : 'Migrar categorías existentes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: categorias.isEmpty
                  ? Center(
                      child: Text(
                        'No hay categorías',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categorias.length,
                      itemBuilder: (context, index) {
                        final categoria = categorias[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(Icons.category_outlined, color: colorScheme.primary),
                            title: Text(categoria.nombre),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_rounded, color: colorScheme.primary),
                                  onPressed: () async {
                                    final nuevoNombre = await showDialog<String>(
                                      context: context,
                                      builder: (context) => CategoriaFormDialog(
                                        categoriaExistente: categoria.nombre,
                                      ),
                                    );
                                    if (nuevoNombre != null && nuevoNombre.isNotEmpty) {
                                      notifier.editarCategoria(categoria.id, nuevoNombre);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_rounded, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar categoría'),
                                        content: Text('¿Eliminar "${categoria.nombre}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              notifier.eliminarCategoria(categoria.id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}