// lib/features/pos/domain/services/venta_calculator.dart
import 'package:app_boosti_v2/features/pos/domain/models/cart_item.dart';

import '../../data/Local/entities/detalle_venta_entity.dart';

/// Resultado del cálculo de descuentos especiales.
class ResultadoDescuentos {
  final bool tieneDescuento;
  final double montoDescuentoTotal;

  const ResultadoDescuentos({
    required this.tieneDescuento,
    required this.montoDescuentoTotal,
  });
}

/// Utilidades puras para cálculo de ventas.
///
/// Sin I/O. Sin Flutter. Sin Isar. 100% testeable en aislamiento.
class VentaCalculator {
  VentaCalculator._(); // No instanciable

  /// Convierte una lista de `CartItem` en `DetalleVentaEntity` listos
  /// para persistir en Isar.
  static List<DetalleVentaEntity> cartItemsADetalles({
    required List<CartItem> cartItems,
    required String ventaIdFk,
  }) {
    return cartItems.map((cartItem) {
      return DetalleVentaEntity()
        ..productoId = int.tryParse(cartItem.producto.id)
        ..nombreProducto = cartItem.producto.nombre
        ..precioUnidad = cartItem.producto.precioUnidad
        ..precioOriginal = cartItem.precioOriginal
        ..esDescuentoEspecial = cartItem.esDescuentoEspecial
        ..cantidad = cartItem.cantidad.toDouble()
        ..subtotal =
            cartItem.cantidad.toDouble() * cartItem.producto.precioUnidad
        ..syncStatus = 'pending'
        ..ventaIdFk = ventaIdFk;
    }).toList();
  }

  /// Calcula si hay descuentos especiales y su monto total descontado.
  ///
  /// Un descuento cuenta solo si:
  /// - `esDescuentoEspecial == true`
  /// - `precioOriginal != null`
  static ResultadoDescuentos calcularDescuentos(
    List<DetalleVentaEntity> detalles,
  ) {
    bool tieneDescuento = false;
    double montoTotal = 0.0;

    for (final item in detalles) {
      if (item.esDescuentoEspecial == true && item.precioOriginal != null) {
        tieneDescuento = true;
        final descuento =
            (item.precioOriginal! - item.precioUnidad) * item.cantidad;
        montoTotal += descuento;
      }
    }

    return ResultadoDescuentos(
      tieneDescuento: tieneDescuento,
      montoDescuentoTotal: montoTotal,
    );
  }

  /// Calcula cuánto descontar de un lote.
  /// Devuelve el mínimo entre lo que se necesita y lo que hay disponible.
  static double calcularDescuentoDeLote({
    required double cantidadNecesaria,
    required double cantidadDisponible,
  }) {
    return cantidadNecesaria > cantidadDisponible
        ? cantidadDisponible
        : cantidadNecesaria;
  }

  /// Evalúa si una cantidad se considera "cero" con tolerancia de flotantes.
  static bool cantidadEsCero(double cantidad) => cantidad <= 0.001;
}