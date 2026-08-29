import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/marca_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/marca_provider.dart';
import '../../utils/responsive_helper.dart';
import 'marca_form_dialog.dart';

/// Diálogo para gestionar marcas (CRUD)
class MarcasManagementDialog extends ConsumerStatefulWidget {
  const MarcasManagementDialog({super.key});

  @override
  ConsumerState<MarcasManagementDialog> createState() =>
      _MarcasManagementDialogState();
}

class _MarcasManagementDialogState
    extends ConsumerState<MarcasManagementDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'todas'; // 'todas', 'activas', 'inactivas'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marcasAsync = ref.watch(marcasNotifierProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colorScheme, isMobile),
            const SizedBox(height: 16),
            _buildSearchAndFilters(colorScheme, isMobile),
            const SizedBox(height: 16),
            Expanded(
              child: marcasAsync.when(
                data: (marcas) => _buildList(marcas, colorScheme, isMobile),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar marcas: $err',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(marcasNotifierProvider.notifier).cargarMarcas();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(ColorScheme colorScheme, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.branding_watermark_rounded,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Gestión de Marcas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 20 : 24,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ==================== BÚSQUEDA Y FILTROS ====================
  Widget _buildSearchAndFilters(ColorScheme colorScheme, bool isMobile) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar marca...',
            prefixIcon: Icon(Icons.search, color: colorScheme.primary),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFilterChip('Todas', 'todas', colorScheme),
            const SizedBox(width: 8),
            _buildFilterChip('Activas', 'activas', colorScheme),
            const SizedBox(width: 8),
            _buildFilterChip('Inactivas', 'inactivas', colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, ColorScheme colorScheme) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      filtered = filtered.where((m) =>
          m.nombre.toLowerCase().contains(q) ||
          (m.descripcion ?? '').toLowerCase().contains(q)).toList();
    }

    return filtered;
  }

  // ==================== LISTA DE MARCAS ====================
  Widget _buildList(List<MarcaEntity> allMarcas, ColorScheme colorScheme, bool isMobile) {
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
              _searchQuery.isNotEmpty ? 'No se encontraron marcas' : 'No hay marcas',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otra búsqueda'
                  : 'Crea tu primera marca',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: marcas.length,
      separatorBuilder: (_, _) => Divider(
        color: colorScheme.outline.withValues(alpha: 0.1),
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        child: marca.logoUrl != null && marca.logoUrl!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  marca.logoUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.branding_watermark_rounded,
                    color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Icon(
                Icons.branding_watermark_rounded,
                color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
      ),
      title: Text(
        marca.nombre,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (marca.descripcion != null && marca.descripcion!.isNotEmpty)
            Text(
              marca.descripcion!,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: [
              Icon(
                isActive ? Icons.circle : Icons.circle_outlined,
                size: 10,
                color: isActive ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
            tooltip: 'Editar',
            onPressed: () => _mostrarFormulario(context, marca),
          ),
          IconButton(
            icon: Icon(
              isActive ? Icons.block_outlined : Icons.check_circle_outline,
              color: isActive ? Colors.orange : Colors.green,
            ),
            tooltip: isActive ? 'Desactivar' : 'Activar',
            onPressed: () => _toggleActivo(marca),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Eliminar',
            onPressed: () => _confirmarEliminacion(marca),
          ),
        ],
      ),
    );
  }

  // ==================== ACCIONES ====================
  Widget _buildActions() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _mostrarFormulario(context, null),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Crear nueva marca'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ==================== MÉTODOS DE ACCIÓN ====================
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
      builder: (context) => AlertDialog(
        title: const Text('Eliminar marca'),
        content: Text(
          '¿Estás seguro de eliminar la marca "${marca.nombre}"?\n\n'
          'Si tiene productos asociados, solo se desactivará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final isar = IsarService();
              final eliminada = await isar.eliminarMarca(marca.id);

              if (!mounted) return;

              if (eliminada) {
                ref.read(marcasNotifierProvider.notifier).cargarMarcas();
                _mostrarMensaje('Marca eliminada correctamente');
              } else {
                _mostrarMensaje('Marca desactivada (tiene productos asociados)');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}