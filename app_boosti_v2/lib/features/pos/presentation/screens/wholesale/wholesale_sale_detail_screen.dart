// lib/features/pos/presentation/screens/wholesale/wholesale_sale_detail_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/autorizacion_descuento_entity.dart';
import '../../../data/Local/entities/detalle_venta_entity.dart';
import '../../../data/Local/entities/pago_venta_entity.dart';
import '../../../data/Local/entities/venta_entity.dart';
import '../../providers/esc_pos_provider.dart';
import '../../providers/isar_provider.dart';
import '../../services/ticket_service.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/status_badge.dart';

class WholesaleSaleDetailScreen extends ConsumerStatefulWidget {
  final VentaEntity venta;

  const WholesaleSaleDetailScreen({super.key, required this.venta});

  @override
  ConsumerState<WholesaleSaleDetailScreen> createState() =>
      _WholesaleSaleDetailScreenState();
}

class _WholesaleSaleDetailScreenState
    extends ConsumerState<WholesaleSaleDetailScreen> {
  // ── Colores por tier ──
  static const _colorMayor = Color(0xFF10B981);
  static const _colorMedio = Color(0xFF3B82F6);
  static const _colorDetal = Color(0xFF64748B);
  static const _colorDescuento = Color(0xFFF59E0B);
  static const _colorAuth = Color(0xFFEF4444);

  bool _cargando = true;
  List<DetalleVentaEntity> _detalles = [];
  List<PagoVentaEntity> _pagos = [];
  List<AutorizacionDescuentoEntity> _autorizaciones = [];

  VentaEntity get venta => widget.venta;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  // ══════════════════════════════════════════════════════════════
  // CARGA
  // ══════════════════════════════════════════════════════════════

  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);
    try {
      final isar = ref.read(isarServiceProvider);
      final ventaSupabaseId = venta.idSupabase ?? '';

      final detalles = ventaSupabaseId.isEmpty
          ? <DetalleVentaEntity>[]
          : await isar.obtenerDetallesPorVenta(ventaSupabaseId);

      final pagos = ventaSupabaseId.isEmpty
          ? <PagoVentaEntity>[]
          : await isar.obtenerPagosPorVentaSupabaseId(ventaSupabaseId);

      final autorizaciones =
          await isar.obtenerAutorizacionesPorVenta(venta.id);

      if (!mounted) return;
      setState(() {
        _detalles = detalles;
        _pagos = pagos;
        _autorizaciones = autorizaciones;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando detalle: $e');
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Detalle de venta',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Reimprimir ticket',
            onPressed: _cargando ? null : _reimprimirTicket,
            icon: const Icon(Icons.print_rounded, size: 22),
            color: Colors.white,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: _colorMayor),
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView(
                    padding: EdgeInsets.all(isMobile ? 12 : 20),
                    children: [
                      _buildHeaderCard(cs, isMobile),
                      const SizedBox(height: 12),
                      _buildResumenCard(cs, isMobile),
                      const SizedBox(height: 12),
                      _buildItemsCard(cs, isMobile),
                      if (_pagos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildPagosCard(cs, isMobile),
                      ],
                      if (_autorizaciones.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildAutorizacionesCard(cs, isMobile),
                      ],
                      const SizedBox(height: 20),
                      _buildAcciones(cs, isMobile),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HEADER CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildHeaderCard(ColorScheme cs, bool isMobile) {
    final fecha = venta.fecha;
    final fechaStr = fecha != null
        ? '${fecha.day.toString().padLeft(2, '0')}/'
            '${fecha.month.toString().padLeft(2, '0')}/'
            '${fecha.year} '
            '${fecha.hour.toString().padLeft(2, '0')}:'
            '${fecha.minute.toString().padLeft(2, '0')}'
        : '—';

    final esNota = venta.tipoDocumento == 'nota_entrega';
    final tipoDocLabel = esNota ? 'Nota de entrega' : 'Factura';

    return _card(
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Título con ícono ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _colorMayor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  esNota
                      ? Icons.description_outlined
                      : Icons.receipt_long_rounded,
                  color: _colorMayor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tipoDocLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: 'MAYOR',
                          color: _colorMayor,
                          icon: Icons.workspace_premium_rounded,
                          size: StatusBadgeSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#${_shortId(venta.idSupabase)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 14),

          // ── Grid de datos ──
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _infoBlock(
                icon: Icons.calendar_today_rounded,
                label: 'Fecha',
                value: fechaStr,
                cs: cs,
              ),
              _infoBlock(
                icon: Icons.person_outline_rounded,
                label: 'Cliente',
                value: venta.clienteNombre ?? 'Sin cliente',
                cs: cs,
              ),
              if ((venta.clienteRif ?? '').isNotEmpty)
                _infoBlock(
                  icon: Icons.badge_outlined,
                  label: 'RIF',
                  value: venta.clienteRif!,
                  cs: cs,
                ),
              if ((venta.clienteRazonSocial ?? '').isNotEmpty)
                _infoBlock(
                  icon: Icons.business_rounded,
                  label: 'Razón social',
                  value: venta.clienteRazonSocial!,
                  cs: cs,
                ),
              if ((venta.clienteDocumento ?? '').isNotEmpty)
                _infoBlock(
                  icon: Icons.assignment_ind_outlined,
                  label: 'Documento',
                  value: venta.clienteDocumento!,
                  cs: cs,
                ),
              _infoBlock(
                icon: Icons.person_pin_rounded,
                label: 'Empleado',
                value: venta.empleado,
                cs: cs,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // RESUMEN CARD (totales)
  // ══════════════════════════════════════════════════════════════

  Widget _buildResumenCard(ColorScheme cs, bool isMobile) {
    final tieneDescuentos = venta.montoDescuentoTotal > 0.01;

    return _card(
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            icon: Icons.summarize_rounded,
            title: 'Resumen',
            cs: cs,
          ),
          const SizedBox(height: 14),

          _filaResumen('Subtotal', '\$${venta.subtotal.toStringAsFixed(2)}', cs),

          if (tieneDescuentos) ...[
            const SizedBox(height: 6),
            _filaResumen(
              'Descuentos'
              '${venta.montoDescuentoPorcentaje > 0 ? " (${venta.montoDescuentoPorcentaje.toStringAsFixed(0)}% global)" : ""}',
              '-\$${venta.montoDescuentoTotal.toStringAsFixed(2)}',
              cs,
              color: _colorDescuento,
            ),
          ],

          const SizedBox(height: 6),
          _filaResumen('IVA', '\$${venta.impuesto.toStringAsFixed(2)}', cs),

          const SizedBox(height: 12),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),

          // Total
          Row(
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '\$${venta.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _colorMayor,
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
            ],
          ),

          if (venta.tasaBcv > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.currency_exchange_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Bs. ${(venta.total * venta.tasaBcv).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '@ ${venta.tasaBcv.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ITEMS CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildItemsCard(ColorScheme cs, bool isMobile) {
    return _card(
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Productos (${_detalles.length})',
            cs: cs,
          ),
          const SizedBox(height: 14),
          if (_detalles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay items registrados',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < _detalles.length; i++) ...[
              _buildItemRow(_detalles[i], cs, isMobile),
              if (i < _detalles.length - 1) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  Widget _buildItemRow(
    DetalleVentaEntity d,
    ColorScheme cs,
    bool isMobile,
  ) {
    final tier = _tierFromString(d.tipoPrecio);
    final tierColor = _colorForTier(tier);
    final tieneDetalTachado = d.precioDetalOriginal != null &&
        d.precioDetalOriginal! > 0 &&
        d.precioDetalOriginal! > d.precioUnidad;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Nombre + tier badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  d.nombreProducto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _tierBadge(tier),
            ],
          ),

          const SizedBox(height: 8),

          // ── Cantidad × precio = subtotal ──
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              _miniStat(
                Icons.numbers_rounded,
                _cantidadLabel(d),
                cs,
              ),
              _miniStat(
                Icons.attach_money_rounded,
                '\$${d.precioUnidad.toStringAsFixed(2)} / unid',
                cs,
              ),
              if (d.descuentoPorcentajeLinea > 0)
                _miniStat(
                  Icons.percent_rounded,
                  'Desc. -${d.descuentoPorcentajeLinea.toStringAsFixed(0)}%',
                  cs,
                  color: _colorDescuento,
                ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 8),

          // ── Totales: detal tachado + subtotal ──
          Row(
            children: [
              if (tieneDetalTachado) ...[
                Text(
                  'Detal: \$${d.precioDetalOriginal!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              Text(
                '\$${d.subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: tierColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          // ── Autorización por línea ──
          if ((d.autorizadoPorLinea ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _colorAuth.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _colorAuth.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 12,
                    color: _colorAuth,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Autorizado por ${d.autorizadoPorLinea}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: _colorAuth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGOS CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildPagosCard(ColorScheme cs, bool isMobile) {
    return _card(
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            icon: Icons.payments_outlined,
            title: venta.esMultipago
                ? 'Pagos (${_pagos.length})'
                : 'Pago',
            cs: cs,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _pagos.length; i++) ...[
            _buildPagoRow(_pagos[i], cs),
            if (i < _pagos.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildPagoRow(PagoVentaEntity p, ColorScheme cs) {
    final usaBs = p.moneda == 'VES';
    final usaUsdt = p.moneda == 'USDT';

    final icon = _iconForMetodo(p.metodo);
    final color = _colorForMetodo(p.metodo);
    final label = _labelForMetodo(p.metodo);

    final montoStr = usaBs
        ? 'Bs. ${p.monto.toStringAsFixed(2)}'
        : (usaUsdt
            ? '${p.monto.toStringAsFixed(2)} USDT'
            : '\$${p.monto.toStringAsFixed(2)}');

    final equivStr = !usaBs && !usaUsdt
        ? null
        : '≈ \$${p.montoUsdEquivalente.toStringAsFixed(2)}';

    final referencias = <String>[
      if ((p.referencia ?? '').isNotEmpty) 'Ref: ${p.referencia}',
      if ((p.ultimosDigitos ?? '').isNotEmpty) '•••• ${p.ultimosDigitos}',
      if ((p.bancoEmisor ?? '').isNotEmpty) p.bancoEmisor!,
      if ((p.titular ?? '').isNotEmpty) p.titular!,
      if ((p.walletDestino ?? '').isNotEmpty) 'Wallet: ${p.walletDestino}',
      if ((p.hashTransaccion ?? '').isNotEmpty) 'Hash: ${p.hashTransaccion}',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    if (equivStr != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        equivStr,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                montoStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          if (referencias.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: referencias
                    .map((r) => Text(
                          r,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: cs.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // AUTORIZACIONES CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildAutorizacionesCard(ColorScheme cs, bool isMobile) {
    return _card(
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            icon: Icons.verified_user_outlined,
            title: 'Autorizaciones (${_autorizaciones.length})',
            cs: cs,
            color: _colorAuth,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _autorizaciones.length; i++) ...[
            _buildAutorizacionRow(_autorizaciones[i], cs),
            if (i < _autorizaciones.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildAutorizacionRow(
    AutorizacionDescuentoEntity a,
    ColorScheme cs,
  ) {
    final aprobada = a.aprobado;
    final color = aprobada ? _colorMayor : _colorAuth;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                aprobada
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a.esGlobal
                      ? 'Descuento global'
                      : 'Descuento en "${a.productoNombre ?? 'producto'}"',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${a.descuentoSolicitado.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _smallRow(
            'Solicitado por',
            '${a.solicitadoPorNombre} (${a.solicitadoPorRol})',
            cs,
          ),
          if (a.topeRolSolicitante > 0)
            _smallRow(
              'Tope del rol',
              '${a.topeRolSolicitante.toStringAsFixed(0)}%',
              cs,
            ),
          if (aprobada && (a.autorizadoPorNombre ?? '').isNotEmpty)
            _smallRow(
              'Autorizado por',
              '${a.autorizadoPorNombre} (${a.autorizadoPorRol ?? 'admin'})',
              cs,
              color: _colorMayor,
            ),
          if (!aprobada && (a.motivoRechazo ?? '').isNotEmpty)
            _smallRow(
              'Motivo rechazo',
              a.motivoRechazo!,
              cs,
              color: _colorAuth,
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ACCIONES
  // ══════════════════════════════════════════════════════════════

  Widget _buildAcciones(ColorScheme cs, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(
              'Volver',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: cs.onSurfaceVariant,
              side: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _reimprimirTicket,
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text(
              'Reimprimir ticket',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: _colorMayor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // REIMPRIMIR
  // ══════════════════════════════════════════════════════════════

  Future<void> _reimprimirTicket() async {
    try {
      if (_detalles.isEmpty) {
        _snack('No hay items para reimprimir');
        return;
      }

      final isar = ref.read(isarServiceProvider);
      final local = await isar.obtenerLocalActivo();
      final selectedPrinter = ref.read(printerProvider);

      // ── Mapear items ──
      final ticketItems = _detalles.map((d) {
        return TicketItem(
          nombre: d.nombreProducto,
          precio: d.precioUnidad,
          cantidad: d.cantidad,
          esPesado: false,
          tipoPrecio: d.tipoPrecio,
          descuentoPorcentaje: d.descuentoPorcentajeLinea,
          precioDetalOriginal: d.precioDetalOriginal,
          unidadEmpaque: d.unidadEmpaque,
          autorizadoPorLinea: d.autorizadoPorLinea,
        );
      }).toList();

      // ── Cliente ──
      final cliente = TicketCliente(
        nombre: venta.clienteNombre,
        rif: venta.clienteRif,
        documento: venta.clienteDocumento,
        razonSocial: venta.clienteRazonSocial,
      );

      // ── Pagos ──
      final ticketPagos = _pagos.map((p) {
        return TicketPago(
          metodo: p.metodo,
          monto: p.monto,
          moneda: p.moneda,
          montoUsdEquivalente: p.montoUsdEquivalente,
          referencia: p.referencia,
        );
      }).toList();

      await TicketService.imprimirTicketVenta(
        context: context,
        local: local,
        items: ticketItems,
        subtotal: venta.subtotal,
        impuesto: venta.impuesto,
        total: venta.total,
        metodoPago: venta.metodoPago,
        montoRecibido: venta.total,
        cambio: 0,
        fechaVenta: venta.fecha ?? DateTime.now(),
        impresoraSeleccionada: selectedPrinter?.device,
        // ✅ Mayoristas
        cliente: cliente,
        pagos: ticketPagos,
        tipoVenta: venta.tipoVenta,
        tipoDocumento: venta.tipoDocumento,
        tasaBcv: venta.tasaBcv,
        montoDescuentoTotal: venta.montoDescuentoTotal,
        requiereAutorizacion: venta.requiereAutorizacion,
        autorizadoPorNombre: venta.autorizadoPorNombre,
        vendedor: venta.empleado,
      );

      _snack('Ticket enviado a impresión');
    } catch (e) {
      debugPrint('❌ Error reimprimiendo ticket: $e');
      _snack('Error al reimprimir: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS UI
  // ══════════════════════════════════════════════════════════════

  /// Muestra un snack flotante simple.
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _card({required ColorScheme cs, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required ColorScheme cs,
    Color? color,
  }) {
    final c = color ?? cs.primary;
    return Row(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _infoBlock({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme cs,
  }) {
    return SizedBox(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(
    String label,
    String value,
    ColorScheme cs, {
    Color? color,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color ?? cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _miniStat(
    IconData icon,
    String label,
    ColorScheme cs, {
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color ?? cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color ?? cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _smallRow(
    String label,
    String value,
    ColorScheme cs, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color ?? cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Tier helpers ────────────────

  String _tierFromString(String? tipo) {
    switch (tipo) {
      case 'mayor':
        return 'mayor';
      case 'medio_mayor':
        return 'medio';
      default:
        return 'detal';
    }
  }

  Color _colorForTier(String tier) {
    switch (tier) {
      case 'mayor':
        return _colorMayor;
      case 'medio':
        return _colorMedio;
      default:
        return _colorDetal;
    }
  }

  String _tierLabel(String tier) {
    switch (tier) {
      case 'mayor':
        return 'MAYOR';
      case 'medio':
        return 'MEDIO';
      default:
        return 'DETAL';
    }
  }

  IconData _tierIcon(String tier) {
    switch (tier) {
      case 'mayor':
        return Icons.workspace_premium_rounded;
      case 'medio':
        return Icons.trending_up_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }

  Widget _tierBadge(String tier) {
    return StatusBadge(
      label: _tierLabel(tier),
      color: _colorForTier(tier),
      icon: _tierIcon(tier),
      size: StatusBadgeSize.small,
    );
  }

  String _cantidadLabel(DetalleVentaEntity d) {
    if (d.unidadEmpaque == 'unidad' || d.unidadEmpaque.isEmpty) {
      return '${d.cantidad.toStringAsFixed(d.cantidad % 1 == 0 ? 0 : 2)} u.';
    }
    final bultos = d.cantidad ~/ d.unidadesPorEmpaque;
    return '$bultos ${d.unidadEmpaque}s '
        '(${d.cantidad.toStringAsFixed(0)} u.)';
  }

  // ──────────────── Métodos de pago ────────────────

  IconData _iconForMetodo(String m) {
    switch (m) {
      case 'efectivo_usd':
      case 'efectivo_bs':
        return Icons.payments_rounded;
      case 'punto':
        return Icons.credit_card_rounded;
      case 'pago_movil':
        return Icons.phone_android_rounded;
      case 'transferencia_bs':
        return Icons.account_balance_rounded;
      case 'binance_pay':
        return Icons.currency_bitcoin_rounded;
      case 'transferencia_usdt':
        return Icons.swap_horiz_rounded;
      case 'zelle':
        return Icons.attach_money_rounded;
      case 'paypal':
        return Icons.payment_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _colorForMetodo(String m) {
    switch (m) {
      case 'efectivo_usd':
      case 'efectivo_bs':
        return _colorMayor;
      case 'punto':
        return const Color(0xFF8B5CF6);
      case 'pago_movil':
      case 'transferencia_bs':
        return const Color(0xFF3B82F6);
      case 'binance_pay':
        return const Color(0xFFF0B90B);
      case 'transferencia_usdt':
        return const Color(0xFF26A17B);
      case 'zelle':
        return const Color(0xFF8B5CF6);
      case 'paypal':
        return const Color(0xFF0070BA);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _labelForMetodo(String m) {
    switch (m) {
      case 'efectivo_usd':
        return 'Efectivo USD';
      case 'efectivo_bs':
        return 'Efectivo Bs';
      case 'punto':
        return 'Punto de venta';
      case 'pago_movil':
        return 'Pago Móvil';
      case 'transferencia_bs':
        return 'Transferencia Bs';
      case 'binance_pay':
        return 'Binance Pay';
      case 'transferencia_usdt':
        return 'Transferencia USDT';
      case 'zelle':
        return 'Zelle';
      case 'paypal':
        return 'PayPal';
      default:
        return m;
    }
  }

  // ──────────────── Util ────────────────

  String _shortId(String? id) {
    if (id == null || id.isEmpty) return '—';
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id;
  }
}