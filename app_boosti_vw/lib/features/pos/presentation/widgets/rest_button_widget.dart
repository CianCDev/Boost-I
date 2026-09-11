import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../presentation/services/sync_service.dart';
import '../../presentation/providers/lock_provider.dart';

class CajeroRestButton extends ConsumerWidget {
  final UsuarioEntity usuario;

  const CajeroRestButton({super.key, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarService = IsarService();
    final syncService = SyncService();

    // Solo mostramos el botón si el usuario es cajero
    if (usuario.rol.toLowerCase() != 'cajero') {
      return const SizedBox.shrink();
    }

    void handleRest() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.coffee, color: Colors.orange),
              SizedBox(width: 8),
              Text('Tomar Descanso', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('La caja se bloqueará y requerirá un PIN para volver a ingresar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                
                // 1. Actualizar estado en Isar (Local)
                await isarService.actualizarEstadoUsuario(usuario.id, 'en_descanso');
                
                await syncService.actualizarEstadoUsuarioEnSupabase(usuario.id, 'en_descanso');
                // 3. Bloquear la pantalla
                ref.read(lockProvider.notifier).manualRest();
              },
              child: const Text('Confirmar Descanso', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.coffee, color: Colors.orange),
      tooltip: 'Tomar Descanso',
      onPressed: handleRest,
    );
  }
}
