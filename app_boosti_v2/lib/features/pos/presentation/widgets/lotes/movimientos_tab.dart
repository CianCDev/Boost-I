// lib/features/pos/presentation/widgets/lotes/detalle_lote/movimientos_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

class MovimientosTab extends ConsumerStatefulWidget {
  final LoteEntity lote;

  const MovimientosTab({super.key, required this.lote});

  @override
  ConsumerState<MovimientosTab> createState() => _MovimientosTabState();
}

class _MovimientosTabState extends ConsumerState<MovimientosTab> {
  final IsarService _isar = IsarService();
  String _periodoSeleccionado = 'hoy';
  String _searchQuery = '';
  late Future<List<MovimientoLoteEntity>> _movimientosFuture;

  // Lista de meses para el filtro personalizado
  final List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  String _mesSeleccionado = '';
  int _anioSeleccionado = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _mesSeleccionado = _meses[DateTime.now().month - 1];
    _cargarMovimientos();
  }

  void _cargarMovimientos() {
    setState(() {
      _movimientosFuture = _isar.obtenerMovimientosPorLote(widget.lote.id);
    });
  }

  List<MovimientoLoteEntity> _filtrarMovimientos(List<MovimientoLoteEntity> movimientos) {
    var resultado = movimientos;

    // Filtro por período
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    switch (_periodoSeleccionado) {
      case 'hoy':
        resultado = resultado.where((m) =>
            m.fecha.year == hoy.year &&
            m.fecha.month == hoy.month &&
            m.fecha.day == hoy.day
        ).toList();
        break;
      case 'semana':
        final inicioSemana = hoy.subtract(Duration(days: ahora.weekday - 1));
        resultado = resultado.where((m) => m.fecha.isAfter(inicioSemana)).toList();
        break;
      case 'mes':
        final inicioMes = DateTime(ahora.year, ahora.month, 1);
        resultado = resultado.where((m) => m.fecha.isAfter(inicioMes)).toList();
        break;
      case 'personalizado':
        final idx = _meses.indexOf(_mesSeleccionado);
        final inicio = DateTime(_anioSeleccionado, idx + 1, 1);
        final fin = DateTime(_anioSeleccionado, idx + 2, 1);
        resultado = resultado.where((m) =>
            m.fecha.isAfter(inicio.subtract(const Duration(seconds: 1))) &&
            m.fecha.isBefore(fin)
        ).toList();
        break;
      default:
        break;
    }

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      resultado = resultado.where((m) =>
          m.tipo.toLowerCase().contains(q) ||
          (m.observaciones?.toLowerCase().contains(q) ?? false) ||
          m.usuarioId.toString().contains(q)
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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPeriodButton('hoy', 'Hoy', isDark),
                          const SizedBox(width: 8),
                          _buildPeriodButton('semana', 'Semana', isDark),
                          const SizedBox(width: 8),
                          _buildPeriodButton('mes', 'Mes', isDark),
                          const SizedBox(width: 8),
                          _buildPeriodButton('personalizado', '📅', isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_periodoSeleccionado == 'personalizado')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _mesSeleccionado,
                          items: _meses.map((mes) {
                            return DropdownMenuItem(value: mes, child: Text(mes));
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _mesSeleccionado = value);
                              _cargarMovimientos();
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _anioSeleccionado,
                          items: List.generate(5, (i) {
                            final anio = DateTime.now().year - i;
                            return DropdownMenuItem(value: anio, child: Text(anio.toString()));
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _anioSeleccionado = value);
                              _cargarMovimientos();
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: _cargarMovimientos,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              // Búsqueda
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por tipo, usuario...',
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
                  _cargarMovimientos();
                },
              ),
            ],
          ),
        ),
        // Lista de movimientos
        Expanded(
          child: FutureBuilder<List<MovimientoLoteEntity>>(
            future: _movimientosFuture,
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
                      Text('Error al cargar movimientos'),
                    ],
                  ),
                );
              }

              final movimientos = _filtrarMovimientos(snapshot.data ?? []);

              if (movimientos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No hay movimientos para este período',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: movimientos.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final m = movimientos[index];
                  return _buildMovimientoItem(context, m, colorScheme, isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String value, String label, bool isDark) {
    final selected = _periodoSeleccionado == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _periodoSeleccionado = value;
          _cargarMovimientos();
        });
      },
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildMovimientoItem(
    BuildContext context,
    MovimientoLoteEntity m,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final color = _getTipoColor(m.tipo);
    final icon = _getTipoIcon(m.tipo);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        _getTipoLabel(m.tipo),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cantidad: ${m.cantidad} kg',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (m.observaciones != null && m.observaciones!.isNotEmpty)
            Text(
              m.observaciones!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(m.fecha),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Usuario: ${m.usuarioId}',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'activacion':
        return Colors.green;
      case 'venta':
        return Colors.blue;
      case 'traspaso':
        return Colors.orange;
      case 'devolucion':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'activacion':
        return Icons.play_arrow_rounded;
      case 'venta':
        return Icons.shopping_cart_rounded;
      case 'traspaso':
        return Icons.swap_horiz_rounded;
      case 'devolucion':
        return Icons.undo_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'activacion':
        return 'Activación';
      case 'venta':
        return 'Venta';
      case 'traspaso':
        return 'Traspaso';
      case 'devolucion':
        return 'Devolución';
      default:
        return tipo;
    }
  }
}