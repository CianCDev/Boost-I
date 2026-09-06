import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/clientes/clientes_provider.dart';
import 'cliente_card.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _mostrarFrecuentes = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Consumimos el provider adecuado según el filtro seleccionado
    final clientesLocales = _mostrarFrecuentes 
        ? ref.watch(clientesFrecuentesProvider) 
        : ref.watch(clientesProvider);

    // Filtro local rápido para la barra de búsqueda (sin mutar el provider)
    final clientesFiltrados = _searchQuery.isEmpty 
        ? clientesLocales 
        : clientesLocales.where((c) {
            final nombre = c.nombre.toLowerCase();
            final documento = c.documento?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return nombre.contains(query) || documento.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Clientes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscador y Filtros
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o documento...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón de filtro "Frecuentes"
                FilterChip(
                  label: const Text('Frecuentes'),
                  selected: _mostrarFrecuentes,
                  onSelected: (selected) => setState(() => _mostrarFrecuentes = selected),
                  avatar: Icon(
                    Icons.star_rounded, 
                    color: _mostrarFrecuentes ? const Color(0xFFF59E0B) : Colors.grey,
                    size: 18,
                  ),
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _mostrarFrecuentes 
                          ? const Color(0xFFF59E0B) 
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Lista de Clientes
            Expanded(
              child: clientesFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron clientes',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final cliente = clientesFiltrados[index];
                        return ClienteCard(
                          cliente: cliente,
                          onTap: () {
                            // TODO: Abrir detalles
                          },
                          onEdit: () {
                            // TODO: Abrir formulario de edición
                          },
                          onDelete: () {
                            ref.read(clientesProvider.notifier).eliminarCliente(cliente.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Abrir formulario nuevo cliente
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo Cliente'),
        backgroundColor: const Color(0xFF8B5CF6), // Tono morado de Boost-i
        foregroundColor: Colors.white,
      ),
    );
  }
}