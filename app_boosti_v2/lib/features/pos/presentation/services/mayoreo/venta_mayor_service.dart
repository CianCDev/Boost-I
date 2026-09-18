// lib/features/pos/presentation/services/mayoreo/venta_mayor_service.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/Local/entities/autorizacion_descuento_entity.dart';
import '../../../data/Local/entities/detalle_venta_entity.dart';
import '../../../data/Local/entities/log_entity.dart';
import '../../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../../data/Local/entities/pago_venta_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../data/Local/entities/venta_entity.dart';
// ignore: unused_import
import '../../../domain/permissions/roles.dart';
import '../../../domain/wholesale/wholesale_cart_item.dart';
import '../../providers/isar_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/wholesale/wholesale_cart_provider.dart';
import '../../providers/wholesale/wholesale_client_provider.dart';
import '../ticket_generator.dart';
// ignore: unused_import
import '../ticket_service.dart';
import 'wholesale_lot_service.dart';
import 'wholesale_pricing_service.dart';

// ═══════════════════════════════════════════════════════════════════
// RESULTADO DE LA VENTA
// ═══════════════════════════════════════════════════════════════════

class VentaMayorResult {
  final bool exito;
  final String? ventaId;
  final String? ventaSupabaseId;
  final double total;
  final String? mensajeError;
  final List<String> warnings;

  const VentaMayorResult({
    required this.exito,
    this.ventaId,
    this.ventaSupabaseId,
    this.total = 0.0,
    this.mensajeError,
    this.warnings = const [],
  });

  factory VentaMayorResult.ok({
    required String ventaId,
    required String ventaSupabaseId,
    required double total,
    List<String> warnings = const [],
  }) {
    return VentaMayorResult(
      exito: true,
      ventaId: ventaId,
      ventaSupabaseId: ventaSupabaseId,
      total: total,
      warnings: warnings,
    );
  }

  factory VentaMayorResult.error(String mensaje) {
    return VentaMayorResult(exito: false, mensajeError: mensaje);
  }
}

// ═══════════════════════════════════════════════════════════════════
// DATOS DE PAGO (parámetros del cobro)
// ═══════════════════════════════════════════════════════════════════

@immutable
class VentaMayorPagoInput {
  /// Lista de pagos (uno o varios).
  final List<PagoInput> pagos;

  /// Tasa BCV usada en el cobro.
  final double tasaBcv;

  /// Monto recibido en USD (para vuelto).
  final double montoRecibidoUsd;

  /// Vuelto calculado.
  final double vueltoUsd;

  const VentaMayorPagoInput({
    required this.pagos,
    required this.tasaBcv,
    this.montoRecibidoUsd = 0.0,
    this.vueltoUsd = 0.0,
  });
}

@immutable
class PagoInput {
  final String metodo;
  final double monto;
  final String moneda;
  final double montoUsdEquivalente;
  final double? tasaBcv;
  final String? referencia;
  final String? ultimosDigitos;
  final String? walletDestino;
  final String? hashTransaccion;
  final String? redCripto;
  final String? bancoEmisor;
  final String? titular;

  const PagoInput({
    required this.metodo,
    required this.monto,
    required this.moneda,
    required this.montoUsdEquivalente,
    this.tasaBcv,
    this.referencia,
    this.ultimosDigitos,
    this.walletDestino,
    this.hashTransaccion,
    this.redCripto,
    this.bancoEmisor,
    this.titular,
  });

  factory PagoInput.efectivo({
    required double monto,
    required String moneda,
    required double tasaBcv,
    required double montoUsdEquivalente,
  }) {
    return PagoInput(
      metodo: moneda == 'USD' ? 'efectivo_usd' : 'efectivo_bs',
      monto: monto,
      moneda: moneda,
      montoUsdEquivalente: montoUsdEquivalente,
      tasaBcv: tasaBcv,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SERVICIO
// ═══════════════════════════════════════════════════════════════════

class VentaMayorService {
  final Ref _ref;

  VentaMayorService(this._ref);

  // ──────────────── Validaciones ────────────────

  /// Valida que la venta pueda proceder. Devuelve un mensaje si hay error.
  String? validar() {
    final cartState = _ref.read(wholesaleCartProvider);
    final clienteState = _ref.read(wholesaleClientProvider);

    if (!cartState.tieneItems) {
      return 'El carrito está vacío';
    }

    if (!clienteState.tieneCliente) {
      return 'Debes seleccionar un cliente';
    }

    final motivo = WholesaleClientNotifier.motivoRechazo(clienteState.cliente);
    if (motivo != null) {
      return motivo;
    }

    if (cartState.requiereAutorizacion) {
      return 'Hay descuentos pendientes de autorización';
    }

    return null;
  }

  // ──────────────── Ejecución principal ────────────────

  /// Ejecuta la venta completa.
  ///
  /// Pasos:
  ///   1. Valida carrito + cliente
  ///   2. Aplica FEFO a cada item
  ///   3. Persiste VentaEntity + DetalleVentaEntity
  ///   4. Persiste Pagos
  ///   5. Registra autorizaciones
  ///   6. Movimientos de inventario
  ///   7. Actualiza estadísticas del cliente
  ///   8. Log de auditoría
  Future<VentaMayorResult> ejecutar({
    required VentaMayorPagoInput pago,
    UsuarioEntity? usuarioLogueado,
  }) async {
    final warnings = <String>[];

    try {
      // ── 1. Validar ──
      final errorValidacion = validar();
      if (errorValidacion != null) {
        return VentaMayorResult.error(errorValidacion);
      }

      final isar = _ref.read(isarServiceProvider);
      final cartState = _ref.read(wholesaleCartProvider);
      final clienteState = _ref.read(wholesaleClientProvider);
      final cliente = clienteState.cliente!;
      final usuario = usuarioLogueado ?? _ref.read(usuarioActualProvider);

      final ahora = DateTime.now();
      final ventaSupabaseId = const Uuid().v4();

      // ── 2. Aplicar FEFO a cada item ──
      final lotService = WholesaleLotService(isarService: isar);
      final detalles = <DetalleVentaEntity>[];
      final lotesAfectados = <String, List<AsignacionLote>>{};

      for (final item in cartState.items) {
        // 2.1 Planificar FEFO
        final plan = await lotService.planificar(
          productoId: item.producto.id,
          cantidad: item.cantidad.toDouble(),
          productoNombre: item.producto.nombre,
        );

        // 2.2 Aplicar descuento de lotes
        final movsCreados = await lotService.aplicar(
          plan: plan,
          usuarioId: usuario?.id ?? 0,
          motivo: 'Venta al mayor ${ventaSupabaseId.substring(0, 8)}',
          ventaSupabaseId: ventaSupabaseId,
        );

        debugPrint(
            '📦 ${item.producto.nombre}: $movsCreados movimientos de lote');

        lotesAfectados[item.lineId] = plan;

        // 2.3 Calcular costo snapshot (para reportes de margen)
        final costoPromedio = WholesaleLotService.calcularCostoPromedio(plan);
        final costoSnapshot = costoPromedio > 0 ? costoPromedio : null;

        // 2.4 Construir detalle
        detalles.add(_construirDetalle(
          item: item,
          ventaSupabaseId: ventaSupabaseId,
          costoUnitarioSnapshot: costoSnapshot,
          plan: plan,
        ));

        // 2.5 Crear movimiento de inventario consolidado
        final producto = await isar.obtenerProductoPorId(item.producto.id);
        if (producto != null) {
          final stockTotal =
              await isar.obtenerStockTotalPorProducto(item.producto.id);
          producto.stock = stockTotal;
          await isar.guardarProducto(producto);

          final movInventario = MovimientoInventarioEntity()
            ..productoId = item.producto.id
            ..nombreProducto = item.producto.nombre
            ..tipoMovimiento = 'Venta al mayor'
            ..cantidad = -item.cantidad.toDouble()
            ..stockResultante = stockTotal
            ..fecha = ahora
            ..usuarioId = usuario?.id ?? 0
            ..syncStatus = 'pending';
          await isar.guardarMovimientoInventario(movInventario);
        } else {
          warnings.add('No se encontró el producto "${item.producto.nombre}"');
        }
      }

      // ── 3. Construir VentaEntity ──
      final tieneDescuento = cartState.montoDescuentoGlobal > 0 ||
          cartState.items.any((i) => i.tieneDescuentoManual || i.tieneDescuentoAuto);

      final venta = VentaEntity()
        ..idSupabase = ventaSupabaseId
        ..fecha = ahora
        ..subtotal = cartState.subtotal
        ..impuesto = cartState.impuesto
        ..total = cartState.total
        ..tasaBcv = pago.tasaBcv
        ..totalBolivares = cartState.total * pago.tasaBcv
        ..metodoPago = _metodoPagoResumen(pago.pagos)
        ..documento = 0
        ..empleado = usuario?.nombre ?? 'Sistema'
        ..syncStatus = 'pending'
        // Tipo de venta al mayor
        ..tipoVenta = 'mayor'
        ..tipoDocumento = 'nota_entrega'
        // Descuentos
        ..tieneDescuentoEspecial = tieneDescuento
        ..montoDescuentoTotal = cartState.montoDescuentoGlobal +
            cartState.items.fold<double>(
              0.0,
              (sum, i) => sum + i.montoDescuentoTotal,
            )
        ..montoDescuentoPorcentaje = cartState.descuentoGlobalPorcentaje
        // Pago
        ..tipoPago = 'contado'
        ..esMultipago = pago.pagos.length > 1
        // Cliente
        ..clienteId = cliente.id
        ..clienteNombre = cliente.nombre
        ..clienteDocumento = cliente.documentoFormateado
        ..clienteRif = cliente.rif
        ..clienteRazonSocial = cliente.razonSocial;

      // ── 4. Persistir venta + detalles ──
      await isar.guardarVenta(venta, detalles: detalles);
      debugPrint('✅ Venta mayor guardada: ${venta.id}');

      // Necesitamos el `id` local (Isar) de la venta para asociar pagos
      final ventaLocal =
          await isar.obtenerVentaPorIdString(ventaSupabaseId);
      if (ventaLocal == null) {
        return VentaMayorResult.error(
            'No se pudo recuperar la venta después de guardarla');
      }

      // ── 5. Persistir pagos ──
      for (final p in pago.pagos) {
        final pagoEntity = PagoVentaEntity()
          ..ventaIdFk = ventaLocal.id
          ..ventaSupabaseId = ventaSupabaseId
          ..metodo = p.metodo
          ..monto = p.monto
          ..moneda = p.moneda
          ..montoUsdEquivalente = p.montoUsdEquivalente
          ..tasaBcv = p.tasaBcv
          ..referencia = p.referencia
          ..ultimosDigitos = p.ultimosDigitos
          ..walletDestino = p.walletDestino
          ..hashTransaccion = p.hashTransaccion
          ..bancoEmisor = p.bancoEmisor
          ..titular = p.titular
          ..fecha = ahora
          ..syncStatus = 'pending'
          ..createdAt = ahora
          ..updatedAt = ahora;

        await isar.guardarPagoVenta(pagoEntity);
      }
      debugPrint('✅ ${pago.pagos.length} pagos guardados');

      // ── 6. Registrar autorizaciones de descuento ──
      await _registrarAutorizaciones(
        cartState: cartState,
        ventaIdFk: ventaLocal.id,
        ventaSupabaseId: ventaSupabaseId,
        usuario: usuario,
      );

      // ── 7. Actualizar estadísticas del cliente ──
      try {
        await isar.actualizarEstadisticasCliente(cliente.id, cartState.total);
      } catch (e) {
        warnings.add('No se pudieron actualizar estadísticas del cliente: $e');
      }

      // ── 8. Log de auditoría ──
      await isar.guardarLog(
        LogEntity()
          ..accion = 'VENTA_MAYOR_CREADA'
          ..usuarioNombre = usuario?.nombre ?? 'Sistema'
          ..usuarioRol = usuario?.rol ?? 'cajero'
          ..detalles = 'Venta ${ventaSupabaseId.substring(0, 8)} · '
              'Cliente: ${cliente.nombre} · Total: \$${cartState.total.toStringAsFixed(2)}'
          ..fecha = ahora
          ..sincronizado = false,
      );

      // ── 9. Imprimir ticket ──
      // Este paso se hace FUERA del service (en la pantalla) porque
      // requiere `BuildContext`. Aquí solo devolvemos el resultado.

      return VentaMayorResult.ok(
        ventaId: ventaLocal.id.toString(),
        ventaSupabaseId: ventaSupabaseId,
        total: cartState.total,
        warnings: warnings,
      );
    } catch (e, stack) {
      debugPrint('❌ Error en VentaMayorService: $e');
      debugPrint('Stack: $stack');
      return VentaMayorResult.error('Error al procesar la venta: $e');
    }
  }

  // ──────────────── Helpers ────────────────

  DetalleVentaEntity _construirDetalle({
    required WholesaleCartItem item,
    required String ventaSupabaseId,
    double? costoUnitarioSnapshot,
    required List<AsignacionLote> plan,
  }) {
    // Tomamos el lote principal como informativo (el primero del plan).
    final lotePrincipalId = plan.isNotEmpty ? plan.first.loteId : null;

    return DetalleVentaEntity()
      ..ventaIdFk = ventaSupabaseId
      ..productoId = item.producto.id
      ..nombreProducto = item.producto.nombre
      ..precioUnidad = item.precioUnitario
      ..precioOriginal = item.precioDetalOriginal
      ..esDescuentoEspecial = item.tieneDescuentoManual ||
          item.tieneDescuentoAuto
      ..cantidad = item.cantidad.toDouble()
      ..subtotal = item.subtotalFinal
      ..syncStatus = 'pending'
      // Wholesale
      ..precioDetalOriginal = item.precioDetalOriginal
      ..precioMayorAplicado = item.tipoPrecio.storageKey == 'mayor' ||
              item.tipoPrecio.storageKey == 'medio_mayor'
          ? item.precioUnitario
          : null
      ..tipoPrecio = item.tipoPrecio.storageKey
      ..descuentoPorcentajeLinea = item.descuentoManualPorcentaje
      ..unidadEmpaque = item.unidadEmpaque
      ..unidadesPorEmpaque = item.unidadesPorEmpaque
      ..autorizadoPorLinea = item.autorizadoPorNombre
      ..costoUnitarioSnapshot = costoUnitarioSnapshot
      ..loteIdIsar = lotePrincipalId;
  }

  Future<void> _registrarAutorizaciones({
    required WholesaleCartState cartState,
    required int ventaIdFk,
    required String ventaSupabaseId,
    UsuarioEntity? usuario,
  }) async {
    final isar = _ref.read(isarServiceProvider);
    final ahora = DateTime.now();

    // Autorizaciones por línea
    for (final item in cartState.items) {
      if (!item.tieneDescuentoManual) continue;

      final entidad = AutorizacionDescuentoEntity()
        ..ventaIdFk = ventaIdFk
        ..ventaSupabaseId = ventaSupabaseId
        ..productoId = item.producto.id
        ..productoNombre = item.producto.nombre
        ..esGlobal = false
        ..descuentoSolicitado = item.descuentoManualPorcentaje
        ..topeRolSolicitante = 0 // se recalcula si hace falta
        ..solicitadoPorId = usuario?.id
        ..solicitadoPorNombre = usuario?.nombre ?? 'Sistema'
        ..solicitadoPorRol = usuario?.rol ?? 'cajero'
        ..autorizadoPorNombre = item.autorizadoPorNombre
        ..autorizadoPorRol = item.autorizadoPorNombre != null ? 'admin' : null
        ..aprobado = item.descuentoAutorizado
        ..fecha = ahora
        ..syncStatus = 'pending';

      await isar.guardarAutorizacionDescuento(entidad);
    }

    // Autorización global
    if (cartState.descuentoGlobalPorcentaje > 0) {
      final entidad = AutorizacionDescuentoEntity()
        ..ventaIdFk = ventaIdFk
        ..ventaSupabaseId = ventaSupabaseId
        ..esGlobal = true
        ..descuentoSolicitado = cartState.descuentoGlobalPorcentaje
        ..topeRolSolicitante = 0
        ..solicitadoPorId = usuario?.id
        ..solicitadoPorNombre = usuario?.nombre ?? 'Sistema'
        ..solicitadoPorRol = usuario?.rol ?? 'cajero'
        ..autorizadoPorNombre = cartState.autorizadoPorNombreGlobal
        ..autorizadoPorRol =
            cartState.autorizadoPorNombreGlobal != null ? 'admin' : null
        ..aprobado = cartState.descuentoGlobalAutorizado
        ..fecha = ahora
        ..syncStatus = 'pending';

      await isar.guardarAutorizacionDescuento(entidad);
    }
  }

  String _metodoPagoResumen(List<PagoInput> pagos) {
    if (pagos.isEmpty) return 'efectivo';
    if (pagos.length == 1) return _labelMetodo(pagos.first.metodo);
    return 'multipago (${pagos.length})';
  }

  String _labelMetodo(String metodo) {
    switch (metodo) {
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
        return metodo;
    }
  }

  // ──────────────── Helpers públicos ────────────────

  /// Genera los items de ticket a partir del carrito actual.
  List<TicketItem> construirTicketItems() {
    final cartState = _ref.read(wholesaleCartProvider);
    return cartState.items.map((item) {
      return TicketItem(
        nombre: item.producto.nombre,
        precio: item.precioUnitario,
        cantidad: item.cantidad.toDouble(),
        esPesado: item.producto.esPesado,
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════

final ventaMayorServiceProvider = Provider<VentaMayorService>((ref) {
  return VentaMayorService(ref);
});