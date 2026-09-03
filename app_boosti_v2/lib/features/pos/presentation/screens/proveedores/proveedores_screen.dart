// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/proveedores/crear_proveedor_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/proveedores/detalle_proveedor_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/proveedores/proveedor_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';

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

  // ==================== SINCRONIZACIÓN ====================
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

  Future<void> _sincronizarProveedoresForzada() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentContext = context;

    try {
      debugPrint('🔥 Iniciando sincronización forzada de proveedores...');
      final isarService = ref.read(isarServiceProvider);
      final pendientes = await isarService.obtenerProveedoresPendientesSync();
      final cantidadPendientes = pendientes.length;

      final sync = SyncService();
      await sync.sincronizarProveedoresPendientes();
      debugPrint('⬆️ $cantidadPendientes proveedores subidos a Supabase');

      await sync.descargarProveedoresDesdeSupabase();
      debugPrint('📥 Proveedores descargados desde Supabase');

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

  // ==================== ELIMINACIÓN PROFESIONAL ====================
  Future<void> _eliminarProveedor(ProveedorEntity proveedor) async {
    final isar = ref.read(isarServiceProvider);
    final productosAsociados = await isar.obtenerProductosPorProveedor(proveedor.id);

    if (productosAsociados.isEmpty) {
      await _confirmarYEliminar(proveedor);
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Proveedor con Productos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El proveedor "${proveedor.nombre}" tiene ${productosAsociados.length} producto(s) asociado(s).',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Qué deseas hacer con los productos?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Desvincular: los productos quedarán sin proveedor.',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              '• Reasignar: mover los productos a otro proveedor.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'unlink'),
            child: const Text('Desvincular productos'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'reassign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reasignar a otro'),
          ),
        ],
      ),
    );

    if (action == 'cancel') return;

    if (action == 'unlink') {
      await _desvincularYEliminar(proveedor, productosAsociados);
    } else if (action == 'reassign') {
      await _reasignarYEliminar(proveedor, productosAsociados);
    }
  }

  Future<void> _confirmarYEliminar(ProveedorEntity proveedor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      await _ejecutarEliminacion(proveedor);
    }
  }

  Future<void> _desvincularYEliminar(ProveedorEntity proveedor, List<ProductoEntity> productos) async {
    final isar = ref.read(isarServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      for (var producto in productos) {
        producto.proveedorId = null;
        await isar.guardarProducto(producto);
      }

      final exito = await isar.eliminarProveedor(proveedor.id);
      if (exito) {
        if (proveedor.supabaseId != null && proveedor.supabaseId!.isNotEmpty) {
          await SyncService().eliminarProveedorEnSupabase(proveedor.supabaseId!);
        }
        ref.invalidate(proveedoresConFiltroProvider((
          query: _queryBusqueda,
          mostrarInactivos: _mostrarInactivos,
          productoId: _productoFiltroId,
        )));
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('✅ Proveedor eliminado. Productos desvinculados.'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('❌ Error al eliminar el proveedor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reasignarYEliminar(ProveedorEntity proveedor, List<ProductoEntity> productos) async {
    final isar = ref.read(isarServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final otrosProveedores = await isar.obtenerProveedores(soloActivos: true);
    otrosProveedores.removeWhere((p) => p.id == proveedor.id);

    if (otrosProveedores.isEmpty) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No hay otros proveedores activos para reasignar.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final proveedorDestino = await showDialog<ProveedorEntity>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seleccionar proveedor destino'),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: ListView.builder(
            itemCount: otrosProveedores.length,
            itemBuilder: (context, index) {
              final p = otrosProveedores[index];
              return ListTile(
                title: Text(p.nombre),
                subtitle: Text(p.empresa ?? ''),
                leading: const Icon(Icons.business_center_rounded),
                onTap: () => Navigator.pop(context, p),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (proveedorDestino == null) return;

    try {
      for (var producto in productos) {
        producto.proveedorId = proveedorDestino.id;
        await isar.guardarProducto(producto);
      }

      final exito = await isar.eliminarProveedor(proveedor.id);
      if (exito) {
        if (proveedor.supabaseId != null && proveedor.supabaseId!.isNotEmpty) {
          await SyncService().eliminarProveedorEnSupabase(proveedor.supabaseId!);
        }
        ref.invalidate(proveedoresConFiltroProvider((
          query: _queryBusqueda,
          mostrarInactivos: _mostrarInactivos,
          productoId: _productoFiltroId,
        )));
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('✅ Productos reasignados a "${proveedorDestino.nombre}" y proveedor eliminado'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('❌ Error al eliminar el proveedor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _ejecutarEliminacion(ProveedorEntity proveedor) async {
    final isar = ref.read(isarServiceProvider);
    final syncService = SyncService();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
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
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('✅ Proveedor eliminado correctamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo eliminar: tiene productos asociados'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==================== BUILD Y UI ====================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    final proveedoresAsync = ref.watch(proveedoresConFiltroProvider((
      query: _queryBusqueda,
      mostrarInactivos: _mostrarInactivos,
      productoId: _productoFiltroId,
    )));

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF0F4F8),
      appBar: CustomAppBar(
        title: isMobile ? 'Proveedores' : 'Gestión de Proveedores',
        showBackButton: true,
        centerTitle: false,
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync_rounded, color: Colors.white),
            onPressed: _isSyncing ? null : _sincronizarProveedoresForzada,
            tooltip: 'Sincronizar',
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
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildSearchBar(colorScheme, isDark),
              const SizedBox(height: 12),
              _buildFiltros(colorScheme, isDark),
              const SizedBox(height: 8),
              Expanded(
                child: proveedoresAsync.when(
                  data: (proveedores) => _buildListaProveedores(proveedores, colorScheme, isDark),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => _buildErrorState(err, colorScheme),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  // ============================================================
  // SEARCH BAR CON GLASSMORPHISM
  // ============================================================
  Widget _buildSearchBar(ColorScheme colorScheme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o empresa...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () {
                setState(() => _queryBusqueda = value);
              });
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTROS CON GLASSMORPHISM
  // ============================================================
  Widget _buildFiltros(ColorScheme colorScheme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'activos',
                    label: Text('Activos'),
                    icon: Icon(Icons.check_circle_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: 'inactivos',
                    label: Text('Inactivos'),
                    icon: Icon(Icons.cancel_rounded, size: 18),
                  ),
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
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide.none,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _productoFiltroId,
                hint: Text(
                  'Filtrar por producto',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                ),
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.inventory_2_rounded,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Todos los productos',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  ..._productos.map((p) => DropdownMenuItem<int?>(
                    value: p.id,
                    child: Text(
                      p.nombre,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _productoFiltroId = value);
                  ref.invalidate(proveedoresConFiltroProvider((
                    query: _queryBusqueda,
                    mostrarInactivos: _mostrarInactivos,
                    productoId: _productoFiltroId,
                  )));
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTA CON CARDS GLASSMORPHISM
  // ============================================================
  Widget _buildListaProveedores(List<ProveedorEntity> proveedores, ColorScheme colorScheme, bool isDark) {
    if (proveedores.isEmpty) return _buildEmptyState(colorScheme, isDark);

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
          padding: const EdgeInsets.only(bottom: 16),
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

  // ============================================================
  // ESTADOS VACÍO Y ERROR
  // ============================================================
  Widget _buildEmptyState(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_rounded,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay proveedores',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer proveedor',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navegarACrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear proveedor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar proveedores',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(proveedoresConFiltroProvider((
                query: _queryBusqueda,
                mostrarInactivos: _mostrarInactivos,
                productoId: _productoFiltroId,
              )));
            },
            child: const Text('Reintentar'),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================
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