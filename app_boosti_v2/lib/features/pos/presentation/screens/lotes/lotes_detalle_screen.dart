// lib/features/pos/presentation/screens/lotes/lotes_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/movimientos_tab.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/codigos_tab.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/asignar_codigo_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
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

  @override
  void initState() {
    super.initState();
    final isPendiente = widget.lote.estado == 'pendiente';
    // Si es pendiente, solo mostramos 2 tabs: Información y Códigos
    final tabCount = isPendiente ? 2 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
    _productoNombreFuture = _cargarProductoNombre();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String?> _cargarProductoNombre() async {
    final isar = IsarService();
    final producto = await isar.obtenerProductoPorId(widget.lote.productoId);
    return producto?.nombre;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPendiente = widget.lote.estado == 'pendiente';
    final estadoColor = _getEstadoColor(widget.lote.estado);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Lote #${widget.lote.id}',
        showBackButton: true,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: estadoColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              widget.lote.estado.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: estadoColor,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _productoNombreFuture,
        builder: (context, snapshot) {
          final productoNombre = snapshot.data ?? 'Producto #${widget.lote.productoId}';

          return Column(
            children: [
              // ✅ Encabezado con información del lote (rediseñado)
              _buildHeader(productoNombre, isDark, colorScheme),

              // ✅ Si es pendiente, mostrar botón de activar grande
              if (isPendiente) ...[
                _buildActivarButton(context),
                const SizedBox(height: 8),
              ],

              // ✅ Tabs (dinámicos según estado)
              _buildTabs(isPendiente, colorScheme),

              // Contenido
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _buildTabViews(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String productoNombre, bool isDark, ColorScheme colorScheme) {
    final lote = widget.lote;
    final isPendiente = lote.estado == 'pendiente';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productoNombre,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.inventory_2_rounded, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                isPendiente
                    ? 'Pendiente de activar'
                    : 'Restante: ${lote.cantidadRestante} kg',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isPendiente ? FontWeight.w500 : FontWeight.normal,
                  color: isPendiente ? Colors.orange.shade600 : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Ingreso: ${_formatearFecha(lote.fechaIngreso)}',
                style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          if (lote.fechaVencimiento != null && !isPendiente)
            Row(
              children: [
                Icon(Icons.event_available_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Vence: ${_formatearFecha(lote.fechaVencimiento!)}',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          if (lote.proveedorNombre != null && lote.proveedorNombre!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.business_center_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Proveedor: ${lote.proveedorNombre}',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActivarButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (_) => AsignarCodigoLoteDialog(lote: widget.lote),
          );
          if (result == true && mounted) {
            // Recargar la lista y volver atrás
            ref.read(lotesProvider.notifier).recargar();
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 24),
        label: const Text(
          'ACTIVAR LOTE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.orange.shade600.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildTabs(bool isPendiente, ColorScheme colorScheme) {
    return TabBar(
      controller: _tabController,
      indicatorColor: colorScheme.primary,
      labelColor: colorScheme.primary,
      tabs: isPendiente
          ? const [
              Tab(icon: Icon(Icons.info_rounded), text: 'Información'),
              Tab(icon: Icon(Icons.qr_code_rounded), text: 'Códigos'),
            ]
          : const [
              Tab(icon: Icon(Icons.info_rounded), text: 'Información'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Movimientos'),
              Tab(icon: Icon(Icons.qr_code_rounded), text: 'Códigos'),
            ],
    );
  }

  List<Widget> _buildTabViews() {
    final isPendiente = widget.lote.estado == 'pendiente';

    if (isPendiente) {
      return [
        _buildInfoTab(), // Información del lote pendiente
        CodigosTab(productoId: widget.lote.productoId),
      ];
    } else {
      return [
        _buildInfoTab(),
        MovimientosTab(lote: widget.lote),
        CodigosTab(productoId: widget.lote.productoId),
      ];
    }
  }

  Widget _buildInfoTab() {
    final lote = widget.lote;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPendiente = lote.estado == 'pendiente';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de información del lote
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
                  _buildInfoRow('ID del lote', '#${lote.id}', colorScheme),
                  const SizedBox(height: 8),
                  _buildInfoRow('Estado', lote.estado.toUpperCase(), colorScheme,
                      color: _getEstadoColor(lote.estado)),
                  const SizedBox(height: 8),
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

          // Mensaje adicional para lotes pendientes
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
      case 'pendiente':
        return Colors.orange.shade600;
      case 'activo':
        return Colors.green.shade600;
      case 'agotado':
        return Colors.red.shade600;
      case 'vencido':
        return Colors.purple.shade600;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}