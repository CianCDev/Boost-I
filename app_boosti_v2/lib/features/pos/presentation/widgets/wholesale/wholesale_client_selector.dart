// lib/features/pos/presentation/widgets/wholesale/wholesale_client_selector.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/cliente_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/wholesale/wholesale_client_provider.dart';
import '../clientes/cliente_form_dialog.dart';

/// Diálogo de selección/creación de cliente para ventas al mayor.
///
/// Flujo:
///   1. Al abrir, carga los 20 clientes más recientes.
///   2. Chips para filtrar por "Todos" / "Frecuentes".
///   3. Busca por nombre, RIF, razón social, documento o teléfono (debounced).
///   4. Permite crear un cliente nuevo sin salir.
///
/// Regla de negocio: el cliente debe tener **RIF** para ser aceptado.
class WholesaleClientSelectorDialog extends ConsumerStatefulWidget {
  const WholesaleClientSelectorDialog({super.key});

  /// Abre el diálogo. Devuelve el cliente seleccionado o `null`.
  static Future<ClienteEntity?> show(BuildContext context) {
    return showDialog<ClienteEntity>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const WholesaleClientSelectorDialog(),
    );
  }

  @override
  ConsumerState<WholesaleClientSelectorDialog> createState() =>
      _WholesaleClientSelectorDialogState();
}

class _WholesaleClientSelectorDialogState
    extends ConsumerState<WholesaleClientSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;
  bool _buscando = false;
  List<ClienteEntity> _resultados = [];
  bool _soloFrecuentes = false;

  // ──────────────── Lifecycle ────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
      _buscar(''); // ✅ FIX: cargar al abrir
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ──────────────── Búsqueda ────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _buscar(query);
    });
  }

  Future<void> _buscar(String query) async {
    final q = query.trim();

    setState(() => _buscando = true);

    try {
      final isar = IsarService();
      List<ClienteEntity> resultados;

      if (q.isEmpty) {
        // Sin query: últimos 20 según filtro
        final todos = await isar.obtenerClientes(
          soloActivos: true,
          soloFrecuentes: _soloFrecuentes,
        );
        resultados = todos.take(20).toList();
      } else {
        resultados = await isar.buscarClientes(
          q,
          soloFrecuentes: _soloFrecuentes,
        );
        resultados = resultados.take(20).toList();
      }

      if (mounted) {
        setState(() {
          _resultados = resultados;
          _buscando = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error buscando clientes: $e');
      if (mounted) {
        setState(() {
          _resultados = [];
          _buscando = false;
        });
      }
    }
  }

  void _toggleFrecuentes(bool valor) {
    setState(() => _soloFrecuentes = valor);
    _buscar(_searchController.text);
  }

  // ──────────────── Crear cliente rápido ────────────────

  Future<void> _crearClienteRapido() async {
    final nuevo = await ClienteFormDialog.mostrar(context);
    if (nuevo == null || !mounted) return;

    // Setear el cliente seleccionado directamente
    ref.read(wholesaleClientProvider.notifier).seleccionar(nuevo);
    Navigator.of(context).pop(nuevo);
  }

  // ──────────────── Seleccionar cliente ────────────────

  void _seleccionar(ClienteEntity cliente) {
    final rif = (cliente.rif ?? '').trim();
    if (rif.isEmpty) {
      _mostrarDialogoSinRif(cliente);
      return;
    }

    ref.read(wholesaleClientProvider.notifier).seleccionar(cliente);
    Navigator.of(context).pop(cliente);
  }

  void _mostrarDialogoSinRif(ClienteEntity cliente) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Falta RIF'),
          ],
        ),
        content: Text(
          '"${cliente.nombre}" no tiene RIF registrado.\n\n'
          'Para ventas al mayor el RIF es obligatorio. '
          'Edítalo antes de continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ──────────────── Build ────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 560,
          maxHeight: 720,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark, cs),

            // ── Buscador ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _buildSearchBar(isDark, cs),
            ),

            // ── Chips de filtro ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _buildFiltroChips(isDark, cs),
            ),

            // ── Botón crear ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _buildCrearButton(isDark),
            ),

            Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),

            // ── Lista de resultados ──
            Flexible(
              child: _buildResultados(isDark, cs),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── Header ────────────────

  Widget _buildHeader(bool isDark, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 22,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleccionar cliente',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'El cliente debe tener RIF para venta al mayor',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 22),
            color: cs.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  // ──────────────── Barra de búsqueda ────────────────

  Widget _buildSearchBar(bool isDark, ColorScheme cs) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      onChanged: _onSearchChanged,
      style: TextStyle(
        fontSize: 14,
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, RIF, documento o teléfono…',
        hintStyle: TextStyle(
          fontSize: 13,
          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  _buscar('');
                },
                icon: const Icon(Icons.clear_rounded, size: 18),
              )
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }

  // ──────────────── Chips de filtro ────────────────

  Widget _buildFiltroChips(bool isDark, ColorScheme cs) {
    return Row(
      children: [
        _buildFiltroChip(
          label: 'Todos',
          icon: Icons.people_outline_rounded,
          selected: !_soloFrecuentes,
          onTap: () => _toggleFrecuentes(false),
        ),
        const SizedBox(width: 8),
        _buildFiltroChip(
          label: 'Frecuentes',
          icon: Icons.star_rounded,
          selected: _soloFrecuentes,
          onTap: () => _toggleFrecuentes(true),
        ),
      ],
    );
  }

  Widget _buildFiltroChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = const Color(0xFF3B82F6);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.6)
                  : Colors.grey.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? color : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── Botón crear ────────────────

  Widget _buildCrearButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: _crearClienteRapido,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
        label: const Text(
          'Crear cliente nuevo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF10B981),
          side: BorderSide(
            color: const Color(0xFF10B981).withValues(alpha: 0.5),
            width: 1.2,
          ),
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ──────────────── Resultados ────────────────

  Widget _buildResultados(bool isDark, ColorScheme cs) {
    if (_buscando) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF10B981),
          ),
        ),
      );
    }

    if (_resultados.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty
                  ? (_soloFrecuentes
                      ? 'No hay clientes frecuentes'
                      : 'No hay clientes registrados')
                  : 'Sin resultados para "${_searchController.text}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
            if (_searchController.text.isEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _crearClienteRapido,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text('Crear cliente nuevo'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _resultados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final c = _resultados[i];
        return _ClienteTile(
          cliente: c,
          onTap: () => _seleccionar(c),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tile de cliente
// ═══════════════════════════════════════════════════════════════════

class _ClienteTile extends StatelessWidget {
  final ClienteEntity cliente;
  final VoidCallback onTap;

  const _ClienteTile({
    required this.cliente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    final tieneRif = (cliente.rif ?? '').trim().isNotEmpty;
    final esMayorista = cliente.esMayorista;
    final docDisplay = cliente.documentoFormateado;

    // ── Subtítulo: compone doc · RIF · teléfono ──
    final partes = <String>[];
    if (docDisplay.isNotEmpty) partes.add(docDisplay);
    if (tieneRif) partes.add(cliente.rif!);
    if ((cliente.telefono ?? '').isNotEmpty) partes.add(cliente.telefono!);
    final subtitulo = partes.isEmpty ? 'Sin datos' : partes.join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tieneRif
                  ? cs.outlineVariant.withValues(alpha: 0.3)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.4),
              width: tieneRif ? 1 : 1.3,
            ),
          ),
          child: Row(
            children: [
              // ── Avatar con iniciales ──
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tieneRif
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(cliente.nombre),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: tieneRif
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + badges
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cliente.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (esMayorista) ...[
                          const SizedBox(width: 6),
                          _badge(
                            'MAYORISTA',
                            const Color(0xFF8B5CF6),
                          ),
                        ],
                        if (cliente.frecuente) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Subtítulo con doc · rif · tel
                    Row(
                      children: [
                        if (!tieneRif) ...[
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 11,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Sin RIF',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            subtitulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Razón social (si existe)
                    if (esMayorista &&
                        (cliente.razonSocial ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        cliente.razonSocial!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _initials(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '?';
    if (partes.length == 1) {
      return partes[0].isEmpty ? '?' : partes[0][0].toUpperCase();
    }
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }
}