import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/proveedores/crear_proveedor_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/proveedores/detalle_proveedor_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/proveedor_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final isar = ref.read(isarServiceProvider);
    final productos = await isar.obtenerProductos();
    setState(() => _productos = productos);
  }

  Future<void> _eliminarProveedor(ProveedorEntity proveedor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text('¿Estás seguro de eliminar a "${proveedor.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Proveedor eliminado correctamente'), backgroundColor: Color(0xFF10B981)),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ No se pudo eliminar: tiene productos asociados'), backgroundColor: Colors.orange),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red));
        }
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme; // ✅

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow, // ✅
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFiltroCategorias(),
          _buildFiltroProductos(),
          Expanded(
            child: proveedoresAsync.when(
              data: (proveedores) => _buildListaProveedores(proveedores),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
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
        IconButton(
          onPressed: () => ref.invalidate(proveedoresConFiltroProvider((
            query: _queryBusqueda,
            mostrarInactivos: _mostrarInactivos,
            productoId: _productoFiltroId,
          ))),
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
          fillColor: colorScheme.surface, // ✅
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (value) => setState(() => _queryBusqueda = value),
      ),
    );
  }

  Widget _buildFiltroCategorias() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
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
          foregroundColor: colorScheme.onSurfaceVariant, // ✅
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFiltroProductos() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonFormField<int?>(
        value: _productoFiltroId,
        hint: Text('Filtrar por producto', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.inventory_2_rounded, size: 20, color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surface, // ✅
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
    );
  }

  Widget _buildListaProveedores(List<ProveedorEntity> proveedores) {
    final colorScheme = Theme.of(context).colorScheme;
    if (proveedores.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(proveedoresConFiltroProvider((query: _queryBusqueda, mostrarInactivos: _mostrarInactivos, productoId: _productoFiltroId)));
        return Future.value();
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Text('No hay proveedores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text('Crea tu primer proveedor', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () => _navegarACrear(),
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }

  void _navegarACrear() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearProveedorScreen())).then((_) {
      ref.invalidate(proveedoresConFiltroProvider((query: _queryBusqueda, mostrarInactivos: _mostrarInactivos, productoId: _productoFiltroId)));
      setState(() {});
    });
  }

  void _navegarAEditar(ProveedorEntity proveedor) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CrearProveedorScreen(proveedor: proveedor))).then((_) {
      ref.invalidate(proveedoresConFiltroProvider((query: _queryBusqueda, mostrarInactivos: _mostrarInactivos, productoId: _productoFiltroId)));
      setState(() {});
    });
  }

  void _navegarADetalle(ProveedorEntity proveedor) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleProveedorScreen(proveedor: proveedor))).then((_) {
      ref.invalidate(proveedoresConFiltroProvider((query: _queryBusqueda, mostrarInactivos: _mostrarInactivos, productoId: _productoFiltroId)));
      setState(() {});
    });
  }

  Future<void> _toggleActivo(ProveedorEntity proveedor) async {
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
          ..sincronizado = proveedor.sincronizado
          ..fechaSincronizacion = proveedor.fechaSincronizacion;
        await ref.read(guardarProveedorProvider(actualizado).future);
      }
      ref.invalidate(proveedoresConFiltroProvider((query: _queryBusqueda, mostrarInactivos: _mostrarInactivos, productoId: _productoFiltroId)));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}