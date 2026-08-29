// lib/features/pos/presentation/widgets/locales/detalle_local_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
// ignore: unused_import
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class DetalleLocalDialog extends ConsumerStatefulWidget {
  final LocalEntity local;

  const DetalleLocalDialog({super.key, required this.local});

  @override
  ConsumerState<DetalleLocalDialog> createState() => _DetalleLocalDialogState();
}

class _DetalleLocalDialogState extends ConsumerState<DetalleLocalDialog> {
  @override
  Widget build(BuildContext context) {
    final departamentosAsync = ref.watch(
      departamentosActivosProvider(widget.local.id)
    );
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final Color estadoColor = widget.local.activo ? Colors.green.shade500 : Colors.red.shade400;

    // Padding adaptativo
    final double dialogPadding = isMobile ? 16 : 24;
    final double innerPadding = isMobile ? 12 : 16;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        padding: EdgeInsets.all(dialogPadding),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== HEADER ==========
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
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
                        widget.local.nombre,
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
                              widget.local.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: estadoColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.local.supabaseId != null)
                            Text(
                              'ID: ${widget.local.supabaseId!.substring(0, 8)}...',
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

            // ========== INFORMACIÓN ==========
            Container(
              padding: EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.location_on_rounded,
                    'Dirección',
                    widget.local.direccion ?? 'No registrada',
                    colorScheme,
                    isMobile,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    Icons.phone_rounded,
                    'Teléfono',
                    widget.local.telefono ?? 'No registrado',
                    colorScheme,
                    isMobile,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    Icons.email_rounded,
                    'Correo',
                    widget.local.email ?? 'No registrado',
                    colorScheme,
                    isMobile,
                  ),
                  if (widget.local.createdAt != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today_rounded,
                      'Creado',
                      '${widget.local.createdAt!.day}/${widget.local.createdAt!.month}/${widget.local.createdAt!.year}',
                      colorScheme,
                      isMobile,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ========== DEPARTAMENTOS ASOCIADOS ==========
            Row(
              children: [
                Icon(Icons.business_center_rounded, color: const Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Departamentos asociados',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton.icon(
                      onPressed: () => _crearDepartamentoDesdeLocal(),
                      icon: Icon(Icons.add_rounded, size: isMobile ? 20 : 18),
                      label: isMobile
                          ? const SizedBox.shrink()
                          : const Text('Agregar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 12,
                          vertical: isMobile ? 8 : 8,
                        ),
                        minimumSize: isMobile ? const Size(40, 40) : null,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: departamentosAsync.when(
                data: (departamentos) {
                  if (departamentos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sin departamentos',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Agrega un departamento a este local',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: departamentos.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = departamentos[index];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            child: Icon(
                              Icons.business_center_rounded,
                              size: 16,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          title: Text(
                            d.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              fontSize: isMobile ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: d.descripcion != null && d.descripcion!.isNotEmpty
                              ? Text(
                                  d.descripcion!,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: isMobile ? 12 : 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : null,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: d.activo ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: d.activo ? Colors.green : Colors.red,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              d.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: d.activo ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          onTap: () => _mostrarDetalleDepartamento(d),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        SizedBox(
          width: isMobile ? 60 : 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 12 : 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isMobile ? 12 : 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  // ========== ACCIONES ==========

  Future<void> _crearDepartamentoDesdeLocal() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CrearDepartamentoDialog(
        localIdPreseleccionado: widget.local.id,
      ),
    );
    if (result == true && mounted) {
      ref.invalidate(departamentosActivosProvider(widget.local.id));
      // ✅ Verificar mounted antes de setState
      if (mounted) setState(() {});
    }
  }

  void _mostrarDetalleDepartamento(DepartamentoEntity departamento) {
    showDialog(
      context: context,
      builder: (_) => DetalleDepartamentoDialog(departamento: departamento),
    );
  }
}