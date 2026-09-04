// lib/features/pos/presentation/screens/lotes/lotes_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/lotes_summary_cards.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/lotes_product_list.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/lotes_codigo_tab.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
// ✅ IMPORT CORREGIDO
import 'package:app_boosti_v2/features/pos/presentation/screens/lotes/lotes_detalle_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class LotesDashboardScreen extends ConsumerStatefulWidget {
  const LotesDashboardScreen({super.key});

  @override
  ConsumerState<LotesDashboardScreen> createState() => _LotesDashboardScreenState();
}

class _LotesDashboardScreenState extends ConsumerState<LotesDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF0F4F8),
      appBar: CustomAppBar(
        title: 'Gestión de Lotes',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: notifier.recargar,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarjetas de resumen
          LotesSummaryCards(
            pendientes: state.lotesPendientes.length,
            activos: state.lotesActivos.length,
            proximosAVencer: _contarProximosAVencer(state.lotesActivos),
            historial: state.lotesHistorial.length,
          ),
          const SizedBox(height: 8),

          // Búsqueda + Tabs integrados
          _buildSearchAndTabs(isDark, isMobile),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLotesPorProducto(state.lotesPendientes, _searchQuery, 'pendiente'),
                _buildLotesPorProducto(state.lotesActivos, _searchQuery, 'activo'),
                _buildLotesPorProducto(state.lotesHistorial, _searchQuery, 'historial'),
                const LotesCodigosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndTabs(bool isDark, bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(8),
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
          // Barra de búsqueda compacta
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar producto o código...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  onPressed: () => setState(() => _searchQuery = ''),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          // Tabs con badges
          TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(3),
            labelColor: const Color(0xFF8B5CF6),
            unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
            labelStyle: TextStyle(
              fontSize: isMobile ? 11 : 13,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isMobile ? 11 : 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              _buildTab(Icons.hourglass_top_rounded, 'Pend.', 0),
              _buildTab(Icons.check_circle_rounded, 'Activos', 0),
              _buildTab(Icons.history_rounded, 'Hist.', 0),
              _buildTab(Icons.qr_code_rounded, 'Cód.', 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, int count) {
    return Tab(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 18),
          if (count > 0)
            Positioned(
              right: -10,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      text: label,
    );
  }

  int _contarProximosAVencer(List<LoteEntity> lotes) {
    final ahora = DateTime.now();
    final limite = ahora.add(const Duration(days: 7));
    return lotes.where((l) =>
        l.fechaVencimiento != null &&
        l.fechaVencimiento!.isAfter(ahora) &&
        l.fechaVencimiento!.isBefore(limite)
    ).length;
  }

  Widget _buildLotesPorProducto(List<LoteEntity> lotes, String query, String estado) {
    final filtrados = lotes.where((l) {
      final productoMatch = l.productoId.toString().contains(query);
      final codigoMatch = l.codigoLoteProveedor?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return productoMatch || codigoMatch;
    }).toList();

    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                estado == 'pendiente' ? Icons.hourglass_empty_rounded :
                estado == 'activo' ? Icons.inventory_2_rounded :
                Icons.history_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              estado == 'pendiente' ? 'No hay lotes pendientes' :
              estado == 'activo' ? 'No hay lotes activos' :
              'No hay historial de lotes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return LotesProductList(
      lotes: filtrados,
      estado: estado,
      onLoteTap: (lote) {
        // ✅ AHORA USA EL IMPORT CORRECTO
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
}