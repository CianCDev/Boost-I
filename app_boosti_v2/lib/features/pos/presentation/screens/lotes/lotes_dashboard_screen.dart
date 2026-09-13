// lib/features/pos/presentation/screens/lotes/lotes_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/lotes_summary_cards.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/lotes_product_list.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/lotes/lotes_detalle_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/categorias_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_search_bar.dart';

import '../../widgets/lotes/detalle_lote/lotes_codigo_tab.dart';

class LotesDashboardScreen extends ConsumerStatefulWidget {
  const LotesDashboardScreen({super.key});

  @override
  ConsumerState<LotesDashboardScreen> createState() =>
      _LotesDashboardScreenState();
}

class _LotesDashboardScreenState extends ConsumerState<LotesDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _contarProximosAVencer(List<LoteEntity> lotes) {
    final ahora = DateTime.now();
    final limite = ahora.add(const Duration(days: 7));
    return lotes
        .where((l) =>
            l.fechaVencimiento != null &&
            l.fechaVencimiento!.isAfter(ahora) &&
            l.fechaVencimiento!.isBefore(limite))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lotesProvider);
    final notifier = ref.read(lotesProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Gestión de Lotes',
        showBackButton: true,
        actions: [
          _buildLocalSelector(notifier),
          _buildCategoriaSelector(state, notifier),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: notifier.recargar,
              tooltip: 'Recargar',
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? _buildErrorState(state, notifier, colorScheme)
                  : Column(
                      children: [
                        // ===== MÉTRICAS (idénticas a Pedidos) =====
                        LotesSummaryCards(
                          pendientes: state.lotesPendientes.length,
                          activos: state.lotesActivos.length,
                          proximosAVencer:
                              _contarProximosAVencer(state.lotesActivos),
                          historial: state.lotesHistorial.length,
                        ),
                        const SizedBox(height: 14),

                        // ===== BÚSQUEDA (GlassSearchBar) =====
                        GlassSearchBar(
                          hint: 'Buscar producto o código...',
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                        ),
                        const SizedBox(height: 12),

                        // ===== TABS (pill style) =====
                        _buildTabs(colorScheme, isMobile),
                        const SizedBox(height: 12),

                        // ===== CONTENIDO =====
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLotesPorProducto(
                                  state.lotesPendientes, 'pendiente'),
                              _buildLotesPorProducto(
                                  state.lotesActivos, 'activo'),
                              _buildLotesPorProducto(
                                  state.lotesHistorial, 'historial'),
                              const LotesCodigosTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  // ============================================================
  // TABS (pill style consistente)
  // ============================================================
  Widget _buildTabs(ColorScheme colorScheme, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _colorPrimary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _colorPrimary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 11 : 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 11 : 13,
        ),
        tabs: const [
          Tab(
            height: 42,
            icon: Icon(Icons.hourglass_top_rounded, size: 18),
            text: 'Pendientes',
          ),
          Tab(
            height: 42,
            icon: Icon(Icons.check_circle_rounded, size: 18),
            text: 'Activos',
          ),
          Tab(
            height: 42,
            icon: Icon(Icons.history_rounded, size: 18),
            text: 'Historial',
          ),
          Tab(
            height: 42,
            icon: Icon(Icons.qr_code_rounded, size: 18),
            text: 'Códigos',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTOR DE LOCAL
  // ============================================================
  Widget _buildLocalSelector(dynamic notifier) {
    return Consumer(
      builder: (context, ref, child) {
        final localesAsync = ref.watch(localesProvider);
        final currentLocalId = ref.watch(localActualProvider);
        return localesAsync.when(
          data: (locales) {
            return PopupMenuButton<int>(
              icon: const Icon(Icons.storefront_rounded, color: Colors.white),
              tooltip: 'Seleccionar local',
              onSelected: (id) async {
                await ref.read(localActualProvider.notifier).setLocalActual(id);
                notifier.recargar();
              },
              itemBuilder: (context) {
                return locales.map((local) {
                  final isSelected = currentLocalId == local.id;
                  return PopupMenuItem<int>(
                    value: local.id,
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: _colorSuccess, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(local.nombre)),
                      ],
                    ),
                  );
                }).toList();
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) =>
              const Icon(Icons.error_outline, color: Colors.white),
        );
      },
    );
  }

  // ============================================================
  // SELECTOR DE CATEGORÍA
  // ============================================================
  Widget _buildCategoriaSelector(dynamic state, dynamic notifier) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriasAsync = ref.watch(categoriasProvider);
        final categoriaSeleccionada = state.categoriaFiltro;
        return categoriasAsync.when(
          data: (categorias) {
            final items = ['Todas', ...categorias.map((c) => c.nombre)];
            return PopupMenuButton<String>(
              icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
              tooltip: 'Filtrar por categoría',
              onSelected: (value) => notifier.setCategoriaFiltro(value),
              itemBuilder: (context) {
                return items.map((cat) {
                  return PopupMenuItem<String>(
                    value: cat,
                    child: Row(
                      children: [
                        if (cat == categoriaSeleccionada)
                          const Icon(Icons.check_circle_rounded,
                              color: _colorSuccess, size: 16),
                        const SizedBox(width: 8),
                        Text(cat),
                      ],
                    ),
                  );
                }).toList();
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) =>
              const Icon(Icons.error_outline, color: Colors.white),
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================
  Widget _buildErrorState(
      dynamic state, dynamic notifier, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 60, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar los lotes',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            state.error.toString(),
            style: TextStyle(
                color: colorScheme.onSurfaceVariant, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: notifier.recargar,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LISTA POR ESTADO
  // ============================================================
  Widget _buildLotesPorProducto(List<LoteEntity> lotes, String estado) {
    final filtrados = lotes.where((l) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final productoMatch = l.productoId.toString().contains(q);
      final codigoMatch = l.codigoLoteProveedor?.toLowerCase().contains(q) ?? false;
      return productoMatch || codigoMatch;
    }).toList();

    if (filtrados.isEmpty) {
      return _buildEmptyState(estado);
    }

    return LotesProductList(
      lotes: filtrados,
      estado: estado,
      onLoteTap: (lote) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LotesDetalleScreen(lote: lote),
          ),
        );
      },
      initiallyExpanded: false,
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
  Widget _buildEmptyState(String estado) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (IconData icono, String texto, Color color) = switch (estado) {
      'pendiente' => (
          Icons.hourglass_empty_rounded,
          'No hay lotes pendientes',
          _colorWarning
        ),
      'activo' => (
          Icons.inventory_2_rounded,
          'No hay lotes activos',
          _colorSuccess
        ),
      _ => (Icons.history_rounded, 'No hay historial de lotes', _colorPrimary),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            texto,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Los lotes aparecerán aquí cuando estén disponibles',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}