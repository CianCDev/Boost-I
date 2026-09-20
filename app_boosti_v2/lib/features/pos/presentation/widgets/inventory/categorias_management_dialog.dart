// lib/features/pos/presentation/widgets/inventory/categorias_management_dialog.dart
import 'package:app_boosti_v2/features/pos/presentation/providers/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/categoria_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/categorias_provider.dart';
import '../../providers/productos_provider.dart';
import '../../utils/responsive_helper.dart';
import '../common/card_action_button.dart';
import '../common/dialog_header.dart';
import '../common/glass_card.dart';
import '../common/glass_dialog.dart';
import '../common/metric_pedido.dart';
import 'categoria_form_dialog.dart';

class CategoriasManagementDialog extends ConsumerStatefulWidget {
  const CategoriasManagementDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const CategoriasManagementDialog(),
    );
  }

  @override
  ConsumerState<CategoriasManagementDialog> createState() =>
      _CategoriasManagementDialogState();
}

class _CategoriasManagementDialogState
    extends ConsumerState<CategoriasManagementDialog> {
  static const _colorPrimary = Color(0xFF10B981);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorDanger = Color(0xFFEF4444);

  final _newCategoryController = TextEditingController();
  final _focusNode = FocusNode();
  bool _migrando = false;

  /// ✅ NUEVO: muestra las categorías inactivas en la lista.
  bool _mostrarInactivas = false;

  @override
  void initState() {
    super.initState();
    // Refresca el estado al abrir el diálogo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(categoriasNotifierProvider.notifier).refrescar();
    });
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  // ACCIONES
  // ════════════════════════════════════════════════════════════

  Future<void> _agregarCategoria() async {
    final value = _newCategoryController.text.trim();
    if (value.isEmpty) return;

    await ref
        .read(categoriasNotifierProvider.notifier)
        .agregarCategoria(value);

    _newCategoryController.clear();
    _focusNode.requestFocus();
  }

  Future<void> _migrarCategorias() async {
    if (_migrando) return;
    setState(() => _migrando = true);

    try {
      final isar = IsarService();
      final productos = await isar.obtenerProductos();
      final categorias = await isar.obtenerCategorias(soloActivas: false);
      final Map<String, int> mapaCategorias = {
        for (var cat in categorias) cat.nombre: cat.id,
      };

      int actualizados = 0;
      int sinCategoria = 0;

      for (var p in productos) {
        if (p.categoriaId == null) {
          final nombreCat = p.categoria.trim();
          final idCat = mapaCategorias[nombreCat];
          if (idCat != null) {
            p.categoriaId = idCat;
            await isar.guardarProducto(p);
            actualizados++;
          } else {
            sinCategoria++;
          }
        }
      }

      debugPrint(
        '✅ Migración: $actualizados actualizados, $sinCategoria sin categoría',
      );

      if (!mounted) return;
      await ref.read(categoriasNotifierProvider.notifier).refrescar();
      await ref.read(productosProvider.notifier).cargarProductos();

      if (!mounted) return;
      _snack(
        'Migración completada: $actualizados productos actualizados',
        _colorPrimary,
      );
    } catch (e) {
      debugPrint('❌ Error al migrar: $e');
      if (!mounted) return;
      _snack('Error: $e', _colorDanger);
    } finally {
      if (mounted) setState(() => _migrando = false);
    }
  }

  Future<void> _editarCategoria(CategoriaEntity categoria) async {
    final nuevoNombre = await showDialog<String>(
      context: context,
      builder: (_) => CategoriaFormDialog(
        categoriaExistente: categoria.nombre,
      ),
    );
    if (nuevoNombre != null && nuevoNombre.isNotEmpty) {
      await ref
          .read(categoriasNotifierProvider.notifier)
          .editarCategoria(categoria.id, nuevoNombre);
    }
  }

  Future<void> _eliminarCategoria(CategoriaEntity categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Desactivar categoría'),
        content: Text(
          '¿Desactivar "${categoria.nombre}"? '
          'Los productos asociados quedarán sin categoría y la categoría '
          'se ocultará de los formularios (podrás reactivarla luego).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref
        .read(categoriasNotifierProvider.notifier)
        .eliminarCategoria(categoria.id);
  }

  /// ✅ NUEVO: Reactiva una categoría previamente desactivada.
  Future<void> _reactivarCategoria(CategoriaEntity categoria) async {
    await ref
        .read(categoriasNotifierProvider.notifier)
        .reactivarCategoria(categoria.id);

    if (!mounted) return;
    _snack('Categoría "${categoria.nombre}" reactivada', _colorPrimary);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final todasAsync = ref.watch(todasLasCategoriasProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return GlassDialog(
      accentColor: _colorPrimary,
      maxWidth: 560,
      maxHeightFactor: 0.88,
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
            DialogHeader(
              icon: Icons.category_rounded,
              title: 'Gestionar categorías',
              subtitle: todasAsync.maybeWhen(
                data: (list) {
                  final activas = list.where((c) => c.activo).length;
                  final inactivas = list.length - activas;
                  if (inactivas == 0) {
                    return '$activas activa${activas == 1 ? '' : 's'}';
                  }
                  return '$activas activas · $inactivas inactiva'
                      '${inactivas == 1 ? '' : 's'}';
                },
                orElse: () => 'Cargando...',
              ),
              color: _colorPrimary,
            ),
            const SizedBox(height: 16),

            // ═════ MÉTRICAS ═════
            todasAsync.maybeWhen(
              data: (list) {
                if (list.isEmpty) return const SizedBox.shrink();
                final activas = list.where((c) => c.activo).length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      MetricPedido(
                        label: 'Total',
                        value: list.length,
                        color: _colorPrimary,
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(width: 8),
                      MetricPedido(
                        label: 'Activas',
                        value: activas,
                        color: primaryGreen,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(width: 8),
                      MetricPedido(
                        label: 'Inactivas',
                        value: list.length - activas,
                        color: _colorDanger,
                        icon: Icons.visibility_off_outlined,
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),

            // ═════ INPUT + BOTÓN AGREGAR ═════
            _buildAddCategoryRow(cs, isDark, isMobile),
            const SizedBox(height: 12),

            // ═════ TOGGLE MOSTRAR INACTIVAS ═════
            _buildToggleInactivas(cs, isMobile),
            const SizedBox(height: 12),

            // ═════ BOTÓN MIGRAR ═════
            _MigrarButton(
              color: _colorWarning,
              isMobile: isMobile,
              isLoading: _migrando,
              onPressed: _migrando ? null : _migrarCategorias,
            ),
            const SizedBox(height: 16),

            // ═════ LISTA / EMPTY STATE ═════
            Flexible(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                      sizeFactor: anim,
                      // ignore: deprecated_member_use
                      axisAlignment: -1,
                      child: child,
                    ),
                  ),
                  child: todasAsync.when(
                    data: (todas) {
                      final visibles = _mostrarInactivas
                          ? todas
                          : todas.where((c) => c.activo).toList();

                      if (visibles.isEmpty) {
                        return _buildEmptyState(
                          key: ValueKey(
                            _mostrarInactivas ? 'empty-all' : 'empty-active',
                          ),
                          colorScheme: cs,
                          mostrarInactivas: _mostrarInactivas,
                          hayInactivas: todas.any((c) => !c.activo),
                          onMostrarInactivas: () =>
                              setState(() => _mostrarInactivas = true),
                        );
                      }

                      return ListView.separated(
                        key: ValueKey(
                          _mostrarInactivas ? 'list-all' : 'list-active',
                        ),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: visibles.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final cat = visibles[i];
                          return _CategoriaCard(
                            categoria: cat,
                            colorPrimary: _colorPrimary,
                            colorSuccess: _colorPrimary,
                            colorDanger: _colorDanger,
                            isMobile: isMobile,
                            onEditar: () => _editarCategoria(cat),
                            onToggleEstado: cat.activo
                                ? () => _eliminarCategoria(cat)
                                : () => _reactivarCategoria(cat),
                          );
                        },
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error: $err',
                        style: TextStyle(color: _colorDanger),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ADD CATEGORY ROW
  // ════════════════════════════════════════════════════════════

  Widget _buildAddCategoryRow(
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _newCategoryController,
            focusNode: _focusNode,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            onSubmitted: (_) => _agregarCategoria(),
            decoration: InputDecoration(
              hintText: 'Nueva categoría...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.add_rounded,
                color: _colorPrimary,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _colorPrimary,
                  width: 1.6,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _AddButton(
          color: _colorPrimary,
          isMobile: isMobile,
          onPressed: _agregarCategoria,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // TOGGLE MOSTRAR INACTIVAS
  // ════════════════════════════════════════════════════════════

  Widget _buildToggleInactivas(ColorScheme cs, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _mostrarInactivas
                ? 'Mostrando todas (activas + inactivas)'
                : 'Mostrando solo activas',
            style: TextStyle(
              fontSize: isMobile ? 11.5 : 12,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        FilterChip(
          label: Text(
            _mostrarInactivas ? 'Ocultar inactivas' : 'Ver inactivas',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight:
                  _mostrarInactivas ? FontWeight.bold : FontWeight.w600,
              color: _mostrarInactivas ? _colorPrimary : cs.onSurfaceVariant,
            ),
          ),
          selected: _mostrarInactivas,
          onSelected: (v) => setState(() => _mostrarInactivas = v),
          selectedColor: _colorPrimary.withValues(alpha: 0.15),
          checkmarkColor: _colorPrimary,
          backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          side: BorderSide(
            color: _mostrarInactivas
                ? _colorPrimary.withValues(alpha: 0.4)
                : cs.outlineVariant.withValues(alpha: 0.4),
          ),
          showCheckmark: false,
          avatar: Icon(
            _mostrarInactivas
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            size: 14,
            color: _mostrarInactivas
                ? _colorPrimary
                : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════

  Widget _buildEmptyState({
    Key? key,
    required ColorScheme colorScheme,
    required bool mostrarInactivas,
    required bool hayInactivas,
    required VoidCallback onMostrarInactivas,
  }) {
    // Caso 1: hay categorías pero todas inactivas y no estamos mostrándolas.
    if (!mostrarInactivas && hayInactivas) {
      return Container(
        key: key,
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
                color: _colorWarning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.visibility_off_outlined,
                size: 40,
                color: _colorWarning,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Todas las categorías están inactivas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Actívalas de nuevo o crea una nueva categoría.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onMostrarInactivas,
              icon: const Icon(Icons.visibility_rounded, size: 16),
              label: const Text('Ver inactivas'),
              style: TextButton.styleFrom(
                foregroundColor: _colorPrimary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _colorPrimary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Caso 2: no hay nada creado todavía.
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
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
              color: _colorPrimary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.category_outlined,
              size: 40,
              color: _colorPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No hay categorías',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Agrega tu primera categoría arriba para\norganizar tus productos',
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
}

// ══════════════════════════════════════════════════════════════
// CARD DE CATEGORÍA
// ══════════════════════════════════════════════════════════════

class _CategoriaCard extends StatelessWidget {
  final CategoriaEntity categoria;
  final Color colorPrimary;
  final Color colorSuccess;
  final Color colorDanger;
  final bool isMobile;
  final VoidCallback onEditar;

  /// ✅ Cambia entre Desactivar (activa) y Reactivar (inactiva).
  final VoidCallback onToggleEstado;

  const _CategoriaCard({
    required this.categoria,
    required this.colorPrimary,
    required this.colorSuccess,
    required this.colorDanger,
    required this.isMobile,
    required this.onEditar,
    required this.onToggleEstado,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activa = categoria.activo;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 14,
        vertical: 8,
      ),
      showStatusBar: true,
      statusColor: activa ? colorPrimary : colorDanger,
      nestedGlass: true,
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activa ? colorPrimary : colorDanger)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              activa
                  ? Icons.category_outlined
                  : Icons.visibility_off_outlined,
              size: isMobile ? 18 : 20,
              color: activa ? colorPrimary : colorDanger,
            ),
          ),
          const SizedBox(width: 12),

          // Nombre + badge
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    categoria.nombre,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w700,
                      color: activa
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!activa) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorDanger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colorDanger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'Inactiva',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF4444),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Acciones
          CardActionButton(
            icon: Icons.edit_outlined,
            color: colorPrimary,
            tooltip: 'Renombrar',
            iconSize: isMobile ? 22 : 20,
            padding: EdgeInsets.all(isMobile ? 10 : 8),
            onPressed: onEditar,
          ),
          CardActionButton(
            icon: activa
                ? Icons.visibility_off_outlined
                : Icons.restore_rounded,
            color: activa ? colorDanger : colorSuccess,
            tooltip: activa ? 'Desactivar' : 'Reactivar',
            iconSize: isMobile ? 22 : 20,
            padding: EdgeInsets.all(isMobile ? 10 : 8),
            onPressed: onToggleEstado,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTÓN AGREGAR (circular con hover)
// ══════════════════════════════════════════════════════════════

class _AddButton extends StatefulWidget {
  final Color color;
  final bool isMobile;
  final VoidCallback onPressed;

  const _AddButton({
    required this.color,
    required this.isMobile,
    required this.onPressed,
  });

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(widget.isMobile ? 14 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.15)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withValues(alpha: _hovered ? 0.45 : 0.28),
                blurRadius: _hovered ? 14 : 8,
                offset: Offset(0, _hovered ? 4 : 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: widget.isMobile ? 20 : 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTÓN MIGRAR
// ══════════════════════════════════════════════════════════════

class _MigrarButton extends StatefulWidget {
  final Color color;
  final bool isMobile;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _MigrarButton({
    required this.color,
    required this.isMobile,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_MigrarButton> createState() => _MigrarButtonState();
}

class _MigrarButtonState extends State<_MigrarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    return MouseRegion(
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 16 : 20,
            vertical: widget.isMobile ? 12 : 11,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: disabled
                  ? [
                      widget.color.withValues(alpha: 0.5),
                      widget.color.withValues(alpha: 0.3),
                    ]
                  : [
                      widget.color,
                      Color.lerp(widget.color, Colors.black, 0.15)!,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: widget.color
                          .withValues(alpha: _hovered ? 0.42 : 0.28),
                      blurRadius: _hovered ? 14 : 8,
                      offset: Offset(0, _hovered ? 4 : 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(
                  Icons.auto_awesome_rounded,
                  size: widget.isMobile ? 18 : 16,
                  color: Colors.white,
                ),
              const SizedBox(width: 8),
              Text(
                widget.isLoading
                    ? 'Migrando...'
                    : 'Migrar categorías existentes',
                style: TextStyle(
                  fontSize: widget.isMobile ? 12.5 : 13,
                  fontWeight: FontWeight.w700,
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