// features/pos/presentation/widgets/cobrar_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bcv_provider.dart';
import '../providers/clientes/clientes_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/input_decoration_helper.dart';
import 'clientes/cliente_form_dialog.dart';

class CobrarDialog extends ConsumerStatefulWidget {
  final double totalAPagar;
  final List<Map<String, dynamic>> productos;

  const CobrarDialog({
    super.key,
    required this.totalAPagar,
    required this.productos,
  });

  @override
  ConsumerState<CobrarDialog> createState() => _CobrarDialogState();
}

class _CobrarDialogState extends ConsumerState<CobrarDialog> {
  // ===== Tabs principales =====
  int _mainTabIndex = 0; // 0 = Método de pago, 1 = Cliente
  int? _hoveredMainTab;

  // ===== Método de pago =====
  int _metodoIndex = 0;
  int? _hoveredMetodo;

  // ===== Moneda / tasa =====
  String _monedaSeleccionada = 'USD';
  bool _tasaExpandida = false;
  String? _hoveredMoneda; // ← hover de chips de moneda

  // ===== Controladores =====
  final _efectivoUsdController = TextEditingController();
  final _efectivoBsController = TextEditingController();
  final _pagoMovilBsController = TextEditingController();
  final _puntoBsController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _tasaManualController = TextEditingController();

  // ===== Focus =====
  final _efectivoUsdFocus = FocusNode();

  // ===== Cliente =====
  ClienteEntity? _clienteSeleccionado;
  final _clienteSearchController = TextEditingController();
  final _clienteFocus = FocusNode();

  // ===== Colores =====
  static const Color _colorEfectivo = Color(0xFF10B981);
  static const Color _colorPagoMovil = Color(0xFF3B82F6);
  static const Color _colorPunto = Color(0xFF8B5CF6);
  static const Color _colorCliente = Color(0xFF8B5CF6);
  static const Color _colorVuelto = Color(0xFFF59E0B); // Ámbar para vuelto

  // Altura estándar de botones principales
  static const double _buttonHeight = 56;

  // Epsilon para comparaciones de montos
  static const double _eps = 0.01;

  Color get _colorMetodo {
    switch (_metodoIndex) {
      case 0:
        return _colorEfectivo;
      case 1:
        return _colorPagoMovil;
      case 2:
        return _colorPunto;
      default:
        return _colorEfectivo;
    }
  }

  String get _metodoPagoSeleccionado {
    switch (_metodoIndex) {
      case 0:
        return 'Efectivo';
      case 1:
        return 'Pago Móvil';
      case 2:
        return 'Punto de Venta';
      default:
        return 'Efectivo';
    }
  }

  @override
  void initState() {
    super.initState();
    _efectivoUsdController.text = widget.totalAPagar.toStringAsFixed(2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _efectivoUsdFocus.requestFocus();
      _efectivoUsdController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _efectivoUsdController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _efectivoUsdController.dispose();
    _efectivoBsController.dispose();
    _pagoMovilBsController.dispose();
    _puntoBsController.dispose();
    _referenciaController.dispose();
    _tasaManualController.dispose();
    _clienteSearchController.dispose();
    _clienteFocus.dispose();
    _efectivoUsdFocus.dispose();
    super.dispose();
  }

  void _limpiarCamposMetodos() {
    _efectivoUsdController.clear();
    _efectivoBsController.clear();
    _pagoMovilBsController.clear();
    _puntoBsController.clear();
  }

  void _cambiarMetodo(int index) {
    if (index == _metodoIndex) return;
    setState(() {
      _metodoIndex = index;
      _limpiarCamposMetodos();
    });
  }

  // ======================================================
  // Moneda helpers
  // ======================================================
  IconData _iconoMoneda(String moneda) {
    switch (moneda) {
      case 'USD':
        return Icons.attach_money_rounded;
      case 'EUR':
        return Icons.euro_rounded;
      case 'Manual':
        return Icons.tune_rounded;
      default:
        return Icons.currency_exchange_rounded;
    }
  }

  String _labelMoneda(String moneda) {
    switch (moneda) {
      case 'USD':
        return 'Dólar';
      case 'EUR':
        return 'Euro';
      case 'Manual':
        return 'Manual';
      default:
        return moneda;
    }
  }

  double _calcularTasaActiva(Map<String, double> tasas) {
    if (_monedaSeleccionada == 'Manual') {
      final manual = double.tryParse(_tasaManualController.text) ?? 0;
      return manual > 0 ? manual : 1.0;
    }
    final t = tasas[_monedaSeleccionada];
    if (t != null && t > 0) return t;
    return 1.0;
  }

  double _totalRecibidoUsd(double tasa) {
    switch (_metodoIndex) {
      case 0:
        final usd = double.tryParse(_efectivoUsdController.text) ?? 0;
        final bs = double.tryParse(_efectivoBsController.text) ?? 0;
        return usd + (bs / tasa);
      case 1:
        final bs = double.tryParse(_pagoMovilBsController.text) ?? 0;
        return bs / tasa;
      case 2:
        final bs = double.tryParse(_puntoBsController.text) ?? 0;
        return bs / tasa;
      default:
        return 0;
    }
  }

  // ======================================================
  // Botones "Exacto"
  // ======================================================
  void _pagarExactoUsd() {
    setState(() {
      _efectivoUsdController.text = widget.totalAPagar.toStringAsFixed(2);
      _efectivoBsController.clear();
    });
  }

  void _pagarExactoPagoMovil(double tasa) {
    if (tasa <= 0) return;
    setState(() {
      _pagoMovilBsController.text =
          (widget.totalAPagar * tasa).toStringAsFixed(2);
    });
  }

  void _pagarExactoPunto(double tasa) {
    if (tasa <= 0) return;
    setState(() {
      _puntoBsController.text =
          (widget.totalAPagar * tasa).toStringAsFixed(2);
    });
  }

  // ======================================================
  // Confirmar pago
  // ======================================================
  void _confirmarPago(double tasa) {
    final totalRecibido = _totalRecibidoUsd(tasa);
    final diferencia = totalRecibido - widget.totalAPagar;
    final vueltoUsd = diferencia > 0 ? diferencia : 0.0;

    if (totalRecibido < (widget.totalAPagar - _eps)) return;

    final usuario = ref.read(usuarioActualProvider);
    final metodo = _metodoPagoSeleccionado;

    IsarService().guardarLog(
      LogEntity()
        ..accion = 'VENTA_REALIZADA'
        ..usuarioNombre = usuario?.nombre ?? 'Sistema'
        ..usuarioRol = usuario?.rol ?? 'cajero'
        ..detalles =
            'Total: \$${widget.totalAPagar.toStringAsFixed(2)} - Método: $metodo'
        ..fecha = DateTime.now()
        ..sincronizado = false,
    );

    Navigator.of(context).pop({
      'procesado': true,
      'metodoPago': metodo,
      // 🔑 Cliente capturado como objeto completo (o null si no se seleccionó)
      'cliente': _clienteSeleccionado,
      'documento': _clienteSeleccionado?.documento ?? 'V-00000000',
      'montoRecibido': totalRecibido,
      'vuelto': vueltoUsd,
      'referencia': _referenciaController.text.trim().isEmpty
          ? null
          : _referenciaController.text.trim(),
      'tasaUsada': tasa,
      'monedaUsada': _monedaSeleccionada,
    });
  }

  // ======================================================
  // Abrir formulario de cliente
  // ======================================================
 Future<void> _abrirFormularioCliente() async {
    final nuevoCliente = await ClienteFormDialog.mostrar(context);
    if (!mounted) return;

    // Refrescar la lista por si el provider no lo hizo
    await ref.read(clientesProvider.notifier).cargarClientes();
    if (!mounted) return;

    if (nuevoCliente != null) {
      // Buscar la versión actualizada en el provider (por si cambió)
      final lista = ref.read(clientesProvider);
      final actualizado = lista.firstWhere(
        (c) => c.id == nuevoCliente.id,
        orElse: () => nuevoCliente,
      );

      setState(() {
        _clienteSeleccionado = actualizado;
        _clienteSearchController.text = actualizado.nombre;
        _mainTabIndex = 0; // ✅ Volver al tab "Método de pago"
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cliente "${actualizado.nombre}" registrado y asignado',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: _colorCliente,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      // El usuario canceló o no guardó: re-validar la selección actual
      final listaActual = ref.read(clientesProvider);
      if (_clienteSeleccionado != null &&
          !listaActual.any((c) => c.id == _clienteSeleccionado!.id)) {
        setState(() {
          _clienteSeleccionado = null;
          _clienteSearchController.clear();
        });
      }
    }
  }

  // ======================================================
  // BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final tasas = ref.watch(tasasDisponiblesProvider);
    final tasaValida = _calcularTasaActiva(tasas);

    final double totalBs = widget.totalAPagar * tasaValida;
    final double totalRecibido = _totalRecibidoUsd(tasaValida);
    final double diferencia = totalRecibido - widget.totalAPagar;
    final bool pagoCompleto = totalRecibido >= (widget.totalAPagar - _eps);
    final bool esExacto = diferencia.abs() <= _eps;
    final bool hayVuelto = diferencia > _eps;
    final double vueltoUsd = hayVuelto ? diferencia : 0.0;
    final double vueltoBs = vueltoUsd * tasaValida;
    final double faltanteUsd = diferencia < -_eps ? diferencia.abs() : 0.0;
    final double faltanteBs = faltanteUsd * tasaValida;

    final double dialogWidth =
        isMobile ? screen.width * 0.95 : (isTablet ? 640 : 880);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (pagoCompleto) _confirmarPago(tasaValida);
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop(null);
        },
      },
      child: Focus(
        autofocus: true,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 24,
            vertical: isMobile ? 12 : 32,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: screen.height * 0.92,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 24,
                    isMobile ? 16 : 24,
                    isMobile ? 16 : 24,
                    isMobile ? 16 : 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(
                        theme: theme,
                        colorScheme: colorScheme,
                        isMobile: isMobile,
                        colorMetodo: _colorMetodo,
                      ),
                      const SizedBox(height: 14),
                      _buildTasaDisplay(
                        tasas: tasas,
                        isMobile: isMobile,
                        colorScheme: colorScheme,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _buildMainTabs(
                        colorScheme: colorScheme,
                        isDark: isDark,
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.05),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: _mainTabIndex == 0
                            ? KeyedSubtree(
                                key: const ValueKey('tab_metodo'),
                                child: _buildMetodoTab(
                                  tasaValida: tasaValida,
                                  isMobile: isMobile,
                                  isTablet: isTablet,
                                  colorScheme: colorScheme,
                                  isDark: isDark,
                                ),
                              )
                            : KeyedSubtree(
                                key: const ValueKey('tab_cliente'),
                                child: _buildClienteTab(
                                  colorScheme: colorScheme,
                                  isDark: isDark,
                                  isMobile: isMobile,
                                  colorMetodo: _colorCliente,
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      _buildTotalesBanner(
                        colorScheme: colorScheme,
                        isDark: isDark,
                        isMobile: isMobile,
                        totalBs: totalBs,
                      ),
                      const SizedBox(height: 12),
                      // ⬇️ Panel con 3 estados: verde / amarillo / rojo
                      _buildPanelVuelto(
                        colorScheme: colorScheme,
                        isMobile: isMobile,
                        esExacto: esExacto,
                        hayVuelto: hayVuelto,
                        vueltoUsd: vueltoUsd,
                        vueltoBs: vueltoBs,
                        faltanteUsd: faltanteUsd,
                        faltanteBs: faltanteBs,
                      ),
                      const SizedBox(height: 18),
                      _buildBotones(
                        pagoCompleto: pagoCompleto,
                        tasaValida: tasaValida,
                        colorMetodo: _colorMetodo,
                        colorScheme: colorScheme,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // HEADER
  // ======================================================
  Widget _buildHeader({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isMobile,
    required Color colorMetodo,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorMetodo.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: colorMetodo,
            size: isMobile ? 22 : 26,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isMobile ? 'Cobro' : 'Procesar Cobro',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 22,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(null),
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: 'Cerrar',
          ),
        ),
      ],
    );
  }

  // ======================================================
  // TASA DISPLAY (con hover + cursor en el chip grande y en los chips de moneda)
  // ======================================================
  Widget _buildTasaDisplay({
    required Map<String, double> tasas,
    required bool isMobile,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final opciones = <String>[...tasas.keys, 'Manual'];
    if (!opciones.contains(_monedaSeleccionada)) {
      _monedaSeleccionada = opciones.first;
    }
    final labelActual = _labelMoneda(_monedaSeleccionada);
    final iconoActual = _iconoMoneda(_monedaSeleccionada);
    final tasaActual = _calcularTasaActiva(tasas);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _tasaExpandida = !_tasaExpandida),
              hoverColor: colorScheme.primary.withValues(alpha: 0.08),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconoActual,
                        color: colorScheme.primary,
                        size: isMobile ? 18 : 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isMobile
                            ? 'Bs. ${tasaActual.toStringAsFixed(2)}'
                            : '$labelActual · Bs. ${tasaActual.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 13 : 14,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _tasaExpandida ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.primary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          child: _tasaExpandida
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: opciones.map((op) {
                            final sel = _monedaSeleccionada == op;
                            final hovering = _hoveredMoneda == op;
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) =>
                                  setState(() => _hoveredMoneda = op),
                              onExit: (_) =>
                                  setState(() => _hoveredMoneda = null),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _monedaSeleccionada = op;
                                    _limpiarCamposMetodos();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? colorScheme.primary
                                        : (hovering
                                            ? colorScheme.primary
                                                .withValues(alpha: 0.18)
                                            : colorScheme.primaryContainer
                                                .withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: sel
                                          ? colorScheme.primary
                                          : (hovering
                                              ? colorScheme.primary
                                                  .withValues(alpha: 0.6)
                                              : colorScheme.primary
                                                  .withValues(alpha: 0.3)),
                                      width: sel || hovering ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _iconoMoneda(op),
                                        size: 14,
                                        color: sel
                                            ? colorScheme.onPrimary
                                            : colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _labelMoneda(op),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: sel
                                              ? colorScheme.onPrimary
                                              : colorScheme.primary,
                                        ),
                                      ),
                                      if (op != 'Manual' &&
                                          (tasas[op] ?? 0) > 0) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          'Bs. ${(tasas[op] ?? 0).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: sel
                                                ? colorScheme.onPrimary
                                                    .withValues(alpha: 0.85)
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_monedaSeleccionada == 'Manual') ...[
                          const SizedBox(height: 10),
                          _campoMonto(
                            controller: _tasaManualController,
                            label: 'Tasa manual (Bs / \$)',
                            prefixIcon: Icons.tune_rounded,
                            color: colorScheme.primary,
                            colorScheme: colorScheme,
                            isDark: isDark,
                            isMobile: isMobile,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ======================================================
  // TABS PRINCIPALES
  // ======================================================
  Widget _buildMainTabs({
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _tabButton(
            index: 0,
            label: 'Método de pago',
            icon: Icons.payments_outlined,
            color: _colorMetodo,
            colorScheme: colorScheme,
            isMobile: isMobile,
          ),
          _tabButton(
            index: 1,
            label: 'Cliente',
            icon: Icons.person_outline_rounded,
            color: _colorCliente,
            colorScheme: colorScheme,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
    required bool isMobile,
  }) {
    final selected = _mainTabIndex == index;
    final hovering = _hoveredMainTab == index;
    final hoverBg = color.withValues(alpha: 0.12);

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredMainTab = index),
        onExit: (_) => setState(() => _hoveredMainTab = null),
        child: GestureDetector(
          onTap: () => setState(() => _mainTabIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? color
                  : (hovering ? hoverBg : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : (hovering ? color : colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 13,
                      color: selected
                          ? Colors.white
                          : (hovering ? color : colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // TAB: MÉTODO DE PAGO
  // ======================================================
  Widget _buildMetodoTab({
    required double tasaValida,
    required bool isMobile,
    required bool isTablet,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final cards = [
      _MetodoInfo(
        label: 'Efectivo',
        sub: 'Divisas y Bs',
        icon: Icons.payments_rounded,
        color: _colorEfectivo,
      ),
      _MetodoInfo(
        label: 'Pago Móvil',
        sub: 'Transferencia',
        icon: Icons.phone_android_rounded,
        color: _colorPagoMovil,
      ),
      _MetodoInfo(
        label: 'Punto',
        sub: 'Tarjeta',
        icon: Icons.credit_card_rounded,
        color: _colorPunto,
      ),
    ];

    final Widget cardsColumn = isMobile || isTablet
        ? Row(
            children: List.generate(cards.length, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == cards.length - 1 ? 0 : 8,
                  ),
                  child: _buildMetodoCardCompact(
                    index: i,
                    info: cards[i],
                    selected: _metodoIndex == i,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                ),
              );
            }),
          )
        : Column(
            children: List.generate(cards.length, (i) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i == cards.length - 1 ? 0 : 10),
                child: _buildMetodoCardVertical(
                  index: i,
                  info: cards[i],
                  selected: _metodoIndex == i,
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              );
            }),
          );

    final fields = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SizeTransition(
          axisAlignment: -1,
          sizeFactor: anim,
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey('metodo_fields_$_metodoIndex'),
        child: _buildMetodoFields(
          tasaValida: tasaValida,
          isMobile: isMobile,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ),
    );

    if (isMobile || isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cardsColumn,
          const SizedBox(height: 14),
          fields,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 180, child: cardsColumn),
        const SizedBox(width: 16),
        Expanded(child: fields),
      ],
    );
  }

  Widget _buildMetodoCardVertical({
    required int index,
    required _MetodoInfo info,
    required bool selected,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final hovering = _hoveredMetodo == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredMetodo = index),
      onExit: (_) => setState(() => _hoveredMetodo = null),
      child: GestureDetector(
        onTap: () => _cambiarMetodo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? info.color
                : (isDark
                    ? Colors.black.withValues(alpha: hovering ? 0.3 : 0.2)
                    : Colors.black.withValues(alpha: hovering ? 0.06 : 0.03)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? info.color
                  : (hovering
                      ? info.color.withValues(alpha: 0.4)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05))),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: info.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : info.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  info.icon,
                  size: 20,
                  color: selected ? Colors.white : info.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            selected ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      info.sub,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.85)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetodoCardCompact({
    required int index,
    required _MetodoInfo info,
    required bool selected,
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isMobile,
  }) {
    final hovering = _hoveredMetodo == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredMetodo = index),
      onExit: (_) => setState(() => _hoveredMetodo = null),
      child: GestureDetector(
        onTap: () => _cambiarMetodo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 14 : 16,
          ),
          decoration: BoxDecoration(
            color: selected
                ? info.color
                : (isDark
                    ? Colors.black.withValues(alpha: hovering ? 0.3 : 0.2)
                    : Colors.black.withValues(alpha: hovering ? 0.06 : 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? info.color
                  : (hovering
                      ? info.color.withValues(alpha: 0.4)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05))),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: info.color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                info.icon,
                size: isMobile ? 20 : 24,
                color: selected ? Colors.white : info.color,
              ),
              const SizedBox(height: 6),
              Text(
                info.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetodoFields({
    required double tasaValida,
    required bool isMobile,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    switch (_metodoIndex) {
      case 0:
        return _buildEfectivoFields(
            tasaValida, isMobile, colorScheme, isDark);
      case 1:
        return _buildPagoMovilFields(
            tasaValida, isMobile, colorScheme, isDark);
      case 2:
        return _buildPuntoFields(tasaValida, isMobile, colorScheme, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEfectivoFields(
    double tasaValida,
    bool isMobile,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    const color = _colorEfectivo;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _campoMonto(
                controller: _efectivoUsdController,
                focusNode: _efectivoUsdFocus,
                label: 'Efectivo \$',
                prefixIcon: Icons.attach_money_rounded,
                color: color,
                colorScheme: colorScheme,
                isDark: isDark,
                isMobile: isMobile,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campoMonto(
                controller: _efectivoBsController,
                label: 'Efectivo Bs',
                prefixIcon: Icons.payments_outlined,
                color: color,
                colorScheme: colorScheme,
                isDark: isDark,
                isMobile: isMobile,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _botonExacto(
            label: '\$ Exacto',
            icon: Icons.attach_money,
            color: color,
            onPressed: _pagarExactoUsd,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildPagoMovilFields(
    double tasaValida,
    bool isMobile,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    const color = _colorPagoMovil;
    return Column(
      children: [
        _campoMonto(
          controller: _pagoMovilBsController,
          label: 'Monto en Bs (Pago Móvil)',
          prefixIcon: Icons.phone_android,
          color: color,
          colorScheme: colorScheme,
          isDark: isDark,
          isMobile: isMobile,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        _campoTexto(
          controller: _referenciaController,
          label: 'Número de Referencia',
          prefixIcon: Icons.numbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _botonExacto(
            label: 'Pago Móvil Exacto',
            icon: Icons.phone_android,
            color: color,
            onPressed: () => _pagarExactoPagoMovil(tasaValida),
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildPuntoFields(
    double tasaValida,
    bool isMobile,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    const color = _colorPunto;
    return Column(
      children: [
        _campoMonto(
          controller: _puntoBsController,
          label: 'Monto en Bs (Punto)',
          prefixIcon: Icons.credit_card,
          color: color,
          colorScheme: colorScheme,
          isDark: isDark,
          isMobile: isMobile,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        _campoTexto(
          controller: _referenciaController,
          label: 'Número de Referencia (opcional)',
          prefixIcon: Icons.numbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _botonExacto(
            label: 'Punto Exacto',
            icon: Icons.credit_card,
            color: color,
            onPressed: () => _pagarExactoPunto(tasaValida),
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  /// Botón "Exacto" reutilizable con cursor pointer + hover nativo
  Widget _botonExacto({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
          ),
          backgroundColor:
              WidgetStatePropertyAll(color.withValues(alpha: 0.05)),
          overlayColor: WidgetStatePropertyAll(
            // hover + ripple tintado con el color del método
            color.withValues(alpha: 0.15),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 22,
              vertical: isMobile ? 12 : 14,
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // TAB: CLIENTE
  // ======================================================
  Widget _buildClienteTab({
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isMobile,
    required Color colorMetodo,
  }) {
    final clientes = ref.watch(clientesProvider);
    final query = _clienteSearchController.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? <ClienteEntity>[]
        : clientes
            .where((c) =>
                c.nombre.toLowerCase().contains(query) ||
                (c.documento ?? '').toLowerCase().contains(query) ||
                (c.telefono ?? '').toLowerCase().contains(query))
            .take(8)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _clienteSearchController,
          focusNode: _clienteFocus,
          onChanged: (_) => setState(() {
            if (_clienteSeleccionado != null) _clienteSeleccionado = null;
          }),
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecorationHelper.build(
            context: context,
            label: 'Buscar por nombre, cédula o teléfono',
            prefixIcon: Icons.search,
            errorText: null,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 10),

        // Botón "Registrar cliente" — ahora más alto + hover + cursor
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _abrirFormularioCliente,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text(
                'Registrar nuevo cliente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorMetodo),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: colorMetodo.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  colorMetodo.withValues(alpha: 0.06),
                ),
                overlayColor: WidgetStatePropertyAll(
                  colorMetodo.withValues(alpha: 0.15),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (_clienteSeleccionado != null)
          _buildClienteCard(_clienteSeleccionado!, colorScheme, isDark,
              colorMetodo)
        else if (matches.isNotEmpty)
          _buildClienteLista(matches, colorScheme, isDark, colorMetodo)
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sin cliente asignado. Esta venta se registrará como venta general.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildClienteCard(
    ClienteEntity cliente,
    ColorScheme colorScheme,
    bool isDark,
    Color colorMetodo,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorMetodo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorMetodo.withValues(alpha: 0.35),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorMetodo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  cliente.frecuente ? Icons.star : Icons.person,
                  color: colorMetodo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cliente.documento ?? 'Sin documento',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  tooltip: 'Quitar',
                  onPressed: () => setState(() {
                    _clienteSeleccionado = null;
                    _clienteSearchController.clear();
                  }),
                  icon: Icon(Icons.close_rounded,
                      size: 18, color: colorScheme.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
                _infoChip(
                  Icons.phone_outlined,
                  cliente.telefono!,
                  colorScheme,
                  isDark,
                ),
              if (cliente.cantidadCompras > 0)
                _infoChip(
                  Icons.shopping_bag_outlined,
                  '${cliente.cantidadCompras} compras',
                  colorScheme,
                  isDark,
                ),
              if (cliente.totalCompras > 0)
                _infoChip(
                  Icons.attach_money_rounded,
                  'Total: \$${cliente.totalCompras.toStringAsFixed(2)}',
                  colorScheme,
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String label,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteLista(
    List<ClienteEntity> clientes,
    ColorScheme colorScheme,
    bool isDark,
    Color colorMetodo,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: clientes.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        itemBuilder: (context, i) {
          final c = clientes[i];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: colorMetodo.withValues(alpha: 0.15),
                child: Icon(
                  c.frecuente ? Icons.star : Icons.person_outline,
                  size: 16,
                  color: colorMetodo,
                ),
              ),
              title: Text(
                c.nombre,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              subtitle: Text(
                '${c.documento ?? "Sin documento"}${c.telefono != null ? " · ${c.telefono}" : ""}',
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () => setState(() {
                _clienteSeleccionado = c;
                _clienteSearchController.text = c.nombre;
              }),
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // BANNER TOTALES
  // ======================================================
  Widget _buildTotalesBanner({
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isMobile,
    required double totalBs,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainer
                ]
              : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                _totalRow(
                    'TOTAL A PAGAR (\$)',
                    '\$${widget.totalAPagar.toStringAsFixed(2)}',
                    colorScheme.primary,
                    22),
                const SizedBox(height: 4),
                _totalRow('TOTAL EN BS', 'Bs. ${totalBs.toStringAsFixed(2)}',
                    colorScheme.primary, 16),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL A PAGAR (\$)',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('\$${widget.totalAPagar.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL EN BOLÍVARES',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Bs. ${totalBs.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _totalRow(String label, String value, Color color, double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(
                color: color, fontSize: size, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ======================================================
  // PANEL VUELTO / FALTANTE  (3 estados: verde/amarillo/rojo)
  // ======================================================
  Widget _buildPanelVuelto({
    required ColorScheme colorScheme,
    required bool isMobile,
    required bool esExacto,
    required bool hayVuelto,
    required double vueltoUsd,
    required double vueltoBs,
    required double faltanteUsd,
    required double faltanteBs,
  }) {
    // Determinar estado visual
    late Color borderColor;
    late Color bgColor;
    late Color textColor;
    late IconData icon;

    if (esExacto) {
      // 🟢 Pago exacto
      borderColor = colorScheme.primary;
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.2);
      textColor = colorScheme.primary;
      icon = Icons.check_circle_rounded;
    } else if (hayVuelto) {
      // 🟡 Hay vuelto (pago de más)
      borderColor = _colorVuelto;
      bgColor = _colorVuelto.withValues(alpha: 0.12);
      textColor = _colorVuelto;
      icon = Icons.savings_rounded;
    } else {
      // 🔴 Faltante (pago por debajo)
      borderColor = colorScheme.error;
      bgColor = colorScheme.errorContainer.withValues(alpha: 0.2);
      textColor = colorScheme.error;
      icon = Icons.warning_amber_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 18, vertical: isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
              Text(
                esExacto
                    ? 'PAGO EXACTO'
                    : (hayVuelto ? 'VUELTO' : 'FALTANTE'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (esExacto) ...[
            _vueltoRow(
              'Vuelto (\$):',
              '\$${vueltoUsd.toStringAsFixed(2)}',
              textColor,
            ),
            const SizedBox(height: 6),
            _vueltoRow(
              'Vuelto (Bs):',
              'Bs. ${vueltoBs.toStringAsFixed(2)}',
              textColor,
            ),
          ] else if (hayVuelto) ...[
            _vueltoRow(
              'Vuelto (\$):',
              '\$${vueltoUsd.toStringAsFixed(2)}',
              textColor,
            ),
            const SizedBox(height: 6),
            _vueltoRow(
              'Vuelto (Bs):',
              'Bs. ${vueltoBs.toStringAsFixed(2)}',
              textColor,
            ),
          ] else ...[
            _vueltoRow(
              'Faltante (\$):',
              '\$${faltanteUsd.toStringAsFixed(2)}',
              textColor,
            ),
            const SizedBox(height: 6),
            _vueltoRow(
              'Faltante (Bs):',
              'Bs. ${faltanteBs.toStringAsFixed(2)}',
              textColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _vueltoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ======================================================
  // CAMPOS REUTILIZABLES
  // ======================================================
  Widget _campoTexto({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData prefixIcon,
    required ColorScheme colorScheme,
    bool isDark = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecorationHelper.build(
        context: context,
        label: label,
        prefixIcon: prefixIcon,
        errorText: null,
        isDark: isDark,
      ),
    );
  }

  Widget _campoMonto({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData prefixIcon,
    required Color color,
    required ColorScheme colorScheme,
    bool isDark = false,
    required ValueChanged<String> onChanged,
    bool isMobile = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: onChanged,
      style: TextStyle(
          fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      decoration: InputDecorationHelper.build(
        context: context,
        label: label,
        prefixIcon: prefixIcon,
        errorText: null,
        isDark: isDark,
      ),
    );
  }

  // ======================================================
  // BOTONES PRINCIPALES
  // ======================================================
  Widget _buildBotones({
    required bool pagoCompleto,
    required double tasaValida,
    required Color colorMetodo,
    required ColorScheme colorScheme,
    required bool isMobile,
  }) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: _buttonHeight,
            child: MouseRegion(
              cursor: pagoCompleto
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.forbidden,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    pagoCompleto
                        ? colorMetodo
                        : colorScheme.surfaceContainerHighest,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    pagoCompleto
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(pagoCompleto ? 4 : 0),
                  overlayColor: WidgetStatePropertyAll(
                    Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                onPressed:
                    pagoCompleto ? () => _confirmarPago(tasaValida) : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 22),
                    SizedBox(width: 10),
                    Text('CONFIRMAR PAGO',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.3)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('CANCELAR',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.3)),
              ),
            ),
          ),
        ],
      );
    }

    // Desktop / tablet
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: _buttonHeight,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('CANCELAR',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: 14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: _buttonHeight,
          child: MouseRegion(
            cursor: pagoCompleto
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  pagoCompleto
                      ? colorMetodo
                      : colorScheme.surfaceContainerHighest,
                ),
                foregroundColor: WidgetStatePropertyAll(
                  pagoCompleto
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 36),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                elevation: WidgetStatePropertyAll(pagoCompleto ? 4 : 0),
                overlayColor: WidgetStatePropertyAll(
                  Colors.white.withValues(alpha: 0.15),
                ),
              ),
              onPressed: pagoCompleto ? () => _confirmarPago(tasaValida) : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('CONFIRMAR PAGO',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Info de cada método de pago (para las cards)
class _MetodoInfo {
  final String label;
  final String sub;
  final IconData icon;
  final Color color;
  const _MetodoInfo({
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
  });
}