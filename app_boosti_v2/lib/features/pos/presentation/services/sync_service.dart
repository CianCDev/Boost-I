import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
// ✅ Eliminado: import '../services/sync_service.dart';

/// Servicio encargado de sincronizar las ventas, catálogo y movimientos (Isar DB)
/// hacia la base de datos remota en la nube (Supabase).
class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Valores por defecto, serán sobrescritos si existe assets/config.json
  String _syncServerUrl = 'https://your-sync-server.example';
  String _syncApiKey = '<REPLACE_WITH_SYNC_API_KEY>';

  bool _configLoaded = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Cabeceras de autorización centralizadas
  Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_syncApiKey',
    };
  }

  /// Carga la configuración desde assets/config.json solo una vez
  Future<void> _loadConfig() async {
    if (_configLoaded) return;
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _syncServerUrl = map['syncServerUrl'] ?? _syncServerUrl;
      _syncApiKey = map['syncApiKey'] ?? _syncApiKey;
      _configLoaded = true;
      debugPrint('🔧 SyncService: config cargada desde assets/config.json');
    } catch (e) {
      debugPrint('⚠️ SyncService: no se pudo cargar config (usando valores por defecto): $e');
      _configLoaded = true;
    }
  }

  /// Inicia la escucha activa de la conexión a internet
  void iniciarMonitoreo() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final tieneConexion = results.any((result) => result != ConnectivityResult.none);
      if (tieneConexion) {
        // Al volver el internet, sincroniza todo lo que esté pendiente
        sincronizarVentasPendientes();
        sincronizarMovimientosInventario();
        sincronizarProductosASupabase();
      }
    });
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
  }

  // ==========================================
  // SINCRONIZACIÓN DE VENTAS
  // ==========================================

  /// Método principal de sincronización de ventas
  Future<int> sincronizarVentasPendientes() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    int ventasSincronizadas = 0;

    try {
      final pendientes = await _isarService.obtenerVentasPendientesSync();
      if (pendientes.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      debugPrint('🔄 [SyncService] Sincronizando ${pendientes.length} ventas hacia Supabase...');

      for (var venta in pendientes) {
        final exito = await _enviarVentaAlServidor(venta);
        if (exito) {
          // ✅ Actualizar syncStatus a 'synced' usando el método dedicado
          await _isarService.actualizarSyncStatusVenta(venta.id, 'synced');
          ventasSincronizadas++;
        } else {
          // ✅ Marcar como 'failed' si falla
          await _isarService.actualizarSyncStatusVenta(venta.id, 'failed');
          debugPrint('⚠️ Venta ${venta.ventaIdString} marcada como failed');
          // No interrumpimos el ciclo, seguimos con las demás
        }
      }
    } catch (e) {
      debugPrint('❌ [SyncService] Error general durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }
    return ventasSincronizadas;
  }

  /// Convierte la entidad de Isar a JSON y la envía al backend
  Future<bool> _enviarVentaAlServidor(VentaEntity venta) async {
    await _loadConfig();
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
        'sync_status': 'synced', // Lo marcamos como sincronizado directamente en la nube
      };

      // Intentar primero con el microservicio
      try {
        final response = await http.post(
          Uri.parse('$_syncServerUrl/api/ventas/sync'),
          headers: _authHeaders(),
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ Venta ${venta.ventaIdString} sincronizada vía microservicio');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ Microservicio falló, intentando con Supabase directo: $e');
      }

      // Fallback: intentar con Supabase directo
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

      debugPrint('✅ Venta ${venta.ventaIdString} sincronizada vía Supabase directo');
      return true;
    } catch (e) {
      debugPrint('🚫 [Supabase] Error al insertar venta ${venta.ventaIdString}: $e');
      return false;
    }
  }

  // ==========================================
  // SINCRONIZACIÓN DE MOVIMIENTOS DE INVENTARIO
  // ==========================================

  Future<int> sincronizarMovimientosInventario() async {
    try {
      final pendientes = await _isarService.obtenerMovimientosPendientesSync();
      if (pendientes.isEmpty) return 0;

      int sincronizados = 0;
      debugPrint('🔄 [SyncService] Sincronizando ${pendientes.length} movimientos de inventario...');

      for (var mov in pendientes) {
        final exito = await _enviarMovimientoAlServidor(mov);
        if (exito) {
          // ✅ Actualizar syncStatus a 'synced'
          await _isarService.actualizarSyncStatusMovimiento(mov.id, 'synced');
          sincronizados++;
        } else {
          // ✅ Marcar como 'failed' si falla
          await _isarService.actualizarSyncStatusMovimiento(mov.id, 'failed');
          debugPrint('⚠️ Movimiento ${mov.id} marcado como failed');
        }
      }

      debugPrint('✅ [Supabase] $sincronizados movimientos sincronizados.');
      return sincronizados;
    } catch (e) {
      debugPrint('🚫 [Supabase] Error al sincronizar movimientos: $e');
      return 0;
    }
  }

  Future<bool> _enviarMovimientoAlServidor(MovimientoInventarioEntity mov) async {
    await _loadConfig();
    try {
      // ✅ PASO 1: Ajustar el stock usando la RPC (operación atómica)
      final rpcResponse = await _supabase.rpc(
        'ajustar_stock',
        params: {
          'p_producto_id': mov.productoId, // Debe ser el UUID de Supabase, ajusta si usas otro identificador
          'p_cantidad': mov.cantidad.toInt(),
          'p_tipo_movimiento': mov.tipoMovimiento, // 'salida' o 'entrada'
        },
      );

      if (rpcResponse == true) {
        // PASO 2: Registrar el movimiento en la tabla de movimientos
        final payload = {
          'producto_id': mov.productoId,
          'nombre_producto': mov.nombreProducto,
          'tipo_movimiento': mov.tipoMovimiento,
          'cantidad': mov.cantidad,
          'stock_resultante': mov.stockResultante,
          'fecha': mov.fecha.toIso8601String(),
          'usuario_id': mov.usuarioId,
          'sync_status': 'synced',
        };

        await _supabase.from('movimientos_inventario').insert(payload);
        debugPrint('✅ Movimiento ${mov.id} sincronizado vía RPC');
        return true;
      } else {
        debugPrint('⚠️ RPC ajustar_stock devolvió false para producto ${mov.productoId} (sin stock)');
        return false; // Se marcará como failed
      }
    } catch (e) {
      debugPrint('🚫 Error enviando movimiento ${mov.id}: $e');
      return false;
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
      debugPrint('🚫 Error sincronizando categorías: $e');
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
      debugPrint('✅ ${productosLocales.length} productos sincronizados con Supabase');
      return true;
    } catch (e) {
      debugPrint('🚫 Error sincronizando productos: $e');
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
        debugPrint('✅ ${response.length} productos descargados desde Supabase');
      }
    } catch (e) {
      debugPrint('🚫 Error al descargar productos de Supabase: $e');
    }
  }

  // ==========================================
  // GESTIÓN DE USUARIOS
  // ==========================================

  /// Crea o actualiza un usuario en el backend seguro (microservicio)
  Future<Map<String, dynamic>?> crearUsuarioEnServidor(UsuarioEntity usuario, {String? email, String? password}) async {
    await _loadConfig();
    try {
      final payload = jsonEncode({
        'nombre': usuario.nombre,
        'rol': usuario.rol,
        'activo': usuario.activo,
        'email': email,
        'password': password,
      });

      final response = await http.post(
        Uri.parse('$_syncServerUrl/api/usuarios'),
        headers: _authHeaders(),
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      debugPrint('⚠️ crearUsuarioEnServidor: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('🚫 Error en crearUsuarioEnServidor: $e');
      return null;
    }
  }

  /// Sincroniza todos los datos pendientes
  Future<void> sincronizarTodo() async {
    await sincronizarVentasPendientes();
    await sincronizarMovimientosInventario();
    await sincronizarProductosASupabase();
    await sincronizarCategoriasASupabase();
  }

  /// Stream para monitorear usuarios en tiempo real (para el monitor de empleados)
  Stream<List<UsuarioEntity>> streamUsuariosEnTiempoReal() {
    return _supabase
        .from('usuarios')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data.map<UsuarioEntity>((row) {
            return UsuarioEntity()
               ..id = row['id_isar'] as int
            ..nombre = row['nombre'] as String
            ..rol = row['rol'] as String
            ..estado = row['estado'] as String? ?? 'inactivo'
            ..deviceId = row['device_id'] as String? ?? '';   // <--- NUEVO
          }).toList();
        });
  }

  /// Actualiza el estado de un usuario en Supabase (activo/inactivo)
  Future<bool> actualizarEstadoUsuarioEnSupabase(int userId, String nuevoEstado) async {
    try {
      debugPrint('🔍 Intentando actualizar userId: $userId a estado: $nuevoEstado');

      final response = await _supabase
          .from('usuarios')
          .update({'estado': nuevoEstado})
          .eq('id_isar', userId)
          .select();

      debugPrint('✅ Filas afectadas: ${response.length}');
      if (response.isNotEmpty) {
        debugPrint('✅ Usuario actualizado: ${response.first}');
      }
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error en actualizarEstadoUsuarioEnSupabase: $e');
      return false;
    }
  }

  /// Limpia recursos
  void dispose() {
    detenerMonitoreo();
  }
}