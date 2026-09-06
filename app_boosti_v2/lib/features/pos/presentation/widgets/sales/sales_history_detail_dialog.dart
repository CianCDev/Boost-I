import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/venta_entity.dart';
import '../../../data/Local/entities/detalle_venta_entity.dart';
import '../../utils/responsive_helper.dart';

class SalesHistoryDetailDialog extends StatefulWidget {
  final VentaEntity venta;

  const SalesHistoryDetailDialog({super.key, required this.venta});

  @override
  State<SalesHistoryDetailDialog> createState() => _SalesHistoryDetailDialogState();
}

class _SalesHistoryDetailDialogState extends State<SalesHistoryDetailDialog> {
  final IsarService _isarService = IsarService();
  late Future<List<DetalleVentaEntity>> _detallesFuture;

  // Acorta el ID para móviles
  String _shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 12)}...';
  }

  @override
  void initState() {
    super.initState();
    _detallesFuture = _cargarDetalles();
  }

  Future<List<DetalleVentaEntity>> _cargarDetalles() async {
    if (widget.venta.items.isNotEmpty) {
      return widget.venta.items.cast<DetalleVentaEntity>().toList();
    } else {
      final ventaId = widget.venta.idSupabase;
      if (ventaId == null || ventaId.isEmpty) return [];
      return await _isarService.obtenerDetallesPorVenta(ventaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !ResponsiveHelper.isMobile(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final venta = widget.venta;
    final fechaLocal = (venta.fecha ?? DateTime.now()).toLocal();
    final String fechaFormatted =
        '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year.toString()} - '
        '${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
    final double tasaVentaValida =
        (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
    final double totalBsVentaValido =
        (venta.totalBolivares.isNaN || venta.totalBolivares <= 0)
            ? (venta.total * tasaVentaValida)
            : venta.totalBolivares;

    final Map<String, Color> coloresMetodo = {
      'Efectivo': const Color(0xFF10B981),
      'Tarjeta': const Color(0xFF3B82F6),
      'Pago Móvil': const Color(0xFF8B5CF6),
      'Divisas': const Color(0xFFF59E0B),
    };
    final Map<String, IconData> iconosMetodo = {
      'Efectivo': Icons.money_rounded,
      'Tarjeta': Icons.credit_card_rounded,
      'Pago Móvil': Icons.phone_android_rounded,
      'Divisas': Icons.currency_exchange_rounded,
    };
    final Color colorMetodo = coloresMetodo[venta.metodoPago] ?? Colors.grey;
    final IconData iconMetodo = iconosMetodo[venta.metodoPago] ?? Icons.more_horiz_rounded;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: isLargeScreen ? 820 : MediaQuery.of(context).size.width * 0.94,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          minHeight: 420,
        ),
        decoration: BoxDecoration(
          // 🧊 Glassmorphism: fondo semi-transparente con desenfoque
          color: isDark
              ? Colors.grey[900]!.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 2,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: isDark
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: FutureBuilder<List<DetalleVentaEntity>>(
                future: _detallesFuture,
                builder: (context, snapshot) {
                  final detalles = snapshot.data ?? [];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- CABECERA MODERNA ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.primary.withValues(alpha: 0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Tooltip(
                                    message: 'ID completo: ${venta.ventaIdString}',
                                    child: Text(
                                      'Venta #${_shortId(venta.ventaIdString)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isLargeScreen ? 22 : 17,
                                        color: colorScheme.onSurface,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: isLargeScreen ? 14 : 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        fechaFormatted,
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 14 : 12,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: 28,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            splashRadius: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ---- TABS CON GLASSMORPHISM ----
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TabBar(
                                  indicator: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  labelColor: colorScheme.primary,
                                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                                  labelStyle: TextStyle(
                                    fontSize: isLargeScreen ? 15 : 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontSize: isLargeScreen ? 15 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  tabs: const [
                                    Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Productos'),
                                    Tab(icon: Icon(Icons.summarize_outlined), text: 'Resumen'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildProductosTab(detalles, isLargeScreen, colorScheme, isDark),
                                    _buildResumenTab(
                                      venta,
                                      detalles,
                                      fechaFormatted,
                                      colorMetodo,
                                      iconMetodo,
                                      tasaVentaValida,
                                      totalBsVentaValido,
                                      isLargeScreen,
                                      colorScheme,
                                      isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== TAB 1: PRODUCTOS =====================

  Widget _buildProductosTab(
    List<DetalleVentaEntity> detalles,
    bool isLargeScreen,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Detalle de productos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 18 : 15,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${detalles.length} ítems',
                style: TextStyle(
                  fontSize: isLargeScreen ? 13 : 11,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(
                minWidth: isLargeScreen ? 600 : 320,
                maxWidth: isLargeScreen ? double.infinity : 320,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3.5),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    children: [
                      _buildHeaderCell('Producto', isLargeScreen, colorScheme),
                      _buildHeaderCell('Cant.', isLargeScreen, colorScheme),
                      _buildHeaderCell('Precio', isLargeScreen, colorScheme),
                      _buildHeaderCell('Subtotal', isLargeScreen, colorScheme),
                    ],
                  ),
                  if (detalles.isEmpty)
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'Sin productos',
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 15 : 13,
                                  color: colorScheme.onSurfaceVariant,
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
                    ...detalles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final tieneDescuento = item.esDescuentoEspecial == true;

                      return TableRow(
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? Colors.transparent
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.black.withValues(alpha: 0.015)),
                        ),
                        children: [
                          // Producto
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.nombreProducto,
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 14 : 12,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (tieneDescuento) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Dscto.',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (tieneDescuento && item.precioOriginal != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${item.precioOriginal!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '\$${item.precioUnidad.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Cantidad
                          _buildBodyCell(
                            item.cantidad.toStringAsFixed(item.cantidad % 1 == 0 ? 0 : 3),
                            isLargeScreen,
                            colorScheme,
                          ),
                          // Precio
                          _buildBodyCell(
                            '\$${item.precioUnidad.toStringAsFixed(2)}',
                            isLargeScreen,
                            colorScheme,
                          ),
                          // Subtotal
                          _buildBodyCell(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            isLargeScreen,
                            colorScheme,
                            esBold: true,
                          ),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== TAB 2: RESUMEN =====================

  Widget _buildResumenTab(
    VentaEntity venta,
    List<DetalleVentaEntity> detalles,
    String fechaFormatted,
    Color colorMetodo,
    IconData iconMetodo,
    double tasaVentaValida,
    double totalBsVentaValido,
    bool isLargeScreen,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isMobile = !isLargeScreen;
    final tieneDescuentoGlobal = venta.tieneDescuentoEspecial == true && venta.montoDescuentoTotal > 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- TARJETA DE INFORMACIÓN (Glassmorphism) ----
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      _buildInfoRow(
                        label: 'Cliente',
                        value: venta.documento == 0 ? 'N/A' : venta.documento.toString(),
                        icon: Icons.person_outline,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        label: 'Atendido por',
                        value: venta.empleadoNombre,
                        icon: Icons.badge_outlined,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        label: 'Método de Pago',
                        value: venta.metodoPago,
                        icon: iconMetodo,
                        colorScheme: colorScheme,
                        iconColor: colorMetodo,
                        valueColor: colorMetodo,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        label: 'Fecha',
                        value: fechaFormatted,
                        icon: Icons.calendar_today_outlined,
                        colorScheme: colorScheme,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCard(
                        label: 'Cliente',
                        value: venta.documento == 0 ? 'N/A' : venta.documento.toString(),
                        icon: Icons.person_outline,
                        colorScheme: colorScheme,
                      ),
                      _buildInfoCard(
                        label: 'Atendido por',
                        value: venta.empleadoNombre,
                        icon: Icons.badge_outlined,
                        colorScheme: colorScheme,
                      ),
                      _buildInfoCard(
                        label: 'Método de Pago',
                        value: venta.metodoPago,
                        icon: iconMetodo,
                        colorScheme: colorScheme,
                        iconColor: colorMetodo,
                        valueColor: colorMetodo,
                      ),
                      _buildInfoCard(
                        label: 'Fecha',
                        value: fechaFormatted,
                        icon: Icons.calendar_today_outlined,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),

          // ---- TOTALES (Glassmorphism) ----
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.grey[900]!.withValues(alpha: 0.6),
                        Colors.grey[850]!.withValues(alpha: 0.8),
                      ]
                    : [
                        const Color(0xFF0F172A).withValues(alpha: 0.9),
                        const Color(0xFF1E293B).withValues(alpha: 0.95),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subtotal e IVA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTotalRow(
                      label: 'Subtotal USD',
                      value: '\$${venta.subtotal.toStringAsFixed(2)}',
                      colorScheme: colorScheme,
                      isLargeScreen: isLargeScreen,
                    ),
                    _buildTotalRow(
                      label: 'IVA USD',
                      value: '\$${venta.impuesto.toStringAsFixed(2)}',
                      colorScheme: colorScheme,
                      isLargeScreen: isLargeScreen,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Tasa BCV + Badge descuento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTotalRow(
                      label: 'Tasa BCV',
                      value: 'Bs. ${tasaVentaValida.toStringAsFixed(2)} / \$',
                      colorScheme: colorScheme,
                      isLargeScreen: isLargeScreen,
                      esDestacado: true,
                    ),
                    if (tieneDescuentoGlobal)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer_rounded,
                              color: Color(0xFFF59E0B),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Dscto: \$${venta.montoDescuentoTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 13 : 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Cantidad de ítems
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${detalles.length} ítems',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 13 : 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Divider(height: 20, color: Colors.white24),
                // TOTALES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTotalRow(
                      label: 'TOTAL USD',
                      value: '\$${venta.total.toStringAsFixed(2)}',
                      colorScheme: colorScheme,
                      isLargeScreen: isLargeScreen,
                      esTotal: true,
                    ),
                    _buildTotalRow(
                      label: 'TOTAL BS',
                      value: 'Bs. ${totalBsVentaValido.toStringAsFixed(2)}',
                      colorScheme: colorScheme,
                      isLargeScreen: isLargeScreen,
                      esTotal: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ===================== HELPER WIDGETS =====================

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: iconColor ?? colorScheme.primary,
          size: 26,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String texto, bool isLargeScreen, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isLargeScreen ? 13 : 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildBodyCell(
    String texto,
    bool isLargeScreen,
    ColorScheme colorScheme, {
    bool alignLeft = false,
    bool esBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        texto,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: isLargeScreen ? 14 : 12,
          fontWeight: esBold ? FontWeight.w700 : FontWeight.w500,
          color: esBold ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTotalRow({
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required bool isLargeScreen,
    bool esDestacado = false,
    bool esTotal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: esDestacado
                ? const Color(0xFF38BDF8)
                : (esTotal ? Colors.white : Colors.white70),
            fontSize: esTotal
                ? (isLargeScreen ? 14 : 13)
                : (isLargeScreen ? 13 : 11),
            fontWeight: esTotal ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: esTotal ? 0.5 : 0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: esDestacado
                ? const Color(0xFF38BDF8)
                : (esTotal ? const Color(0xFF34D399) : Colors.white),
            fontSize: esTotal
                ? (isLargeScreen ? 22 : 18)
                : (isLargeScreen ? 16 : 14),
            fontWeight: esTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}