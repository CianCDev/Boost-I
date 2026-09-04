// ignore_for_file: unused_local_variable

import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/crear_pedido_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_pedido_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/pedido_card.dart';
import '../providers/sync_provider.dart' as sync;
import '../providers/lotes_provider.dart';
import '../providers/locales_provider.dart';
import '../widgets/sales/sales_history_filter_bar.dart';
import '../utils/responsive_helper.dart';
import '../widgets/appbar.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// ✅ CORREGIDO: Usa String (UUID) para filtrar por local
// ✅ CORREGIDO: Filtra por el local destino usando el UUID
final pedidosListProvider = FutureProvider.family<List<PedidoEntity>, String>((ref, localDestinoUuid) async {
  final isar = ref.watch(isarServiceProvider);
  
  // 1. Obtener el local correspondiente al UUID
  final local = await isar.obtenerLocalPorSupabaseId(localDestinoUuid);
  if (local == null) {
    // Si no se encuentra el local, devolver lista vacía
    return [];
  }
  
  // 2. Obtener pedidos de todos los estados para ese local destino
  final pendientes = await isar.obtenerPedidosPorEstado(EstadoPedido.pendiente, localDestinoId: local.id);
  final recibidos = await isar.obtenerPedidosPorEstado(EstadoPedido.recibido, localDestinoId: local.id);
  final cancelados = await isar.obtenerPedidosPorEstado(EstadoPedido.cancelado, localDestinoId: local.id);
  
  return [...pendientes, ...recibidos, ...cancelados];
});

final cancelarPedidoProvider = FutureProvider.family<void, int>((ref, pedidoId) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.cancelarPedido(pedidoId);
  ref.invalidate(pedidosListProvider);
});

final registrarRecepcionProvider = FutureProvider.family<void, ({
  int pedidoId,
  int usuarioId,
  String observaciones,
  Map<int, DateTime>? fechasVencimiento,
  Map<int, double>? costosUnitarios,
})>((ref, datos) async {
  final isar = ref.watch(isarServiceProvider);

  final pedido = await isar.obtenerPedidoPorId(datos.pedidoId);
  if (pedido == null) {
    throw Exception('Pedido no encontrado');
  }

  final detalles = await isar.obtenerDetallesPorPedido(datos.pedidoId);
  if (detalles.isEmpty) {
    throw Exception('El pedido no tiene productos');
  }

  final recepcion = RecepcionEntity()
    ..pedidoId = datos.pedidoId
    ..fechaRecepcion = DateTime.now()
    ..usuarioId = datos.usuarioId
    ..observaciones = datos.observaciones.trim().isEmpty
        ? null
        : datos.observaciones.trim()
    ..sincronizado = false;

  await isar.guardarRecepcion(recepcion);
  await isar.actualizarEstadoPedido(datos.pedidoId, EstadoPedido.recibido);
  await isar.actualizarSyncStatusPedido(datos.pedidoId, false);

  // ✅ CREAR LOTES
  for (var detalle in detalles) {
    final lote = LoteEntity()
      ..productoId = detalle.productoId
      ..cantidadInicial = detalle.cantidad
      ..cantidadRestante = detalle.cantidad
      ..fechaIngreso = DateTime.now()
      ..fechaVencimiento = datos.fechasVencimiento?[detalle.productoId]
      ..costoUnitario = datos.costosUnitarios?[detalle.productoId] ?? detalle.precioUnidad
      ..estado = 'pendiente'
      ..sincronizado = false;

    await isar.guardarLote(lote);

    await isar.guardarMovimientoLote(
      MovimientoLoteEntity()
        ..loteId = lote.id
        ..tipo = 'recepcion'
        ..cantidad = detalle.cantidad
        ..fecha = DateTime.now()
        ..usuarioId = datos.usuarioId
        ..observaciones = 'Lote creado desde recepción de pedido ${pedido.id}'
        ..sincronizado = false,
    );
  }

  ref.invalidate(pedidosListProvider);
  ref.invalidate(lotesProvider);
});

final syncServiceProvider = sync.syncServiceProvider;

final proveedoresActivosProvider = FutureProvider<List<ProveedorEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return isar.obtenerProveedores(soloActivos: true);
});

// ============================================================
// PANTALLA DE PEDIDOS (ahora usa pedidosListProvider con UUID)
// ============================================================

class PedidosProveedorScreen extends ConsumerStatefulWidget {
  const PedidosProveedorScreen({super.key});

  @override
  ConsumerState<PedidosProveedorScreen> createState() => _PedidosProveedorScreenState();
}

class _PedidosProveedorScreenState extends ConsumerState<PedidosProveedorScreen>
    with SingleTickerProviderStateMixin {
  EstadoPedido? _estadoFiltro;
  String? _localDestinoUuid; // ✅ UUID
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

    if (_estadoFiltro != null) {
      filtrados = filtrados.where((p) => p.estado == _estadoFiltro).toList();
    }

    filtrados = filtrados
        .where((p) => _perteneceAlPeriodo(p.fechaPedido, _periodoSeleccionado))
        .toList();

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final localesAsync = ref.watch(localesProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF0F4F8),
      appBar: CustomAppBar(
        title: 'Pedidos a Proveedores',
        showBackButton: true,
        centerTitle: false,
        actions: [
          // ✅ POPUPMENU DINÁMICO CON LOCALES REALES
          Consumer(
            builder: (context, ref, child) {
              final localesAsync = ref.watch(localesProvider);
              return localesAsync.when(
                data: (locales) {
                  if (locales.isEmpty) {
                    return const Icon(Icons.storefront_rounded, color: Colors.white);
                  }
                  if (_localDestinoUuid == null && locales.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _localDestinoUuid = locales.first.supabaseId;
                      });
                    });
                  }
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.storefront_rounded, color: Colors.white),
                    onSelected: (value) {
                      setState(() => _localDestinoUuid = value);
                      ref.invalidate(pedidosListProvider(value));
                    },
                    itemBuilder: (context) {
                      return locales.map((local) {
                        final isSelected = _localDestinoUuid == local.supabaseId;
                        return PopupMenuItem<String>(
                          value: local.supabaseId,
                          child: Row(
                            children: [
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                ),
                error: (err, stack) => const Icon(Icons.error_outline, color: Colors.white),
              );
            },
          ),
          IconButton(
            onPressed: () {
              if (_localDestinoUuid != null) {
                ref.invalidate(pedidosListProvider(_localDestinoUuid!));
                setState(() {});
                _animationController.forward(from: 0.0);
              }
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
          // ✅ BOTÓN PARA FORZAR DESCARGA DE PEDIDOS DESDE SUPABASE
          IconButton(
            onPressed: () async {
              try {
                final syncService = ref.read(syncServiceProvider);
                await syncService.descargarPedidosDesdeSupabase();
                if (_localDestinoUuid != null) {
                  ref.invalidate(pedidosListProvider(_localDestinoUuid!));
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Pedidos sincronizados desde la nube'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error al sincronizar pedidos: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.cloud_download_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildResumenPedidos(isDark),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.zero,
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
              const SizedBox(height: 8),
              _buildFiltroEstado(colorScheme, isDark, isMobile),
              const SizedBox(height: 8),
              Expanded(
                child: _buildPedidosList(isDark, colorScheme),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildResumenPedidos(bool isDark) {
    if (_localDestinoUuid == null) {
      return const SizedBox.shrink();
    }
    final pedidosAsync = ref.watch(pedidosListProvider(_localDestinoUuid!));
    return pedidosAsync.when(
      data: (todos) {
        final pedidos = _filtrarPedidos(todos);
        final total = pedidos.length;
        final pendientes = pedidos.where((p) => p.estado == EstadoPedido.pendiente).length;
        final recibidos = pedidos.where((p) => p.estado == EstadoPedido.recibido).length;
        final cancelados = pedidos.where((p) => p.estado == EstadoPedido.cancelado).length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildContadorItem('Total', total, const Color(0xFF8B5CF6), isDark),
              _buildContadorItem('Pendientes', pendientes, Colors.orange.shade600, isDark),
              _buildContadorItem('Recibidos', recibidos, Colors.green.shade600, isDark),
              _buildContadorItem('Cancelados', cancelados, Colors.red.shade600, isDark),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildContadorItem(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroEstado(ColorScheme colorScheme, bool isDark, bool isMobile) {
    final List<Map<String, dynamic>> opciones = [
      {'valor': null, 'etiqueta': 'Todos', 'icono': Icons.list_rounded},
      {'valor': EstadoPedido.pendiente, 'etiqueta': 'Pendientes', 'icono': Icons.hourglass_top_rounded},
      {'valor': EstadoPedido.recibido, 'etiqueta': 'Recibidos', 'icono': Icons.check_circle_rounded},
      {'valor': EstadoPedido.cancelado, 'etiqueta': 'Cancelados', 'icono': Icons.cancel_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(6),
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
                  _animationController.forward(from: 0.0);
                },
                isMobile: isMobile,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPedidosList(bool isDark, ColorScheme colorScheme) {
    if (_localDestinoUuid == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Selecciona un local',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      );
    }

    final pedidosAsync = ref.watch(pedidosListProvider(_localDestinoUuid!));

    return pedidosAsync.when(
      data: (todos) {
        final pedidosFiltrados = _filtrarPedidos(todos);
        if (pedidosFiltrados.isEmpty) {
          return _buildEmptyState(isDark);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pedidosListProvider(_localDestinoUuid!));
            await Future.delayed(const Duration(milliseconds: 300));
            setState(() {});
            _animationController.forward(from: 0.0);
          },
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: pedidosFiltrados.length,
              itemBuilder: (context, index) {
                final pedido = pedidosFiltrados[index];
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
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6))),
            SizedBox(height: 16),
            Text('Cargando pedidos...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      error: (err, stack) => _buildErrorState(err, colorScheme),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, size: 40, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _estadoFiltro == null
                ? 'Comienza creando tu primer pedido'
                : 'No hay pedidos en este estado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          if (_estadoFiltro != null)
            ElevatedButton.icon(
              onPressed: () => setState(() => _estadoFiltro = null),
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Ver todos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Text('Error al cargar los pedidos', style: TextStyle(color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(error.toString(), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
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
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }
}

class _EstadoChip extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isMobile;
  final ColorScheme colorScheme;
  final bool isDark;

  const _EstadoChip({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isMobile,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  State<_EstadoChip> createState() => _EstadoChipState();
}

class _EstadoChipState extends State<_EstadoChip> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.isMobile;
    final double iconSize = isMobile ? 14 : 18;
    final double fontSize = isMobile ? 10 : 14;
    final double paddingHoriz = isMobile ? 6 : 16;
    final double paddingVert = isMobile ? 4 : 8;
    final double borderRadius = isMobile ? 8 : 12;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: paddingVert, horizontal: paddingHoriz),
          decoration: BoxDecoration(
            color: widget.selected ? const Color(0xFF8B5CF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFF8B5CF6)
                  : (isHovering
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.5)
                      : (widget.isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB))),
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
                color: widget.selected ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 4),
              Text(
                isMobile ? widget.label.substring(0, 1) : widget.label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: widget.selected ? FontWeight.bold : FontWeight.w500,
                  color: widget.selected ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}