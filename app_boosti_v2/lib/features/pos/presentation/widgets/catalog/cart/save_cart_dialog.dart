// lib/features/pos/presentation/widgets/cart/save_cart_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/Local/entities/cliente_entity.dart';
import '../../../controllers/cart_sessions_controller.dart';
import '../../../providers/clientes/clientes_provider.dart';
import '../../../providers/usuario_provider.dart';
import '../../../utils/responsive_helper.dart';
import '../../common/dialog_header.dart';
import '../../common/filtro_chip_template.dart';
import '../../common/glass_dialog.dart';

class SaveCartDialog extends ConsumerStatefulWidget {
  final ClienteEntity? cliente;

  const SaveCartDialog({super.key, this.cliente});

  static Future<bool> mostrar(
    BuildContext context, {
    ClienteEntity? cliente,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SaveCartDialog(cliente: cliente),
    );
    return result ?? false;
  }

  @override
  ConsumerState<SaveCartDialog> createState() => _SaveCartDialogState();
}

class _SaveCartDialogState extends ConsumerState<SaveCartDialog> {
  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorSuccess = Color(0xFF10B981);

  final _nombreController = TextEditingController();
  final _clienteSearchController = TextEditingController();
  final _clienteFocus = FocusNode();

  ClienteEntity? _clienteSeleccionado;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // ✅ Hereda el cliente que venga del caller (si lo hay).
    _clienteSeleccionado = widget.cliente;
    final count = ref.read(cartSessionsProvider).count;
    _nombreController.text = 'Carrito ${count + 1}';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _clienteSearchController.dispose();
    _clienteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return GlassDialog(
      accentColor: _colorPrimary,
      maxWidth: 520,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 24,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 18 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.pause_circle_outline_rounded,
              title: 'Poner en espera',
              subtitle: 'Podrás retomarlo cuando quieras',
              color: _colorPrimary,
            ),
            const SizedBox(height: 18),

            // ── Nombre del carrito ──
            TextField(
              controller: _nombreController,
              autofocus: true,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Nombre del carrito',
                prefixIcon:
                    const Icon(Icons.label_outline, color: _colorPrimary),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _colorPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Sugerencias (tienda / mercado) ──
            Text(
              'Sugerencias rápidas',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in const [
                  'Mostrador',
                  'Para llevar',
                  'Domicilio',
                  'Mayorista',
                  'Apartado',
                ])
                  FiltroChip(
                    label: s,
                    icon: Icons.bookmark_outline_rounded,
                    color: _colorPrimary,
                    selected: _nombreController.text == s,
                    size: FiltroChipSize.small,
                    style: FiltroChipStyle.outlined,
                    onTap: () =>
                        setState(() => _nombreController.text = s),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Cliente (opcional) ──
            _buildClienteSection(colorScheme, isDark),

            const SizedBox(height: 22),

            // ── Botones ──
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _guardar,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.pause_rounded, size: 18),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Poner en espera',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CLIENTE — sección completa
  // ══════════════════════════════════════════════════════════════

  Widget _buildClienteSection(ColorScheme colorScheme, bool isDark) {
    // Si ya hay cliente seleccionado → mostrar card
    if (_clienteSeleccionado != null) {
      return _buildClienteCard(_clienteSeleccionado!, colorScheme);
    }

    // Si no → buscador + dropdown con coincidencias
    final clientes = ref.watch(clientesProvider);
    final q = _clienteSearchController.text.trim().toLowerCase();
    final matches = q.isEmpty
        ? const <ClienteEntity>[]
        : clientes
            .where((c) =>
                c.nombre.toLowerCase().contains(q) ||
                (c.documento ?? '').toLowerCase().contains(q) ||
                (c.telefono ?? '').toLowerCase().contains(q))
            .take(5)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline_rounded,
                size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'CLIENTE (OPCIONAL)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _clienteSearchController,
          focusNode: _clienteFocus,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, cédula o teléfono',
            prefixIcon: Icon(Icons.search_rounded,
                color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _colorPrimary, width: 1.5),
            ),
          ),
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 170),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: matches.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, i) {
                final c = matches[i];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          _colorPrimary.withValues(alpha: 0.15),
                      child: Icon(
                        c.frecuente
                            ? Icons.star_rounded
                            : Icons.person_outline_rounded,
                        size: 14,
                        color: _colorPrimary,
                      ),
                    ),
                    title: Text(
                      c.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${c.documento ?? "Sin documento"}'
                      '${c.telefono != null ? " · ${c.telefono}" : ""}',
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => setState(() {
                      _clienteSeleccionado = c;
                      _clienteSearchController.clear();
                      _clienteFocus.unfocus();
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildClienteCard(ClienteEntity c, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _colorPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _colorPrimary.withValues(alpha: 0.35),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              c.frecuente ? Icons.star_rounded : Icons.person_rounded,
              color: _colorPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (c.documento != null && c.documento!.isNotEmpty)
                  Text(
                    c.documento!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: () =>
                  setState(() => _clienteSeleccionado = null),
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: colorScheme.error,
              ),
              tooltip: 'Quitar cliente',
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // GUARDAR
  // ══════════════════════════════════════════════════════════════

  Future<void> _guardar() async {
    setState(() => _isSaving = true);
    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) {
        if (mounted) Navigator.pop(context, false);
        return;
      }

      final error = await ref
          .read(cartSessionsProvider.notifier)
          .parkearCarritoActivo(
            nombre: _nombreController.text.trim().isEmpty
                ? 'Carrito sin nombre'
                : _nombreController.text.trim(),
            // ✅ Usa el cliente seleccionado en el diálogo
            cliente: _clienteSeleccionado,
          );

      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: _colorDanger),
        );
        setState(() => _isSaving = false);
        return;
      }

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carrito guardado en espera'),
          backgroundColor: _colorSuccess,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }
}