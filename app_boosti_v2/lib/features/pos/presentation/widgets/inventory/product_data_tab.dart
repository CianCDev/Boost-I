// lib/features/pos/presentation/widgets/product/product_data_tab.dart
import 'dart:io';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/persona_form_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

import '../../../data/Local/entities/categoria_entity.dart';
import '../../../data/Local/entities/marca_entity.dart';
import '../../providers/categorias_provider.dart';
import '../../utils/responsive_helper.dart';
import '../common/active_toggle.dart';
import '../inventory/categorias_management_dialog.dart';

/// Pestaña "Producto" del `ProductFormDialog`.
///
/// **Presentacional**: recibe todos los controladores + estado + callbacks
/// del padre. El estado real vive en `_ProductFormDialogState` para poder
/// leer los valores al guardar.
class ProductDataTab extends ConsumerStatefulWidget {
  // ── Controllers ──
  final TextEditingController codigoController;
  final TextEditingController nombreController;
  final TextEditingController precioController;
  final TextEditingController stockController;
  final TextEditingController stockMinController;
  final TextEditingController precioMayorController;
  final TextEditingController cantidadMinimaMayorController;
  final TextEditingController precioMedioMayorController;
  final TextEditingController cantidadMinimaMedioMayorController;
  final TextEditingController unidadesPorBultoController;
  final TextEditingController costoUnitarioController;

  // ── State ──
  final bool esPesado;
  final bool activo;
  final bool permiteVentaMayor;
  final bool generandoCodigo;
  final bool subiendoImagen;
  final int? categoriaIdSeleccionada;
  final String categoriaSeleccionada;
  final MarcaEntity? marcaSeleccionada;
  final String imagenUrlPreview;
  final XFile? imagenSeleccionada;

  // ── Callbacks ──
  final ValueChanged<bool> onEsPesadoChanged;
  final ValueChanged<bool> onActivoChanged;
  final ValueChanged<bool> onPermiteVentaMayorChanged;
  final ValueChanged<MarcaEntity?> onMarcaChanged;
  final ValueChanged<CategoriaEntity?> onCategoriaChanged;
  final VoidCallback onGenerarCodigo;
  final VoidCallback onEscanear;
  final ValueChanged<ImageSource> onPickImage;
  final VoidCallback onClearImage;

  const ProductDataTab({
    super.key,
    required this.codigoController,
    required this.nombreController,
    required this.precioController,
    required this.stockController,
    required this.stockMinController,
    required this.precioMayorController,
    required this.cantidadMinimaMayorController,
    required this.precioMedioMayorController,
    required this.cantidadMinimaMedioMayorController,
    required this.unidadesPorBultoController,
    required this.costoUnitarioController,
    required this.esPesado,
    required this.activo,
    required this.permiteVentaMayor,
    required this.generandoCodigo,
    required this.subiendoImagen,
    required this.categoriaIdSeleccionada,
    required this.categoriaSeleccionada,
    required this.marcaSeleccionada,
    required this.imagenUrlPreview,
    required this.imagenSeleccionada,
    required this.onEsPesadoChanged,
    required this.onActivoChanged,
    required this.onPermiteVentaMayorChanged,
    required this.onMarcaChanged,
    required this.onCategoriaChanged,
    required this.onGenerarCodigo,
    required this.onEscanear,
    required this.onPickImage,
    required this.onClearImage,
  });

  @override
  ConsumerState<ProductDataTab> createState() => _ProductDataTabState();
}

class _ProductDataTabState extends ConsumerState<ProductDataTab> {
  static const Color _colorMayor = Color(0xFF8B5CF6);
  static const Color _colorInfo = Color(0xFF3B82F6);
  static const Color _colorDanger = Color(0xFFEF4444);

  late final TextEditingController _marcaSearchCtrl;

  @override
  void initState() {
    super.initState();
    _marcaSearchCtrl =
        TextEditingController(text: widget.marcaSeleccionada?.nombre ?? '');
  }

  @override
  void dispose() {
    _marcaSearchCtrl.dispose();
    super.dispose();
  }

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
          FormSection(
            title: 'Identificación',
            icon: Icons.qr_code_rounded,
            accentColor: cs.primary,
            children: [
              _buildBarcodeField(cs),
              const SizedBox(height: 14),
              PersonaTextField(
                controller: widget.nombreController,
                label: 'Nombre del producto *',
                icon: Icons.label_outline_rounded,
                accentColor: cs.primary,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              _buildMarcaField(cs),
              const SizedBox(height: 14),
              _buildCategoriaField(cs),
            ],
          ),
          const SizedBox(height: 22),

          FormSection(
            title: 'Presentación',
            icon: Icons.tune_rounded,
            accentColor: cs.primary,
            children: [
              _buildSwitchPesado(cs),
              const SizedBox(height: 12),
              ActiveToggle(
                value: widget.activo,
                onChanged: widget.onActivoChanged,
                activeLabel: 'Producto activo',
                inactiveLabel: 'Producto inactivo',
                activeSubtitle: 'Disponible en el catálogo y POS',
                inactiveSubtitle: 'Oculto de la operación actual',
              ),
            ],
          ),
          const SizedBox(height: 22),

          _buildImageSection(cs, isMobile),
          const SizedBox(height: 22),

          FormSection(
            title: 'Precios y stock',
            icon: Icons.attach_money_rounded,
            accentColor: cs.primary,
            children: [_buildPrecioStock(cs, isMobile)],
          ),
          const SizedBox(height: 22),

          _buildWholesaleSection(cs),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CÓDIGO DE BARRAS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBarcodeField(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PersonaTextField(
          controller: widget.codigoController,
          label: 'Código de barras *',
          icon: Icons.qr_code_2_rounded,
          accentColor: cs.primary,
          keyboardType: TextInputType.text,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMiniActionButton(
              icon: Icons.refresh_rounded,
              label: 'Generar',
              color: cs.primary,
              onPressed: widget.generandoCodigo ? null : widget.onGenerarCodigo,
            ),
            _buildMiniActionButton(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Escanear',
              color: cs.secondary,
              onPressed: widget.onEscanear,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return MouseRegion(
      cursor: onPressed == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
          backgroundColor: color.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MARCA (Autocomplete)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMarcaField(ColorScheme cs) {
    return _MarcaAutocomplete(
      controller: _marcaSearchCtrl,
      seleccionada: widget.marcaSeleccionada,
      onChanged: widget.onMarcaChanged,
      accentColor: cs.primary,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CATEGORÍA (Dropdown + botón gestionar)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCategoriaField(ColorScheme cs) {
    final activasAsync = ref.watch(categoriasProvider);
    final todasAsync = ref.watch(todasLasCategoriasProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activasAsync.isLoading || todasAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final activas = activasAsync.valueOrNull ?? const <CategoriaEntity>[];
    final todas = todasAsync.valueOrNull ?? const <CategoriaEntity>[];
    final opciones = _combinarCategorias(activas, todas);

    final seleccionada = _resolverSeleccionada(opciones);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<CategoriaEntity>(
            initialValue: seleccionada,
            isExpanded: true,
            decoration: buildInputDecoration(
              label: 'Categoría *',
              icon: Icons.category_outlined,
              accentColor: cs.primary,
              colorScheme: cs,
            ),
            hint: const Text('Selecciona una categoría'),
            items: [
              const DropdownMenuItem<CategoriaEntity>(
                value: null,
                child: Text('Sin categoría'),
              ),
              ...opciones.map((cat) => _buildCategoriaItem(cat, cs, isDark)),
            ],
            onChanged: widget.onCategoriaChanged,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Gestionar categorías',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: () =>
                  CategoriasManagementDialog.mostrar(context),
              icon: Icon(Icons.settings_rounded,
                  color: cs.primary, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  /// Combina activas + la categoría actual si está inactiva.
  List<CategoriaEntity> _combinarCategorias(
    List<CategoriaEntity> activas,
    List<CategoriaEntity> todas,
  ) {
    final result = <CategoriaEntity>[...activas];
    final idSel = widget.categoriaIdSeleccionada;

    if (idSel != null && !result.any((c) => c.id == idSel)) {
      final inactiva = todas.firstWhereOrNull((c) => c.id == idSel);
      if (inactiva != null && !inactiva.activo) result.add(inactiva);
    }
    return result;
  }

  CategoriaEntity? _resolverSeleccionada(List<CategoriaEntity> opciones) {
    final idSel = widget.categoriaIdSeleccionada;
    if (idSel != null) {
      final byId = opciones.firstWhereOrNull((c) => c.id == idSel);
      if (byId != null) return byId;
    }
    if (widget.categoriaSeleccionada.isNotEmpty) {
      return opciones.firstWhereOrNull(
        (c) => c.nombre == widget.categoriaSeleccionada,
      );
    }
    return null;
  }

  DropdownMenuItem<CategoriaEntity> _buildCategoriaItem(
    CategoriaEntity cat,
    ColorScheme cs,
    bool isDark,
  ) {
    final activa = cat.activo;
    return DropdownMenuItem<CategoriaEntity>(
      value: cat,
      child: Row(
        children: [
          Icon(
            activa
                ? Icons.category_rounded
                : Icons.visibility_off_rounded,
            size: 15,
            color: activa ? cs.onSurfaceVariant : cs.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activa ? cat.nombre : '${cat.nombre} (inactiva)',
              style: TextStyle(
                color: activa ? cs.onSurface : cs.error,
                fontWeight: activa ? FontWeight.w500 : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SWITCH PESADO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSwitchPesado(ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activo = widget.esPesado;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: activo
              ? _colorInfo.withValues(alpha: 0.10)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: activo
                ? _colorInfo.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: SwitchListTile(
          title: Text(
            '¿Es producto pesado (granel)?',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
          subtitle: Text(
            activo ? 'Se pesa al vender (kg)' : 'Se vende por unidad',
            style: TextStyle(fontSize: 11.5, color: cs.onSurfaceVariant),
          ),
          value: activo,
          onChanged: widget.onEsPesadoChanged,
          activeThumbColor: _colorInfo,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // IMAGEN
  // ═══════════════════════════════════════════════════════════════

  Widget _buildImageSection(ColorScheme cs, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tieneImagen = widget.imagenSeleccionada != null ||
        (widget.imagenUrlPreview.isNotEmpty &&
            widget.imagenUrlPreview.startsWith('http'));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Imagen del producto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildImagePreview(cs),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMiniActionButton(
                icon: Icons.photo_library_rounded,
                label: 'Galería',
                color: cs.primary,
                onPressed: () => widget.onPickImage(ImageSource.gallery),
              ),
              _buildMiniActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'Cámara',
                color: cs.primary,
                onPressed: () => widget.onPickImage(ImageSource.camera),
              ),
              if (tieneImagen)
                _buildMiniActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Eliminar',
                  color: _colorDanger,
                  onPressed: widget.onClearImage,
                ),
            ],
          ),
          if (widget.subiendoImagen) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Subiendo imagen...',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview(ColorScheme cs) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.imagenSeleccionada != null
            ? Image.file(File(widget.imagenSeleccionada!.path),
                fit: BoxFit.cover)
            : widget.imagenUrlPreview.isNotEmpty &&
                    widget.imagenUrlPreview.startsWith('http')
                ? Image.network(
                    widget.imagenUrlPreview,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: cs.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: cs.onSurfaceVariant,
                  ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PRECIO / STOCK / STOCK MIN
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPrecioStock(ColorScheme cs, bool isMobile) {
    final unidadStock = widget.esPesado ? 'kg' : 'unid';

    final fields = <Widget>[
      PersonaTextField(
        controller: widget.precioController,
        label: 'Precio (\$) *',
        icon: Icons.attach_money_rounded,
        accentColor: cs.primary,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requerido';
          final val = double.tryParse(v.replaceAll(',', '.'));
          if (val == null || val < 0) return 'Precio inválido';
          return null;
        },
      ),
      PersonaTextField(
        controller: widget.stockController,
        label: 'Stock inicial ($unidadStock) *',
        icon: Icons.inventory_2_outlined,
        accentColor: cs.primary,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requerido';
          final val = double.tryParse(v.replaceAll(',', '.'));
          if (val == null || val < 0) return 'Stock inválido';
          return null;
        },
      ),
      PersonaTextField(
        controller: widget.stockMinController,
        label: 'Stock mínimo *',
        icon: Icons.warning_amber_rounded,
        accentColor: cs.primary,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requerido';
          final val = double.tryParse(v.replaceAll(',', '.'));
          if (val == null || val < 0) return 'Stock mínimo inválido';
          return null;
        },
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          fields[0],
          const SizedBox(height: 12),
          fields[1],
          const SizedBox(height: 12),
          fields[2],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: fields[0]),
        const SizedBox(width: 12),
        Expanded(child: fields[1]),
        const SizedBox(width: 12),
        Expanded(child: fields[2]),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // VENTA AL MAYOR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildWholesaleSection(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorMayor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _colorMayor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWholesaleToggle(cs),
          if (widget.permiteVentaMayor) ...[
            const SizedBox(height: 16),
            Divider(color: _colorMayor.withValues(alpha: 0.2)),
            const SizedBox(height: 8),
            _buildWholesaleFields(cs),
            const SizedBox(height: 10),
            _buildWholesaleInfo(cs),
          ],
        ],
      ),
    );
  }

  Widget _buildWholesaleToggle(ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _colorMayor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.warehouse_rounded,
              size: 18, color: _colorMayor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Venta al mayor',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _colorMayor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Habilita precios B2B para este producto',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Switch(
          value: widget.permiteVentaMayor,
          onChanged: widget.onPermiteVentaMayorChanged,
          activeThumbColor: _colorMayor,
        ),
      ],
    );
  }

  Widget _buildWholesaleFields(ColorScheme cs) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _campoMayor(
                controller: widget.precioMayorController,
                label: 'Precio mayor (\$) *',
                icon: Icons.workspace_premium_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                helper: 'Precio por unidad al mayor',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campoMayor(
                controller: widget.cantidadMinimaMayorController,
                label: 'Cant. mínima *',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                helper: 'Ej: 6 unidades',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _campoMayor(
                controller: widget.precioMedioMayorController,
                label: 'Precio medio mayor (\$)',
                icon: Icons.trending_up_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                helper: 'Opcional',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campoMayor(
                controller: widget.cantidadMinimaMedioMayorController,
                label: 'Cant. mínima medio',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                helper: 'Opcional',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _campoMayor(
                controller: widget.unidadesPorBultoController,
                label: 'Unidades por bulto',
                icon: Icons.inventory_2_rounded,
                keyboardType: TextInputType.number,
                helper: 'Ej: 12',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campoMayor(
                controller: widget.costoUnitarioController,
                label: 'Costo promedio (\$)',
                icon: Icons.attach_money_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                helper: 'Para alertas de margen',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _campoMayor({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? helper,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: cs.onSurface, fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
        helperText: helper,
        helperStyle:
            TextStyle(color: cs.onSurfaceVariant, fontSize: 10, height: 1.2),
        prefixIcon: Icon(icon, color: _colorMayor, size: 18),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _colorMayor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }

  Widget _buildWholesaleInfo(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _colorMayor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: _colorMayor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Los niveles de precio se aplican según la cantidad que el '
              'cliente compre. Si no configuras alguno, se usará el '
              'precio de detal.',
              style: TextStyle(
                fontSize: 10.5,
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// AUTOCOMPLETE DE MARCA (widget auxiliar)
// ═══════════════════════════════════════════════════════════════════════

class _MarcaAutocomplete extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final MarcaEntity? seleccionada;
  final ValueChanged<MarcaEntity?> onChanged;
  final Color accentColor;

  const _MarcaAutocomplete({
    required this.controller,
    required this.seleccionada,
    required this.onChanged,
    required this.accentColor,
  });

  @override
  ConsumerState<_MarcaAutocomplete> createState() =>
      _MarcaAutocompleteState();
}

class _MarcaAutocompleteState extends ConsumerState<_MarcaAutocomplete> {
  late Future<List<MarcaEntity>> _marcasFuture;

  @override
  void initState() {
    super.initState();
    _marcasFuture = _cargarMarcas();
  }

  Future<List<MarcaEntity>> _cargarMarcas() async {
    // Ajusta este import a tu IsarService o provider real.
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final marcas = _marcasFuture;

    return FutureBuilder<List<MarcaEntity>>(
      future: marcas,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final lista = snapshot.data ?? const <MarcaEntity>[];
        if (lista.isEmpty) {
          return Text(
            'No hay marcas disponibles.',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          );
        }

        return Autocomplete<MarcaEntity>(
          optionsBuilder: (value) {
            if (value.text.isEmpty) return lista;
            final q = value.text.toLowerCase();
            return lista.where((m) =>
                m.nombre.toLowerCase().contains(q) ||
                (m.descripcion ?? '').toLowerCase().contains(q));
          },
          displayStringForOption: (m) => m.nombre,
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: cs.onSurface),
              decoration: buildInputDecoration(
                label: 'Marca (opcional)',
                icon: Icons.branding_watermark_outlined,
                accentColor: widget.accentColor,
                colorScheme: cs,
              ),
              onChanged: (value) {
                if (widget.seleccionada != null &&
                    widget.seleccionada!.nombre != value) {
                  widget.onChanged(null);
                }
              },
            );
          },
          onSelected: (m) {
            widget.onChanged(m);
            widget.controller.text = m.nombre;
          },
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: cs.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200, minWidth: 280),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final opt = options.elementAt(i);
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.branding_watermark_rounded,
                          color: widget.accentColor, size: 20),
                      title: Text(opt.nombre),
                      subtitle: (opt.descripcion ?? '').isEmpty
                          ? null
                          : Text(opt.descripcion!,
                              style: const TextStyle(fontSize: 12)),
                      onTap: () => onSelected(opt),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}