import 'package:flutter/material.dart';
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

  // Variables para el filtro de Mes específico
  String _mesSeleccionadoDropdown = 'Actual';
  final List<String> _listaMesesDropdown = [
    'Actual', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  // Variables para el filtro de Año dinámico
  int _anioSeleccionadoDropdown = DateTime.now().year;
  List<int> _listaAniosDisponibles = [];

  // Acumuladores de totales
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

  void _mostrarModalDetalleVenta(BuildContext context, VentaEntity venta) {
    final fechaLocal = venta.fecha.toLocal();
    final String fechaFormatted = '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year.toString()} - ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
    final double tasaVentaValida = (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
    final double totalBsVentaValido = (venta.totalBolivares.isNaN || venta.totalBolivares <= 0)
        ? (venta.total * tasaVentaValida)
        : venta.totalBolivares;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 600,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.receipt_long, color: Colors.white, size: 20)),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Venta #${venta.ventaIdString}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                          Text(fechaFormatted, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ]),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const Divider(height: 24),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _columnaDetalle('Cliente', venta.documento.isEmpty ? 'N/A' : venta.documento),
                  _columnaDetalle('Atendido por', venta.empleado),
                  _columnaDetalle('Método', venta.metodoPago),
                  _columnaDetalle('Sincronizado', venta.sincronizado ? 'Sí' : 'No', colorValor: venta.sincronizado ? const Color(0xFF059669) : const Color(0xFFD97706)),
                ])),
                const SizedBox(height: 16),
                const Text('Detalle de Productos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))), child: Table(columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1.5)}, children: [
                      TableRow(decoration: const BoxDecoration(color: Color(0xFFF1F5F9)), children: [_celdaHeader('Producto'), _celdaHeader('Cant.'), _celdaHeader('Precio (\$)'), _celdaHeader('Subtotal (\$)')]),
                      ...venta.items.map((item) => TableRow(children: [_celdaBody(item.nombreProducto, alignLeft: true), _celdaBody(item.cantidad.toStringAsFixed(item.cantidad % 1 == 0 ? 0 : 3)), _celdaBody('\$${item.precioUnidad.toStringAsFixed(2)}'), _celdaBody('\$${item.subtotal.toStringAsFixed(2)}', esBold: true)])),
                    ])),
                  ),
                ),
                const SizedBox(height: 16),
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)), child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal USD:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)), Text('\$${venta.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12))]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Impuesto (IVA USD):', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)), Text('\$${venta.impuesto.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12))]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tasa BCV:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)), Text('Bs. ${tasaVentaValida.toStringAsFixed(2)} / \$', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold))]),
                  const Divider(color: Color(0xFF334155), height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL USD:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text('\$${venta.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 17))]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL BS:', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12)), Text('Bs. ${totalBsVentaValido.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 15))]),
                ])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _columnaDetalle(String titulo, String valor, {Color? colorValor}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))), const SizedBox(height: 2), Text(valor, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorValor ?? const Color(0xFF0F172A)))]);

  // CORREGIDO: Se eliminaron los paréntesis y punto y coma extra al final.
  Widget _celdaHeader(String texto) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Text(
      texto,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
    ),
  );

  Widget _celdaBody(String texto, {bool alignLeft = false, bool esBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Text(
      texto,
      textAlign: alignLeft ? TextAlign.left : TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: esBold ? FontWeight.bold : FontWeight.normal,
        color: const Color(0xFF0F172A),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    // ignore: unused_local_variable
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Historial de Transacciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromRGBO(122, 153, 255, 1), Color.fromARGB(255, 85, 59, 235)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), tooltip: 'Actualizar Historial', onPressed: _cargarVentas), const SizedBox(width: 8)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // FILTROS DE PERIODO (Responsivos con SingleChildScrollView)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _botonPeriodo('dia', 'Hoy', Icons.today),
                        const SizedBox(width: 8),
                        _botonPeriodo('semana', 'Semana', Icons.date_range),
                        const SizedBox(width: 8),
                        _botonPeriodo('mes', 'Mes', Icons.calendar_month),
                        const SizedBox(width: 8),
                        _botonPeriodo('anio', 'Año', Icons.calendar_today),
                        const SizedBox(width: 8),
                        _botonPeriodo('todos', 'Todas', Icons.all_inclusive),
                      ],
                    ),
                  ),
                  // SELECTORES DE MES/AÑO
                  if (_periodoSeleccionado == 'mes') ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF10B981), width: 1.5)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, value: _mesSeleccionadoDropdown, icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)), style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600), items: _listaMesesDropdown.map((mes) => DropdownMenuItem(value: mes, child: Text(mes == 'Actual' ? 'Mes Actual' : mes))).toList(), onChanged: (val) { if (val != null) { setState(() => _mesSeleccionadoDropdown = val); _aplicarFiltros(); } }))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF10B981), width: 1.5)), child: DropdownButtonHideUnderline(child: DropdownButton<int>(isExpanded: true, value: _anioSeleccionadoDropdown, icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)), style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600), items: _listaAniosDisponibles.map((anio) => DropdownMenuItem(value: anio, child: Text('$anio${anio == DateTime.now().year ? ' (Actual)' : ''}'))).toList(), onChanged: (val) { if (val != null) { setState(() => _anioSeleccionadoDropdown = val); _aplicarFiltros(); } }))),
                        ),
                      ],
                    )
                  ] else if (_periodoSeleccionado == 'anio') ...[
                    const SizedBox(height: 10),
                    Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF10B981), width: 1.5)), child: DropdownButtonHideUnderline(child: DropdownButton<int>(isExpanded: true, value: _anioSeleccionadoDropdown, icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981)), style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600), items: _listaAniosDisponibles.map((anio) => DropdownMenuItem(value: anio, child: Text('$anio${anio == DateTime.now().year ? ' (Actual)' : ''}'))).toList(), onChanged: (val) { if (val != null) { setState(() => _anioSeleccionadoDropdown = val); _aplicarFiltros(); } }))),
                  ],
                  const SizedBox(height: 12),
                  // TARJETAS DE RESUMEN
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _tarjetaResumen('Ventas', '${_ventasFiltradas.length}', Icons.receipt_long, const Color(0xFF3B82F6), isMobile),
                      _tarjetaResumen('Total USD', '\$${_totalUSD.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF10B981), isMobile),
                      _tarjetaResumen('Total Bs.', 'Bs. ${_totalBs.toStringAsFixed(2)}', Icons.currency_exchange, const Color(0xFF0284C7), isMobile),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // BARRA DE BÚSQUEDA Y FILTRO DE MÉTODO DE PAGO
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: TextField(
                            onChanged: (val) { _searchQuery = val; _aplicarFiltros(); },
                            decoration: InputDecoration(
                              hintText: 'Buscar por ID, Cédula o Empleado...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // CHIPS DE MÉTODO DE PAGO
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _metodos.map((metodo) {
                              final bool esSeleccionado = _metodoSeleccionado == metodo;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () { setState(() { _metodoSeleccionado = metodo; }); _aplicarFiltros(); },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: esSeleccionado ? const Color(0xFF0F172A) : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: esSeleccionado ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1)),
                                    ),
                                    child: Text(metodo, style: TextStyle(fontSize: 12, fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal, color: esSeleccionado ? Colors.white : const Color(0xFF475569))),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // LISTA DE VENTAS
                  Expanded(
                    child: _ventasFiltradas.isEmpty
                        ? const Center(child: Text('No hay ventas registradas en el periodo seleccionado.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)))
                        : ListView.separated(
                            itemCount: _ventasFiltradas.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                  child: Row(
                                    children: [
                                      Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.article_outlined, color: Color(0xFF334155), size: 22)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Row(children: [
                                            Text('Venta #${venta.ventaIdString}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                            const SizedBox(width: 8),
                                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFBAE6FD))), child: Text('Tasa: Bs. ${tasaVentaValida.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))))
                                          ]),
                                          const SizedBox(height: 4),
                                          Text('$fechaFormatted • Atendido por: ${venta.empleado}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                        ]),
                                      ),
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)), child: Text(venta.metodoPago.toLowerCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)))),
                                      const SizedBox(width: 16),
                                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                        Text('\$${venta.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                        Text('Bs. ${totalBsVentaValido.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                      ]),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
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

  Widget _botonPeriodo(String clave, String titulo, IconData icono) {
    final bool seleccionado = _periodoSeleccionado == clave;
    return InkWell(
      onTap: () { setState(() { _periodoSeleccionado = clave; }); _aplicarFiltros(); },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: seleccionado ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 13, color: seleccionado ? Colors.white : const Color(0xFF475569)),
            const SizedBox(width: 4),
            // CORREGIDO: Se eliminó el paréntesis de cierre extra que sobraba
            Flexible(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
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
  Widget _tarjetaResumen(String titulo, String valor, IconData icono, Color color, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icono, color: color, size: 18)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ]),
        ],
      ),
    );
  }
}