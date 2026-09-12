import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/clientes/clientes_provider.dart';
import 'cliente_card.dart';
import 'cliente_form_dialog.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _mostrarFrecuentes = false;
  String _searchQuery = '';

  static const Color _colorCliente = Color(0xFF8B5CF6);
  static const Color _colorFrecuente = Color(0xFFF59E0B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final clientesLocales = _mostrarFrecuentes
        ? ref.watch(clientesFrecuentesProvider)
        : ref.watch(clientesProvider);

    final clientesFiltrados = _searchQuery.isEmpty
        ? clientesLocales
        : clientesLocales.where((c) {
            final nombre = c.nombre.toLowerCase();
            final documento = c.documento?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return nombre.contains(query) || documento.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Clientes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHigh
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o documento...',
                        hintStyle:
                            TextStyle(color: colorScheme.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilterChip(
                    label: const Text('Frecuentes'),
                    selected: _mostrarFrecuentes,
                    onSelected: (selected) =>
                        setState(() => _mostrarFrecuentes = selected),
                    avatar: Icon(
                      Icons.star_rounded,
                      color: _mostrarFrecuentes
                          ? _colorFrecuente
                          : colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    backgroundColor: isDark
                        ? colorScheme.surfaceContainerHigh
                        : Colors.white,
                    selectedColor:
                        _colorFrecuente.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _mostrarFrecuentes
                          ? _colorFrecuente
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _mostrarFrecuentes
                            ? _colorFrecuente
                            : colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: clientesFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron clientes',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final cliente = clientesFiltrados[index];
                        return ClienteCard(
                          cliente: cliente,
                          onTap: () {},
                          onEdit: () async {
                            await ClienteFormDialog.mostrar(context,
                                cliente: cliente);
                          },
                          onDelete: () {
                            ref
                                .read(clientesProvider.notifier)
                                .eliminarCliente(cliente.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await ClienteFormDialog.mostrar(context);
          },
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Nuevo Cliente'),
          backgroundColor: _colorCliente,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}