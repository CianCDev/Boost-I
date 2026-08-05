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
import '../../data/Local/entities/turno_entity.dart';
import '../../data/Local/entities/detalle_venta_entity.dart';


/// Servicio encargado de sincronizar ventas, catálogo, movimientos y turnos
/// hacia la base de datos remota (Supabase).
class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  final SupabaseClient _supabase = Supabase.instance.client;

  String _syncServerUrl = 'https://your-sync-server.example';
  String _syncApiKey = '<REPLACE_WITH_SYNC_API_KEY>';

  bool _configLoaded = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_syncApiKey',
    };
  }

  Future<void> _loadConfig() async {
    if (_configLoaded) return;
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _syncServerUrl = map['syncServerUrl'] ?? _syncServerUrl;
      _syncApiKey = map['syncApiKey'] ?? _syncApiKey;
      _configLoaded = true;
      debugPrint('🔧 SyncService: config cargada');
    } catch (e) {
      debugPrint('⚠️ SyncService: usando valores por defecto: $e');
      _configLoaded = true;
    }
  }

  void iniciarMonitoreo() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final tieneConexion = results.any((result) => result != ConnectivityResult.none);
      if (tieneConexion) {
        sincronizarVentasPendientes();
        sincronizarMovimientosInventario();
        sincronizarProductosASupabase();
        sincronizarTurnos();
      }
    });
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
  }

  // ==========================================
  // SINCRONIZACIÓN DE USUARIOS (SIN 'activo')
  // ==========================================

  Future<void> sincronizarUsuariosASupabase() async {
    try {
      final usuarios = await _isarService.obtenerUsuarios();
      if (usuarios.isEmpty) {
        debugPrint('ℹ️ No hay usuarios locales para sincronizar');
        return;
      }

      debugPrint('🔄 Sincronizando ${usuarios.length} usuarios con Supabase...');
      int sincronizados = 0;

      for (var usuario in usuarios) {
        try {
          final existing = await _supabase
              .from('usuarios')
              .select('id')
              .eq('id_isar', usuario.id)
              .maybeSingle();

          final data = {
            'id_isar': usuario.id,
            'nombre': usuario.nombre,
            'pin': usuario.pin,
            'rol': usuario.rol,
            'email': usuario.email ?? '',
            'device_id': usuario.deviceId ?? '',
            'estado': usuario.estado,  // ✅ solo 'estado' (activo, inactivo, etc.)
            'caja_asignada': usuario.cajaAsignada,
          };

          if (existing == null) {
            await _supabase.from('usuarios').insert(data);
            debugPrint('✅ Usuario "${usuario.nombre}" creado en Supabase');
          } else {
            await _supabase
                .from('usuarios')
                .update(data)
                .eq('id_isar', usuario.id);
            debugPrint('✅ Usuario "${usuario.nombre}" actualizado en Supabase');
          }
          sincronizados++;
        } catch (e) {
          debugPrint('⚠️ Error sincronizando usuario "${usuario.nombre}": $e');
        }
      }
      debugPrint('✅ $sincronizados usuarios sincronizados con Supabase');
    } catch (e) {
      debugPrint('❌ Error general sincronizando usuarios: $e');
    }
  }

  Future<void> descargarUsuariosDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .order('id_isar');

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay usuarios en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} usuarios desde Supabase...');

      for (var data in response) {
        final usuario = UsuarioEntity()
          ..id = data['id_isar'] ?? 0
          ..nombre = data['nombre'] ?? ''
          ..pin = data['pin'] ?? '0000'
          ..rol = data['rol'] ?? 'cajero'
          ..email = data['email'] ?? ''
          ..deviceId = data['device_id'] ?? ''
          ..estado = data['estado'] ?? 'inactivo'   // ← solo 'estado'
          ..cajaAsignada = data['caja_asignada'] ?? '';

        if (usuario.id > 0) {
          await _isarService.guardarUsuario(usuario);
        } else {
          debugPrint('⚠️ Usuario sin id_isar válido: ${data['nombre']}');
        }
      }
      debugPrint('✅ ${response.length} usuarios descargados desde Supabase');
    } catch (e) {
      debugPrint('❌ Error descargando usuarios: $e');
    }
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
      if (pendientes.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      debugPrint('🔄 [SyncService] Sincronizando ${pendientes.length} ventas...');

      for (var venta in pendientes) {
        final exito = await _enviarVentaAlServidor(venta);
        if (exito) {
          await _isarService.actualizarSyncStatusVenta(venta.id, 'synced');
          ventasSincronizadas++;
        } else {
          await _isarService.actualizarSyncStatusVenta(venta.id, 'failed');
          debugPrint('⚠️ Venta ${venta.ventaIdString} marcada como failed');
        }
      }
    } catch (e) {
      debugPrint('❌ [SyncService] Error general durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }
    return ventasSincronizadas;
  }

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
        'sync_status': 'synced',
      };

      // Microservicio (opcional)
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

      // Fallback: Supabase directo
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
      for (var mov in pendientes) {
        final exito = await _enviarMovimientoAlServidor(mov);
        if (exito) {
          await _isarService.actualizarSyncStatusMovimiento(mov.id, 'synced');
          sincronizados++;
        } else {
          await _isarService.actualizarSyncStatusMovimiento(mov.id, 'failed');
          debugPrint('⚠️ Movimiento ${mov.id} marcado como failed');
        }
      }
      debugPrint('✅ $sincronizados movimientos sincronizados.');
      return sincronizados;
    } catch (e) {
      debugPrint('🚫 [Supabase] Error al sincronizar movimientos: $e');
      return 0;
    }
  }

  Future<bool> _enviarMovimientoAlServidor(MovimientoInventarioEntity mov) async {
    await _loadConfig();
    try {
      final rpcResponse = await _supabase.rpc(
        'ajustar_stock',
        params: {
          'p_producto_id': mov.productoId,
          'p_cantidad': mov.cantidad.toInt(),
          'p_tipo_movimiento': mov.tipoMovimiento,
        },
      );

      if (rpcResponse == true) {
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
        debugPrint('⚠️ RPC ajustar_stock devolvió false');
        return false;
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
      debugPrint('✅ ${productosLocales.length} productos sincronizados');
      return true;
    } catch (e) {
      debugPrint('🚫 Error sincronizando productos: $e');
      return false;
    }
  }

  Future<void> descargarProductosDesdeSupabase() async {
    // ... (igual que antes, sin cambios)
  }

  // ==========================================
  // GESTIÓN DE USUARIOS (sin 'activo')
  // ==========================================

  Future<Map<String, dynamic>?> crearUsuarioEnServidor(UsuarioEntity usuario, {String? email, String? password}) async {
    await _loadConfig();
    try {
      final payload = jsonEncode({
        'nombre': usuario.nombre,
        'rol': usuario.rol,
        'email': email,
        'password': password,
        // ✅ eliminado 'activo' porque no existe en la tabla
      });

      final response = await http.post(
        Uri.parse('$_syncServerUrl/api/usuarios'),
        headers: _authHeaders(),
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🚫 Error en crearUsuarioEnServidor: $e');
      return null;
    }
  }

  Future<void> sincronizarTodo() async {
    await sincronizarVentasPendientes();
    await sincronizarMovimientosInventario();
    await sincronizarProductosASupabase();
    await sincronizarCategoriasASupabase();
    await sincronizarTurnos();
  }

  // ==========================================
  // STREAM DE USUARIOS EN TIEMPO REAL
  // ==========================================
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
               ..deviceId = row['device_id'] as String? ?? '';
          }).toList();
        });
  }

  Future<bool> actualizarEstadoUsuarioEnSupabase(int userId, String nuevoEstado) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .update({'estado': nuevoEstado})
          .eq('id_isar', userId)
          .select();

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error actualizando estado usuario: $e');
      return false;
    }
  }

  // ==========================================
  // SINCRONIZACIÓN DE TURNOS
  // ==========================================

  Future<int> sincronizarTurnos() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    int sincronizados = 0;

    try {
      final pendientes = await _isarService.obtenerTurnosPendientes();
      if (pendientes.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      debugPrint('🔄 [SyncService] Sincronizando ${pendientes.length} turnos...');

      for (var turno in pendientes) {
        final exito = await _enviarTurnoAlServidor(turno);
        if (exito) {
          await _isarService.marcarTurnoComoSincronizado(turno.id);
          sincronizados++;
          debugPrint('✅ Turno ${turno.id} sincronizado');
        } else {
          debugPrint('⚠️ Turno ${turno.id} falló, se reintentará después');
        }
      }

      debugPrint('✅ $sincronizados turnos sincronizados');
      return sincronizados;
    } catch (e) {
      debugPrint('❌ Error sincronizando turnos: $e');
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _enviarTurnoAlServidor(TurnoEntity turno) async {
    try {
      final Map<String, dynamic> payload = {
        'monto_inicial': turno.montoInicial,
        'monto_final': turno.montoFinal ?? 0.0,
        'fecha_apertura': turno.fechaApertura.toIso8601String(),
        'estado': turno.estado,
        'sync_status': 'pending',
        'id_isar': turno.id,
      };

      if (turno.fechaCierre != null) {
        payload['fecha_cierre'] = turno.fechaCierre!.toIso8601String();
      }

      debugPrint('📤 Enviando turno a tabla turno_cajas');
      debugPrint('📤 Payload: ${jsonEncode(payload)}');

      await _supabase.from('turno_cajas').insert(payload);
      debugPrint('✅ Turno sincronizado correctamente');
      return true;
    } catch (e) {
      debugPrint('🚫 Error al enviar turno: $e');
      return false;
    }
  }

  /// Descarga todas las ventas desde Supabase y las guarda localmente (Isar)
Future<void> descargarVentasDesdeSupabase() async {
  try {
    final response = await _supabase
        .from('ventas')
        .select()
        .order('fecha', ascending: false);

    if (response.isEmpty) {
      debugPrint('ℹ️ No hay ventas en Supabase para descargar');
      return;
    }

    debugPrint('🔄 Descargando ${response.length} ventas desde Supabase...');

    // Para cada venta, convertir los datos de Supabase a VentaEntity y guardar en Isar
    for (var data in response) {
      // Crear la venta
      final venta = VentaEntity()
        ..ventaIdString = data['venta_id'] ?? ''
        ..fecha = DateTime.parse(data['fecha']).toLocal()
        ..subtotal = (data['subtotal'] as num).toDouble()
        ..impuesto = (data['impuesto'] as num).toDouble()
        ..total = (data['total'] as num).toDouble()
        ..tasaBcv = (data['tasa_bcv'] as num?)?.toDouble() ?? 0.0
        ..totalBolivares = (data['total_bolivares'] as num?)?.toDouble() ?? 0.0
        ..metodoPago = data['metodo_pago'] ?? ''
        ..documento = data['documento'] ?? ''
        ..empleado = data['empleado'] ?? ''
        ..syncStatus = 'synced' // Ya sincronizado
        // Si necesitas más campos, ajustar
        ;

      // Guardar en Isar
      await _isarService.guardarVenta(venta);
    }

    debugPrint('✅ ${response.length} ventas descargadas y guardadas localmente');
  } catch (e) {
    debugPrint('❌ Error descargando ventas: $e');
  }
}

// ==================== GESTIÓN DE DETALLES DE VENTA ====================

/// Obtiene todos los detalles de una venta por su ID
// ==================== GESTIÓN DE DETALLES DE VENTA ====================


  void dispose() {
    detenerMonitoreo();
  }
}