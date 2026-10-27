// lib/features/pos/presentation/services/venta_service.dart
// ignore_for_file: use_build_context_synchronously

import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ventas_calculator.dart';
import 'documento_fiscal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/esc_pos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ticket_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:uuid/uuid.dart';
import '../../data/Local/entities/isar_service.dart';

class VentaService {
  final Ref _ref;

  VentaService(this._ref);

  /// Persiste la venta del carrito actual y ejecuta la post-venta.
  ///
  /// `context` es OPCIONAL: el servicio puede guardar la venta sin UI
  /// (tests, jobs offline). Si es `null`, se omiten la impresión del ticket y
  /// el feedback visual; la persistencia, los lotes y el carrito igual
  /// se hacen igual. Con `context` real, el comportamiento no cambia.
  Future<void> procesarVenta(
    BuildContext? context, {
    required String metodoPago,
    required double cambio,
    required double recibido,
    required double tasaActual,
    UsuarioEntity? usuarioLogueado,
    ClienteEntity? cliente,
    /// R.4 · Propina voluntaria del cobro de mesa. Se suma al total y se
    /// registra como una línea "Propina" en el detalle (sin producto).
    ///
    /// No se grava con IVA: `subtotal` e `impuesto` se quedan como los
    /// calculó el carrito. Son 0 en ventas de retail y de mostrador.
    double propina = 0.0,
    /// R.4 · Mesero que atendió la mesa, si la venta viene de una comanda.
    ///
    /// Se guarda en `VentaEntity.empleado`, que es el campo que el sync ya
    /// empuja como `empleado_nombre` y que agrupa "ventas por empleado".
    /// Consecuencia: en restaurante esa columna pasa a decir quién atendió,
    /// no quién cobró (no hay campo para ambos sin tocar la entidad).
    String? meseroNombre,
  }) async {
    final isar = _ref.read(isarServiceProvider);
    final cartState = _ref.read(cartProvider);
    final cartNotifier = _ref.read(cartProvider.notifier);

    // Un carrito vacío no genera venta. Sin este guard, `procesarVenta`
    // persistía una `VentaEntity` con 0 detalles y ensuciaba el histórico.
    // El test `carrito vacío: no guarda ninguna venta` lo verifica.
    // Se retorna silenciosamente (no es un error del caller, es un no-op).
    if (cartState.items.isEmpty) {
      debugPrint('ℹ️ procesarVenta: carrito vacío, no se guarda venta');
      return;
    }

    try {
      // ============================================================
      // 1. Descontar lotes
      // ============================================================
      final productosAfectados = <int>{};

      for (var cartItem in cartState.items) {
        final productoId = int.tryParse(cartItem.producto.id);
        if (productoId == null) continue;

        double cantidadPorDescontar = cartItem.cantidad;

        while (!VentaCalculator.cantidadEsCero(cantidadPorDescontar)) {
          final lote = await isar.obtenerLoteParaVenta(
            productoId,
            priorizarVencimiento: true,
          );
          if (lote == null) {
            throw Exception(
                'Stock insuficiente para ${cartItem.producto.nombre}');
          }

          final descontar = VentaCalculator.calcularDescuentoDeLote(
            cantidadNecesaria: cantidadPorDescontar,
            cantidadDisponible: lote.cantidadRestante,
          );

          final exito = await isar.descontarLote(lote.id, descontar);
          if (!exito) {
            throw Exception(
                'Error al descontar lote de ${cartItem.producto.nombre}');
          }
          cantidadPorDescontar -= descontar;
        }
        productosAfectados.add(productoId);
      }

      // ============================================================
      // 2. Actualizar stock desde los lotes (fuente única de verdad)
      // ============================================================
      await isar.recalcularStockDe(productosAfectados.toList());

      // ============================================================
      // 3. Preparar detalles de la venta
      // ============================================================
      final nuevoUuidVenta = const Uuid().v4();
      final ahora = DateTime.now();

      // R.4 · La propina se suma al total pero NO al IVA ni al subtotal.
      // Se normaliza a 0 si llega negativa o NaN: un total menor que el
      // consumo dejaría el vuelto mal calculado sin ningún aviso.
      final propinaAplicada = (propina.isFinite && propina > 0)
          ? _redondearDosDecimales(propina)
          : 0.0;
      final totalConPropina =
          _redondearDosDecimales(cartState.total + propinaAplicada);
      final totalBsCalculado =
          _redondearDosDecimales(totalConPropina * tasaActual);

      final itemsIsar = VentaCalculator.cartItemsADetalles(
        cartItems: cartState.items,
        ventaIdFk: nuevoUuidVenta,
      );

      final resultadoDescuentos = VentaCalculator.calcularDescuentos(itemsIsar);

      // Numeración fiscal. Se pide ANTES de construir la entidad porque
      // es async: el número va en el mismo INSERT que la venta, así que
      // no puede completarse después.
      //
      // ⚠️ `..documento` NO se toca: ese campo guarda el documento del
      //    CLIENTE, no el número de factura. Ver `VentaEntity`.
      final numeroFactura = await DocumentoFiscalService.siguiente();

      final nuevaVenta = VentaEntity()
        ..idSupabase = nuevoUuidVenta
        ..fecha = ahora
        ..total = totalConPropina
        ..subtotal = cartState.subtotal
        ..impuesto = cartState.impuesto
        ..tasaBcv = tasaActual
        ..totalBolivares = totalBsCalculado
        ..metodoPago = metodoPago
        ..numeroFactura = numeroFactura
        ..documento = 0
        ..empleado = meseroNombre ??
            usuarioLogueado?.nombre ??
            'Administrador / Catálogo'
        ..syncStatus = 'pending'
        ..tieneDescuentoEspecial = resultadoDescuentos.tieneDescuento
        ..montoDescuentoTotal = resultadoDescuentos.montoDescuentoTotal;

      // Vinculación con cliente
      if (cliente != null) {
        nuevaVenta.clienteId = cliente.id;
        nuevaVenta.clienteNombre = cliente.nombre;
        nuevaVenta.clienteDocumento = cliente.documentoFormateado;
        nuevaVenta.clienteRif = cliente.rif;
        nuevaVenta.clienteRazonSocial = cliente.razonSocial;
      }

      // ── R.4 · Línea de propina ────────────────────────────────────
      //
      // `DetalleVentaEntity.productoId` es nullable y
      // `detalle_ventas.producto_id` es `bigint` sin NOT NULL, así que
      // esta línea sincroniza igual que cualquier otra. Va SIN IVA: el
      // impuesto de la venta es el del consumo.
      final detallesVenta = List<DetalleVentaEntity>.of(itemsIsar);
      if (propinaAplicada > 0) {
        detallesVenta.add(
          DetalleVentaEntity()
            ..productoId = null
            ..nombreProducto = 'Propina'
            ..precioUnidad = propinaAplicada
            ..cantidad = 1
            ..subtotal = propinaAplicada
            ..ventaIdFk = nuevoUuidVenta
            ..syncStatus = 'pending',
        );
      }

      // ============================================================
      // 4. Guardar venta con sus detalles
      // ============================================================
      await isar.guardarVenta(nuevaVenta, detalles: detallesVenta);
      debugPrint(
          '✅ Venta guardada localmente con ${detallesVenta.length} detalles');

      // ============================================================
      // 4.1 Actualizar fidelización del cliente
      // ============================================================
      if (cliente != null) {
        try {
          final clienteActualizado = ClienteEntity()
            ..id = cliente.id
            ..supabaseId = cliente.supabaseId
            ..localId = cliente.localId
            ..localSupabaseId = cliente.localSupabaseId
            ..nombre = cliente.nombre
            ..documento = cliente.documento
            ..tipoDocumento = cliente.tipoDocumento
            ..rif = cliente.rif
            ..razonSocial = cliente.razonSocial
            ..esMayorista = cliente.esMayorista
            ..limiteCredito = cliente.limiteCredito
            ..diasCredito = cliente.diasCredito
            ..descuentoPreferencial = cliente.descuentoPreferencial
            ..telefono = cliente.telefono
            ..email = cliente.email
            ..direccion = cliente.direccion
            ..fechaRegistro = cliente.fechaRegistro
            ..frecuente = true
            ..totalCompras = cliente.totalCompras + cartState.total
            ..ultimaCompra = ahora
            ..cantidadCompras = cliente.cantidadCompras + 1
            ..activo = cliente.activo
            ..preferenciasMarketing = cliente.preferenciasMarketing
            ..fechaNacimiento = cliente.fechaNacimiento
            ..notas = cliente.notas
            ..syncStatus = 'pending'
            ..createdAt = cliente.createdAt
            ..updatedAt = ahora;
          await isar.guardarCliente(clienteActualizado);
          debugPrint('✅ Fidelización actualizada para ${cliente.nombre}');
        } catch (e) {
          debugPrint('⚠️ No se pudo actualizar fidelización del cliente: $e');
        }
      }

      // ============================================================
      // 5. Recargar productos y limpiar carrito
      // ============================================================
      final productosNotifier = _ref.read(productosProvider.notifier);
      await productosNotifier.cargarProductos();
      cartNotifier.limpiarCarrito();

      // ============================================================
      // 6. Imprimir ticket
      // ============================================================
      final local = await IsarService().obtenerLocalActivo();

      // Sin `context` no hay dónde dibujar el ticket: se salta la impresión
      // entera. La venta YA quedó guardada antes de llegar aquí, así que
      // omitir esto no deja datos inconsistentes.
      if (context != null) {
        try {
          final ticketItems = detallesVenta.map((detalle) {
            return TicketItem(
              nombre: detalle.nombreProducto,
              precio: detalle.precioUnidad,
              cantidad: detalle.cantidad,
              esPesado: detalle.esPesado,
              // Extras por si algún ítem de detal tiene tier aplicado
              tipoPrecio: detalle.tipoPrecio,
              descuentoPorcentaje: detalle.descuentoPorcentajeLinea,
              precioDetalOriginal: detalle.precioDetalOriginal,
              unidadEmpaque: detalle.unidadEmpaque,
              autorizadoPorLinea: detalle.autorizadoPorLinea,
            );
          }).toList();

          // ✅ NUEVO: ticket cliente como objeto (firma nueva de la API)
          final ticketCliente = cliente != null
              ? TicketCliente(
                  nombre: cliente.nombre,
                  rif: cliente.rif,
                  documento: cliente.documentoFormateado,
                  razonSocial: cliente.razonSocial,
                )
              : null;

          final selectedPrinter = _ref.read(printerProvider);
          await TicketService.imprimirTicketVenta(
            context: context,
            local: local,
            // La venta ya se creó arriba con su número fiscal. Sin esto el
            // PDF de respaldo sale con "FACTURA" y sin N°.
            numeroFactura: nuevaVenta.numeroFactura,
            items: ticketItems,
            subtotal: cartState.subtotal,
            impuesto: cartState.impuesto,
            total: totalConPropina,
            metodoPago: metodoPago,
            montoRecibido: recibido,
            cambio: cambio,
            fechaVenta: DateTime.now(),
            impresoraSeleccionada: selectedPrinter?.device,
            // ✅ Objeto cliente (reemplaza los params sueltos viejos)
            cliente: ticketCliente,
            // Extras de contexto
            tipoVenta: 'detal',
            tasaBcv: tasaActual,
            montoDescuentoTotal: resultadoDescuentos.montoDescuentoTotal,
            vendedor: usuarioLogueado?.nombre,
          );
        } catch (e) {
          debugPrint('⚠️ Error al intentar imprimir el ticket: $e');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Venta registrada con éxito! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context?.mounted ?? false) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text('Error al registrar la venta: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      rethrow;
    }
  }
}

final ventaServiceProvider = Provider<VentaService>((ref) => VentaService(ref));

double _redondearDosDecimales(double valor) =>
    (valor * 100).roundToDouble() / 100;