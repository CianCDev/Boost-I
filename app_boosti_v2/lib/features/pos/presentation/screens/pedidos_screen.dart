import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/pedido_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/crear_pedido_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/detalle_pedido_screen.dart';

class PedidosProveedorScreen extends ConsumerStatefulWidget {
  const PedidosProveedorScreen({super.key});

  @override
  ConsumerState<PedidosProveedorScreen> createState() => _PedidosProveedorScreenState();
}

class _PedidosProveedorScreenState extends ConsumerState<PedidosProveedorScreen>
    with SingleTickerProviderStateMixin {
  EstadoPedido? _estadoFiltro;
  int? _localDestinoId;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localDestinoId = _localDestinoId ?? 1; // TODO: obtener del usuario actual

    final pedidosAsync = ref.watch(
      pedidosPorEstadoProvider(
        (localDestinoId: localDestinoId, estado: _estadoFiltro),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Resumen rápido con contadores
          _buildResumenPedidos(pedidosAsync),
          // Filtro por estado
          _buildFiltroEstado(),
          // Lista de pedidos
          Expanded(
            child: pedidosAsync.when(
              data: (pedidos) => _buildListaPedidos(pedidos),
              loading: () => _buildLoadingState(),
              error: (err, stack) => _buildErrorState(err),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  // ==========================================
  // APP BAR CON ESTILO MEJORADO
  // ==========================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Pedidos a Proveedores',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(68, 109, 241, 1),
              Color.fromARGB(255, 85, 59, 235),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      foregroundColor: Colors.white,
      actions: [
        // Filtro por local destino
        PopupMenuButton<int>(
          icon: const Icon(Icons.storefront_rounded),
          onSelected: (value) => setState(() => _localDestinoId = value),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 1, child: Text('Local Principal')),
            PopupMenuItem(value: 2, child: Text('Local Secundario')),
          ],
        ),
        IconButton(
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  // ==========================================
  // RESUMEN CON CONTADORES (NUEVO)
  // ==========================================
  Widget _buildResumenPedidos(AsyncValue<List<PedidoEntity>> pedidosAsync) {
    return pedidosAsync.when(
      data: (pedidos) {
        final total = pedidos.length;
        final pendientes = pedidos.where((p) => p.estado == EstadoPedido.pendiente).length;
        final recibidos = pedidos.where((p) => p.estado == EstadoPedido.recibido).length;
        final cancelados = pedidos.where((p) => p.estado == EstadoPedido.cancelado).length;

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildContadorItem('Total', total, Colors.blue.shade600),
              _buildContadorItem('Pendientes', pendientes, Colors.orange.shade600),
              _buildContadorItem('Recibidos', recibidos, Colors.green.shade600),
              _buildContadorItem('Cancelados', cancelados, Colors.red.shade600),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContadorItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FILTRO POR ESTADO CON ESTILO
  // ==========================================
  Widget _buildFiltroEstado() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SegmentedButton<EstadoPedido?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Todos'), icon: Icon(Icons.list_rounded)),
              ButtonSegment(
                value: EstadoPedido.pendiente,
                label: Text('Pendientes'),
                icon: Icon(Icons.hourglass_top_rounded),
              ),
              ButtonSegment(
                value: EstadoPedido.recibido,
                label: Text('Recibidos'),
                icon: Icon(Icons.check_circle_rounded),
              ),
              ButtonSegment(
                value: EstadoPedido.cancelado,
                label: Text('Cancelados'),
                icon: Icon(Icons.cancel_rounded),
              ),
            ],
            selected: {_estadoFiltro},
            onSelectionChanged: (Set<EstadoPedido?> newSelection) {
              setState(() {
                _estadoFiltro = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.grey.shade700,
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LISTA DE PEDIDOS CON ANIMACIÓN
  // ==========================================
  Widget _buildListaPedidos(List<PedidoEntity> pedidos) {
    if (pedidos.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PedidoCard(
                      pedido: pedido,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetallePedidoProveedorScreen(pedidoId: pedido.id),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // ESTADO VACÍO CON DISEÑO ATRACTIVO
  // ==========================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 60,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _estadoFiltro == null
                ? 'Comienza creando tu primer pedido\npresionando el botón +'
                : 'No hay pedidos en este estado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          if (_estadoFiltro != null)
            ElevatedButton.icon(
              onPressed: () => setState(() => _estadoFiltro = null),
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Ver todos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // ESTADOS DE CARGA Y ERROR
  // ==========================================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando pedidos...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar los pedidos',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTÓN FLOTANTE CON ESTILO
  // ==========================================
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CrearPedidoProveedorScreen(),
          ),
        );
        setState(() {});
      },
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }
}