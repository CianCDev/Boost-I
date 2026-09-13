// lib/features/pos/presentation/screens/pedido/pedidos_screen.dart
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/crear_pedido_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_pedido_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/pedido_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import '../../providers/pedidos_provider.dart';
import '../../providers/locales_provider.dart';
import '../../providers/local_actual_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../../data/Local/entities/local_entity.dart';
import '../../widgets/pedidos/pedido_filtro.dart';

class PedidosProveedorScreen extends ConsumerStatefulWidget {
  const PedidosProveedorScreen({super.key});

  @override
  ConsumerState<PedidosProveedorScreen> createState() =>
      _PedidosProveedorScreenState();
}

class _PedidosProveedorScreenState extends ConsumerState<PedidosProveedorScreen>
    with SingleTickerProviderStateMixin {
  EstadoFiltroPedido _estadoFiltro = EstadoFiltroPedido.todos;
  PeriodoPedido _periodo = PeriodoPedido.todas;
  String? _localDestinoUuid;

  late AnimationController _animationController;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTRADO
  // ============================================================
  bool _perteneceAlPeriodo(DateTime fecha) {
    final now = DateTime.now();
    final fechaLocal = fecha.toLocal();
    final fechaDia =
        DateTime(fechaLocal.year, fechaLocal.month, fechaLocal.day);
    final hoy = DateTime(now.year, now.month, now.day);

    switch (_periodo) {
      case PeriodoPedido.hoy:
        return fechaDia.isAtSameMomentAs(hoy);
      case PeriodoPedido.semana:
        final inicioSemana = hoy.subtract(Duration(days: now.weekday - 1));
        final finSemana = inicioSemana.add(const Duration(days: 6));
        return (fechaDia.isAtSameMomentAs(inicioSemana) ||
                fechaDia.isAfter(inicioSemana)) &&
            (fechaDia.isAtSameMomentAs(finSemana) ||
                fechaDia.isBefore(finSemana));
      case PeriodoPedido.mes:
        return fechaLocal.year == now.year && fechaLocal.month == now.month;
      case PeriodoPedido.anio:
        return fechaLocal.year == now.year;
      case PeriodoPedido.todas:
        return true;
    }
  }

  bool _perteneceAlEstado(EstadoPedido estado) {
    switch (_estadoFiltro) {
      case EstadoFiltroPedido.todos:
        return true;
      case EstadoFiltroPedido.pendiente:
        return estado == EstadoPedido.pendiente;
      case EstadoFiltroPedido.recibido:
        return estado == EstadoPedido.recibido;
      case EstadoFiltroPedido.cancelado:
        return estado == EstadoPedido.cancelado;
    }
  }

  List<PedidoEntity> _filtrarPedidos(List<PedidoEntity> todos) {
    return todos
        .where((p) =>
            _perteneceAlPeriodo(p.fechaPedido) &&
            _perteneceAlEstado(p.estado))
        .toList();
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Pedidos a Proveedores',
        showBackButton: true,
        centerTitle: false,
        actions: [
          _buildLocalSelector(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: () {
                if (_localDestinoUuid != null) {
                  ref.invalidate(pedidosListProvider(_localDestinoUuid!));
                  setState(() {});
                  _animationController.forward(from: 0.0);
                }
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Recargar',
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_localDestinoUuid != null) _buildFiltrosSection(),
              const SizedBox(height: 12),
              Expanded(child: _buildPedidosList(colorScheme)),
            ],
          ),
        ),
      ),
      floatingActionButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => const CrearPedidoDialog(),
            );
            if (result == true) {
              if (_localDestinoUuid != null) {
                ref.invalidate(pedidosListProvider(_localDestinoUuid!));
              }
              setState(() {});
              _animationController.forward(from: 0.0);
            }
          },
          backgroundColor: _colorPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }

  // ============================================================
  // SELECTOR DE LOCAL
  // ============================================================
  Widget _buildLocalSelector() {
    return Consumer(
      builder: (context, ref, child) {
        final localesAsync = ref.watch(localesProvider);
        return localesAsync.when(
          data: (locales) {
            if (locales.isEmpty) {
              return const Icon(Icons.storefront_rounded,
                  color: Colors.white);
            }
            if (_localDestinoUuid == null && locales.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _localDestinoUuid = locales.first.supabaseId);
                }
              });
            }
            return PopupMenuButton<String>(
              icon: const Icon(Icons.storefront_rounded, color: Colors.white),
              tooltip: 'Seleccionar local',
              onSelected: (value) async {
                setState(() => _localDestinoUuid = value);
                ref.invalidate(pedidosListProvider(value));

                final localEncontrado = locales.firstWhere(
                  (l) => l.supabaseId == value,
                  orElse: () => LocalEntity(),
                );
                if (localEncontrado.id != 0) {
                  await ref
                      .read(localActualProvider.notifier)
                      .setLocalActual(localEncontrado.id);
                }
              },
              itemBuilder: (context) {
                return locales.map((local) {
                  final isSelected = _localDestinoUuid == local.supabaseId;
                  return PopupMenuItem<String>(
                    value: local.supabaseId,
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
          loading: () => const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ),
          ),
          error: (_, __) =>
              const Icon(Icons.error_outline, color: Colors.white),
        );
      },
    );
  }

  // ============================================================
  // SECCIÓN DE FILTROS + MÉTRICAS
  // ============================================================
  Widget _buildFiltrosSection() {
    final pedidosAsync = ref.watch(pedidosListProvider(_localDestinoUuid!));

    return pedidosAsync.when(
      data: (todos) {
        final porPeriodo =
            todos.where((p) => _perteneceAlPeriodo(p.fechaPedido)).toList();
        final total = porPeriodo.length;
        final pendientes =
            porPeriodo.where((p) => p.estado == EstadoPedido.pendiente).length;
        final recibidos =
            porPeriodo.where((p) => p.estado == EstadoPedido.recibido).length;
        final cancelados =
            porPeriodo.where((p) => p.estado == EstadoPedido.cancelado).length;

        return PedidosFiltros(
          total: total,
          pendientes: pendientes,
          recibidos: recibidos,
          cancelados: cancelados,
          periodoActual: _periodo,
          estadoActual: _estadoFiltro,
          onPeriodoChanged: (p) {
            setState(() => _periodo = p);
            _animationController.forward(from: 0.0);
          },
          onEstadoChanged: (e) {
            setState(() => _estadoFiltro = e);
            _animationController.forward(from: 0.0);
          },
        );
      },
      loading: () => const SizedBox(height: 120),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ============================================================
  // LISTA DE PEDIDOS
  // ============================================================
  Widget _buildPedidosList(ColorScheme colorScheme) {
    if (_localDestinoUuid == null) {
      return _buildEmptyState(
        titulo: 'Selecciona un local',
        subtitulo: 'Elige un local para ver sus pedidos',
        icono: Icons.storefront_rounded,
        colorScheme: colorScheme,
      );
    }

    final pedidosAsync = ref.watch(pedidosListProvider(_localDestinoUuid!));

    return pedidosAsync.when(
      data: (todos) {
        final pedidosFiltrados = _filtrarPedidos(todos);

        if (pedidosFiltrados.isEmpty) {
          return _buildEmptyState(
            titulo: 'No hay pedidos',
            subtitulo: _estadoFiltro == EstadoFiltroPedido.todos
                ? 'Comienza creando tu primer pedido'
                : 'No hay pedidos en este estado',
            icono: Icons.inbox_rounded,
            colorScheme: colorScheme,
            accion: _estadoFiltro != EstadoFiltroPedido.todos
                ? TextButton.icon(
                    onPressed: () => setState(
                        () => _estadoFiltro = EstadoFiltroPedido.todos),
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    label: const Text('Ver todos'),
                    style: TextButton.styleFrom(
                      foregroundColor: _colorPrimary,
                    ),
                  )
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pedidosListProvider(_localDestinoUuid!));
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              setState(() {});
              _animationController.forward(from: 0.0);
            }
          },
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: pedidosFiltrados.length,
              itemBuilder: (context, index) {
                final pedido = pedidosFiltrados[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 30,
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
                              builder: (_) =>
                                  DetallePedidoDialog(pedidoId: pedido.id),
                            );
                            if (mounted) setState(() {});
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
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _colorPrimary),
            SizedBox(height: 16),
            Text('Cargando pedidos...'),
          ],
        ),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 60, color: _colorDanger),
            const SizedBox(height: 16),
            Text('Error al cargar los pedidos',
                style: TextStyle(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(err.toString(),
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================
  Widget _buildEmptyState({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required ColorScheme colorScheme,
    Widget? accion,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 40, color: _colorPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (accion != null) ...[
            const SizedBox(height: 12),
            accion,
          ],
        ],
      ),
    );
  }
}