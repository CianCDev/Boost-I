// lib/features/pos/presentation/screens/lotes/lotes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/lotes_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/verificar_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/categorias_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/categoria_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart';

class LotesScreen extends ConsumerStatefulWidget {
  const LotesScreen({super.key});

  @override
  ConsumerState<LotesScreen> createState() => _LotesScreenState();
}

class _LotesScreenState extends ConsumerState<LotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(lotesProvider.notifier).setTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lotesProvider);
    final notifier = ref.read(lotesProvider.notifier);
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: isMobile ? 'Lotes' : 'Gestión de Lotes',
        showBackButton: true,
        actions: [
          // 🔥 Dropdown de categorías en la AppBar (sin conflicto icon/child)
          _buildCategoryDropdown(categoriasAsync, state.categoriaFiltro, notifier),
          const SizedBox(width: 8),
          IconButton(
            icon: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: state.isLoading ? null : notifier.refresh,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por producto o código de barras...',
                    prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: colorScheme.onSurfaceVariant),
                            onPressed: () => notifier.setSearch(''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: notifier.setSearch,
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Pendientes', icon: Icon(Icons.hourglass_top_rounded)),
                  Tab(text: 'Activos', icon: Icon(Icons.check_circle_rounded)),
                  Tab(text: 'Próximos', icon: Icon(Icons.event_available_rounded)),
                  Tab(text: 'Historial', icon: Icon(Icons.history_rounded)),
                ],
              ),

              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null
                        ? Center(child: Text('Error: ${state.error}'))
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLista(state, notifier, esAdmin, 0),
                              _buildLista(state, notifier, esAdmin, 1),
                              _buildLista(state, notifier, esAdmin, 2),
                              _buildLista(state, notifier, esAdmin, 3),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para el dropdown de categorías (CORREGIDO: sin icon)
  Widget _buildCategoryDropdown(
    AsyncValue<List<CategoriaEntity>> categoriasAsync,
    String categoriaSeleccionada,
    LotesNotifier notifier,
  ) {
    return categoriasAsync.when(
      data: (categorias) {
        final items = <String>[
          'Todas',
          ...categorias.map((cat) => cat.nombre),
        ];

        return PopupMenuButton<String>(
          // ✅ Quitamos 'icon' y usamos solo 'child' para evitar el error
          tooltip: 'Filtrar por categoría',
          onSelected: (value) => notifier.setCategoriaFiltro(value),
          itemBuilder: (context) {
            return items.map((cat) {
              return PopupMenuItem<String>(
                value: cat,
                child: Row(
                  children: [
                    if (cat == categoriaSeleccionada)
                      const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(cat),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_alt_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  categoriaSeleccionada == 'Todas' ? 'Categoría' : categoriaSeleccionada,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const SizedBox(
          width: 80,
          height: 20,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ),
        ),
      ),
      error: (err, stack) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Text('Error', style: TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  Widget _buildLista(LotesState state, LotesNotifier notifier, bool esAdmin, int tabIndex) {
    final lotes = state.getLotesPorTab(tabIndex);

    if (lotes.isEmpty) {
      String mensaje;
      IconData icono;
      String subtitulo = '';
      switch (tabIndex) {
        case 0:
          mensaje = 'No hay lotes pendientes';
          icono = Icons.inbox_rounded;
          subtitulo = 'Los lotes aparecerán aquí al recibir un pedido';
          break;
        case 1:
          mensaje = 'No hay lotes activos';
          icono = Icons.inventory_2_rounded;
          break;
        case 2:
          mensaje = 'No hay lotes próximos a vencer';
          icono = Icons.event_available_rounded;
          break;
        case 3:
          mensaje = 'No hay historial de lotes';
          icono = Icons.history_rounded;
          break;
        default:
          mensaje = 'No hay lotes';
          icono = Icons.inbox_rounded;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            if (subtitulo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: lotes.length,
          itemBuilder: (context, index) {
            final lote = lotes[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  curve: Curves.easeOutCubic,
                  child: LoteCard(
                    lote: lote,
                    esAdmin: esAdmin,
                    onTap: () => _mostrarDetalle(lote, notifier),
                    onVerificar: lote.estado == 'pendiente'
                        ? () => _mostrarVerificacion(lote, notifier)
                        : null,
                    onReponer: lote.estado == 'activo' && lote.cantidadRestante > 0 && esAdmin
                        ? () => _mostrarReponer(lote, notifier)
                        : null,
                    isProximoAVencer: tabIndex == 2 && lote.fechaVencimiento != null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _mostrarDetalle(LoteEntity lote, LotesNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => DetalleLoteDialog(lote: lote),
    ).then((_) => notifier.recargar());
    ref.read(productosProvider.notifier).cargarProductos();
  }

  void _mostrarVerificacion(LoteEntity lote, LotesNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => VerificarLoteDialog(lote: lote),
    ).then((_) => notifier.recargar());
  }

  void _mostrarReponer(LoteEntity lote, LotesNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => TraspasoLoteDialog(lote: lote),
    ).then((_) => notifier.recargar());
  }
}