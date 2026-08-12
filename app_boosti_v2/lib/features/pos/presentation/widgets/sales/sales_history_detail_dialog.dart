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

  @override
  void initState() {
    super.initState();
    _detallesFuture = _cargarDetalles();
  }

  Future<List<DetalleVentaEntity>> _cargarDetalles() async {
    if (widget.venta.items.isNotEmpty) {
      return widget.venta.items.cast<DetalleVentaEntity>().toList();
    } else {
      return await _isarService.obtenerDetallesPorVenta(widget.venta.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !ResponsiveHelper.isMobile(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final venta = widget.venta;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: isLargeScreen ? 820 : MediaQuery.of(context).size.width * 0.94,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          minHeight: 420,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
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
                // ---- CABECERA ----
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
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
                                  colorScheme.primary.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
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
                              Text(
                                'Venta #${venta.ventaIdString}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 22 : 17,
                                  color: colorScheme.onSurface,
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
                      Row(
                        children: [
                          if (isLargeScreen)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: venta.syncStatus == 'synced'
                                    ? colorScheme.primary.withValues(alpha: 0.12)
                                    : (venta.syncStatus == 'pending'
                                        ? const Color(0xFFFEF3C7)
                                        : colorScheme.error.withValues(alpha: 0.12)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: venta.syncStatus == 'synced'
                                      ? colorScheme.primary
                                      : (venta.syncStatus == 'pending'
                                          ? const Color(0xFFF59E0B)
                                          : colorScheme.error),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    venta.syncStatus == 'synced'
                                        ? Icons.check_circle_rounded
                                        : (venta.syncStatus == 'pending'
                                            ? Icons.hourglass_top_rounded
                                            : Icons.error_rounded),
                                    size: 16,
                                    color: venta.syncStatus == 'synced'
                                        ? colorScheme.primary
                                        : (venta.syncStatus == 'pending'
                                            ? const Color(0xFFF59E0B)
                                            : colorScheme.error),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    venta.syncStatus == 'synced'
                                        ? 'Sincronizado'
                                        : (venta.syncStatus == 'pending'
                                            ? 'Pendiente'
                                            : 'Fallida'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: venta.syncStatus == 'synced'
                                          ? colorScheme.primary
                                          : (venta.syncStatus == 'pending'
                                              ? const Color(0xFFF59E0B)
                                              : colorScheme.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant, size: 28),
                            onPressed: () => Navigator.of(context).pop(),
                            splashRadius: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ---- DATOS DEL CLIENTE ----
                Container(
                  padding: EdgeInsets.all(isMobile ? 14 : 18),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildInfoRowModern(
                              label: 'Cliente',
                              value: venta.documento.isEmpty ? 'N/A' : venta.documento,
                              icon: Icons.person_outline,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRowModern(
                              label: 'Atendido por',
                              value: venta.empleado,
                              icon: Icons.badge_outlined,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRowModern(
                              label: 'Método de Pago',
                              value: venta.metodoPago,
                              icon: iconMetodo,
                              colorScheme: colorScheme,
                              iconColor: colorMetodo,
                              valueColor: colorMetodo,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRowModern(
                              label: 'Sincronizado',
                              value: venta.syncStatus == 'synced'
                                  ? 'Sí ✓'
                                  : (venta.syncStatus == 'pending' ? '⏳ Pendiente' : '✗ Fallida'),
                              icon: venta.syncStatus == 'synced'
                                  ? Icons.check_circle_outline
                                  : (venta.syncStatus == 'pending'
                                      ? Icons.hourglass_empty
                                      : Icons.error_outline),
                              colorScheme: colorScheme,
                              iconColor: venta.syncStatus == 'synced'
                                  ? colorScheme.primary
                                  : (venta.syncStatus == 'pending'
                                      ? const Color(0xFFF59E0B)
                                      : colorScheme.error),
                              valueColor: venta.syncStatus == 'synced'
                                  ? colorScheme.primary
                                  : (venta.syncStatus == 'pending'
                                      ? const Color(0xFFF59E0B)
                                      : colorScheme.error),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCard(
                              label: 'Cliente',
                              value: venta.documento.isEmpty ? 'N/A' : venta.documento,
                              icon: Icons.person_outline,
                              colorScheme: colorScheme,
                            ),
                            _buildInfoCard(
                              label: 'Atendido por',
                              value: venta.empleado,
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
                          ],
                        ),
                ),
                const SizedBox(height: 18),

                // ---- TABLA DE PRODUCTOS ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalle de Productos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeScreen ? 18 : 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: isLargeScreen ? 600 : 320,
                        maxWidth: isLargeScreen ? double.infinity : 320,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.15),
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
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            children: [
                              _buildHeaderCellModern('Producto', isLargeScreen, colorScheme),
                              _buildHeaderCellModern('Cant.', isLargeScreen, colorScheme),
                              _buildHeaderCellModern('Precio', isLargeScreen, colorScheme),
                              _buildHeaderCellModern('Subtotal', isLargeScreen, colorScheme),
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
                            ...detalles.map((item) => TableRow(
                                  children: [
                                    _buildBodyCellModern(
                                      item.nombreProducto,
                                      isLargeScreen,
                                      colorScheme,
                                      alignLeft: true,
                                    ),
                                    _buildBodyCellModern(
                                      item.cantidad.toStringAsFixed(
                                          item.cantidad % 1 == 0 ? 0 : 3),
                                      isLargeScreen,
                                      colorScheme,
                                    ),
                                    _buildBodyCellModern(
                                      '\$${item.precioUnidad.toStringAsFixed(2)}',
                                      isLargeScreen,
                                      colorScheme,
                                    ),
                                    _buildBodyCellModern(
                                      '\$${item.subtotal.toStringAsFixed(2)}',
                                      isLargeScreen,
                                      colorScheme,
                                      esBold: true,
                                    ),
                                  ],
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ---- TOTALES (con colores mejorados para máxima legibilidad) ----
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              colorScheme.surfaceContainerHighest,
                              colorScheme.surfaceContainer,
                            ]
                          : [
                              const Color(0xFF0F172A),
                              const Color(0xFF1A2332),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTotalRowModern(
                            label: 'Subtotal USD',
                            value: '\$${venta.subtotal.toStringAsFixed(2)}',
                            colorScheme: colorScheme,
                            isLargeScreen: isLargeScreen,
                            isSubtotal: true,
                          ),
                          _buildTotalRowModern(
                            label: 'IVA USD',
                            value: '\$${venta.impuesto.toStringAsFixed(2)}',
                            colorScheme: colorScheme,
                            isLargeScreen: isLargeScreen,
                            isSubtotal: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTotalRowModern(
                            label: 'Tasa BCV',
                            value: 'Bs. ${tasaVentaValida.toStringAsFixed(2)} / \$',
                            colorScheme: colorScheme,
                            isLargeScreen: isLargeScreen,
                            esDestacado: true,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                            ),
                            child: Text(
                              'Tasa BCV',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 10 : 8,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: colorScheme.outline, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTotalRowModern(
                            label: 'TOTAL USD',
                            value: '\$${venta.total.toStringAsFixed(2)}',
                            colorScheme: colorScheme,
                            isLargeScreen: isLargeScreen,
                            esTotal: true,
                          ),
                          _buildTotalRowModern(
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
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- FUNCIONES HELPER ----
  Widget _buildInfoRowModern({
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
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
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
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCellModern(String texto, bool isLargeScreen, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isLargeScreen ? 13 : 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBodyCellModern(
    String texto,
    bool isLargeScreen,
    ColorScheme colorScheme, {
    bool alignLeft = false,
    bool esBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  // ✅ Función de totales con colores mejorados para máxima legibilidad
  Widget _buildTotalRowModern({
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required bool isLargeScreen,
    bool esDestacado = false,
    bool esTotal = false,
    bool isSubtotal = false,
  }) {
    Color textColor;
    Color valueColor;

    if (esDestacado) {
      // Tasa BCV: azul fijo
      textColor = const Color(0xFF38BDF8);
      valueColor = const Color(0xFF38BDF8);
    } else if (esTotal) {
      // TOTAL USD y TOTAL BS: etiqueta blanca, valor verde
      textColor = Colors.white;
      valueColor = const Color(0xFF10B981);
    } else if (isSubtotal) {
      // Subtotal e IVA: etiqueta gris claro, valor blanco
      textColor = Colors.white70;
      valueColor = Colors.white;
    } else {
      // Fallback
      textColor = Colors.white70;
      valueColor = Colors.white;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: esTotal ? (isLargeScreen ? 14 : 13) : (isLargeScreen ? 13 : 11),
            fontWeight: esTotal ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: esTotal ? 0.5 : 0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: esTotal ? (isLargeScreen ? 20 : 18) : (isLargeScreen ? 16 : 14),
            fontWeight: esTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}