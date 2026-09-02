// ignore_for_file: unused_local_variable

import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/crear_pedido_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_pedido_dialog.dart';
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
  late Animation<double> _fadeAnimation;

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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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

  // ==========================================
  // FILTROS EN MEMORIA
  // ==========================================
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

  List<PedidoEntity> _filtrarPedidos(List<PedidoEntity> todos) {
    var filtrados = todos;

    // Filtro por estado
    if (_estadoFiltro != null) {
      filtrados = filtrados.where((p) => p.estado == _estadoFiltro).toList();
    }

    // Filtro por período
    filtrados = filtrados
        .where((p) => _perteneceAlPeriodo(p.fechaPedido, _periodoSeleccionado))
        .toList();

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    final localDestinoId = _localDestinoId ?? 1;
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    // 🔥 Usamos pedidosListProvider (sin filtro de estado) para evitar recarga al cambiar filtro
    final pedidosAsync = ref.watch(pedidosListProvider(localDestinoId));

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
              data: (todos) {
                final pedidosFiltrados = _filtrarPedidos(todos);
                return _buildContent(pedidosFiltrados);
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

  // ==========================================
  // CONTENIDO CON ANIMACIÓN DE ENTRADA
  // ==========================================
  Widget _buildContent(List<PedidoEntity> pedidos) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey('pedidos_${_estadoFiltro?.name ?? 'todos'}_${pedidos.length}'),
          child: _buildListaPedidos(pedidos),
        ),
      ),
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
          onPressed: () {
            // Recargar forzado: invalidar provider y reiniciar animación
            ref.invalidate(pedidosListProvider(_localDestinoId ?? 1));
            setState(() {});
            _animationController.forward(from: 0.0);
          },
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildResumenPedidos(AsyncValue<List<PedidoEntity>> pedidosAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    return pedidosAsync.when(
      data: (todos) {
        final pedidos = _filtrarPedidos(todos);
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
      error: (err, stack) => const SizedBox.shrink(),
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
  // FILTRO POR ESTADO (CON HOVER Y ANIMACIÓN)
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
                child: _EstadoChip(
                  key: ValueKey(opcion['etiqueta']),
                  selected: esSeleccionado,
                  icon: opcion['icono'],
                  label: opcion['etiqueta'],
                  onTap: () {
                    setState(() {
                      _estadoFiltro = opcion['valor'];
                    });
                    // Reiniciamos la animación al cambiar de filtro
                    _animationController.forward(from: 0.0);
                  },
                  isMobile: isMobile,
                  colorScheme: colorScheme,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LISTA DE PEDIDOS CON ANIMACIÓN ESCALONADA
  // ==========================================
  Widget _buildListaPedidos(List<PedidoEntity> pedidos) {
    if (pedidos.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Recargar datos desde la nube/local
        ref.invalidate(pedidosListProvider(_localDestinoId ?? 1));
        // Esperar a que se recargue
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {});
        _animationController.forward(from: 0.0);
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
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
  // BOTÓN FLOTANTE
  // ==========================================
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (_) => const CrearPedidoDialog(),
        );
        if (result == true) {
          // Recargar datos después de crear un pedido
          ref.invalidate(pedidosListProvider(_localDestinoId ?? 1));
          setState(() {});
          _animationController.forward(from: 0.0);
        }
      },
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }
}

// ==========================================
// CHIP DE ESTADO (CON HOVER Y ANIMACIÓN)
// ==========================================
class _EstadoChip extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isMobile;
  final ColorScheme colorScheme;

  const _EstadoChip({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isMobile,
    required this.colorScheme,
  });

  @override
  State<_EstadoChip> createState() => _EstadoChipState();
}

class _EstadoChipState extends State<_EstadoChip> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final isMobile = widget.isMobile;

    final double fontSize = isMobile ? 12 : 14;
    final double iconSize = isMobile ? 16 : 18;
    final double verticalPadding = isMobile ? 6 : 8;
    final double horizontalPadding = isMobile ? 10 : 16;
    final double borderRadius = isMobile ? 8 : 12;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: widget.selected ? const Color(0xFF8B5CF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFF8B5CF6)
                  : (isHovering
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.5)
                      : colorScheme.outline.withValues(alpha: 0.3)),
              width: widget.selected ? 1.5 : 1.0,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: iconSize,
                color: widget.selected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: widget.selected ? FontWeight.bold : FontWeight.w500,
                  color: widget.selected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}