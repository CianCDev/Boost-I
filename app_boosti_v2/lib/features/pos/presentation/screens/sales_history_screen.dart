import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/detalle_venta_entity.dart'; // ✅ IMPORTANTE
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';


class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  // ============================================================
  // CARGA DE VENTAS (SOLO LOCALES)
  // ============================================================
  Future<void> _cargarVentas() async {
    setState(() => _isLoading = true);
    try {
      // 🔥 Si quieres descargar desde Supabase, implementa el método y descomenta
      // await SyncService().descargarVentasDesdeSupabase();

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
          SnackBar(content: Text('Error al cargar las ventas: $e'), backgroundColor: Colors.red),
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
    });
  }

  // ============================================================
  // MÉTODOS AUXILIARES PARA EL DETALLE
  // ============================================================
  Widget _detalleFila(String label, String valor, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, String valor, bool isLargeScreen,
      {bool esDestacado = false, bool esTotal = false, bool esTotalBs = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: esDestacado
                ? const Color(0xFF38BDF8)
                : (esTotal
                    ? Colors.white
                    : (esTotalBs
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF94A3B8))),
            fontSize: esTotal
                ? (isLargeScreen ? 16 : 15)
                : (isLargeScreen ? 13 : 12),
            fontWeight: esTotal
                ? FontWeight.bold
                : (esDestacado ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            color: esDestacado
                ? const Color(0xFF38BDF8)
                : (esTotal
                    ? const Color(0xFF34D399)
                    : (esTotalBs ? const Color(0xFF38BDF8) : Colors.white)),
            fontSize: esTotal
                ? (isLargeScreen ? 17 : 16)
                : (isLargeScreen ? 13 : 12),
            fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _columnaDetalle(String titulo, String valor, bool isLargeScreen,
      {Color? colorValor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: isLargeScreen ? 10 : 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            fontSize: isLargeScreen ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: colorValor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _celdaHeader(String texto, bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isLargeScreen ? 11 : 10,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _celdaBody(String texto, bool isLargeScreen,
      {bool alignLeft = false, bool esBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Text(
        texto,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: isLargeScreen ? 11 : 10,
          fontWeight: esBold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  // ============================================================
  // DETALLE DE VENTA (MODAL) – CON CARGA DE PRODUCTOS
  // ============================================================
  void _mostrarModalDetalleVenta(BuildContext context, VentaEntity venta) {
    final fechaLocal = venta.fecha.toLocal();
    final String fechaFormatted =
        '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year.toString()} - '
        '${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
    final double tasaVentaValida =
        (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
    final double totalBsVentaValido =
        (venta.totalBolivares.isNaN || venta.totalBolivares <= 0)
            ? (venta.total * tasaVentaValida)
            : venta.totalBolivares;

    final isLargeScreen = !ResponsiveHelper.isMobile(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    // 🔥 Cargar detalles desde Isar (si no están presentes)
    Future<List<DetalleVentaEntity>> getDetalles() async {
      if (venta.items.isNotEmpty) {
        return venta.items.cast<DetalleVentaEntity>().toList();
      } else {
        return await _isarService.obtenerDetallesPorVenta(venta.id);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<DetalleVentaEntity>>(
          future: getDetalles(),
          builder: (context, snapshot) {
            final detalles = snapshot.data ?? [];

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: isLargeScreen ? 650 : MediaQuery.of(context).size.width * 0.92,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- CABECERA ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Venta #${venta.ventaIdString}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLargeScreen ? 18 : 15,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  fechaFormatted,
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 13 : 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF64748B)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // ---- DATOS DEL CLIENTE (RESPONSIVE) ----
                    isMobile
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detalleFila('Cliente',
                                    venta.documento.isEmpty ? 'N/A' : venta.documento),
                                const SizedBox(height: 8),
                                _detalleFila('Atendido por', venta.empleado),
                                const SizedBox(height: 8),
                                _detalleFila('Método', venta.metodoPago),
                                const SizedBox(height: 8),
                                _detalleFila(
                                  'Sincronizado',
                                  venta.syncStatus == 'synced'
                                      ? 'Sí'
                                      : (venta.syncStatus == 'pending'
                                          ? 'Pendiente'
                                          : 'Fallida'),
                                  color: venta.syncStatus == 'synced'
                                      ? const Color(0xFF059669)
                                      : (venta.syncStatus == 'pending'
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFFEF4444)),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _columnaDetalle(
                                    'Cliente',
                                    venta.documento.isEmpty ? 'N/A' : venta.documento,
                                    isLargeScreen),
                                _columnaDetalle('Atendido por', venta.empleado,
                                    isLargeScreen),
                                _columnaDetalle('Método', venta.metodoPago,
                                    isLargeScreen),
                                _columnaDetalle(
                                  'Sincronizado',
                                  venta.syncStatus == 'synced'
                                      ? 'Sí'
                                      : (venta.syncStatus == 'pending'
                                          ? 'Pendiente'
                                          : 'Fallida'),
                                  isLargeScreen,
                                  colorValor: venta.syncStatus == 'synced'
                                      ? const Color(0xFF059669)
                                      : (venta.syncStatus == 'pending'
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFFEF4444)),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 16),

                    // ---- TABLA DE PRODUCTOS (USA `detalles`) ----
                    Text(
                      'Detalle de Productos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeScreen ? 15 : 13,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: isLargeScreen ? double.infinity : 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1.5),
                            },
                            children: [
                              TableRow(
                                decoration:
                                    const BoxDecoration(color: Color(0xFFF1F5F9)),
                                children: [
                                  _celdaHeader('Producto', isLargeScreen),
                                  _celdaHeader('Cant.', isLargeScreen),
                                  _celdaHeader('Precio (\$)', isLargeScreen),
                                  _celdaHeader('Subtotal (\$)', isLargeScreen),
                                ],
                              ),
                              if (detalles.isEmpty)
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Center(
                                          child: Text(
                                            'Sin productos',
                                            style: TextStyle(
                                              fontSize: isLargeScreen ? 14 : 12,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(child: Container()),
                                    TableCell(child: Container()),
                                    TableCell(child: Container()),
                                  ],
                                )
                              else
                                ...detalles.map((item) => TableRow(
                                      children: [
                                        _celdaBody(item.nombreProducto,
                                            isLargeScreen, alignLeft: true),
                                        _celdaBody(
                                            item.cantidad.toStringAsFixed(
                                                item.cantidad % 1 == 0 ? 0 : 3),
                                            isLargeScreen),
                                        _celdaBody(
                                            '\$${item.precioUnidad.toStringAsFixed(2)}',
                                            isLargeScreen),
                                        _celdaBody(
                                            '\$${item.subtotal.toStringAsFixed(2)}',
                                            isLargeScreen,
                                            esBold: true),
                                      ],
                                    )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- TOTALES ----
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _totalRow('Subtotal USD:',
                              '\$${venta.subtotal.toStringAsFixed(2)}', isLargeScreen),
                          const SizedBox(height: 6),
                          _totalRow('Impuesto (IVA USD):',
                              '\$${venta.impuesto.toStringAsFixed(2)}', isLargeScreen),
                          const SizedBox(height: 6),
                          _totalRow(
                            'Tasa BCV:',
                            'Bs. ${tasaVentaValida.toStringAsFixed(2)} / \$',
                            isLargeScreen,
                            esDestacado: true,
                          ),
                          const Divider(color: Color(0xFF334155), height: 20),
                          _totalRow(
                            'TOTAL USD:',
                            '\$${venta.total.toStringAsFixed(2)}',
                            isLargeScreen,
                            esTotal: true,
                          ),
                          const SizedBox(height: 6),
                          _totalRow(
                            'TOTAL BS:',
                            'Bs. ${totalBsVentaValido.toStringAsFixed(2)}',
                            isLargeScreen,
                            esTotalBs: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // EXPORTAR CSV
  // ============================================================
  Future<void> _exportarCSV() async {
    if (_ventasFiltradas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No hay ventas para exportar en el período seleccionado.'),
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
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // ============================================================
  // BUILD RESPONSIVE
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final double hPadding = isTablet ? 20.0 : 12.0;
    final double vPadding = isTablet ? 20.0 : 12.0;

    final double fontSizeTitle = isTablet ? 22 : 18;
    final double fontSizeResumen = isMobile ? 13 : 16;
    final double fontSizeResumenValor = isMobile ? 16 : 20;
    final double spacingWrap = isMobile ? 8 : 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Historial de Transacciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSizeTitle,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromRGBO(81, 120, 252, 1), Color.fromARGB(255, 62, 40, 189)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Exportar CSV de ventas',
            onPressed: _exportarCSV,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar Historial',
            onPressed: _cargarVentas,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              child: Column(
                children: [
                  // ---- FILTRO DE PERÍODO ----
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _botonPeriodo('dia', 'Hoy', Icons.today, isMobile),
                        const SizedBox(width: 6),
                        _botonPeriodo('semana', 'Semana', Icons.date_range, isMobile),
                        const SizedBox(width: 6),
                        _botonPeriodo('mes', 'Mes', Icons.calendar_month, isMobile),
                        const SizedBox(width: 6),
                        _botonPeriodo('anio', 'Año', Icons.calendar_today, isMobile),
                        const SizedBox(width: 6),
                        _botonPeriodo('todos', 'Todas', Icons.all_inclusive, isMobile),
                      ],
                    ),
                  ),

                  // ---- SELECTORES MES/AÑO ----
                  if (_periodoSeleccionado == 'mes') ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: isTablet ? 44 : 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _mesSeleccionadoDropdown,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)),
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w600,
                                ),
                                items: _listaMesesDropdown.map((mes) {
                                  return DropdownMenuItem(
                                    value: mes,
                                    child: Text(mes == 'Actual' ? 'Mes Actual' : mes),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _mesSeleccionadoDropdown = val);
                                    _aplicarFiltros();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: isTablet ? 44 : 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: _anioSeleccionadoDropdown,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)),
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w600,
                                ),
                                items: _listaAniosDisponibles.map((anio) {
                                  return DropdownMenuItem(
                                    value: anio,
                                    child: Text('$anio${anio == DateTime.now().year ? ' (Actual)' : ''}'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _anioSeleccionadoDropdown = val);
                                    _aplicarFiltros();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_periodoSeleccionado == 'anio') ...[
                    const SizedBox(height: 10),
                    Container(
                      height: isTablet ? 44 : 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _anioSeleccionadoDropdown,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)),
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                          items: _listaAniosDisponibles.map((anio) {
                            return DropdownMenuItem(
                              value: anio,
                              child: Text('$anio${anio == DateTime.now().year ? ' (Actual)' : ''}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _anioSeleccionadoDropdown = val);
                              _aplicarFiltros();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // ---- TARJETAS DE RESUMEN ----
                  Wrap(
                    spacing: spacingWrap,
                    runSpacing: spacingWrap,
                    children: [
                      _tarjetaResumen(
                        'Ventas',
                        '${_ventasFiltradas.length}',
                        Icons.receipt_long,
                        const Color(0xFF3B82F6),
                        isMobile,
                        isTablet,
                        fontSizeResumen,
                        fontSizeResumenValor,
                      ),
                      _tarjetaResumen(
                        'Total USD',
                        '\$${_totalUSD.toStringAsFixed(2)}',
                        Icons.attach_money,
                        const Color(0xFF10B981),
                        isMobile,
                        isTablet,
                        fontSizeResumen,
                        fontSizeResumenValor,
                      ),
                      _tarjetaResumen(
                        'Total Bs.',
                        'Bs. ${_totalBs.toStringAsFixed(2)}',
                        Icons.currency_exchange,
                        const Color(0xFF0284C7),
                        isMobile,
                        isTablet,
                        fontSizeResumen,
                        fontSizeResumenValor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ---- BUSCADOR Y FILTRO POR MÉTODO ----
                  Container(
                    padding: EdgeInsets.all(isTablet ? 14.0 : 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: isTablet ? 44 : 38,
                          child: TextField(
                            onChanged: (val) {
                              _searchQuery = val;
                              _aplicarFiltros();
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar por ID, Cédula o Empleado...',
                              hintStyle: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF94A3B8),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: isTablet ? 22 : 18,
                                color: const Color(0xFF64748B),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _metodos.map((metodo) {
                              final bool esSeleccionado = _metodoSeleccionado == metodo;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _metodoSeleccionado = metodo;
                                    });
                                    _aplicarFiltros();
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 12 : 8,
                                      vertical: isTablet ? 7 : 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: esSeleccionado ? const Color(0xFF0F172A) : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: esSeleccionado ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: Text(
                                      metodo,
                                      style: TextStyle(
                                        fontSize: isTablet ? 13 : 11,
                                        fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                                        color: esSeleccionado ? Colors.white : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---- LISTA DE VENTAS ----
                  Expanded(
                    child: _ventasFiltradas.isEmpty
                        ? Center(
                            child: Text(
                              'No hay ventas registradas en el periodo seleccionado.',
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _ventasFiltradas.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final venta = _ventasFiltradas[index];
                              final fechaLocal = venta.fecha.toLocal();
                              final String fechaFormatted =
                                  '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year.toString()} - '
                                  '${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
                              final double tasaVentaValida =
                                  (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
                              final double totalBsVentaValido =
                                  (venta.totalBolivares.isNaN || venta.totalBolivares <= 0)
                                      ? (venta.total * tasaVentaValida)
                                      : venta.totalBolivares;

                              return InkWell(
                                onTap: () => _mostrarModalDetalleVenta(context, venta),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 16 : 10,
                                    vertical: isTablet ? 14 : 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      // ---- ICONO ----
                                      Container(
                                        width: isTablet ? 44 : 36,
                                        height: isTablet ? 44 : 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.article_outlined,
                                          color: const Color(0xFF334155),
                                          size: isTablet ? 26 : 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // ---- INFORMACIÓN CENTRAL ----
                                      Flexible(
                                        flex: isMobile ? 1 : 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Venta #${venta.ventaIdString}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: isTablet ? 16 : 13,
                                                      color: const Color(0xFF0F172A),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE0F2FE),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(
                                                      color: const Color(0xFFBAE6FD),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Tasa: Bs. ${tasaVentaValida.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: isTablet ? 10 : 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF0369A1),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$fechaFormatted • Atendido por: ${venta.empleado}',
                                              style: TextStyle(
                                                fontSize: isTablet ? 12 : 10,
                                                color: const Color(0xFF64748B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // ---- MÉTODO DE PAGO ----
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          venta.metodoPago.toLowerCase(),
                                          style: TextStyle(
                                            fontSize: isTablet ? 12 : 10,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF059669),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // ---- TOTALES ----
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '\$${venta.total.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: isTablet ? 17 : 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF059669),
                                            ),
                                          ),
                                          Text(
                                            'Bs. ${totalBsVentaValido.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: isTablet ? 12 : 10,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0284C7),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(width: 6),

                                      // ---- FLECHA ----
                                      Icon(
                                        Icons.chevron_right,
                                        color: const Color(0xFFCBD5E1),
                                        size: isTablet ? 24 : 18,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // BOTÓN DE PERÍODO (RESPONSIVE)
  // ============================================================
  Widget _botonPeriodo(String clave, String titulo, IconData icono, bool isMobile) {
    final bool seleccionado = _periodoSeleccionado == clave;
    final bool isTablet = ResponsiveHelper.isTablet(context);

    return InkWell(
      onTap: () {
        setState(() {
          _periodoSeleccionado = clave;
        });
        _aplicarFiltros();
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 10 : 6,
          horizontal: isTablet ? 14 : 10,
        ),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: isTablet ? 15 : 12,
              color: seleccionado ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 10,
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                  color: seleccionado ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DE RESUMEN (RESPONSIVE)
  // ============================================================
  Widget _tarjetaResumen(
    String titulo,
    String valor,
    IconData icono,
    Color color,
    bool isMobile,
    bool isTablet,
    double fontSizeLabel,
    double fontSizeValue,
  ) {
    final double iconSize = isTablet ? 20 : 16;
    final double paddingSize = isTablet ? 14 : 10;
    final double spacing = isMobile ? 6 : 8;

    return Container(
      padding: EdgeInsets.all(paddingSize),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: iconSize),
          ),
          SizedBox(width: spacing),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                valor,
                style: TextStyle(
                  fontSize: isTablet ? 22 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}