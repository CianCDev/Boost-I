import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../../data/Local/entities/gasto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../../data/Local/entities/detalle_venta_entity.dart';
import '../../data/Local/entities/proveedor_entity.dart';
import '../../data/Local/entities/recepcion_entity.dart';
import '../../data/Local/entities/pedido_entity.dart';
import '../../data/Local/entities/detalle_pedido_entity.dart';
import '../../data/Local/entities/local_entity.dart';
import '../../data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';

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

  bool _hasValidSyncConfig() {
    return _syncServerUrl.isNotEmpty &&
        _syncServerUrl != 'https://your-sync-server.example' &&
        _syncApiKey.isNotEmpty &&
        _syncApiKey != '<REPLACE_WITH_SYNC_API_KEY>';
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
        sincronizarTodo();
      }
    });
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
  }

  // ==========================================
  // SINCRONIZACIÓN DE USUARIOS (hacia Supabase)
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
              .select('id_isar')
              .eq('id_isar', usuario.id)
              .maybeSingle();

          final data = {
            'id_isar': usuario.id,
            'nombre': usuario.nombre,
            'pin': usuario.pin,
            'rol': usuario.rol,
            'email': usuario.email ?? '',
            'device_id': usuario.deviceId ?? '',
            'estado': usuario.estado,
            'caja_asignada': usuario.cajaAsignada,
            'departamento': (usuario.departamento != null && usuario.departamento!.isNotEmpty) ? usuario.departamento : null,
          };

          if (existing == null) {
            await _supabase.from('usuarios').insert(data);
          } else {
            await _supabase
                .from('usuarios')
                .update(data)
                .eq('id_isar', usuario.id);
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

  Future<bool> eliminarUsuarioEnSupabase(int userId) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .delete()
          .eq('id_isar', userId)
          .select();
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error eliminando usuario en Supabase: $e');
      return false;
    }
  }

  Future<double> obtenerTotalVentasPorEmpleadoYRango(
    String empleado,
    DateTime inicio,
    DateTime fin,
  ) async {
    final isar = await _isarService.db;
    final ventas = await isar.ventaEntitys
        .filter()
        .empleadoEqualTo(empleado)
        .and()
        .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
        .findAll();

    double total = 0;
    for (var v in ventas) {
      total += v.total;
    }
    return total;
  }

  Future<bool> eliminarProveedorEnSupabase(String supabaseId) async {
    try {
      final response = await _supabase
          .from('proveedores')
          .delete()
          .eq('id', supabaseId)
          .select();
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error eliminando proveedor en Supabase: $e');
      return false;
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

      if (_hasValidSyncConfig()) {
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
      } else {
        debugPrint('ℹ️ No hay configuración válida de syncServerUrl/syncApiKey; se usa Supabase directo.');
      }

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
          await _supabase.from('movimientos_inventarios').insert(payload);
          debugPrint('✅ Movimiento ${mov.id} sincronizado vía RPC');
          return true;
        } else {
          debugPrint('⚠️ RPC ajustar_stock devolvió false');
          return false;
        }
      } catch (rpcError) {
        debugPrint('⚠️ RPC falló, intentando directo: $rpcError');

        final producto = await _isarService.obtenerProductoPorId(mov.productoId);
        if (producto != null && producto.codigoBarras.isNotEmpty) {
          await _supabase
              .from('productos')
              .update({'stock': mov.stockResultante})
              .eq('codigo_barras', producto.codigoBarras);

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
          await _supabase.from('movimientos_inventarios').insert(payload);
          debugPrint('✅ Movimiento ${mov.id} sincronizado vía directa');
          return true;
        } else {
          debugPrint('⚠️ Producto no encontrado o sin código de barras para movimiento ${mov.id}');
          return false;
        }
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

  /// ✅ Sincroniza productos y actualiza supabaseId local
  Future<bool> sincronizarProductosASupabase() async {
  try {
    final productosLocales = await _isarService.obtenerProductos();
    if (productosLocales.isEmpty) return true;

    // Enviamos todos los productos (upsert por código de barras)
    final List<Map<String, dynamic>> payloadList = productosLocales.map((p) {
      return {
        'id_isar': p.id,
        'codigo_barras': p.codigoBarras,
        'nombre': p.nombre,
        'precio_unidad': _limpiarNumero(p.precioUnidad, 0.0),
        'stock': _limpiarNumero(p.stock, 0.0),
        'stock_minimo': _limpiarNumero(p.stockMinimo, 5.0),
        'es_pesado': p.esPesado,
        'categoria': p.categoria,
        'proveedor_nombre': p.proveedorNombre,
        'proveedor_telefono': p.proveedorTelefono,
        'imagen_url': p.imagenUrl,
      };
    }).toList();

    // Realizar upsert
    await _supabase
        .from('productos')
        .upsert(payloadList, onConflict: 'codigo_barras');

    // Ahora obtener los IDs de Supabase para todos los productos locales
    final idsIsar = productosLocales.map((p) => p.id).toList();
    final response = await _supabase
        .from('productos')
        .select('id, id_isar')
        .inFilter('id_isar', idsIsar);

    // Mapear id_isar -> supabaseId
    final Map<int, String> mapa = {};
    for (var row in response) {
      final idIsar = row['id_isar'] as int?;
      final supabaseId = row['id']?.toString();
      if (idIsar != null && supabaseId != null && supabaseId.isNotEmpty) {
        mapa[idIsar] = supabaseId;
      }
    }

    // Actualizar cada producto local con su supabaseId
    int actualizados = 0;
    for (var p in productosLocales) { 
      final nuevoId = mapa[p.id];
      if (nuevoId != null && p.supabaseId != nuevoId) {
        p.supabaseId = nuevoId;
        p.sincronizado = true;
        p.fechaSincronizacion = DateTime.now();
        await _isarService.guardarProducto(p);
        actualizados++;
        debugPrint('✅ Producto ${p.nombre} (id: ${p.id}) → supabaseId: $nuevoId');
      }
    }

    debugPrint('✅ ${productosLocales.length} productos sincronizados. $actualizados supabaseId actualizados.');
    return true;
  } catch (e) {
    debugPrint('🚫 Error sincronizando productos: $e');
    return false;
  }
}

  Future<bool> eliminarProductoEnSupabase(String codigoBarras) async {
    try {
      final codigoLimpio = codigoBarras.trim();
      if (codigoLimpio.isEmpty) {
        debugPrint('⚠️ Código de barras vacío, no se puede eliminar.');
        return false;
      }

      var existing = await _supabase
          .from('productos')
          .select('id')
          .eq('codigo_barras', codigoLimpio)
          .maybeSingle();

      if (existing == null) {
        debugPrint('ℹ️ Producto con código exacto "$codigoLimpio" no encontrado, intentando búsqueda flexible...');
        final resultados = await _supabase
            .from('productos')
            .select('id')
            .ilike('codigo_barras', codigoLimpio)
            .limit(1);
        if (resultados.isNotEmpty) {
          existing = resultados.first;
          debugPrint('🔍 Producto encontrado con búsqueda flexible: ${existing['id']}');
        }
      }

      if (existing == null) {
        debugPrint('ℹ️ Producto con código "$codigoLimpio" no existe en Supabase.');
        return false;
      }

      final response = await _supabase
          .from('productos')
          .delete()
          .eq('id', existing['id']);

      final int affected = response != null ? response.length : 0;
      debugPrint('📦 Filas afectadas en Supabase: $affected');

      if (affected > 0) {
        debugPrint('✅ Producto eliminado de Supabase (id: ${existing['id']})');
        return true;
      } else {
        debugPrint('⚠️ No se eliminó ninguna fila (código: $codigoLimpio)');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error eliminando producto de Supabase: $e');
      rethrow;
    }
  }

  // ==========================================
  // SINCRONIZACIÓN DE GASTOS
  // ==========================================

  Future<int> sincronizarGastosPendientes() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    int sincronizados = 0;

    try {
      final pendientes = await _isarService.obtenerGastosPendientesSync();
      if (pendientes.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      debugPrint('🔄 [SyncService] Sincronizando ${pendientes.length} gastos...');

      for (var gasto in pendientes) {
        final exito = await _enviarGastoAlServidor(gasto);
        if (exito) {
          await _isarService.actualizarSyncStatusGasto(gasto.id, 'synced');
          sincronizados++;
          debugPrint('✅ Gasto ${gasto.id} sincronizado');
        } else {
          await _isarService.actualizarSyncStatusGasto(gasto.id, 'failed');
          debugPrint('⚠️ Gasto ${gasto.id} marcado como failed');
        }
      }

      debugPrint('✅ $sincronizados gastos sincronizados');
      return sincronizados;
    } catch (e) {
      debugPrint('❌ Error sincronizando gastos: $e');
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _enviarGastoAlServidor(GastoEntity gasto) async {
    try {
      String? usuarioUuid;
      final usuario = await _isarService.obtenerUsuarioPorId(gasto.usuarioId);
      if (usuario != null && usuario.supabaseId != null && usuario.supabaseId!.isNotEmpty) {
        usuarioUuid = usuario.supabaseId;
      } else {
        debugPrint('⚠️ Usuario ID ${gasto.usuarioId} no tiene supabaseId. Se envía null.');
      }

      final payload = {
        'id_isar': gasto.id,
        'descripcion': gasto.descripcion,
        'monto': gasto.monto,
        'moneda': gasto.moneda,
        'tasa_bcv': gasto.tasaBcv,
        'categoria': gasto.categoria,
        'usuario_nombre': gasto.usuarioNombre,
        'fecha': gasto.fecha.toIso8601String(),
        'sync_status': 'synced',
        'usuario_id': usuarioUuid,
      };

      debugPrint('📤 Enviando gasto: ${jsonEncode(payload)}');

      final existing = await _supabase
          .from('gastos')
          .select('id')
          .eq('id_isar', gasto.id)
          .maybeSingle();

      dynamic response;
      if (existing != null) {
        response = await _supabase
            .from('gastos')
            .update(payload)
            .eq('id_isar', gasto.id)
            .select()
            .single();
        debugPrint('✅ Gasto ${gasto.id} actualizado correctamente.');
      } else {
        response = await _supabase
            .from('gastos')
            .insert(payload)
            .select()
            .single();
        debugPrint('✅ Gasto ${gasto.id} insertado correctamente. ID: ${response['id']}');
      }

      return true;
    } catch (e) {
      debugPrint('🚫 Error al enviar gasto: $e');
      if (e is PostgrestException) {
        debugPrint('Código de error Supabase: ${e.code}, Mensaje: ${e.message}');
      }
      return false;
    }
  }

  // ==========================================
  // GESTIÓN DE USUARIOS (microservicio)
  // ==========================================

  Future<Map<String, dynamic>?> crearUsuarioEnServidor(UsuarioEntity usuario, {String? email, String? password}) async {
    await _loadConfig();
    if (!_hasValidSyncConfig()) {
      debugPrint('ℹ️ No hay configuración válida de syncServerUrl/syncApiKey; se omite crearUsuarioEnServidor.');
      return null;
    }

    try {
      final payload = jsonEncode({
        'nombre': usuario.nombre,
        'rol': usuario.rol,
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
      return null;
    } catch (e) {
      debugPrint('🚫 Error en crearUsuarioEnServidor: $e');
      return null;
    }
  }

  /// 🔥 Orden de sincronización CORRECTO: productos primero, luego lotes y alias
  Future<void> sincronizarTodo() async {
  await sincronizarVentasPendientes();
  await sincronizarMovimientosInventario();
  await sincronizarProductosASupabase();
  await sincronizarCategoriasASupabase();
  await sincronizarTurnos();
  await sincronizarUsuariosASupabase();
  await sincronizarUsuariosDesdeSupabase();
  await sincronizarGastosPendientes();
  
  // 🔥 NUEVOS
  await sincronizarLocalesPendientes();
  await descargarLocalesDesdeSupabase();
  await sincronizarDepartamentosPendientes();
  await descargarDepartamentosDesdeSupabase();

  await _obtenerLocalActualUuid();
  await sincronizarPedidosPendientes();
  await descargarPedidosDesdeSupabase();
  await descargarProductosDesdeSupabase();
  await sincronizarProveedoresPendientes();
  await descargarProveedoresDesdeSupabase();
  await sincronizarAliasPendientes();
  await sincronizarLotesPendientes();
  await sincronizarTelegramConfigPendientes();
  await descargarTelegramConfigDesdeSupabase();
}

  // ==========================================
  // STREAM DE USUARIOS EN TIEMPO REAL (MONITOR)
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

Future<void> sincronizarProveedoresForzada() async {
  try {
    debugPrint('🔥 Iniciando sincronización forzada de proveedores...');
    
    final supabase = Supabase.instance.client;
    
    // 1. Descargar todos los proveedores desde Supabase
    final response = await supabase
        .from('proveedores')
        .select()
        .order('nombre', ascending: true);
    
    debugPrint('📥 Descargados ${response.length} proveedores desde Supabase');
    
    // 2. Obtener todos los proveedores locales
    final locales = await _isarService.obtenerProveedores(soloActivos: false);
    final Map<int, ProveedorEntity> localesPorId = {
      for (var p in locales) p.id: p
    };
    
    // 3. Mapa de supabaseId -> proveedor local para actualizar
    final Map<String, ProveedorEntity> localesPorSupabaseId = {
      for (var p in locales) if (p.supabaseId != null) p.supabaseId!: p
    };
    
    // 4. Procesar proveedores de Supabase
    final Set<int> idsLocalesProcesados = {};
    final Set<String> supabaseIdsProcesados = {};
    
    for (var data in response) {
      final supabaseId = data['id'] as String?;
      if (supabaseId == null) continue;
      
      supabaseIdsProcesados.add(supabaseId);
      
      // Buscar si ya existe localmente (por supabaseId o por id_isar)
      final idIsar = data['id_isar'] as int?;
      ProveedorEntity? local = localesPorSupabaseId[supabaseId];
      
      if (local == null && idIsar != null) {
        local = localesPorId[idIsar];
      }
      
      final proveedorNube = ProveedorEntity()
        ..supabaseId = supabaseId
        ..nombre = data['nombre'] ?? ''
        ..cedula = data['cedula'] as String?
        ..email = data['email'] as String?
        ..direccion = data['direccion']
        ..telefono = data['telefono'] as String?
        ..empresa = data['empresa'] as String?
        ..activo = data['activo'] ?? true
        ..sincronizado = true
        ..fechaSincronizacion = DateTime.now();
      
      if (local != null) {
        // Actualizar existente
        proveedorNube.id = local.id;
        await _isarService.guardarProveedor(proveedorNube);
        idsLocalesProcesados.add(local.id);
        debugPrint('🔄 Proveedor actualizado: ${proveedorNube.nombre}');
      } else {
        // Crear nuevo
        await _isarService.guardarProveedor(proveedorNube);
        debugPrint('📥 Proveedor creado desde Supabase: ${proveedorNube.nombre}');
      }
    }
    
    // 5. Subir proveedores locales que no están en Supabase
    int subidos = 0;
    for (var local in locales) {
      if (!idsLocalesProcesados.contains(local.id)) {
        // Este proveedor no existe en Supabase, subirlo
        final data = {
          'id_isar': local.id,
          'nombre': local.nombre,
          'cedula': local.cedula,
          'email': local.email,
          'direccion': local.direccion,
          'telefono': local.telefono,
          'empresa': local.empresa,
          'activo': local.activo,
          'sync_status': 'synced',
        };
        
        try {
          final response = await supabase
              .from('proveedores')
              .insert(data)
              .select('id')
              .single();
          
          final supabaseId = response['id'] as String?;
          if (supabaseId != null) {
            local.supabaseId = supabaseId;
            local.sincronizado = true;
            local.fechaSincronizacion = DateTime.now();
            await _isarService.guardarProveedor(local);
            subidos++;
            debugPrint('⬆️ Proveedor subido a Supabase: ${local.nombre}');
          }
        } catch (e) {
          debugPrint('❌ Error al subir proveedor ${local.nombre}: $e');
        }
      }
    }
    
    debugPrint('✅ Sincronización forzada completada: ${response.length} descargados, $subidos subidos');
  } catch (e) {
    debugPrint('❌ Error en sincronización forzada: $e');
    rethrow;
  }
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
        'id_isar': turno.id,
        'usuario_id_int': turno.usuarioId,
        'usuario_nombre': turno.usuarioNombre,
        'monto_inicial': turno.montoInicial,
        'monto_final': turno.montoFinal ?? 0.0,
        'fecha_apertura': turno.fechaApertura.toIso8601String(),
        'estado': turno.estado,
        'sync_status': 'pending',
      };

      if (turno.fechaCierre != null) {
        payload['fecha_cierre'] = turno.fechaCierre!.toIso8601String();
      }

      final existing = await _supabase
          .from('turnos')
          .select('id_isar')
          .eq('id_isar', turno.id)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('turnos').insert(payload);
        debugPrint('✅ Turno ${turno.id} insertado correctamente');
      } else {
        await _supabase
            .from('turnos')
            .update(payload)
            .eq('id_isar', turno.id);
        debugPrint('✅ Turno ${turno.id} actualizado correctamente');
      }
      return true;
    } catch (e) {
      debugPrint('🚫 Error al enviar turno: $e');
      return false;
    }
  }

  // ==========================================
  // DESCARGA DE VENTAS DESDE SUPABASE
  // ==========================================
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
      int insertadas = 0;
      int actualizadas = 0;

      for (var data in response) {
        final int ventaIdNum = data['id'];
        final String ventaIdString = data['venta_id'] as String? ?? '';
        if (ventaIdString.isEmpty) continue;

        final detallesResponse = await _supabase
            .from('detalle_ventas')
            .select()
            .eq('venta_id_fk', ventaIdNum);

        final detalles = detallesResponse.map<DetalleVentaEntity>((d) {
          return DetalleVentaEntity()
            ..nombreProducto = d['nombre_producto'] ?? ''
            ..precioUnidad = (d['precio_unidad'] as num?)?.toDouble() ?? 0.0
            ..cantidad = (d['cantidad'] as num?)?.toDouble() ?? 0.0
            ..subtotal = (d['subtotal'] as num?)?.toDouble() ?? 0.0;
        }).toList();

        final existing = await _isarService.obtenerVentaPorIdString(ventaIdString);

        final venta = VentaEntity()
          ..ventaIdString = ventaIdString
          ..fecha = DateTime.parse(data['fecha']).toLocal()
          ..subtotal = (data['subtotal'] as num).toDouble()
          ..impuesto = (data['impuesto'] as num).toDouble()
          ..total = (data['total'] as num).toDouble()
          ..tasaBcv = (data['tasa_bcv'] as num?)?.toDouble() ?? 0.0
          ..totalBolivares = (data['total_bolivares'] as num?)?.toDouble() ?? 0.0
          ..metodoPago = data['metodo_pago'] ?? ''
          ..documento = data['documento'] ?? ''
          ..empleado = data['empleado'] ?? ''
          ..syncStatus = 'synced';

        if (existing != null) {
          venta.id = existing.id;
          await _isarService.guardarVenta(venta);
          actualizadas++;
        } else {
          await _isarService.guardarVenta(venta);
          insertadas++;
        }

        if (detalles.isNotEmpty) {
          final ventaLocal = await _isarService.obtenerVentaPorIdString(ventaIdString);
          if (ventaLocal != null) {
            await _isarService.guardarDetallesVenta(ventaLocal.id, detalles);
            debugPrint('📦 ${detalles.length} detalles guardados para venta $ventaIdString');
          }
        }
      }

      debugPrint('✅ $insertadas ventas insertadas, $actualizadas actualizadas');
    } catch (e) {
      debugPrint('❌ Error descargando ventas: $e');
    }
  }

 Future<void> descargarProductosDesdeSupabase() async {
  try {
    final response = await _supabase
        .from('productos')
        .select()
        .order('nombre', ascending: true);

    if (response.isEmpty) {
      debugPrint('ℹ️ No hay productos en Supabase para descargar');
      return;
    }

    debugPrint('🔄 Procesando ${response.length} productos desde Supabase...');
    
    // Obtener productos locales
    final productosLocales = await _isarService.obtenerTodosLosProductos();
    final Map<String, ProductoEntity> localesPorCodigo = {
      for (var p in productosLocales) p.codigoBarras: p
    };
    
    final Set<String> codigosEnNube = {};

    for (var data in response) {
      final codigoBarras = data['codigo_barras'] ?? '';
      if (codigoBarras.isEmpty) continue;
      
      codigosEnNube.add(codigoBarras);

      final productoLocal = localesPorCodigo[codigoBarras];
      
      final productoNube = ProductoEntity()
        ..codigoBarras = codigoBarras
        ..nombre = data['nombre'] ?? ''
        ..precioUnidad = (data['precio_unidad'] as num?)?.toDouble() ?? 0.0
        ..stock = (data['stock'] as num?)?.toDouble() ?? 0.0
        ..stockMinimo = (data['stock_minimo'] as num?)?.toDouble() ?? 5.0
        ..esPesado = data['es_pesado'] ?? false
        ..categoria = data['categoria'] ?? ''
        ..proveedorNombre = data['proveedor_nombre'] ?? ''
        ..proveedorTelefono = data['proveedor_telefono'] ?? ''
        ..imagenUrl = data['imagen_url'] ?? ''
        ..supabaseId = data['id']?.toString()
        ..sincronizado = true
        ..fechaSincronizacion = DateTime.now();

      if (productoLocal != null) {
        // ✅ Actualizar producto existente
        productoNube.id = productoLocal.id;
        productoNube.proveedorId = productoLocal.proveedorId;
        await _isarService.guardarProducto(productoNube);
        debugPrint('🔄 Producto actualizado: ${productoNube.nombre}');
      } else {
        // ✅ Crear producto nuevo
        await _isarService.guardarProducto(productoNube);
        debugPrint('✅ Producto creado: ${productoNube.nombre}');
      }
    }

    // ✅ ELIMINAR productos locales que ya no existen en Supabase
    int eliminados = 0;
    for (var producto in productosLocales) {
      if (!codigosEnNube.contains(producto.codigoBarras)) {
        await _isarService.eliminarProducto(producto.id);
        eliminados++;
        debugPrint('🗑️ Producto eliminado por no existir en Supabase: ${producto.nombre}');
      }
    }

    debugPrint('✅ Productos sincronizados: ${response.length} actualizados/creados, $eliminados eliminados');
  } catch (e) {
    debugPrint('❌ Error descargando productos: $e');
    rethrow;
  }
}

  // ============================================================
  // NUEVOS MÉTODOS PARA SINCRONIZACIÓN DE USUARIOS DESDE SUPABASE
  // ============================================================

  Future<void> sincronizarUsuariosDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .order('nombre', ascending: true);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay usuarios en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} usuarios desde Supabase...');

      final locales = await _isarService.obtenerUsuarios();
      final Map<int, UsuarioEntity> localesMap = {for (var u in locales) u.id: u};

      for (var data in response) {
        final int idIsar = data['id_isar'] as int? ?? 0;
        if (idIsar == 0) {
          debugPrint('⚠️ Usuario sin id_isar, omitiendo: ${data['nombre']}');
          continue;
        }

        final local = localesMap[idIsar];
        if (local != null) {
          local.supabaseId = data['id'];

          local.email = data['email'] ?? local.email;
          local.deviceId = data['device_id'] ?? local.deviceId;
          local.cajaAsignada = data['caja_asignada'] ?? local.cajaAsignada;
          local.departamento = data['departamento'] ?? local.departamento;

          final estadoNube = data['estado'] as String? ?? 'inactivo';
          if (estadoNube == 'inactivo' && (local.estado == 'activo' || local.estado == 'descanso')) {
            local.estado = 'inactivo';
            debugPrint('🔄 Usuario ${local.nombre} marcado como inactivo por sincronización');
          }

          await _isarService.guardarUsuario(local);
        } else {
          final nuevoUsuario = UsuarioEntity()
            ..id = idIsar
            ..nombre = data['nombre'] ?? ''
            ..pin = data['pin'] ?? '1234'
            ..rol = data['rol'] ?? 'cajero'
            ..activo = true
            ..estado = 'inactivo'
            ..cajaAsignada = data['caja_asignada'] ?? ''
            ..email = data['email']
            ..deviceId = data['device_id'] ?? ''
            ..departamento = data['departamento'];
          await _isarService.guardarUsuario(nuevoUsuario);
        }
      }

      debugPrint('✅ Usuarios sincronizados desde Supabase');
    } catch (e) {
      debugPrint('❌ Error descargando usuarios: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerUsuariosDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .order('nombre', ascending: true);
      return response;
    } catch (e) {
      debugPrint('❌ Error obteniendo usuarios desde Supabase: $e');
      return [];
    }
  }

  // ============================================================
  // PEDIDOS
  // ============================================================

  Future<int> guardarPedido(PedidoEntity pedido) async {
    final isar = await _isarService.db;
    return isar.writeTxn<int>(() async {
      return await isar.pedidoEntitys.put(pedido);
    });
  }

  Future<List<PedidoEntity>> obtenerPedidosPorLocalDestino(int localDestinoId) async {
    final isar = await _isarService.db;
    return await isar.pedidoEntitys
        .where()
        .localDestinoIdEqualTo(localDestinoId)
        .findAll();
  }

  Future<List<PedidoEntity>> obtenerPedidosPorEstado(
    EstadoPedido estado, {
    int? localDestinoId,
  }) async {
    final isar = await _isarService.db;
    if (localDestinoId != null) {
      return await isar.pedidoEntitys
          .where()
          .localDestinoIdEqualTo(localDestinoId)
          .filter()
          .estadoEqualTo(estado)
          .findAll();
    } else {
      return await isar.pedidoEntitys
          .where()
          .filter()
          .estadoEqualTo(estado)
          .findAll();
    }
  }

  Future<PedidoEntity?> obtenerPedidoPorId(int id) async {
    final isar = await _isarService.db;
    return await isar.pedidoEntitys.get(id);
  }

  Future<void> actualizarEstadoPedido(int id, EstadoPedido nuevoEstado) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final pedido = await isar.pedidoEntitys.get(id);
      if (pedido != null) {
        pedido.estado = nuevoEstado;
        await isar.pedidoEntitys.put(pedido);
      }
    });
  }

  Future<void> actualizarSyncStatusPedido(int id, bool sincronizado) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final pedido = await isar.pedidoEntitys.get(id);
      if (pedido != null) {
        pedido.sincronizado = sincronizado;
        pedido.fechaSincronizacion = DateTime.now();
        await isar.pedidoEntitys.put(pedido);
      }
    });
  }

  Future<List<PedidoEntity>> obtenerPedidosPendientesSync() async {
    final isar = await _isarService.db;
    return await isar.pedidoEntitys
        .where()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  Future<PedidoEntity?> obtenerPedidoPorSupabaseId(String supabaseId) async {
    final isar = await _isarService.db;
    if (supabaseId.isEmpty) return null;
    return await isar.pedidoEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  // ============================================================
  // DETALLES DE PEDIDO
  // ============================================================

  Future<int> guardarDetallePedido(DetallePedidoEntity detalle) async {
    final isar = await _isarService.db;
    return isar.writeTxn<int>(() async {
      return await isar.detallePedidoEntitys.put(detalle);
    });
  }

  Future<List<DetallePedidoEntity>> obtenerDetallesPorPedido(int pedidoId) async {
    final isar = await _isarService.db;
    return await isar.detallePedidoEntitys
        .filter()
        .pedidoIdEqualTo(pedidoId)
        .findAll();
  }

  Future<void> eliminarDetallesPorPedido(int pedidoId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final detalles = await isar.detallePedidoEntitys
          .filter()
          .pedidoIdEqualTo(pedidoId)
          .findAll();
      for (var d in detalles) {
        await isar.detallePedidoEntitys.delete(d.id);
      }
    });
  }

  // ============================================================
  // RECEPCIONES
  // ============================================================

  Future<int> guardarRecepcion(RecepcionEntity recepcion) async {
    final isar = await _isarService.db;
    return isar.writeTxn<int>(() async {
      return await isar.recepcionEntitys.put(recepcion);
    });
  }

  Future<RecepcionEntity?> obtenerRecepcionPorPedido(int pedidoId) async {
    final isar = await _isarService.db;
    return await isar.recepcionEntitys
        .filter()
        .pedidoIdEqualTo(pedidoId)
        .findFirst();
  }

  Future<void> actualizarSyncStatusRecepcion(int id, bool sincronizado) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final recepcion = await isar.recepcionEntitys.get(id);
      if (recepcion != null) {
        recepcion.sincronizado = sincronizado;
        recepcion.fechaSincronizacion = DateTime.now();
        await isar.recepcionEntitys.put(recepcion);
      }
    });
  }

  // ============================================================
  // SINCRONIZACIÓN DE PEDIDOS (PROVEEDORES) - CORREGIDA
  // ============================================================
  
  /// Obtiene el ID entero del producto en Supabase (no el UUID, sino el 'id' de la tabla 'productos').
  /// Si el producto no existe en Supabase, lo crea y retorna su ID.
  Future<int?> _obtenerOCrearProductoEnSupabase(int productoLocalId) async {
    // 1. Obtener el producto local
    final productoLocal = await _isarService.obtenerProductoPorId(productoLocalId);
    if (productoLocal == null) {
      debugPrint('⚠️ Producto local $productoLocalId no encontrado en Isar');
      return null;
    }
    
    // 2. Verificar si ya tiene supabaseId (que ahora es el ID entero)
    if (productoLocal.supabaseId != null && productoLocal.supabaseId!.isNotEmpty) {
      final idInt = int.tryParse(productoLocal.supabaseId!);
      if (idInt != null && idInt > 0) {
        // Verificar que realmente existe en Supabase
        final response = await _supabase
            .from('productos')
            .select('id')
            .eq('id', idInt)
            .maybeSingle();
        if (response != null) {
          return idInt;
        } else {
          // El ID ya no existe en Supabase, limpiar y recrear
          productoLocal.supabaseId = null;
          await _isarService.guardarProducto(productoLocal);
        }
      }
    }
    
    // 3. Buscar el producto en Supabase por código de barras
    if (productoLocal.codigoBarras.isNotEmpty) {
      final response = await _supabase
          .from('productos')
          .select('id')
          .eq('codigo_barras', productoLocal.codigoBarras)
          .maybeSingle();
      
      if (response != null) {
        final id = response['id'] as int?;
        if (id != null && id > 0) {
          // Actualizar el supabaseId local
          productoLocal.supabaseId = id.toString();
          productoLocal.sincronizado = true;
          productoLocal.fechaSincronizacion = DateTime.now();
          await _isarService.guardarProducto(productoLocal);
          return id;
        }
      }
    }
    
    // 4. Si no existe en Supabase, crearlo
    try {
      final data = {
        'id_isar': productoLocal.id,
        'codigo_barras': productoLocal.codigoBarras,
        'nombre': productoLocal.nombre,
        'precio_unidad': productoLocal.precioUnidad,
        'stock': productoLocal.stock,
        'stock_minimo': productoLocal.stockMinimo,
        'es_pesado': productoLocal.esPesado,
        'categoria': productoLocal.categoria,
        'proveedor_nombre': productoLocal.proveedorNombre,
        'proveedor_telefono': productoLocal.proveedorTelefono,
        'imagen_url': productoLocal.imagenUrl,
        'sync_status': 'synced',
      };
      
      final response = await _supabase
          .from('productos')
          .insert(data)
          .select('id')
          .single();
      
      final newId = response['id'] as int?;
      if (newId != null && newId > 0) {
        productoLocal.supabaseId = newId.toString();
        productoLocal.sincronizado = true;
        productoLocal.fechaSincronizacion = DateTime.now();
        await _isarService.guardarProducto(productoLocal);
        debugPrint('✅ Producto "${productoLocal.nombre}" creado en Supabase con ID: $newId');
        return newId;
      }
    } catch (e) {
      debugPrint('❌ Error creando producto ${productoLocal.nombre} en Supabase: $e');
    }
    
    return null;
  }

  Future<void> sincronizarPedidosPendientes() async {
    try {
      // 🔥 Asegurar que el local principal existe y tiene UUID
      await _obtenerLocalActualUuid();
      
      final pedidosPendientes = await _isarService.obtenerPedidosPendientesSync();
      if (pedidosPendientes.isEmpty) return;

      final supabase = Supabase.instance.client;

      for (var pedido in pedidosPendientes) {
        // Obtener UUIDs con fallback automático
        final String? localOrigenUuid = await _obtenerSupabaseIdLocal(pedido.localOrigenId);
        final String? localDestinoUuid = await _obtenerSupabaseIdLocal(pedido.localDestinoId);
        final String? usuarioUuid = await _obtenerSupabaseIdUsuario(pedido.usuarioId);

        // Si algún UUID es null, intentar resolverlo
        if (localOrigenUuid == null || localDestinoUuid == null || usuarioUuid == null) {
          debugPrint('⚠️ Pedido ${pedido.id} omitido: localOrigenUuid=$localOrigenUuid, localDestinoUuid=$localDestinoUuid, usuarioUuid=$usuarioUuid');
          continue;
        }

        // Construir JSON SOLO con las columnas que existen en la tabla 'pedidos'
        final pedidoData = {
          'local_id': localOrigenUuid,
          'local_destino_id': localDestinoUuid,
          'usuario_id': usuarioUuid,
          'fecha_pedido': pedido.fechaPedido.toIso8601String(),
          'estado': pedido.estado.name,
          'proveedor_nombre': pedido.proveedorNombre,
          'proveedor_cedula': pedido.proveedorCedula,
          'proveedor_telefono': pedido.proveedorTelefono,
          'proveedor_empresa': pedido.proveedorEmpresa,
          'observaciones': pedido.observaciones,
          'total': pedido.total,
          'tipo_pedido': 'proveedor',
          'sync_status': 'synced',
        };

        // Insertar el pedido y obtener el UUID generado
        final response = await supabase
            .from('pedidos')
            .insert(pedidoData)
            .select()
            .single();

        final supabasePedidoId = response['id'] as String;

        // Procesar detalles del pedido
        final detalles = await _isarService.obtenerDetallesPorPedido(pedido.id);
        for (var detalle in detalles) {
          // 🔥 Obtener o crear el producto en Supabase
          final int? supabaseProductoId = await _obtenerOCrearProductoEnSupabase(detalle.productoId);
          
          if (supabaseProductoId == null) {
            debugPrint('⚠️ Detalle omitido: no se pudo obtener/crear producto ${detalle.productoId}');
            continue;
          }
          
          await supabase.from('detalles_pedido').insert({
            'pedido_id': supabasePedidoId,
            'producto_id': supabaseProductoId,
            'nombre_producto': detalle.nombreProducto,
            'cantidad': detalle.cantidad,
            'precio_unidad': detalle.precioUnidad,
            'subtotal': detalle.subtotal,
          });
        }

        // Procesar recepción (si existe)
        final recepcion = await _isarService.obtenerRecepcionPorPedido(pedido.id);
        if (recepcion != null) {
          await supabase.from('recepciones').insert({
            'pedido_id': supabasePedidoId,
            'fecha_recepcion': recepcion.fechaRecepcion.toIso8601String(),
            'usuario_id': recepcion.usuarioId,
            'observaciones': recepcion.observaciones,
          });
          await _isarService.actualizarSyncStatusRecepcion(recepcion.id, true);
        }

        // Marcar pedido como sincronizado
        await _isarService.actualizarSyncStatusPedido(pedido.id, true);
      }
    } catch (e) {
      debugPrint('Error sincronizando pedidos: $e');
      rethrow;
    }
  }

  // ============================================================
  // DESCARGA DE PEDIDOS DESDE SUPABASE (CORREGIDA)
  // ============================================================
  Future<void> descargarPedidosDesdeSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final isar = await _isarService.db;

      final String? localActualUuid = await _obtenerLocalActualUuid();
      if (localActualUuid == null || localActualUuid.isEmpty) {
        debugPrint('⚠️ No se pudo obtener el UUID del local actual. No se descargarán pedidos.');
        return;
      }

      final response = await supabase
          .from('pedidos')
          .select('*, detalles_pedido(*), recepciones(*)')
          .or('local_id.eq.$localActualUuid,local_destino_id.eq.$localActualUuid')
          .order('fecha_pedido', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay pedidos en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} pedidos desde Supabase...');

      for (var pedidoJson in response) {
        final existing = await isar.collection<PedidoEntity>()
            .filter()
            .supabaseIdEqualTo(pedidoJson['id'])
            .findFirst();
        if (existing != null) continue;

        final String? localOrigenUuid = pedidoJson['local_id']?.toString();
        final String? localDestinoUuid = pedidoJson['local_destino_id']?.toString();
        final String? usuarioUuid = pedidoJson['usuario_id']?.toString();

        if (localOrigenUuid == null || localDestinoUuid == null || usuarioUuid == null) {
          debugPrint('⚠️ Pedido ${pedidoJson['id']} omitido por falta de mapeo de IDs en la descarga');
          continue;
        }

        final int localOrigenId = await _obtenerIsarIdLocal(localOrigenUuid);
        final int localDestinoId = await _obtenerIsarIdLocal(localDestinoUuid);
        final int usuarioId = await _obtenerIsarIdUsuario(usuarioUuid);

        if (localOrigenId == 0 || localDestinoId == 0 || usuarioId == 0) {
          debugPrint('⚠️ Pedido ${pedidoJson['id']} omitido: IDs locales no encontrados');
          continue;
        }

        final pedido = PedidoEntity()
          ..supabaseId = pedidoJson['id']
          ..localOrigenId = localOrigenId
          ..localDestinoId = localDestinoId
          ..usuarioId = usuarioId
          ..fechaPedido = DateTime.parse(pedidoJson['fecha_pedido'])
          ..estado = EstadoPedido.values.firstWhere(
            (e) => e.name == pedidoJson['estado'],
            orElse: () => EstadoPedido.pendiente,
          )
          ..proveedorNombre = pedidoJson['proveedor_nombre'] ?? ''
          ..proveedorCedula = pedidoJson['proveedor_cedula']
          ..proveedorTelefono = pedidoJson['proveedor_telefono']
          ..proveedorEmpresa = pedidoJson['proveedor_empresa']
          ..observaciones = pedidoJson['observaciones']
          ..total = (pedidoJson['total'] as num).toDouble()
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        await isar.writeTxn(() async {
          final pedidoId = await isar.collection<PedidoEntity>().put(pedido);

          for (var detalleJson in pedidoJson['detalles_pedido'] ?? []) {
            final int productoId = await _obtenerIsarIdProducto(detalleJson['producto_id']);
            final detalle = DetallePedidoEntity()
              ..supabaseId = detalleJson['id']
              ..pedidoId = pedidoId
              ..productoId = productoId
              ..nombreProducto = detalleJson['nombre_producto']
              ..cantidad = (detalleJson['cantidad'] as num).toDouble()
              ..precioUnidad = (detalleJson['precio_unidad'] as num).toDouble()
              ..subtotal = (detalleJson['subtotal'] as num).toDouble();
            await isar.collection<DetallePedidoEntity>().put(detalle);
          }

          final recepcionJson = pedidoJson['recepciones'];
          if (recepcionJson != null && recepcionJson.isNotEmpty) {
            final recepcionData = recepcionJson[0];
            final int usuarioRecepcionId = await _obtenerIsarIdUsuario(recepcionData['usuario_id']);
            final recepcion = RecepcionEntity()
              ..supabaseId = recepcionData['id']
              ..pedidoId = pedidoId
              ..fechaRecepcion = DateTime.parse(recepcionData['fecha_recepcion'])
              ..usuarioId = usuarioRecepcionId
              ..observaciones = recepcionData['observaciones']
              ..sincronizado = true
              ..fechaSincronizacion = DateTime.now();
            await isar.collection<RecepcionEntity>().put(recepcion);
          }
        });
      }

      debugPrint('✅ ${response.length} pedidos descargados y guardados correctamente.');
    } catch (e) {
      debugPrint('❌ Error descargando pedidos: $e');
      rethrow;
    }
  }

  // ============================================================
  // MÉTODOS AUXILIARES (CORREGIDOS - PROFESIONAL)
  // ============================================================
  
  /// Obtiene el UUID de un local por su ID de Isar.
  /// Si no existe, busca cualquier local con supabaseId.
  /// Si no hay, intenta obtener de Supabase o crea uno.
  Future<String?> _obtenerSupabaseIdLocal(int isarId) async {
    final isar = await _isarService.db;
    
    // 1. Intentar obtener el local por ID
    LocalEntity? local = await isar.localEntitys.get(isarId);
    
    // 2. Si el local existe y tiene supabaseId, devolverlo
    if (local != null && local.supabaseId != null && local.supabaseId!.isNotEmpty) {
      return local.supabaseId;
    }
    
    // 3. Si no tiene supabaseId, buscar cualquier local con supabaseId
    if (local != null) {
      final localesConUuid = await isar.localEntitys
          .filter()
          .supabaseIdIsNotNull()
          .findAll();
      
      if (localesConUuid.isNotEmpty) {
        final localExistente = localesConUuid.first;
        // Si el local actual no tiene UUID, asignarle el del primero encontrado
        // Esto es un fallback, no es ideal pero evita errores
        if (local.supabaseId == null || local.supabaseId!.isEmpty) {
          local.supabaseId = localExistente.supabaseId;
          await isar.writeTxn(() async {
            await isar.localEntitys.put(local);
          });
          debugPrint('🔄 Asignado UUID del local ${localExistente.id} al local ${local.id} (fallback)');
        }
        return localExistente.supabaseId;
      }
    }
    
    // 4. Si no hay locales con UUID, obtener de Supabase o crear
    try {
      final response = await _supabase
          .from('locales')
          .select('id')
          .eq('id_isar', isarId)
          .maybeSingle();
      
      if (response != null) {
        final supabaseId = response['id'] as String?;
        if (supabaseId != null && supabaseId.isNotEmpty) {
          if (local != null) {
            local.supabaseId = supabaseId;
            await isar.writeTxn(() async {
              await isar.localEntitys.put(local);
            });
            debugPrint('✅ UUID del local $isarId obtenido de Supabase: $supabaseId');
          } else {
            // Crear el local en Isar con el UUID obtenido
            final nuevoLocal = LocalEntity()
              ..id = isarId
              ..nombre = 'Local Principal'
              ..supabaseId = supabaseId;
            await isar.writeTxn(() async {
              await isar.localEntitys.put(nuevoLocal);
            });
            debugPrint('✅ Local $isarId creado en Isar con UUID: $supabaseId');
          }
          return supabaseId;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error obteniendo UUID del local $isarId desde Supabase: $e');
    }
    
    // 5. Si todo falla, intentar obtener el UUID del local actual
    return await _obtenerLocalActualUuid();
  }

  Future<String?> _obtenerSupabaseIdUsuario(int isarId) async {
    final usuario = await _isarService.obtenerUsuarioPorId(isarId);
    if (usuario == null || usuario.supabaseId == null || usuario.supabaseId!.isEmpty) {
      return null;
    }
    return usuario.supabaseId;
  }

  Future<String?> _obtenerSupabaseIdProducto(int isarId) async {
    final producto = await _isarService.obtenerProductoPorId(isarId);
    if (producto == null || producto.supabaseId == null || producto.supabaseId!.isEmpty) {
      return null;
    }
    return producto.supabaseId;
  }

  Future<int> _obtenerIsarIdLocal(String supabaseId) async {
    final local = await _isarService.obtenerLocalPorSupabaseId(supabaseId);
    return local?.id ?? 0;
  }

  Future<int> _obtenerIsarIdUsuario(String supabaseId) async {
    final usuario = await _isarService.obtenerUsuarioPorSupabaseId(supabaseId);
    return usuario?.id ?? 0;
  }

  Future<int> _obtenerIsarIdProducto(String supabaseId) async {
    final producto = await _isarService.obtenerProductoPorSupabaseId(supabaseId);
    return producto?.id ?? 0;
  }

  /// Obtiene el UUID del local principal (ID 1).
  /// Si no existe, lo crea en Isar y en Supabase.
  Future<String?> _obtenerLocalActualUuid() async {
    final isar = await _isarService.db;
    
    // 1. Intentar obtener el local con ID 1
    LocalEntity? localIsar = await isar.localEntitys.get(1);
    
    // 2. Si no existe, crearlo con ID 1
    if (localIsar == null) {
      final nuevoLocal = LocalEntity()
        ..id = 1
        ..nombre = 'Local Principal';
      await isar.writeTxn(() async {
        await isar.localEntitys.put(nuevoLocal);
      });
      localIsar = nuevoLocal;
      debugPrint('✅ Local Principal (ID 1) creado en Isar porque no existía.');
    }
    
    // 3. Si ya tiene supabaseId, devolverlo
    if (localIsar.supabaseId != null && localIsar.supabaseId!.isNotEmpty) {
      return localIsar.supabaseId;
    }
    
    // 4. Buscar en Supabase o crear
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('locales').select('id').eq('id_isar', 1).maybeSingle();
      
      String uuid;
      if (data != null) {
        uuid = data['id'] as String;
        debugPrint('✅ Local encontrado en Supabase con id_isar = 1. UUID: $uuid');
      } else {
        final newData = await supabase.from('locales').insert({
          'id_isar': 1,
          'nombre': 'Local Principal',
        }).select().single();
        uuid = newData['id'] as String;
        debugPrint('✅ Local creado en Supabase con id_isar = 1. UUID: $uuid');
      }
      
      // Guardar en Isar
      localIsar.supabaseId = uuid;
      await isar.writeTxn(() async {
        await isar.localEntitys.put(localIsar!);
      });
      
      return uuid;
    } catch (e) {
      debugPrint('⚠️ Error crítico en _obtenerLocalActualUuid: $e');
      return null;
    }
  }

  // ============================================================
  // SINCRONIZACIÓN DE PROVEEDORES
  // ============================================================

  Future<void> sincronizarProveedoresPendientes() async {
  try {
    final pendientes = await _isarService.obtenerProveedoresPendientesSync();
    if (pendientes.isEmpty) {
      debugPrint('ℹ️ No hay proveedores pendientes para sincronizar');
      return;
    }

    debugPrint('🔄 Sincronizando ${pendientes.length} proveedores con Supabase...');

    final supabase = Supabase.instance.client;

    for (var proveedor in pendientes) {
      debugPrint('📤 Enviando proveedor: ${proveedor.nombre} (ID local: ${proveedor.id})');

      final data = {
        'id_isar': proveedor.id,
        'nombre': proveedor.nombre,
        'cedula': proveedor.cedula,
        'email': proveedor.email,
        'direccion': proveedor.direccion,
        'telefono': proveedor.telefono,
        'empresa': proveedor.empresa,
        'activo': proveedor.activo,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        // ✅ 1. Realizar upsert y obtener el id
        final response = await supabase
            .from('proveedores')
            .upsert(data, onConflict: 'id_isar')
            .select('id')
            .maybeSingle();

        String? supabaseId = response?['id'] as String?;

        // ✅ 2. Si no se obtuvo, buscar por id_isar
        if (supabaseId == null) {
          final findResponse = await supabase
              .from('proveedores')
              .select('id')
              .eq('id_isar', proveedor.id)
              .maybeSingle();
          supabaseId = findResponse?['id'] as String?;
        }

        // ✅ 3. Actualizar localmente solo si se obtuvo el ID
        if (supabaseId != null) {
          proveedor.supabaseId = supabaseId;
          proveedor.sincronizado = true;
          proveedor.fechaSincronizacion = DateTime.now();
          proveedor.updatedAt = DateTime.now();
          await _isarService.guardarProveedor(proveedor);
          debugPrint('✅ Proveedor ${proveedor.nombre} sincronizado con ID: $supabaseId');
        } else {
          debugPrint('⚠️ No se pudo obtener ID de Supabase para ${proveedor.nombre}');
        }
      } catch (e) {
        debugPrint('❌ Error al sincronizar proveedor ${proveedor.nombre}: $e');
      }
    }

    debugPrint('✅ Sincronización de proveedores completada');
  } catch (e) {
    debugPrint('❌ Error general en sincronizarProveedoresPendientes: $e');
    rethrow;
  }
}

Future<void> descargarProveedoresDesdeSupabase() async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('proveedores')
        .select()
        .order('nombre', ascending: true);

    debugPrint('🔄 Descargando ${response.length} proveedores desde Supabase...');

    // Obtener todos los proveedores locales
    final locales = await _isarService.obtenerProveedores(soloActivos: false);
    final Map<String, ProveedorEntity> localesPorSupabaseId = {
      for (var p in locales) if (p.supabaseId != null) p.supabaseId!: p
    };
    final Map<int, ProveedorEntity> localesPorId = {
      for (var p in locales) p.id: p
    };

    for (var data in response) {
      final supabaseId = data['id'] as String?;
      if (supabaseId == null) continue;

      final idIsar = data['id_isar'] as int?;
      ProveedorEntity? local = localesPorSupabaseId[supabaseId];
      
      if (local == null && idIsar != null) {
        local = localesPorId[idIsar];
      }

      final proveedorNube = ProveedorEntity()
        ..supabaseId = supabaseId
        ..nombre = data['nombre'] ?? ''
        ..cedula = data['cedula'] as String?
        ..email = data['email'] as String?
        ..direccion = data['direccion']
        ..telefono = data['telefono'] as String?
        ..empresa = data['empresa'] as String?
        ..activo = data['activo'] ?? true
        ..sincronizado = true
        ..fechaSincronizacion = DateTime.now();

      if (local != null) {
        // Actualizar existente
        proveedorNube.id = local.id;
        await _isarService.guardarProveedor(proveedorNube);
        debugPrint('🔄 Proveedor ${proveedorNube.nombre} actualizado');
      } else {
        // Crear nuevo
        await _isarService.guardarProveedor(proveedorNube);
        debugPrint('📥 Proveedor ${proveedorNube.nombre} creado');
      }
    }
  } catch (e) {
    debugPrint('❌ Error descargando proveedores: $e');
    rethrow;
  }

}

Future<Map<String, int>> sincronizarTodoConResumen() async {
  int ventas = 0, productos = 0, proveedores = 0, gastos = 0, pedidos = 0, lotes = 0;
  int locales = 0, departamentos = 0, telegram = 0; // 🔥 NUEVOS

  try {
    // Ventas
    final ventasPend = await _isarService.obtenerVentasPendientesSync();
    if (ventasPend.isNotEmpty) {
      await sincronizarVentasPendientes();
      ventas = ventasPend.length;
    }

    // Productos
    final productosPend = await _isarService.obtenerProductosPendientesSync();
    if (productosPend.isNotEmpty) {
      await sincronizarProductosASupabase();
      productos = productosPend.length;
    }

    // Proveedores
    final proveedoresPend = await _isarService.obtenerProveedoresPendientesSync();
    if (proveedoresPend.isNotEmpty) {
      await sincronizarProveedoresPendientes();
      proveedores = proveedoresPend.length;
    }

    // Gastos
    final gastosPend = await _isarService.obtenerGastosPendientesSync();
    if (gastosPend.isNotEmpty) {
      await sincronizarGastosPendientes();
      gastos = gastosPend.length;
    }

    // Pedidos
    final pedidosPend = await _isarService.obtenerPedidosPendientesSync();
    if (pedidosPend.isNotEmpty) {
      await sincronizarPedidosPendientes();
      pedidos = pedidosPend.length;
    }

    // Lotes
    final lotesPend = await _isarService.obtenerLotesPendientesSync();
    if (lotesPend.isNotEmpty) {
      await sincronizarLotesPendientes();
      lotes = lotesPend.length;
    }

    // 🔥 LOCALES
    final localesPend = await _isarService.obtenerLocalesPendientesSync();
    if (localesPend.isNotEmpty) {
      await sincronizarLocalesPendientes();
      locales = localesPend.length;
    }

    // 🔥 DEPARTAMENTOS
    final departamentosPend = await _isarService.obtenerDepartamentosPendientesSync();
    if (departamentosPend.isNotEmpty) {
      await sincronizarDepartamentosPendientes();
      departamentos = departamentosPend.length;
    }

    // 🔥 TELEGRAM
    final telegramPend = await _isarService.obtenerTelegramConfigsPendientesSync();
    if (telegramPend.isNotEmpty) {
      await sincronizarTelegramConfigPendientes();
      telegram = telegramPend.length;
    }

    // Finalmente descargar todo lo nuevo
    await descargarVentasDesdeSupabase();
    await descargarProductosDesdeSupabase();
    await descargarProveedoresDesdeSupabase();
    await descargarLocalesDesdeSupabase();        // 🔥
    await descargarDepartamentosDesdeSupabase(); // 🔥
    await descargarTelegramConfigDesdeSupabase(); // 🔥

    return {
      'ventas': ventas,
      'productos': productos,
      'proveedores': proveedores,
      'gastos': gastos,
      'pedidos': pedidos,
      'lotes': lotes,
      'locales': locales,
      'departamentos': departamentos,
      'telegram': telegram,
    };
  } catch (e) {
    debugPrint('❌ Error en sincronización completa: $e');
    rethrow;
  }
}
  // ==================== SINCRONIZACIÓN DE ALIAS ====================

  Future<void> sincronizarAliasPendientes() async {
    try {
      final pendientes = await _isarService.obtenerAliasPendientesSync();
      if (pendientes.isEmpty) return;

      for (var alias in pendientes) {
        final existing = await _supabase
            .from('codigos_barras_alias')
            .select('id_isar')
            .eq('id_isar', alias.id)
            .maybeSingle();

        final data = {
          'id_isar': alias.id,
          'codigo': alias.codigo,
          'producto_id_fk': await _obtenerSupabaseIdProducto(alias.productoId),
          'factor': alias.factor,
          'activo': alias.activo,
          'fecha_asignacion': alias.fechaAsignacion.toIso8601String(),
          'observaciones': alias.observaciones,
          'sincronizado': true,
          'fecha_sincronizacion': DateTime.now().toIso8601String(),
        };

        if (existing == null) {
          await _supabase.from('codigos_barras_alias').insert(data);
        } else {
          await _supabase.from('codigos_barras_alias').update(data).eq('id_isar', alias.id);
        }

        alias.sincronizado = true;
        alias.fechaSincronizacion = DateTime.now();
        await _isarService.guardarCodigoAlias(alias);
      }
    } catch (e) {
      debugPrint('❌ Error sincronizando alias: $e');
    }
  }

  // ==================== SINCRONIZACIÓN DE LOTES (DEFINITIVA) ====================

  Future<void> sincronizarLotesPendientes() async {
    try {
      final pendientes = await _isarService.obtenerLotesPendientesSync();
      if (pendientes.isEmpty) return;

      for (var lote in pendientes) {
        final productoIdFk = await _obtenerSupabaseIdProducto(lote.productoId);

        if (productoIdFk == null || productoIdFk.isEmpty) {
          debugPrint('⚠️ Lote ${lote.id} omitido: producto ${lote.productoId} sin supabaseId (se reintentará)');
          continue;
        }

        final existing = await _supabase
            .from('lotes')
            .select('id_isar')
            .eq('id_isar', lote.id)
            .maybeSingle();

        final data = {
          'id_isar': lote.id,
          'producto_id_fk': productoIdFk,
          'codigo_lote_proveedor': lote.codigoLoteProveedor,
          'cantidad_inicial': lote.cantidadInicial,
          'cantidad_restante': lote.cantidadRestante,
          'fecha_ingreso': lote.fechaIngreso.toIso8601String(),
          'fecha_vencimiento': lote.fechaVencimiento?.toIso8601String(),
          'estado': lote.estado,
          'costo_unitario': lote.costoUnitario,
          'sincronizado': true,
          'fecha_sincronizacion': DateTime.now().toIso8601String(),
        };

        if (existing == null) {
          await _supabase.from('lotes').insert(data);
        } else {
          await _supabase.from('lotes').update(data).eq('id_isar', lote.id);
        }

        lote.sincronizado = true;
        lote.fechaSincronizacion = DateTime.now();
        await _isarService.guardarLote(lote);
      }
    } catch (e) {
      debugPrint('❌ Error sincronizando lotes: $e');
    }
  }

  // Métodos para obtener pendientes (delegados a IsarService)
  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPendientesSync() async {
    return await _isarService.obtenerAliasPendientesSync();
  }

  Future<List<LoteEntity>> obtenerLotesPendientesSync() async {
    return await _isarService.obtenerLotesPendientesSync();
  }

  // ==================== SINCRONIZACIÓN DE LOCALES ====================

Future<void> sincronizarLocalesPendientes() async {
  try {
    final pendientes = await _isarService.obtenerLocalesPendientesSync();
    if (pendientes.isEmpty) {
      debugPrint('ℹ️ No hay locales pendientes para sincronizar');
      return;
    }

    debugPrint('🔄 Sincronizando ${pendientes.length} locales con Supabase...');

    for (var local in pendientes) {
      final data = {
        'id_isar': local.id,
        'nombre': local.nombre,
        'direccion': local.direccion,
        'telefono': local.telefono,
        'email': local.email,
        'activo': local.activo,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        final response = await _supabase
            .from('locales')
            .upsert(data, onConflict: 'id_isar')
            .select('id')
            .maybeSingle();

        String? supabaseId = response?['id'] as String?;
        if (supabaseId == null) {
          final findResponse = await _supabase
              .from('locales')
              .select('id')
              .eq('id_isar', local.id)
              .maybeSingle();
          supabaseId = findResponse?['id'] as String?;
        }

        if (supabaseId != null) {
          local.supabaseId = supabaseId;
          local.sincronizado = true;
          local.fechaSincronizacion = DateTime.now();
          await _isarService.guardarLocal(local);
          debugPrint('✅ Local ${local.nombre} sincronizado con ID: $supabaseId');
        }
      } catch (e) {
        debugPrint('❌ Error al sincronizar local ${local.nombre}: $e');
      }
    }
  } catch (e) {
    debugPrint('❌ Error general en sincronizarLocalesPendientes: $e');
    rethrow;
  }
}

Future<void> descargarLocalesDesdeSupabase() async {
  try {
    final response = await _supabase
        .from('locales')
        .select()
        .order('nombre', ascending: true);

    debugPrint('🔄 Descargando ${response.length} locales desde Supabase...');

    final localesLocales = await _isarService.obtenerLocales(soloActivos: false);
    final Map<String, LocalEntity> localesPorSupabaseId = {
      for (var l in localesLocales) if (l.supabaseId != null) l.supabaseId!: l
    };
    final Map<int, LocalEntity> localesPorId = {
      for (var l in localesLocales) l.id: l
    };

    for (var data in response) {
      final supabaseId = data['id'] as String?;
      if (supabaseId == null) continue;

      final idIsar = data['id_isar'] as int?;
      LocalEntity? local = localesPorSupabaseId[supabaseId];
      if (local == null && idIsar != null) {
        local = localesPorId[idIsar];
      }

      final localNube = LocalEntity()
        ..supabaseId = supabaseId
        ..nombre = data['nombre'] ?? ''
        ..direccion = data['direccion'] as String?
        ..telefono = data['telefono'] as String?
        ..email = data['email'] as String?
        ..activo = data['activo'] ?? true
        ..sincronizado = true
        ..fechaSincronizacion = DateTime.now();

      if (local != null) {
        localNube.id = local.id;
        await _isarService.guardarLocal(localNube);
        debugPrint('🔄 Local ${localNube.nombre} actualizado');
      } else {
        await _isarService.guardarLocal(localNube);
        debugPrint('📥 Local ${localNube.nombre} creado');
      }
    }
  } catch (e) {
    debugPrint('❌ Error descargando locales: $e');
    rethrow;
  }
}

// ==================== SINCRONIZACIÓN DE DEPARTAMENTOS ====================

Future<void> sincronizarDepartamentosPendientes() async {
  try {
    final pendientes = await _isarService.obtenerDepartamentosPendientesSync();
    if (pendientes.isEmpty) {
      debugPrint('ℹ️ No hay departamentos pendientes para sincronizar');
      return;
    }

    debugPrint('🔄 Sincronizando ${pendientes.length} departamentos con Supabase...');

    for (var departamento in pendientes) {
      // 🔥 OBTENER EL UUID DEL LOCAL ASOCIADO
      String? localUuid;
      if (departamento.localId != null) {
        localUuid = await _obtenerSupabaseIdLocal(departamento.localId!);
      }

      final data = {
        'id_isar': departamento.id,
        'nombre': departamento.nombre,
        'descripcion': departamento.descripcion,
        // 🔥 ENVIAR UUID, NO EL ID ENTERO
        'local_id': localUuid, // Puede ser null si no tiene local asociado
        'activo': departamento.activo,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Si no tiene local, enviar null (la columna acepta null en Supabase)
      // Si localUuid es null, Supabase pondrá NULL en la columna (si está permitido)

      try {
        final response = await _supabase
            .from('departamentos')
            .upsert(data, onConflict: 'id_isar')
            .select('id')
            .maybeSingle();

        String? supabaseId = response?['id'] as String?;
        if (supabaseId == null) {
          final findResponse = await _supabase
              .from('departamentos')
              .select('id')
              .eq('id_isar', departamento.id)
              .maybeSingle();
          supabaseId = findResponse?['id'] as String?;
        }

        if (supabaseId != null) {
          departamento.supabaseId = supabaseId;
          departamento.sincronizado = true;
          departamento.fechaSincronizacion = DateTime.now();
          await _isarService.guardarDepartamento(departamento);
          debugPrint('✅ Departamento ${departamento.nombre} sincronizado con ID: $supabaseId');
        }
      } catch (e) {
        debugPrint('❌ Error al sincronizar departamento ${departamento.nombre}: $e');
      }
    }
  } catch (e) {
    debugPrint('❌ Error general en sincronizarDepartamentosPendientes: $e');
    rethrow;
  }
}

Future<void> descargarDepartamentosDesdeSupabase() async {
  try {
    final response = await _supabase
        .from('departamentos')
        .select()
        .order('nombre', ascending: true);

    debugPrint('🔄 Descargando ${response.length} departamentos desde Supabase...');

    if (response.isEmpty) return;

    // Obtener locales locales para mapear UUID -> id_isar
    final localesLocales = await _isarService.obtenerLocales(soloActivos: false);
    final Map<String, int> uuidToIsarId = {};
    for (var local in localesLocales) {
      if (local.supabaseId != null) {
        uuidToIsarId[local.supabaseId!] = local.id;
      }
    }

    final departamentosLocales = await _isarService.obtenerDepartamentos(soloActivos: false);
    final Map<String, DepartamentoEntity> localesPorSupabaseId = {
      for (var d in departamentosLocales) if (d.supabaseId != null) d.supabaseId!: d
    };
    final Map<int, DepartamentoEntity> localesPorId = {
      for (var d in departamentosLocales) d.id: d
    };

    for (var data in response) {
      final supabaseId = data['id'] as String?;
      if (supabaseId == null) continue;

      final idIsar = data['id_isar'] as int?;
      DepartamentoEntity? departamento = localesPorSupabaseId[supabaseId];
      if (departamento == null && idIsar != null) {
        departamento = localesPorId[idIsar];
      }

      // 🔥 Obtener el local_id (UUID) de Supabase y mapear a entero (id_isar)
      final localUuid = data['local_id'] as String?;
      int? localIsarId;
      if (localUuid != null && uuidToIsarId.containsKey(localUuid)) {
        localIsarId = uuidToIsarId[localUuid];
      }

      final departamentoNube = DepartamentoEntity()
        ..supabaseId = supabaseId
        ..nombre = data['nombre'] ?? ''
        ..descripcion = data['descripcion'] as String?
        ..localId = localIsarId // 🔥 Asignamos el ID de Isar del local
        ..activo = data['activo'] ?? true
        ..sincronizado = true
        ..fechaSincronizacion = DateTime.now();

      if (departamento != null) {
        departamentoNube.id = departamento.id;
        await _isarService.guardarDepartamento(departamentoNube);
        debugPrint('🔄 Departamento ${departamentoNube.nombre} actualizado');
      } else {
        await _isarService.guardarDepartamento(departamentoNube);
        debugPrint('📥 Departamento ${departamentoNube.nombre} creado');
      }
    }
  } catch (e) {
    debugPrint('❌ Error descargando departamentos: $e');
    rethrow;
  }
}

// ==================== TELEGRAM CONFIG ====================

Future<void> sincronizarTelegramConfigPendientes() async {
  try {
    final pendientes = await _isarService.obtenerTelegramConfigsPendientesSync();
    if (pendientes.isEmpty) {
      debugPrint('ℹ️ No hay configuraciones de Telegram pendientes para sincronizar');
      return;
    }

    debugPrint('🔄 Sincronizando ${pendientes.length} configuraciones de Telegram con Supabase...');

    for (var config in pendientes) {
      // 🔥 Asegurar que comandos_permitidos sea una lista no nula
      final comandos = config.comandosPermitidos ?? ['/ventas', '/stock', '/ayuda'];
      
      final data = {
        'id_isar': config.id,
        'bot_token': config.botToken ?? '',
        'chat_id': config.chatId ?? '',
        'nombre_chat': config.nombreChat ?? '',
        'enabled': config.enabled,
        'notificar_stock_bajo': config.notificarStockBajo,
        'notificar_ventas': config.notificarVentas,
        'notificar_pedidos': config.notificarPedidos,
        // 🔥 Enviar como JSON string porque Supabase espera JSONB
        'comandos_permitidos': jsonEncode(comandos),
        'sync_status': 'synced',
        'sincronizado': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        final response = await _supabase
            .from('telegram_config')
            .upsert(data, onConflict: 'id_isar')
            .select('id')
            .maybeSingle();

        final supabaseId = response?['id'] as String?;
        if (supabaseId != null) {
          config.supabaseId = supabaseId;
          config.sincronizado = true;
          config.fechaSincronizacion = DateTime.now();
          await _isarService.guardarTelegramConfig(config);
          debugPrint('✅ Configuración de Telegram sincronizada con ID: $supabaseId');
        }
      } catch (e) {
        debugPrint('❌ Error al sincronizar configuración de Telegram: $e');
      }
    }
  } catch (e) {
    debugPrint('❌ Error general en sincronizarTelegramConfigPendientes: $e');
  }
}

Future<void> descargarTelegramConfigDesdeSupabase() async {
  try {
    final response = await _supabase
        .from('telegram_config')
        .select()
        .order('id_isar', ascending: true);

    debugPrint('🔄 Descargando ${response.length} configuraciones de Telegram desde Supabase...');

    if (response.isEmpty) return;

    // Obtener configuraciones locales existentes
    final locales = await _isarService.obtenerTelegramConfigs(); // ✅ Necesitas este método
    final Map<int, TelegramConfigEntity> localesPorId = {
      for (var c in locales) c.id: c
    };

    for (var data in response) {
      final idIsar = data['id_isar'] as int?;
      if (idIsar == null) continue;

      // Buscar si ya existe localmente
      TelegramConfigEntity? local = localesPorId[idIsar];

      // Si no existe por id_isar, intentar por supabaseId
      if (local == null) {
        final supabaseId = data['id'] as String?;
        if (supabaseId != null) {
          local = locales.firstWhere(
            (c) => c.supabaseId == supabaseId,
            orElse: () => null as TelegramConfigEntity,
          );
        }
      }

      final configNube = TelegramConfigEntity()
        ..id = idIsar
        ..supabaseId = data['id']
        ..botToken = data['bot_token'] as String? ?? ''
        ..chatId = data['chat_id'] as String? ?? ''
        ..nombreChat = data['nombre_chat'] as String? ?? ''
        ..enabled = data['enabled'] ?? true
        ..notificarStockBajo = data['notificar_stock_bajo'] ?? true
        ..notificarVentas = data['notificar_ventas'] ?? false
        ..notificarPedidos = data['notificar_pedidos'] ?? false
        ..comandosPermitidos = data['comandos_permitidos'] is List
            ? List<String>.from(data['comandos_permitidos'])
            : ['/ventas', '/stock', '/ayuda']
        ..sincronizado = true
        ..fechaSincronizacion = DateTime.now()
        ..createdAt = data['created_at'] != null ? DateTime.parse(data['created_at']) : null
        ..updatedAt = data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null;

      if (local != null) {
        // Actualizar existente
        configNube.id = local.id;
        await _isarService.guardarTelegramConfig(configNube);
        debugPrint('🔄 Configuración de Telegram actualizada localmente (ID Isar: ${local.id})');
      } else {
        // Crear nueva (solo si no existe)
        await _isarService.guardarTelegramConfig(configNube);
        debugPrint('📥 Configuración de Telegram creada localmente (ID Isar: $idIsar)');
      }
    }

    // 🔥 ELIMINAR configuraciones locales que ya no existen en Supabase
    final supabaseIds = response.map((d) => d['id'] as String).toSet();
    final localesParaEliminar = locales.where((c) => 
      c.supabaseId != null && !supabaseIds.contains(c.supabaseId)
    ).toList();

    for (var c in localesParaEliminar) {
      await _isarService.eliminarTelegramConfig(c.id); // ✅ Ahora existe
      debugPrint('🗑️ Configuración de Telegram eliminada localmente (ID: ${c.id})');
    }

    debugPrint('✅ Descarga de configuraciones de Telegram completada');
  } catch (e) {
    debugPrint('❌ Error descargando configuraciones de Telegram: $e');
  }
}


  // ==========================================
  // LIMPIEZA DE RECURSOS
  // ==========================================

  void dispose() {
    detenerMonitoreo();
  }
}