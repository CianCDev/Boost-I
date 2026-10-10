import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/gasto_anulado_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/venta_anulada_entity.dart';
import 'error_service.dart';

/// Servicio que orquesta la anulación de ventas y gastos.
///
/// Principios:
///   1. Nunca edita ni elimina el registro original.
///   2. Crea contra-registros (VentaAnuladaEntity, GastoAnuladoEntity).
///   3. Ajusta el stock con un movimiento inverso (nuevo registro).
///   4. Registra todo en `LogEntity`.
class VentaAnulacionService {
  final IsarService _isar = IsarService();

  /// Anula una venta por completo.
  ///
  /// Pasos:
  ///   1. Crea `VentaAnuladaEntity`.
  ///   2. Por cada detalle de la venta, crea un `MovimientoInventarioEntity`
  ///      de contra (signo invertido).
  ///   3. Actualiza el stock del producto (guardar producto con stock
  ///      restaurado — el producto SÍ es editable).
  ///   4. Registra log.
  Future<bool> anularVenta({
    required String ventaIdOriginal,
    required String tenantId,
    required String motivo,
    required UsuarioEntity usuario,
    required double montoOriginal,
  }) async {
    try {
      // 1. Registrar la anulación
      final anulacion = VentaAnuladaEntity()
        ..ventaIdOriginal = ventaIdOriginal
        ..tenantId = tenantId
        ..motivo = motivo
        ..usuarioId = usuario.id
        ..usuarioNombre = usuario.nombre
        ..usuarioRol = usuario.rol
        ..fechaAnulacion = DateTime.now()
        ..montoOriginal = montoOriginal;

      await _isar.guardarVentaAnulada(anulacion);

      // 2. Ajustar stock por cada detalle
      final detalles = await _isar.obtenerDetallesPorVenta(ventaIdOriginal);
      final productosAfectados = <int>{};
      for (final detalle in detalles) {
        final productoIdInt = detalle.productoId ?? 0;
        if (productoIdInt <= 0) continue;
        final producto = await _isar.obtenerProductoPorId(productoIdInt);
        if (producto == null) continue;

        // ⚠️ Devolver a un LOTE, no a `producto.stock` (lotes = fuente
        // única de verdad). Antes se hacía
        // `producto.stock = stockAntes + detalle.cantidad`, una
        // aritmética ciega a los lotes: devolvía unidades al producto
        // pero NO al lote que las había entregado, así que los lotes
        // seguían descontados de forma permanente.
        //
        // Si el detalle tiene `loteIdIsar` (mayorista lo registra en
        // `venta_mayor_service:432`), se devuelve a ese lote. Si no
        // (retail: el bucle FEFO de `procesarVenta` no registra qué
        // lotes tocó), se crea un lote de devolución explícito.
        final loteId = detalle.loteIdIsar;
        if (loteId != null) {
          await _isar.devolverALote(loteId, detalle.cantidad);
        } else {
          await _isar.crearLoteDevolucion(
            productoId: productoIdInt,
            cantidad: detalle.cantidad,
            nota: 'Anulacion venta $ventaIdOriginal',
          );
        }
        productosAfectados.add(productoIdInt);

        // Movimiento de contra. `stockResultante` se lee de los lotes,
        // no del campo del producto.
        final stockResultante =
            await _isar.obtenerStockTotalPorProducto(productoIdInt);
        final movimiento = MovimientoInventarioEntity()
          ..productoId = producto.id
          ..nombreProducto = '[ANULACIÓN] ${producto.nombre}'
          ..tipoMovimiento = 'ajuste_anulacion'
          ..cantidad = detalle.cantidad
          ..stockResultante = stockResultante
          ..usuarioId = usuario.id
          ..fecha = DateTime.now()
          ..syncStatus = 'pending';

        await _isar.guardarMovimientoInventario(movimiento);
      }

      // Recalcular el cache derivado `producto.stock` desde los lotes.
      await _isar.recalcularStockDe(productosAfectados.toList());

      debugPrint('✅ Venta $ventaIdOriginal anulada correctamente.');
      return true;
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'anularVenta_fallo',
        extras: {'ventaId': ventaIdOriginal},
      );
      return false;
    }
  }

  /// Anula un gasto.
  Future<bool> anularGasto({
    required int gastoIdOriginal,
    required String tenantId,
    required String motivo,
    required UsuarioEntity usuario,
    required double montoOriginal,
  }) async {
    try {
      final anulacion = GastoAnuladoEntity()
        ..gastoIdOriginal = gastoIdOriginal
        ..tenantId = tenantId
        ..motivo = motivo
        ..usuarioId = usuario.id
        ..usuarioNombre = usuario.nombre
        ..fechaAnulacion = DateTime.now()
        ..montoOriginal = montoOriginal;

      await _isar.guardarGastoAnulado(anulacion);
      debugPrint('✅ Gasto $gastoIdOriginal anulado correctamente.');
      return true;
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'anularGasto_fallo',
        extras: {'gastoId': gastoIdOriginal},
      );
      return false;
    }
  }
}

final ventaAnulacionServiceProvider = Provider<VentaAnulacionService>(
  (ref) => VentaAnulacionService(),
);
