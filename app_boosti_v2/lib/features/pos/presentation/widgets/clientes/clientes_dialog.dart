// lib/features/pos/presentation/widgets/clientes/clientes_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../data/Local/entities/cliente_entity.dart';
import '../../providers/clientes/clientes_provider.dart';
import 'cliente_card.dart';
import 'cliente_form_dialog.dart';

class ClientesDialog extends ConsumerStatefulWidget {
  const ClientesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ClientesDialog(),
    );
  }

  @override
  ConsumerState<ClientesDialog> createState() => _ClientesDialogState();
}

class _ClientesDialogState extends ConsumerState<ClientesDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color _colorCliente = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    final allClientes = ref.watch(clientesProvider);
    final frecuentes = ref.watch(clientesFrecuentesProvider);

    List<ClienteEntity> getClientesFiltrados(bool soloFrecuentes) {
      final base = soloFrecuentes ? frecuentes : allClientes;
      if (_searchQuery.isEmpty) return base;
      final q = _searchQuery.toLowerCase();
      return base.where((c) {
        final nombre = c.nombre.toLowerCase();
        final doc = c.documento?.toLowerCase() ?? '';
        return nombre.contains(q) || doc.contains(q);
      }).toList();
    }

    final surfaceColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.92);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 12 : 32,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 800,
          maxHeight: screenSize.height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // ===== CABECERA =====
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    colorScheme.outlineVariant.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      _colorCliente.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.people_rounded,
                                  color: _colorCliente,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Gestión de Clientes',
                                style: TextStyle(
                                  fontSize: isMobile ? 18 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  tooltip: 'Cerrar',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== TABS =====
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colorScheme.surfaceContainerHigh
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: _colorCliente,
                              unselectedLabelColor: colorScheme.onSurfaceVariant,
                              indicator: BoxDecoration(
                                color: _colorCliente.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              indicatorPadding: const EdgeInsets.all(4),
                              dividerColor: Colors.transparent,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              tabs: const [
                                Tab(text: 'Todos'),
                                Tab(text: 'Frecuentes'),
                              ],
                            ),
                          ),
                        ),

                        // ===== BÚSQUEDA =====
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre o documento...',
                              hintStyle:
                                  TextStyle(color: colorScheme.onSurfaceVariant),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: IconButton(
                                        icon: Icon(Icons.clear_rounded,
                                            color:
                                                colorScheme.onSurfaceVariant),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      ),
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark
                                  ? colorScheme.surfaceContainerHigh
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: _colorCliente,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        // ===== LISTA =====
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildList(getClientesFiltrados(false)),
                              _buildList(getClientesFiltrados(true)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== FAB =====
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: FloatingActionButton(
                        onPressed: _agregarCliente,
                        backgroundColor: _colorCliente,
                        foregroundColor: Colors.white,
                        tooltip: 'Agregar cliente',
                        elevation: 4,
                        child: const Icon(Icons.add_rounded, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<ClienteEntity> clientes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (clientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay clientes',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton.icon(
                onPressed: _agregarCliente,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Agregar cliente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorCliente,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(clientesProvider);
        ref.invalidate(clientesFrecuentesProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final cliente = clientes[index];
          return ClienteCard(
            cliente: cliente,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cliente: ${cliente.nombre}'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _colorCliente,
                ),
              );
            },
            onEdit: () => _editarCliente(cliente),
            onDelete: () => _eliminarCliente(cliente),
          );
        },
      ),
    );
  }

  Future<void> _agregarCliente() async {
    await ClienteFormDialog.mostrar(context);
  }

  Future<void> _editarCliente(ClienteEntity cliente) async {
    await ClienteFormDialog.mostrar(context, cliente: cliente);
  }

  void _eliminarCliente(ClienteEntity cliente) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text('¿Estás seguro de eliminar a "${cliente.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              ref
                  .read(clientesProvider.notifier)
                  .eliminarCliente(cliente.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}