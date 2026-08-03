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
    final theme = Theme.of(context);
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
                Icons.coffee,
                color: theme.brightness == Brightness.dark
                    ? Colors.orange.shade300
                    : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Tomar Descanso',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          content: Text(
            'La caja se bloqueará y requerirá un PIN para volver a ingresar.',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.textTheme.bodyMedium?.color,
              ),
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

                // 2. Actualizar estado en Supabase (Nube)
                await syncService.actualizarEstadoUsuarioEnSupabase(usuario.id, 'en_descanso');

                // 3. Bloquear la pantalla
                ref.read(lockProvider.notifier).manualRest();
              },
              child: const Text(
                'Confirmar Descanso',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return IconButton(
      icon: Icon(
        Icons.coffee,
        color: theme.brightness == Brightness.dark
            ? Colors.orange.shade300
            : Colors.orange,
      ),
      tooltip: 'Tomar Descanso',
      onPressed: handleRest,
    );
  }
}