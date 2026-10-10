// ignore_for_file: unused_local_variable

// PASO 2.2 · P1 · Eliminada la clase `PedidosProveedorScreen` (y las clases
// privadas `_PedidosProveedorScreenState`, `_EstadoChip`, `_EstadoChipState`)
// que vivían duplicadas en este archivo. La versión vigente de esa pantalla
// es `screens/pedido/pedidos_screen.dart`, que es la que importa
// `menu_config.dart` y `main_pos_screen.dart`.
//
// Restaurable con una `mv` desde el `.bak` si algo hiciera falta.
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/sync_provider.dart'
    as sync;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// ✅ CORREGIDO: Usa String (UUID) para filtrar por local
// ✅ CORREGIDO: Filtra por el local destino usando el UUID
final pedidosListProvider = FutureProvider.family<List<PedidoEntity>, String>(
    (ref, localDestinoUuid) async {
  final isar = ref.watch(isarServiceProvider);

  // 1. Obtener el local correspondiente al UUID
  final local = await isar.obtenerLocalPorSupabaseId(localDestinoUuid);
  if (local == null) {
    // Si no se encuentra el local, devolver lista vacía
    return [];
  }

  // 2. Obtener pedidos de todos los estados para ese local destino
  final pendientes = await isar.obtenerPedidosPorEstado(EstadoPedido.pendiente,
      localDestinoId: local.id);
  final recibidos = await isar.obtenerPedidosPorEstado(EstadoPedido.recibido,
      localDestinoId: local.id);
  final cancelados = await isar.obtenerPedidosPorEstado(EstadoPedido.cancelado,
      localDestinoId: local.id);

  return [...pendientes, ...recibidos, ...cancelados];
});

final cancelarPedidoProvider =
    FutureProvider.family<void, int>((ref, pedidoId) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.cancelarPedido(pedidoId);
  ref.invalidate(pedidosListProvider);
});

final registrarRecepcionProvider = FutureProvider.family<
    void,
    ({
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
    ..observaciones =
        datos.observaciones.trim().isEmpty ? null : datos.observaciones.trim()
    ..sincronizado = false;

  await isar.guardarRecepcion(recepcion);
  await isar.actualizarEstadoPedido(datos.pedidoId, EstadoPedido.recibido);
  await isar.actualizarSyncStatusPedido(datos.pedidoId, false);

  // ✅ CREAR LOTES
  for (var detalle in detalles) {
    final proveedorUuid =
        await isar.obtenerSupabaseIdProveedorPorNombre(pedido.proveedorNombre);

    final lote = LoteEntity()
      ..productoId = detalle.productoId
      ..localId = pedido.localOrigenId
      ..cantidadInicial = detalle.cantidad
      ..cantidadRestante = detalle.cantidad
      ..fechaIngreso = DateTime.now()
      ..fechaVencimiento = datos.fechasVencimiento?[detalle.productoId]
      ..costoUnitario =
          datos.costosUnitarios?[detalle.productoId] ?? detalle.precioUnidad
      ..estado = 'pendiente'
      ..proveedorId = proveedorUuid // ✅ UUID válido o null
      ..proveedorNombre =
          pedido.proveedorNombre // ✅ El nombre sigue siendo útil para mostrar
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

final proveedoresActivosProvider =
    FutureProvider<List<ProveedorEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return isar.obtenerProveedores(soloActivos: true);
});