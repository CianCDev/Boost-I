import 'package:isar/isar.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';

class ResumenCorteCaja {
  final double totalVentas;
  final int cantidadTransacciones;
  final Map<String, double> totalesPorMetodo;
  final Map<String, int> conteoPorMetodo;

  ResumenCorteCaja({
    required this.totalVentas,
    required this.cantidadTransacciones,
    required this.totalesPorMetodo,
    required this.conteoPorMetodo,
  });
}

class CashRegisterService {
  final IsarService _isarService = IsarService();

  /// Calcula el resumen del día consultando Isar.
  /// Delega el cálculo puro a [calcularDesdeVentas].
  Future<ResumenCorteCaja> calcularCorteDelDia() async {
    final isar = await _isarService.db;
    final now = DateTime.now();
    final inicioDelDia = DateTime(now.year, now.month, now.day);

    final ventasHoy = await isar.ventaEntitys
        .filter()
        .fechaGreaterThan(inicioDelDia)
        .findAll();

    return calcularDesdeVentas(ventasHoy);
  }

  /// ✅ NUEVO: Lógica pura, sin I/O. Testeable.
  ///
  /// Recibe una lista de ventas y devuelve el resumen agregado por
  /// método de pago.
  ///
  /// Métodos base esperados: 'Efectivo', 'Tarjeta', 'Pago Móvil', 'Divisas'.
  /// Si aparece un método no listado, se agrega dinámicamente.
  static ResumenCorteCaja calcularDesdeVentas(List<VentaEntity> ventas) {
    double totalGeneral = 0.0;
    final Map<String, double> totalesMetodo = {
      'Efectivo': 0.0,
      'Tarjeta': 0.0,
      'Pago Móvil': 0.0,
      'Divisas': 0.0,
    };
    final Map<String, int> conteoMetodo = {
      'Efectivo': 0,
      'Tarjeta': 0,
      'Pago Móvil': 0,
      'Divisas': 0,
    };

    for (var venta in ventas) {
      totalGeneral += venta.total;
      final metodo = venta.metodoPago;

      if (totalesMetodo.containsKey(metodo)) {
        totalesMetodo[metodo] = totalesMetodo[metodo]! + venta.total;
        conteoMetodo[metodo] = conteoMetodo[metodo]! + 1;
      } else {
        // Método nuevo no previsto: se agrega dinámicamente
        totalesMetodo[metodo] = venta.total;
        conteoMetodo[metodo] = 1;
      }
    }

    return ResumenCorteCaja(
      totalVentas: totalGeneral,
      cantidadTransacciones: ventas.length,
      totalesPorMetodo: totalesMetodo,
      conteoPorMetodo: conteoMetodo,
    );
  }
}