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
        sincronizarTodo();
      }
    });
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
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
          // Buscar si ya existe por id_isar
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

/// Obtiene el total de ventas realizadas en un rango de fechas (para un usuario)
Future<double> obtenerTotalVentasPorEmpleadoYRango(
  String empleado,
  DateTime inicio,
  DateTime fin,
) async {
  final isar = await _isarService.db;
  final ventas = await isar.ventaEntitys
      .filter()
      .empleadoEqualTo(empleado)
      .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
      .findAll();

  double total = 0;
  for (var v in ventas) {
    total += v.total;
  }
  return total;
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
    // Primero, actualizar stock usando RPC (si existe)
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
        // Insertar registro en movimientos_inventarios
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
      // Si RPC falla, intentamos directo (actualizar producto y luego insertar)
      debugPrint('⚠️ RPC falló, intentando directo: $rpcError');
      
      // ✅ CORRECCIÓN: Usar _isarService en lugar de db
      final producto = await _isarService.obtenerProductoPorId(mov.productoId);
      if (producto != null && producto.codigoBarras.isNotEmpty) {
        // Actualizar stock en Supabase usando codigo_barras
        await _supabase
            .from('productos')
            .update({'stock': mov.stockResultante})
            .eq('codigo_barras', producto.codigoBarras);

        // Insertar movimiento
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
        'imagen_url': p.imagenUrl ?? '', // ✅ Enviar la URL guardada
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

 /// Elimina un producto de Supabase por su código de barras.
/// Retorna `true` si se eliminó al menos una fila, `false` en caso contrario.
Future<bool> eliminarProductoEnSupabase(String codigoBarras) async {
  try {
    final codigoLimpio = codigoBarras.trim();
    if (codigoLimpio.isEmpty) {
      debugPrint('⚠️ Código de barras vacío, no se puede eliminar.');
      return false;
    }

    // Primero, verificar si el producto existe (con eq exacto)
    var existing = await _supabase
        .from('productos')
        .select('id')
        .eq('codigo_barras', codigoLimpio)
        .maybeSingle();

    // Si no existe con exacto, intentar con ilike (insensible a mayúsculas)
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

    // Ejecutar DELETE (usando el id para mayor precisión)
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

  Future<void> sincronizarTodo() async {
    await sincronizarVentasPendientes();
    await sincronizarMovimientosInventario();
    await sincronizarProductosASupabase();
    await sincronizarCategoriasASupabase();
    await sincronizarTurnos();
    await sincronizarUsuariosASupabase();
    await sincronizarGastosPendientes();
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

      // Verificar si ya existe un turno con este id_isar
      final existing = await _supabase
          .from('turnos')
          .select('id_isar')
          .eq('id_isar', turno.id)
          .maybeSingle();

      if (existing == null) {
        // Insertar nuevo
        await _supabase.from('turnos').insert(payload);
        debugPrint('✅ Turno ${turno.id} insertado correctamente');
      } else {
        // Actualizar existente
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
      final ventaId = data['venta_id'] as String? ?? '';
      if (ventaId.isEmpty) continue;

      // 🔥 Descargar detalles de esta venta
      final detallesResponse = await _supabase
          .from('detalle_ventas')
          .select()
          .eq('venta_id_fk', ventaId);

      final detalles = detallesResponse.map<DetalleVentaEntity>((d) {
        return DetalleVentaEntity()
          ..nombreProducto = d['nombre_producto'] ?? ''
          ..precioUnidad = (d['precio_unidad'] as num?)?.toDouble() ?? 0.0
          ..cantidad = (d['cantidad'] as num?)?.toDouble() ?? 0.0
          ..subtotal = (d['subtotal'] as num?)?.toDouble() ?? 0.0;
      }).toList();

      // Buscar si ya existe localmente
      final existing = await _isarService.obtenerVentaPorIdString(ventaId);

      final venta = VentaEntity()
        ..ventaIdString = ventaId
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

      // Guardar detalles (usando el ID local de la venta)
      if (detalles.isNotEmpty) {
        await _isarService.guardarDetallesVenta(venta.id, detalles);
        debugPrint('📦 ${detalles.length} detalles guardados para venta $ventaId');
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
        ..imagenUrl = data['imagen_url'] ?? '';

      // Guardar localmente (si ya existe, se actualiza por código de barras)
      await _isarService.guardarProducto(producto);
    }

    debugPrint('✅ ${response.length} productos descargados y guardados localmente');
  } catch (e) {
    debugPrint('❌ Error descargando productos: $e');
  }
}
  // ==========================================
  // LIMPIEZA DE RECURSOS
  // ==========================================

  void dispose() {
    detenerMonitoreo();
  }
}