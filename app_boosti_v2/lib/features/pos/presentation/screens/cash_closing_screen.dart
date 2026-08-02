import 'package:flutter/material.dart';
import '../services/cash_register_service.dart';
import '../services/ticket_service.dart';
import '../utils/responsive_helper.dart';

class CashClosingScreen extends StatefulWidget {
  const CashClosingScreen({super.key});

  @override
  State<CashClosingScreen> createState() => _CashClosingScreenState();
}

class _CashClosingScreenState extends State<CashClosingScreen> {
  final CashRegisterService _cashService = CashRegisterService();
  bool _isLoading = true;
  ResumenCorteCaja? _resumen;

  @override
  void initState() {
    super.initState();
    _cargarCorte();
  }

  Future<void> _cargarCorte() async {
    setState(() => _isLoading = true);
    try {
      final resumen = await _cashService.calcularCorteDelDia();
      if (mounted) {
        setState(() {
          _resumen = resumen;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al calcular el corte: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Future<void> _ejecutarCierreYGuardarPdf() async {
    if (_resumen == null) return;
    try {
      final List<TicketItem> itemsArqueo = [TicketItem(nombre: 'Cierre de Caja / Arqueo Diario', precio: _resumen!.totalVentas, cantidad: 1.0, esPesado: false)];
      await TicketService.generarYProcesarPdf(
        items: itemsArqueo,
        subtotal: _resumen!.totalVentas,
        impuesto: 0.0,
        total: _resumen!.totalVentas,
        metodoPago: 'ARQUEO DE CAJA',
        montoRecibido: _resumen!.totalVentas,
        vuelto: 0.0,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cierre de caja procesado y PDF guardado con éxito! 📄'), backgroundColor: Color(0xFF10B981)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar el PDF del arqueo: $e'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Corte de Caja Diario', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromRGBO(122, 153, 255, 1), Color.fromARGB(255, 85, 59, 235)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), tooltip: 'Actualizar Corte', onPressed: _cargarCorte)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : _resumen == null
              ? const Center(child: Text('No hay datos disponibles'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tarjeta principal del total
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('TOTAL RECAUDADO HOY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              Text('\$${_resumen!.totalVentas.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: isTablet ? 36 : 28, fontWeight: FontWeight.bold)),
                            ]),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF10B981))),
                              child: Column(children: [const Text('Transacciones', style: TextStyle(color: Color(0xFF10B981), fontSize: 11)), const SizedBox(height: 2), Text('${_resumen!.cantidadTransacciones}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Desglose por Método de Pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      // Grid de métodos de pago (MÁS GRANDE EN TABLET)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isMobile ? 2.2 : 1.8,
                        ),
                        itemCount: _resumen!.totalesPorMetodo.keys.length,
                        itemBuilder: (context, index) {
                          String metodo = _resumen!.totalesPorMetodo.keys.elementAt(index);
                          double monto = _resumen!.totalesPorMetodo[metodo]!;
                          int cantidad = _resumen!.conteoPorMetodo[metodo]!;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(metodo, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13)), Text('$cantidad ops', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))]),
                                const Spacer(),
                                Text('\$${monto.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Botón de Cierre
                      SizedBox(
                        height: isMobile ? 52 : 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          onPressed: _ejecutarCierreYGuardarPdf,
                          icon: const Icon(Icons.print, size: 20),
                          label: Text('Realizar Cierre y Guardar PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
