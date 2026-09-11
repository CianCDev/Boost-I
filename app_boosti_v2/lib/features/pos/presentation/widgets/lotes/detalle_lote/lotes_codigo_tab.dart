// lib/features/pos/presentation/widgets/lotes/lotes_codigos_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/historial_codigos_dialog.dart';

class LotesCodigosTab extends ConsumerStatefulWidget {
  const LotesCodigosTab({super.key});

  @override
  ConsumerState<LotesCodigosTab> createState() => _LotesCodigosTabState();
}

class _LotesCodigosTabState extends ConsumerState<LotesCodigosTab> {
  final IsarService _isar = IsarService();
  String _searchQuery = '';
  String _filterTipo = 'todos'; // 'todos', 'alias', 'lote'

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _cargarTodosLosCodigos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 12),
                Text('Error al cargar los códigos'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];
        final filtrados = _filtrarItems(items);

        if (filtrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay códigos de barras registrados',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los códigos aparecerán aquí cuando se creen alias o lotes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildFiltros(colorScheme, isDark),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtrados.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final item = filtrados[index];
                  return _buildCodigoItem(context, item, colorScheme, isDark);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _cargarTodosLosCodigos() async {
    final List<Map<String, dynamic>> todos = [];
    final productos = await _isar.obtenerProductos();

    for (var producto in productos) {
      final historial = await _isar.obtenerHistorialCodigosPorProducto(producto.id);
      for (var item in historial) {
        todos.add({
          'productoId': producto.id,
          'productoNombre': producto.nombre,
          'codigo': item.codigo,
          'tipo': item.tipo,
          'fechaIngreso': item.fechaIngreso,
          'fechaVencimiento': item.fechaVencimiento,
          'proveedorNombre': item.proveedorNombre ?? '',
          'cantidad': item.cantidad,
          'precio': item.precio,
        });
      }
    }

    todos.sort((a, b) => b['fechaIngreso'].compareTo(a['fechaIngreso']));
    return todos;
  }

  List<Map<String, dynamic>> _filtrarItems(List<Map<String, dynamic>> items) {
    var resultado = items;

    if (_filterTipo != 'todos') {
      resultado = resultado.where((item) => item['tipo'] == _filterTipo).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      resultado = resultado.where((item) {
        final nombre = (item['productoNombre'] as String).toLowerCase();
        final codigo = (item['codigo'] as String).toLowerCase();
        return nombre.contains(q) || codigo.contains(q);
      }).toList();
    }

    return resultado;
  }

  Widget _buildFiltros(ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por producto o código...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _filterTipo,
            dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_alt_rounded),
            style: TextStyle(color: colorScheme.onSurface),
            items: const [
              DropdownMenuItem(value: 'todos', child: Text('Todos')),
              DropdownMenuItem(value: 'alias', child: Text('📌 Alias')),
              DropdownMenuItem(value: 'lote', child: Text('📦 Lotes')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _filterTipo = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCodigoItem(
    BuildContext context,
    Map<String, dynamic> item,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isAlias = item['tipo'] == 'alias';
    final color = isAlias ? Colors.purple : Colors.blue;
    final icon = isAlias ? Icons.label_rounded : Icons.inventory_2_rounded;
    final label = isAlias ? 'Alias' : 'Lote';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => HistorialCodigosDialog(
            productoId: item['productoId'],
            productoNombre: item['productoNombre'],
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['productoNombre'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['codigo'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatearFecha(item['fechaIngreso']),
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
                if (item['fechaVencimiento'] != null)
                  Text(
                    'Vence: ${_formatearFecha(item['fechaVencimiento'])}',
                    style: TextStyle(fontSize: 10, color: Colors.orange.shade600),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}