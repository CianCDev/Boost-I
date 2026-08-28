import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/crear_local_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/local_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../../widgets/locales/detalle_local_dialog.dart';

class LocalesScreen extends ConsumerStatefulWidget {
  const LocalesScreen({super.key});

  @override
  ConsumerState<LocalesScreen> createState() => _LocalesScreenState();
}

class _LocalesScreenState extends ConsumerState<LocalesScreen> {
  String _queryBusqueda = '';
  bool _mostrarInactivos = false;
  bool _isSyncing = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _sincronizarLocales() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final sync = SyncService();
      await sync.sincronizarLocalesPendientes();
      await sync.descargarLocalesDesdeSupabase();
      ref.invalidate(localesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Locales sincronizados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al sincronizar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localesAsync = ref.watch(localesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    // Filtrar locales
    final localesFiltrados = localesAsync.whenData((locales) {
      return locales.where((l) {
        final coincideNombre = l.nombre.toLowerCase().contains(_queryBusqueda.toLowerCase());
        final coincideEstado = _mostrarInactivos ? !l.activo : l.activo;
        return coincideNombre && coincideEstado;
      }).toList();
    });

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFiltros(),
          Expanded(
            child: localesFiltrados.when(
              data: (locales) => _buildListaLocales(locales),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorState(err),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Locales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
          icon: _isSyncing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.sync_rounded, color: Colors.white),
          onPressed: _isSyncing ? null : _sincronizarLocales,
          tooltip: 'Sincronizar locales',
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
          hintText: 'Buscar locales...',
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
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            setState(() => _queryBusqueda = value);
          });
        },
      ),
    );
  }

  Widget _buildFiltros() {
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
    );
  }

  Widget _buildListaLocales(List<LocalEntity> locales) {
    if (locales.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(localesProvider);
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 88),
          itemCount: locales.length,
          itemBuilder: (context, index) {
            final local = locales[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  curve: Curves.easeOutCubic,
                  child: LocalCard(
                    local: local,
                    onTap: () => _mostrarDetalle(local),
                    onEdit: () => _mostrarEditar(local),
                    onToggleActivo: () => _toggleActivo(local),
                    onDelete: () => _eliminarLocal(local),
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
          Icon(Icons.storefront_rounded, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No hay locales',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer local',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _mostrarCrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear local'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: colorScheme.error),
          const SizedBox(height: 16),
          Text('Error al cargar locales', style: TextStyle(color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(error.toString(), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(localesProvider),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: _mostrarCrear,
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }

void _mostrarCrear() {
  showDialog<bool>(
    context: context,
    builder: (_) => const CrearLocalDialog(),
  ).then((result) {
    if (result == true && mounted) {
      // Forzar recarga completa
      ref.refresh(localesProvider);
      // Forzar rebuild del widget
      setState(() {});
    }
  });
}

void _mostrarEditar(LocalEntity local) {
  showDialog<bool>(
    context: context,
    builder: (_) => CrearLocalDialog(local: local),
  ).then((result) {
    if (result == true && mounted) {
      ref.refresh(localesProvider);
      setState(() {});
    }
  });
}

void _mostrarDetalle(LocalEntity local) {
  showDialog(
    context: context,
    builder: (_) => DetalleLocalDialog(local: local),
  );
}

  Future<void> _toggleActivo(LocalEntity local) async {
    try {
      final actualizado = LocalEntity()
        ..id = local.id
        ..nombre = local.nombre
        ..direccion = local.direccion
        ..telefono = local.telefono
        ..email = local.email
        ..activo = !local.activo
        ..supabaseId = local.supabaseId
        ..sincronizado = false;
      await ref.read(guardarLocalProvider(actualizado).future);
      await _sincronizarLocales();
      ref.invalidate(localesProvider);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _eliminarLocal(LocalEntity local) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Local'),
        content: Text('¿Estás seguro de eliminar "${local.nombre}"? Esta acción no se puede deshacer.'),
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
      try {
        await ref.read(eliminarLocalProvider(local.id).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Local eliminado correctamente'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}