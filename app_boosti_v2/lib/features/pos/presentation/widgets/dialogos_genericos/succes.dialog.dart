import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String content;

  const SuccessDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}