// lib/features/pos/presentation/widgets/marcas/marcas_managment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/marca_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/marca_provider.dart';
import '../../utils/responsive_helper.dart';
import '../common/filtro_chip_template.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/glass_search_bar.dart';
import '../common/status_badge.dart';
import '../common/card_action_button.dart';
import 'marca_form_dialog.dart';

class MarcasManagementDialog extends ConsumerStatefulWidget {
  const MarcasManagementDialog({super.key});

  @override
  ConsumerState<MarcasManagementDialog> createState() =>
      _MarcasManagementDialogState();
}

class _MarcasManagementDialogState
    extends ConsumerState<MarcasManagementDialog> {
  String _searchQuery = '';
  String _filter = 'todas';

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final marcasAsync = ref.watch(marcasNotifierProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 800,
      maxHeightFactor: 0.9,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.branding_watermark_rounded,
              title: 'Gestión de Marcas',
              subtitle: 'Administra las marcas de tus productos',
            ),
            const SizedBox(height: 16),

            // ===== BÚSQUEDA Y FILTROS =====
            _buildSearchAndFilters(colorScheme, isMobile),
            const SizedBox(height: 12),

            // ===== LISTA =====
            Flexible(
              child: marcasAsync.when(
                data: (marcas) =>
                    _buildList(marcas, colorScheme, isMobile),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: colorScheme.error),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar marcas: $err',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(marcasNotifierProvider.notifier)
                              .cargarMarcas();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== BOTÓN CREAR =====
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarFormulario(context, null),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text(
                    'Crear nueva marca',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BÚSQUEDA Y FILTROS ====================
  Widget _buildSearchAndFilters(ColorScheme colorScheme, bool isMobile) {
    return Column(
      children: [
        GlassSearchBar(
          hint: 'Buscar marca...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FiltroChip(
                label: 'Todas',
                icon: Icons.list_alt_rounded,
                color: _colorPrimary,
                selected: _filter == 'todas',
                onTap: () => setState(() => _filter = 'todas'),
                size: FiltroChipSize.small,
              ),
              const SizedBox(width: 8),
              FiltroChip(
                label: 'Activas',
                icon: Icons.check_circle_rounded,
                color: _colorSuccess,
                selected: _filter == 'activas',
                onTap: () => setState(() => _filter = 'activas'),
                size: FiltroChipSize.small,
              ),
              const SizedBox(width: 8),
              FiltroChip(
                label: 'Inactivas',
                icon: Icons.cancel_rounded,
                color: _colorDanger,
                selected: _filter == 'inactivas',
                onTap: () => setState(() => _filter = 'inactivas'),
                size: FiltroChipSize.small,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<MarcaEntity> _marcasFiltradas(List<MarcaEntity> marcas) {
    var filtered = marcas;

    if (_filter == 'activas') {
      filtered = filtered.where((m) => m.activo).toList();
    } else if (_filter == 'inactivas') {
      filtered = filtered.where((m) => !m.activo).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((m) =>
              m.nombre.toLowerCase().contains(q) ||
              (m.descripcion ?? '').toLowerCase().contains(q))
          .toList();
    }

    return filtered;
  }

  // ==================== LISTA ====================
  Widget _buildList(
      List<MarcaEntity> allMarcas, ColorScheme colorScheme, bool isMobile) {
    final marcas = _marcasFiltradas(allMarcas);

    if (marcas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.branding_watermark_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron marcas'
                  : 'No hay marcas',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otra búsqueda'
                  : 'Crea tu primera marca para empezar',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: marcas.length,
      separatorBuilder: (context, index) => Divider(
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final marca = marcas[index];
        return _buildMarcaTile(marca, colorScheme);
      },
    );
  }

  Widget _buildMarcaTile(MarcaEntity marca, ColorScheme colorScheme) {
    final isActive = marca.activo;
    final estadoColor = isActive ? _colorSuccess : _colorDanger;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            child: marca.logoUrl != null && marca.logoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      marca.logoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.branding_watermark_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  )
                : Icon(
                    Icons.branding_watermark_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        marca.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    StatusBadge(
                      label: isActive ? 'Activa' : 'Inactiva',
                      color: estadoColor,
                      size: StatusBadgeSize.small,
                    ),
                  ],
                ),
                if (marca.descripcion?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 2),
                  Text(
                    marca.descripcion!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          CardActionButton(
            icon: Icons.edit_outlined,
            color: colorScheme.primary,
            tooltip: 'Editar',
            onPressed: () => _mostrarFormulario(context, marca),
          ),
          CardActionButton(
            icon: isActive
                ? Icons.block_outlined
                : Icons.check_circle_outline,
            color: isActive ? _colorWarning : _colorSuccess,
            tooltip: isActive ? 'Desactivar' : 'Activar',
            onPressed: () => _toggleActivo(marca),
          ),
          CardActionButton(
            icon: Icons.delete_outline,
            color: _colorDanger,
            tooltip: 'Eliminar',
            onPressed: () => _confirmarEliminacion(marca),
          ),
        ],
      ),
    );
  }

  // ==================== ACCIONES ====================
  void _mostrarFormulario(BuildContext context, MarcaEntity? marca) {
    showDialog(
      context: context,
      builder: (_) => MarcaFormDialog(
        marca: marca,
        onGuardar: () {
          ref.read(marcasNotifierProvider.notifier).cargarMarcas();
        },
      ),
    );
  }

  void _toggleActivo(MarcaEntity marca) async {
    final notifier = ref.read(marcasNotifierProvider.notifier);
    marca.activo = !marca.activo;
    await notifier.actualizarMarca(marca);
    await notifier.cargarMarcas();
  }

  void _confirmarEliminacion(MarcaEntity marca) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar marca'),
        content: Text(
          '¿Estás seguro de eliminar la marca "${marca.nombre}"?\n\n'
          'Si tiene productos asociados, solo se desactivará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final isar = IsarService();
                final eliminada = await isar.eliminarMarca(marca.id);

                if (!mounted) return;

                if (eliminada) {
                  ref.read(marcasNotifierProvider.notifier).cargarMarcas();
                  _mostrarMensaje('Marca eliminada correctamente');
                } else {
                  _mostrarMensaje(
                      'Marca desactivada (tiene productos asociados)');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorDanger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}