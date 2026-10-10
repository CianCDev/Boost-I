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
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_dialog.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';

final ultimoFactorProvider = StateProvider<double>((ref) => 1.0);

class CatalogActions {
  final IsarService _isar;
  // ignore: unused_field
  final SyncService _sync;
  final Ref _ref;

  CatalogActions(this._isar, this._sync, this._ref);

  // ═══════════════════════════════════════════════════════════════════
  // BÚSQUEDA DE PRODUCTO
  // ═══════════════════════════════════════════════════════════════════

  /// Busca producto por código de barras (alias o principal).
  Future<ProductoEntity?> buscarProductoPorCodigo(String codigo) async {
    final codigoLimpio = codigo.trim();
    final alias = await _isar.obtenerAliasPorCodigo(codigoLimpio);
    if (alias != null) {
      final producto = await _isar.obtenerProductoPorId(alias.productoId);
      if (producto != null) {
        _ref.read(ultimoFactorProvider.notifier).state = alias.factor;
        return producto;
      }
    }
    final producto =
        await _isar.obtenerProductoPorCodigoBarrasExacto(codigoLimpio);
    if (producto != null) {
      _ref.read(ultimoFactorProvider.notifier).state = 1.0;
      return producto;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // AFILIAR CÓDIGO
  // ═══════════════════════════════════════════════════════════════════

  Future<void> afiliarCodigo(String codigo, BuildContext context) async {
    final productos = await _isar.obtenerProductos();
    if (productos.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No hay productos disponibles para afiliar. Crea uno primero.'),
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
              return FutureBuilder<double>(
                future: _isar.obtenerStockTotalPorProducto(p.id),
                builder: (context, snapshot) {
                  final stock = snapshot.data ?? 0.0;
                  return ListTile(
                    title: Text(p.nombre),
                    subtitle: Text('Código: ${p.codigoBarras} | Stock: $stock'),
                    onTap: () => Navigator.pop(context, p),
                  );
                },
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
            content: Text(
                '✅ Código "$codigo" afiliado a "${productoSeleccionado.nombre}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _ref.read(catalogProvider.notifier).setBusqueda('');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREAR PRODUCTO
  // ═══════════════════════════════════════════════════════════════════

  Future<void> crearProducto(String codigo, BuildContext context) async {
    final usuario = _ref.read(usuarioActualProvider);
    if (usuario == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('⚠️ Usuario no autenticado. No se puede crear producto.'),
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
          await productosNotifier.guardarProducto(producto, usuario,
              esNuevo: true);
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

  // ═══════════════════════════════════════════════════════════════════
  // MOSTRAR MODAL DE CANTIDAD
  // ═══════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════
  // AGREGAR AL CARRITO
  // ═══════════════════════════════════════════════════════════════════
  //
  // 🎯 FIX CRÍTICO: Validación estricta de stock.
  //
  //   Reglas aplicadas:
  //     1. Si stock <= 0 → diálogo bloqueante "Sin stock" (no agrega).
  //     2. Si cantidad > stock → ajustar a stock (SnackBar informativo).
  //     3. El nuevo stock NUNCA queda negativo (clamp a 0).
  //
  //   Antes: se mostraba un SnackBar pero igual se seguía con el flujo,
  //   provocando stock negativo al vender productos agotados.
  //
  void agregarAlCarrito(
    ProductoEntity producto,
    double cantidad,
    BuildContext context,
  ) {
    final usuario = _ref.read(usuarioActualProvider);
    if (usuario == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️ Usuario no autenticado. No se puede agregar al carrito.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _isar.obtenerStockTotalPorProducto(producto.id).then((stockTotal) async {
      // ── Caso 1: producto agotado → bloquear ──
      if (stockTotal <= 0) {
        if (context.mounted) {
          _mostrarDialogoSinStock(context, producto);
        }
        return;
      }

      // ── Caso 2: cantidad excede stock → ajustar ──
      double cantidadFinal = cantidad;
      if (cantidadFinal > stockTotal) {
        cantidadFinal = stockTotal;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Solo hay ${stockTotal.toStringAsFixed(producto.esPesado ? 3 : 0)} '
                'disponibles. Se ajustó la cantidad.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // ── Agregar al carrito (Fase 1: SIN descontar stock) ──
      //
      //   El carrito NO es una venta. Agregar un producto solo lo anota
      //   en la lista; el stock se descuenta al confirmar el cobro
      //   (Fase 2, dentro de la transacción de `procesarVenta`).
      //
      //   Antes se llamaba `actualizarStock()` aquí, lo que producía
      //   3 fallos encadenados:
      //     1. El stock se perdía para siempre: `eliminarItem()` del
      //        carrito no tiene forma de devolverlo.
      //     2. Generaba un `MovimientoInventarioEntity` con
      //        `motivo: 'Venta'` y lo sincronizaba a Supabase al
      //        instante, aunque la venta nunca se cobrara.
      //     3. `obtenerStockTotalPorProducto()` devuelve el stock de
      //        LOTES, no `productos.stock`, así que el campo quedaba
      //        sobrescrito con el valor de otro origen.
      HapticFeedback.lightImpact();
      final productItem = ProductItem(
        id: producto.id.toString(),
        codigoBarras: producto.codigoBarras,
        nombre: producto.nombre,
        precioUnidad: producto.precioUnidad,
        esPesado: producto.esPesado,
        categoria: producto.categoria,
      );
      _ref.read(cartProvider.notifier).agregarProducto(
            productItem,
            cantidad: cantidadFinal,
            stockMaximo: stockTotal,
            // R.3: destino de preparación del plato (KDS). `null` si el
            // producto no requiere preparación.
            estacionId: producto.departamentoId,
            // R.3.2: foto del producto, para la miniatura del KDS y de la
            // comanda. `ProductoEntity` es el único punto donde vive la
            // URL, así que hay que copiarla aquí.
            imagenUrl: producto.imagenUrl,
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
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al verificar stock: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // DIÁLOGO BLOQUEANTE: SIN STOCK
  // ═══════════════════════════════════════════════════════════════════

  /// Muestra un diálogo bloqueante cuando el producto no tiene stock.
  ///
  /// Usa `GlassDialog` para mantener consistencia visual con el resto
  /// de la app. No permite "continuar"; solo cerrar y elegir otro
  /// producto.
  void _mostrarDialogoSinStock(
    BuildContext context,
    ProductoEntity producto,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GlassDialog(
        maxWidth: 420,
        accentColor: const Color(0xFFEF4444),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icono ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFFEF4444),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),

              // ── Título ──
              const Text(
                'Producto sin stock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // ── Mensaje ──
              Text(
                '"${producto.nombre}" no tiene unidades disponibles.\n\n'
                'Repón el stock en el inventario antes de intentar venderlo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // ── Botón cerrar ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COBRO
  // ═══════════════════════════════════════════════════════════════════

  /// Abre el diálogo de cobro y procesa la venta.
///
/// R.2: devuelve `true` si `procesarVenta` completó sin lanzar. Es un
/// cambio ADITIVO: los callers existentes hacen `await` e ignoran el
/// retorno, así que no se rompen.
///
/// Lo usa `ComandaScreen` para decidir si cerrar la comanda.
Future<bool> mostrarModalCobro(
    BuildContext context,
    UsuarioEntity? usuarioLogueado,
  ) async {
    final cartState = _ref.read(cartProvider);
    if (cartState.total <= 0) return false;

    // 🎯 Guard extra: aunque el botón ya está deshabilitado,
    //    defendemos aquí por si el estado se modificó por otra vía.
    //
    //    `hayItemsSinStock` recibe los productos porque el carrito no
    //    descuenta stock (Fase 1): el disponible real es
    //    `producto.stock`, no `producto.stock - cantidadEnCarrito`.
    final productos = _ref.read(productosProvider).items;
    if (cartState.hayItemsSinStock(productos)) {
      return false;
    }

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

    if (resultado != null &&
        resultado['procesado'] == true &&
        context.mounted) {
      final String metodoPago = resultado['metodoPago'] ?? 'Efectivo';
      final double montoRecibido =
          resultado['montoRecibido'] ?? cartState.total;
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
      return true;
    }

    // El usuario cerró el diálogo sin cobrar.
    return false;
  }
}

final catalogActionsProvider = Provider<CatalogActions>((ref) {
  final isar = IsarService();
  final sync = SyncService();
  return CatalogActions(isar, sync, ref);
});