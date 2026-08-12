import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';


final isarServiceProvider = Provider<IsarService>((ref) => IsarService());
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

// ==========================================
// ✅ ESTE ES EL PROVIDER QUE NECESITAS
// ==========================================
final productosParaPedidosProvider = FutureProvider<List<ProductoEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerProductos();
});

// ==========================================
// PROVIDERS PARA PEDIDOS
// ==========================================

final pedidosListProvider = FutureProvider.family<List<PedidoEntity>, int>((ref, localDestinoId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerPedidosPorLocalDestino(localDestinoId);
});

final pedidosPorEstadoProvider = FutureProvider.family<List<PedidoEntity>, ({
  int localDestinoId,
  EstadoPedido? estado
})>((ref, params) async {
  final isar = ref.watch(isarServiceProvider);
  if (params.estado != null) {
    return await isar.obtenerPedidosPorEstado(
      params.estado!,
      localDestinoId: params.localDestinoId,
    );
  } else {
    return await isar.obtenerPedidosPorLocalDestino(params.localDestinoId);
  }
});

// ==========================================
// PROVIDERS PARA ACCIONES
// ==========================================

final crearPedidoProvider = FutureProvider.family<void, ({
  PedidoEntity pedido,
  List<DetallePedidoEntity> detalles
})>((ref, params) async {
  final isar = ref.watch(isarServiceProvider);
  final syncService = ref.watch(syncServiceProvider);

  final pedidoId = await isar.guardarPedido(params.pedido);
  for (var detalle in params.detalles) {
    detalle.pedidoId = pedidoId;
    await isar.guardarDetallePedido(detalle);
  }
  await syncService.sincronizarPedidosPendientes();
});

final registrarRecepcionProvider = FutureProvider.family<void, ({
  int pedidoId,
  int usuarioId,
  String? observaciones
})>((ref, params) async {
  final isar = ref.watch(isarServiceProvider);
  final syncService = ref.watch(syncServiceProvider);

  final recepcion = RecepcionEntity()
    ..pedidoId = params.pedidoId
    ..usuarioId = params.usuarioId
    ..observaciones = params.observaciones
    ..fechaRecepcion = DateTime.now();

  await isar.guardarRecepcion(recepcion);
  await isar.actualizarEstadoPedido(params.pedidoId, EstadoPedido.recibido);
  await syncService.sincronizarPedidosPendientes();
});

final cancelarPedidoProvider = FutureProvider.family<void, int>((ref, pedidoId) async {
  final isar = ref.watch(isarServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  await isar.actualizarEstadoPedido(pedidoId, EstadoPedido.cancelado);
  await syncService.sincronizarPedidosPendientes();
});

final proveedoresActivosProvider = FutureProvider<List<ProveedorEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerProveedores(soloActivos: true);
});
