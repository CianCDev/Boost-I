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
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class DetallePedidoDialog extends ConsumerStatefulWidget {
  final int pedidoId;

  const DetallePedidoDialog({super.key, required this.pedidoId});

  @override
  ConsumerState<DetallePedidoDialog> createState() =>
      _DetallePedidoDialogState();
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 700,
      maxHeightFactor: 0.9,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: FutureBuilder(
          future: Future.wait(
              [_pedidoFuture, _detallesFuture, _recepcionFuture]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            // Header siempre visible
            final header = const DialogHeader(
              icon: Icons.receipt_long_rounded,
              title: 'Detalle del Pedido',
              subtitle: 'Revisa y gestiona el pedido',
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 40),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 40),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 60, color: colorScheme.error),
                        const SizedBox(height: 12),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 32),
                  const Center(child: Text('No se encontró el pedido')),
                ],
              );
            }

            final pedido = snapshot.data![0] as PedidoEntity?;
            if (pedido == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 32),
                  const Center(child: Text('Pedido no encontrado')),
                ],
              );
            }

            final detalles = snapshot.data![1] as List<DetallePedidoEntity>;
            final recepcion = snapshot.data![2] as RecepcionEntity?;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 16),
                Flexible(
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
                            if (mounted) setState(() => _cargarDatos());
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