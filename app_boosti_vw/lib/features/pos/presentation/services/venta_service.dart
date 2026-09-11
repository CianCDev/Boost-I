// lib/features/pos/presentation/services/venta_service.dart
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
import '../../data/Local/entities/producto_entity.dart';

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
      // 1. Descontar stock directamente de los productos
      for (var cartItem in cartState.items) {
        // 🔥 LÓGICA ROBUSTA DE BÚSQUEDA EN 3 PASOS
        ProductoEntity? productoReal;

        // Paso A: Buscar en la lista en memoria por CÓDIGO DE BARRAS (único identificador)
        final listaActual = _ref.read(productosProvider).items;
        final codigo = cartItem.producto.codigoBarras.trim();
        
        final encontradosMemoria = listaActual.where((p) => p.codigoBarras.trim() == codigo).toList();
        productoReal = encontradosMemoria.isNotEmpty ? encontradosMemoria.first : null;

        // Paso B: Si no está en memoria, buscar en la base de datos por CLAVE EXACTA (codigoBarras)
        if (productoReal == null) {
          productoReal = await isar.obtenerProductoPorCodigoBarrasExacto(codigo);
        }

        // Paso C: Si aún es null, buscar en TODOS los productos de la BD (último recurso)
        if (productoReal == null) {
          final todosProductos = await isar.obtenerProductos();
          final encontradosBD = todosProductos.where((p) => p.codigoBarras.trim() == codigo).toList();
          if (encontradosBD.isNotEmpty) {
            productoReal = encontradosBD.first;
          }
        }

        // Si después de todo no existe, lanzar error claro
        if (productoReal == null) {
          throw Exception('Producto no encontrado: ${cartItem.producto.nombre}');
        }

        // Verificar stock disponible
        if (productoReal.stock < cartItem.cantidad) {
          throw Exception('Stock insuficiente para ${cartItem.producto.nombre}');
        }

        // Descontar stock
        productoReal.stock -= cartItem.cantidad;
        
        // 🔥 Guardar usando el código de barras como clave (sobrescribe si existe)
        await isar.guardarProducto(productoReal);
      }

      // 2. Preparar detalles de la venta
      final nuevoUuidVenta = const Uuid().v4();
      final ahora = DateTime.now();
      final totalBsCalculado = cartState.total * tasaActual;

      final itemsIsar = cartState.items.map((cartItem) {
        return DetalleVentaEntity()
          ..productoId = 0 // 🔥 YA NO USAMOS ID numérico, lo dejamos en 0
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

      // 3. Guardar venta con sus detalles
      await isar.guardarVenta(
        nuevaVenta,
        detalles: itemsIsar,
      );
      debugPrint('✅ Venta guardada localmente con ${itemsIsar.length} detalles');

      // 4. Recargar productos y limpiar carrito
      await _ref.read(productosProvider.notifier).cargarProductos();
      cartNotifier.limpiarCarrito();
      
      // 5. Imprimir ticket (silencioso si falla)
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
      // 🔥 Relanzamos el error para que el llamador (catalog_actions) pueda manejarlo
      rethrow;
    }
  }
}

final ventaServiceProvider = Provider<VentaService>((ref) => VentaService(ref));