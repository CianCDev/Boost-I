import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/producto_entity.dart';
// IMPORTANTE: Asegúrate de tener o crear este modelo

/// Servicio encargado de sincronizar las ventas, catálogo y movimientos (Isar DB)
/// hacia la base de datos remota en la nube (Supabase).
class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Inicia la escucha activa de la conexión a internet.
  void iniciarMonitoreo() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final tieneConexion = results.any((result) => result != ConnectivityResult.none);
      if (tieneConexion) {
        // Al volver el internet, sincroniza todo lo que esté pendiente
        sincronizarVentasPendientes();
        sincronizarMovimientosInventario();
      }
    });
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
  }

  // ==========================================
  // SINCRONIZACIÓN DE VENTAS
  // ==========================================
  Future<int> sincronizarVentasPendientes() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    int ventasSincronizadas = 0;
    try {
      final pendientes = await _isarService.obtenerVentasPendientesSync();
      if (pendientes.isEmpty) return 0;

      debugPrint('🔄 [SyncService] Sincronizando ${pendientes.length} ventas hacia Supabase...');

      for (var venta in pendientes) {
        final exito = await _enviarVentaASupabase(venta);
        if (exito) {
          venta.sincronizado = true;
          await _isarService.guardarVenta(venta);
          ventasSincronizadas++;
        } else {
          break; // Pausa si hay error para no saltarse ventas
        }
      }
    } catch (e) {
      debugPrint('❌ [SyncService] Error general durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }
    return ventasSincronizadas;
  }

  Future<bool> _enviarVentaASupabase(VentaEntity venta) async {
    try {
      final payload = {
        'venta_id': venta.ventaIdString,
        'fecha': venta.fecha.toIso8601String(),
        'subtotal': venta.subtotal,
        'impuesto': venta.impuesto,
        'total': venta.total,
        'tasa_bcv': venta.tasaBcv,
        'total_bolivares': venta.totalBolivares,
        'metodo_pago': venta.metodoPago,
        'documento': venta.documento,
        'empleado': venta.empleado,
      };

      final responseVenta = await _supabase.from('ventas').insert(payload).select('id').single();
      final int ventaIdPk = responseVenta['id'];

      if (venta.items.isNotEmpty) {
        final List<Map<String, dynamic>> itemsPayload = venta.items.map((item) {
          return {
            'venta_id_fk': ventaIdPk,
            'nombre_producto': item.nombreProducto,
            'precio_unidad': item.precioUnidad,
            'cantidad': item.cantidad,
            'subtotal': item.subtotal,
          };
        }).toList();
        await _supabase.from('detalle_ventas').insert(itemsPayload);
      }
      return true;
    } catch (e) {
      debugPrint('🚫 [Supabase] Error al insertar venta ${venta.ventaIdString}: $e');
      return false;
    }
  }

  // ==========================================
  // SINCRONIZACIÓN DE MOVIMIENTOS DE INVENTARIO (NUEVO)
  // ==========================================
  Future<int> sincronizarMovimientosInventario() async {
    try {
      // 1. Buscamos los movimientos locales que no han subido a la nube
      final pendientes = await _isarService.obtenerMovimientosPendientesSync();
      if (pendientes.isEmpty) return 0;
      
      int sincronizados = 0;
      debugPrint('🔄 [SyncService] Sincronizando ${pendientes.length} movimientos de inventario...');

      for (var mov in pendientes) {
        final payload = {
          'producto_id': mov.productoId,
          'nombre_producto': mov.nombreProducto,
          'tipo_movimiento': mov.tipoMovimiento,
          'cantidad': mov.cantidad,
          'stock_resultante': mov.stockResultante,
          'fecha': mov.fecha.toIso8601String(),
          'usuario': mov.usuarioId,
        };

        // 2. Subimos a Supabase
        await _supabase.from('movimientos_inventario').insert(payload);
        
        // 3. Marcamos como sincronizado localmente
        mov.sincronizado = true;
        await _isarService.guardarMovimientoInventario(mov);
        sincronizados++;
      }
      debugPrint('✅ [Supabase] Movimientos sincronizados.');
      return sincronizados;
    } catch (e) {
      debugPrint('🚫 [Supabase] Error al sincronizar movimientos: $e');
      return 0;
    }
  }

  // ==========================================
  // SINCRONIZACIÓN DE PRODUCTOS Y CATEGORÍAS
  // ==========================================
  double _limpiarNumero(double? valor, [double valorPorDefecto = 0.0]) {
    if (valor == null || valor.isNaN || valor.isInfinite) return valorPorDefecto;
    return valor;
  }

  Future<bool> sincronizarCategoriasASupabase() async {
    try {
      final productos = await _isarService.obtenerProductos();
      final nombresCategorias = productos
          .map((p) => p.categoria.trim())
          .where((c) => c.isNotEmpty)
          .toSet();

      if (nombresCategorias.isEmpty) return true;

      final List<Map<String, dynamic>> payload = nombresCategorias.map((n) => {'nombre': n}).toList();
      await _supabase.from('categorias').upsert(payload, onConflict: 'nombre');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sincronizarProductosASupabase() async {
    try {
      final productosLocales = await _isarService.obtenerProductos();
      if (productosLocales.isEmpty) return true;

      final List<Map<String, dynamic>> payloadList = productosLocales.map((p) {
        return {
          'codigo_barras': p.codigoBarras,
          'nombre': p.nombre,
          'precio_unidad': _limpiarNumero(p.precioUnidad, 0.0),
          'stock': _limpiarNumero(p.stock, 0.0),
          'stock_minimo': _limpiarNumero(p.stockMinimo, 5.0),
          'es_pesado': p.esPesado,
          'categoria': p.categoria,
          'proveedor_nombre': p.proveedorNombre,
          'proveedor_telefono': p.proveedorTelefono,
        };
      }).toList();

      await _supabase.from('productos').upsert(payloadList, onConflict: 'codigo_barras');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> descargarProductosDesdeSupabase() async {
    try {
      final List<dynamic> response = await _supabase.from('productos').select();
      if (response.isNotEmpty) {
        for (var item in response) {
          final codigo = item['codigo_barras'] as String;
          final existentes = await _isarService.buscarProductoPorCodigoONombre(codigo);
          final producto = existentes.firstWhere(
            (p) => p.codigoBarras == codigo,
            orElse: () => ProductoEntity(),
          );

          producto.codigoBarras = codigo;
          producto.nombre = item['nombre'] ?? '';
          producto.precioUnidad = (item['precio_unidad'] as num).toDouble();
          producto.stock = (item['stock'] as num).toDouble();
          producto.stockMinimo = (item['stock_minimo'] as num?)?.toDouble() ?? 5.0;
          producto.esPesado = item['es_pesado'] ?? false;
          producto.categoria = item['categoria'] ?? 'General';
          producto.proveedorNombre = item['proveedor_nombre'] ?? '';
          producto.proveedorTelefono = item['proveedor_telefono'] ?? '';

          await _isarService.guardarProducto(producto);
        }
      }
    } catch (e) {
      debugPrint('🚫 Error al descargar productos de Supabase: $e');
    }
  }
}