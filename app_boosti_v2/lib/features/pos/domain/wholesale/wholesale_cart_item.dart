// lib/features/pos/domain/models/wholesale/wholesale_cart_item.dart
import 'package:flutter/foundation.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../presentation/services/mayoreo/wholesale_pricing_service.dart';

/// Representa una línea del carrito de ventas al mayor.
///
/// Es **inmutable** y calcula sus totales en base a:
///   - Cantidad (unidades)
///   - Precio unitario resuelto (detal / medio mayor / mayor)
///   - Descuento automático por volumen (reglas)
///   - Descuento manual por línea
///   - Autorización (si el descuento supera el tope del rol)
@immutable
class WholesaleCartItem {
  final ProductoEntity producto;
  final int cantidad;

  /// 'unidad' | 'bulto' | 'caja'
  final String unidadEmpaque;

  /// Unidades por empaque (si aplica)
  final int unidadesPorEmpaque;

  /// Precio unitario final (aplicado a la venta).
  final double precioUnitario;

  /// Tipo de precio aplicado (detal / medio mayor / mayor).
  final PrecioTipo tipoPrecio;

  /// Precio detal original del producto (para mostrar ahorro).
  final double precioDetalOriginal;

  /// Descuento automático por reglas de volumen (%).
  final double descuentoAutoPorcentaje;

  /// Nombre de la regla que aplicó (si aplica).
  final String? reglaAutoNombre;

  /// Descuento manual aplicado a esta línea (%).
  final double descuentoManualPorcentaje;

  /// `true` si el descuento manual de esta línea ya fue autorizado.
  final bool descuentoAutorizado;

  /// Nombre del autorizador (si aplica).
  final String? autorizadoPorNombre;

  const WholesaleCartItem({
    required this.producto,
    required this.cantidad,
    this.unidadEmpaque = 'unidad',
    this.unidadesPorEmpaque = 1,
    required this.precioUnitario,
    required this.tipoPrecio,
    required this.precioDetalOriginal,
    this.descuentoAutoPorcentaje = 0.0,
    this.reglaAutoNombre,
    this.descuentoManualPorcentaje = 0.0,
    this.descuentoAutorizado = false,
    this.autorizadoPorNombre,
  });

  // ──────────────── Cálculos ────────────────

  /// Subtotal antes de descuentos.
  double get subtotalBruto => precioUnitario * cantidad;

  /// Monto descontado por reglas de volumen.
  double get montoDescuentoAuto =>
      subtotalBruto * (descuentoAutoPorcentaje / 100.0);

  /// Monto descontado por descuento manual.
  double get montoDescuentoManual =>
      subtotalBruto * (descuentoManualPorcentaje / 100.0);

  /// Total descontado (auto + manual).
  double get montoDescuentoTotal =>
      montoDescuentoAuto + montoDescuentoManual;

  /// Subtotal final después de descuentos.
  double get subtotalFinal => subtotalBruto - montoDescuentoTotal;

  /// Ahorro vs. precio detal.
  double get ahorroVsDetal {
    final diff = precioDetalOriginal - precioUnitario;
    return diff > 0 ? diff * cantidad : 0.0;
  }

  /// Descuento efectivo total (% respecto al precio detal).
  double get descuentoEfectivoPorcentaje {
    if (precioDetalOriginal <= 0) return 0;
    final descuentoUnitario = precioDetalOriginal - precioUnitario;
    final pctPorPrecio = (descuentoUnitario / precioDetalOriginal) * 100;
    return pctPorPrecio + descuentoManualPorcentaje;
  }

  // ──────────────── Identidad ────────────────

  /// ID único de la línea (basado en producto + empaque).
  String get lineId => '${producto.id}-$unidadEmpaque';

  // ──────────────── Helpers UI ────────────────

  String get tipoPrecioLabel {
    switch (tipoPrecio) {
      case PrecioTipo.detal:
        return 'Detal';
      case PrecioTipo.medioMayor:
        return 'Medio Mayor';
      case PrecioTipo.mayor:
        return 'Mayor';
    }
  }

  bool get tieneDescuentoAuto => descuentoAutoPorcentaje > 0;
  bool get tieneDescuentoManual => descuentoManualPorcentaje > 0;

  /// Indica si esta línea requiere autorización por superar tope.
  bool get requiereAutorizacionDescuento =>
      descuentoManualPorcentaje > 0 && !descuentoAutorizado;

  // ──────────────── copyWith ────────────────

  WholesaleCartItem copyWith({
    int? cantidad,
    double? precioUnitario,
    PrecioTipo? tipoPrecio,
    double? descuentoManualPorcentaje,
    bool? descuentoAutorizado,
    String? autorizadoPorNombre,
    bool clearAutorizadoPorNombre = false,
  }) {
    return WholesaleCartItem(
      producto: producto,
      cantidad: cantidad ?? this.cantidad,
      unidadEmpaque: unidadEmpaque,
      unidadesPorEmpaque: unidadesPorEmpaque,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      tipoPrecio: tipoPrecio ?? this.tipoPrecio,
      precioDetalOriginal: precioDetalOriginal,
      descuentoAutoPorcentaje: descuentoAutoPorcentaje,
      reglaAutoNombre: reglaAutoNombre,
      descuentoManualPorcentaje:
          descuentoManualPorcentaje ?? this.descuentoManualPorcentaje,
      descuentoAutorizado:
          descuentoAutorizado ?? this.descuentoAutorizado,
      autorizadoPorNombre: clearAutorizadoPorNombre
          ? null
          : (autorizadoPorNombre ?? this.autorizadoPorNombre),
    );
  }

  // ──────────────── Constructores de fábrica ────────────────

  /// Crea una línea a partir del resultado del `WholesalePricingService`.
  factory WholesaleCartItem.desdePrecioResuelto({
    required ProductoEntity producto,
    required int cantidad,
    required PrecioResuelto precio,
    String unidadEmpaque = 'unidad',
    int? unidadesPorEmpaque,
  }) {
    return WholesaleCartItem(
      producto: producto,
      cantidad: cantidad,
      unidadEmpaque: unidadEmpaque,
      unidadesPorEmpaque:
          unidadesPorEmpaque ?? producto.unidadesPorBulto,
      precioUnitario: precio.precioUnitario,
      tipoPrecio: precio.tipo,
      precioDetalOriginal:
          precio.precioDetalOriginal ?? producto.precioUnidad,
      descuentoAutoPorcentaje: precio.descuentoAutoPorcentaje,
      reglaAutoNombre: precio.reglaAplicada,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WholesaleCartItem &&
          runtimeType == other.runtimeType &&
          lineId == other.lineId &&
          cantidad == other.cantidad &&
          precioUnitario == other.precioUnitario &&
          descuentoManualPorcentaje == other.descuentoManualPorcentaje &&
          descuentoAutorizado == other.descuentoAutorizado;

  @override
  int get hashCode =>
      lineId.hashCode ^
      cantidad.hashCode ^
      precioUnitario.hashCode ^
      descuentoManualPorcentaje.hashCode ^
      descuentoAutorizado.hashCode;
}