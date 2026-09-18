// lib/features/pos/presentation/services/venta_service.dart
// ignore_for_file: use_build_context_synchronously

import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ventas_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
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

  Future<void> procesarVenta(
    BuildContext context, {
    required String metodoPago,
    required double cambio,
    required double recibido,
    required double tasaActual,
    UsuarioEntity? usuarioLogueado,
    ClienteEntity? cliente,
  }) async {
    final isar = _ref.read(isarServiceProvider);
    final cartState = _ref.read(cartProvider);
    final cartNotifier = _ref.read(cartProvider.notifier);

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
      // 2. Actualizar stock
      // ============================================================
      for (var productoId in productosAfectados) {
        final producto = await isar.obtenerProductoPorId(productoId);
        if (producto == null) continue;
        final stockTotal = await isar.obtenerStockTotalPorProducto(productoId);
        producto.stock = stockTotal;
        await isar.guardarProducto(producto);
      }

      // ============================================================
      // 3. Preparar detalles de la venta
      // ============================================================
      final nuevoUuidVenta = const Uuid().v4();
      final ahora = DateTime.now();
      final totalBsCalculado = cartState.total * tasaActual;

      final itemsIsar = VentaCalculator.cartItemsADetalles(
        cartItems: cartState.items,
        ventaIdFk: nuevoUuidVenta,
      );

      final resultadoDescuentos = VentaCalculator.calcularDescuentos(itemsIsar);

      final nuevaVenta = VentaEntity()
        ..idSupabase = nuevoUuidVenta
        ..fecha = ahora
        ..total = cartState.total
        ..subtotal = cartState.subtotal
        ..impuesto = cartState.impuesto
        ..tasaBcv = tasaActual
        ..totalBolivares = totalBsCalculado
        ..metodoPago = metodoPago
        ..documento = 0
        ..empleado = usuarioLogueado?.nombre ?? 'Administrador / Catálogo'
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

      // ============================================================
      // 4. Guardar venta con sus detalles
      // ============================================================
      await isar.guardarVenta(nuevaVenta, detalles: itemsIsar);
      debugPrint(
          '✅ Venta guardada localmente con ${itemsIsar.length} detalles');

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

      try {
        final ticketItems = itemsIsar.map((detalle) {
          return TicketItem(
            nombre: detalle.nombreProducto,
            precio: detalle.precioUnidad,
            cantidad: detalle.cantidad,
            esPesado: false,
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
          items: ticketItems,
          subtotal: cartState.subtotal,
          impuesto: cartState.impuesto,
          total: cartState.total,
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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