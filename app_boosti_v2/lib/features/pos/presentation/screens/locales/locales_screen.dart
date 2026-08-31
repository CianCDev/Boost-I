// lib/features/pos/presentation/screens/locales/locales_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Providers
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';

// Entities
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';

// Widgets
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/local_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/crear_local_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/detalle_local_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/dialogos_genericos/dialogos_genericos.dart';

// Services & Utils
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

import '../../widgets/dialogos_genericos/error_dialog.dart';
import '../../widgets/dialogos_genericos/succes.dialog.dart';

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

  // ============================================================
  // Sincronización
  // ============================================================
  Future<void> _sincronizarLocales() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final sync = SyncService();
      await sync.sincronizarLocalesPendientes();
      await sync.descargarLocalesDesdeSupabase();
      ref.invalidate(localesProvider);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => const SuccessDialog(
            title: 'Sincronización exitosa',
            content: 'Los locales se han sincronizado correctamente.',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error al sincronizar',
            content: e.toString(),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final localesAsync = ref.watch(localesProvider);
    final currentLocalId = ref.watch(localActualProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    final localesFiltrados = localesAsync.whenData((locales) {
      return locales.where((l) {
        final coincideNombre = l.nombre.toLowerCase().contains(_queryBusqueda.toLowerCase());
        final coincideEstado = _mostrarInactivos ? !l.activo : l.activo;
        return coincideNombre && coincideEstado;
      }).toList();
    });

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: isMobile ? 'Locales' : 'Gestión de Locales',
        showBackButton: true,
        centerTitle: false,
        actions: [
          // Botón de sincronización
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
          // Menú para cambiar local actual
          PopupMenuButton<int>(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            tooltip: 'Cambiar local actual',
            onSelected: (int localId) async {
              await ref.read(localActualProvider.notifier).setLocalActual(localId);
              setState(() {});
            },
            itemBuilder: (context) {
              return localesAsync.when(
                data: (locales) {
                  final currentId = ref.read(localActualProvider);
                  return locales.map((local) {
                    return PopupMenuItem<int>(
                      value: local.id,
                      child: Row(
                        children: [
                          if (currentId == local.id)
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(local.nombre)),
                        ],
                      ),
                    );
                  }).toList();
                },
                loading: () => [const PopupMenuItem(child: Text('Cargando...'))],
                error: (_, __) => [const PopupMenuItem(child: Text('Error'))],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFiltros(),
              Expanded(
                child: localesFiltrados.when(
                  data: (locales) => _buildListaLocales(locales, currentLocalId),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => _buildErrorState(err),
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
  // Widgets de UI
  // ============================================================
  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar locales por nombre...',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
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
      ),
    );
  }

  Widget _buildListaLocales(List<LocalEntity> locales, int? currentLocalId) {
    if (locales.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(localesProvider);
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 88),
          itemCount: locales.length,
          itemBuilder: (context, index) {
            final local = locales[index];
            final isLocalActual = currentLocalId == local.id;
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
                    isLocalActual: isLocalActual,
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

  // ============================================================
  // Acciones
  // ============================================================
  void _mostrarCrear() {
    showDialog<bool>(
      context: context,
      builder: (_) => const CrearLocalDialog(),
    ).then((result) {
      if (result == true && mounted) {
        // ignore: unused_result
        ref.refresh(localesProvider);
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
        // ignore: unused_result
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
        ..rif = local.rif
        ..activo = !local.activo
        ..supabaseId = local.supabaseId
        ..sincronizado = false;
      await ref.read(guardarLocalProvider(actualizado).future);
      await _sincronizarLocales();
      ref.invalidate(localesProvider);
      setState(() {});
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error al cambiar estado',
            content: e.toString(),
          ),
        );
      }
    }
  }

Future<void> _eliminarLocal(LocalEntity local) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDialog(
      title: 'Eliminar Local',
      content: '¿Estás seguro de eliminar "${local.nombre}"? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      confirmColor: Colors.red,
      onConfirm: () => Navigator.of(context).pop(true),
    ),
  );

  if (confirm == true) {
    try {
      // 1. Eliminar local en la base de datos local
      await ref.read(eliminarLocalProvider(local.id).future);

      // 2. Sincronizar usuarios desde Supabase
      await SyncService().sincronizarUsuariosDesdeSupabase();

      // 3. Recargar local actual por si era el que se eliminó
      await ref.read(localActualProvider.notifier).cargarLocalActual();

      // 4. Invalidar providers para refrescar todas las vistas afectadas
      ref.invalidate(usuariosProvider);
      ref.invalidate(todosDepartamentosProvider);
      ref.invalidate(localesProvider);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => const SuccessDialog(
            title: 'Local eliminado',
            content: 'El local se ha eliminado correctamente.',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error al eliminar',
            content: e.toString(),
          ),
        );
      }
    }
  }
}
}