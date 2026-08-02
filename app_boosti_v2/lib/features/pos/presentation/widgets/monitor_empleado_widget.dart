import 'dart:async';
import 'package:flutter/material.dart';
import '../../presentation/services/sync_service.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';

class EmployeeMonitorDialog extends StatefulWidget {
  const EmployeeMonitorDialog({super.key});

  @override
  State<EmployeeMonitorDialog> createState() => _EmployeeMonitorDialogState();
}

class _EmployeeMonitorDialogState extends State<EmployeeMonitorDialog> {
  final SyncService _syncService = SyncService();
  // Variable para almacenar la suscripción y poder cancelarla al cerrar el modal
  StreamSubscription? _realtimeSub;

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.monitor_heart_outlined, color: Color(0xFF3B82F6), size: 28),
          SizedBox(width: 10),
          Text('Monitor en Tiempo Real', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 360,
        // CAMBIO: De FutureBuilder a StreamBuilder
        child: StreamBuilder<List<UsuarioEntity>>(
          stream: _syncService.streamUsuariosEnTiempoReal(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 13)));
            }
            
            final usuarios = snapshot.data ?? [];
            if (usuarios.isEmpty) {
              return const Center(child: Text('No hay cajeros registrados.', style: TextStyle(color: Color(0xFF64748B))));
            }

            return ListView.separated(
              itemCount: usuarios.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                Color colorEstado;
                IconData iconoEstado;
                String textoEstado;

                final estado = (usuario.estado ?? 'inactivo').toLowerCase();
                switch (estado) {
                  case 'activo':
                    colorEstado = const Color(0xFF10B981);
                    iconoEstado = Icons.point_of_sale;
                    textoEstado = 'Activo';
                    break;
                  case 'descanso':
                  case 'manualrest':
                    colorEstado = Colors.orange;
                    iconoEstado = Icons.coffee;
                    textoEstado = 'En Descanso';
                    break;
                  default:
                    colorEstado = const Color(0xFF64748B);
                    iconoEstado = Icons.power_off;
                    textoEstado = 'Inactivo';
                }

                return ListTile(
                  leading: CircleAvatar(backgroundColor: colorEstado.withValues(alpha: 0.15), child: Icon(iconoEstado, color: colorEstado, size: 20)),
                  title: Text(usuario.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Rol: ${usuario.rol.toUpperCase()} | Caja: ${usuario.cajaAsignada ?? "No asignada"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: colorEstado.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: colorEstado.withValues(alpha: 0.5))), child: Text(textoEstado, style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12))),
                );
              },
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar'))],
    );
  }
}