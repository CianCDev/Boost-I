// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/proveedores/crear_proveedor_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/proveedores/detalle_proveedor_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/proveedor_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';

class ProveedoresScreen extends ConsumerStatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  ConsumerState<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends ConsumerState<ProveedoresScreen> {
  String _queryBusqueda = '';
  bool _mostrarInactivos = false;
  int? _productoFiltroId;
  List<ProductoEntity> _productos = [];
  bool _isSyncing = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    final isar = ref.read(isarServiceProvider);
    final productos = await isar.obtenerProductos();
    if (mounted) {
      setState(() => _productos = productos);
    }
  }

  // 🔥 Método centralizado con manejo seguro de context

  // 🔥 Sincronización normal (con snackbar seguro)
  Future<void> _sincronizarProveedores() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final sync = SyncService();
      await sync.sincronizarProveedoresPendientes();
      await sync.descargarProveedoresDesdeSupabase();

      ref.invalidate(proveedoresConFiltroProvider((
        query: _queryBusqueda,
        mostrarInactivos: _mostrarInactivos,
        productoId: _productoFiltroId,
      )));
      await _cargarProductos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Proveedores sincronizados correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al sincronizar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      debugPrint('❌ Error en sincronización de proveedores: $e');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  // 🔥 MÉTODO QUE GENERABA EL ERROR - Corregido
 Future<void> _sincronizarProveedoresForzada() async {
  if (_isSyncing) return;
  setState(() => _isSyncing = true);

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final currentContext = context;

  try {
    debugPrint('🔥 Iniciando sincronización forzada de proveedores...');
    
    // ✅ 1. Obtener proveedores pendientes desde IsarService (usando el provider)
    final isarService = ref.read(isarServiceProvider);
    final pendientes = await isarService.obtenerProveedoresPendientesSync();
    final cantidadPendientes = pendientes.length;
    
    final sync = SyncService();

    // 2. Subir proveedores pendientes
    await sync.sincronizarProveedoresPendientes();
    debugPrint('⬆️ $cantidadPendientes proveedores subidos a Supabase');

    // 3. Descargar proveedores desde Supabase
    await sync.descargarProveedoresDesdeSupabase();
    debugPrint('📥 Proveedores descargados desde Supabase');

    // 4. Refrescar UI
    ref.invalidate(proveedoresConFiltroProvider((
      query: _queryBusqueda,
      mostrarInactivos: _mostrarInactivos,
      productoId: _productoFiltroId,
    )));
    await _cargarProductos();

    if (!currentContext.mounted) return;
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('✅ Sincronización forzada completada: $cantidadPendientes subidos'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  } catch (e) {
    if (!currentContext.mounted) return;
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('❌ Error en sincronización forzada: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    debugPrint('❌ Error en sincronización forzada: $e');
  } finally {
    if (mounted) {
      setState(() => _isSyncing = false);
    }
  }
}

  Future<void> _eliminarProveedor(ProveedorEntity proveedor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text('¿Estás seguro de eliminar a "${proveedor.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final currentContext = context;

      try {
        final isar = ref.read(isarServiceProvider);
        final syncService = SyncService();

        final exitoLocal = await isar.eliminarProveedor(proveedor.id);
        if (exitoLocal) {
          if (proveedor.supabaseId != null && proveedor.supabaseId!.isNotEmpty) {
            await syncService.eliminarProveedorEnSupabase(proveedor.supabaseId!);
          }
          ref.invalidate(proveedoresConFiltroProvider((
            query: _queryBusqueda,
            mostrarInactivos: _mostrarInactivos,
            productoId: _productoFiltroId,
          )));

          if (!currentContext.mounted) return;
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('✅ Proveedor eliminado correctamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        } else {
          if (!currentContext.mounted) return;
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo eliminar: tiene productos asociados'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (!currentContext.mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedoresAsync = ref.watch(proveedoresConFiltroProvider((
      query: _queryBusqueda,
      mostrarInactivos: _mostrarInactivos,
      productoId: _productoFiltroId,
    )));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFiltros(colorScheme),
          Expanded(
            child: proveedoresAsync.when(
              data: (proveedores) => _buildListaProveedores(proveedores),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 60, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error al cargar proveedores', style: TextStyle(color: colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text(err.toString(), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(proveedoresConFiltroProvider((
                        query: _queryBusqueda,
                        mostrarInactivos: _mostrarInactivos,
                        productoId: _productoFiltroId,
                      ))),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Proveedores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      foregroundColor: Colors.white,
      actions: [
        // Botón de sincronización forzada
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, color: Colors.white),
              onPressed: _isSyncing ? null : _sincronizarProveedoresForzada,
              tooltip: 'Sincronización forzada (sube todos los proveedores)',
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            ref.invalidate(proveedoresConFiltroProvider((
              query: _queryBusqueda,
              mostrarInactivos: _mostrarInactivos,
              productoId: _productoFiltroId,
            )));
            _cargarProductos();
          },
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Recargar lista',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o empresa...',
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (value) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            setState(() => _queryBusqueda = value);
          });
        },
      ),
    );
  }

  Widget _buildFiltros(ColorScheme colorScheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'activos', label: Text('Activos'), icon: Icon(Icons.check_circle_rounded)),
              ButtonSegment(value: 'inactivos', label: Text('Inactivos'), icon: Icon(Icons.cancel_rounded)),
            ],
            selected: {_mostrarInactivos ? 'inactivos' : 'activos'},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _mostrarInactivos = newSelection.first == 'inactivos');
              ref.invalidate(proveedoresConFiltroProvider((
                query: _queryBusqueda,
                mostrarInactivos: _mostrarInactivos,
                productoId: _productoFiltroId,
              )));
            },
            style: SegmentedButton.styleFrom(
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: colorScheme.onSurfaceVariant,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonFormField<int?>(
            initialValue: _productoFiltroId,
            hint: Text('Filtrar por producto', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.inventory_2_rounded, size: 20, color: colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text('Todos los productos', style: TextStyle(color: colorScheme.onSurface))),
              ..._productos.map((p) => DropdownMenuItem<int?>(value: p.id, child: Text(p.nombre, style: TextStyle(color: colorScheme.onSurface)))),
            ],
            onChanged: (value) {
              setState(() => _productoFiltroId = value);
              ref.invalidate(proveedoresConFiltroProvider((
                query: _queryBusqueda,
                mostrarInactivos: _mostrarInactivos,
                productoId: _productoFiltroId,
              )));
            },
            icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildListaProveedores(List<ProveedorEntity> proveedores) {
    if (proveedores.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(proveedoresConFiltroProvider((
          query: _queryBusqueda,
          mostrarInactivos: _mostrarInactivos,
          productoId: _productoFiltroId,
        )));
        await _cargarProductos();
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 88),
          itemCount: proveedores.length,
          itemBuilder: (context, index) {
            final proveedor = proveedores[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  curve: Curves.easeOutCubic,
                  child: ProveedorCard(
                    proveedor: proveedor,
                    onTap: () => _navegarADetalle(proveedor),
                    onEdit: () => _navegarAEditar(proveedor),
                    onToggleActivo: () => _toggleActivo(proveedor),
                    onDelete: () => _eliminarProveedor(proveedor),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center_rounded, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No hay proveedores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer proveedor',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navegarACrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear proveedor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: _navegarACrear,
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }

  void _navegarACrear() {
    showDialog(
      context: context,
      builder: (_) => const CrearProveedorDialog(),
    ).then((_) {
      if (mounted) {
        ref.invalidate(proveedoresConFiltroProvider((
          query: _queryBusqueda,
          mostrarInactivos: _mostrarInactivos,
          productoId: _productoFiltroId,
        )));
        _cargarProductos();
        setState(() {});
      }
    });
  }

  void _navegarAEditar(ProveedorEntity proveedor) {
    showDialog(
      context: context,
      builder: (_) => CrearProveedorDialog(proveedor: proveedor),
    ).then((_) {
      if (mounted) {
        ref.invalidate(proveedoresConFiltroProvider((
          query: _queryBusqueda,
          mostrarInactivos: _mostrarInactivos,
          productoId: _productoFiltroId,
        )));
        _cargarProductos();
        setState(() {});
      }
    });
  }

  void _navegarADetalle(ProveedorEntity proveedor) {
    showDialog(
      context: context,
      builder: (_) => DetalleProveedorDialog(proveedor: proveedor),
    ).then((_) {
      if (mounted) {
        ref.invalidate(proveedoresConFiltroProvider((
          query: _queryBusqueda,
          mostrarInactivos: _mostrarInactivos,
          productoId: _productoFiltroId,
        )));
        setState(() {});
      }
    });
  }

  Future<void> _toggleActivo(ProveedorEntity proveedor) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentContext = context;

    try {
      if (proveedor.activo) {
        await ref.read(desactivarProveedorProvider(proveedor.id).future);
      } else {
        final actualizado = ProveedorEntity()
          ..id = proveedor.id
          ..nombre = proveedor.nombre
          ..cedula = proveedor.cedula
          ..telefono = proveedor.telefono
          ..empresa = proveedor.empresa
          ..direccion = proveedor.direccion
          ..activo = true
          ..supabaseId = proveedor.supabaseId
          ..sincronizado = false
          ..fechaSincronizacion = proveedor.fechaSincronizacion
          ..email = proveedor.email;
        await ref.read(guardarProveedorProvider(actualizado).future);
        await _sincronizarProveedores();
      }

      if (mounted) {
        ref.invalidate(proveedoresConFiltroProvider((
          query: _queryBusqueda,
          mostrarInactivos: _mostrarInactivos,
          productoId: _productoFiltroId,
        )));
        setState(() {});
      }
    } catch (e) {
      if (!currentContext.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}