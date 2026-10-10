import 'package:flutter/material.dart';

/// Pantalla de herramientas de administración.
///
/// Placeholder: se implementa en la Subfase 3.3.2.
///
/// No declara `Scaffold` ni `AppBar` porque vive dentro del body de
/// `ControlCenterScreen`, que ya aporta ambos. Mantenerlos aquí anidaría
/// dos encabezados.
class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dev Tools — próximamente'),
    );
  }
}
