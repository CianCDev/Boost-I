import 'dart:async';
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/gasto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../providers/bcv_provider.dart';
import '../providers/usuario_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/appbar.dart';
import '../widgets/gastos/gastos_filter_bar.dart';
import '../widgets/gastos/gastos_summary_cards.dart';
import '../widgets/gastos/gastos_search_bar.dart';
import '../widgets/gastos/gastos_list.dart';
import '../widgets/gastos/gastos_detail_dialog.dart';

class GastosScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const GastosScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  ConsumerState<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends ConsumerState<GastosScreen> {
  final IsarService _isarService = IsarService();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String _monedaSeleccionada = 'USD';
  String _categoriaSeleccionada = 'General';
  final List<String> _categorias = ['General', 'Alimentación', 'Transporte', 'Servicios', 'Otros'];

  List<GastoEntity> _todosLosGastos = [];
  List<GastoEntity> _gastosFiltrados = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _categoriaFiltro = 'Todas';
  String _periodoSeleccionado = 'todos';

  String _mesSeleccionadoDropdown = 'Actual';
  final List<String> _listaMesesDropdown = [
    'Actual', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  int _anioSeleccionadoDropdown = DateTime.now().year;
  List<int> _listaAniosDisponibles = [];

  double _totalUSD = 0.0;
  double _totalBs = 0.0;

  Key _listKey = const ValueKey('initial');

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGA Y FILTRADO
  // ============================================================
  Future<void> _cargarGastos() async {
    setState(() => _isLoading = true);
    try {
      final gastos = await _isarService.obtenerGastos();
      gastos.sort((a, b) => b.fecha.compareTo(a.fecha));

      int anioMinimo = DateTime.now().year;
      if (gastos.isNotEmpty) {
        anioMinimo = gastos.map((g) => g.fecha.toLocal().year).reduce((a, b) => a < b ? a : b);
      }
      final int anioActual = DateTime.now().year;
      List<int> anios = [];
      for (int i = anioActual; i >= anioMinimo; i--) {
        anios.add(i);
      }

      if (mounted) {
        _todosLosGastos = gastos;
        _listaAniosDisponibles = anios;
        if (!_listaAniosDisponibles.contains(_anioSeleccionadoDropdown)) {
          _anioSeleccionadoDropdown = anioActual;
        }
        _isLoading = false;
        _aplicarFiltros();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar gastos: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  bool _perteneceAlPeriodo(DateTime fecha, String periodo) {
    final now = DateTime.now();
    final fechaLocal = fecha.toLocal();
    final fechaDia = DateTime(fechaLocal.year, fechaLocal.month, fechaLocal.day);
    final hoy = DateTime(now.year, now.month, now.day);

    switch (periodo) {
      case 'dia':
        return fechaDia.isAtSameMomentAs(hoy);
      case 'semana':
        final inicioSemana = hoy.subtract(Duration(days: now.weekday - 1));
        final finSemana = inicioSemana.add(const Duration(days: 6));
        return (fechaDia.isAtSameMomentAs(inicioSemana) || fechaDia.isAfter(inicioSemana)) &&
               (fechaDia.isAtSameMomentAs(finSemana) || fechaDia.isBefore(finSemana));
      case 'mes':
        if (_mesSeleccionadoDropdown == 'Actual') {
          return fechaLocal.year == now.year && fechaLocal.month == now.month;
        } else {
          final int indexMes = _listaMesesDropdown.indexOf(_mesSeleccionadoDropdown);
          return fechaLocal.year == _anioSeleccionadoDropdown && fechaLocal.month == indexMes;
        }
      case 'anio':
        return fechaLocal.year == _anioSeleccionadoDropdown;
      case 'todos':
      default:
        return true;
    }
  }

  void _aplicarFiltros() {
    final filtrados = _todosLosGastos.where((gasto) {
      final coincidePeriodo = _perteneceAlPeriodo(gasto.fecha, _periodoSeleccionado);
      final query = _searchQuery.toLowerCase().trim();
      final coincideDescripcion = gasto.descripcion.toLowerCase().contains(query);
      final coincideBusqueda = query.isEmpty || coincideDescripcion;
      final coincideCategoria = _categoriaFiltro == 'Todas' ||
          gasto.categoria.toLowerCase() == _categoriaFiltro.toLowerCase();
      return coincidePeriodo && coincideBusqueda && coincideCategoria;
    }).toList();

    final acumuladoUSD = filtrados
        .where((g) => g.moneda == 'USD')
        .fold<double>(0.0, (sum, g) => sum + g.monto);
    final acumuladoBs = filtrados
        .where((g) => g.moneda == 'Bs')
        .fold<double>(0.0, (sum, g) => sum + g.monto);

    setState(() {
      _gastosFiltrados = filtrados;
      _totalUSD = acumuladoUSD;
      _totalBs = acumuladoBs;
      _listKey = ValueKey('${filtrados.length}_${DateTime.now().millisecondsSinceEpoch}');
    });
  }

  // ============================================================
  // REGISTRAR GASTO
  // ============================================================
  Future<void> _registrarGasto() async {
    final descripcion = _descripcionController.text.trim();
    final montoStr = _montoController.text.trim().replaceAll(',', '.');
    final monto = double.tryParse(montoStr);

    if (descripcion.isEmpty || monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una descripción y un monto válido.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario no identificado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tasaBcv = ref.read(bcvProvider).tasa;
    final gasto = GastoEntity()
      ..descripcion = descripcion
      ..monto = monto
      ..moneda = _monedaSeleccionada
      ..tasaBcv = _monedaSeleccionada == 'USD' ? tasaBcv : null
      ..categoria = _categoriaSeleccionada
      ..usuarioId = usuario.id
      ..usuarioNombre = usuario.nombre
      ..fecha = DateTime.now()
      ..syncStatus = 'pending';

    await _isarService.guardarGasto(gasto);
    _descripcionController.clear();
    _montoController.clear();
    await _cargarGastos();
    await _isarService.guardarLog(
      LogEntity()
        ..accion = 'GASTO_REGISTRADO'
        ..usuarioNombre = usuario.nombre
        ..usuarioRol = usuario.rol
        ..detalles = '${gasto.descripcion} - Monto: ${gasto.monto} ${gasto.moneda}'
        ..fecha = DateTime.now()
        ..sincronizado = false,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Gasto registrado correctamente.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  // ============================================================
  // MOSTRAR DETALLE DE GASTO
  // ============================================================
  void _mostrarDetalleGasto(GastoEntity gasto) {
    showDialog(
      context: context,
      builder: (_) => GastosDetailDialog(
        title: 'Detalle del Gasto',
        gastos: [gasto],
        color: const Color(0xFFEF4444),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final double hPadding = isTablet ? 32.0 : 12.0;
    final double vPadding = isTablet ? 24.0 : 12.0;
    final double fontSizeResumen = isMobile ? 13 : 16;
    final double fontSizeResumenValor = isMobile ? 16 : (isTablet ? 26 : 22);
    final double spacingWrap = isMobile ? 8 : (isTablet ? 18 : 14);

    final body = _isLoading
        ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildRegistroForm(colorScheme, isMobile, isTablet),
                    const SizedBox(height: 12),

                    GastosFilterBar(
                      selectedPeriod: _periodoSeleccionado,
                      onPeriodChanged: (periodo) {
                        setState(() => _periodoSeleccionado = periodo);
                        _aplicarFiltros();
                      },
                      isMobile: isMobile,
                      isTablet: isTablet,
                      mesesDropdown: _listaMesesDropdown,
                      mesSeleccionado: _mesSeleccionadoDropdown,
                      aniosDisponibles: _listaAniosDisponibles,
                      anioSeleccionado: _anioSeleccionadoDropdown,
                      onMesChanged: (mes) {
                        setState(() => _mesSeleccionadoDropdown = mes);
                        _aplicarFiltros();
                      },
                      onAnioChanged: (anio) {
                        setState(() => _anioSeleccionadoDropdown = anio);
                        _aplicarFiltros();
                      },
                    ),
                    const SizedBox(height: 12),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: GastosSummaryCards(
                        key: ValueKey('summary_${_gastosFiltrados.length}_${_totalUSD}_$_totalBs'),
                        gastosCount: _gastosFiltrados.length,
                        totalUSD: _totalUSD,
                        totalBs: _totalBs,
                        isMobile: isMobile,
                        isTablet: isTablet,
                        spacingWrap: spacingWrap,
                        fontSizeResumen: fontSizeResumen,
                        fontSizeResumenValor: fontSizeResumenValor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GastosSearchBar(
                      searchQuery: _searchQuery,
                      onSearchChanged: (value) {
                        setState(() => _searchQuery = value);
                        _aplicarFiltros();
                      },
                      selectedCategory: _categoriaFiltro,
                      categories: ['Todas', ..._categorias],
                      onCategorySelected: (categoria) {
                        setState(() => _categoriaFiltro = categoria);
                        _aplicarFiltros();
                      },
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 12),

                    GastosList(
                      key: _listKey,
                      gastos: _gastosFiltrados,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      shrinkWrap: true,
                      onGastoTap: _mostrarDetalleGasto,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );

    if (widget.showAppBar) {
      final gradient = isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.9),
                colorScheme.primary,
              ],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromRGBO(239, 68, 68, 1), Color.fromARGB(255, 185, 28, 28)],
            );

      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        appBar: CustomAppBar(
          title: 'Registro de Gastos',
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Actualizar',
              onPressed: _cargarGastos,
            ),
          ],
          gradient: gradient,
        ),
        body: body,
      );
    } else {
      return body;
    }
  }

  // ---- FORMULARIO DE REGISTRO (sin cambios) ----
  Widget _buildRegistroForm(ColorScheme colorScheme, bool isMobile, bool isTablet) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: const Color(0xFFEF4444),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Registrar Gasto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 15,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Gasto',
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _descripcionController,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 13,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Descripción *',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _montoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 13,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Monto *',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    prefixText: _monedaSeleccionada == 'USD' ? '\$ ' : 'Bs. ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _monedaSeleccionada,
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'Bs', child: Text('Bolívares')),
                  ],
                  onChanged: (val) => setState(() => _monedaSeleccionada = val!),
                  decoration: InputDecoration(
                    labelText: 'Moneda',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: colorScheme.onSurface,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _categoriaSeleccionada,
                  items: _categorias.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: colorScheme.onSurface,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: isTablet ? 50 : 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: _registrarGasto,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Registrar Gasto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}