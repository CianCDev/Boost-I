import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';

class InfoRecepcion extends StatelessWidget {
  final RecepcionEntity recepcion;

  const InfoRecepcion({super.key, required this.recepcion});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Recepción Registrada', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(recepcion.fechaRecepcion)}'),
            if (recepcion.observaciones != null) Text('Observaciones: ${recepcion.observaciones}'),
          ],
        ),
      ),
    );
  }
}