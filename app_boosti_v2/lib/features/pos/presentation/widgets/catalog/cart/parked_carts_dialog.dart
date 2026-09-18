// lib/features/pos/presentation/widgets/cart/parked_carts_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/Local/entities/cart_session_entity.dart';
import '../../../controllers/cart_sessions_controller.dart';
import '../../../providers/usuario_provider.dart';
import '../../../utils/responsive_helper.dart';
import '../../common/card_action_button.dart';
import '../../common/dialog_header.dart';
import '../../common/glass_card.dart';
import '../../common/glass_dialog.dart';
import '../../common/glass_search_bar.dart';
import '../../common/metric_pedido.dart';
import '../../common/segmented_toggle.dart';
import '../../common/status_badge.dart';

enum _FiltroEstado { todos, activos, abandonados }

class ParkedCartsDialog extends ConsumerStatefulWidget {
  const ParkedCartsDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ParkedCartsDialog(),
    );
  }

  @override
  ConsumerState<ParkedCartsDialog> createState() => _ParkedCartsDialogState();
}

class _ParkedCartsDialogState extends ConsumerState<ParkedCartsDialog> {
  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  final _searchController = TextEditingController();
  String _query = '';
  _FiltroEstado _filtro = _FiltroEstado.todos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario != null) {
        ref.read(cartSessionsProvider.notifier).cargarSesiones(usuario.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // FILTRADO
  // ────────────────────────────────────────────────────────────

  List<CartSessionEntity> _filtrar(List<CartSessionEntity> input) {
    final q = _query.trim().toLowerCase();
    return input.where((s) {
      switch (_filtro) {
        case _FiltroEstado.activos:
          if (s.esAbandonado) return false;
        case _FiltroEstado.abandonados:
          if (!s.esAbandonado) return false;
        case _FiltroEstado.todos:
          break;
      }
      if (q.isEmpty) return true;
      final nombre = s.nombre.toLowerCase();
      final cliente = (s.clienteNombre ?? '').toLowerCase();
      return nombre.contains(q) || cliente.contains(q);
    }).toList();
  }

  // ────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    final filtradas = _filtrar(state.sessions);

    final totalItems = state.sessions.fold<int>(
      0,
      (sum, s) => sum + s.cantidadItems,
    );
    final totalMonto = state.sessions.fold<double>(
      0,
      (sum, s) => sum + s.total,
    );

    return GlassDialog(
      accentColor: _colorPrimary,
      maxWidth: 720,
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
            DialogHeader(
              icon: Icons.pause_circle_outline_rounded,
              title: 'Carritos en espera',
              subtitle:
                  '${state.count}/$kMaxCarritosEnEspera · '
                  'Puedes atender hasta $kMaxCarritosEnEspera personas a la vez',
              color: _colorPrimary,
            ),
            const SizedBox(height: 16),

            // ═════ MÉTRICAS ═════
            if (state.sessions.isNotEmpty) ...[
              Row(
                children: [
                  MetricPedido(
                    label: 'Carritos',
                    value: state.count,
                    color: _colorPrimary,
                    icon: Icons.shopping_bag_outlined,
                  ),
                  const SizedBox(width: 8),
                  MetricPedido(
                    label: 'Items',
                    value: totalItems,
                    color: _colorSuccess,
                    icon: Icons.inventory_2_outlined,
                  ),
                  const SizedBox(width: 8),
                  MetricPedido(
                    label: 'Total',
                    value: totalMonto.round(),
                    color: _colorWarning,
                    icon: Icons.attach_money_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ═════ BÚSQUEDA + FILTRO ═════
            if (state.sessions.isNotEmpty) ...[
              GlassSearchBar(
                hint: 'Buscar por nombre o cliente...',
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              SegmentedToggle<_FiltroEstado>(
                accentColor: _colorPrimary,
                selected: _filtro,
                onChanged: (v) => setState(() => _filtro = v),
                compact: isMobile,
                items: const [
                  SegmentedToggleItem(
                    value: _FiltroEstado.todos,
                    label: 'Todos',
                    icon: Icons.apps_rounded,
                  ),
                  SegmentedToggleItem(
                    value: _FiltroEstado.activos,
                    label: 'Activos',
                    icon: Icons.access_time_rounded,
                  ),
                  SegmentedToggleItem(
                    value: _FiltroEstado.abandonados,
                    label: 'Abandonados',
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ═════ LISTA ═════
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
                  child: _buildContent(
                    state: state,
                    filtradas: filtradas,
                    colorScheme: colorScheme,
                    isMobile: isMobile,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // CONTENT (state switch)
  // ────────────────────────────────────────────────────────────

  Widget _buildContent({
    required CartSessionsState state,
    required List<CartSessionEntity> filtradas,
    required ColorScheme colorScheme,
    required bool isMobile,
  }) {
    if (state.isLoading) {
      return const Padding(
        key: ValueKey('loading'),
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.sessions.isEmpty) {
      return _buildEmptyState(
        key: const ValueKey('empty'),
        colorScheme: colorScheme,
      );
    }
    if (filtradas.isEmpty) {
      return _buildNoResultados(
        key: const ValueKey('no-results'),
        colorScheme: colorScheme,
      );
    }
    return ListView.separated(
      key: const ValueKey('list'),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: filtradas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _SessionCard(
        session: filtradas[i],
        colorPrimary: _colorPrimary,
        colorSuccess: _colorSuccess,
        colorDanger: _colorDanger,
        colorWarning: _colorWarning,
        isMobile: isMobile,
        onRenombrar: _renombrar,
        onEliminar: _eliminar,
        onRetomar: _retomar,
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // EMPTY STATES
  // ────────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    Key? key,
    required ColorScheme colorScheme,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pause_circle_outline_rounded,
              size: 44,
              color: _colorPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes carritos en espera',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Agrega productos al carrito y presiona\n'
            '"Poner en espera" para atender a otro cliente',
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

  Widget _buildNoResultados({
    Key? key,
    required ColorScheme colorScheme,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _query.isEmpty
                ? 'No hay carritos que coincidan con este filtro'
                : 'No hay coincidencias para "$_query"',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // ACCIONES
  // ────────────────────────────────────────────────────────────

  Future<void> _retomar(CartSessionEntity s) async {
    final notifier = ref.read(cartSessionsProvider.notifier);
    final error = await notifier.retomarSesion(s.sessionId);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: _colorDanger),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Carrito "${s.nombre}" retomado'),
        backgroundColor: _colorSuccess,
      ),
    );
  }

  Future<void> _eliminar(CartSessionEntity s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar carrito'),
        content: Text(
          '¿Eliminar "${s.nombre}"? Los items se perderán permanentemente.',
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await ref.read(cartSessionsProvider.notifier).eliminarSesion(s.sessionId);
  }

  Future<void> _renombrar(CartSessionEntity s) async {
    final controller = TextEditingController(text: s.nombre);
    final nuevo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Renombrar carrito'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej: Mesa 3, Juan, Para llevar',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevo == null) return;
    await ref
        .read(cartSessionsProvider.notifier)
        .renombrarSesion(s.sessionId, nuevo);
  }
}

// ══════════════════════════════════════════════════════════════
// CARD DE SESIÓN
// ══════════════════════════════════════════════════════════════

class _SessionCard extends StatelessWidget {
  final CartSessionEntity session;
  final Color colorPrimary;
  final Color colorSuccess;
  final Color colorDanger;
  final Color colorWarning;
  final bool isMobile;
  final ValueChanged<CartSessionEntity> onRenombrar;
  final ValueChanged<CartSessionEntity> onEliminar;
  final ValueChanged<CartSessionEntity> onRetomar;

  const _SessionCard({
    required this.session,
    required this.colorPrimary,
    required this.colorSuccess,
    required this.colorDanger,
    required this.colorWarning,
    required this.isMobile,
    required this.onRenombrar,
    required this.onEliminar,
    required this.onRetomar,
  });

  /// Nombres de los productos guardados en la sesión.
  /// Fuente única: `CartSessionEntity.itemsNombres`.
  List<String> _previewNombres() {
    return session.itemsNombres
        .where((n) => n.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final abandonado = session.esAbandonado;
    final statusColor = abandonado ? colorDanger : colorWarning;
    final tiempo = _formatearTiempo(session.createdAt);
    final preview = _previewNombres();

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      isHighlighted: abandonado,
      highlightColor: colorDanger,
      statusColor: statusColor,
      showStatusBar: true,
      nestedGlass: true, // ✅ refuerza el blur dentro del diálogo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: nombre + badge de tiempo ──
          Row(
            children: [
              Expanded(
                child: Text(
                  session.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 14 : 15,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: abandonado ? 'Abandonado' : tiempo,
                color: statusColor,
                icon: abandonado
                    ? Icons.warning_amber_rounded
                    : Icons.access_time_rounded,
                size: StatusBadgeSize.small,
              ),
            ],
          ),

          // ── Cliente (opcional) ──
          if (session.clienteNombre != null &&
              session.clienteNombre!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.clienteNombre!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // ── Vista previa de items ──
          _buildPreview(preview, colorScheme),

          const SizedBox(height: 12),

          // ── Total + acciones ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorSuccess.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorSuccess.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '\$${session.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w800,
                    color: colorSuccess,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Spacer(),
              CardActionButton(
                icon: Icons.edit_outlined,
                color: colorPrimary,
                tooltip: 'Renombrar',
                iconSize: isMobile ? 22 : 20,
                padding: EdgeInsets.all(isMobile ? 10 : 8),
                onPressed: () => onRenombrar(session),
              ),
              CardActionButton(
                icon: Icons.delete_outline_rounded,
                color: colorDanger,
                tooltip: 'Eliminar',
                iconSize: isMobile ? 22 : 20,
                padding: EdgeInsets.all(isMobile ? 10 : 8),
                onPressed: () => onEliminar(session),
              ),
              const SizedBox(width: 6),
              _RetomarButton(
                color: colorPrimary,
                isMobile: isMobile,
                onPressed: () => onRetomar(session),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(List<String> nombres, ColorScheme colorScheme) {
    // ── Fallback: solo contador ──
    if (nombres.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 13,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '${session.cantidadItems} '
              'item${session.cantidadItems == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // ── Vista previa con nombres ──
    final visibles = nombres.take(2).toList();
    final restantes = nombres.length - visibles.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final n in visibles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: isMobile ? 160 : 220,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (restantes > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$restantes más',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  String _formatearTiempo(DateTime creado) {
    final diff = DateTime.now().difference(creado);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return DateFormat('dd/MM HH:mm').format(creado);
  }
}

// ══════════════════════════════════════════════════════════════
// BOTÓN RETOMAR
// ══════════════════════════════════════════════════════════════

class _RetomarButton extends StatefulWidget {
  final Color color;
  final bool isMobile;
  final VoidCallback onPressed;

  const _RetomarButton({
    required this.color,
    required this.isMobile,
    required this.onPressed,
  });

  @override
  State<_RetomarButton> createState() => _RetomarButtonState();
}

class _RetomarButtonState extends State<_RetomarButton> {
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
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 16 : 18,
            vertical: widget.isMobile ? 12 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.15)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(
                  alpha: _hovered ? 0.4 : 0.25,
                ),
                blurRadius: _hovered ? 14 : 8,
                offset: Offset(0, _hovered ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                size: widget.isMobile ? 18 : 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                'Retomar',
                style: TextStyle(
                  fontSize: widget.isMobile ? 13 : 12.5,
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