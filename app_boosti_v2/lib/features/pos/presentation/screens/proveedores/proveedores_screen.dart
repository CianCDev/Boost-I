// lib/features/pos/presentation/screens/proveedores_screen.dart
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
import 'package:app_boosti_v2/features/pos/presentation/widgets/proveedores/proveedor_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_search_bar.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/segmented_toggle.dart';

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

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

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
    if (mounted) setState(() => _productos = productos);
  }

  void _invalidarLista() {
    ref.invalidate(proveedoresConFiltroProvider((
      query: _queryBusqueda,
      mostrarInactivos: _mostrarInactivos,
      productoId: _productoFiltroId,
    )));
  }

  // ============================================================
  // SYNC
  // ============================================================
  Future<void> _sincronizarProveedores() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      final sync = SyncService();
      await sync.sincronizarProveedoresPendientes();
      await sync.descargarProveedoresDesdeSupabase();
      _invalidarLista();
      await _cargarProductos();
      if (mounted) _snack('Proveedores sincronizados', _colorSuccess);
    } catch (e) {
      if (mounted) _snack('Error al sincronizar: $e', _colorDanger);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // ============================================================
  // ELIMINACIÓN
  // ============================================================
  Future<void> _eliminarProveedor(ProveedorEntity proveedor) async {
    final isar = ref.read(isarServiceProvider);
    final productosAsociados =
        await isar.obtenerProductosPorProveedor(proveedor.id);

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
            const Text('• Desvincular: quedarán sin proveedor.',
                style: TextStyle(fontSize: 13)),
            const Text('• Reasignar: mover a otro proveedor.',
                style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'unlink'),
            child: const Text('Desvincular'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'reassign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reasignar'),
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
        content: Text(
            '¿Estás seguro de eliminar a "${proveedor.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorDanger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) await _ejecutarEliminacion(proveedor);
  }

  Future<void> _desvincularYEliminar(
      ProveedorEntity proveedor, List<ProductoEntity> productos) async {
    final isar = ref.read(isarServiceProvider);
    try {
      for (var p in productos) {
        p.proveedorId = null;
        await isar.guardarProducto(p);
      }
      final ok = await isar.eliminarProveedor(proveedor.id);
      if (ok) {
        if (proveedor.supabaseId?.isNotEmpty ?? false) {
          await SyncService()
              .eliminarProveedorEnSupabase(proveedor.supabaseId!);
        }
        _invalidarLista();
        if (mounted) {
          _snack('Proveedor eliminado. Productos desvinculados.',
              _colorSuccess);
        }
      } else {
        if (mounted) _snack('Error al eliminar el proveedor', _colorDanger);
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', _colorDanger);
    }
  }

  Future<void> _reasignarYEliminar(
      ProveedorEntity proveedor, List<ProductoEntity> productos) async {
    final isar = ref.read(isarServiceProvider);
    final otros = await isar.obtenerProveedores(soloActivos: true);
    otros.removeWhere((p) => p.id == proveedor.id);

    if (otros.isEmpty) {
      if (mounted) {
        _snack('No hay otros proveedores activos para reasignar.',
            _colorWarning);
      }
      return;
    }

    final destino = await showDialog<ProveedorEntity>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seleccionar proveedor destino'),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: ListView.builder(
            itemCount: otros.length,
            itemBuilder: (context, i) {
              final p = otros[i];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ListTile(
                  title: Text(p.nombre),
                  subtitle: Text(p.empresa ?? ''),
                  leading: const Icon(Icons.business_center_rounded,
                      color: _colorPrimary),
                  onTap: () => Navigator.pop(context, p),
                ),
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

    if (destino == null) return;

    try {
      for (var p in productos) {
        p.proveedorId = destino.id;
        await isar.guardarProducto(p);
      }
      final ok = await isar.eliminarProveedor(proveedor.id);
      if (ok) {
        if (proveedor.supabaseId?.isNotEmpty ?? false) {
          await SyncService()
              .eliminarProveedorEnSupabase(proveedor.supabaseId!);
        }
        _invalidarLista();
        if (mounted) {
          _snack(
              'Productos reasignados a "${destino.nombre}" y proveedor eliminado',
              _colorSuccess);
        }
      } else {
        if (mounted) _snack('Error al eliminar el proveedor', _colorDanger);
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', _colorDanger);
    }
  }

  Future<void> _ejecutarEliminacion(ProveedorEntity proveedor) async {
    final isar = ref.read(isarServiceProvider);
    final sync = SyncService();
    try {
      final ok = await isar.eliminarProveedor(proveedor.id);
      if (ok) {
        if (proveedor.supabaseId?.isNotEmpty ?? false) {
          await sync.eliminarProveedorEnSupabase(proveedor.supabaseId!);
        }
        _invalidarLista();
        if (mounted) _snack('Proveedor eliminado correctamente', _colorSuccess);
      } else {
        if (mounted) {
          _snack('No se pudo eliminar: tiene productos asociados',
              _colorWarning);
        }
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', _colorDanger);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final proveedoresAsync = ref.watch(proveedoresConFiltroProvider((
      query: _queryBusqueda,
      mostrarInactivos: _mostrarInactivos,
      productoId: _productoFiltroId,
    )));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: isMobile ? 'Proveedores' : 'Gestión de Proveedores',
        showBackButton: true,
        centerTitle: false,
        actions: [
          MouseRegion(
            cursor: _isSyncing
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
            child: IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, color: Colors.white),
              onPressed: _isSyncing ? null : _sincronizarProveedores,
              tooltip: 'Sincronizar',
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: () {
                _invalidarLista();
                _cargarProductos();
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Recargar lista',
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // ===== SEARCH =====
              GlassSearchBar(
                hint: 'Buscar por nombre o empresa...',
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    if (mounted) setState(() => _queryBusqueda = value);
                  });
                },
              ),
              const SizedBox(height: 12),

              // ===== FILTROS =====
              _buildFiltros(colorScheme, isDark),
              const SizedBox(height: 12),

              // ===== LISTA =====
              Expanded(
                child: proveedoresAsync.when(
                  data: (proveedores) =>
                      _buildLista(proveedores, colorScheme),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => _buildError(err, colorScheme),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FloatingActionButton(
          onPressed: _navegarACrear,
          backgroundColor: _colorPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }

  // ============================================================
  // FILTROS
  // ============================================================
  Widget _buildFiltros(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SegmentedToggle<bool>(
            selected: _mostrarInactivos,
            onChanged: (value) {
              setState(() => _mostrarInactivos = value);
              _invalidarLista();
            },
            items: const [
              SegmentedToggleItem(
                value: false,
                label: 'Activos',
                icon: Icons.check_circle_rounded,
              ),
              SegmentedToggleItem(
                value: true,
                label: 'Inactivos',
                icon: Icons.cancel_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int?>(
            initialValue: _productoFiltroId,
            hint: Text(
              'Filtrar por producto',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.inventory_2_rounded,
                  size: 20, color: colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _colorPrimary, width: 2),
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
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              ..._productos.map((p) => DropdownMenuItem<int?>(
                    value: p.id,
                    child: Text(
                      p.nombre,
                      style: TextStyle(color: colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() => _productoFiltroId = value);
              _invalidarLista();
            },
            icon: Icon(Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant),
            dropdownColor: colorScheme.surface,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LISTA
  // ============================================================
  Widget _buildLista(List<ProveedorEntity> proveedores, ColorScheme colorScheme) {
    if (proveedores.isEmpty) return _buildEmpty(colorScheme);

    return RefreshIndicator(
      onRefresh: () async {
        _invalidarLista();
        await _cargarProductos();
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: proveedores.length,
          itemBuilder: (context, index) {
            final p = proveedores[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 350),
              child: SlideAnimation(
                verticalOffset: 30,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  child: ProveedorCard(
                    proveedor: p,
                    onTap: () => _navegarADetalle(p),
                    onEdit: () => _navegarAEditar(p),
                    onToggleActivo: () => _toggleActivo(p),
                    onDelete: () => _eliminarProveedor(p),
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
  // ESTADOS VACÍO / ERROR
  // ============================================================
  Widget _buildEmpty(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_center_rounded,
              size: 48,
              color: _colorPrimary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay proveedores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea tu primer proveedor para empezar',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton.icon(
              onPressed: _navegarACrear,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Crear proveedor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 60, color: colorScheme.error),
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
            onPressed: _invalidarLista,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================
  Future<void> _navegarACrear() async {
    await showDialog(
      context: context,
      builder: (_) => const CrearProveedorDialog(),
    );
    if (mounted) {
      _invalidarLista();
      await _cargarProductos();
    }
  }

  Future<void> _navegarAEditar(ProveedorEntity proveedor) async {
    await showDialog(
      context: context,
      builder: (_) => CrearProveedorDialog(proveedor: proveedor),
    );
    if (mounted) {
      _invalidarLista();
      await _cargarProductos();
    }
  }

  Future<void> _navegarADetalle(ProveedorEntity proveedor) async {
    await showDialog(
      context: context,
      builder: (_) => DetalleProveedorDialog(proveedor: proveedor),
    );
    if (mounted) _invalidarLista();
  }

  Future<void> _toggleActivo(ProveedorEntity proveedor) async {
    try {
      if (proveedor.activo) {
        await ref
            .read(proveedoresProvider.notifier)
            .desactivarProveedor(proveedor.id);
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
        await ref
            .read(proveedoresProvider.notifier)
            .guardarProveedor(actualizado);
        await _sincronizarProveedores();
      }
      _invalidarLista();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) _snack('Error: $e', _colorDanger);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}