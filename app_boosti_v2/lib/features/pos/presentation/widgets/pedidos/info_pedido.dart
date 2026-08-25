import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'estado_chip.dart';

class InfoPedido extends StatelessWidget {
  final PedidoEntity pedido;

  const InfoPedido({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pedido.proveedorNombre,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                EstadoChip(estado: pedido.estado),
              ],
            ),
            const SizedBox(height: 8),
            if (pedido.proveedorEmpresa != null) Text('Empresa: ${pedido.proveedorEmpresa}'),
            if (pedido.proveedorCedula != null) Text('Cédula: ${pedido.proveedorCedula}'),
            if (pedido.proveedorTelefono != null) Text('Teléfono: ${pedido.proveedorTelefono}'),
            const SizedBox(height: 8),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(pedido.fechaPedido)}'),
            Text('Local Destino: ${pedido.localDestinoId}'),
            if (pedido.observaciones != null) Text('Observaciones: ${pedido.observaciones}'),
            const SizedBox(height: 8),
            Text(
              'Total: \$${pedido.total.toStringAsFixed(2)}', // ✅ USD
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}