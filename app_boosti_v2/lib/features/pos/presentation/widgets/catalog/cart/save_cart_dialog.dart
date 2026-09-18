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
  static const _colorMayorista = Color(0xFF10B981);

  /// Máximo de resultados visibles en el dropdown.
  static const _maxResultados = 6;

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

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

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

            // ── Sugerencias rápidas ──
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
    // ── Si ya hay cliente seleccionado → mostrar card ──
    if (_clienteSeleccionado != null) {
      return _buildClienteCard(_clienteSeleccionado!, colorScheme);
    }

    // ── Si no → buscador + resultados ──
    final clientes = ref.watch(clientesProvider);
    final matches = _filtrarClientes(clientes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header sección
        Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
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

        // Buscador
        TextField(
          controller: _clienteSearchController,
          focusNode: _clienteFocus,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, documento, RIF o teléfono',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            // ✅ Botón limpiar
            suffixIcon: _clienteSearchController.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: () {
                      _clienteSearchController.clear();
                      setState(() {});
                      _clienteFocus.requestFocus();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
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

        // ── Resultados ──
        if (_clienteSearchController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          if (matches.isEmpty)
            _buildEmptyResults(colorScheme, isDark)
          else
            _buildMatchesList(matches, colorScheme, isDark),
        ],
      ],
    );
  }

  // ──────────────── Filtro de clientes ────────────────

  /// Filtra la lista completa según la query actual.
  ///
  /// Optimización: normaliza la query una sola vez y reutiliza.
  List<ClienteEntity> _filtrarClientes(List<ClienteEntity> todos) {
    final q = _clienteSearchController.text.trim().toLowerCase();
    if (q.isEmpty) return const [];

    return todos
        .where((c) {
          final nombre = c.nombre.toLowerCase();
          final doc = c.documentoFormateado.toLowerCase();
          final rif = (c.rif ?? '').toLowerCase();
          final razonSocial = (c.razonSocial ?? '').toLowerCase();
          final telefono = (c.telefono ?? '').toLowerCase();

          return nombre.contains(q) ||
              doc.contains(q) ||
              rif.contains(q) ||
              razonSocial.contains(q) ||
              telefono.contains(q);
        })
        .take(_maxResultados)
        .toList();
  }

  // ──────────────── Lista de resultados ────────────────

  Widget _buildMatchesList(
    List<ClienteEntity> matches,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
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
        itemBuilder: (context, i) =>
            _buildClienteTile(matches[i], colorScheme),
      ),
    );
  }

  Widget _buildClienteTile(ClienteEntity c, ColorScheme colorScheme) {
    final esMayorista = c.esMayorista;
    final tieneRif = (c.rif ?? '').trim().isNotEmpty;

    // Subtítulo: documento · teléfono (o razón social si existe)
    final partes = <String>[];
    if (c.documentoFormateado.isNotEmpty) {
      partes.add(c.documentoFormateado);
    }
    if (esMayorista && (c.razonSocial ?? '').isNotEmpty) {
      partes.add(c.razonSocial!);
    } else if ((c.telefono ?? '').isNotEmpty) {
      partes.add(c.telefono!);
    }
    final subtitulo = partes.isEmpty ? 'Sin datos' : partes.join(' · ');

    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: esMayorista
              ? _colorMayorista.withValues(alpha: 0.15)
              : _colorPrimary.withValues(alpha: 0.15),
          child: Icon(
            c.frecuente
                ? Icons.star_rounded
                : (esMayorista
                    ? Icons.store_rounded
                    : Icons.person_outline_rounded),
            size: 14,
            color: esMayorista ? _colorMayorista : _colorPrimary,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                c.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (esMayorista) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: _colorMayorista.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'MAYORISTA',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: _colorMayorista,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
            if (esMayorista && !tieneRif) ...[
              const SizedBox(width: 4),
              const Tooltip(
                message: 'Sin RIF — no podrá usarse en venta al mayor',
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 12,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitulo,
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
  }

  // ──────────────── Sin resultados ────────────────

  Widget _buildEmptyResults(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Prueba con otro nombre, documento o teléfono.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Card cliente seleccionado ────────────────

  Widget _buildClienteCard(ClienteEntity c, ColorScheme colorScheme) {
    final esMayorista = c.esMayorista;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _colorPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  c.frecuente
                      ? Icons.star_rounded
                      : (esMayorista
                          ? Icons.store_rounded
                          : Icons.person_rounded),
                  color: _colorPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (esMayorista) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _colorMayorista.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'MAYORISTA',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: _colorMayorista,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Línea de datos: doc · rif · teléfono
                    _buildClienteDetailLine(c, colorScheme),
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
          // Razón social (si aplica)
          if (esMayorista &&
              (c.razonSocial ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Text(
                c.razonSocial!,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClienteDetailLine(ClienteEntity c, ColorScheme colorScheme) {
    final items = <Widget>[];

    if (c.documentoFormateado.isNotEmpty) {
      items.add(_detailItem(
        Icons.badge_outlined,
        c.documentoFormateado,
        colorScheme,
      ));
    }
    if ((c.rif ?? '').trim().isNotEmpty) {
      items.add(_detailItem(
        Icons.receipt_outlined,
        c.rif!,
        colorScheme,
      ));
    }
    if ((c.telefono ?? '').trim().isNotEmpty) {
      items.add(_detailItem(
        Icons.phone_outlined,
        c.telefono!,
        colorScheme,
      ));
    }

    if (items.isEmpty) {
      return Text(
        'Sin datos adicionales',
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Separar por " · "
    final List<Widget> row = [];
    for (var i = 0; i < items.length; i++) {
      row.add(items[i]);
      if (i < items.length - 1) {
        row.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '·',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ));
      }
    }

    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: row,
          ),
        ),
      ],
    );
  }

  Widget _detailItem(IconData icon, String text, ColorScheme cs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
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