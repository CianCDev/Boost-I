// lib/features/panel/controllers/panel_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/themes/theme_provider.dart';
import '../widgets/dialogos_genericos/succes_dialog.dart';

class PanelController {
  void cambiarImpresora(BuildContext context) {
    // La acción real se dispara desde el panel, que abre el diálogo de selección
  }

  void cambiarLector(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SuccessDialog(
        title: 'Lector cambiado',
        content: 'Función en desarrollo',
      ),
    );
  }

  void cambiarCajero(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar cajero'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingrese PIN del administrador:'),
            SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cajero cambiado')),
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void clientesFrecuentes(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SuccessDialog(
        title: 'Clientes frecuentes',
        content: 'Pantalla en construcción',
      ),
    );
  }

  void descuentoEspecial(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descuento especial'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingrese el descuento (porcentaje o monto fijo):'),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descuento aplicado')),
              );
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void crearPromocion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SuccessDialog(
        title: 'Crear promoción',
        content: 'Formulario en desarrollo',
      ),
    );
  }

  void productosInactivos(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SuccessDialog(
        title: 'Productos inactivos',
        content: 'Función en desarrollo',
      ),
    );
  }

  void pedidosRemotos(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SuccessDialog(
        title: 'Pedidos remotos',
        content: 'Lista en construcción',
      ),
    );
  }

  void atajosTeclado(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atajos de teclado'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• F1 - Ayuda'),
            Text('• F2 - Buscar producto'),
            Text('• Ctrl+N - Nuevo pedido'),
            Text('• Ctrl+E - Editar producto'),
            Text('• Ctrl+S - Guardar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void toggleTheme(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    themeNotifier.toggleTheme();
    final currentMode = ref.read(themeProvider);
    final modeText = currentMode == ThemeMode.dark ? 'oscuro' : 'claro';
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tema cambiado a $modeText')),
    );
  }

  void descanso(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Iniciar descanso'),
        content: const Text('¿Estás seguro de iniciar tu descanso? La caja se bloqueará.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descanso iniciado')),
              );
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }
}