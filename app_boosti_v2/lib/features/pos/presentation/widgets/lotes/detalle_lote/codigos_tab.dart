// lib/features/pos/presentation/widgets/lotes/detalle_lote/codigos_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

class CodigosTab extends ConsumerStatefulWidget {
  final int productoId;

  const CodigosTab({super.key, required this.productoId});

  @override
  ConsumerState<CodigosTab> createState() => _CodigosTabState();
}

class _CodigosTabState extends ConsumerState<CodigosTab> {
  final IsarService _isar = IsarService();
  String _filterTipo = 'todos';
  String _searchQuery = '';
  late Future<List<HistorialCodigoItem>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _cargarCodigos();
  }

  void _cargarCodigos() {
    setState(() {
      _historialFuture = _isar.obtenerHistorialCodigosPorProducto(widget.productoId);
    });
  }

  List<HistorialCodigoItem> _filtrarItems(List<HistorialCodigoItem> items) {
    var resultado = items;

    if (_filterTipo != 'todos') {
      resultado = resultado.where((item) => item.tipo == _filterTipo).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      resultado = resultado.where((item) =>
          item.codigo.toLowerCase().contains(q) ||
          (item.proveedorNombre?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar código...',
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
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _cargarCodigos();
                  },
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
                  if (value != null) {
                    setState(() => _filterTipo = value);
                    _cargarCodigos();
                  }
                },
              ),
            ],
          ),
        ),
        // Lista de códigos
        Expanded(
          child: FutureBuilder<List<HistorialCodigoItem>>(
            future: _historialFuture,
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
                      Text('Error al cargar códigos'),
                    ],
                  ),
                );
              }

              final items = _filtrarItems(snapshot.data ?? []);

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No hay códigos de barras para este producto',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCodigoItem(context, item, colorScheme, isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodigoItem(
    BuildContext context,
    HistorialCodigoItem item,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isAlias = item.tipo == 'alias';
    final color = isAlias ? Colors.purple : Colors.blue;
    final icon = isAlias ? Icons.label_rounded : Icons.inventory_2_rounded;
    final label = isAlias ? 'Alias' : 'Lote';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
      ),
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
                  item.codigo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
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
                    if (item.proveedorNombre != null && item.proveedorNombre!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Proveedor: ${item.proveedorNombre}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
                if (!isAlias) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Ingreso: ${_formatearFecha(item.fechaIngreso)}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      if (item.fechaVencimiento != null)
                        Row(
                          children: [
                            Icon(Icons.event_available_rounded, size: 12, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              'Vence: ${_formatearFecha(item.fechaVencimiento!)}',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (item.cantidad > 0 || item.precio > 0)
                    Row(
                      children: [
                        Text(
                          'Cantidad: ${item.cantidad}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Precio: \$${item.precio.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}