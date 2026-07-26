import 'package:flutter/material.dart';


class PaymentDialog extends StatefulWidget {
  final double totalAPagar;

  const PaymentDialog({
    super.key,
    required this.totalAPagar,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _metodoPago = 'efectivo'; // 'efectivo', 'tarjeta', 'pago_movil'
  final TextEditingController _montoRecibidoController = TextEditingController();
  double _montoRecibido = 0.0;

  @override
  void initState() {
    super.initState();
    _montoRecibidoController.text = widget.totalAPagar.toStringAsFixed(2);
    _montoRecibido = widget.totalAPagar;
  }

  double get _vuelto => _montoRecibido >= widget.totalAPagar 
      ? _montoRecibido - widget.totalAPagar 
      : 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.point_of_sale, color: Color(0xFF10B981)),
          SizedBox(width: 8),
          Text('Procesar Cobro', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contenedor del Total a Pagar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL A PAGAR',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.totalAPagar.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Selector de Método de Pago
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'efectivo', label: Text('Efectivo'), icon: Icon(Icons.payments)),
                ButtonSegment(value: 'tarjeta', label: Text('Tarjeta'), icon: Icon(Icons.credit_card)),
                ButtonSegment(value: 'pago_movil', label: Text('Pago Móvil'), icon: Icon(Icons.phone_android)),
              ],
              selected: {_metodoPago},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _metodoPago = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),

            // Campo para ingresar Monto Recibido (Si es efectivo)
            if (_metodoPago == 'efectivo') ...[
              TextField(
                controller: _montoRecibidoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Monto Recibido (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() {
                    _montoRecibido = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Indicador de Cambio / Vuelto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _montoRecibido >= widget.totalAPagar 
                      ? Colors.green.shade50 
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _montoRecibido >= widget.totalAPagar 
                        ? Colors.green.shade300 
                        : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _montoRecibido >= widget.totalAPagar ? 'Vuelto / Cambio:' : 'Faltante:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _montoRecibido >= widget.totalAPagar
                          ? '\$${_vuelto.toStringAsFixed(2)}'
                          : '\$${(widget.totalAPagar - _montoRecibido).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _montoRecibido >= widget.totalAPagar 
                            ? Colors.green.shade800 
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Procese la transacción en el punto/POS y confirme para completar.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          onPressed: (_metodoPago == 'efectivo' && _montoRecibido < widget.totalAPagar)
              ? null
              : () => Navigator.of(context).pop(true),
          child: const Text('CONFIRMAR PAGO'),
        ),
      ],
    );
  }
}