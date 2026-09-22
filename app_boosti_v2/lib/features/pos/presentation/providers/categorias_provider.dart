// lib/features/pos/presentation/providers/categorias_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/Local/entities/categoria_entity.dart';
// ignore: unused_import
import '../../data/Local/entities/producto_entity.dart';
import 'isar_provider.dart';
import 'productos_provider.dart';
import 'sync_provider.dart';

// ══════════════════════════════════════════════════════════════
// PROVIDERS DE LECTURA (Vistas)
// ══════════════════════════════════════════════════════════════

final categoriasProvider = FutureProvider.autoDispose<List<CategoriaEntity>>(
  (ref) async {
    final isar = ref.watch(isarServiceProvider);
    return await isar.obtenerCategorias(soloActivas: true);
  },
);

final todasLasCategoriasProvider =
    FutureProvider.autoDispose<List<CategoriaEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerCategorias(soloActivas: false);
});

// ══════════════════════════════════════════════════════════════
// NOTIFIER PRINCIPAL (Controlador)
// ══════════════════════════════════════════════════════════════

final categoriasNotifierProvider =
    StateNotifierProvider<CategoriasNotifier, List<CategoriaEntity>>((ref) {
  return CategoriasNotifier(ref);
});

class CategoriasNotifier extends StateNotifier<List<CategoriaEntity>> {
  final Ref ref;

  CategoriasNotifier(this.ref) : super([]) {
    _cargarCategorias(isInit: true);
  }

  Future<void> _cargarCategorias({bool isInit = false}) async {
    try {
      final isar = ref.read(isarServiceProvider);
      final lista = await isar.obtenerCategorias(soloActivas: true);
      
      if (!mounted) return;
      state = lista;

      // FIX 3: Evitar invalidar providers durante la construcción inicial.
      // Solo se invalidan tras operaciones CRUD posteriores.
      if (!isInit) {
        ref.invalidate(categoriasProvider);
        ref.invalidate(todasLasCategoriasProvider);
      }
    } catch (e) {
      debugPrint('Error al cargar categorías: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // CRUD
  // ══════════════════════════════════════════════════════════════

  Future<void> agregarCategoria(String nombre, {String? descripcion}) async {
    try {
      final isar = ref.read(isarServiceProvider);
      final nueva = CategoriaEntity(
        supabaseId: const Uuid().v4(),
        nombre: nombre.trim(),
        descripcion: descripcion,
        syncStatus: 'pending',
      );
      
      await isar.guardarCategoria(nueva);
      await _cargarCategorias();
      
      // FIX 1: Fire-and-forget. No bloqueamos la UI esperando la red.
      _sincronizarEnSegundoPlano();
    } catch (e) {
      debugPrint('Error al agregar categoría: $e');
    }
  }

  Future<void> editarCategoria(
    int id,
    String nuevoNombre, {
    String? nuevaDescripcion,
  }) async {
    try {
      final isar = ref.read(isarServiceProvider);
      final categoria = await isar.obtenerCategoriaPorId(id);
      if (categoria == null) return;

      final nombreViejo = categoria.nombre;
      categoria.nombre = nuevoNombre.trim();
      if (nuevaDescripcion != null) categoria.descripcion = nuevaDescripcion;
      
      categoria.updatedAt = DateTime.now();
      categoria.syncStatus = 'pending';
      await isar.guardarCategoria(categoria);

      if (nombreViejo != categoria.nombre) {
        await _renombrarCategoriaEnProductos(
          nombreViejo: nombreViejo,
          nombreNuevo: categoria.nombre,
          nuevaCategoriaId: id,
        );
      }

      await _cargarCategorias();
      await ref.read(productosProvider.notifier).cargarProductos();
      
      _sincronizarEnSegundoPlano();
    } catch (e) {
      debugPrint('Error al editar categoría: $e');
    }
  }

  Future<void> eliminarCategoria(int id) async {
    try {
      final isar = ref.read(isarServiceProvider);
      final categoria = await isar.obtenerCategoriaPorId(id);
      if (categoria == null) return;

      // 1. Reasignar productos primero
      await _reasignarProductosSinCategoria(categoria.nombre);

      // 2. Soft delete
      categoria.activo = false;
      categoria.updatedAt = DateTime.now();
      categoria.syncStatus = 'pending';
      await isar.guardarCategoria(categoria);

      // 3. Refrescar estado local
      await _cargarCategorias();
      await ref.read(productosProvider.notifier).cargarProductos();
      
      _sincronizarEnSegundoPlano();
    } catch (e) {
      debugPrint('Error al eliminar categoría: $e');
    }
  }

  Future<void> reactivarCategoria(int id) async {
    try {
      final isar = ref.read(isarServiceProvider);
      final categoria = await isar.obtenerCategoriaPorId(id);
      if (categoria == null) return;

      categoria.activo = true;
      categoria.updatedAt = DateTime.now();
      categoria.syncStatus = 'pending';
      await isar.guardarCategoria(categoria);
      
      await _cargarCategorias();
      _sincronizarEnSegundoPlano();
    } catch (e) {
      debugPrint('Error al reactivar categoría: $e');
    }
  }

  Future<int> purgarCategoriasInactivas() async {
    final isar = ref.read(isarServiceProvider);
    final inactivas = await isar.obtenerCategorias(soloActivas: false);
    final aBorrar = inactivas.where((c) => !c.activo).toList();
    
    if (aBorrar.isEmpty) return 0;

    try {
      // FIX 2: Borrado concurrente (optimización de I/O)
      await Future.wait(
        aBorrar.map((cat) => isar.eliminarCategoriaFisica(cat.id)),
      );
      
      await _cargarCategorias();
      return aBorrar.length;
    } catch (e) {
      debugPrint('Error al purgar categorías: $e');
      return 0;
    }
  }

  Future<void> refrescar() async {
    await _cargarCategorias();
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════

  void _sincronizarEnSegundoPlano() {
    ref.read(syncServiceProvider).sincronizarCategorias().catchError((e) {
      debugPrint('Error de sincronización en 2do plano (Offline mode): $e');
    });
  }

  Future<void> _reasignarProductosSinCategoria(String nombreCategoria) async {
    final isar = ref.read(isarServiceProvider);
    final productos = await isar.obtenerProductos();

    final afectados = productos.where(
      (p) => p.categoria.trim().toLowerCase() == nombreCategoria.trim().toLowerCase(),
    ).toList();

    if (afectados.isEmpty) return;

    final timestamp = DateTime.now();
    for (final p in afectados) {
      p.categoria = 'Sin categoría';
      p.categoriaId = null;
      p.updatedAt = timestamp;
      p.sincronizado = false;
    }

    // FIX 2: Ejecución paralela en lugar de bucle secuencial
    await Future.wait(afectados.map((p) => isar.guardarProducto(p)));

    debugPrint('🔄 ${afectados.length} productos reasignados a "Sin categoría"');
  }

  Future<void> _renombrarCategoriaEnProductos({
    required String nombreViejo,
    required String nombreNuevo,
    required int nuevaCategoriaId,
  }) async {
    final isar = ref.read(isarServiceProvider);
    final productos = await isar.obtenerProductos();

    final afectados = productos.where(
      (p) => p.categoria.trim().toLowerCase() == nombreViejo.trim().toLowerCase(),
    ).toList();

    if (afectados.isEmpty) return;

    final timestamp = DateTime.now();
    for (final p in afectados) {
      p.categoria = nombreNuevo;
      p.categoriaId = nuevaCategoriaId; // FIX 4: Asegurar consistencia del ID
      p.updatedAt = timestamp;
      p.sincronizado = false;
    }

    // FIX 2: Ejecución paralela en lugar de bucle secuencial
    await Future.wait(afectados.map((p) => isar.guardarProducto(p)));

    debugPrint('🔄 ${afectados.length} productos renombrados a "$nombreNuevo"');
  }
}