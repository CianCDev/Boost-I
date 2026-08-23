import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import '../providers/catalog_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/pedidos/estado_chip.dart';

class DetallePedidoProveedorScreen extends ConsumerStatefulWidget {
  final int pedidoId;

  const DetallePedidoProveedorScreen({super.key, required this.pedidoId});

  @override
  ConsumerState<DetallePedidoProveedorScreen> createState() => _DetallePedidoProveedorScreenState();
}

class _DetallePedidoProveedorScreenState extends ConsumerState<DetallePedidoProveedorScreen> {
  late Future<PedidoEntity?> _pedidoFuture;
  late Future<List<DetallePedidoEntity>> _detallesFuture;
  late Future<RecepcionEntity?> _recepcionFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final isar = ref.read(isarServiceProvider);
    _pedidoFuture = isar.obtenerPedidoPorId(widget.pedidoId);
    _detallesFuture = isar.obtenerDetallesPorPedido(widget.pedidoId);
    _recepcionFuture = isar.obtenerRecepcionPorPedido(widget.pedidoId);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Detalle del Pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => setState(() => _cargarDatos()),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([_pedidoFuture, _detallesFuture, _recepcionFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos del pedido'));
          }

          final pedido = snapshot.data![0] as PedidoEntity?;
          if (pedido == null) {
            return const Center(child: Text('Pedido no encontrado'));
          }
          final detalles = snapshot.data![1] as List<DetallePedidoEntity>;
          final recepcion = snapshot.data![2] as RecepcionEntity?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoPedido(pedido: pedido),
                const SizedBox(height: 20),
                DetallesList(detalles: detalles),
                const SizedBox(height: 20),
                if (recepcion != null) ...[
                  InfoRecepcion(recepcion: recepcion),
                  const SizedBox(height: 20),
                ],
                AccionesPedido(
                  pedido: pedido,
                  onActualizar: () => setState(() => _cargarDatos()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// WIDGET: INFO DEL PROVEEDOR
// ==========================================
class InfoPedido extends StatelessWidget {
  final PedidoEntity pedido;

  const InfoPedido({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final fechaLocal = pedido.fechaPedido.toLocal();
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(fechaLocal);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.surface,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pedido.proveedorNombre.isNotEmpty ? pedido.proveedorNombre : 'Proveedor sin nombre',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                EstadoChip(estado: pedido.estado),
              ],
            ),
            const SizedBox(height: 12),
            Divider(thickness: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 12),
            _buildInfoRow(colorScheme, Icons.badge_outlined, 'Cédula / RIF', pedido.proveedorCedula ?? 'No especificada'),
            const SizedBox(height: 6),
            _buildInfoRow(colorScheme, Icons.phone_outlined, 'Teléfono', pedido.proveedorTelefono ?? 'No especificado'),
            const SizedBox(height: 6),
            _buildInfoRow(colorScheme, Icons.calendar_today_outlined, 'Fecha del pedido', fechaFormateada),
            const SizedBox(height: 6),
            _buildInfoRow(colorScheme, Icons.storefront_outlined, 'Local destino', 'Local ${pedido.localDestinoId}'),
            if (pedido.observaciones != null && pedido.observaciones!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildInfoRow(colorScheme, Icons.note_outlined, 'Observaciones', pedido.observaciones!),
            ],
            const SizedBox(height: 12),
            Divider(thickness: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL DEL PEDIDO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8),
                  ),
                  Text(
                    'Bs ${pedido.total.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ColorScheme colorScheme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// WIDGET: LISTA DE PRODUCTOS
// ==========================================
class DetallesList extends StatelessWidget {
  final List<DetallePedidoEntity> detalles;

  const DetallesList({super.key, required this.detalles});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (detalles.isEmpty) {
      return Center(
        child: Text(
          'No hay productos en este pedido.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.surface,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Productos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...detalles.map((d) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2_outlined, color: colorScheme.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.nombreProducto, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colorScheme.onSurface)),
                          const SizedBox(height: 2),
                          Text(
                            '${d.cantidad.toStringAsFixed(d.cantidad % 1 == 0 ? 0 : 3)} x Bs ${d.precioUnidad.toStringAsFixed(2)}',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Bs ${d.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 15),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: INFORMACIÓN DE RECEPCIÓN
// ==========================================
class InfoRecepcion extends StatelessWidget {
  final RecepcionEntity recepcion;

  const InfoRecepcion({super.key, required this.recepcion});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.green.shade50,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Recepción registrada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(recepcion.fechaRecepcion.toLocal()),
                    style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                  ),
                  if (recepcion.observaciones != null && recepcion.observaciones!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      recepcion.observaciones!,
                      style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: ACCIONES DEL PEDIDO
// ==========================================
class AccionesPedido extends ConsumerWidget {
  final PedidoEntity pedido;
  final VoidCallback onActualizar;

  const AccionesPedido({super.key, required this.pedido, required this.onActualizar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (pedido.estado == EstadoPedido.recibido || pedido.estado == EstadoPedido.cancelado) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Pedido ya finalizado',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final messenger = ScaffoldMessenger.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => RegistrarRecepcionDialog(pedidoId: pedido.id),
            );
            if (result == true) {
              onActualizar();
            }
          },
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: const Text('Registrar Recepción'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Cancelar Pedido'),
                content: const Text('¿Estás seguro de cancelar este pedido?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sí, cancelar'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              try {
                await ref.read(cancelarPedidoProvider(pedido.id).future);
                messenger.showSnackBar(
                  const SnackBar(content: Text('✅ Pedido cancelado'), backgroundColor: Color(0xFF10B981)),
                );
                onActualizar();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            }
          },
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: const Text('Cancelar Pedido'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// DIÁLOGO: REGISTRAR RECEPCIÓN (CORREGIDO)
// ==========================================
class RegistrarRecepcionDialog extends ConsumerStatefulWidget {
  final int pedidoId;

  const RegistrarRecepcionDialog({super.key, required this.pedidoId});

  @override
  ConsumerState<RegistrarRecepcionDialog> createState() => _RegistrarRecepcionDialogState();
}

class _RegistrarRecepcionDialogState extends ConsumerState<RegistrarRecepcionDialog> {
  final TextEditingController _observacionesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Registrar Recepción', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Confirma la llegada de todos los productos al inventario.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _observacionesController,
              decoration: InputDecoration(
                labelText: 'Observaciones (opcional)',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _confirmarRecepcion,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmar Recepción'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Future<void> _confirmarRecepcion() async {
  setState(() => _isLoading = true);
  try {
    final userId = 1; // Obtener usuario actual
    await ref.read(registrarRecepcionProvider((
      pedidoId: widget.pedidoId,
      usuarioId: userId,
      observaciones: _observacionesController.text,
      fechasVencimiento: null,
      costosUnitarios: null,
    )).future);

    // ✅ 1. RECARGAR EL CATÁLOGO (refresca el provider completo)
    ref.refresh(catalogProvider);

    // ✅ 2. INCREMENTAR EL CONTADOR PARA RECONSTRUIR EL GRIDVIEW
    ref.read(refreshCatalogCounterProvider.notifier).state++;

    // ✅ 3. ACTUALIZAR LA LISTA DE PEDIDOS
    ref.invalidate(pedidosPorEstadoProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Recepción registrada y stock actualizado'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
    Navigator.pop(context, true);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
}