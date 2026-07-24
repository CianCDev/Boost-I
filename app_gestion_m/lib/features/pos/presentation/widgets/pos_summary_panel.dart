import 'package:flutter/material.dart';

class PosSummaryPanel extends StatelessWidget {
  final double subtotal;
  final double impuesto;
  final double total;
  final VoidCallback onPagarPressed;
  final VoidCallback onLimpiarPressed;

  const PosSummaryPanel({
    super.key,
    required this.subtotal,
    required this.impuesto,
    required this.total,
    required this.onPagarPressed,
    required this.onLimpiarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'RESUMEN DE VENTA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
            const Divider(height: 24),
            
            // Subtotal
            _buildRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            
            // IVA (16%)
            _buildRow('IVA (16%)', '\$${impuesto.toStringAsFixed(2)}'),
            const Divider(height: 24),
            
            // Total Destacado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const Spacer(),
            
            // Botón de Cobro Principal
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: total > 0 ? onPagarPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.payment, size: 24),
                label: const Text(
                  'COBRAR (F12)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón Limpiar Venta
            OutlinedButton.icon(
              onPressed: subtotal > 0 ? onLimpiarPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('CANCELAR VENTA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}