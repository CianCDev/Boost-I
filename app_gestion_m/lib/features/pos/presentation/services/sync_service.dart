import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';

class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  
  // Endpoint original de ventas (si lo usas)
  final String _apiUrl = 'https://tu-api.com/api/ventas/sync';

  // Valores por defecto, serán sobrescritos si existe assets/config.json
  String _syncServerUrl = 'https://your-sync-server.example';
  String _syncApiKey = '<REPLACE_WITH_SYNC_API_KEY>';

  // Opcional: si quieres exponer Supabase desde el config
  String? _supabaseUrl;
  String? _supabaseAnonKey;

  bool _configLoaded = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Cabeceras de autorización usadas por las llamadas al microservicio
  Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_syncApiKey',
    };
  }

  /// Crea o actualiza un usuario en el backend seguro (microservicio)
  /// Recibe el usuario local y, opcionalmente, email/password (si se desea crear cuenta en Supabase Auth)
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

  Future<void> _loadConfig() async {
    if (_configLoaded) return;
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _syncServerUrl = map['syncServerUrl'] ?? _syncServerUrl;
      _syncApiKey = map['syncApiKey'] ?? _syncApiKey;
      _supabaseUrl = map['supabaseUrl'] ?? _supabaseUrl;
      _supabaseAnonKey = map['supabaseAnonKey'] ?? _supabaseAnonKey;
      _configLoaded = true;
      debugPrint('🔧 SyncService: config cargada desde assets/config.json');
    } catch (e) {
      // Si no existe el archivo o hay error, seguir con valores por defecto
      debugPrint('⚠️ SyncService: no se pudo cargar config (usando valores por defecto): $e');
      _configLoaded = true;
    }
  }

  /// Inicia la escucha activa de la conexión a internet
  void iniciarMonitoreo() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final tieneConexion = results.any((result) => result != ConnectivityResult.none);
      if (tieneConexion) {
        // Disparar múltiples sincronizaciones en paralelo (ventas, movimientos, productos)
        sincronizarVentasPendientes();
        sincronizarMovimientosInventario();
        sincronizarProductosASupabase();
      }
    });
  }

  /// Cancela la suscripción al destruir el servicio
  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
  }

  /// Método principal de sincronización de ventas
  Future<int> sincronizarVentasPendientes() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    int ventasSincronizadas = 0;

    try {
      // 1. Obtener ventas no sincronizadas de Isar
      final pendientes = await _isarService.obtenerVentasPendientesSync();

      if (pendientes.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      debugPrint('🔄 Iniciando sincronización de ${pendientes.length} ventas...');

      for (var venta in pendientes) {
        final exito = await _enviarVentaAlServidor(venta);

        if (exito) {
          // 2. Marcar como sincronizada en la base de datos local
          venta.sincronizado = true;
          await _isarService.guardarVenta(venta);
          ventasSincronizadas++;
        } else {
          // Si una falla, pausamos para reintentar en el siguiente ciclo
          break;
        }
      }
    } catch (e) {
      debugPrint('❌ Error durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }

    return ventasSincronizadas;
  }

  /// Convierte la entidad de Isar a JSON y la envía al backend
  Future<bool> _enviarVentaAlServidor(VentaEntity venta) async {
    try {
      final payload = jsonEncode({
        'venta_id_string': venta.ventaIdString,
        'fecha': venta.fecha.toIso8601String(),
        'total': venta.total,
        'subtotal': venta.subtotal,
        'impuesto': venta.impuesto,
        'metodo_pago': venta.metodoPago,
        'cedula_cliente': venta.cedulaCliente,
        'empleado': venta.empleado,
        'items': venta.items.map((item) => {
          'nombre_producto': item.nombreProducto,
          'precio_unidad': item.precioUnidad,
          'cantidad': item.cantidad,
          'subtotal': item.subtotal,
        }).toList(),
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Venta ${venta.ventaIdString} subida con éxito');
        return true;
      } else {
        debugPrint('⚠️ Error backend (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('🚫 Error de red al enviar venta ${venta.ventaIdString}: $e');
      return false;
    }
  }

  // ==================== SINCRONIZACIÓN DE PRODUCTOS ====================

  /// Envía el catálogo de productos al backend. Actualmente envía todos los productos.
  Future<void> sincronizarProductosASupabase() async {
    await _loadConfig();
    try {
      final productos = await _isarService.obtenerProductos();
      if (productos.isEmpty) return;

      debugPrint('🔄 Enviando ${productos.length} productos al backend...');

      // Por simplicidad enviamos todos los productos en un solo payload
      final payload = jsonEncode({
        'productos': productos.map((p) => {
          'codigo_barras': p.codigoBarras,
          'nombre': p.nombre,
          'precio_unidad': p.precioUnidad,
          'stock': p.stock,
          'es_pesado': p.esPesado,
          'categoria': p.categoria,
          'proveedor_nombre': p.proveedorNombre,
          'proveedor_telefono': p.proveedorTelefono,
          'stock_minimo': p.stockMinimo,
        }).toList(),
      });

      // Endpoint hipotético para productos
      final response = await http.post(
        Uri.parse('$_syncServerUrl/api/productos/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \\${_syncApiKey}',
        },
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Productos sincronizados con éxito');
      } else {
        debugPrint('⚠️ Error backend productos (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('🚫 Error enviando productos: $e');
    }
  }

  // ==================== SINCRONIZACIÓN DE MOVIMIENTOS DE INVENTARIO ====================

  Future<int> sincronizarMovimientosInventario() async {
    final pendientes = await _isarService.obtenerMovimientosPendientesSync();
    if (pendientes.isEmpty) return 0;

    int sincronizados = 0;

    for (var mov in pendientes) {
      final exito = await _enviarMovimientoAlServidor(mov);
      if (exito) {
        mov.sincronizado = true;
        await _isarService.guardarMovimientoInventario(mov);
        sincronizados++;
      } else {
        break;
      }
    }

    return sincronizados;
  }

  Future<bool> _enviarMovimientoAlServidor(MovimientoInventarioEntity mov) async {
    await _loadConfig();
    try {
      final payload = jsonEncode({
        'productoId': mov.productoId,
        'nombreProducto': mov.nombreProducto,
        'tipoMovimiento': mov.tipoMovimiento,
        'cantidad': mov.cantidad,
        'stockResultante': mov.stockResultante,
        'fecha': mov.fecha.toIso8601String(),
        'usuarioId': mov.usuarioId,
      });

      final response = await http.post(
        Uri.parse('$_syncServerUrl/api/inventario/movimientos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \\${_syncApiKey}',
        },
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Movimiento ${mov.id} sincronizado');
        return true;
      } else {
        debugPrint('⚠️ Error backend movimiento (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('🚫 Error enviando movimiento ${mov.id}: $e');
      return false;
    }
  }
}