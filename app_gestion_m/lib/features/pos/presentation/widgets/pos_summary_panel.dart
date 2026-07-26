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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
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
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            
            // Subtotal
            _buildRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            
            // IVA (16%)
            _buildRow('IVA (16%)', '\$${impuesto.toStringAsFixed(2)}'),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            
            // Total Destacado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // Botón de Cobro Principal
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: total > 0 ? onPagarPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.payment, size: 22),
                label: const Text(
                  'COBRAR (F12)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón Limpiar Venta
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: subtotal > 0 ? onLimpiarPressed : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  disabledForegroundColor: const Color(0xFFCBD5E1),
                  side: BorderSide(
                    color: subtotal > 0 ? Colors.redAccent : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text(
                  'CANCELAR VENTA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
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
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 15)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}