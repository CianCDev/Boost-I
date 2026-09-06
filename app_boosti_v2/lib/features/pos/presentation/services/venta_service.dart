// ignore_for_file: use_build_context_synchronously

import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/esc_pos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ticket_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/ticket_generator.dart';
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
  }) async {
    final isar = _ref.read(isarServiceProvider);
    final cartState = _ref.read(cartProvider);
    final cartNotifier = _ref.read(cartProvider.notifier);
    
    try {
      // 1. Descontar lotes
      final productosAfectados = <int>{};

      for (var cartItem in cartState.items) {
        final productoId = int.tryParse(cartItem.producto.id);
        if (productoId == null) continue;

        double cantidadPorDescontar = cartItem.cantidad;
        while (cantidadPorDescontar > 0.001) {
          final lote = await isar.obtenerLoteParaVenta(productoId, priorizarVencimiento: true);
          if (lote == null) {
            throw Exception('Stock insuficiente para ${cartItem.producto.nombre}');
          }
          final descontar = cantidadPorDescontar > lote.cantidadRestante
              ? lote.cantidadRestante
              : cantidadPorDescontar;
          final exito = await isar.descontarLote(lote.id, descontar);
          if (!exito) {
            throw Exception('Error al descontar lote de ${cartItem.producto.nombre}');
          }
          cantidadPorDescontar -= descontar;
        }
        productosAfectados.add(productoId);
      }

      // 2. Actualizar stock
      for (var productoId in productosAfectados) {
        final producto = await isar.obtenerProductoPorId(productoId);
        if (producto == null) continue;
        final stockTotal = await isar.obtenerStockTotalPorProducto(productoId);
        producto.stock = stockTotal;
        await isar.guardarProducto(producto);
      }
      
      // 3. Preparar detalles de la venta
      final nuevoUuidVenta = const Uuid().v4();
      final ahora = DateTime.now();
      final totalBsCalculado = cartState.total * tasaActual;

      final itemsIsar = cartState.items.map((cartItem) {
        return DetalleVentaEntity()
          ..productoId = int.tryParse(cartItem.producto.id)
          ..nombreProducto = cartItem.producto.nombre
          ..precioUnidad = cartItem.producto.precioUnidad
          ..precioOriginal = cartItem.precioOriginal
          ..esDescuentoEspecial = cartItem.esDescuentoEspecial
          ..cantidad = cartItem.cantidad.toDouble()
          ..subtotal = cartItem.cantidad.toDouble() * cartItem.producto.precioUnidad
          ..syncStatus = 'pending'
          ..ventaIdFk = nuevoUuidVenta;
      }).toList();

      // Calcular descuentos totales
      bool tieneDescuento = false;
      double montoDescuentoTotal = 0.0;

      for (var item in itemsIsar) {
        if (item.esDescuentoEspecial == true && item.precioOriginal != null) {
          tieneDescuento = true;
          final descuento = (item.precioOriginal! - item.precioUnidad) * item.cantidad;
          montoDescuentoTotal += descuento;
        }
      }

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
        ..tieneDescuentoEspecial = tieneDescuento
        ..montoDescuentoTotal = montoDescuentoTotal;

      // 4. Guardar venta con sus detalles explícitamente
      await isar.guardarVenta(
        nuevaVenta,
        detalles: itemsIsar, // 🔥 Pasar los detalles
      );
      debugPrint('✅ Venta guardada localmente con ${itemsIsar.length} detalles');

      // 5. Recargar productos y limpiar carrito
      final productosNotifier = _ref.read(productosProvider.notifier);
      await productosNotifier.cargarProductos();
      cartNotifier.limpiarCarrito();
      
      // 6. Imprimir ticket
      final local = await IsarService().obtenerLocalActivo();

      try {
        final ticketItems = itemsIsar.map((detalle) {
          return TicketItem(
            nombre: detalle.nombreProducto,
            precio: detalle.precioUnidad,
            cantidad: detalle.cantidad,
            esPesado: false,
          );
        }).toList();

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
        );
      } catch (_) {
        debugPrint('⚠️ Error silencioso al intentar imprimir el ticket');
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