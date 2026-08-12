import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/detalle_venta_entity.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/sales/sales_history_filter_bar.dart';
import '../widgets/sales/sales_history_summary_cards.dart';
import '../widgets/sales/sales_history_search_bar.dart';
import '../widgets/sales/sales_history_list.dart';

class SalesHistoryScreen extends StatefulWidget {
  final bool showAppBar;

  const SalesHistoryScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final IsarService _isarService = IsarService();

  List<VentaEntity> _todasLasVentas = [];
  List<VentaEntity> _ventasFiltradas = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _metodoSeleccionado = 'Todos';
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

  final List<String> _metodos = ['Todos', 'Efectivo', 'Tarjeta', 'Pago Móvil', 'Divisas'];

  Key _listKey = const ValueKey('initial');

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  // ============================================================
  // CARGA Y FILTRADO
  // ============================================================
  Future<void> _cargarVentas() async {
    setState(() => _isLoading = true);
    try {
      try {
        await SyncService().descargarVentasDesdeSupabase();
      } catch (_) {}

      final ventas = await _isarService.obtenerVentas();
      ventas.sort((a, b) => b.fecha.compareTo(a.fecha));

      int anioMinimo = DateTime.now().year;
      if (ventas.isNotEmpty) {
        anioMinimo = ventas.map((v) => v.fecha.toLocal().year).reduce((a, b) => a < b ? a : b);
      }
      final int anioActual = DateTime.now().year;

      List<int> anios = [];
      for (int i = anioActual; i >= anioMinimo; i--) {
        anios.add(i);
      }

      if (mounted) {
        _todasLasVentas = ventas;
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
            content: Text('Error al cargar las ventas: $e'),
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
    final filtradas = _todasLasVentas.where((venta) {
      final coincidePeriodo = _perteneceAlPeriodo(venta.fecha, _periodoSeleccionado);
      final query = _searchQuery.toLowerCase().trim();
      final coincideId = venta.ventaIdString.toLowerCase().contains(query);
      final coincideEmpleado = venta.empleado.toLowerCase().contains(query);
      final coincideCliente = venta.documento.toLowerCase().contains(query);
      final coincideBusqueda = query.isEmpty || coincideId || coincideEmpleado || coincideCliente;
      final coincideMetodo = _metodoSeleccionado == 'Todos' ||
          venta.metodoPago.toLowerCase() == _metodoSeleccionado.toLowerCase();
      return coincidePeriodo && coincideBusqueda && coincideMetodo;
    }).toList();

    final acumuladoUSD = filtradas.fold<double>(0.0, (sum, v) => sum + (v.total.isNaN ? 0.0 : v.total));
    final acumuladoBs = filtradas.fold<double>(0.0, (sum, v) {
      final double tasaValida = (v.tasaBcv.isNaN || v.tasaBcv <= 0) ? 0.0 : v.tasaBcv;
      final double totalBsVenta = (v.totalBolivares.isNaN || v.totalBolivares <= 0)
          ? (v.total * tasaValida)
          : v.totalBolivares;
      return sum + (totalBsVenta.isNaN ? 0.0 : totalBsVenta);
    });

    setState(() {
      _ventasFiltradas = filtradas;
      _totalUSD = acumuladoUSD;
      _totalBs = acumuladoBs;
      _listKey = ValueKey('${filtradas.length}_${DateTime.now().millisecondsSinceEpoch}');
    });
  }

  // ============================================================
  // EXPORTAR CSV
  // ============================================================
  Future<void> _exportarCSV() async {
    if (_ventasFiltradas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay ventas para exportar en el período seleccionado.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('ID Venta;Fecha;Empleado;Método Pago;Total USD;Total Bs.');

      for (var venta in _ventasFiltradas) {
        final fechaLocal = venta.fecha.toLocal();
        final String fechaStr =
            '${fechaLocal.day}/${fechaLocal.month}/${fechaLocal.year} ${fechaLocal.hour}:${fechaLocal.minute}';
        final double tasaVentaValida =
            (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
        final double totalBsVentaValido = (venta.totalBolivares.isNaN ||
                venta.totalBolivares <= 0)
            ? (venta.total * tasaVentaValida)
            : venta.totalBolivares;

        buffer.writeln(
            '${venta.ventaIdString};$fechaStr;${venta.empleado};${venta.metodoPago};${venta.total.toStringAsFixed(2)};${totalBsVentaValido.toStringAsFixed(2)}');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'ventas_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(buffer.toString(), encoding: utf8);

      final shareResult = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Historial de Ventas Exportado',
      );

      if (shareResult.status == ShareResultStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Archivo CSV exportado correctamente!'),
              backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al exportar CSV: $e'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
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
    final double fontSizeTitle = isTablet ? 26 : 18;
    final double fontSizeResumen = isMobile ? 13 : 16;
    final double fontSizeResumenValor = isMobile ? 16 : (isTablet ? 26 : 22);
    final double spacingWrap = isMobile ? 8 : (isTablet ? 18 : 14);

    final body = _isLoading
        ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
        : Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SalesHistoryFilterBar(
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
                    const SizedBox(height: 16),

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
                      child: SalesHistorySummaryCards(
                        key: ValueKey('summary_${_ventasFiltradas.length}_${_totalUSD}_${_totalBs}'),
                        ventasCount: _ventasFiltradas.length,
                        totalUSD: _totalUSD,
                        totalBs: _totalBs,
                        isMobile: isMobile,
                        isTablet: isTablet,
                        spacingWrap: spacingWrap,
                        fontSizeResumen: fontSizeResumen,
                        fontSizeResumenValor: fontSizeResumenValor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SalesHistorySearchBar(
                      searchQuery: _searchQuery,
                      onSearchChanged: (value) {
                        setState(() => _searchQuery = value);
                        _aplicarFiltros();
                      },
                      selectedMethod: _metodoSeleccionado,
                      methods: _metodos,
                      onMethodSelected: (metodo) {
                        setState(() => _metodoSeleccionado = metodo);
                        _aplicarFiltros();
                      },
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 16),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: SalesHistoryList(
                        key: _listKey,
                        ventas: _ventasFiltradas,
                        isMobile: isMobile,
                        isTablet: isTablet,
                        shrinkWrap: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        appBar: AppBar(
          title: Text(
            'Historial de Transacciones',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSizeTitle,
              color: colorScheme.onPrimary,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: isDark
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
                      colors: [Color.fromRGBO(81, 120, 252, 1), Color.fromARGB(255, 62, 40, 189)],
                    ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: Icon(Icons.download_rounded, color: colorScheme.onPrimary),
              tooltip: 'Exportar CSV de ventas',
              onPressed: _exportarCSV,
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
              tooltip: 'Actualizar Historial',
              onPressed: _cargarVentas,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: body,
      );
    } else {
      return body;
    }
  }
}