import 'package:isar/isar.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/isar_service.dart';

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

  Future<ResumenCorteCaja> calcularCorteDelDia() async {
    final isar = await _isarService.db;
    final now = DateTime.now();
    final inicioDelDia = DateTime(now.year, now.month, now.day);

    // Obtenemos las ventas desde las 00:00:00 de hoy
    final ventasHoy = await isar.ventaEntitys
        .filter()
        .fechaGreaterThan(inicioDelDia)
        .findAll();

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

    for (var venta in ventasHoy) {
      totalGeneral += venta.total;
      final metodo = venta.metodoPago;
      
      if (totalesMetodo.containsKey(metodo)) {
        totalesMetodo[metodo] = (totalesMetodo[metodo]! + venta.total);
        conteoMetodo[metodo] = (conteoMetodo[metodo]! + 1);
      } else {
        totalesMetodo[metodo] = venta.total;
        conteoMetodo[metodo] = 1;
      }
    }

    return ResumenCorteCaja(
      totalVentas: totalGeneral,
      cantidadTransacciones: ventasHoy.length,
      totalesPorMetodo: totalesMetodo,
      conteoPorMetodo: conteoMetodo,
    );
  }
}