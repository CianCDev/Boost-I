import 'dart:ui';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 700,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 60, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  );
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
                    _buildHeader(isDark, isMobile),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
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
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Detalle del Pedido',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 22,
              color: isDark ? Colors.white : const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}