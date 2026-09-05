// lib/features/pos/presentation/screens/lotes/lotes_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/movimientos_tab.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/codigos_tab.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/asignar_codigo_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart'; // ✅ Importar el diálogo
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/themes/app_colors.dart';

class LotesDetalleScreen extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const LotesDetalleScreen({super.key, required this.lote});

  @override
  ConsumerState<LotesDetalleScreen> createState() => _LotesDetalleScreenState();
}

class _LotesDetalleScreenState extends ConsumerState<LotesDetalleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<String?> _productoNombreFuture;
  late Future<List<dynamic>> _movimientosFuture; // Usamos dynamic para simplificar
  final IsarService _isar = IsarService();

  @override
  void initState() {
    super.initState();
    final isPendiente = widget.lote.estado == 'pendiente';
    _tabController = TabController(length: isPendiente ? 1 : 3, vsync: this);
    _cargarDatos();
  }

  // ✅ Método para cargar/recargar datos
  void _cargarDatos() {
    _productoNombreFuture = _isar.obtenerProductoPorId(widget.lote.productoId)
        .then((producto) => producto?.nombre);
    _movimientosFuture = _isar.obtenerMovimientosPorLote(widget.lote.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPendiente = widget.lote.estado == 'pendiente';
    final estadoColor = _getEstadoColor(widget.lote.estado);
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Lote #${widget.lote.id}',
        showBackButton: true,
      ),
      body: FutureBuilder<String?>(
        future: _productoNombreFuture,
        builder: (context, snapshot) {
          final productoNombre = snapshot.data ?? 'Producto #${widget.lote.productoId}';

          if (isPendiente) {
            return _buildPendienteLayout(productoNombre, isDark, colorScheme, esAdmin);
          } else {
            return _buildLayoutConTabs(productoNombre, isDark, colorScheme, esAdmin);
          }
        },
      ),
    );
  }

  // ============================================================
  // LAYOUT PARA LOTES PENDIENTES
  // ============================================================
  Widget _buildPendienteLayout(String productoNombre, bool isDark, ColorScheme colorScheme, bool esAdmin) {
    final lote = widget.lote;
    final estadoColor = _getEstadoColor(lote.estado);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        productoNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: estadoColor.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        lote.estado.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: estadoColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Pendiente de activar',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Ingreso: ${_formatearFecha(lote.fechaIngreso)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (lote.proveedorNombre != null && lote.proveedorNombre!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.business_center_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            lote.proveedorNombre!,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botón ACTIVAR LOTE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => AsignarCodigoLoteDialog(lote: widget.lote),
                );
                if (result == true && mounted) {
                  ref.read(lotesProvider.notifier).recargar();
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 28),
              label: const Text(
                'ACTIVAR LOTE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.orange.shade600.withValues(alpha: 0.4),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información detallada
          Card(
            elevation: 0,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.orange.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar ID solo para admins
                  if (esAdmin) ...[
                    _buildInfoRow('ID del lote', '#${lote.id}', colorScheme),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoRow('Estado', lote.estado.toUpperCase(), colorScheme,
                      color: estadoColor),
                  _buildInfoRow('Código de barras', lote.codigoLoteProveedor ?? 'Sin asignar', colorScheme),
                  const SizedBox(height: 8),
                  _buildInfoRow('Cantidad', '${lote.cantidadInicial} kg', colorScheme),
                  const SizedBox(height: 8),
                  _buildInfoRow('Fecha de ingreso', _formatearFecha(lote.fechaIngreso), colorScheme),
                  if (lote.fechaVencimiento != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Fecha de vencimiento', _formatearFecha(lote.fechaVencimiento!), colorScheme),
                  ],
                  if (lote.proveedorNombre != null && lote.proveedorNombre!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Proveedor', lote.proveedorNombre!, colorScheme),
                  ],
                  if (lote.costoUnitario != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Costo unitario', '\$${lote.costoUnitario!.toStringAsFixed(2)}', colorScheme),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mensaje informativo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.orange.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este lote está pendiente de activación. '
                    'Presiona el botón "ACTIVAR LOTE" para asignar un código de barras y fecha de vencimiento.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT CON TABS (para lotes activos, agotados, vencidos)
  // ============================================================
  Widget _buildLayoutConTabs(String productoNombre, bool isDark, ColorScheme colorScheme, bool esAdmin) {
    final lote = widget.lote;
    final isPendiente = lote.estado == 'pendiente';

    return Column(
      children: [
        _buildHeader(productoNombre, isDark, colorScheme, esAdmin),
        _buildTabs(isPendiente, colorScheme, isDark),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(esAdmin),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER (sin borde inferior)
  // ============================================================
  Widget _buildHeader(String productoNombre, bool isDark, ColorScheme colorScheme, bool esAdmin) {
    final lote = widget.lote;
    final isPendiente = lote.estado == 'pendiente';
    final estadoColor = _getEstadoColor(lote.estado);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  productoNombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: estadoColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  lote.estado.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: estadoColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    isPendiente
                        ? 'Pendiente de activar'
                        : 'Restante: ${lote.cantidadRestante} kg',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isPendiente ? FontWeight.w500 : FontWeight.normal,
                      color: isPendiente ? Colors.orange.shade600 : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Ingreso: ${_formatearFecha(lote.fechaIngreso)}',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (lote.fechaVencimiento != null && !isPendiente)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_available_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Vence: ${_formatearFecha(lote.fechaVencimiento!)}',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              if (lote.proveedorNombre != null && lote.proveedorNombre!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business_center_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      lote.proveedorNombre!,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS (sin línea gris)
  // ============================================================
  Widget _buildTabs(bool isPendiente, ColorScheme colorScheme, bool isDark) {
    final List<Widget> tabs = isPendiente
        ? const [
            Tab(icon: Icon(Icons.info_rounded), text: 'Información'),
          ]
        : const [
            Tab(icon: Icon(Icons.info_rounded), text: 'Información'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Movimientos'),
            Tab(icon: Icon(Icons.qr_code_rounded), text: 'Códigos'),
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        labelColor: const Color(0xFF8B5CF6),
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: tabs,
      ),
    );
  }

  // ============================================================
  // TAB VIEWS
  // ============================================================
  List<Widget> _buildTabViews(bool esAdmin) {
    final isPendiente = widget.lote.estado == 'pendiente';

    if (isPendiente) {
      return [
        _buildInfoTab(esAdmin),
      ];
    } else {
      return [
        _buildInfoTab(esAdmin),
        MovimientosTab(lote: widget.lote),
        CodigosTab(productoId: widget.lote.productoId),
      ];
    }
  }

  // ============================================================
  // TAB DE INFORMACIÓN (con botón Reponer y actualización automática)
  // ============================================================
  Widget _buildInfoTab(bool esAdmin) {
    final lote = widget.lote;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPendiente = lote.estado == 'pendiente';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isPendiente
                    ? Colors.orange.withValues(alpha: 0.3)
                    : colorScheme.outline.withValues(alpha: 0.1),
                width: isPendiente ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Mostrar ID solo para admins
                  if (esAdmin) ...[
                    _buildInfoRow('ID del lote', '#${lote.id}', colorScheme),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoRow('Estado', lote.estado.toUpperCase(), colorScheme,
                      color: _getEstadoColor(lote.estado)),
                  _buildInfoRow('Código de barras', lote.codigoLoteProveedor ?? 'Sin asignar', colorScheme),
                  const SizedBox(height: 8),
                  _buildInfoRow('Cantidad', '${lote.cantidadInicial} kg', colorScheme),
                  if (!isPendiente) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Restante', '${lote.cantidadRestante} kg', colorScheme),
                  ],
                  const SizedBox(height: 8),
                  _buildInfoRow('Fecha de ingreso', _formatearFecha(lote.fechaIngreso), colorScheme),
                  if (lote.fechaVencimiento != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Fecha de vencimiento', _formatearFecha(lote.fechaVencimiento!), colorScheme),
                  ],
                  if (lote.proveedorNombre != null && lote.proveedorNombre!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Proveedor', lote.proveedorNombre!, colorScheme),
                  ],
                  if (lote.costoUnitario != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Costo unitario', '\$${lote.costoUnitario!.toStringAsFixed(2)}', colorScheme),
                  ],
                ],
              ),
            ),
          ),

          // ✅ Botón REPONER (solo para admins, lotes activos con stock restante)
          if (!isPendiente && lote.estado == 'activo' && lote.cantidadRestante > 0 && esAdmin) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Abrir diálogo y esperar resultado
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (_) => TraspasoLoteDialog(lote: lote),
                  );
                  
                  // ✅ Si la reposición fue exitosa, recargar datos
                  if (result == true && mounted) {
                    // 1. Recargar datos del lote (nombre, etc.)
                    setState(() {
                      _cargarDatos();
                    });
                    
                    // 2. Recargar el provider de lotes (para actualizar el dashboard)
                    ref.read(lotesProvider.notifier).recargar();
                    
                    // 3. Mostrar confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Stock repuesto correctamente'),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                label: const Text('Reponer Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          // Mensaje informativo para pendientes
          if (isPendiente)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este lote está pendiente de activación. '
                      'Presiona el botón "ACTIVAR LOTE" para asignar un código de barras y fecha de vencimiento.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // MÉTODOS AUXILIARES
  // ============================================================
  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange.shade600;
      case 'activo': return Colors.green.shade600;
      case 'agotado': return Colors.red.shade600;
      case 'vencido': return Colors.purple.shade600;
      default: return Colors.grey;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}