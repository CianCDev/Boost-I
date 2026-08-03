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
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.transparent,
          width: 1,
        ),
      ),
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(
            Icons.point_of_sale,
            color: theme.brightness == Brightness.dark
                ? Colors.green.shade300
                : const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          Text(
            'Procesar Cobro',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
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
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'TOTAL A PAGAR',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
                ButtonSegment(
                  value: 'efectivo',
                  label: Text('Efectivo'),
                  icon: Icon(Icons.payments),
                ),
                ButtonSegment(
                  value: 'tarjeta',
                  label: Text('Tarjeta'),
                  icon: Icon(Icons.credit_card),
                ),
                ButtonSegment(
                  value: 'pago_movil',
                  label: Text('Pago Móvil'),
                  icon: Icon(Icons.phone_android),
                ),
              ],
              selected: {_metodoPago},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _metodoPago = newSelection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200;
                    }
                    return Colors.transparent;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return theme.brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF0F172A);
                    }
                    return theme.textTheme.bodyMedium?.color ?? Colors.black;
                  },
                ),
                side: WidgetStateProperty.resolveWith<BorderSide>(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade600
                            : const Color(0xFF0F172A),
                        width: 1.5,
                      );
                    }
                    return BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: 1,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campo para ingresar Monto Recibido (Si es efectivo)
            if (_metodoPago == 'efectivo') ...[
              TextField(
                controller: _montoRecibidoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Monto Recibido (\$)',
                  labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
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
                      ? (theme.brightness == Brightness.dark
                          ? Colors.green.withOpacity(0.15)
                          : Colors.green.shade50)
                      : (theme.brightness == Brightness.dark
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.orange.shade50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _montoRecibido >= widget.totalAPagar
                        ? (theme.brightness == Brightness.dark
                            ? Colors.green.withOpacity(0.3)
                            : Colors.green.shade300)
                        : (theme.brightness == Brightness.dark
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.orange.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _montoRecibido >= widget.totalAPagar ? 'Vuelto / Cambio:' : 'Faltante:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      _montoRecibido >= widget.totalAPagar
                          ? '\$${_vuelto.toStringAsFixed(2)}'
                          : '\$${(widget.totalAPagar - _montoRecibido).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _montoRecibido >= widget.totalAPagar
                            ? (theme.brightness == Brightness.dark
                                ? Colors.green.shade300
                                : Colors.green.shade800)
                            : (theme.brightness == Brightness.dark
                                ? Colors.orange.shade300
                                : Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Procese la transacción en el punto/POS y confirme para completar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.textTheme.bodyMedium?.color,
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          onPressed: (_metodoPago == 'efectivo' && _montoRecibido < widget.totalAPagar)
              ? null
              : () => Navigator.of(context).pop(true),
          child: const Text('CONFIRMAR PAGO', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}