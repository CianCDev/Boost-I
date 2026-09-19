// lib/features/pos/presentation/widgets/proveedores/detalle_proveedor_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/multi_select_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../common/glass_dialog.dart';
import '../common/status_badge.dart';

class DetalleProveedorDialog extends ConsumerWidget {
  final ProveedorEntity proveedor;

  const DetalleProveedorDialog({super.key, required this.proveedor});

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync =
        ref.watch(productosPorProveedorProvider(proveedor.id));
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 720,
      maxHeightFactor: 0.9,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 18 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ HERO (fijo arriba) ═══
            _buildHero(context, isMobile, colorScheme),
            const SizedBox(height: 22),

            // ═══ SECCIONES (scrollable si hace falta) ═══
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIdentificacion(context, isMobile, colorScheme),
                    const SizedBox(height: 20),
                    _buildContacto(context, isMobile, colorScheme),
                    const SizedBox(height: 20),
                    _buildProductosSection(
                      context,
                      ref,
                      isMobile,
                      colorScheme,
                      productosAsync,
                      esAdmin,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHero(
    BuildContext context,
    bool isMobile,
    ColorScheme colorScheme,
  ) {
    final activo = proveedor.activo;
    final estadoColor = activo ? _colorSuccess : _colorDanger;
    final inicial = proveedor.nombre.isNotEmpty
        ? proveedor.nombre[0].toUpperCase()
        : '?';
    final mostrarEmpresa = proveedor.empresa != null &&
        proveedor.empresa!.isNotEmpty &&
        proveedor.empresa!.toLowerCase() != proveedor.nombre.toLowerCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(inicial, activo, isMobile),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                proveedor.nombre,
                style: TextStyle(
                  fontSize: isMobile ? 19 : 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (mostrarEmpresa) ...[
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        proveedor.empresa!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StatusBadge(
                    label: activo ? 'Activo' : 'Inactivo',
                    color: estadoColor,
                    size: StatusBadgeSize.medium,
                  ),
                  if (proveedor.supabaseId != null) _syncBadge(),
                ],
              ),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Cerrar',
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String inicial, bool activo, bool isMobile) {
    final size = isMobile ? 58.0 : 68.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: activo
              ? const [_colorPrimary, Color(0xFF6D28D9)]
              : [
                  _colorPrimary.withValues(alpha: 0.5),
                  const Color(0xFF6D28D9).withValues(alpha: 0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _colorPrimary.withValues(alpha: activo ? 0.35 : 0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          inicial,
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _syncBadge() {
    final sincronizado = proveedor.sincronizado;
    final color = sincronizado ? _colorSuccess : _colorWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sincronizado
                ? Icons.cloud_done_rounded
                : Icons.cloud_off_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            sincronizado ? 'Sincronizado' : 'Pendiente',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SECCIÓN: IDENTIFICACIÓN
  // ═══════════════════════════════════════════════════════════════

  Widget _buildIdentificacion(
    BuildContext context,
    bool isMobile,
    ColorScheme colorScheme,
  ) {
    final tieneRif = proveedor.rif != null && proveedor.rif!.isNotEmpty;
    final tieneDoc = proveedor.documento != null;
    final tieneCedulaLegacy =
        proveedor.cedula != null && proveedor.cedula!.isNotEmpty;

    final fields = <_FieldEntry>[];

    if (tieneDoc) {
      final tipo = proveedor.tipoDocumento ?? '';
      final numero = proveedor.documento.toString();
      fields.add(_FieldEntry(
        _infoField(
          context,
          icon: _iconoDocumento(proveedor.tipoDocumento),
          label: 'Documento',
          value: tipo.isEmpty ? numero : '$tipo-$numero',
          color: _colorPrimary,
          colorScheme: colorScheme,
        ),
      ));
    } else if (tieneCedulaLegacy) {
      fields.add(_FieldEntry(
        _infoField(
          context,
          icon: Icons.badge_rounded,
          label: 'Cédula / Documento',
          value: proveedor.cedula!,
          color: _colorPrimary,
          colorScheme: colorScheme,
        ),
      ));
    }

    if (tieneRif) {
      fields.add(_FieldEntry(
        _infoField(
          context,
          icon: Icons.receipt_long_rounded,
          label: 'RIF',
          value: proveedor.rif!,
          color: _colorPrimary,
          colorScheme: colorScheme,
        ),
      ));
    }

    if (fields.isEmpty) {
      fields.add(_FieldEntry(
        _emptyField(
          context,
          icon: Icons.badge_outlined,
          message: 'Sin identificación registrada',
          colorScheme: colorScheme,
        ),
        fullWidth: true,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          context,
          icon: Icons.badge_rounded,
          title: 'Identificación',
          color: _colorPrimary,
        ),
        _buildFieldsGrid(fields, isMobile),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SECCIÓN: CONTACTO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContacto(
    BuildContext context,
    bool isMobile,
    ColorScheme colorScheme,
  ) {
    final fields = <_FieldEntry>[];

    if (proveedor.telefono?.isNotEmpty ?? false) {
      fields.add(_FieldEntry(
        _infoField(
          context,
          icon: Icons.phone_rounded,
          label: 'Teléfono',
          value: proveedor.telefono!,
          color: _colorSuccess,
          colorScheme: colorScheme,
        ),
      ));
    }

    if (proveedor.email?.isNotEmpty ?? false) {
      fields.add(_FieldEntry(
        _infoField(
          context,
          icon: Icons.email_rounded,
          label: 'Correo',
          value: proveedor.email!,
          color: _colorSuccess,
          colorScheme: colorScheme,
        ),
      ));
    }

    if (proveedor.direccion?.isNotEmpty ?? false) {
      fields.add(_FieldEntry(
        _infoField(
          context,
          icon: Icons.location_on_rounded,
          label: 'Dirección',
          value: proveedor.direccion!,
          color: _colorSuccess,
          colorScheme: colorScheme,
        ),
        fullWidth: true,
      ));
    }

    if (fields.isEmpty) {
      fields.add(_FieldEntry(
        _emptyField(
          context,
          icon: Icons.contact_mail_outlined,
          message: 'Sin datos de contacto',
          colorScheme: colorScheme,
        ),
        fullWidth: true,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          context,
          icon: Icons.contact_mail_rounded,
          title: 'Contacto',
          color: _colorSuccess,
        ),
        _buildFieldsGrid(fields, isMobile),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SECCIÓN: PRODUCTOS ASOCIADOS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildProductosSection(
    BuildContext context,
    WidgetRef ref,
    bool isMobile,
    ColorScheme colorScheme,
    AsyncValue<List<ProductoEntity>> productosAsync,
    bool esAdmin,
  ) {
    final count = productosAsync.maybeWhen(
      data: (p) => p.length,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          context,
          icon: Icons.shopping_bag_rounded,
          title: 'Productos asociados',
          color: _colorPrimary,
          count: count,
          trailing: esAdmin
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _mostrarDialogoAsignarProductos(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(isMobile ? '' : 'Asignar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              : null,
        ),
        productosAsync.when(
          data: (productos) {
            if (productos.isEmpty) {
              return _emptyProductsPanel(context, colorScheme, esAdmin);
            }
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant
                      .withValues(alpha: 0.35),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                itemCount: productos.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color:
                      colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, index) {
                  return _ProductoProveedorTile(
                    producto: productos[index],
                    isMobile: isMobile,
                    colorScheme: colorScheme,
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $err'),
          ),
        ),
      ],
    );
  }

  Widget _emptyProductsPanel(
    BuildContext context,
    ColorScheme colorScheme,
    bool esAdmin,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 32,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            esAdmin
                ? 'No hay productos asignados. Presiona "Asignar" para agregar.'
                : 'No hay productos asignados a este proveedor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COMPONENTES BASE
  // ═══════════════════════════════════════════════════════════════

  /// Header de sección con icono + título + contador + trailing.
  /// Mismo patrón visual que `FormSection` del template.
  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    int? count,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: color.withValues(alpha: 0.25),
              height: 1,
              thickness: 1,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  /// Campo individual: icono en caja + label arriba + valor grande.
  Widget _infoField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.25,
                  letterSpacing: -0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Campo de "estado vacío" cuando no hay datos.
  Widget _emptyField(
    BuildContext context, {
    required IconData icon,
    required String message,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  /// Grid responsive: 1 columna en mobile, 2 en desktop.
  /// Los `fullWidth` ocupan toda la fila.
  Widget _buildFieldsGrid(List<_FieldEntry> fields, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            fields[i].widget,
          ],
        ],
      );
    }

    if (fields.length == 1) {
      return fields.first.widget;
    }

    final rows = <Widget>[];
    int i = 0;
    while (i < fields.length) {
      if (i > 0) rows.add(const SizedBox(height: 14));

      final current = fields[i];

      // Full-width o último → ocupa toda la fila
      if (current.fullWidth || i == fields.length - 1) {
        rows.add(current.widget);
        i += 1;
      } else {
        final next = fields[i + 1];
        if (next.fullWidth) {
          // El siguiente necesita fila completa → el actual va solo
          rows.add(current.widget);
          i += 1;
        } else {
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: current.widget),
              const SizedBox(width: 20),
              Expanded(child: next.widget),
            ],
          ));
          i += 2;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  IconData _iconoDocumento(String? tipo) {
    switch (tipo) {
      case 'J':
        return Icons.storefront_rounded;
      case 'G':
        return Icons.account_balance_rounded;
      case 'P':
        return Icons.flight_takeoff_rounded;
      case 'C':
        return Icons.groups_rounded;
      case 'V':
      case 'E':
      default:
        return Icons.badge_rounded;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ASIGNAR PRODUCTOS (queda igual por ahora — Paso 7 lo reescribe)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _mostrarDialogoAsignarProductos(
      BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarServiceProvider);
    final todosLosProductos = await isar.obtenerProductos();
    final productosSinProveedor =
        todosLosProductos.where((p) => p.proveedorId == null).toList();

    if (productosSinProveedor.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay productos sin proveedor para asignar'),
            backgroundColor: Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final seleccionados = await showDialog<List<ProductoEntity>>(
      context: context,
      builder: (_) => MultiSelectDialog(
        items: productosSinProveedor,
        title: 'Asignar productos a ${proveedor.nombre}',
      ),
    );

    if (seleccionados != null && seleccionados.isNotEmpty) {
      for (var producto in seleccionados) {
        producto.proveedorId = proveedor.id;
        await isar.guardarProducto(producto);
      }
      ref.invalidate(productosPorProveedorProvider(proveedor.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
                '${seleccionados.length} productos asignados a ${proveedor.nombre}'),
            backgroundColor: _colorSuccess,
          ),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MODELO AUXILIAR
// ═══════════════════════════════════════════════════════════════════════

class _FieldEntry {
  final Widget widget;
  final bool fullWidth;
  const _FieldEntry(this.widget, {this.fullWidth = false});
}

// ═══════════════════════════════════════════════════════════════════════
// TILE DE PRODUCTO ASOCIADO
// ═══════════════════════════════════════════════════════════════════════

class _ProductoProveedorTile extends StatefulWidget {
  final ProductoEntity producto;
  final bool isMobile;
  final ColorScheme colorScheme;

  const _ProductoProveedorTile({
    required this.producto,
    required this.isMobile,
    required this.colorScheme,
  });

  @override
  State<_ProductoProveedorTile> createState() =>
      _ProductoProveedorTileState();
}

class _ProductoProveedorTileState extends State<_ProductoProveedorTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Color(0xFF8B5CF6),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.producto.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.colorScheme.onSurface,
                      fontSize: widget.isMobile ? 13 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Código: ${widget.producto.codigoBarras}',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
                fontSize: widget.isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}