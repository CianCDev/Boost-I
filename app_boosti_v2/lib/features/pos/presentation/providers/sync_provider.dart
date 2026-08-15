import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import '../../data/Local/entities/gasto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../../data/Local/entities/detalle_venta_entity.dart';

/// Servicio de sincronización completo
class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  final SupabaseClient _supabase = Supabase.instance.client;

  String _syncServerUrl = 'https://your-sync-server.example';
  String _syncApiKey = '<REPLACE_WITH_SYNC_API_KEY>';

  bool _configLoaded = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  // ==========================================
  // CONFIGURACIÓN Y MONITOREO
  // ==========================================

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

  void dispose() {
    detenerMonitoreo();
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
        debugPrint('ℹ️ No hay configuración válida; se usa Supabase directo.');
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
  // SINCRONIZACIÓN DE MOVIMIENTOS
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
          'imagen_url': p.imagenUrl,
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
      final payload = {
        'id_isar': gasto.id,
        'descripcion': gasto.descripcion,
        'monto': gasto.monto,
        'moneda': gasto.moneda,
        'tasa_bcv': gasto.tasaBcv,
        'categoria': gasto.categoria,
        'usuario_id': gasto.usuarioId,
        'usuario_nombre': gasto.usuarioNombre,
        'fecha': gasto.fecha.toIso8601String(),
        'sync_status': 'synced',
      };

      await _supabase.from('gastos').insert(payload);
      debugPrint('✅ Gasto sincronizado correctamente');
      return true;
    } catch (e) {
      debugPrint('🚫 Error al enviar gasto: $e');
      return false;
    }
  }

  // ==========================================
  // SINCRONIZACIÓN DE USUARIOS
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
  // DESCARGA DE VENTAS Y PRODUCTOS
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

      debugPrint('🔄 Descargando ${response.length} productos desde Supabase...');

      for (var data in response) {
        final producto = ProductoEntity()
          ..codigoBarras = data['codigo_barras'] ?? ''
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

        await _isarService.guardarProducto(producto);
      }

      debugPrint('✅ ${response.length} productos descargados y guardados localmente');
    } catch (e) {
      debugPrint('❌ Error descargando productos: $e');
    }
  }

  // ==========================================
  // SINCRONIZACIÓN DE PEDIDOS
  // ==========================================

  Future<void> sincronizarPedidosPendientes() async {
    try {
      final pedidosPendientes = await _isarService.obtenerPedidosPendientesSync();
      if (pedidosPendientes.isEmpty) return;

      final supabase = Supabase.instance.client;

      for (var pedido in pedidosPendientes) {
        final localOrigenUuid = await _obtenerSupabaseIdLocal(pedido.localOrigenId);
        final localDestinoUuid = await _obtenerSupabaseIdLocal(pedido.localDestinoId);
        final usuarioUuid = await _obtenerSupabaseIdUsuario(pedido.usuarioId);

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

        final response = await supabase
            .from('pedidos')
            .insert(pedidoData)
            .select()
            .single();

        final supabasePedidoId = response['id'] as String;

        final detalles = await _isarService.obtenerDetallesPorPedido(pedido.id);
        for (var detalle in detalles) {
          final productoUuid = await _obtenerSupabaseIdProducto(detalle.productoId);
          await supabase.from('detalles_pedido').insert({
            'pedido_id': supabasePedidoId,
            'producto_id': productoUuid,
            'nombre_producto': detalle.nombreProducto,
            'cantidad': detalle.cantidad,
            'precio_unidad': detalle.precioUnidad,
            'subtotal': detalle.subtotal,
          });
        }

        final recepcion = await _isarService.obtenerRecepcionPorPedido(pedido.id);
        if (recepcion != null) {
          final usuarioRecepcionUuid = await _obtenerSupabaseIdUsuario(recepcion.usuarioId);
          await supabase.from('recepciones').insert({
            'pedido_id': supabasePedidoId,
            'fecha_recepcion': recepcion.fechaRecepcion.toIso8601String(),
            'usuario_id': usuarioRecepcionUuid,
            'observaciones': recepcion.observaciones,
          });
          await _isarService.actualizarSyncStatusRecepcion(recepcion.id, true);
        }

        await _isarService.actualizarSyncStatusPedido(pedido.id, true);
      }
    } catch (e) {
      print('Error sincronizando pedidos: $e');
      rethrow;
    }
  }

  Future<void> descargarPedidosDesdeSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final localActual = await _obtenerLocalActual();

      final response = await supabase
          .from('pedidos')
          .select('*, detalles_pedido(*), recepciones(*)')
          .or('local_id.eq.$localActual,local_destino_id.eq.$localActual')
          .order('fecha_pedido', ascending: false);

      for (var pedidoJson in response) {
        final existing = await _isarService.obtenerPedidoPorSupabaseId(pedidoJson['id']);
        if (existing != null) continue;

        final localOrigenId = await _obtenerIsarIdLocal(pedidoJson['local_id']);
        final localDestinoId = await _obtenerIsarIdLocal(pedidoJson['local_destino_id']);
        final usuarioId = await _obtenerIsarIdUsuario(pedidoJson['usuario_id']);

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

        final pedidoId = await _isarService.guardarPedido(pedido);

        for (var detalleJson in pedidoJson['detalles_pedido'] ?? []) {
          final productoId = await _obtenerIsarIdProducto(detalleJson['producto_id']);
          final detalle = DetallePedidoEntity()
            ..supabaseId = detalleJson['id']
            ..pedidoId = pedidoId
            ..productoId = productoId
            ..nombreProducto = detalleJson['nombre_producto']
            ..cantidad = (detalleJson['cantidad'] as num).toDouble()
            ..precioUnidad = (detalleJson['precio_unidad'] as num).toDouble()
            ..subtotal = (detalleJson['subtotal'] as num).toDouble();
          await _isarService.guardarDetallePedido(detalle);
        }

        final recepcionJson = pedidoJson['recepciones'];
        if (recepcionJson != null && recepcionJson.isNotEmpty) {
          final recepcionData = recepcionJson[0];
          final usuarioRecepcionId = await _obtenerIsarIdUsuario(recepcionData['usuario_id']);
          final recepcion = RecepcionEntity()
            ..supabaseId = recepcionData['id']
            ..pedidoId = pedidoId
            ..fechaRecepcion = DateTime.parse(recepcionData['fecha_recepcion'])
            ..usuarioId = usuarioRecepcionId
            ..observaciones = recepcionData['observaciones']
            ..sincronizado = true
            ..fechaSincronizacion = DateTime.now();
          await _isarService.guardarRecepcion(recepcion);
        }
      }
    } catch (e) {
      print('Error descargando pedidos: $e');
      rethrow;
    }
  }

  // ==========================================
  // MÉTODOS AUXILIARES PARA MAPEAR IDs
  // ==========================================

  Future<String> _obtenerSupabaseIdLocal(int isarId) async {
    final local = await _isarService.obtenerLocalPorId(isarId);
    return local?.supabaseId ?? '';
  }

  Future<int> _obtenerIsarIdLocal(String supabaseId) async {
    final local = await _isarService.obtenerLocalPorSupabaseId(supabaseId);
    return local?.id ?? 0;
  }

  Future<String> _obtenerSupabaseIdUsuario(int isarId) async {
    final usuario = await _isarService.obtenerUsuarioPorId(isarId);
    return usuario?.supabaseId ?? '';
  }

  Future<int> _obtenerIsarIdUsuario(String supabaseId) async {
    final usuario = await _isarService.obtenerUsuarioPorSupabaseId(supabaseId);
    return usuario?.id ?? 0;
  }

  Future<String> _obtenerSupabaseIdProducto(int isarId) async {
    final producto = await _isarService.obtenerProductoPorId(isarId);
    return producto?.supabaseId ?? '';
  }

  Future<int> _obtenerIsarIdProducto(String supabaseId) async {
    final producto = await _isarService.obtenerProductoPorSupabaseId(supabaseId);
    return producto?.id ?? 0;
  }

  Future<int> _obtenerLocalActual() async {
    // Implementa con tu lógica real (SharedPreferences, provider, etc.)
    return 1; // Placeholder
  }

  // ==========================================
  // SINCRONIZAR TODO
  // ==========================================

  Future<void> sincronizarTodo() async {
    await sincronizarVentasPendientes();
    await sincronizarMovimientosInventario();
    await sincronizarProductosASupabase();
    await sincronizarCategoriasASupabase();
    await sincronizarTurnos();
    await sincronizarUsuariosASupabase();
    await sincronizarGastosPendientes();
    await sincronizarPedidosPendientes();
    await descargarPedidosDesdeSupabase();
    await sincronizarUsuariosDesdeSupabase();
  }
}