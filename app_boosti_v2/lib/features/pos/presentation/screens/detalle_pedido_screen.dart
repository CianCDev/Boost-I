import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import '../widgets/pedidos/info_ pedido.dart';
import '../widgets/pedidos/detalles_list.dart';
import '../widgets/pedidos/info_recepcion.dart';
import '../widgets/pedidos/acciones_pedido.dart';

class DetallePedidoProveedorScreen extends ConsumerStatefulWidget {
  final int pedidoId;

  const DetallePedidoProveedorScreen({super.key, required this.pedidoId});

  @override
  ConsumerState<DetallePedidoProveedorScreen> createState() => _DetallePedidoProveedorScreenState();
}

class _DetallePedidoProveedorScreenState extends ConsumerState<DetallePedidoProveedorScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _cargarDatos()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([_pedidoFuture, _detallesFuture, _recepcionFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final pedido = snapshot.data![0] as PedidoEntity?;
            if (pedido == null) {
              return const Center(child: Text('Pedido no encontrado'));
            }
            final detalles = snapshot.data![1] as List<DetallePedidoEntity>;
            final recepcion = snapshot.data![2] as RecepcionEntity?;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoPedido(pedido: pedido),
                  const Divider(),
                  DetallesList(detalles: detalles),
                  const Divider(),
                  if (recepcion != null) InfoRecepcion(recepcion: recepcion),
                  const SizedBox(height: 16),
                  AccionesPedido(
                    pedido: pedido,
                    onActualizar: () => setState(() => _cargarDatos()),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No hay datos'));
        },
      ),
    );
  }
}