// lib/features/pos/presentation/widgets/marcas/marcas_managment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/marca_entity.dart';
import '../../providers/marca_provider.dart';
import '../../utils/responsive_helper.dart';
import '../common/card_action_button.dart';
import '../common/dialog_header.dart';
import '../common/glass_card.dart';
import '../common/glass_dialog.dart';
import '../common/glass_search_bar.dart';
import '../common/metric_pedido.dart';
import '../common/segmented_toggle.dart';
import '../common/status_badge.dart';
import 'marca_form_dialog.dart';

enum _FiltroMarca { todas, activas, inactivas }

class MarcasManagementDialog extends ConsumerStatefulWidget {
  const MarcasManagementDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const MarcasManagementDialog(),
    );
  }

  @override
  ConsumerState<MarcasManagementDialog> createState() =>
      _MarcasManagementDialogState();
}

class _MarcasManagementDialogState
    extends ConsumerState<MarcasManagementDialog> {
  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorDanger = Color(0xFFEF4444);

  final _searchController = TextEditingController();
  String _searchQuery = '';
  _FiltroMarca _filtro = _FiltroMarca.todas;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  // FILTRADO
  // ════════════════════════════════════════════════════════════

  List<MarcaEntity> _filtrar(List<MarcaEntity> marcas) {
    var filtered = marcas;

    switch (_filtro) {
      case _FiltroMarca.activas:
        filtered = filtered.where((m) => m.activo).toList();
      case _FiltroMarca.inactivas:
        filtered = filtered.where((m) => !m.activo).toList();
      case _FiltroMarca.todas:
        break;
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

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final marcasAsync = ref.watch(marcasNotifierProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      accentColor: _colorPrimary,
      maxWidth: 800,
      maxHeightFactor: 0.9,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 32,
        vertical: isMobile ? 12 : 32,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═════ HEADER ═════
            const DialogHeader(
              icon: Icons.branding_watermark_rounded,
              title: 'Gestión de Marcas',
              subtitle: 'Administra las marcas de tus productos',
              color: _colorPrimary,
            ),
            const SizedBox(height: 16),

            // ═════ CONTENIDO ═════
            Flexible(
              child: AnimatedSwitcher(
                // ✅ Solo fade, 150ms, curva simple → barato y suave.
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: marcasAsync.when(
                  data: (marcas) => _buildDataState(
                    // ✅ Key estable: solo cambia cuando cambia el filtro,
                    //    así el switcher no re-anima al escribir en el search.
                    key: ValueKey('data-$_filtro'),
                    marcas: marcas,
                    colorScheme: colorScheme,
                    isMobile: isMobile,
                  ),
                  loading: () => const Padding(
                    key: ValueKey('loading'),
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => _buildErrorState(
                    key: const ValueKey('error'),
                    error: err,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ═════ BOTÓN CREAR ═════
            _CrearMarcaButton(
              color: _colorPrimary,
              isMobile: isMobile,
              onPressed: () => _mostrarFormulario(context, null),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // DATA STATE
  // ════════════════════════════════════════════════════════════

  Widget _buildDataState({
    required Key key,
    required List<MarcaEntity> marcas,
    required ColorScheme colorScheme,
    required bool isMobile,
  }) {
    final filtradas = _filtrar(marcas);

    final totalActivas = marcas.where((m) => m.activo).length;
    final totalInactivas = marcas.length - totalActivas;

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Métricas (solo si hay marcas)
        if (marcas.isNotEmpty) ...[
          Row(
            children: [
              MetricPedido(
                label: 'Total',
                value: marcas.length,
                color: _colorPrimary,
                icon: Icons.branding_watermark_outlined,
              ),
              const SizedBox(width: 8),
              MetricPedido(
                label: 'Activas',
                value: totalActivas,
                color: _colorSuccess,
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              MetricPedido(
                label: 'Inactivas',
                value: totalInactivas,
                color: _colorDanger,
                icon: Icons.cancel_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Búsqueda
        GlassSearchBar(
          hint: 'Buscar marca...',
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 12),

        // Filtros
        SegmentedToggle<_FiltroMarca>(
          accentColor: _colorPrimary,
          selected: _filtro,
          onChanged: (v) => setState(() => _filtro = v),
          compact: isMobile,
          items: const [
            SegmentedToggleItem(
              value: _FiltroMarca.todas,
              label: 'Todas',
              icon: Icons.list_alt_rounded,
            ),
            SegmentedToggleItem(
              value: _FiltroMarca.activas,
              label: 'Activas',
              icon: Icons.check_circle_rounded,
            ),
            SegmentedToggleItem(
              value: _FiltroMarca.inactivas,
              label: 'Inactivas',
              icon: Icons.cancel_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista o empty states
        if (marcas.isEmpty)
          _buildEmptyGlobal(colorScheme)
        else if (filtradas.isEmpty)
          _buildEmptyFiltro(colorScheme, isMobile)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: filtradas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _MarcaCard(
              marca: filtradas[i],
              colorPrimary: _colorPrimary,
              colorSuccess: _colorSuccess,
              colorWarning: _colorWarning,
              colorDanger: _colorDanger,
              isMobile: isMobile,
              onEditar: () => _mostrarFormulario(context, filtradas[i]),
              onToggle: () => _toggleActivo(filtradas[i]),
              onEliminar: () => _confirmarEliminacion(filtradas[i]),
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // EMPTY STATES
  // ════════════════════════════════════════════════════════════

  Widget _buildEmptyGlobal(ColorScheme colorScheme) {
    return _emptyContainer(
      colorScheme: colorScheme,
      icon: Icons.branding_watermark_rounded,
      color: _colorPrimary,
      title: 'No hay marcas',
      subtitle: 'Crea tu primera marca para empezar',
    );
  }

  Widget _buildEmptyFiltro(ColorScheme colorScheme, bool isMobile) {
    final esBusqueda = _searchQuery.isNotEmpty;
    return _emptyContainer(
      colorScheme: colorScheme,
      icon: esBusqueda
          ? Icons.search_off_rounded
          : Icons.filter_alt_off_rounded,
      color: _colorPrimary,
      title: esBusqueda
          ? 'Sin resultados'
          : _filtro == _FiltroMarca.activas
              ? 'No hay marcas activas'
              : 'No hay marcas inactivas',
      subtitle: esBusqueda
          ? 'No hay coincidencias para "$_searchQuery"'
          : 'Cambia el filtro para ver otras marcas',
    );
  }

  Widget _emptyContainer({
    required ColorScheme colorScheme,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ERROR STATE
  // ════════════════════════════════════════════════════════════

  Widget _buildErrorState({
    required Key key,
    required Object error,
    required ColorScheme colorScheme,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40, color: colorScheme.error),
          const SizedBox(height: 10),
          Text(
            'Error al cargar marcas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(marcasNotifierProvider.notifier).cargarMarcas(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ACCIONES
  // ════════════════════════════════════════════════════════════

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

  Future<void> _toggleActivo(MarcaEntity marca) async {
    final notifier = ref.read(marcasNotifierProvider.notifier);
    marca.activo = !marca.activo;
    await notifier.actualizarMarca(marca);
    await notifier.cargarMarcas();
  }

  Future<void> _confirmarEliminacion(MarcaEntity marca) async {
    final confirm = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final isar = IsarService();
    final eliminada = await isar.eliminarMarca(marca.id);

    if (!mounted) return;

    if (eliminada) {
      ref.read(marcasNotifierProvider.notifier).cargarMarcas();
      _mostrarMensaje('Marca eliminada correctamente');
    } else {
      _mostrarMensaje('Marca desactivada (tiene productos asociados)');
    }
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

// ══════════════════════════════════════════════════════════════
// CARD DE MARCA
// ══════════════════════════════════════════════════════════════

class _MarcaCard extends StatelessWidget {
  final MarcaEntity marca;
  final Color colorPrimary;
  final Color colorSuccess;
  final Color colorWarning;
  final Color colorDanger;
  final bool isMobile;
  final VoidCallback onEditar;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;

  const _MarcaCard({
    required this.marca,
    required this.colorPrimary,
    required this.colorSuccess,
    required this.colorWarning,
    required this.colorDanger,
    required this.isMobile,
    required this.onEditar,
    required this.onToggle,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = marca.activo;
    final estadoColor = isActive ? colorSuccess : colorDanger;
    final tieneLogo = marca.logoUrl != null && marca.logoUrl!.isNotEmpty;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 14,
        vertical: 10,
      ),
      showStatusBar: true,
      statusColor: estadoColor,
      nestedGlass: true,
      child: Row(
        children: [
          // Logo / avatar
          CircleAvatar(
            radius: isMobile ? 18 : 20,
            backgroundColor: colorPrimary.withValues(alpha: 0.12),
            child: tieneLogo
                ? ClipOval(
                    child: Image.network(
                      marca.logoUrl!,
                      width: isMobile ? 36 : 40,
                      height: isMobile ? 36 : 40,
                      fit: BoxFit.cover,
                      // ✅ cacheWidth reduce memoria en listas largas
                      cacheWidth: isMobile ? 72 : 80,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.branding_watermark_rounded,
                        color: colorPrimary,
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                  )
                : Icon(
                    Icons.branding_watermark_rounded,
                    color: colorPrimary,
                    size: isMobile ? 18 : 20,
                  ),
          ),
          const SizedBox(width: 12),

          // Nombre + descripción + badge
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
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 14 : 15,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: isActive ? 'Activa' : 'Inactiva',
                      color: estadoColor,
                      size: StatusBadgeSize.small,
                    ),
                  ],
                ),
                if (marca.descripcion?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 3),
                  Text(
                    marca.descripcion!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Acciones
          CardActionButton(
            icon: Icons.edit_outlined,
            color: colorPrimary,
            tooltip: 'Editar',
            iconSize: isMobile ? 22 : 20,
            padding: EdgeInsets.all(isMobile ? 10 : 8),
            onPressed: onEditar,
          ),
          CardActionButton(
            icon: isActive
                ? Icons.block_outlined
                : Icons.check_circle_outline,
            color: isActive ? colorWarning : colorSuccess,
            tooltip: isActive ? 'Desactivar' : 'Activar',
            iconSize: isMobile ? 22 : 20,
            padding: EdgeInsets.all(isMobile ? 10 : 8),
            onPressed: onToggle,
          ),
          CardActionButton(
            icon: Icons.delete_outline,
            color: colorDanger,
            tooltip: 'Eliminar',
            iconSize: isMobile ? 22 : 20,
            padding: EdgeInsets.all(isMobile ? 10 : 8),
            onPressed: onEliminar,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTÓN CREAR MARCA
// ══════════════════════════════════════════════════════════════

class _CrearMarcaButton extends StatefulWidget {
  final Color color;
  final bool isMobile;
  final VoidCallback onPressed;

  const _CrearMarcaButton({
    required this.color,
    required this.isMobile,
    required this.onPressed,
  });

  @override
  State<_CrearMarcaButton> createState() => _CrearMarcaButtonState();
}

class _CrearMarcaButtonState extends State<_CrearMarcaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          // ✅ 120ms, easeOut → suficiente para feedback sin coste.
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: widget.isMobile ? 14 : 13,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? Color.lerp(widget.color, Colors.black, 0.12)
                : widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withValues(alpha: _hovered ? 0.40 : 0.25),
                blurRadius: _hovered ? 14 : 8,
                offset: Offset(0, _hovered ? 3 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: widget.isMobile ? 18 : 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Crear nueva marca',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: widget.isMobile ? 13 : 13.5,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}