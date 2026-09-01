import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

// Entidades locales
import '../../data/Local/entities/categoria_entity.dart';
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
// ignore: unused_import
import '../../data/Local/entities/codigo_barra_alia_entity.dart';
// ignore: unused_import
import '../../data/Local/entities/lote_entity.dart';
import '../../data/Local/entities/telegram_config_entity.dart';
import '../../data/Local/entities/marca_entity.dart';

/// Servicio central de sincronización entre la base de datos local (Isar) y Supabase.
/// Maneja la subida y descarga de datos, así como la monitorización de conectividad.
class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  final SupabaseClient _supabase = Supabase.instance.client;

  String _syncServerUrl = 'https://your-sync-server.example';
  String _syncApiKey = '<REPLACE_WITH_SYNC_API_KEY>';

  bool _configLoaded = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  // ============================================================
  // SUSCRIPCIONES REALTIME Y CALLBACK
  // ============================================================
  List<RealtimeChannel> _channels = [];

  /// Callback opcional para notificar cambios en la UI
  final VoidCallback? onDataChanged;

  /// Constructor con callback opcional
  SyncService({this.onDataChanged});

  /// Inicia suscripciones a cambios en las tablas principales
  void iniciarSuscripcionesRealtime() {
    _suscribirATabla('productos', () => descargarProductosDesdeSupabase());
    _suscribirATabla('categorias', () => descargarCategoriasDesdeSupabase());
    _suscribirATabla('marcas', () => descargarMarcasDesdeSupabase());
    _suscribirATabla('locales', () => descargarLocalesDesdeSupabase());
    _suscribirATabla(
        'departamentos', () => descargarDepartamentosDesdeSupabase());
    _suscribirATabla('usuarios', () => sincronizarUsuariosDesdeSupabase());
    _suscribirATabla('gastos', () => descargarGastosDesdeSupabase());
    debugPrint('✅ Suscripciones Realtime iniciadas');
  }

  void _suscribirATabla(String tabla, Future<void> Function() onCambio) {
    final channel = _supabase
        .channel('realtime:$tabla')
        .onPostgresChanges(
          schema: 'public',
          table: tabla,
          event: PostgresChangeEvent.all, // <--- USAR ENUM
          callback: (payload) {
            debugPrint('🔄 Cambio detectado en $tabla, actualizando...');
            onCambio();
          },
        )
        .subscribe();
    _channels.add(channel);
  }

  /// Detiene todas las suscripciones
  void detenerSuscripcionesRealtime() {
    for (var channel in _channels) {
      channel.unsubscribe();
    }
    _channels.clear();
    debugPrint('⏹️ Suscripciones Realtime detenidas');
  }

  // ============================================================
  // CONFIGURACIÓN Y MONITOREO
  // ============================================================

  /// Cabeceras de autenticación para el microservicio.
  Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_syncApiKey',
    };
  }

  /// Verifica si la configuración del microservicio es válida.
  bool _hasValidSyncConfig() {
    return _syncServerUrl.isNotEmpty &&
        _syncServerUrl != 'https://your-sync-server.example' &&
        _syncApiKey.isNotEmpty &&
        _syncApiKey != '<REPLACE_WITH_SYNC_API_KEY>';
  }

  /// Carga la configuración desde `assets/config.json`.
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

  /// Inicia el monitoreo de conectividad. Al recuperar conexión, ejecuta sincronización completa.
  void iniciarMonitoreo() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      final tieneConexion =
          results.any((result) => result != ConnectivityResult.none);
      if (tieneConexion) {
        sincronizarTodo();
      }
    });
  }

  /// Detiene el monitoreo de conectividad.
  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Libera recursos.
  void dispose() {
    detenerMonitoreo();
    detenerSuscripcionesRealtime();
  }

  // ============================================================
  // USUARIOS (CORREGIDO)
  // ============================================================

  /// Sube todos los usuarios locales a Supabase (crea o actualiza).
  Future<void> sincronizarUsuariosASupabase() async {
    try {
      final usuarios = await _isarService.obtenerUsuarios();
      if (usuarios.isEmpty) {
        debugPrint('ℹ️ No hay usuarios locales para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${usuarios.length} usuarios con Supabase...');
      int sincronizados = 0;

      for (var usuario in usuarios) {
        try {
          // 1️⃣ Si no tiene supabaseId, verificar si ya existe en auth.users por email
          if (usuario.supabaseId == null || usuario.supabaseId!.isEmpty) {
            // Si no tiene email, no podemos crearlo en auth
            if (usuario.email == null || usuario.email!.isEmpty) {
              debugPrint('⚠️ Usuario "${usuario.nombre}" sin email, omitido');
              continue;
            }

            // Buscar en auth.users por email
            try {
              final allUsers = await _supabase.auth.admin.listUsers();
              final existingUser = allUsers.firstWhereOrNull(
                (u) => u.email == usuario.email,
              );

              if (existingUser != null) {
                // Ya existe en auth, usar su ID
                usuario.supabaseId = existingUser.id;
                await _isarService.guardarUsuario(usuario);
                debugPrint(
                    '✅ Usuario "${usuario.nombre}" tiene cuenta en auth (ID: ${usuario.supabaseId})');
              } else {
                // No existe en auth, crearlo
                if (usuario.password == null || usuario.password!.isEmpty) {
                  debugPrint(
                      '⚠️ Usuario "${usuario.nombre}" sin password, omitido');
                  continue;
                }

                final newUser = await _supabase.auth.admin.createUser(
                  AdminUserAttributes(
                    email: usuario.email!,
                    password: usuario.password!,
                    emailConfirm: true,
                    userMetadata: {
                      'nombre': usuario.nombre,
                      'rol': usuario.rol,
                    },
                  ),
                );
                usuario.supabaseId = newUser.user?.id;
                await _isarService.guardarUsuario(usuario);
                debugPrint(
                    '✅ Usuario "${usuario.nombre}" creado en auth.users (ID: ${usuario.supabaseId})');
              }
            } catch (e) {
              debugPrint('⚠️ Error al buscar/crear usuario en auth: $e');
              continue;
            }
          }

          // 2️⃣ Ahora sí, insertar/actualizar en public.usuarios
          final data = {
            'id': usuario.supabaseId,
            'id_isar': usuario.id,
            'nombre': usuario.nombre,
            'pin': usuario.pin,
            'rol': usuario.rol,
            'email': usuario.email ?? '',
            'device_id': usuario.deviceId ?? '',
            'estado': usuario.estado,
            'caja_asignada': usuario.cajaAsignada,
            'departamento': usuario.departamento,
            'local_id': usuario.localId,
          };

          await _supabase.from('usuarios').upsert(data, onConflict: 'id_isar');
          sincronizados++;
        } catch (e) {
          debugPrint('⚠️ Error sincronizando usuario "${usuario.nombre}": $e');
        }
      }
      debugPrint('✅ $sincronizados usuarios sincronizados con Supabase');
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error general sincronizando usuarios: $e');
    }
  }

  /// Descarga todos los usuarios desde Supabase y los guarda/actualiza localmente.
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

      debugPrint(
          '🔄 Descargando ${response.length} usuarios desde Supabase...');
      final locales = await _isarService.obtenerUsuarios();
      final Map<int, UsuarioEntity> localesMap = {
        for (var u in locales) u.id: u
      };

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
          local.localId = data['local_id'] as int?;

          final estadoNube = data['estado'] as String? ?? 'inactivo';
          if (estadoNube == 'inactivo' &&
              (local.estado == 'activo' || local.estado == 'descanso')) {
            local.estado = 'inactivo';
            debugPrint(
                '🔄 Usuario ${local.nombre} marcado como inactivo por sincronización');
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
            ..departamento = data['departamento']
            ..localId = data['local_id'] as int?;
          await _isarService.guardarUsuario(nuevoUsuario);
        }
      }
      debugPrint('✅ Usuarios sincronizados desde Supabase');
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando usuarios: $e');
      rethrow;
    }
  }

  /// Obtiene la lista de usuarios desde Supabase (como Map).
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

  /// Actualiza el estado de un usuario en Supabase.
  Future<bool> actualizarEstadoUsuarioEnSupabase(
      int userId, String nuevoEstado) async {
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

  /// Elimina un usuario de Supabase por su ID de Isar.
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

  /// Stream en tiempo real de cambios en usuarios (para monitoreo).
  Stream<List<UsuarioEntity>> streamUsuariosEnTiempoReal() {
    return _supabase.from('usuarios').stream(primaryKey: ['id']).map((data) {
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

  // ============================================================
  // PROVEEDORES
  // ============================================================

  /// Sincroniza proveedores pendientes (syncStatus = pending/failed) hacia Supabase.
  Future<void> sincronizarProveedoresPendientes() async {
    try {
      final pendientes = await _isarService.obtenerProveedoresPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay proveedores pendientes para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} proveedores con Supabase...');

      for (var proveedor in pendientes) {
        debugPrint(
            '📤 Enviando proveedor: ${proveedor.nombre} (ID local: ${proveedor.id})');

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
          final response = await _supabase
              .from('proveedores')
              .upsert(data, onConflict: 'id_isar')
              .select('id')
              .maybeSingle();

          String? supabaseId = response?['id'] as String?;
          if (supabaseId == null) {
            final findResponse = await _supabase
                .from('proveedores')
                .select('id')
                .eq('id_isar', proveedor.id)
                .maybeSingle();
            supabaseId = findResponse?['id'] as String?;
          }

          if (supabaseId != null) {
            proveedor.supabaseId = supabaseId;
            proveedor.sincronizado = true;
            proveedor.fechaSincronizacion = DateTime.now();
            proveedor.updatedAt = DateTime.now();
            await _isarService.guardarProveedor(proveedor);
            debugPrint(
                '✅ Proveedor ${proveedor.nombre} sincronizado con ID: $supabaseId');
          } else {
            debugPrint(
                '⚠️ No se pudo obtener ID de Supabase para ${proveedor.nombre}');
          }
        } catch (e) {
          debugPrint(
              '❌ Error al sincronizar proveedor ${proveedor.nombre}: $e');
        }
      }
      debugPrint('✅ Sincronización de proveedores completada');
    } catch (e) {
      debugPrint('❌ Error general en sincronizarProveedoresPendientes: $e');
      rethrow;
    }
  }

  /// Descarga todos los proveedores desde Supabase y los guarda/actualiza localmente.
  Future<void> descargarProveedoresDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('proveedores')
          .select()
          .order('nombre', ascending: true);
      debugPrint(
          '🔄 Descargando ${response.length} proveedores desde Supabase...');

      final locales = await _isarService.obtenerProveedores(soloActivos: false);
      final Map<String, ProveedorEntity> localesPorSupabaseId = {
        for (var p in locales)
          if (p.supabaseId != null) p.supabaseId!: p
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
          proveedorNube.id = local.id;
          await _isarService.guardarProveedor(proveedorNube);
          debugPrint('🔄 Proveedor ${proveedorNube.nombre} actualizado');
        } else {
          await _isarService.guardarProveedor(proveedorNube);
          debugPrint('📥 Proveedor ${proveedorNube.nombre} creado');
        }
      }
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando proveedores: $e');
      rethrow;
    }
  }

  /// Elimina un proveedor de Supabase por su UUID.
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

  /// Sincronización forzada (subida y descarga) de proveedores.
  Future<void> sincronizarProveedoresForzada() async {
    try {
      debugPrint('🔥 Iniciando sincronización forzada de proveedores...');

      final response = await _supabase
          .from('proveedores')
          .select()
          .order('nombre', ascending: true);
      debugPrint(
          '📥 Descargados ${response.length} proveedores desde Supabase');

      final locales = await _isarService.obtenerProveedores(soloActivos: false);
      final Map<int, ProveedorEntity> localesPorId = {
        for (var p in locales) p.id: p
      };
      final Map<String, ProveedorEntity> localesPorSupabaseId = {
        for (var p in locales)
          if (p.supabaseId != null) p.supabaseId!: p
      };

      final Set<int> idsLocalesProcesados = {};
      final Set<String> supabaseIdsProcesados = {};

      for (var data in response) {
        final supabaseId = data['id'] as String?;
        if (supabaseId == null) continue;
        supabaseIdsProcesados.add(supabaseId);

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
          proveedorNube.id = local.id;
          await _isarService.guardarProveedor(proveedorNube);
          idsLocalesProcesados.add(local.id);
          debugPrint('🔄 Proveedor actualizado: ${proveedorNube.nombre}');
        } else {
          await _isarService.guardarProveedor(proveedorNube);
          debugPrint(
              '📥 Proveedor creado desde Supabase: ${proveedorNube.nombre}');
        }
      }

      int subidos = 0;
      for (var local in locales) {
        if (!idsLocalesProcesados.contains(local.id)) {
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
            final response = await _supabase
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
      debugPrint(
          '✅ Sincronización forzada completada: ${response.length} descargados, $subidos subidos');
    } catch (e) {
      debugPrint('❌ Error en sincronización forzada: $e');
      rethrow;
    }
  }

  // ============================================================
  // PRODUCTOS
  // ============================================================

  /// Limpia valores numéricos (evita NaN o infinito).
  double _limpiarNumero(double? valor, [double valorPorDefecto = 0.0]) {
    if (valor == null || valor.isNaN || valor.isInfinite)
      return valorPorDefecto;
    return valor;
  }

  /// Sube todos los productos locales a Supabase (crea o actualiza por código de barras).
  Future<bool> sincronizarProductosASupabase() async {
    try {
      final productosLocales = await _isarService.obtenerProductos();
      if (productosLocales.isEmpty) return true;

      final List<Map<String, dynamic>> payloadList = productosLocales.map((p) {
        final Map<String, dynamic> payload = {
          'id_isar': p.id,
          'codigo_barras': p.codigoBarras,
          'nombre': p.nombre,
          'marca': p.marca,
          'marca_supabase_id': p.marcaSupabaseId,
          'precio_unidad': _limpiarNumero(p.precioUnidad, 0.0),
          'stock': _limpiarNumero(p.stock, 0.0),
          'stock_minimo': _limpiarNumero(p.stockMinimo, 5.0),
          'es_pesado': p.esPesado,
          'categoria': p.categoria,
          'proveedor_nombre': p.proveedorNombre,
          'proveedor_telefono': p.proveedorTelefono,
          'proveedor_email': p.proveedorEmail,
          'proveedor_direccion': p.proveedorDireccion,
          'version': p.version,
          'created_at': p.createdAt?.toIso8601String(),
          'updated_at': p.updatedAt?.toIso8601String(),
          'created_by': p.createdBy,
          'updated_by': p.updatedBy,
          'created_by_name': p.createdByName ?? '',
          'updated_by_name': p.updatedByName ?? '',
        };
        if (p.imagenUrl != null && p.imagenUrl!.isNotEmpty) {
          payload['imagen_url'] = p.imagenUrl;
        }
        return payload;
      }).toList();

      await _supabase
          .from('productos')
          .upsert(payloadList, onConflict: 'codigo_barras');

      // Actualizar supabaseId local
      final idsIsar = productosLocales.map((p) => p.id).toList();
      final response = await _supabase
          .from('productos')
          .select('id, id_isar')
          .inFilter('id_isar', idsIsar);

      final Map<int, String> mapa = {};
      for (var row in response) {
        final idIsar = row['id_isar'] as int?;
        final supabaseId = row['id']?.toString();
        if (idIsar != null && supabaseId != null && supabaseId.isNotEmpty) {
          mapa[idIsar] = supabaseId;
        }
      }

      int actualizados = 0;
      for (var p in productosLocales) {
        final nuevoId = mapa[p.id];
        if (nuevoId != null && p.supabaseId != nuevoId) {
          p.supabaseId = nuevoId;
          p.sincronizado = true;
          p.fechaSincronizacion = DateTime.now();
          await _isarService.guardarProducto(p);
          actualizados++;
        }
      }

      debugPrint(
          '✅ ${productosLocales.length} productos sincronizados. $actualizados supabaseId actualizados.');
      return true;
    } catch (e) {
      debugPrint('🚫 Error sincronizando productos: $e');
      return false;
    }
  }

  /// Descarga todos los productos desde Supabase y los guarda/actualiza localmente.
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

      debugPrint(
          '🔄 Procesando ${response.length} productos desde Supabase...');

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

        final imagenUrlNube = data['imagen_url'] as String?;
        final imagenUrlLocal = productoLocal?.imagenUrl ?? '';
        final imagenUrlFinal =
            (imagenUrlNube != null && imagenUrlNube.isNotEmpty)
                ? imagenUrlNube
                : imagenUrlLocal;

        final productoNube = ProductoEntity()
          ..codigoBarras = codigoBarras
          ..nombre = data['nombre'] ?? ''
          ..marca = data['marca'] as String? ?? ''
          ..marcaSupabaseId = data['marca_supabase_id'] as String?
          ..precioUnidad = (data['precio_unidad'] as num?)?.toDouble() ?? 0.0
          ..stock = (data['stock'] as num?)?.toDouble() ?? 0.0
          ..stockMinimo = (data['stock_minimo'] as num?)?.toDouble() ?? 5.0
          ..esPesado = data['es_pesado'] ?? false
          ..categoria = data['categoria'] ?? ''
          ..proveedorNombre = data['proveedor_nombre'] ?? ''
          ..proveedorTelefono = data['proveedor_telefono'] ?? ''
          ..proveedorEmail = data['proveedor_email'] ?? ''
          ..proveedorDireccion = data['proveedor_direccion'] ?? ''
          ..version = data['version'] ?? 0
          ..createdAt = data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null
          ..updatedAt = data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null
          ..createdBy = data['created_by'] as int?
          ..updatedBy = data['updated_by'] as int?
          ..createdByName = data['created_by_name'] ?? ''
          ..updatedByName = data['updated_by_name'] ?? ''
          ..imagenUrl = imagenUrlFinal.isEmpty ? null : imagenUrlFinal
          ..supabaseId = data['id']?.toString()
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        if (productoLocal != null) {
          productoNube.id = productoLocal.id;
          productoNube.proveedorId = productoLocal.proveedorId;
          await _isarService.guardarProducto(productoNube);
          debugPrint('🔄 Producto actualizado: ${productoNube.nombre}');
        } else {
          await _isarService.guardarProducto(productoNube);
          debugPrint('✅ Producto creado: ${productoNube.nombre}');
        }
      }

      int eliminados = 0;
      for (var producto in productosLocales) {
        if (!codigosEnNube.contains(producto.codigoBarras)) {
          await _isarService.eliminarProducto(producto.id);
          eliminados++;
          debugPrint(
              '🗑️ Producto eliminado por no existir en Supabase: ${producto.nombre}');
        }
      }
      debugPrint(
          '✅ Productos sincronizados: ${response.length} actualizados/creados, $eliminados eliminados');
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando productos: $e');
      rethrow;
    }
  }

  /// Elimina un producto de Supabase por su código de barras.
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
        debugPrint(
            'ℹ️ Producto con código exacto "$codigoLimpio" no encontrado, intentando búsqueda flexible...');
        final resultados = await _supabase
            .from('productos')
            .select('id')
            .ilike('codigo_barras', codigoLimpio)
            .limit(1);
        if (resultados.isNotEmpty) {
          existing = resultados.first;
          debugPrint(
              '🔍 Producto encontrado con búsqueda flexible: ${existing['id']}');
        }
      }

      if (existing == null) {
        debugPrint(
            'ℹ️ Producto con código "$codigoLimpio" no existe en Supabase.');
        return false;
      }

      final response =
          await _supabase.from('productos').delete().eq('id', existing['id']);
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

  // ============================================================
  // VENTAS
  // ============================================================

  /// Sincroniza ventas pendientes (syncStatus = pending/failed) hacia Supabase.
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

      debugPrint(
          '🔄 [SyncService] Sincronizando ${pendientes.length} ventas...');

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

  /// Envía una venta al microservicio o directamente a Supabase.
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
          final response = await http
              .post(
                Uri.parse('$_syncServerUrl/api/ventas/sync'),
                headers: _authHeaders(),
                body: jsonEncode(payload),
              )
              .timeout(const Duration(seconds: 10));
          if (response.statusCode == 200 || response.statusCode == 201) {
            debugPrint(
                '✅ Venta ${venta.ventaIdString} sincronizada vía microservicio');
            return true;
          }
        } catch (e) {
          debugPrint(
              '⚠️ Microservicio falló, intentando con Supabase directo: $e');
        }
      } else {
        debugPrint('ℹ️ No hay configuración válida; se usa Supabase directo.');
      }

      final responseVenta =
          await _supabase.from('ventas').insert(payload).select('id').single();
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

      debugPrint(
          '✅ Venta ${venta.ventaIdString} sincronizada vía Supabase directo');
      return true;
    } catch (e) {
      debugPrint(
          '🚫 [Supabase] Error al insertar venta ${venta.ventaIdString}: $e');
      return false;
    }
  }

  /// Descarga todas las ventas desde Supabase y las guarda/actualiza localmente.
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
      int insertadas = 0, actualizadas = 0;

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

        final existing =
            await _isarService.obtenerVentaPorIdString(ventaIdString);
        final venta = VentaEntity()
          ..ventaIdString = ventaIdString
          ..fecha = DateTime.parse(data['fecha']).toLocal()
          ..subtotal = (data['subtotal'] as num).toDouble()
          ..impuesto = (data['impuesto'] as num).toDouble()
          ..total = (data['total'] as num).toDouble()
          ..tasaBcv = (data['tasa_bcv'] as num?)?.toDouble() ?? 0.0
          ..totalBolivares =
              (data['total_bolivares'] as num?)?.toDouble() ?? 0.0
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
          final ventaLocal =
              await _isarService.obtenerVentaPorIdString(ventaIdString);
          if (ventaLocal != null) {
            await _isarService.guardarDetallesVenta(ventaLocal.id, detalles);
            debugPrint(
                '📦 ${detalles.length} detalles guardados para venta $ventaIdString');
          }
        }
      }
      debugPrint('✅ $insertadas ventas insertadas, $actualizadas actualizadas');
    } catch (e) {
      debugPrint('❌ Error descargando ventas: $e');
    }
  }

  // ============================================================
  // MOVIMIENTOS DE INVENTARIO
  // ============================================================

  /// Sincroniza movimientos de inventario pendientes hacia Supabase.
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

  Future<bool> _enviarMovimientoAlServidor(
      MovimientoInventarioEntity mov) async {
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

        final producto =
            await _isarService.obtenerProductoPorId(mov.productoId);
        if (producto != null && producto.codigoBarras.isNotEmpty) {
          await _supabase
              .from('productos')
              .update({'stock': mov.stockResultante}).eq(
                  'codigo_barras', producto.codigoBarras);

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
          debugPrint(
              '⚠️ Producto no encontrado o sin código de barras para movimiento ${mov.id}');
          return false;
        }
      }
    } catch (e) {
      debugPrint('🚫 Error enviando movimiento ${mov.id}: $e');
      return false;
    }
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  /// Sincroniza categorías pendientes hacia Supabase.
  Future<void> sincronizarCategorias() async {
    try {
      final pendientes = await _isarService.obtenerCategoriasPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay categorías pendientes para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} categorías con Supabase...');
      int sincronizadas = 0;

      for (final categoria in pendientes) {
        try {
          if (categoria.supabaseId == null || categoria.supabaseId!.isEmpty) {
            categoria.supabaseId = const Uuid().v4();
            await _isarService.guardarCategoria(categoria);
          }

          final json = categoria.toSupabaseJson();
          await _supabase
              .from('categorias')
              .upsert(json, onConflict: 'id')
              .select();
          categoria.syncStatus = 'synced';
          await _isarService.guardarCategoria(categoria);
          sincronizadas++;
        } catch (e) {
          categoria.syncStatus = 'failed';
          await _isarService.guardarCategoria(categoria);
          debugPrint('❌ Error sincronizando categoría ${categoria.nombre}: $e');
        }
      }
      debugPrint('✅ $sincronizadas categorías sincronizadas con Supabase');
    } catch (e) {
      debugPrint('❌ Error general sincronizando categorías: $e');
    }
  }

  /// Descarga todas las categorías desde Supabase y las guarda/actualiza localmente.
  Future<void> descargarCategoriasDesdeSupabase() async {
    try {
      final response = await _supabase.from('categorias').select('*');
      debugPrint(
          '📥 [SyncService] Descargadas ${response.length} categorías desde Supabase');

      int guardadas = 0;
      for (final json in response) {
        final supabaseId = json['id']?.toString();
        if (supabaseId == null || supabaseId.isEmpty) {
          debugPrint('⚠️ Categoría sin id, omitiendo: $json');
          continue;
        }

        final categoria = CategoriaEntity.fromSupabase(json);
        final existente =
            await _isarService.obtenerCategoriaPorSupabaseId(supabaseId);

        if (existente != null) {
          if (existente.nombre != categoria.nombre ||
              existente.descripcion != categoria.descripcion ||
              existente.activo != categoria.activo) {
            existente.nombre = categoria.nombre;
            existente.descripcion = categoria.descripcion;
            existente.activo = categoria.activo;
            existente.updatedAt = DateTime.now();
            existente.syncStatus = 'synced';
            await _isarService.guardarCategoria(existente);
            guardadas++;
          }
        } else {
          await _isarService.guardarCategoria(categoria);
          guardadas++;
        }
      }
      debugPrint(
          '✅ [SyncService] $guardadas categorías guardadas/actualizadas en Isar');
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando categorías: $e');
    }
  }

  // ============================================================
  // MARCAS
  // ============================================================

  /// Sincroniza marcas pendientes hacia Supabase.
  Future<void> sincronizarMarcasPendientes() async {
    try {
      final pendientes = await _isarService.obtenerMarcasPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay marcas pendientes para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} marcas con Supabase...');
      int sincronizadas = 0;

      for (var marca in pendientes) {
        final exito = await _enviarMarcaAlServidor(marca);
        if (exito) {
          await _isarService.actualizarSyncStatusMarca(marca.id, 'synced');
          sincronizadas++;
          debugPrint('✅ Marca ${marca.nombre} sincronizada');
        } else {
          await _isarService.actualizarSyncStatusMarca(marca.id, 'failed');
          debugPrint('⚠️ Marca ${marca.nombre} marcada como failed');
        }
      }
      debugPrint('✅ $sincronizadas marcas sincronizadas con Supabase');
    } catch (e) {
      debugPrint('❌ Error sincronizando marcas: $e');
    }
  }

  Future<bool> _enviarMarcaAlServidor(MarcaEntity marca) async {
    try {
      if (marca.supabaseId == null || marca.supabaseId!.isEmpty) {
        marca.supabaseId = const Uuid().v4();
      }

      final data = {
        'id': marca.supabaseId,
        'nombre': marca.nombre,
        'descripcion': marca.descripcion,
        'logo_url': marca.logoUrl,
        'proveedor_id': marca.proveedorId,
        'activo': marca.activo,
        'created_at': marca.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('marcas').upsert(data, onConflict: 'id').select();
      return true;
    } catch (e) {
      debugPrint('🚫 Error enviando marca ${marca.nombre}: $e');
      return false;
    }
  }

  /// Descarga todas las marcas desde Supabase y las guarda/actualiza localmente.
  Future<void> descargarMarcasDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('marcas')
          .select()
          .order('nombre', ascending: true);
      debugPrint(
          '📥 [SyncService] Descargadas ${response.length} marcas desde Supabase');

      final isar = await _isarService.db;
      int guardadas = 0, actualizadas = 0;

      final locales = await isar.marcaEntitys.where().findAll();
      final Map<String, MarcaEntity> localesPorSupabaseId = {
        for (var m in locales)
          if (m.supabaseId != null) m.supabaseId!: m
      };

      for (var json in response) {
        final supabaseId = json['id'] as String?;
        if (supabaseId == null) continue;

        final marcaNube = MarcaEntity.fromSupabase(json);
        final local = localesPorSupabaseId[supabaseId];

        if (local != null) {
          if (local.nombre != marcaNube.nombre ||
              local.descripcion != marcaNube.descripcion ||
              local.logoUrl != marcaNube.logoUrl ||
              local.proveedorId != marcaNube.proveedorId ||
              local.activo != marcaNube.activo) {
            local.nombre = marcaNube.nombre;
            local.descripcion = marcaNube.descripcion;
            local.logoUrl = marcaNube.logoUrl;
            local.proveedorId = marcaNube.proveedorId;
            local.activo = marcaNube.activo;
            local.updatedAt = DateTime.now();
            local.syncStatus = 'synced';
            await isar.writeTxn(() async {
              await isar.marcaEntitys.put(local);
            });
            actualizadas++;
          }
        } else {
          await isar.writeTxn(() async {
            await isar.marcaEntitys.put(marcaNube);
          });
          guardadas++;
        }
      }
      debugPrint(
          '✅ [SyncService] $guardadas marcas insertadas, $actualizadas actualizadas');
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando marcas: $e');
      rethrow;
    }
  }

  // ============================================================
  // GASTOS
  // ============================================================

  /// Descarga todos los gastos desde Supabase y los guarda/actualiza localmente.
  Future<void> descargarGastosDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('gastos')
          .select()
          .order('fecha', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay gastos en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} gastos desde Supabase...');

      // Obtener todos los gastos locales actuales para mapear por id_isar y supabaseId
      final gastosLocales = await _isarService.obtenerGastos();
      final Map<int, GastoEntity> porIdIsar = {
        for (var g in gastosLocales) g.id: g
      };
      final Map<String, GastoEntity> porSupabaseId = {
        for (var g in gastosLocales)
          if (g.supabaseId != null && g.supabaseId!.isNotEmpty) g.supabaseId!: g
      };

      int insertados = 0, actualizados = 0;

      for (var data in response) {
        final supabaseId = data['id'] as String?;
        if (supabaseId == null || supabaseId.isEmpty) continue;

        final idIsar = data['id_isar'] as int?;
        GastoEntity? gastoLocal;

        // Buscar por supabaseId o por id_isar
        if (idIsar != null && porIdIsar.containsKey(idIsar)) {
          gastoLocal = porIdIsar[idIsar];
        } else if (supabaseId.isNotEmpty &&
            porSupabaseId.containsKey(supabaseId)) {
          gastoLocal = porSupabaseId[supabaseId];
        }

        // Crear entidad con los datos de la nube
        final gastoNube = GastoEntity()
          ..supabaseId = supabaseId
          ..descripcion = data['descripcion'] ?? ''
          ..monto = (data['monto'] as num?)?.toDouble() ?? 0.0
          ..moneda = data['moneda'] ?? 'USD'
          ..tasaBcv = (data['tasa_bcv'] as num?)?.toDouble()
          ..categoria = data['categoria'] ?? 'General'
          ..usuarioId = data['usuario_id'] as int? ?? 0
          ..usuarioNombre = data['usuario_nombre'] ?? ''
          ..fecha = DateTime.parse(data['fecha']).toLocal()
          ..syncStatus = 'synced';

        if (gastoLocal != null) {
          // Actualizar existente: conservar el id de Isar y reemplazar el resto
          gastoNube.id = gastoLocal.id;
          await _isarService.guardarGasto(gastoNube);
          actualizados++;
          debugPrint('🔄 Gasto actualizado: ${gastoNube.descripcion}');
        } else {
          // Insertar nuevo (Isar generará un id automáticamente si es 0)
          // Si el id_isar existe en la nube pero no local, podemos usarlo.
          if (idIsar != null && idIsar > 0) {
            gastoNube.id = idIsar;
          }
          await _isarService.guardarGasto(gastoNube);
          insertados++;
          debugPrint('📥 Gasto creado: ${gastoNube.descripcion}');
        }
      }

      debugPrint(
          '✅ Gastos sincronizados: $insertados insertados, $actualizados actualizados');
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando gastos desde Supabase: $e');
      rethrow;
    }
  }

  /// Sincroniza gastos pendientes hacia Supabase.
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

      debugPrint(
          '🔄 [SyncService] Sincronizando ${pendientes.length} gastos...');

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
      if (usuario != null &&
          usuario.supabaseId != null &&
          usuario.supabaseId!.isNotEmpty) {
        usuarioUuid = usuario.supabaseId;
      } else {
        debugPrint(
            '⚠️ Usuario ID ${gasto.usuarioId} no tiene supabaseId. Se envía null.');
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

      final existing = await _supabase
          .from('gastos')
          .select('id')
          .eq('id_isar', gasto.id)
          .maybeSingle();
      if (existing != null) {
        await _supabase.from('gastos').update(payload).eq('id_isar', gasto.id);
        debugPrint('✅ Gasto ${gasto.id} actualizado correctamente.');
      } else {
        await _supabase.from('gastos').insert(payload);
        debugPrint('✅ Gasto ${gasto.id} insertado correctamente.');
      }
      return true;
    } catch (e) {
      debugPrint('🚫 Error al enviar gasto: $e');
      return false;
    }
  }

  // ============================================================
  // TURNOS
  // ============================================================

  /// Sincroniza turnos pendientes hacia Supabase.
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

      debugPrint(
          '🔄 [SyncService] Sincronizando ${pendientes.length} turnos...');

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
      final payload = {
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
        await _supabase.from('turnos').update(payload).eq('id_isar', turno.id);
        debugPrint('✅ Turno ${turno.id} actualizado correctamente');
      }
      return true;
    } catch (e) {
      debugPrint('🚫 Error al enviar turno: $e');
      return false;
    }
  }

  // ============================================================
  // LOCALES
  // ============================================================

  /// Sincroniza locales pendientes hacia Supabase.
  Future<void> sincronizarLocalesPendientes() async {
    try {
      final pendientes = await _isarService.obtenerLocalesPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay locales pendientes para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} locales con Supabase...');

      for (var local in pendientes) {
        final data = {
          'id_isar': local.id,
          'nombre': local.nombre,
          'rif': local.rif,
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
            debugPrint(
                '✅ Local ${local.nombre} sincronizado con ID: $supabaseId');
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

  /// Descarga todos los locales desde Supabase y los guarda/actualiza localmente.
  Future<void> descargarLocalesDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('locales')
          .select()
          .order('nombre', ascending: true);
      debugPrint('🔄 Descargando ${response.length} locales desde Supabase...');

      final localesLocales =
          await _isarService.obtenerLocales(soloActivos: false);
      final Map<String, LocalEntity> localesPorSupabaseId = {
        for (var l in localesLocales)
          if (l.supabaseId != null) l.supabaseId!: l
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
          ..fechaSincronizacion = DateTime.now()
          ..rif = data['rif'];

        if (local != null) {
          localNube.id = local.id;
          await _isarService.guardarLocal(localNube);
          debugPrint('🔄 Local ${localNube.nombre} actualizado');
        } else {
          await _isarService.guardarLocal(localNube);
          debugPrint('📥 Local ${localNube.nombre} creado');
        }
      }
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando locales: $e');
      rethrow;
    }
  }

  // ============================================================
  // DEPARTAMENTOS
  // ============================================================

  /// Sincroniza departamentos pendientes hacia Supabase.
  Future<void> sincronizarDepartamentosPendientes() async {
    try {
      final pendientes =
          await _isarService.obtenerDepartamentosPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay departamentos pendientes para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} departamentos con Supabase...');

      for (var departamento in pendientes) {
        String? localUuid;
        if (departamento.localId != null) {
          localUuid = await _obtenerSupabaseIdLocal(departamento.localId!);
        }

        String? usuarioUuid;
        if (departamento.usuarioId != null) {
          usuarioUuid =
              await _obtenerSupabaseIdUsuario(departamento.usuarioId!);
        }

        final data = {
          'id_isar': departamento.id,
          'nombre': departamento.nombre,
          'descripcion': departamento.descripcion,
          'local_id': localUuid,
          'usuario_id': usuarioUuid,
          'activo': departamento.activo,
          'sync_status': 'synced',
          'updated_at': DateTime.now().toIso8601String(),
        };

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
            debugPrint(
                '✅ Departamento ${departamento.nombre} sincronizado con ID: $supabaseId');
          }
        } catch (e) {
          debugPrint(
              '❌ Error al sincronizar departamento ${departamento.nombre}: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error general en sincronizarDepartamentosPendientes: $e');
      rethrow;
    }
  }

  /// Descarga todos los departamentos desde Supabase y los guarda/actualiza localmente.
  Future<void> descargarDepartamentosDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('departamentos')
          .select()
          .order('nombre', ascending: true);
      debugPrint(
          '🔄 Descargando ${response.length} departamentos desde Supabase...');

      if (response.isEmpty) return;

      final localesLocales =
          await _isarService.obtenerLocales(soloActivos: false);
      final Map<String, int> uuidToIsarId = {};
      for (var local in localesLocales) {
        if (local.supabaseId != null) {
          uuidToIsarId[local.supabaseId!] = local.id;
        }
      }

      final deptosLocales =
          await _isarService.obtenerDepartamentos(soloActivos: false);
      final Map<String, DepartamentoEntity> localesPorSupabaseId = {
        for (var d in deptosLocales)
          if (d.supabaseId != null) d.supabaseId!: d
      };
      final Map<int, DepartamentoEntity> localesPorId = {
        for (var d in deptosLocales) d.id: d
      };

      for (var data in response) {
        final supabaseId = data['id'] as String?;
        if (supabaseId == null) continue;

        final idIsar = data['id_isar'] as int?;
        DepartamentoEntity? depto = localesPorSupabaseId[supabaseId];
        if (depto == null && idIsar != null) {
          depto = localesPorId[idIsar];
        }

        final localUuid = data['local_id'] as String?;
        int? localIsarId;
        if (localUuid != null && uuidToIsarId.containsKey(localUuid)) {
          localIsarId = uuidToIsarId[localUuid];
        }

        int? usuarioIsarId;
        final usuarioUuid = data['usuario_id'] as String?;
        if (usuarioUuid != null && usuarioUuid.isNotEmpty) {
          usuarioIsarId = await _obtenerIsarIdUsuario(usuarioUuid);
        }

        final deptoNube = DepartamentoEntity()
          ..supabaseId = supabaseId
          ..nombre = data['nombre'] ?? ''
          ..descripcion = data['descripcion'] as String?
          ..localId = localIsarId
          ..usuarioId = usuarioIsarId
          ..activo = data['activo'] ?? true
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        if (depto != null) {
          deptoNube.id = depto.id;
          await _isarService.guardarDepartamento(deptoNube);
          debugPrint('🔄 Departamento ${deptoNube.nombre} actualizado');
        } else {
          await _isarService.guardarDepartamento(deptoNube);
          debugPrint('📥 Departamento ${deptoNube.nombre} creado');
        }
      }
      onDataChanged?.call();
    } catch (e) {
      debugPrint('❌ Error descargando departamentos: $e');
      rethrow;
    }
  }

  // ============================================================
  // CÓDIGOS DE BARRAS ALIAS
  // ============================================================

  /// Sincroniza alias pendientes hacia Supabase.
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
          await _supabase
              .from('codigos_barras_alias')
              .update(data)
              .eq('id_isar', alias.id);
        }

        alias.sincronizado = true;
        alias.fechaSincronizacion = DateTime.now();
        await _isarService.guardarCodigoAlias(alias);
      }
    } catch (e) {
      debugPrint('❌ Error sincronizando alias: $e');
    }
  }

  // ============================================================
  // LOTES
  // ============================================================

  /// Sincroniza lotes pendientes hacia Supabase.
  Future<void> sincronizarLotesPendientes() async {
    try {
      final pendientes = await _isarService.obtenerLotesPendientesSync();
      if (pendientes.isEmpty) return;

      for (var lote in pendientes) {
        final productoIdFk = await _obtenerSupabaseIdProducto(lote.productoId);
        if (productoIdFk == null || productoIdFk.isEmpty) {
          debugPrint(
              '⚠️ Lote ${lote.id} omitido: producto ${lote.productoId} sin supabaseId');
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

  // ============================================================
  // TELEGRAM CONFIG
  // ============================================================

  /// Sincroniza configuraciones de Telegram pendientes hacia Supabase.
 // ==================== TELEGRAM CONFIG - SUBIR ====================

Future<void> sincronizarTelegramConfigPendientes() async {
  try {
    final pendientes = await _isarService.obtenerTelegramConfigsPendientesSync();
    if (pendientes.isEmpty) {
      debugPrint('ℹ️ No hay configuraciones de Telegram pendientes para sincronizar');
      return;
    }

    debugPrint('🔄 Sincronizando ${pendientes.length} configuraciones de Telegram con Supabase...');

    for (var config in pendientes) {
      // 🔥 Si el usuario ya tiene una configuración en Supabase, usar upsert por usuario_id
      final data = {
        'id_isar': config.id,
        'usuario_id': config.usuarioId,
        'bot_token': config.botToken ?? '',
        'chat_id': config.chatId ?? '',
        'nombre_chat': config.nombreChat ?? '',
        'enabled': config.enabled,
        'notificar_stock_bajo': config.notificarStockBajo,
        'notificar_ventas': config.notificarVentas,
        'notificar_pedidos': config.notificarPedidos,
        'comandos_permitidos': jsonEncode(config.comandosPermitidos),
        'sync_status': 'synced',
        'sincronizado': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        // 🔥 Usar upsert con onConflict: 'usuario_id'
        final response = await _supabase
            .from('telegram_config')
            .upsert(data, onConflict: 'usuario_id') // ✅ Cambiado de 'id_isar' a 'usuario_id'
            .select('id')
            .maybeSingle();

        final supabaseId = response?['id'] as String?;
        if (supabaseId != null) {
          config.supabaseId = supabaseId;
          config.sincronizado = true;
          config.fechaSincronizacion = DateTime.now();
          await _isarService.guardarTelegramConfig(config);
          debugPrint('✅ Configuración de Telegram (usuario ${config.usuarioId}) sincronizada con ID: $supabaseId');
        } else {
          debugPrint('⚠️ No se pudo obtener ID de Supabase para usuario ${config.usuarioId}');
        }
      } catch (e) {
        debugPrint('❌ Error al sincronizar configuración (usuario ${config.usuarioId}): $e');
      }
    }
  } catch (e) {
    debugPrint('❌ Error general en sincronizarTelegramConfigPendientes: $e');
  }
}

  /// Descarga todas las configuraciones de Telegram desde Supabase.
 // ==================== TELEGRAM CONFIG - DESCARGAR ====================

Future<void> descargarTelegramConfigDesdeSupabase() async {
  try {
    final response = await _supabase
        .from('telegram_config')
        .select()
        .order('id_isar', ascending: true);

    if (response.isEmpty) {
      debugPrint('ℹ️ No hay configuraciones de Telegram en Supabase para descargar');
      return;
    }

    debugPrint('🔄 Descargando ${response.length} configuraciones de Telegram desde Supabase...');

    // 🔥 Obtener configuraciones locales existentes por usuario
    final locales = await _isarService.obtenerTodasTelegramConfigs();
    final Map<int?, TelegramConfigEntity> localesPorUsuario = {
      for (var c in locales) c.usuarioId: c
    };

    for (var data in response) {
      final idIsar = data['id_isar'] as int?;
      final usuarioId = data['usuario_id'] as int?;
      
      if (idIsar == null || usuarioId == null) {
        debugPrint('⚠️ Configuración sin id_isar o usuario_id, omitiendo...');
        continue;
      }

      // 🔥 Buscar local por usuario (no por id_isar)
      TelegramConfigEntity? local = localesPorUsuario[usuarioId];

      final configNube = TelegramConfigEntity()
        ..id = idIsar
        ..usuarioId = usuarioId
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
        ..fechaSincronizacion = DateTime.now();

      if (local != null) {
        // 🔥 Actualizar el local existente (mantener el ID de Isar)
        configNube.id = local.id;
        await _isarService.guardarTelegramConfig(configNube);
        debugPrint('🔄 Configuración de Telegram actualizada (usuario $usuarioId)');
      } else {
        // 🔥 Crear nueva configuración en Isar
        await _isarService.guardarTelegramConfig(configNube);
        debugPrint('📥 Nueva configuración de Telegram creada (usuario $usuarioId)');
      }
    }

    // 🧹 Eliminar configuraciones locales que ya no existen en Supabase
    final supabaseIds = response.map((d) => d['id'] as String).toSet();
    final localesParaEliminar = locales.where((c) => 
      c.supabaseId != null && !supabaseIds.contains(c.supabaseId)
    ).toList();

    for (var c in localesParaEliminar) {
      await _isarService.eliminarTelegramConfig(c.id);
      debugPrint('🗑️ Configuración de Telegram eliminada localmente (usuario ${c.usuarioId})');
    }

    debugPrint('✅ Descarga de configuraciones de Telegram completada');
  } catch (e) {
    debugPrint('❌ Error descargando configuraciones de Telegram: $e');
  }
}
  // ============================================================
  // PEDIDOS
  // ============================================================

  /// Obtiene el ID entero del producto en Supabase (no UUID, sino el 'id' numérico).
  /// Si no existe, lo crea y retorna el ID.
  Future<int?> _obtenerOCrearProductoEnSupabase(int productoLocalId) async {
    final productoLocal =
        await _isarService.obtenerProductoPorId(productoLocalId);
    if (productoLocal == null) {
      debugPrint('⚠️ Producto local $productoLocalId no encontrado en Isar');
      return null;
    }

    if (productoLocal.supabaseId != null &&
        productoLocal.supabaseId!.isNotEmpty) {
      final idInt = int.tryParse(productoLocal.supabaseId!);
      if (idInt != null && idInt > 0) {
        final response = await _supabase
            .from('productos')
            .select('id')
            .eq('id', idInt)
            .maybeSingle();
        if (response != null) {
          return idInt;
        } else {
          productoLocal.supabaseId = null;
          await _isarService.guardarProducto(productoLocal);
        }
      }
    }

    if (productoLocal.codigoBarras.isNotEmpty) {
      final response = await _supabase
          .from('productos')
          .select('id')
          .eq('codigo_barras', productoLocal.codigoBarras)
          .maybeSingle();
      if (response != null) {
        final id = response['id'] as int?;
        if (id != null && id > 0) {
          productoLocal.supabaseId = id.toString();
          productoLocal.sincronizado = true;
          productoLocal.fechaSincronizacion = DateTime.now();
          await _isarService.guardarProducto(productoLocal);
          return id;
        }
      }
    }

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

      final response =
          await _supabase.from('productos').insert(data).select('id').single();
      final newId = response['id'] as int?;
      if (newId != null && newId > 0) {
        productoLocal.supabaseId = newId.toString();
        productoLocal.sincronizado = true;
        productoLocal.fechaSincronizacion = DateTime.now();
        await _isarService.guardarProducto(productoLocal);
        debugPrint(
            '✅ Producto "${productoLocal.nombre}" creado en Supabase con ID: $newId');
        return newId;
      }
    } catch (e) {
      debugPrint(
          '❌ Error creando producto ${productoLocal.nombre} en Supabase: $e');
    }
    return null;
  }

  /// Sincroniza pedidos pendientes hacia Supabase.
  Future<void> sincronizarPedidosPendientes() async {
    try {
      await _obtenerLocalActualUuid();

      final pedidosPendientes =
          await _isarService.obtenerPedidosPendientesSync();
      if (pedidosPendientes.isEmpty) return;

      for (var pedido in pedidosPendientes) {
        final String? localOrigenUuid =
            await _obtenerSupabaseIdLocal(pedido.localOrigenId);
        final String? localDestinoUuid =
            await _obtenerSupabaseIdLocal(pedido.localDestinoId);
        final String? usuarioUuid =
            await _obtenerSupabaseIdUsuario(pedido.usuarioId);

        if (localOrigenUuid == null ||
            localDestinoUuid == null ||
            usuarioUuid == null) {
          debugPrint(
              '⚠️ Pedido ${pedido.id} omitido: localOrigenUuid=$localOrigenUuid, localDestinoUuid=$localDestinoUuid, usuarioUuid=$usuarioUuid');
          continue;
        }

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

        final response = await _supabase
            .from('pedidos')
            .insert(pedidoData)
            .select()
            .single();
        final supabasePedidoId = response['id'] as String;

        final detalles = await _isarService.obtenerDetallesPorPedido(pedido.id);
        for (var detalle in detalles) {
          final int? supabaseProductoId =
              await _obtenerOCrearProductoEnSupabase(detalle.productoId);
          if (supabaseProductoId == null) {
            debugPrint(
                '⚠️ Detalle omitido: no se pudo obtener/crear producto ${detalle.productoId}');
            continue;
          }
          await _supabase.from('detalles_pedido').insert({
            'pedido_id': supabasePedidoId,
            'producto_id': supabaseProductoId,
            'nombre_producto': detalle.nombreProducto,
            'cantidad': detalle.cantidad,
            'precio_unidad': detalle.precioUnidad,
            'subtotal': detalle.subtotal,
          });
        }

        final recepcion =
            await _isarService.obtenerRecepcionPorPedido(pedido.id);
        if (recepcion != null) {
          await _supabase.from('recepciones').insert({
            'pedido_id': supabasePedidoId,
            'fecha_recepcion': recepcion.fechaRecepcion.toIso8601String(),
            'usuario_id': recepcion.usuarioId,
            'observaciones': recepcion.observaciones,
          });
          await _isarService.actualizarSyncStatusRecepcion(recepcion.id, true);
        }

        await _isarService.actualizarSyncStatusPedido(pedido.id, true);
      }
    } catch (e) {
      debugPrint('Error sincronizando pedidos: $e');
      rethrow;
    }
  }

  /// Descarga pedidos desde Supabase y los guarda localmente.
  Future<void> descargarPedidosDesdeSupabase() async {
    try {
      final String? localActualUuid = await _obtenerLocalActualUuid();
      if (localActualUuid == null || localActualUuid.isEmpty) {
        debugPrint(
            '⚠️ No se pudo obtener el UUID del local actual. No se descargarán pedidos.');
        return;
      }

      final response = await _supabase
          .from('pedidos')
          .select('*, detalles_pedido(*), recepciones(*)')
          .or('local_id.eq.$localActualUuid,local_destino_id.eq.$localActualUuid')
          .order('fecha_pedido', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay pedidos en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} pedidos desde Supabase...');

      final isar = await _isarService.db;
      for (var pedidoJson in response) {
        final existing = await isar.pedidoEntitys
            .filter()
            .supabaseIdEqualTo(pedidoJson['id'])
            .findFirst();
        if (existing != null) continue;

        final String? localOrigenUuid = pedidoJson['local_id']?.toString();
        final String? localDestinoUuid =
            pedidoJson['local_destino_id']?.toString();
        final String? usuarioUuid = pedidoJson['usuario_id']?.toString();

        if (localOrigenUuid == null ||
            localDestinoUuid == null ||
            usuarioUuid == null) {
          debugPrint(
              '⚠️ Pedido ${pedidoJson['id']} omitido por falta de mapeo de IDs');
          continue;
        }

        final int localOrigenId = await _obtenerIsarIdLocal(localOrigenUuid);
        final int localDestinoId = await _obtenerIsarIdLocal(localDestinoUuid);
        final int usuarioId = await _obtenerIsarIdUsuario(usuarioUuid);

        if (localOrigenId == 0 || localDestinoId == 0 || usuarioId == 0) {
          debugPrint(
              '⚠️ Pedido ${pedidoJson['id']} omitido: IDs locales no encontrados');
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
          final pedidoId = await isar.pedidoEntitys.put(pedido);

          for (var detalleJson in pedidoJson['detalles_pedido'] ?? []) {
            final int productoId =
                await _obtenerIsarIdProducto(detalleJson['producto_id']);
            final detalle = DetallePedidoEntity()
              ..supabaseId = detalleJson['id']
              ..pedidoId = pedidoId
              ..productoId = productoId
              ..nombreProducto = detalleJson['nombre_producto']
              ..cantidad = (detalleJson['cantidad'] as num).toDouble()
              ..precioUnidad = (detalleJson['precio_unidad'] as num).toDouble()
              ..subtotal = (detalleJson['subtotal'] as num).toDouble();
            await isar.detallePedidoEntitys.put(detalle);
          }

          final recepcionJson = pedidoJson['recepciones'];
          if (recepcionJson != null && recepcionJson.isNotEmpty) {
            final recepcionData = recepcionJson[0];
            final int usuarioRecepcionId =
                await _obtenerIsarIdUsuario(recepcionData['usuario_id']);
            final recepcion = RecepcionEntity()
              ..supabaseId = recepcionData['id']
              ..pedidoId = pedidoId
              ..fechaRecepcion =
                  DateTime.parse(recepcionData['fecha_recepcion'])
              ..usuarioId = usuarioRecepcionId
              ..observaciones = recepcionData['observaciones']
              ..sincronizado = true
              ..fechaSincronizacion = DateTime.now();
            await isar.recepcionEntitys.put(recepcion);
          }
        });
      }
      debugPrint(
          '✅ ${response.length} pedidos descargados y guardados correctamente.');
    } catch (e) {
      debugPrint('❌ Error descargando pedidos: $e');
      rethrow;
    }
  }

  // ============================================================
  // MÉTODOS AUXILIARES (UUID ↔ ID de Isar)
  // ============================================================

  /// Obtiene el UUID de un local por su ID de Isar. Si no existe, intenta crearlo/obtenerlo.
  Future<String?> _obtenerSupabaseIdLocal(int isarId) async {
    final isar = await _isarService.db;

    LocalEntity? local = await isar.localEntitys.get(isarId);
    if (local != null &&
        local.supabaseId != null &&
        local.supabaseId!.isNotEmpty) {
      return local.supabaseId;
    }

    if (local != null) {
      final localesConUuid =
          await isar.localEntitys.filter().supabaseIdIsNotNull().findAll();
      if (localesConUuid.isNotEmpty) {
        final localExistente = localesConUuid.first;
        if (local.supabaseId == null || local.supabaseId!.isEmpty) {
          local.supabaseId = localExistente.supabaseId;
          await isar.writeTxn(() async {
            await isar.localEntitys.put(local);
          });
          debugPrint(
              '🔄 Asignado UUID del local ${localExistente.id} al local ${local.id} (fallback)');
        }
        return localExistente.supabaseId;
      }
    }

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
            debugPrint(
                '✅ UUID del local $isarId obtenido de Supabase: $supabaseId');
          } else {
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
      debugPrint(
          '⚠️ Error obteniendo UUID del local $isarId desde Supabase: $e');
    }
    return await _obtenerLocalActualUuid();
  }

  Future<String?> _obtenerSupabaseIdUsuario(int isarId) async {
    final usuario = await _isarService.obtenerUsuarioPorId(isarId);
    return usuario?.supabaseId;
  }

  Future<String?> _obtenerSupabaseIdProducto(int isarId) async {
    final producto = await _isarService.obtenerProductoPorId(isarId);
    return producto?.supabaseId;
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
    final producto =
        await _isarService.obtenerProductoPorSupabaseId(supabaseId);
    return producto?.id ?? 0;
  }

  /// Obtiene el UUID del local principal (ID 1). Lo crea si no existe.
  Future<String?> _obtenerLocalActualUuid() async {
    final isar = await _isarService.db;

    LocalEntity? localIsar = await isar.localEntitys.get(1);
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

    if (localIsar.supabaseId != null && localIsar.supabaseId!.isNotEmpty) {
      return localIsar.supabaseId;
    }

    try {
      final data = await _supabase
          .from('locales')
          .select('id')
          .eq('id_isar', 1)
          .maybeSingle();
      String uuid;
      if (data != null) {
        uuid = data['id'] as String;
        debugPrint(
            '✅ Local encontrado en Supabase con id_isar = 1. UUID: $uuid');
      } else {
        final newData = await _supabase
            .from('locales')
            .insert({'id_isar': 1, 'nombre': 'Local Principal'})
            .select()
            .single();
        uuid = newData['id'] as String;
        debugPrint('✅ Local creado en Supabase con id_isar = 1. UUID: $uuid');
      }

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
  // REPARACIÓN DE IMÁGENES
  // ============================================================

  /// Busca imágenes en Storage y las asigna a productos que no tienen imagenUrl.
  Future<int> repararImagenesFaltantes() async {
    debugPrint('🔍 [SyncService] Iniciando reparación de imágenes...');
    final productos = await _isarService.obtenerProductos();
    final supabase = Supabase.instance.client;
    int reparados = 0;

    final allFiles = await supabase.storage.from('productos').list();
    debugPrint('📁 [SyncService] Archivos en Storage: ${allFiles.length}');

    final Map<String, String> archivosPorCodigo = {};
    for (var file in allFiles) {
      final name = file.name;
      for (var p in productos) {
        if (name.startsWith(p.codigoBarras)) {
          archivosPorCodigo[p.codigoBarras] = name;
          break;
        }
      }
    }

    for (var p in productos) {
      if (p.imagenUrl != null && p.imagenUrl!.isNotEmpty) continue;

      final fileName = archivosPorCodigo[p.codigoBarras];
      if (fileName != null) {
        final publicUrl =
            supabase.storage.from('productos').getPublicUrl(fileName);
        p.imagenUrl = publicUrl;
        await _isarService.guardarProducto(p);
        reparados++;
        debugPrint('🖼️ Imagen reparada para ${p.nombre}');
      } else {
        debugPrint(
            '⚠️ No se encontró imagen para ${p.nombre} (código: ${p.codigoBarras})');
      }
    }

    if (reparados > 0) {
      debugPrint(
          '✅ $reparados imágenes reparadas, sincronizando con Supabase...');
      await sincronizarProductosASupabase();
    } else {
      debugPrint('ℹ️ No se encontraron imágenes faltantes.');
    }
    return reparados;
  }

  // ============================================================
  // SINCRONIZACIÓN COMPLETA
  // ============================================================

  /// Ejecuta una sincronización completa de todos los módulos (subida y descarga).
  Future<void> sincronizarTodo() async {
    // 1. Categorías
    await descargarCategoriasDesdeSupabase();
    await sincronizarCategorias();

    // 2. Marcas
    await descargarMarcasDesdeSupabase();
    await sincronizarMarcasPendientes();

    // 3. Productos
    await sincronizarProductosASupabase();
    await descargarProductosDesdeSupabase();

    // 4. Ventas
    await sincronizarVentasPendientes();
    await descargarVentasDesdeSupabase();

    // 5. Movimientos de inventario
    await sincronizarMovimientosInventario();

    // 6. Turnos
    await sincronizarTurnos();

    // 7. Usuarios
    await sincronizarUsuariosASupabase();
    await sincronizarUsuariosDesdeSupabase();

    // 8. Gastos
    await sincronizarGastosPendientes();
    await descargarGastosDesdeSupabase();

    // 9. Locales (UUID)
    await _obtenerLocalActualUuid();

    // 10. Pedidos
    await sincronizarPedidosPendientes();
    await descargarPedidosDesdeSupabase();

    // 11. Proveedores
    await sincronizarProveedoresPendientes();
    await descargarProveedoresDesdeSupabase();

    // 12. Alias y Lotes
    await sincronizarAliasPendientes();
    await sincronizarLotesPendientes();

    // 13. Locales y Departamentos
    await sincronizarLocalesPendientes();
    await descargarLocalesDesdeSupabase();
    await sincronizarDepartamentosPendientes();
    await descargarDepartamentosDesdeSupabase();

    // 14. Telegram
    await sincronizarTelegramConfigPendientes();
    await descargarTelegramConfigDesdeSupabase();

    debugPrint('✅ Sincronización completa finalizada.');
    onDataChanged?.call();
  }

  /// Ejecuta sincronización completa y devuelve un resumen con cantidades sincronizadas.
  Future<Map<String, int>> sincronizarTodoConResumen() async {
    int ventas = 0, productos = 0, proveedores = 0, gastos = 0;
    int pedidos = 0, lotes = 0, marcas = 0, locales = 0;
    int departamentos = 0, telegram = 0;

    try {
      // Categorías
      await descargarCategoriasDesdeSupabase();
      await sincronizarCategorias();

      // Marcas
      await descargarMarcasDesdeSupabase();
      final marcasPend = await _isarService.obtenerMarcasPendientesSync();
      if (marcasPend.isNotEmpty) {
        await sincronizarMarcasPendientes();
        marcas = marcasPend.length;
      }

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
      final proveedoresPend =
          await _isarService.obtenerProveedoresPendientesSync();
      if (proveedoresPend.isNotEmpty) {
        await sincronizarProveedoresPendientes();
        proveedores = proveedoresPend.length;
      }

      // Gastos
      final gastosPend = await _isarService.obtenerGastosPendientesSync();
      if (gastosPend.isNotEmpty) {
        await sincronizarGastosPendientes();
        await descargarGastosDesdeSupabase();
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

      // Locales
      final localesPend = await _isarService.obtenerLocalesPendientesSync();
      if (localesPend.isNotEmpty) {
        await sincronizarLocalesPendientes();
        locales = localesPend.length;
      }

      // Departamentos
      final deptosPend =
          await _isarService.obtenerDepartamentosPendientesSync();
      if (deptosPend.isNotEmpty) {
        await sincronizarDepartamentosPendientes();
        departamentos = deptosPend.length;
      }

      // Telegram
      final telegramPend =
          await _isarService.obtenerTelegramConfigsPendientesSync();
      if (telegramPend.isNotEmpty) {
        await sincronizarTelegramConfigPendientes();
        telegram = telegramPend.length;
      }

      // Descargas finales
      await descargarVentasDesdeSupabase();
      await descargarProductosDesdeSupabase();
      await descargarProveedoresDesdeSupabase();
      await descargarLocalesDesdeSupabase();
      await descargarDepartamentosDesdeSupabase();
      await descargarTelegramConfigDesdeSupabase();
      await descargarMarcasDesdeSupabase();
      await descargarCategoriasDesdeSupabase();

      return {
        'ventas': ventas,
        'productos': productos,
        'proveedores': proveedores,
        'gastos': gastos,
        'pedidos': pedidos,
        'lotes': lotes,
        'marcas': marcas,
        'locales': locales,
        'departamentos': departamentos,
        'telegram': telegram,
      };
    } catch (e) {
      debugPrint('❌ Error en sincronización completa con resumen: $e');
      rethrow;
    }
  }
}
