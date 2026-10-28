// lib/features/pos/presentation/widgets/product/product_data_tab.dart
import 'dart:io';
import 'package:app_boosti_v2/features/pos/presentation/providers/marca_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/persona_form_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

import '../../../data/Local/entities/categoria_entity.dart';
import '../../../data/Local/entities/marca_entity.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/receta_entity.dart';
import '../../providers/business_mode_provider.dart';
import '../../providers/categorias_provider.dart';
import '../../utils/responsive_helper.dart';
import '../common/active_toggle.dart';
import '../common/departamento_selector.dart';
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

  /// Motivo de la reposición. Solo tiene sentido cuando el stock **sube**:
  /// bajar stock no necesita justificación.
  ///
  /// El campo se oculta cuando no hay delta positivo (ver `_deltaPositivo`).
  final TextEditingController motivoController;

  /// Stock actual del producto, tal como está en Isar.
  ///
  /// Se pasa aparte porque [stockController] arranca con el valor formateado
  /// del stock (`p.stock.toStringAsFixed(0)`, redondeado), y el delta tiene
  /// que compararse contra el valor real, no contra el redondeado.
  final double stockActual;

  // ── State ──
  final bool esPesado;
  final bool activo;
  final bool permiteVentaMayor;
  final bool generandoCodigo;
  final bool subiendoImagen;
  final int? categoriaIdSeleccionada;
  final String categoriaSeleccionada;

  /// R.3.2 · Estación de preparación (KDS). `null` = venta directa.
  final int? departamentoIdSeleccionado;
  final MarcaEntity? marcaSeleccionada;
  final String imagenUrlPreview;
  final XFile? imagenSeleccionada;

  // ── Callbacks ──
  final ValueChanged<bool> onEsPesadoChanged;
  final ValueChanged<bool> onActivoChanged;
  final ValueChanged<bool> onPermiteVentaMayorChanged;
  final ValueChanged<MarcaEntity?> onMarcaChanged;
  final ValueChanged<CategoriaEntity?> onCategoriaChanged;

  /// R.3.2 · Cambio de estación de preparación.
  final ValueChanged<int?>? onDepartamentoChanged;
  final VoidCallback onGenerarCodigo;
  final VoidCallback onEscanear;
  final ValueChanged<ImageSource> onPickImage;
  final VoidCallback onClearImage;

  // ── G.2 · Presentación: ingrediente y unidad ──

  /// El producto actúa como ingrediente de recetas de otros productos.
  ///
  /// Llega aplanado a `bool` desde el padre, aunque en `ProductoEntity` sea
  /// `bool?`. Ver la nota del campo `_esIngredienteSel` en
  /// `product_form_dialog.dart`.
  final bool esIngredienteSeleccionado;
  final ValueChanged<bool> onEsIngredienteChanged;

  /// Unidad base de medida en recetas: 'kg' | 'g' | 'lt' | 'ml' | 'unidad'.
  ///
  /// NO es lo mismo que [esPesado]: ese es "se vende a granel al cliente",
  /// este es "en qué se mide dentro de una receta".
  final String unidadSeleccionada;
  final ValueChanged<String> onUnidadChanged;

  // ── G.2 · Receta ──

  /// Ingredientes de la receta en edición.
  ///
  /// ⚠️ Es la MISMA lista que el padre guarda, no una copia: el padre la
  /// reemplaza entera con [onRecetaChanged]. Por eso los items de aquí se
  /// tratan como inmutables (no se mutan, se quita la referencia y se pasa
  /// una lista nueva).
  final List<RecetaItemEntity> itemsReceta;

  final ValueChanged<List<RecetaItemEntity>> onRecetaChanged;

  /// Productos marcados como `esIngrediente == true`.
  ///
  /// ⚠️ Los trae el padre de `IsarService.obtenerIngredientes(localId)`, y
  /// ese método **no filtra por local**: `ProductoEntity` no tiene
  /// `localId`, así que la lista incluye ingredientes de todas las
  /// sucursales. Se acepta en G.2 (un ingrediente "Arroz" es el mismo
  /// arroz en cualquier local) y está anotado en `docs/TODO.md`.
  final List<ProductoEntity> ingredientesDisponibles;

  /// `true` mientras se lee la lista de ingredientes. Permite pintar un
  /// spinner en vez de un empty state que parece "no hay ingredientes".
  final bool cargandoIngredientes;

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
    required this.motivoController,
    required this.stockActual,
    required this.esPesado,
    required this.activo,
    required this.permiteVentaMayor,
    required this.generandoCodigo,
    required this.subiendoImagen,
    required this.categoriaIdSeleccionada,
    required this.categoriaSeleccionada,
    required this.departamentoIdSeleccionado,
    this.onDepartamentoChanged,
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
    required this.esIngredienteSeleccionado,
    required this.onEsIngredienteChanged,
    required this.unidadSeleccionada,
    required this.onUnidadChanged,
    required this.itemsReceta,
    required this.onRecetaChanged,
    required this.ingredientesDisponibles,
    required this.cargandoIngredientes,
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
    // El campo "Motivo de la reposición" solo aparece cuando el stock tipeado
    // supera al actual, así que hay que reevaluar en cada tecla del campo de
    // stock. `TextEditingController` no notifica solo.
    widget.stockController.addListener(_onStockChanged);
  }

  void _onStockChanged() => setState(() {});

  @override
  void didUpdateWidget(covariant ProductDataTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el padre cambia el controller (no debería, pero el contrato lo pide),
    // el listener viejo se queda escuchando el viejo.
    if (!identical(oldWidget.stockController, widget.stockController)) {
      oldWidget.stockController.removeListener(_onStockChanged);
      widget.stockController.addListener(_onStockChanged);
    }
  }

  @override
  void dispose() {
    widget.stockController.removeListener(_onStockChanged);
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
              const SizedBox(height: 14),
              // R.3.2 · Estación de preparación.
              //
              // Va pegado a la categoría porque las dos cosas responden a la
              // misma pregunta: "¿cómo clasifico este plato?". Si el producto
              // no tiene estación, en el POS se cobra directo y nunca llega al
              // KDS (Paso E).
              DepartamentoSelector(
                value: widget.departamentoIdSeleccionado,
                onChanged: widget.onDepartamentoChanged,
                label: 'Estación de preparación',
              ),
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
              const SizedBox(height: 12),
              // ── G.2 · Ingrediente ──
              ActiveToggle(
                value: widget.esIngredienteSeleccionado,
                onChanged: widget.onEsIngredienteChanged,
                activeLabel: 'Es ingrediente',
                inactiveLabel: 'No es ingrediente',
                activeSubtitle: 'Se usa en las recetas de otros productos',
                inactiveSubtitle: 'Se vende solo, no como ingrediente',
              ),
              const SizedBox(height: 14),
              _buildUnidadField(cs),
            ],
          ),
          const SizedBox(height: 22),

          // G.2 · Receta. Va entre "Presentación" y la imagen porque
          // responde a la misma pregunta que `esIngrediente` y `unidad`:
          // "cómo se compone esto por dentro".
          _buildSeccionReceta(cs),
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
  // G.2 · UNIDAD DE MEDIDA
  // ═══════════════════════════════════════════════════════════════

  /// Unidades ofrecidas en recetas.
  ///
  /// ⚠️ Lista FIJA, no enum: el campo en BD es `String` libre (misma
  /// decisión que `DetalleVentaEntity.unidadEmpaque`), así que añadir una
  /// unidad nueva es una línea aquí y ninguna migración. El riesgo es que
  /// alguien escriba otra a mano desde Supabase y el dropdown muestre un
  /// `value` que no está en `items`: por eso el `initialValue` se valida
  /// contra la lista antes de pasarse.
  static const _unidades = <String>['kg', 'g', 'lt', 'ml', 'unidad'];

  /// Etiqueta legible de cada unidad. El código interno sigue siendo el
  /// que va a la BD.
  static const _etiquetasUnidad = <String, String>{
    'kg': 'Kilogramo (kg)',
    'g': 'Gramo (g)',
    'lt': 'Litro (lt)',
    'ml': 'Mililitro (ml)',
    'unidad': 'Unidad',
  };

  Widget _buildUnidadField(ColorScheme cs) {
    // Si la BD trae una unidad que no está en la lista (dato escrito a mano,
    // o de una versión futura de la app), se cae a 'unidad' en vez de
    // dejar el dropdown con un valor inexistente, que lanzaría al abrir.
    final valor = _unidades.contains(widget.unidadSeleccionada)
        ? widget.unidadSeleccionada
        : 'unidad';

    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      decoration: buildInputDecoration(
        label: 'Unidad base (recetas)',
        icon: Icons.straighten_rounded,
        accentColor: cs.primary,
        colorScheme: cs,
      ).copyWith(
        // ⚠️ Va por `copyWith` y no como argumento: `buildInputDecoration`
        // es una función compartida por todo el form y su firma
        // (`persona_form_template.dart:419`) no admite `helperText`.
        // Añadirlo ahí obligaría a tocar un helper que usan 2 sitios más.
        helperText: 'No es lo mismo que "producto pesado": eso define '
            'cómo se vende, esto cómo se mide al descontar ingredientes.',
        helperMaxLines: 2,
        helperStyle: TextStyle(
          fontSize: 10.5,
          color: cs.onSurfaceVariant,
        ),
      ),
      hint: const Text('Unidad'),
      items: [
        for (final u in _unidades)
          DropdownMenuItem<String>(
            value: u,
            child: Text(_etiquetasUnidad[u] ?? u),
          ),
      ],
      onChanged: (v) {
        if (v == null) return;
        widget.onUnidadChanged(v);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // G.2 · RECETA
  // ═══════════════════════════════════════════════════════════════

  /// Sección completa de receta: contador, lista y botón de agregar.
  ///
  /// ⚠️ Visible SIEMPRE, sin gate por `esIngrediente`: un producto puede
  /// no ser ingrediente (no se consume en otras recetas) y aun así tener
  /// receta propia (la pizza usa arroz y no es ingrediente de nada). El
  /// empty state explica esa diferencia.
  Widget _buildSeccionReceta(ColorScheme cs) {
    // TODO:891 · Resuelto: en retail (y en servicios) el producto es una
    // unidad completa y la sección no se pinta. El gate es de MODO
    // (`mostrarRecetas`), no de plan: contratar o no la feature por plan
    // queda para cuando exista la clave en `planes.features`.
    if (!ref.watch(featureFlagsProvider).mostrarRecetas) {
      return const SizedBox.shrink();
    }
    final items = widget.itemsReceta;

    final obligatorios = items.where((i) => !i.esOpcional).length;
    final opcionales = items.where((i) => i.esOpcional).length;

    return FormSection(
      title: 'Receta',
      icon: Icons.menu_book_rounded,
      accentColor: cs.primary,
      children: [
        if (items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _contadorReceta(obligatorios, opcionales),
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            _buildRecetaItem(items[i], cs),
            if (i < items.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
        ] else
          _buildRecetaEmptyState(cs),
        const SizedBox(height: 10),
        _buildBotonAgregarIngrediente(),
      ],
    );
  }

  /// "2 obligatorios · 1 opcional". Las partes a 0 se omiten: "3
  /// obligatorios · 0 opcionales" suena a que existe un tipo de ingrediente
  /// opcional con cero elementos.
  String _contadorReceta(int obligatorios, int opcionales) {
    final partes = <String>[];

    if (obligatorios > 0) {
      partes.add('$obligatorios obligatorio${obligatorios == 1 ? '' : 's'}');
    }
    if (opcionales > 0) {
      partes.add('$opcionales opcional${opcionales == 1 ? '' : 'es'}');
    }

    if (partes.isEmpty) return 'Sin ingredientes';
    if (partes.length == 1) return partes.first;

    return '${partes.first} · ${partes[1]}';
  }

  Widget _buildRecetaEmptyState(ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Este producto no tiene receta definida',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Añade los ingredientes que se descuentan del inventario al '
            'servir este plato. Que este producto sea "ingrediente" de '
            'otros es otra cosa distinta.',
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecetaItem(RecetaItemEntity item, ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unidad = _etiquetasUnidad[item.unidad] ?? item.unidad;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.ingredienteNombre,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.esOpcional) ...[
                      const SizedBox(width: 8),
                      _chipOpcional(cs),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  // "1 Kilogramo (kg)" se lee mejor que "1.0 Kilogramo".
                  item.cantidad == 1.0
                      ? '1 $unidad'
                      : '${item.cantidad} $unidad',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('quitar-ingrediente-${item.ingredienteId}'),
            tooltip: 'Quitar de la receta',
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: cs.error,
            onPressed: () => _confirmarEliminarIngrediente(item),
          ),
        ],
      ),
    );
  }

  Widget _chipOpcional(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _colorMayor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Opcional',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: _colorMayor,
        ),
      ),
    );
  }

  Widget _buildBotonAgregarIngrediente() {
    final cargando = widget.cargandoIngredientes;
    final vacio =
        !cargando && widget.ingredientesDisponibles.isEmpty;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('btn-agregar-ingrediente'),
        onPressed: (cargando || vacio) ? null : () => _agregarIngrediente(),
        icon: cargando
            ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_rounded, size: 18),
        label: Text(
          widget.itemsReceta.isEmpty
              ? 'Añadir primer ingrediente'
              : 'Agregar ingrediente',
        ),
      ),
    );
  }

  /// Pide confirmación y quita el ingrediente.
  ///
  /// ⚠️ El `AlertDialog` (y no el `_mostrarDialogoSimple` del padre) es
  /// deliberado: aquel es un aviso informativo con Lottie y un solo botón
  /// de OK; esto es una pregunta de sí-o-no, y un Lottie de "te informo"
  /// no comunica lo mismo. Mismo criterio que `comanda_screen._cancelar`.
  ///
  /// ⚠️ La comparación es por IDENTIDAD con `identical`, no por `==`.
  /// `RecetaItemEntity` no sobrescribe `==`, así que ambos son equivalentes
  /// hoy, pero `identical` dice explícitamente lo que se quiere: quitar
  /// ESTA instancia. Si algún día la entidad gana un `==` por nombre, el
  /// `==` empezaría a borrar dos ingredientes con el mismo nombre.
  Future<void> _confirmarEliminarIngrediente(RecetaItemEntity item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('¿Quitar ${item.ingredienteNombre}?'),
        content: const Text(
          'Se eliminará este ingrediente de la receta. '
          'La acción no se puede deshacer.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    widget.onRecetaChanged(
      widget.itemsReceta.where((i) => !identical(i, item)).toList(),
    );
  }

  Future<void> _agregarIngrediente() async {
    final nuevo = await _mostrarDialogoIngrediente();
    if (nuevo == null) return;
    if (!mounted) return;

    // Defensa extra: el diálogo ya avisa de los repetidos, pero si otro
    // caller usara `_agregarIngrediente` no quiero una receta con el mismo
    // ingrediente dos veces.
    final repetido = widget.itemsReceta
        .any((i) => i.ingredienteId == nuevo.ingredienteId);
    if (repetido) return;

    widget.onRecetaChanged([...widget.itemsReceta, nuevo]);
  }

  /// Diálogo de alta. Devuelve `null` si se cancela o si no hay
  /// ingredientes que ofrecer.
  Future<RecetaItemEntity?> _mostrarDialogoIngrediente() async {
    if (widget.ingredientesDisponibles.isEmpty) return null;

    return showDialog<RecetaItemEntity>(
      context: context,
      builder: (ctx) => _EstadoDialogoIngrediente(
        disponibles: widget.ingredientesDisponibles,
        yaUsados: widget.itemsReceta.map((i) => i.ingredienteId).toSet(),
        unidades: _unidades,
        etiquetas: _etiquetasUnidad,
      ),
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
          if (_deltaPositivo) ...[
            const SizedBox(height: 12),
            _buildMotivoField(cs),
          ],
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 12),
            Expanded(child: fields[1]),
            const SizedBox(width: 12),
            Expanded(child: fields[2]),
          ],
        ),
        if (_deltaPositivo) ...[
          const SizedBox(height: 12),
          _buildMotivoField(cs),
        ],
      ],
    );
  }

  /// `true` cuando el stock tipeado supera al stock actual del producto.
  ///
  /// Solo en ese caso tiene sentido pedir un motivo: bajar stock no necesita
  /// justificación, y el descuento ya deja su rastro en los lotes.
  bool get _deltaPositivo {
    final tipeado =
        double.tryParse(widget.stockController.text.replaceAll(',', '.')) ??
            0.0;
    return tipeado - widget.stockActual > 0.0001;
  }

  Widget _buildMotivoField(ColorScheme cs) {
    return PersonaTextField(
      controller: widget.motivoController,
      label: 'Motivo de la reposición (opcional)',
      icon: Icons.edit_note_outlined,
      accentColor: cs.primary,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 2,
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
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 🎯 FIX CRÍTICO: leer del provider reactivo en vez de un Future
    //    hardcodeado con `const []`. El StreamProvider refresca solo
    //    cuando Isar cambia, así que el dropdown ve marcas nuevas al
    //    instante sin reiniciar la app.
    final marcasAsync = ref.watch(marcasProvider);

    return marcasAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (err, stack) => Text(
        'Error al cargar marcas: $err',
        style: TextStyle(fontSize: 13, color: cs.error),
      ),
      data: (lista) {
        if (lista.isEmpty) {
          return Text(
            'No hay marcas disponibles.',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          );
        }

        return Autocomplete<MarcaEntity>(
          initialValue: TextEditingValue(
            text: widget.seleccionada?.nombre ?? '',
          ),
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
                constraints:
                    const BoxConstraints(maxHeight: 200, minWidth: 280),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final opt = options.elementAt(i);
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.branding_watermark_rounded,
                        color: widget.accentColor,
                        size: 20,
                      ),
                      title: Text(opt.nombre),
                      subtitle: (opt.descripcion ?? '').isEmpty
                          ? null
                          : Text(
                              opt.descripcion!,
                              style: const TextStyle(fontSize: 12),
                            ),
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
// ══════════════════════════════════════════════════════════════════
// G.2 · DIÁLOGO DE ALTA DE INGREDIENTE
// ══════════════════════════════════════════════════════════════════

/// Diálogo de "añadir ingrediente a la receta".
///
/// ⚠️ Es un `StatefulWidget` y no un `AlertDialog` con variables locales
/// por una razón concreta: los `TextEditingController` de la cantidad
/// tienen que sobrevivir a los rebuilds. Cambiar la unidad del dropdown
/// provoca un `setState`, y con estado local la cantidad escrita se
/// perdería a media escritura.
///
/// Devuelve el `RecetaItemEntity` listo para appendear, o `null` si se
/// cancela. Nunca lanza por datos inválidos: los muestra y deja corregir.
class _EstadoDialogoIngrediente extends StatefulWidget {
  final List<ProductoEntity> disponibles;
  final Set<int> yaUsados;
  final List<String> unidades;
  final Map<String, String> etiquetas;

  const _EstadoDialogoIngrediente({
    required this.disponibles,
    required this.yaUsados,
    required this.unidades,
    required this.etiquetas,
  });

  @override
  State<_EstadoDialogoIngrediente> createState() =>
      _EstadoDialogoIngredienteState();
}

class _EstadoDialogoIngredienteState
    extends State<_EstadoDialogoIngrediente> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController(text: '1');
  final _buscarCtrl = TextEditingController();

  ProductoEntity? _seleccionado;
  String _unidad = 'unidad';
  bool _opcional = false;

  /// Texto del buscador. Se guarda aparte del controller para poder
  /// filtrar en el `build` sin escuchar al controller.
  String _busqueda = '';

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _buscarCtrl.dispose();
    super.dispose();
  }

  /// Ingredientes que aún no están en la receta.
  ///
  /// Se filtran en la UI en vez de solo deshabilitarlos: con 40
  /// ingredientes ya usados, una lista de 100 con 60 en gris es más difícil
  /// de leer que una lista de 40. Los usados siguen apareciendo en la
  /// sección de arriba, así que no se pierde información.
  List<ProductoEntity> get _disponibles =>
      widget.disponibles.where((p) => !widget.yaUsados.contains(p.id)).toList();

  /// Lista ya filtrada por el buscador.
  ///
  /// Busca en nombre, categoría y código de barras. Un restaurante con 100
  /// ingredientes no se recorre con el ojo: se escribe "queso" y listo.
  List<ProductoEntity> get _filtrados {
    final q = _normalizar(_busqueda.trim());
    if (q.isEmpty) return _disponibles;
    return _disponibles.where((p) {
      return _normalizar(p.nombre).contains(q) ||
          _normalizar(p.categoria).contains(q) ||
          p.codigoBarras.toLowerCase().contains(q);
    }).toList();
  }

  /// Minúsculas y sin tildes, para que "cesar" encuentre "Ensalada César"
  /// y "arroz" encuentre "Arroz".
  ///
  /// Es local y no un helper compartido a propósito: el proyecto no tiene
  /// un normalizador común y esto es lo único que lo necesita.
  String _normalizar(String texto) {
    const conTilde = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const sinTilde = 'aaaaaeeeeiiiiooooouuuunc';
    final buffer = StringBuffer();
    for (final rune in texto.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      final i = conTilde.indexOf(ch);
      buffer.write(i >= 0 ? sinTilde[i] : ch);
    }
    return buffer.toString();
  }

  /// Selecciona un ingrediente y arrastra su unidad base a la receta.
  ///
  /// Si el producto se mide en gramos (`ProductoEntity.unidad == 'g'`),
  /// pedir la cantidad en "unidad" obligaría a convertir a mano. El
  /// usuario puede cambiarla después en el desplegable.
  void _seleccionar(ProductoEntity producto) {
    setState(() {
      _seleccionado = producto;
      if (widget.unidades.contains(producto.unidad)) {
        _unidad = producto.unidad;
      }
    });
  }

  void _agregar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final producto = _seleccionado;
    if (producto == null) return;

    Navigator.of(context).pop(
      RecetaItemEntity()
        ..ingredienteId = producto.id
        ..ingredienteNombre = producto.nombre
        ..cantidad = double.tryParse(_cantidadCtrl.text.trim()) ?? 0.0
        ..unidad = _unidad
        ..esOpcional = _opcional,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disponibles = _disponibles;
    final filtrados = _filtrados;

    // Tamaño: en escritorio el diálogo es amplio porque la lista puede
    // tener decenas de ingredientes; en móvil ocupa el ancho disponible.
    final media = MediaQuery.sizeOf(context);
    final ancho = (media.width - 48).clamp(300.0, 560.0);
    final altoLista = (media.height * 0.42).clamp(140.0, 380.0);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      // En pantallas bajas el contenido scrollea en vez de desbordar.
      scrollable: true,
      title: Row(
        children: [
          Icon(Icons.restaurant_menu_rounded, color: cs.primary, size: 24),
          const SizedBox(width: 10),
          const Expanded(child: Text('Agregar ingrediente')),
        ],
      ),
      content: SizedBox(
        width: ancho,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (disponibles.isEmpty)
                _sinIngredientes(cs)
              else ...[
                TextField(
                  controller: _buscarCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _busqueda = v),
                  decoration: buildInputDecoration(
                    label: 'Buscar ingrediente',
                    icon: Icons.search_rounded,
                    accentColor: cs.primary,
                    colorScheme: cs,
                  ).copyWith(
                    hintText: 'Nombre, categoría o código',
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _buscarCtrl.clear();
                              setState(() => _busqueda = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    _busqueda.trim().isEmpty
                        ? '${disponibles.length} ingrediente(s) disponible(s)'
                        : '${filtrados.length} de ${disponibles.length} '
                            'ingrediente(s)',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 140,
                    maxHeight: altoLista,
                  ),
                  child: _listaIngredientes(filtrados, cs, isDark),
                ),
                if (_seleccionado != null) ...[
                  const SizedBox(height: 12),
                  _panelCantidad(cs),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (disponibles.isNotEmpty)
          FilledButton(
            key: const Key('btn-confirmar-ingrediente'),
            // Deshabilitado hasta elegir: antes el botón vivía y el
            // formulario escupía "Selecciona un ingrediente" al pulsar.
            onPressed: _seleccionado == null ? null : _agregar,
            child: const Text('Agregar'),
          ),
      ],
    );
  }

  /// Estado vacío: no hay ingredientes que ofrecer.
  Widget _sinIngredientes(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.no_food_outlined,
            size: 40,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            widget.yaUsados.isEmpty
                ? 'No hay ingredientes configurados. Marca productos como '
                    '"Es ingrediente" para usarlos aquí.'
                : 'Todos los ingredientes disponibles ya están en esta '
                    'receta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Lista con scroll propio de los ingredientes que pasan el filtro.
  Widget _listaIngredientes(
    List<ProductoEntity> items,
    ColorScheme cs,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Ningún ingrediente coincide con «$_busqueda».',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Scrollbar(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: items.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withValues(alpha: 0.35),
          ),
          itemBuilder: (_, i) => _filaIngrediente(items[i], cs),
        ),
      ),
    );
  }

  Widget _filaIngrediente(ProductoEntity p, ColorScheme cs) {
    final activo = _seleccionado?.id == p.id;
    final stock = p.stock % 1 == 0
        ? p.stock.toStringAsFixed(0)
        : p.stock.toStringAsFixed(2);

    return InkWell(
      onTap: () => _seleccionar(p),
      child: Container(
        color: activo ? cs.primary.withValues(alpha: 0.10) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(
              activo ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: activo ? cs.primary : cs.outlineVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${p.categoria} · stock $stock ${_unidadCorta(p.unidad)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cantidad, unidad y opcional del ingrediente ya elegido.
  ///
  /// Se pinta en un bloque con fondo para que no se confunda con los
  /// campos de arriba: arriba se filtra, abajo se guarda.
  Widget _panelCantidad(ColorScheme cs) {
    final producto = _seleccionado!;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_rounded, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  producto.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _cantidadCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: buildInputDecoration(
                    label: 'Cantidad por porción *',
                    icon: Icons.numbers_rounded,
                    accentColor: cs.primary,
                    colorScheme: cs,
                  ),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim());
                    if (n == null) return 'Escribe un número';
                    if (n <= 0) return 'Debe ser mayor que 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  // La key re-sincroniza el campo cuando la unidad cambia
                  // por código al elegir el ingrediente.
                  key: ValueKey('unidad-receta-$_unidad'),
                  initialValue:
                      widget.unidades.contains(_unidad) ? _unidad : 'unidad',
                  isExpanded: true,
                  decoration: buildInputDecoration(
                    label: 'Unidad',
                    icon: Icons.straighten_rounded,
                    accentColor: cs.primary,
                    colorScheme: cs,
                  ),
                  items: [
                    for (final u in widget.unidades)
                      DropdownMenuItem<String>(
                        value: u,
                        child: Text(
                          widget.etiquetas[u] ?? u,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _unidad = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Switch(
                value: _opcional,
                onChanged: (v) => setState(() => _opcional = v),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _opcional
                      ? 'Opcional · si falta, se avisa pero no bloquea la '
                          'entrega'
                      : 'Obligatorio · si falta, se avisa al entregar el '
                          'plato',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Abreviatura de la unidad para la línea de stock.
  ///
  /// `widget.etiquetas` devuelve "Gramo (g)", que en una fila de 11 px
  /// ocupa media línea. Aquí importa el código, no el nombre largo.
  String _unidadCorta(String unidad) => switch (unidad) {
        'kg' => 'kg',
        'g' => 'g',
        'lt' => 'lt',
        'ml' => 'ml',
        _ => 'u',
      };
}
