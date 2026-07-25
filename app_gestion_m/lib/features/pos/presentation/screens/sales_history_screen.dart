import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IsarService _isarService = IsarService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Modal para ver los productos comprados de una venta de Isar
  void _mostrarDetalleItems(BuildContext context, VentaEntity venta) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text('Detalle de Venta #${venta.ventaIdString}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cliente: ${venta.cedulaCliente}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Cajero: ${venta.empleado}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Productos Comprados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: venta.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = venta.items[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.nombreProducto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text('${item.cantidad} x \$${item.precioUnidad.toStringAsFixed(2)}'),
                        trailing: Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                      );
                    },
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('\$${venta.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF059669))),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Registro y Auditoría de Ventas (Local)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: const [
            Tab(text: 'DÍA ACTUAL', icon: Icon(Icons.today, size: 18)),
            Tab(text: 'ÚLTIMA SEMANA', icon: Icon(Icons.date_range, size: 18)),
            Tab(text: 'ÚLTIMO MES', icon: Icon(Icons.calendar_month, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPestanaVentas('dia'),
          _buildPestanaVentas('semana'),
          _buildPestanaVentas('mes'),
        ],
      ),
    );
  }

  Widget _buildPestanaVentas(String periodo) {
    return FutureBuilder<List<VentaEntity>>(
      future: _isarService.obtenerVentasPorPeriodo(periodo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar registros: ${snapshot.error}'));
        }

        final ventas = snapshot.data ?? [];

        if (ventas.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCBD5E1)),
                SizedBox(height: 8),
                Text('No hay registros de venta en este período.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                dataRowMaxHeight: 56,
                columns: const [
                  DataColumn(label: Text('ID Venta', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Fecha y Hora', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Cédula Cliente', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Cajero / Empleado', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Método', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Acción', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                ],
                rows: ventas.map((venta) {
                  final String horaFormatted = "${venta.fecha.hour.toString().padLeft(2, '0')}:${venta.fecha.minute.toString().padLeft(2, '0')}";
                  final String fechaFormatted = "${venta.fecha.day}/${venta.fecha.month}/${venta.fecha.year}";

                  return DataRow(
                    cells: [
                      DataCell(Text(venta.ventaIdString, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('$fechaFormatted - $horaFormatted')),
                      DataCell(Text(venta.cedulaCliente)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
                          child: Text(venta.empleado, style: const TextStyle(fontSize: 12, color: Color(0xFF0369A1), fontWeight: FontWeight.w600)),
                        )
                      ),
                      DataCell(Text(venta.metodoPago)),
                      DataCell(Text('\$${venta.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Color(0xFF3B82F6), size: 20),
                          tooltip: 'Ver productos comprados',
                          onPressed: () => _mostrarDetalleItems(context, venta),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}