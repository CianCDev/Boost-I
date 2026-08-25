import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';

// NUEVO: Import para entidades de lotes
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';

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

// ==========================================
// NUEVO: registrarRecepcionProvider MODIFICADO para crear lotes
// ==========================================
final registrarRecepcionProvider = FutureProvider.family<void, ({
  int pedidoId,
  int usuarioId,
  String? observaciones,
  // NUEVO: Parámetro opcional para fecha de vencimiento por producto
  Map<int, DateTime?>? fechasVencimiento,
  // NUEVO: Parámetro opcional para costo unitario por producto
  Map<int, double?>? costosUnitarios,
})>((ref, params) async {
  final isar = ref.watch(isarServiceProvider);
  final syncService = ref.watch(syncServiceProvider);

  // 1. Obtener los detalles del pedido
  final detalles = await isar.obtenerDetallesPorPedido(params.pedidoId);
  if (detalles.isEmpty) {
    throw Exception('El pedido no tiene productos para recibir');
  }

  // 2. Crear la recepción
  final recepcion = RecepcionEntity()
    ..pedidoId = params.pedidoId
    ..usuarioId = params.usuarioId
    ..observaciones = params.observaciones
    ..fechaRecepcion = DateTime.now();

  await isar.guardarRecepcion(recepcion);

  // 3. Procesar cada detalle: crear lotes
  for (var detalle in detalles) {
    final producto = await isar.obtenerProductoPorId(detalle.productoId);
    if (producto == null) {
      debugPrint('⚠️ Producto ${detalle.productoId} no encontrado, omitiendo...');
      continue;
    }

    // NUEVO: Determinar la cantidad a ingresar (en unidades base)
    // Si el detalle tiene un alias (factor), ya debería estar convertido
    // Por ahora, asumimos que la cantidad del detalle está en unidades base
    final double cantidad = detalle.cantidad;

    // NUEVO: Obtener fecha de vencimiento si se proporcionó
    DateTime? fechaVencimiento;
    if (params.fechasVencimiento != null && params.fechasVencimiento!.containsKey(detalle.productoId)) {
      fechaVencimiento = params.fechasVencimiento![detalle.productoId];
    }

    // NUEVO: Obtener costo unitario si se proporcionó
    double? costoUnitario;
    if (params.costosUnitarios != null && params.costosUnitarios!.containsKey(detalle.productoId)) {
      costoUnitario = params.costosUnitarios![detalle.productoId];
    }

    // NUEVO: Crear el lote
    final nuevoLote = LoteEntity()
      ..productoId = detalle.productoId
      ..cantidadInicial = cantidad
      ..cantidadRestante = cantidad
      ..fechaIngreso = DateTime.now()
      ..fechaVencimiento = fechaVencimiento
      ..estado = 'activo'
      ..costoUnitario = costoUnitario
      ..sincronizado = false;

    await isar.guardarLote(nuevoLote);
  }

  // 4. Actualizar estado del pedido
  await isar.actualizarEstadoPedido(params.pedidoId, EstadoPedido.recibido);

  // 5. Sincronizar
  await syncService.sincronizarPedidosPendientes();

  // NUEVO: Sincronizar lotes pendientes
  await syncService.sincronizarLotesPendientes();
});

// ==========================================
// NUEVO: Provider para obtener lotes de un producto
// ==========================================
final lotesPorProductoProvider = FutureProvider.family<List<LoteEntity>, int>((ref, productoId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerLotesActivos(productoId);
});

// ==========================================
// NUEVO: Provider para obtener stock total de un producto (desde lotes)
// ==========================================
final stockTotalProductoProvider = FutureProvider.family<double, int>((ref, productoId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerStockTotalPorProducto(productoId);
});

// ==========================================
// Provider existente (sin cambios)
// ==========================================
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