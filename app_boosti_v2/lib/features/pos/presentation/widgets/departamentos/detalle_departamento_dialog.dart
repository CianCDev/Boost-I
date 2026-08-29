// lib/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class DetalleDepartamentoDialog extends ConsumerWidget {
  final DepartamentoEntity departamento;

  const DetalleDepartamentoDialog({super.key, required this.departamento});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAsync = departamento.localId != null
        ? ref.watch(localPorIdProvider(departamento.localId!))
        : const AsyncValue<LocalEntity?>.data(null);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final Color estadoColor = departamento.activo ? Colors.green.shade500 : Colors.red.shade400;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business_center_rounded,
                      color: const Color(0xFF8B5CF6),
                      size: isMobile ? 24 : 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          departamento.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 22,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: estadoColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                departamento.activo ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: estadoColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (departamento.supabaseId != null)
                              Text(
                                'ID: ${departamento.supabaseId!.substring(0, 8)}...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // INFORMACIÓN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.description_rounded,
                      'Descripción',
                      departamento.descripcion ?? 'Sin descripción',
                      colorScheme,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      context,
                      Icons.storefront_rounded,
                      'Local asociado',
                      localAsync.when(
                        data: (local) => local?.nombre ?? 'Sin local asignado',
                        loading: () => 'Cargando...',
                        error: (_, _) => 'Error al cargar',
                      ),
                      colorScheme,
                    ),
                    if (departamento.createdAt != null) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        context,
                        Icons.calendar_today_rounded,
                        'Creado',
                        '${departamento.createdAt!.day}/${departamento.createdAt!.month}/${departamento.createdAt!.year}',
                        colorScheme,
                      ),
                    ],
                    if (departamento.updatedAt != null) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        context,
                        Icons.update_rounded,
                        'Actualizado',
                        '${departamento.updatedAt!.day}/${departamento.updatedAt!.month}/${departamento.updatedAt!.year}',
                        colorScheme,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // NOTA INFORMATIVA
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: const Color(0xFF8B5CF6), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los productos de este departamento se pueden gestionar desde el inventario.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}