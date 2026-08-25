import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/info_pedido.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalles_list.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/info_recepcion.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/acciones_pedido.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class DetallePedidoDialog extends ConsumerStatefulWidget {
  final int pedidoId;

  const DetallePedidoDialog({super.key, required this.pedidoId});

  @override
  ConsumerState<DetallePedidoDialog> createState() => _DetallePedidoDialogState();
}

class _DetallePedidoDialogState extends ConsumerState<DetallePedidoDialog> {
  late Future<PedidoEntity?> _pedidoFuture;
  late Future<List<DetallePedidoEntity>> _detallesFuture;
  late Future<RecepcionEntity?> _recepcionFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final isar = ref.read(isarServiceProvider);
    _pedidoFuture = isar.obtenerPedidoPorId(widget.pedidoId);
    _detallesFuture = isar.obtenerDetallesPorPedido(widget.pedidoId);
    _recepcionFuture = isar.obtenerRecepcionPorPedido(widget.pedidoId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ignore: unused_local_variable
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FutureBuilder(
          future: Future.wait([_pedidoFuture, _detallesFuture, _recepcionFuture]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encontró el pedido'));
            }

            final pedido = snapshot.data![0] as PedidoEntity?;
            if (pedido == null) {
              return const Center(child: Text('Pedido no encontrado'));
            }
            final detalles = snapshot.data![1] as List<DetallePedidoEntity>;
            final recepcion = snapshot.data![2] as RecepcionEntity?;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: const Color(0xFF8B5CF6), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Detalle del Pedido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                // CONTENIDO CON SCROLL
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoPedido(pedido: pedido),
                        const SizedBox(height: 16),
                        DetallesList(detalles: detalles),
                        if (recepcion != null) ...[
                          const SizedBox(height: 16),
                          InfoRecepcion(recepcion: recepcion),
                        ],
                        const SizedBox(height: 16),
                        AccionesPedido(
                          pedido: pedido,
                          onActualizar: () {
                            setState(() => _cargarDatos());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}