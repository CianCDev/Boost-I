// lib/features/pos/domain/services/wholesale_pricing_service.dart
import '../../../data/Local/entities/config_descuento_mayorista_entity.dart';
import '../../../data/Local/entities/producto_entity.dart';

/// Tipo de precio aplicado a una línea de venta.
enum PrecioTipo {
  detal,
  medioMayor,
  mayor,
}

extension PrecioTipoX on PrecioTipo {
  String get label {
    switch (this) {
      case PrecioTipo.detal:
        return 'Detal';
      case PrecioTipo.medioMayor:
        return 'Medio Mayor';
      case PrecioTipo.mayor:
        return 'Mayor';
    }
  }

  String get storageKey {
    switch (this) {
      case PrecioTipo.detal:
        return 'detal';
      case PrecioTipo.medioMayor:
        return 'medio_mayor';
      case PrecioTipo.mayor:
        return 'mayor';
    }
  }
}

/// Resultado del cálculo de precio para un producto + cantidad.
class PrecioResuelto {
  final double precioUnitario;
  final PrecioTipo tipo;
  final double? precioDetalOriginal;
  final double? precioMayorAplicado;

  /// Descuento automático por volumen (aplicado por reglas).
  final double descuentoAutoPorcentaje;

  /// Nombre de la regla de volumen aplicada (si hubo).
  final String? reglaAplicada;

  const PrecioResuelto({
    required this.precioUnitario,
    required this.tipo,
    this.precioDetalOriginal,
    this.precioMayorAplicado,
    this.descuentoAutoPorcentaje = 0.0,
    this.reglaAplicada,
  });

  /// Subtotal ANTES de aplicar descuentos manuales.
  double subtotalPara(int cantidad) {
    return precioUnitario * cantidad;
  }

  /// Ahorro vs detal original.
  double ahorroVsDetal(int cantidad) {
    if (precioDetalOriginal == null) return 0;
    return (precioDetalOriginal! - precioUnitario) * cantidad;
  }

  /// `true` si se aplicó algún tipo de precio distinto a detal.
  bool get esMayorista => tipo != PrecioTipo.detal;
}

/// Servicio puro de resolución de precios y descuentos por volumen.
///
/// **Sin I/O, sin Isar, sin Flutter.** 100% testeable.
class WholesalePricingService {
  WholesalePricingService._();

  /// Resuelve el precio unitario para un producto dado una cantidad.
  ///
  /// Prioridad:
  ///   1. Precio mayor si `cantidad >= cantidadMinimaMayor`
  ///   2. Precio medio mayor si `cantidad >= cantidadMinimaMedioMayor`
  ///   3. Precio detal
  ///
  /// Luego aplica la **mejor regla de descuento por volumen** de
  /// [reglasVolumen] que aplique al producto/cantidad.
  static PrecioResuelto resolver({
    required ProductoEntity producto,
    required int cantidad,
    List<ConfigDescuentoMayoristaEntity> reglasVolumen = const [],
  }) {
    if (cantidad <= 0) {
      return PrecioResuelto(
        precioUnitario: producto.precioUnidad,
        tipo: PrecioTipo.detal,
        precioDetalOriginal: producto.precioUnidad,
      );
    }

    // ── 1. Si el producto no permite venta al mayor → detal ──
    if (!producto.permiteVentaMayor) {
      return PrecioResuelto(
        precioUnitario: producto.precioUnidad,
        tipo: PrecioTipo.detal,
        precioDetalOriginal: producto.precioUnidad,
      );
    }

    // ── 2. Intentar precio mayor ──
    if (producto.precioMayor != null &&
        producto.cantidadMinimaMayor != null &&
        cantidad >= producto.cantidadMinimaMayor!) {
      final descuento = _mejorDescuentoVolumen(
        producto: producto,
        cantidad: cantidad,
        reglas: reglasVolumen,
      );
      return PrecioResuelto(
        precioUnitario: producto.precioMayor!,
        tipo: PrecioTipo.mayor,
        precioDetalOriginal: producto.precioUnidad,
        precioMayorAplicado: producto.precioMayor,
        descuentoAutoPorcentaje: descuento?.porcentaje ?? 0.0,
        reglaAplicada: descuento?.nombre,
      );
    }

    // ── 3. Intentar medio mayor ──
    if (producto.precioMedioMayor != null &&
        producto.cantidadMinimaMedioMayor != null &&
        cantidad >= producto.cantidadMinimaMedioMayor!) {
      final descuento = _mejorDescuentoVolumen(
        producto: producto,
        cantidad: cantidad,
        reglas: reglasVolumen,
      );
      return PrecioResuelto(
        precioUnitario: producto.precioMedioMayor!,
        tipo: PrecioTipo.medioMayor,
        precioDetalOriginal: producto.precioUnidad,
        precioMayorAplicado: producto.precioMedioMayor,
        descuentoAutoPorcentaje: descuento?.porcentaje ?? 0.0,
        reglaAplicada: descuento?.nombre,
      );
    }

    // ── 4. Fallback: detal ──
    return PrecioResuelto(
      precioUnitario: producto.precioUnidad,
      tipo: PrecioTipo.detal,
      precioDetalOriginal: producto.precioUnidad,
    );
  }

  /// Devuelve la mejor regla de descuento por volumen aplicable.
  ///
  /// Filtra por:
  ///   - `activo == true`
  ///   - Aplica a la categoría del producto (o globales)
  ///   - `cantidad` dentro del rango
  ///
  /// Ordena por `descuentoPorcentaje DESC` y devuelve la primera.
  static _ReglaVolumenResuelta? _mejorDescuentoVolumen({
    required ProductoEntity producto,
    required int cantidad,
    required List<ConfigDescuentoMayoristaEntity> reglas,
  }) {
    final aplicables = reglas.where((r) {
      if (!r.activo) return false;

      // Filtrar por categoría (si la regla tiene una asignada)
      if (r.categoriaIdIsar != null && r.categoriaIdIsar != producto.categoriaId) {
        return false;
      }

      if (cantidad < r.cantidadMinima) return false;
      if (r.cantidadMaxima != null && cantidad > r.cantidadMaxima!) return false;

      return true;
    }).toList()
      ..sort((a, b) =>
          b.descuentoPorcentaje.compareTo(a.descuentoPorcentaje));

    if (aplicables.isEmpty) return null;

    final mejor = aplicables.first;
    return _ReglaVolumenResuelta(
      nombre: mejor.nombre,
      porcentaje: mejor.descuentoPorcentaje,
      requiereAutorizacion: mejor.requiereAutorizacion,
    );
  }

  /// Calcula el descuento en monto (no en %) sobre un subtotal.
  static double calcularDescuentoMonto({
    required double subtotal,
    required double porcentaje,
  }) {
    if (porcentaje <= 0) return 0.0;
    if (porcentaje >= 100) return subtotal;
    return subtotal * (porcentaje / 100.0);
  }

  /// Total final después de aplicar un % de descuento global.
  static double aplicarDescuentoGlobal({
    required double subtotal,
    required double descuentoPorcentaje,
  }) {
    final descuento = calcularDescuentoMonto(
      subtotal: subtotal,
      porcentaje: descuentoPorcentaje,
    );
    return (subtotal - descuento).clamp(0, double.infinity);
  }

  /// Redondea a 2 decimales de forma consistente.
  static double redondear(double valor) {
    return (valor * 100).roundToDouble() / 100;
  }
}

class _ReglaVolumenResuelta {
  final String nombre;
  final double porcentaje;
  final bool requiereAutorizacion;

  const _ReglaVolumenResuelta({
    required this.nombre,
    required this.porcentaje,
    required this.requiereAutorizacion,
  });
}