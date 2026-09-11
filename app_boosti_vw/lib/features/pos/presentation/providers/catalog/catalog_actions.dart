// lib/features/pos/presentation/providers/catalog/catalog_actions.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/bcv_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/venta_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/catalog/quantity_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/cobrar_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/inventory/product_form_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/catalog_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';

final ultimoFactorProvider = StateProvider<double>((ref) => 1.0);

class CatalogActions {
  final IsarService _isar;
  final SyncService _sync;
  final Ref _ref;

  CatalogActions(this._isar, this._sync, this._ref);

  // Buscar producto por código (alias + principal)
  Future<ProductoEntity?> buscarProductoPorCodigo(String codigo) async {
    try {
      final codigoLimpio = codigo.trim();
      final alias = await _isar.obtenerAliasPorCodigo(codigoLimpio);
      if (alias != null) {
        final producto = await _isar.obtenerProductoPorId(alias.productoId);
        if (producto != null) {
          _ref.read(ultimoFactorProvider.notifier).state = alias.factor;
          return producto;
        }
      }
      final producto = await _isar.obtenerProductoPorCodigoBarrasExacto(codigoLimpio);
      if (producto != null) {
        _ref.read(ultimoFactorProvider.notifier).state = 1.0;
        return producto;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error buscando producto por código: $e');
      return null;
    }
  }

  // Afiliar código a producto existente
  Future<void> afiliarCodigo(String codigo, BuildContext context) async {
    try {
      final productos = await _isar.obtenerProductos();
      if (productos.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay productos disponibles para afiliar. Crea uno primero.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final productoSeleccionado = await showDialog<ProductoEntity>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Producto'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];
                return ListTile(
                  title: Text(p.nombre),
                  subtitle: Text('Código: ${p.codigoBarras} | Stock: ${p.stock}'),
                  onTap: () => Navigator.pop(context, p),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (productoSeleccionado != null) {
        final nuevoAlias = CodigoBarrasAliasEntity()
          ..codigo = codigo.trim()
          ..productoId = productoSeleccionado.id
          ..factor = 1.0
          ..activo = true
          ..fechaAsignacion = DateTime.now()
          ..observaciones = 'Código afiliado desde escaneo'
          ..sincronizado = false;
        await _isar.guardarCodigoAlias(nuevoAlias);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Código "$codigo" afiliado a "${productoSeleccionado.nombre}"'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _ref.read(catalogProvider.notifier).setBusqueda('');
      }
    } catch (e) {
      debugPrint('❌ Error afiliando código: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al afiliar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Crear nuevo producto
  Future<void> crearProducto(String codigo, BuildContext context) async {
    final usuario = _ref.read(usuarioActualProvider);
    if (usuario == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Usuario no autenticado. No se puede crear producto.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        codigoBarrasPrecargado: codigo,
        onGuardar: (producto) async {
          final productosNotifier = _ref.read(productosProvider.notifier);
          await productosNotifier.guardarProducto(producto, usuario, esNuevo: true);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Producto creado exitosamente'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        },
        usuarioActual: usuario,
      ),
    );
  }

  // Mostrar diálogo de cantidad y agregar al carrito
  void mostrarModalCantidad(
    ProductoEntity producto,
    BuildContext context, {
    double factor = 1.0,
  }) {
    showDialog(
      context: context,
      builder: (context) => QuantityDialog(
        producto: producto,
        cantidadInicial: factor,
        onAgregar: (productoModificado, cantidad) {
          agregarAlCarrito(productoModificado, cantidad, context);
        },
      ),
    );
  }

  // 🔥 CORREGIDO Y ROBUSTO: EL STOCK SOLO SE DESCUENTA AL COBRAR
  Future<void> agregarAlCarrito(ProductoEntity producto, double cantidad, BuildContext context) async {
    final usuario = _ref.read(usuarioActualProvider);
    if (usuario == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Usuario no autenticado. No se puede agregar al carrito.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Validación de stock: usamos el stock actual sin modificarlo
      final double stockTotal = producto.stock;

      if (stockTotal < cantidad && !producto.esPesado) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stock insuficiente. Disponible: $stockTotal'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      // 🔥 IMPORTANTE: Ya NO actualizamos el stock aquí. Solo agregamos al carrito.
      HapticFeedback.lightImpact();
      final productItem = ProductItem(
        id: producto.id.toString(),
        codigoBarras: producto.codigoBarras,
        nombre: producto.nombre,
        precioUnidad: producto.precioUnidad,
        esPesado: producto.esPesado,
        categoria: producto.categoria,
      );
      
      // Usamos `stockTotal` (sin restar) como límite máximo para que el carrito no acepte más de lo disponible
      _ref.read(cartProvider.notifier).agregarProducto(
            productItem,
            cantidad: cantidad,
            stockMaximo: stockTotal, 
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${producto.nombre} agregado al carrito.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      _ref.read(catalogProvider.notifier).setBusqueda('');
      
    } catch (e) {
      debugPrint('❌ Error al agregar al carrito: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar al carrito: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Procesar cobro
  Future<void> mostrarModalCobro(BuildContext context, UsuarioEntity? usuarioLogueado) async {
    final cartState = _ref.read(cartProvider);
    if (cartState.total <= 0) return;
    HapticFeedback.mediumImpact();
    double tasaActual = _ref.read(bcvProvider).tasa;
    if (tasaActual.isNaN || tasaActual <= 0) tasaActual = 0.0;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: cartState.total,
        productos: const [],
      ),
    );

    if (resultado != null && resultado['procesado'] == true && context.mounted) {
      final String metodoPago = resultado['metodoPago'] ?? 'Efectivo';
      final double montoRecibido = resultado['montoRecibido'] ?? cartState.total;
      final double cambio = resultado['vuelto'] ?? 0.0;

      final ventaService = _ref.read(ventaServiceProvider);
      await ventaService.procesarVenta(
        context,
        metodoPago: metodoPago,
        cambio: cambio,
        recibido: montoRecibido,
        tasaActual: tasaActual,
        usuarioLogueado: usuarioLogueado,
      );
    }
  }
}

final catalogActionsProvider = Provider<CatalogActions>((ref) {
  final isar = IsarService();
  final sync = SyncService();
  return CatalogActions(isar, sync, ref);
});