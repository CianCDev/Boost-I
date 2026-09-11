import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final fontSize = ResponsiveHelper.getFontSize(context, baseSize: 14);
    
    final paddingHorizontal = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final paddingVertical = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final buttonHeight = isMobile ? 44.0 : 48.0;
    final buttonFontSize = isMobile ? 12.0 : 14.0;

    return Card(
      elevation: isMobile ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: isMobile ? 0.5 : 1),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('RESUMEN DE VENTA', style: TextStyle(fontSize: isMobile ? fontSize * 0.85 : fontSize, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.8)),
            const SizedBox(height: 12),
            _buildRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', fontSize, isMobile),
            const SizedBox(height: 6),
            _buildRow('IVA (16%)', '\$${impuesto.toStringAsFixed(2)}', fontSize, isMobile),
            const Divider(height: 20, color: Color(0xFFCECECE)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 10 : 14),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('TOTAL', style: TextStyle(fontSize: isMobile ? fontSize * 1.1 : fontSize * 1.2, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: isMobile ? fontSize * 1.5 : fontSize * 1.8, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(height: buttonHeight, width: double.infinity, child: ElevatedButton.icon(
              onPressed: total > 0 ? onPagarPressed : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, disabledForegroundColor: Colors.grey.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 8)),
              icon: Icon(Icons.payment, size: isMobile ? 18 : 22),
              label: Text(isMobile ? 'COBRAR' : 'COBRAR (F12)', style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(height: 8),
            SizedBox(height: isMobile ? 38 : 42, width: double.infinity, child: OutlinedButton.icon(
              onPressed: subtotal > 0 ? onLimpiarPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                disabledForegroundColor: Colors.grey.shade400,
                side: BorderSide(color: subtotal > 0 ? const Color(0xFFEF4444) : Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(Icons.delete_sweep, size: isMobile ? 16 : 18),
              label: Text(isMobile ? 'CANCELAR' : 'CANCELAR VENTA', style: TextStyle(fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, double fontSize, bool isMobile) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? fontSize * 0.85 : fontSize)),
      Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? fontSize * 0.9 : fontSize, color: Colors.grey.shade800)),
    ]);
  }
}