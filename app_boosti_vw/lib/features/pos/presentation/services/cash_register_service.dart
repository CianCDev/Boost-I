// lib/features/pos/presentation/services/cash_register_service.dart
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';

/// Modelo que representa el resumen del corte de caja
class ResumenCorteCaja {
  final double totalVentas;
  final int cantidadTransacciones;
  final Map<String, double> totalesPorMetodo;

  const ResumenCorteCaja({
    required this.totalVentas,
    required this.cantidadTransacciones,
    required this.totalesPorMetodo,
  });

  factory ResumenCorteCaja.vacio() => const ResumenCorteCaja(
        totalVentas: 0,
        cantidadTransacciones: 0,
        totalesPorMetodo: {},
      );
}

class CashRegisterService {
  final IsarService _isar = IsarService();

  /// Calcula el resumen del día (en el stub retornará datos vacíos)
  Future<ResumenCorteCaja> calcularCorteDelDia() async {
    final ventas = await _isar.obtenerVentas();

    // Filtrar por hoy
    final hoy = DateTime.now();
    final ventasDeHoy = ventas.where((v) {
      final fecha = v.fecha;
      if (fecha == null) return false;
      return fecha.year == hoy.year &&
          fecha.month == hoy.month &&
          fecha.day == hoy.day;
    }).toList();

    double total = 0;
    final totalesPorMetodo = <String, double>{};

    for (final venta in ventasDeHoy) {
      total += venta.total;
      totalesPorMetodo[venta.metodoPago] =
          (totalesPorMetodo[venta.metodoPago] ?? 0) + venta.total;
    }

    return ResumenCorteCaja(
      totalVentas: total,
      cantidadTransacciones: ventasDeHoy.length,
      totalesPorMetodo: totalesPorMetodo,
    );
  }
}