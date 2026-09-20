// lib/features/pos/presentation/widgets/inventory/product_proveedor_tab.dart
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/persona_form_template.dart';
import 'package:flutter/material.dart';
import '../../../data/Local/entities/proveedor_entity.dart';
import '../../utils/responsive_helper.dart';
import '../common/dialog_header.dart';
import '../common/glass_search_bar.dart';

/// Pestaña "Proveedor" del formulario de productos.
class ProductProveedorTab extends StatelessWidget {
  final List<ProveedorEntity> proveedores;
  final ProveedorEntity? proveedorSeleccionado;
  final bool cargandoProveedores;

  final VoidCallback onAbrirPanel;
  final VoidCallback onCrearProveedor;
  final ValueChanged<ProveedorEntity?> onSeleccionar;
  final TextEditingController busquedaController;

  const ProductProveedorTab({
    super.key,
    required this.proveedores,
    required this.proveedorSeleccionado,
    required this.cargandoProveedores,
    required this.onAbrirPanel,
    required this.onCrearProveedor,
    required this.onSeleccionar,
    required this.busquedaController,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSelector(context, cs, isMobile),
          const SizedBox(height: 16),
          _buildBotonCrear(cs),
          const SizedBox(height: 16),
          if (proveedorSeleccionado != null)
            _ProveedorSeleccionadoCard(
              proveedor: proveedorSeleccionado!,
              onQuitar: () => onSeleccionar(null),
            ),
        ],
      ),
    );
  }

  // ✅ FIX: Ahora recibe `context` explícitamente.
  Widget _buildSelector(
    BuildContext context,
    ColorScheme cs,
    bool isMobile,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center_rounded,
                  color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Proveedores',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(Icons.view_list_rounded,
                      color: cs.primary, size: 20),
                  tooltip: 'Ver todos',
                  onPressed: onAbrirPanel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cargandoProveedores)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (proveedores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No hay proveedores activos. Crea uno desde abajo.',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            )
          else
            Autocomplete<ProveedorEntity>(
              optionsBuilder: (v) {
                if (v.text.isEmpty) return proveedores;
                final q = v.text.toLowerCase();
                return proveedores.where((p) =>
                    p.nombre.toLowerCase().contains(q) ||
                    (p.empresa ?? '').toLowerCase().contains(q));
              },
              displayStringForOption: (p) => p.nombre,
              fieldViewBuilder: (context, controller, focusNode, _) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(color: cs.onSurface),
                  decoration: buildInputDecoration(
                    label: 'Buscar proveedor...',
                    icon: Icons.search_rounded,
                    accentColor: cs.primary,
                    colorScheme: cs,
                  ),
                  onChanged: (value) {
                    if (proveedorSeleccionado != null &&
                        proveedorSeleccionado!.nombre != value) {
                      onSeleccionar(null);
                    }
                  },
                );
              },
              onSelected: onSeleccionar,
              optionsViewBuilder: (_, onSelected, options) => Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: cs.surface,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 200, minWidth: 300),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (_, i) {
                        final opt = options.elementAt(i);
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.business_rounded,
                              color: cs.primary, size: 20),
                          title: Text(opt.nombre),
                          subtitle: (opt.empresa ?? '').isEmpty
                              ? null
                              : Text(opt.empresa!,
                                  style: const TextStyle(fontSize: 12)),
                          tileColor: opt == proveedorSeleccionado
                              ? cs.primary.withValues(alpha: 0.1)
                              : null,
                          onTap: () => onSelected(opt),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBotonCrear(ColorScheme cs) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onCrearProveedor,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          label: const Text(
            'Crear nuevo proveedor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

/// Card con los datos del proveedor actualmente seleccionado.
class _ProveedorSeleccionadoCard extends StatelessWidget {
  final ProveedorEntity proveedor;
  final VoidCallback onQuitar;

  static const Color _colorPrimary = Color(0xFF8B5CF6);

  const _ProveedorSeleccionadoCard({
    required this.proveedor,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _colorPrimary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: _colorPrimary),
              const SizedBox(width: 6),
              const Text(
                'Proveedor seleccionado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _colorPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                  onPressed: onQuitar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Quitar',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            proveedor.nombre,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (proveedor.telefono?.isNotEmpty ?? false)
            _detalle(Icons.phone_rounded, proveedor.telefono!, cs),
          if (proveedor.email?.isNotEmpty ?? false)
            _detalle(Icons.email_rounded, proveedor.email!, cs),
          if (proveedor.direccion?.isNotEmpty ?? false)
            _detalle(Icons.location_on_rounded, proveedor.direccion!, cs),
        ],
      ),
    );
  }

  Widget _detalle(IconData icon, String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style:
                  TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PANEL LATERAL DE PROVEEDORES
// ═══════════════════════════════════════════════════════════════════════

class ProveedoresPanelDialog extends StatefulWidget {
  final List<ProveedorEntity> proveedores;
  final ProveedorEntity? seleccionado;
  final void Function(ProveedorEntity) onSeleccionar;
  final VoidCallback onCrearProveedor;

  const ProveedoresPanelDialog({
    super.key,
    required this.proveedores,
    this.seleccionado,
    required this.onSeleccionar,
    required this.onCrearProveedor,
  });

  @override
  State<ProveedoresPanelDialog> createState() =>
      _ProveedoresPanelDialogState();
}

class _ProveedoresPanelDialogState extends State<ProveedoresPanelDialog> {
  String _busqueda = '';

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  List<ProveedorEntity> get _filtrados {
    if (_busqueda.isEmpty) return widget.proveedores;
    final q = _busqueda.toLowerCase();
    return widget.proveedores
        .where((p) =>
            p.nombre.toLowerCase().contains(q) ||
            (p.empresa ?? '').toLowerCase().contains(q) ||
            (p.telefono ?? '').contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      alignment: Alignment.centerRight,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? cs.surface.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const DialogHeader(
                icon: Icons.business_center_rounded,
                title: 'Proveedores',
                subtitle: 'Selecciona uno o crea uno nuevo',
              ),
              const SizedBox(height: 16),
              GlassSearchBar(
                hint: 'Buscar por nombre, empresa o teléfono...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _filtrados.isEmpty
                    ? _empty(cs)
                    : ListView.separated(
                        itemCount: _filtrados.length,
                        separatorBuilder: (_, __) => Divider(
                          color:
                              cs.outlineVariant.withValues(alpha: 0.4),
                          height: 1,
                        ),
                        itemBuilder: (_, i) {
                          final p = _filtrados[i];
                          final sel = widget.seleccionado?.id == p.id;
                          final activo = p.activo;
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    _colorPrimary.withValues(alpha: 0.12),
                                child: const Icon(
                                  Icons.business_center_rounded,
                                  color: _colorPrimary,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                p.nombre,
                                style: TextStyle(
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: sel
                                      ? _colorPrimary
                                      : cs.onSurface,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  if (p.empresa?.isNotEmpty ?? false)
                                    Text(p.empresa!,
                                        style: const TextStyle(
                                            fontSize: 12)),
                                  if (p.telefono?.isNotEmpty ?? false)
                                    Text('Tel: ${p.telefono}',
                                        style: const TextStyle(
                                            fontSize: 12)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (activo
                                              ? _colorSuccess
                                              : _colorDanger)
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      activo ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: activo
                                            ? _colorSuccess
                                            : _colorDanger,
                                      ),
                                    ),
                                  ),
                                  if (sel) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: _colorPrimary,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                              onTap: () {
                                widget.onSeleccionar(p);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: widget.onCrearProveedor,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text(
                      'Crear Nuevo Proveedor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_center_rounded,
              size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('No hay proveedores',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}