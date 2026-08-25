import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';

class ProveedorCard extends StatelessWidget {
  final ProveedorEntity proveedor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback onDelete; // ✅ NUEVO CALLBACK

  const ProveedorCard({
    super.key,
    required this.proveedor,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActivo,
    required this.onDelete, // ✅ AGREGADO
  });

  @override
  Widget build(BuildContext context) {
    final color = proveedor.activo ? Colors.green.shade400 : Colors.red.shade400;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proveedor.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (proveedor.empresa != null && proveedor.empresa!.isNotEmpty)
                      Text(
                        proveedor.empresa!,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    Row(
                      children: [
                        Icon(Icons.phone_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          proveedor.telefono ?? 'Sin teléfono',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.badge_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          proveedor.cedula ?? 'Sin RIF',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: proveedor.activo
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      proveedor.activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: proveedor.activo ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        onPressed: onEdit,
                        color: const Color(0xFF8B5CF6),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          proveedor.activo
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 18,
                        ),
                        onPressed: onToggleActivo,
                        color: proveedor.activo ? Colors.orange : Colors.green,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // ✅ NUEVO BOTÓN DE ELIMINAR
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
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