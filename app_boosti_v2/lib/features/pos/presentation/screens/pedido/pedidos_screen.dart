// ignore_for_file: unused_local_variable

import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/crear_pedido_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_pedido_dialog.dart'; // ✅ NUEVO
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/pedido_card.dart';
import '../../widgets/sales/sales_history_filter_bar.dart';
import '../../utils/responsive_helper.dart';

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

  String _periodoSeleccionado = 'todos';
  String _mesSeleccionado = 'Actual';
  int _anioSeleccionado = DateTime.now().year;
  final List<int> _aniosDisponibles = [];

  final List<String> _listaMesesDropdown = [
    'Actual', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();

    final now = DateTime.now();
    for (int i = 2020; i <= now.year; i++) {
      _aniosDisponibles.add(i);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _perteneceAlPeriodo(DateTime fecha, String periodo) {
    final now = DateTime.now();
    final fechaLocal = fecha.toLocal();
    final fechaDia = DateTime(fechaLocal.year, fechaLocal.month, fechaLocal.day);
    final hoy = DateTime(now.year, now.month, now.day);

    switch (periodo) {
      case 'dia':
        return fechaDia.isAtSameMomentAs(hoy);
      case 'semana':
        final inicioSemana = hoy.subtract(Duration(days: now.weekday - 1));
        final finSemana = inicioSemana.add(const Duration(days: 6));
        return (fechaDia.isAtSameMomentAs(inicioSemana) || fechaDia.isAfter(inicioSemana)) &&
               (fechaDia.isAtSameMomentAs(finSemana) || fechaDia.isBefore(finSemana));
      case 'mes':
        if (_mesSeleccionado == 'Actual') {
          return fechaLocal.year == now.year && fechaLocal.month == now.month;
        } else {
          final int indexMes = _listaMesesDropdown.indexOf(_mesSeleccionado);
          return fechaLocal.year == _anioSeleccionado && fechaLocal.month == indexMes;
        }
      case 'anio':
        return fechaLocal.year == _anioSeleccionado;
      case 'todos':
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localDestinoId = _localDestinoId ?? 1;
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    final pedidosAsync = ref.watch(
      pedidosPorEstadoProvider(
        (localDestinoId: localDestinoId, estado: _estadoFiltro),
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildResumenPedidos(pedidosAsync),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0, vertical: 4.0),
            child: SalesHistoryFilterBar(
              selectedPeriod: _periodoSeleccionado,
              onPeriodChanged: (periodo) => setState(() => _periodoSeleccionado = periodo),
              isMobile: isMobile,
              isTablet: ResponsiveHelper.isTablet(context),
              mesesDropdown: _listaMesesDropdown,
              mesSeleccionado: _mesSeleccionado,
              aniosDisponibles: _aniosDisponibles,
              anioSeleccionado: _anioSeleccionado,
              onMesChanged: (mes) => setState(() => _mesSeleccionado = mes),
              onAnioChanged: (anio) => setState(() => _anioSeleccionado = anio),
            ),
          ),
          _buildFiltroEstado(),
          Expanded(
            child: pedidosAsync.when(
              data: (pedidos) {
                final pedidosFiltrados = pedidos.where((p) => _perteneceAlPeriodo(p.fechaPedido, _periodoSeleccionado)).toList();
                return _buildListaPedidos(pedidosFiltrados);
              },
              loading: () => _buildLoadingState(),
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
      title: const Text('Pedidos a Proveedores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        PopupMenuButton<int>(
          icon: const Icon(Icons.storefront_rounded, color: Colors.white),
          onSelected: (value) => setState(() => _localDestinoId = value),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 1, child: Text('Local Principal')),
            PopupMenuItem(value: 2, child: Text('Local Secundario')),
          ],
        ),
        IconButton(
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildResumenPedidos(AsyncValue<List<PedidoEntity>> pedidosAsync) {
    final colorScheme = Theme.of(context).colorScheme;
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
            color: colorScheme.surface,
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
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildContadorItem(String label, int count, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FILTRO POR ESTADO
  // ==========================================
  Widget _buildFiltroEstado() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    final List<Map<String, dynamic>> opciones = [
      {'valor': null, 'etiqueta': 'Todos', 'icono': Icons.list_rounded},
      {'valor': EstadoPedido.pendiente, 'etiqueta': 'Pendientes', 'icono': Icons.hourglass_top_rounded},
      {'valor': EstadoPedido.recibido, 'etiqueta': 'Recibidos', 'icono': Icons.check_circle_rounded},
      {'valor': EstadoPedido.cancelado, 'etiqueta': 'Cancelados', 'icono': Icons.cancel_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: opciones.map((opcion) {
              final bool esSeleccionado = _estadoFiltro == opcion['valor'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _estadoFiltro = opcion['valor'];
                    });
                    ref.invalidate(pedidosPorEstadoProvider(
                      (localDestinoId: _localDestinoId ?? 1, estado: _estadoFiltro),
                    ));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 6 : 8,
                      horizontal: isMobile ? 10 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: esSeleccionado ? const Color(0xFF8B5CF6) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          opcion['icono'],
                          size: 16,
                          color: esSeleccionado ? Colors.white : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          opcion['etiqueta'],
                          style: TextStyle(
                            color: esSeleccionado ? Colors.white : colorScheme.onSurfaceVariant,
                            fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.w500,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LISTA DE PEDIDOS CON ANIMACIÓN
  // ==========================================
  Widget _buildListaPedidos(List<PedidoEntity> pedidos) {
    final colorScheme = Theme.of(context).colorScheme;
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
                        // ✅ ABRIR DIÁLOGO DE DETALLE
                        await showDialog(
                          context: context,
                          builder: (_) => DetallePedidoDialog(pedidoId: pedido.id),
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
  // ESTADO VACÍO
  // ==========================================
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
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
            child: const Icon(Icons.inbox_rounded, size: 60, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            _estadoFiltro == null
                ? 'Comienza creando tu primer pedido\npresionando el botón +'
                : 'No hay pedidos en este estado',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6))),
          SizedBox(height: 16),
          Text('Cargando pedidos...', style: TextStyle(color: Colors.grey)),
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
          Text('Error al cargar los pedidos', style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(error.toString(), style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==========================================
  // BOTÓN FLOTANTE (ABRE DIÁLOGO DE CREACIÓN)
  // ==========================================
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (_) => const CrearPedidoDialog(),
        );
        if (result == true) {
          ref.invalidate(pedidosPorEstadoProvider((localDestinoId: _localDestinoId ?? 1, estado: _estadoFiltro)));
          setState(() {});
        }
      },
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }
}