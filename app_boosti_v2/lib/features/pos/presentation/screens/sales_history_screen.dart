import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
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
  String _periodoSeleccionado = 'dia';

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

  Future<void> _cargarVentas() async {
    setState(() => _isLoading = true);
    try {
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
          SnackBar(content: Text('Error al cargar las ventas: $e'), backgroundColor: Theme.of(context).colorScheme.error),
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

  void _mostrarModalDetalleVenta(BuildContext context, VentaEntity venta) {
    final theme = Theme.of(context);
    final fechaLocal = venta.fecha.toLocal();
    final String fechaFormatted = '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year.toString()} - ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
    final double tasaVentaValida = (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
    final double totalBsVentaValido = (venta.totalBolivares.isNaN || venta.totalBolivares <= 0)
        ? (venta.total * tasaVentaValida)
        : venta.totalBolivares;

    final isLargeScreen = !ResponsiveHelper.isMobile(context);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: isLargeScreen ? 650 : 600,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            'Venta #${venta.ventaIdString}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 18 : 16,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            fechaFormatted,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 13 : 12,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ]),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: theme.textTheme.bodyMedium?.color),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(height: 24, color: theme.dividerColor),

                // ✅ SECCIÓN DE DETALLES DEL CLIENTE (CORREGIDA)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _columnaDetalle('Cliente', venta.documento.isEmpty ? 'N/A' : venta.documento, theme),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: _columnaDetalle('Atendido por', venta.empleado, theme),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: _columnaDetalle('Método', venta.metodoPago, theme),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: _columnaDetalle(
                          'Sincronizado',
                          venta.sincronizado ? 'Sí' : 'No',
                          theme,
                          colorValor: venta.sincronizado ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Detalle de Productos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 15 : 13,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                        ),
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
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            ),
                            children: [
                              _celdaHeader('Producto', theme),
                              _celdaHeader('Cant.', theme),
                              _celdaHeader('Precio (\$)', theme),
                              _celdaHeader('Subtotal (\$)', theme),
                            ],
                          ),
                          ...venta.items.map((item) => TableRow(
                            children: [
                              _celdaBody(item.nombreProducto, alignLeft: true, theme: theme),
                              _celdaBody(item.cantidad.toStringAsFixed(item.cantidad % 1 == 0 ? 0 : 3), theme: theme),
                              _celdaBody('\$${item.precioUnidad.toStringAsFixed(2)}', theme: theme),
                              _celdaBody('\$${item.subtotal.toStringAsFixed(2)}', esBold: true, theme: theme),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal USD:',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                              fontSize: isLargeScreen ? 13 : 12,
                            ),
                          ),
                          Text(
                            '\$${venta.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Impuesto (IVA USD):',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                              fontSize: isLargeScreen ? 13 : 12,
                            ),
                          ),
                          Text(
                            '\$${venta.impuesto.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tasa BCV:',
                            style: TextStyle(
                              color: const Color(0xFF38BDF8),
                              fontSize: isLargeScreen ? 13 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Bs. ${tasaVentaValida.toStringAsFixed(2)} / \$',
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFF334155),
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL USD:',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 16 : 14,
                            ),
                          ),
                          Text(
                            '\$${venta.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL BS:',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 13 : 12,
                            ),
                          ),
                          Text(
                            'Bs. ${totalBsVentaValido.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
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
  }

  Widget _columnaDetalle(String titulo, String valor, ThemeData theme, {Color? colorValor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 9,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colorValor ?? theme.textTheme.bodyLarge?.color,
          ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _celdaHeader(String texto, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _celdaBody(String texto, {bool alignLeft = false, bool esBold = false, required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        texto,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: esBold ? FontWeight.bold : FontWeight.normal,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Future<void> _exportarCSV() async {
    if (_ventasFiltradas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ventas para exportar en el período seleccionado.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('ID Venta;Fecha;Empleado;Método Pago;Total USD;Total Bs.');

      for (var venta in _ventasFiltradas) {
        final fechaLocal = venta.fecha.toLocal();
        final String fechaStr = '${fechaLocal.day}/${fechaLocal.month}/${fechaLocal.year} ${fechaLocal.hour}:${fechaLocal.minute}';
        final double tasaVentaValida = (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
        final double totalBsVentaValido = (venta.totalBolivares.isNaN || venta.totalBolivares <= 0)
            ? (venta.total * tasaVentaValida)
            : venta.totalBolivares;

        buffer.writeln('${venta.ventaIdString};$fechaStr;${venta.empleado};${venta.metodoPago};${venta.total.toStringAsFixed(2)};${totalBsVentaValido.toStringAsFixed(2)}');
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
          const SnackBar(content: Text('¡Archivo CSV exportado correctamente!'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar CSV: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isSmallMobile = isMobile && MediaQuery.of(context).size.width < 400;

    final double hPadding = isSmallMobile ? 2.0 : (isTablet ? 20.0 : 12.0);
    final double vPadding = isSmallMobile ? 2.0 : (isTablet ? 20.0 : 12.0);
    final double fontSizeTitle = isSmallMobile ? 16 : (isTablet ? 22 : 18);
    final double fontSizeResumenValor = isSmallMobile ? 14 : (isTablet ? 20 : 14);
    final double fontSizeResumenTitulo = isSmallMobile ? 9 : (isTablet ? 13 : 11);
    final double fontSizeVenta = isSmallMobile ? 11 : (isTablet ? 17 : 14);
    final double fontSizeVentaDetalle = isSmallMobile ? 9 : (isTablet ? 13 : 11);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Historial de Transacciones',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeTitle),
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
                  // FILTROS DE PERIODO
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _botonPeriodo('dia', 'Hoy', Icons.today, theme, isSmallMobile),
                        SizedBox(width: isSmallMobile ? 4 : 8),
                        _botonPeriodo('semana', 'Semana', Icons.date_range, theme, isSmallMobile),
                        SizedBox(width: isSmallMobile ? 4 : 8),
                        _botonPeriodo('mes', 'Mes', Icons.calendar_month, theme, isSmallMobile),
                        SizedBox(width: isSmallMobile ? 4 : 8),
                        _botonPeriodo('anio', 'Año', Icons.calendar_today, theme, isSmallMobile),
                        SizedBox(width: isSmallMobile ? 4 : 8),
                        _botonPeriodo('todos', 'Todas', Icons.all_inclusive, theme, isSmallMobile),
                      ],
                    ),
                  ),

                  // SELECTORES DE MES/AÑO
                  if (_periodoSeleccionado == 'mes') ...[
                    SizedBox(height: isSmallMobile ? 6 : 12),
                    isSmallMobile
                        ? Column(
                            children: [
                              _buildDropdownMes(theme, isSmallMobile, isTablet),
                              const SizedBox(height: 6),
                              _buildDropdownAnio(theme, isSmallMobile, isTablet),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _buildDropdownMes(theme, isSmallMobile, isTablet)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildDropdownAnio(theme, isSmallMobile, isTablet)),
                            ],
                          ),
                  ] else if (_periodoSeleccionado == 'anio') ...[
                    SizedBox(height: isSmallMobile ? 6 : 12),
                    _buildDropdownAnio(theme, isSmallMobile, isTablet),
                  ],
                  SizedBox(height: isSmallMobile ? 8 : 16),

                  // TARJETAS DE RESUMEN
                  isSmallMobile
                      ? Column(
                          children: [
                            _tarjetaResumen('Ventas', '${_ventasFiltradas.length}', Icons.receipt_long, const Color(0xFF3B82F6), isSmallMobile, isTablet, theme),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: _tarjetaResumen('Total USD', '\$${_totalUSD.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF10B981), isSmallMobile, isTablet, theme),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: _tarjetaResumen('Total Bs.', 'Bs. ${_totalBs.toStringAsFixed(2)}', Icons.currency_exchange, const Color(0xFF0284C7), isSmallMobile, isTablet, theme),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _tarjetaResumen('Ventas', '${_ventasFiltradas.length}', Icons.receipt_long, const Color(0xFF3B82F6), isSmallMobile, isTablet, theme),
                            _tarjetaResumen('Total USD', '\$${_totalUSD.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF10B981), isSmallMobile, isTablet, theme),
                            _tarjetaResumen('Total Bs.', 'Bs. ${_totalBs.toStringAsFixed(2)}', Icons.currency_exchange, const Color(0xFF0284C7), isSmallMobile, isTablet, theme),
                          ],
                        ),
                  SizedBox(height: isSmallMobile ? 8 : 16),

                  // BARRA DE BÚSQUEDA Y FILTRO DE MÉTODO DE PAGO
                  Container(
                    padding: EdgeInsets.all(isSmallMobile ? 8.0 : (isTablet ? 16.0 : 12.0)),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: isSmallMobile ? 36 : (isTablet ? 48 : 40),
                          child: TextField(
                            onChanged: (val) {
                              _searchQuery = val;
                              _aplicarFiltros();
                            },
                            style: TextStyle(fontSize: isSmallMobile ? 12 : (isTablet ? 15 : 13), color: theme.textTheme.bodyLarge?.color),
                            decoration: InputDecoration(
                              hintText: isSmallMobile ? 'Buscar...' : 'Buscar por ID, Cédula o Empleado...',
                              hintStyle: TextStyle(
                                fontSize: isSmallMobile ? 11 : (isTablet ? 15 : 13),
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: isSmallMobile ? 16 : (isTablet ? 24 : 20),
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallMobile ? 4 : 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _metodos.map((metodo) {
                              final bool esSeleccionado = _metodoSeleccionado == metodo;
                              return Padding(
                                padding: EdgeInsets.only(right: isSmallMobile ? 4.0 : 8.0),
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
                                      horizontal: isSmallMobile ? 6 : (isTablet ? 14 : 10),
                                      vertical: isSmallMobile ? 4 : (isTablet ? 8 : 6),
                                    ),
                                    decoration: BoxDecoration(
                                      color: esSeleccionado
                                          ? (theme.brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFF0F172A))
                                          : theme.cardColor,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: esSeleccionado
                                            ? (theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFF0F172A))
                                            : (theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    child: Text(
                                      metodo,
                                      style: TextStyle(
                                        fontSize: isSmallMobile ? 9 : (isTablet ? 14 : 12),
                                        fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                                        color: esSeleccionado
                                            ? (theme.brightness == Brightness.dark ? Colors.white : Colors.white)
                                            : (theme.brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF475569)),
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
                  SizedBox(height: isSmallMobile ? 8 : 16),

                  // LISTA DE VENTAS (MÁS ANCHA EN MÓVIL PEQUEÑO)
                  Expanded(
                    child: _ventasFiltradas.isEmpty
                        ? Center(
                            child: Text(
                              'No hay ventas registradas.',
                              style: TextStyle(
                                fontSize: isSmallMobile ? 13 : (isTablet ? 16 : 14),
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _ventasFiltradas.length,
                            separatorBuilder: (_, __) => SizedBox(height: isSmallMobile ? 4 : 12),
                            itemBuilder: (context, index) {
                              final venta = _ventasFiltradas[index];
                              final fechaLocal = venta.fecha.toLocal();
                              final String fechaFormatted = '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year.toString()} - ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
                              final double tasaVentaValida = (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
                              final double totalBsVentaValido = (venta.totalBolivares.isNaN || venta.totalBolivares <= 0) ? (venta.total * tasaVentaValida) : venta.totalBolivares;

                              return InkWell(
                                onTap: () => _mostrarModalDetalleVenta(context, venta),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallMobile ? 4 : (isTablet ? 20 : 16),
                                    vertical: isSmallMobile ? 4 : (isTablet ? 16 : 12),
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Icono
                                      Container(
                                        width: isSmallMobile ? 24 : (isTablet ? 48 : 40),
                                        height: isSmallMobile ? 24 : (isTablet ? 48 : 40),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.article_outlined,
                                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                          size: isSmallMobile ? 12 : (isTablet ? 28 : 22),
                                        ),
                                      ),
                                      SizedBox(width: isSmallMobile ? 4 : 16),

                                      // Columna de texto
                                      Expanded(
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
                                                      fontSize: fontSizeVenta,
                                                      color: theme.textTheme.bodyLarge?.color,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isSmallMobile) ...[
                                                  const SizedBox(width: 2),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFE0F2FE),
                                                      borderRadius: BorderRadius.circular(2),
                                                      border: Border.all(color: const Color(0xFFBAE6FD)),
                                                    ),
                                                    child: Text(
                                                      'Bs. ${tasaVentaValida.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 6,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF0369A1),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 1),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    '$fechaFormatted • ${venta.empleado}',
                                                    style: TextStyle(
                                                      fontSize: fontSizeVentaDetalle,
                                                      color: theme.textTheme.bodyMedium?.color,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isSmallMobile && venta.metodoPago.isNotEmpty) ...[
                                                  const SizedBox(width: 2),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFECFDF5),
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                    child: Text(
                                                      venta.metodoPago.substring(0, 1).toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 7,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xFF059669),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Badge del método de pago (solo en desktop/tablet)
                                      if (!isSmallMobile) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            venta.metodoPago,
                                            style: TextStyle(
                                              fontSize: isTablet ? 13 : 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF059669),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: isSmallMobile ? 4 : 16),
                                      ],

                                      // Totales
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${venta.total.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: isSmallMobile ? 11 : (isTablet ? 18 : 15),
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF059669),
                                            ),
                                          ),
                                          Text(
                                            'Bs. ${totalBsVentaValido.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: isSmallMobile ? 8 : (isTablet ? 13 : 11),
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0284C7),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Flecha
                                      SizedBox(width: isSmallMobile ? 2 : 12),
                                      Icon(
                                        Icons.chevron_right,
                                        color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                                        size: isSmallMobile ? 12 : (isTablet ? 26 : 20),
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

  Widget _buildDropdownMes(ThemeData theme, bool isSmallMobile, bool isTablet) {
    return Container(
      height: isSmallMobile ? 36 : (isTablet ? 48 : 40),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _mesSeleccionadoDropdown,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)),
          style: TextStyle(
            fontSize: isSmallMobile ? 11 : (isTablet ? 15 : 13),
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: theme.cardColor,
          items: _listaMesesDropdown.map((mes) => DropdownMenuItem(
            value: mes,
            child: Text(mes == 'Actual' ? 'Mes Actual' : mes),
          )).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _mesSeleccionadoDropdown = val);
              _aplicarFiltros();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdownAnio(ThemeData theme, bool isSmallMobile, bool isTablet) {
    return Container(
      height: isSmallMobile ? 36 : (isTablet ? 48 : 40),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _anioSeleccionadoDropdown,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)),
          style: TextStyle(
            fontSize: isSmallMobile ? 11 : (isTablet ? 15 : 13),
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: theme.cardColor,
          items: _listaAniosDisponibles.map((anio) => DropdownMenuItem(
            value: anio,
            child: Text('$anio${anio == DateTime.now().year ? ' (Actual)' : ''}'),
          )).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _anioSeleccionadoDropdown = val);
              _aplicarFiltros();
            }
          },
        ),
      ),
    );
  }

  Widget _botonPeriodo(String clave, String titulo, IconData icono, ThemeData theme, bool isSmallMobile) {
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
          vertical: isSmallMobile ? 4 : (isTablet ? 12 : 8),
          horizontal: isSmallMobile ? 6 : (isTablet ? 16 : 12),
        ),
        decoration: BoxDecoration(
          color: seleccionado
              ? (theme.brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFF0F172A))
              : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado
                ? (theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFF0F172A))
                : (theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: isSmallMobile ? 12 : (isTablet ? 16 : 13),
              color: seleccionado
                  ? Colors.white
                  : (theme.brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF475569)),
            ),
            SizedBox(width: isSmallMobile ? 2 : 4),
            Flexible(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmallMobile ? 8 : (isTablet ? 14 : 11),
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                  color: seleccionado
                      ? Colors.white
                      : (theme.brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaResumen(String titulo, String valor, IconData icono, Color color, bool isSmallMobile, bool isTablet, ThemeData theme) {
    final double size = isSmallMobile ? 14 : (isTablet ? 18.0 : 14.0);
    final double fontSizeValor = isSmallMobile ? 14 : (isTablet ? 20 : 14);
    final double fontSizeTitulo = isSmallMobile ? 9 : (isTablet ? 13 : 11);

    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 8.0 : (isTablet ? 14.0 : 12.0)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: isSmallMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: size),
          ),
          SizedBox(width: isSmallMobile ? 6 : 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: fontSizeTitulo,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              Text(
                valor,
                style: TextStyle(
                  fontSize: fontSizeValor,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}