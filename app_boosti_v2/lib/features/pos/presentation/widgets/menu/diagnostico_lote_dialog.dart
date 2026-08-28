// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';

class DiagnosticoLotesDialog extends ConsumerStatefulWidget {
  const DiagnosticoLotesDialog({super.key});

  @override
  ConsumerState<DiagnosticoLotesDialog> createState() => _DiagnosticoLotesDialogState();
}

class _DiagnosticoLotesDialogState extends ConsumerState<DiagnosticoLotesDialog> {
  late Future<Map<String, dynamic>> _diagnosticoFuture;
  bool _isMigrating = false;

  @override
  void initState() {
    super.initState();
    _cargarDiagnostico();
  }

  void _cargarDiagnostico() {
    final isar = ref.read(isarServiceProvider);
    _diagnosticoFuture = _obtenerDiagnostico(isar);
  }

  Future<Map<String, dynamic>> _obtenerDiagnostico(IsarService isar) async {
    final totalProductos = await isar.contarProductos();
    final totalLotes = await isar.contarLotes();

    final productos = await isar.obtenerTodosLosProductos();
    final todosLosLotes = await isar.obtenerTodosLosLotes();

    final productosSinLote = <String>[];
    final productosConStockSinLote = <String>[];

    for (var p in productos) {
      final lotesProducto = todosLosLotes
          .where((lote) => lote.productoId == p.id)
          .toList();

      if (lotesProducto.isEmpty) {
        productosSinLote.add(p.nombre);
        if (p.stock > 0) {
          productosConStockSinLote.add('${p.nombre} (stock: ${p.stock})');
        }
      }
    }

    final porcentaje = totalProductos > 0
        ? ((totalProductos - productosSinLote.length) / totalProductos * 100).toStringAsFixed(1)
        : '0.0';

    return {
      'totalProductos': totalProductos,
      'totalLotes': totalLotes,
      'productosSinLote': productosSinLote,
      'productosSinLoteCount': productosSinLote.length,
      'productosConStockSinLote': productosConStockSinLote,
      'porcentajeCobertura': '$porcentaje%',
    };
  }

  Future<void> _ejecutarMigracion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar migración'),
        content: const Text('Se crearán lotes para todos los productos que tengan stock y no tengan lotes. ¿Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ejecutar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isMigrating = true);
    try {
      final isar = ref.read(isarServiceProvider);
      final result = await isar.migrarStockExistenteALotes();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] 
              ? '✅ Migración exitosa: ${result['lotesCreados']} lotes creados' 
              : '❌ Error en migración: ${result['error']}'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      _cargarDiagnostico();
      setState(() {});
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isMigrating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Color(0xFF3B82F6), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Diagnóstico de Inventario',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contenido
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _diagnosticoFuture,
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
                          const SizedBox(height: 8),
                          Text('Error al cargar diagnóstico', style: TextStyle(color: colorScheme.error)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _cargarDiagnostico();
                              setState(() {});
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  final data = snapshot.data!;
                  final totalProductos = data['totalProductos'] as int;
                  final totalLotes = data['totalLotes'] as int;
                  final productosSinLoteCount = data['productosSinLoteCount'] as int;
                  final productosConStockSinLote = data['productosConStockSinLote'] as List<String>;
                  final porcentaje = data['porcentajeCobertura'] as String;
                  final cobertura = double.tryParse(porcentaje.replaceAll('%', '')) ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjetas de métricas con Wrap
                      Wrap(
                        spacing: isMobile ? 8 : 12,
                        runSpacing: isMobile ? 8 : 12,
                        children: [
                          _buildMetricCard(
                            context,
                            'Productos',
                            '$totalProductos',
                            Icons.inventory_2_rounded,
                            Colors.blue,
                            isMobile,
                          ),
                          _buildMetricCard(
                            context,
                            'Lotes',
                            '$totalLotes',
                            Icons.production_quantity_limits_rounded,
                            Colors.purple,
                            isMobile,
                          ),
                          _buildMetricCard(
                            context,
                            'Cobertura',
                            porcentaje,
                            Icons.pie_chart_rounded,
                            cobertura >= 80 ? Colors.green : (cobertura >= 50 ? Colors.orange : Colors.red),
                            isMobile,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Productos sin lote - CASO CON PRODUCTOS
                      if (productosSinLoteCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$productosSinLoteCount producto(s) sin lote',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              if (productosConStockSinLote.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '⚠️ ${productosConStockSinLote.length} con stock sin lote',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: productosConStockSinLote.map((p) {
                                    return Chip(
                                      label: Text(p, style: const TextStyle(fontSize: 11)),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: Colors.orange.shade100,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        // 🔥 PRODUCTOS SIN LOTE - CASO VACÍO (ALERTA VERDE CORREGIDA)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded( // ✅ Esto evita que el texto se desborde
                                child: Text(
                                  '✅ Todos los productos tienen lote asignado',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                    fontSize: 13,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      
                      // Botones de acción
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          SizedBox(
                            width: isMobile ? double.infinity : 140,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _cargarDiagnostico();
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Recargar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isMobile ? double.infinity : 160,
                            child: ElevatedButton.icon(
                              onPressed: _isMigrating ? null : _ejecutarMigracion,
                              icon: _isMigrating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.play_arrow_rounded, size: 18),
                              label: Text(_isMigrating ? 'Migrando...' : 'Ejecutar Migración'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final ancho = isMobile ? (MediaQuery.of(context).size.width / 3.4) : 160.0;

    return Container(
      width: ancho,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}