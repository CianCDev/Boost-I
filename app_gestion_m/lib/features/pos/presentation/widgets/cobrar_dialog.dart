import 'package:flutter/material.dart';

class CobrarDialog extends StatefulWidget {
  final double totalAPagar;

  const CobrarDialog({
    super.key,
    required this.totalAPagar,
  });

  @override
  State<CobrarDialog> createState() => _CobrarDialogState();
}

class _CobrarDialogState extends State<CobrarDialog> {
  String _metodoPago = 'efectivo'; // 'efectivo', 'tarjeta', 'pago_movil'
  final TextEditingController _montoRecibidoController = TextEditingController();
  double _montoRecibido = 0.0;

  @override
  void initState() {
    super.initState();
    _montoRecibidoController.text = widget.totalAPagar.toStringAsFixed(2);
    _montoRecibido = widget.totalAPagar;
  }

  @override
  void dispose() {
    _montoRecibidoController.dispose();
    super.dispose();
  }

  double get _vuelto {
    if (_metodoPago != 'efectivo') return 0.0;
    final vuelto = _montoRecibido - widget.totalAPagar;
    return vuelto > 0 ? vuelto : 0.0;
  }

  bool get _montoInsuficiente {
    return _metodoPago == 'efectivo' && _montoRecibido < widget.totalAPagar;
  }

  void _confirmarPago() {
    if (_montoInsuficiente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto recibido es menor al total a pagar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'procesado': true,
      'metodoPago': _metodoPago,
      'montoRecibido': _metodoPago == 'efectivo' ? _montoRecibido : widget.totalAPagar,
      'vuelto': _vuelto,
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos colores dinámicos: Naranja si el pago es insuficiente, Verde si está bien
    final Color bannerBgColor = _montoInsuficiente 
        ? const Color(0xFFFFF3E0) 
        : const Color(0xFFE8F5E9);

    final Color bannerBorderColor = _montoInsuficiente 
        ? const Color(0xFFFFB74D) 
        : const Color(0xFFA5D6A7);

    final Color bannerTextColor = _montoInsuficiente 
        ? const Color(0xFFE65100) 
        : const Color(0xFF1B5E20);

    final Color bannerMontoColor = _montoInsuficiente 
        ? const Color(0xFFEF6C00) 
        : const Color(0xFF2E7D32);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFF3F4F6),
      child: SingleChildScrollView( // Evita overflow si aparece el teclado
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título (CORREGIDO: const aplicado a nivel de la lista)
              const Row(
          children: [
            Icon(
             Icons.point_of_sale,
             size: 24,
             color: Color(0xFF10B981),
           ),
           SizedBox(width: 8),
           Text(
             'Procesar Cobro',
             style: TextStyle(
               fontSize: 20,
               fontWeight: FontWeight.bold,
               color: Color(0xFF111827),
              ),
            ),
          ],
        ),
              const SizedBox(height: 16),

              // Tarjeta superior oscura
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL A PAGAR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.totalAPagar.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Selector de Método de Pago
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'efectivo',
                    label: Text('Efectivo'),
                    icon: Icon(Icons.check, size: 16),
                  ),
                  ButtonSegment(
                    value: 'tarjeta',
                    label: Text('Tarjeta'),
                    icon: Icon(Icons.credit_card, size: 16),
                  ),
                  ButtonSegment(
                    value: 'pago_movil',
                    label: Text('Pago Móvil'),
                    icon: Icon(Icons.smartphone, size: 16),
                  ),
                ],
                selected: {_metodoPago},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _metodoPago = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Campos de Efectivo
              if (_metodoPago == 'efectivo') ...[
                TextField(
                  controller: _montoRecibidoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monto Recibido (\$)',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _montoRecibido = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Banner dinámico (Naranja si falta pago / Verde si hay cambio suficiente)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bannerBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: bannerBorderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _montoInsuficiente ? 'Falta por Pagar:' : 'Vuelto / Cambio:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: bannerTextColor,
                        ),
                      ),
                      Text(
                        _montoInsuficiente
                            ? '\$${(widget.totalAPagar - _montoRecibido).toStringAsFixed(2)}'
                            : '\$${_vuelto.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: bannerMontoColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Botones de acción inferiores
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _confirmarPago,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'CONFIRMAR PAGO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}