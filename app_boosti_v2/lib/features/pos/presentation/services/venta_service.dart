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
// ignore: unused_import
import 'package:app_boosti_v2/features/pos/presentation/providers/catalog_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';

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
      // 🔥 Descontar lotes y actualizar stock del producto principal
      final productosAfectados = <int>{}; // IDs de productos afectados

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

        // ✅ Marcar producto para actualizar stock
        productosAfectados.add(productoId);
      }

      // ✅ Actualizar stock del producto principal (suma de lotes activos)
      for (var productoId in productosAfectados) {
        final producto = await isar.obtenerProductoPorId(productoId);
        if (producto == null) continue;

        final stockTotal = await isar.obtenerStockTotalPorProducto(productoId);
        producto.stock = stockTotal;
        await isar.guardarProducto(producto);

        // Registrar movimiento de inventario (ya se hizo en descontarLote)
      }

      // Guardar venta
      final ventaIdStr = 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final ahora = DateTime.now();
      final totalBsCalculado = cartState.total * tasaActual;

      final itemsIsar = cartState.items.map((cartItem) {
        return DetalleVentaEntity()
          ..productoId = int.tryParse(cartItem.producto.id)
          ..nombreProducto = cartItem.producto.nombre
          ..precioUnidad = cartItem.producto.precioUnidad
          ..cantidad = cartItem.cantidad.toDouble()
          ..subtotal = cartItem.cantidad.toDouble() * cartItem.producto.precioUnidad;
      }).toList();

      final nuevaVenta = VentaEntity()
        ..ventaIdString = ventaIdStr
        ..fecha = ahora
        ..total = cartState.total
        ..subtotal = cartState.subtotal
        ..impuesto = cartState.impuesto
        ..tasaBcv = tasaActual
        ..totalBolivares = totalBsCalculado
        ..metodoPago = metodoPago
        ..documento = '...'
        ..empleado = usuarioLogueado?.nombre ?? 'Administrador / Catálogo'
        ..items = itemsIsar.cast<DetalleVentaEntity>()
        ..syncStatus = 'pending';

      await isar.guardarVenta(nuevaVenta);

      // ✅ Recargar productosProvider para actualizar stock en UI
      final productosNotifier = _ref.read(productosProvider.notifier);
      await productosNotifier.cargarProductos();

      // Limpiar carrito
      cartNotifier.limpiarCarrito();

      // Imprimir ticket
      try {
        final ticketItems = cartState.items.map((item) {
          return TicketItem(
            nombre: item.producto.nombre,
            precio: item.producto.precioUnidad,
            cantidad: item.cantidad.toDouble(),
            esPesado: item.producto.esPesado,
          );
        }).toList();

        final selectedPrinter = _ref.read(printerProvider);
        await TicketService.imprimirTicketVenta(
          context: context,
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
        // Error al imprimir, ignorar
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