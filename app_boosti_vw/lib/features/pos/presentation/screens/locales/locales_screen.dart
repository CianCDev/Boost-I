// lib/features/pos/presentation/screens/locales/locales_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/local_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/crear_local_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/locales/detalle_local_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/dialogos_genericos/dialogos_genericos.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../../widgets/dialogos_genericos/error_dialog.dart';
import '../../widgets/dialogos_genericos/succes_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final localesAsync = ref.watch(localesProvider);
    final currentLocalId = ref.watch(localActualProvider);

    final localesFiltrados = localesAsync.whenData((locales) {
      return locales.where((l) {
        final coincideNombre = l.nombre.toLowerCase().contains(_queryBusqueda.toLowerCase());
        final coincideEstado = _mostrarInactivos ? !l.activo : l.activo;
        return coincideNombre && coincideEstado;
      }).toList();
    });

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF0F4F8),
      appBar: CustomAppBar(
        title: isMobile ? 'Locales' : 'Gestión de Locales',
        showBackButton: true,
        centerTitle: false,
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync_rounded, color: Colors.white),
            onPressed: _isSyncing ? null : _sincronizarLocales,
            tooltip: 'Sincronizar locales',
          ),
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
                child: localesFiltrados.when(
                  data: (locales) => _buildListaLocales(locales, currentLocalId, colorScheme, isDark),
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
              hintText: 'Buscar locales por nombre...',
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
              _debounce?.cancel();
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
          child: SegmentedButton<String>(
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
        ),
      ),
    );
  }

  // ============================================================
  // LISTA CON CARDS GLASSMORPHISM
  // ============================================================
  Widget _buildListaLocales(List<LocalEntity> locales, int? currentLocalId, ColorScheme colorScheme, bool isDark) {
    if (locales.isEmpty) return _buildEmptyState(colorScheme, isDark);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(localesProvider);
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
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

  // ============================================================
  // ESTADOS VACÍO Y ERROR
  // ============================================================
  Widget _buildEmptyState(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_rounded,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay locales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer local',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _mostrarCrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear local'),
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
            'Error al cargar locales',
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
            onPressed: () => ref.invalidate(localesProvider),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FLOATING BUTTON
  // ============================================================
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: _mostrarCrear,
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
  void _mostrarCrear() {
    showDialog<bool>(
      context: context,
      builder: (_) => const CrearLocalDialog(),
    ).then((result) {
      if (result == true && mounted) {
        ref.invalidate(localesProvider);
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
        ref.invalidate(localesProvider);
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
        confirmColor: const Color(0xFFEF4444),
        onConfirm: () {},
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(eliminarLocalProvider(local.id).future);
        await SyncService().sincronizarUsuariosDesdeSupabase();
        await ref.read(localActualProvider.notifier).cargarLocalActual();
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