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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    // Escuchar cambios en los clientes
    final allClientes = ref.watch(clientesProvider);
    final frecuentes = ref.watch(clientesFrecuentesProvider);

    // Filtrar según búsqueda y pestaña
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

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 12 : 32,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 8,
      child: Container(
        width: isMobile ? double.infinity : 800,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Contenido principal
                  SizedBox.expand(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // ----- CABECERA -----
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.people_rounded,
                                  color: Color(0xFF8B5CF6),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Gestión de Clientes',
                                style: TextStyle(
                                  fontSize: isMobile ? 18 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                                tooltip: 'Cerrar',
                              ),
                            ],
                          ),
                        ),

                        // ----- PESTAÑAS -----
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: const Color(0xFF8B5CF6),
                              unselectedLabelColor: isDark ? Colors.white54 : Colors.grey.shade600,
                              indicator: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              indicatorPadding: const EdgeInsets.all(4),
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

                        // ----- BÚSQUEDA -----
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre o documento...',
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear_rounded,
                                          color: isDark ? Colors.white54 : Colors.grey.shade600),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8B5CF6),
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        // ----- LISTA DE CLIENTES -----
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildList(getClientesFiltrados(false), isDark),
                              _buildList(getClientesFiltrados(true), isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ----- BOTÓN FLOTANTE PARA NUEVO CLIENTE -----
                Positioned(
                bottom: 24,
                right: 24,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FloatingActionButton(
                    onPressed: _agregarCliente,
                    backgroundColor: const Color(0xFF8B5CF6),
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

  Widget _buildList(List<ClienteEntity> clientes, bool isDark) {
    if (clientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay clientes',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _agregarCliente,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Agregar cliente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
              // Puedes abrir detalles aquí, por ahora solo mostramos un snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cliente: ${cliente.nombre}'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: const Color(0xFF8B5CF6),
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

  void _agregarCliente() {
    ClienteFormDialog.mostrar(context);
  }

  void _editarCliente(ClienteEntity cliente) {
    ClienteFormDialog.mostrar(context, cliente: cliente);
  }

  void _eliminarCliente(ClienteEntity cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text('¿Estás seguro de eliminar a "${cliente.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(clientesProvider.notifier).eliminarCliente(cliente.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}