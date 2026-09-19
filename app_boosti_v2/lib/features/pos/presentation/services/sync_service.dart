import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import '../../data/Local/entities/lote_entity.dart';
// Entidades locales

import '../utils/pin_hasher.dart';
import '../utils/tenant_utils.dart';
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
import '../../data/Local/entities/telegram_config_entity.dart';
import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/movimiento_lote_entity.dart';
import '../../data/Local/entities/cliente_entity.dart';
import 'error_service.dart'; // ✅ NUEVO: Para monitoreo

/// Servicio central de sincronización entre la base de datos local (Isar) y Supabase.
class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  SupabaseClient? _supabaseClient;

  SupabaseClient get _supabase {
    if (_supabaseClient != null) return _supabaseClient!;
    try {
      _supabaseClient = Supabase.instance.client;
      return _supabaseClient!;
    } catch (e) {
      throw StateError(
        'Supabase no está inicializado. Llama a Supabase.initialize() '
        'antes de usar SyncService.',
      );
    }
  }

  String _syncServerUrl = 'https://your-sync-server.example';
  String _syncApiKey = '<REPLACE_WITH_SYNC_API_KEY>';

  bool _configLoaded = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  bool _syncEnCurso = false; // guard de sincronizarTodo

  /// Convierte valores que PostgREST serializa como String (bigint, numeric)
  /// a tipos nativos de Dart. Nunca lanza, siempre devuelve un valor válido.
  int _toInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  double _toDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // ============================================================
  // VERIFICACIÓN DE SESIÓN
  // ============================================================

  /// Verifica si hay una sesión activa de Supabase.
  ///
  /// Sin sesión, el JWT no tiene `tenant_id` y RLS rechazará
  /// cualquier operación de escritura con error 42501.
  ///
  /// Retorna `false` si:
  /// - Supabase no está inicializado.
  /// - No hay sesión activa.
  /// - El accessToken está vacío.
  bool _tieneSesionSupabase() {
    try {
      final session = _supabase.auth.currentSession;
      return session != null && session.accessToken.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // SUSCRIPCIONES REALTIME Y CALLBACK
  // ============================================================
  final List<RealtimeChannel> _channels = [];
  final VoidCallback? onDataChanged;

  SyncService({
    this.onDataChanged,
    SupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient;

  void iniciarSuscripcionesRealtime() {
    try {
      _suscribirATabla('productos', () => descargarProductosDesdeSupabase());
      _suscribirATabla('categorias', () => descargarCategoriasDesdeSupabase());
      _suscribirATabla('marcas', () => descargarMarcasDesdeSupabase());
      _suscribirATabla('locales', () => descargarLocalesDesdeSupabase());
      _suscribirATabla(
          'departamentos', () => descargarDepartamentosDesdeSupabase());
      _suscribirATabla('usuarios', () => sincronizarUsuariosDesdeSupabase());
      _suscribirATabla('gastos', () => descargarGastosDesdeSupabase());
      _suscribirATabla('clientes', () => descargarClientesDesdeSupabase());

      debugPrint('✅ Suscripciones Realtime iniciadas');
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'iniciarSuscripcionesRealtime_fallo');
    }
  }

  void _suscribirATabla(String tabla, Future<void> Function() onCambio) {
    Timer? debounce;
    try {
      final channel = _supabase
          .channel('realtime:$tabla')
          .onPostgresChanges(
            schema: 'public',
            table: tabla,
            event: PostgresChangeEvent.all,
            callback: (payload) {
              if (_isSyncing) return;
              // ✅ Debounce: evita ráfagas de cambios seguidos
              debounce?.cancel();
              debounce = Timer(const Duration(seconds: 5), () {
                if (_isSyncing) return;
                debugPrint('🔄 Cambio detectado en $tabla, actualizando...');
                onCambio();
              });
            },
          )
          .subscribe();
      _channels.add(channel);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: '_suscribirATabla_fallo',
          extras: {'tabla': tabla});
    }
  }

  void detenerSuscripcionesRealtime() {
    for (var channel in _channels) {
      try {
        channel.unsubscribe();
      } catch (e) {
        // Error silencioso al desconectar
      }
    }
    _channels.clear();
    debugPrint('⏹️ Suscripciones Realtime detenidas');
  }

  // ============================================================
  // CONFIGURACIÓN Y MONITOREO
  // ============================================================

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
    } catch (e, stack) {
      debugPrint('⚠️ SyncService: usando valores por defecto: $e');
      ErrorService.captureError(e, stack: stack, hint: '_loadConfig_fallo');
      _configLoaded = true;
    }
  }

  void iniciarMonitoreo() {
    _connectivitySubscription?.cancel();
    Timer? connectivityDebounce;
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.handleError((e) {
      debugPrint('⚠️ Error de conectividad: $e');
    }).listen((results) {
      final tieneConexion =
          results.any((result) => result != ConnectivityResult.none);
      if (tieneConexion && !_isSyncing) {
        // ✅ FIX Bug B: debounce 10s para evitar sync en ráfagas de conectividad
        connectivityDebounce?.cancel();
        connectivityDebounce = Timer(const Duration(seconds: 10), () {
          if (!_isSyncing) sincronizarTodo();
        });
      }
    });
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void dispose() {
    detenerMonitoreo();
    detenerSuscripcionesRealtime();
  }

  // ============================================================
  // USUARIOS
  // ============================================================

  Future<void> sincronizarUsuariosASupabase() async {
    // ✅ Sin sesión activa no hay tenant_id → RLS bloqueará
    if (!_tieneSesionSupabase()) {
      debugPrint(
          '⚠️ [SyncService] Sin sesión activa. sincronizarUsuariosASupabase omitido.');
      return;
    }

    try {
      final usuarios = await _isarService.obtenerUsuarios();
      if (usuarios.isEmpty) {
        debugPrint('ℹ️ No hay usuarios locales para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${usuarios.length} usuarios con Supabase...');
      int sincronizados = 0;
      int recuperados = 0;

      // ✅ Obtener el usuario actual para saltarlo (evita error 42501
      // cuando el usuario opera en un tenant distinto a su "home tenant")
      final currentUserId = _supabase.auth.currentUser?.id;

      for (var usuario in usuarios) {
        try {
          // ============================================================
          // CASO 1: Ya tiene supabaseId → actualizar
          // ============================================================
          if (usuario.supabaseId != null && usuario.supabaseId!.isNotEmpty) {
            final esUsuarioActual = usuario.supabaseId == currentUserId;

            final existing = await _supabase
                .from('usuarios')
                .select('id, pin')
                .eq('id', usuario.supabaseId!)
                .maybeSingle();

            // ═══════════════════════════════════════════════════════════
            // ✅ FIX: UUID fantasma → intentar recuperar por email
            //    Antes hacíamos `continue` y el usuario quedaba huérfano
            //    para siempre. Ahora intentamos rescatar por email y, si
            //    no existe en ningún lado, limpiamos el UUID local para
            //    que en el próximo ciclo entre al CASO 2 y se cree.
            // ═══════════════════════════════════════════════════════════
            if (existing == null) {
              debugPrint(
                  '⚠️ Usuario "${usuario.nombre}" tiene supabaseId fantasma (${usuario.supabaseId}). Recuperando...');

              // 1️⃣ Intentar recuperar UUID real por email
              if (usuario.email != null && usuario.email!.isNotEmpty) {
                try {
                  final byEmail = await _supabase
                      .from('usuarios')
                      .select('id, pin, nombre')
                      .eq('email', usuario.email!)
                      .maybeSingle();

                  if (byEmail != null) {
                    final realUuid = byEmail['id'] as String;
                    final nombreNube = byEmail['nombre'] as String? ?? '';

                    // ✅ Validar que el UUID no esté en uso por OTRO usuario local
                    final yaEnUso = await _isarService
                        .obtenerUsuarioPorSupabaseId(realUuid);
                    final colisionaConOtro =
                        yaEnUso != null && yaEnUso.id != usuario.id;

                    // ✅ Validar que el nombre coincida (case-insensitive)
                    final nombreCoincide = nombreNube.trim().toLowerCase() ==
                        usuario.nombre.trim().toLowerCase();

                    if (colisionaConOtro || !nombreCoincide) {
                      debugPrint(
                          '⚠️ COLISIÓN para "${usuario.nombre}": el email "${usuario.email}" '
                          'pertenece a otro usuario (nube: "$nombreNube", UUID: $realUuid). '
                          'Se omite la asignación.');
                      continue;
                    }

                    usuario.supabaseId = realUuid;
                    await _isarService.guardarUsuario(usuario);
                    debugPrint(
                        '✅ UUID real recuperado para "${usuario.nombre}": $realUuid');

                    try {
                      await _supabase.from('usuarios').update({
                        'estado': usuario.estado,
                        'device_id': usuario.deviceId ?? '',
                      }).eq('id', realUuid);
                    } catch (e) {
                      debugPrint('⚠️ No se pudo refrescar estado: $e');
                    }
                    recuperados++;
                    sincronizados++;
                    continue;
                  }
                } catch (e) {
                  debugPrint('⚠️ Error buscando por email: $e');
                }
              }

              // 2️⃣ No existe en ningún lado → limpiar UUID fantasma local
              debugPrint(
                  '🗑️ UUID fantasma eliminado localmente para "${usuario.nombre}". Se creará en el próximo sync.');
              usuario.supabaseId = null;
              await _isarService.guardarUsuario(usuario);
              continue;
            }

            // ── Resolver tenant ──
            String? tenantUuid;
            if (usuario.localId != null && usuario.localId! > 0) {
              tenantUuid = await _obtenerSupabaseIdLocal(usuario.localId!);
            }
            if (tenantUuid == null || tenantUuid.isEmpty) {
              final localActivo = await _isarService.obtenerLocalActivo();
              if (localActivo != null) {
                tenantUuid = localActivo.supabaseId;
                if (tenantUuid == null || tenantUuid.isEmpty) {
                  tenantUuid = await _obtenerSupabaseIdLocal(localActivo.id);
                }
                if (tenantUuid != null && tenantUuid.isNotEmpty) {
                  usuario.localId = localActivo.id;
                }
              }
            }

            if (tenantUuid == null || tenantUuid.isEmpty) {
              debugPrint(
                  '⚠️ Usuario "${usuario.nombre}" sin local asignado. No se puede sincronizar (tenant_id es NOT NULL).');
              continue;
            }

            // ── Preparar payload ──
            final Map<String, dynamic> payload = {
              'nombre': usuario.nombre,
              'rol': usuario.rol,
              'email': usuario.email ?? '',
              'device_id': usuario.deviceId ?? '',
              'estado': usuario.estado,
              'caja_asignada': usuario.cajaAsignada,
              'departamento': usuario.departamento,
              'tenant_id': tenantUuid,
              'updated_at': DateTime.now().toIso8601String(),
            };

            // ✅ Sincronizar PIN solo si difiere del que hay en Supabase.
            final pinLocal = usuario.pin;
            final pinNube = existing['pin'] as String?;
            if (pinLocal.isNotEmpty && pinLocal != pinNube) {
              payload['pin'] = pinLocal;
              debugPrint(
                  '📤 Actualizando PIN de "${usuario.nombre}" en Supabase');
            }

            // ── Skip del usuario actual ──
            if (esUsuarioActual) {
              debugPrint(
                  'ℹ️ Saltando campos bloqueados por RLS para el usuario actual "${usuario.nombre}"');

              try {
                await _supabase.from('usuarios').update({
                  'device_id': usuario.deviceId ?? '',
                  'estado': usuario.estado,
                }).eq('id', usuario.supabaseId!);
              } catch (e) {
                debugPrint(
                    '⚠️ No se pudo actualizar device_id del usuario actual: $e');
              }
              continue;
            }

            // ── Update normal ──
            await _supabase
                .from('usuarios')
                .update(payload)
                .eq('id', usuario.supabaseId!);

            usuario.sincronizado = true;
            usuario.fechaSincronizacion = DateTime.now();
            await _isarService.guardarUsuario(usuario);

            debugPrint(
                '✅ Usuario "${usuario.nombre}" actualizado en public.usuarios');
            sincronizados++;
            continue;
          }

          // ============================================================
          // CASO 2: No tiene supabaseId → recuperar o crear
          // ============================================================

          if (usuario.email == null || usuario.email!.isEmpty) {
            debugPrint(
                '⚠️ Usuario "${usuario.nombre}" sin email. No se sincroniza.');
            continue;
          }

          final existingByEmail = await _supabase
              .from('usuarios')
              .select('id')
              .eq('email', usuario.email!)
              .maybeSingle();

          if (existingByEmail != null) {
            final recoveredUuid = existingByEmail['id'] as String;
            usuario.supabaseId = recoveredUuid;
            await _isarService.guardarUsuario(usuario);
            debugPrint(
                '✅ UUID recuperado para "${usuario.nombre}" desde public.usuarios: $recoveredUuid');
            recuperados++;
            sincronizados++;
            continue;
          }

          // ═══════════════════════════════════════════════════════════
          // ✅ FIX: Usuario sin password → no se puede crear en auth,
          //    pero lo marcamos claramente para que el usuario sepa que
          //    debe asignarle una contraseña desde el formulario.
          // ═══════════════════════════════════════════════════════════
          if (usuario.password == null || usuario.password!.isEmpty) {
            debugPrint('⚠️ Usuario "${usuario.nombre}" sin password. '
                'Omitido. Debe asignársele una contraseña desde el formulario de usuarios '
                'para poder sincronizarlo con auth.users.');
            continue;
          }

          try {
            final tenantId = usuario.tenantId ?? getTenantIdFromJWT();
            if (tenantId == null) {
              debugPrint(
                  '⚠️ Usuario "${usuario.nombre}" sin tenant_id. Saltando signUp.');
              continue;
            }

            final response = await _supabase.auth.signUp(
              email: usuario.email!,
              password: usuario.password!,
              data: {
                'nombre': usuario.nombre,
                'rol': usuario.rol,
                'pin': usuario.pin,
                'tenant_id': tenantId,
              },
            );
            if (response.user != null) {
              usuario.supabaseId = response.user!.id;
              await _isarService.guardarUsuario(usuario);
              debugPrint(
                  '✅ Usuario "${usuario.nombre}" creado en auth.users (ID: ${usuario.supabaseId})');
              sincronizados++;
            } else {
              debugPrint(
                  '⚠️ Usuario "${usuario.nombre}" no se pudo crear en auth (response.user = null)');
            }
          } on AuthApiException catch (e) {
            final esUserAlreadyExists = e.code == 'user_already_exists' ||
                e.statusCode == '422' ||
                e.message.toLowerCase().contains('already registered');

            if (esUserAlreadyExists) {
              debugPrint(
                  '⚠️ Usuario "${usuario.nombre}" ya existe en auth. Recuperando UUID...');

              await Future.delayed(const Duration(milliseconds: 500));

              final retryLookup = await _supabase
                  .from('usuarios')
                  .select('id')
                  .eq('email', usuario.email!)
                  .maybeSingle();

              if (retryLookup != null) {
                final recoveredUuid = retryLookup['id'] as String;
                usuario.supabaseId = recoveredUuid;
                await _isarService.guardarUsuario(usuario);
                debugPrint(
                    '✅ UUID recuperado tras 422 para "${usuario.nombre}": $recoveredUuid');
                recuperados++;
                sincronizados++;
              } else {
                debugPrint(
                    '❌ Usuario "${usuario.nombre}" existe en auth pero no en public.usuarios. '
                    'Requiere intervención manual (revisar trigger on_auth_user_created).');
              }
            } else {
              debugPrint(
                  '❌ Error auth para "${usuario.nombre}": ${e.message} (code: ${e.code})');
            }
          } catch (e) {
            debugPrint('❌ Error inesperado creando "${usuario.nombre}": $e');
          }
        } catch (e, stack) {
          debugPrint('⚠️ Error procesando usuario "${usuario.nombre}": $e');
          ErrorService.captureError(e,
              stack: stack, hint: 'sincronizarUsuario_individual_fallo');
        }
      }

      debugPrint(
          '✅ $sincronizados usuarios sincronizados ($recuperados UUIDs recuperados)');
      onDataChanged?.call();
    } catch (e, stack) {
      debugPrint('❌ Error general sincronizando usuarios: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarUsuariosASupabase_fallo');
    }
  }

  Future<int> limpiarUsuariosHuerfanosEnSupabase() async {
    try {
      // Buscar usuarios con id_isar null o 0
      final huerfanos = await _supabase
          .from('usuarios')
          .select('id, nombre, email')
          .or('id_isar.is.null,id_isar.eq.0');

      if (huerfanos.isEmpty) {
        debugPrint('✅ No hay usuarios huérfanos en Supabase');
        return 0;
      }

      debugPrint(
          '🧹 Encontrados ${huerfanos.length} usuarios huérfanos en Supabase:');

      int eliminados = 0;
      for (var huerfano in huerfanos) {
        final uuid = huerfano['id'] as String?;
        final nombre = huerfano['nombre'] ?? 'sin nombre';
        if (uuid == null) continue;

        try {
          await _supabase.from('usuarios').delete().eq('id', uuid);
          eliminados++;
          debugPrint('🗑️ Huérfano eliminado: "$nombre" (id: $uuid)');
        } catch (e) {
          debugPrint('⚠️ No se pudo eliminar huérfano "$nombre": $e');
        }
      }

      debugPrint('✅ $eliminados usuarios huérfanos limpiados');
      return eliminados;
    } catch (e, stack) {
      debugPrint('❌ Error limpiando huérfanos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'limpiarUsuariosHuerfanosEnSupabase_fallo');
      return 0;
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

      debugPrint(
          '🔄 Descargando ${response.length} usuarios desde Supabase...');

      final locales = await _isarService.obtenerUsuarios();
      final Map<int, UsuarioEntity> localesMap = {
        for (var u in locales) u.id: u,
      };

      for (var data in response) {
        final idIsar = _toInt(data['id_isar']);
        if (idIsar == 0) {
          debugPrint('⚠️ Usuario sin id_isar, omitiendo: ${data['nombre']}');
          continue;
        }

        // ✅ Convertir tenant_id (UUID) → localId (Isar int) una sola vez
        final String? tenantUuid = data['tenant_id'] as String?;
        int? localIdResuelto;
        if (tenantUuid != null && tenantUuid.isNotEmpty) {
          localIdResuelto = await _obtenerIsarIdLocal(tenantUuid);
        }

        final local = localesMap[idIsar];

        if (local != null) {
          // ============================================================
          // USUARIO EXISTENTE → actualizar campos
          // ============================================================
          local.supabaseId = data['id'] as String?;
          local.email = data['email'] as String? ?? local.email;
          local.deviceId = data['device_id'] as String? ?? local.deviceId;
          local.cajaAsignada =
              data['caja_asignada'] as String? ?? local.cajaAsignada;
          local.departamento =
              data['departamento'] as String? ?? local.departamento;
          // ✅ Después: solo sobreescribe el PIN si el que viene de la nube NO es null
          // y NO es igual al local. Esto evita perder el hash local si Supabase
          // tiene un pin plano legacy (que no debería usarse).
          final pinNube = data['pin'] as String?;
          if (pinNube != null && pinNube.isNotEmpty && pinNube != local.pin) {
            // Si el pin de la nube está hasheado (sha256:...) → es la fuente de
            // verdad, lo tomamos.
            // Si el pin de la nube es plano → también lo tomamos, pero al
            // guardarlo localmente se va a hashear de nuevo.
            local.pin = pinNube;
          }
          local.rol = data['rol'] as String? ?? local.rol;

          // ✅ tenantId directo (UUID)
          if (tenantUuid != null && tenantUuid.isNotEmpty) {
            local.tenantId = tenantUuid;
          }
          // ✅ localId resuelto (int)
          if (localIdResuelto != null) {
            local.localId = localIdResuelto;
          }

          // ✅ Campos nuevos
          local.inicioDescanso = data['inicio_descanso'] != null
              ? DateTime.tryParse(data['inicio_descanso'].toString())
              : local.inicioDescanso;
          local.minutosDescanso =
              _toInt(data['minutos_descanso'], local.minutosDescanso ?? 0);
          local.ultimaActividad = data['ultima_actividad'] != null
              ? DateTime.tryParse(data['ultima_actividad'].toString())
              : local.ultimaActividad;
          local.ultimaActualizacion = data['ultimaActualizacion'] != null
              ? DateTime.tryParse(data['ultimaActualizacion'].toString())
              : local.ultimaActualizacion;

          // ✅ Estado: no forzar 'inactivo' si viene estado desde nube
          final estadoNube = data['estado'] as String?;
          if (estadoNube != null && estadoNube.isNotEmpty) {
            local.estado = estadoNube;
            local.activo =
                estadoNube != 'inactivo' && estadoNube != 'desconectado';
          }

          // ✅ created/updated
          final creadoRaw = data['creado_en'] ?? data['created_at'];
          if (creadoRaw != null) {
            local.createdAt = DateTime.tryParse(creadoRaw.toString());
          }
          if (data['updated_at'] != null) {
            local.updatedAt = DateTime.tryParse(data['updated_at'].toString());
          }

          local.sincronizado = true;
          local.fechaSincronizacion = DateTime.now();

          await _isarService.guardarUsuario(local);
        } else {
          // ============================================================
          // USUARIO NUEVO → crear desde Supabase
          // ============================================================
          final nuevoUsuario = UsuarioEntity()
            ..id = idIsar
            ..nombre = data['nombre'] as String? ?? ''
            ..pin = data['pin'] as String? ?? ''
            ..rol = data['rol'] as String? ?? 'cajero'
            ..activo = true
            ..estado = data['estado'] as String? ?? 'inactivo'
            ..cajaAsignada =
                data['caja_asignada'] as String? ?? 'Caja Principal'
            ..email = data['email'] as String?
            ..deviceId = data['device_id'] as String? ?? ''
            ..departamento = data['departamento'] as String?
            ..supabaseId = data['id'] as String?
            ..tenantId = tenantUuid
            ..localId = localIdResuelto
            ..inicioDescanso = data['inicio_descanso'] != null
                ? DateTime.tryParse(data['inicio_descanso'].toString())
                : null
            ..minutosDescanso = data['minutos_descanso'] == null
                ? null
                : _toInt(data['minutos_descanso'])
            ..ultimaActividad = data['ultima_actividad'] != null
                ? DateTime.tryParse(data['ultima_actividad'].toString())
                : null
            ..ultimaActualizacion = data['ultimaActualizacion'] != null
                ? DateTime.tryParse(data['ultimaActualizacion'].toString())
                : null
            ..createdAt = (data['creado_en'] ?? data['created_at']) != null
                ? DateTime.tryParse(
                    (data['creado_en'] ?? data['created_at']).toString())
                : null
            ..updatedAt = data['updated_at'] != null
                ? DateTime.tryParse(data['updated_at'].toString())
                : null
            ..sincronizado = true
            ..fechaSincronizacion = DateTime.now();

          await _isarService.guardarUsuario(nuevoUsuario);
        }
      }

      debugPrint('✅ Usuarios sincronizados desde Supabase');
      onDataChanged?.call();
    } catch (e, stack) {
      debugPrint('❌ Error descargando usuarios: $e');
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'sincronizarUsuariosDesdeSupabase_fallo',
      );
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
    } catch (e, stack) {
      debugPrint('❌ Error obteniendo usuarios desde Supabase: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerUsuariosDesdeSupabase_fallo');
      return [];
    }
  }

  Future<bool> actualizarEstadoUsuarioEnSupabase(
      int userId, String nuevoEstado) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .update({'estado': nuevoEstado})
          .eq('id_isar', userId)
          .select();
      return response.isNotEmpty;
    } catch (e, stack) {
      debugPrint('❌ Error actualizando estado usuario: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarEstadoUsuarioEnSupabase_fallo',
          extras: {'userId': userId, 'nuevoEstado': nuevoEstado});
      return false;
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
    } catch (e, stack) {
      debugPrint('❌ Error eliminando usuario en Supabase: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarUsuarioEnSupabase_fallo',
          extras: {'userId': userId});
      return false;
    }
  }

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
    } catch (e, stack) {
      debugPrint('❌ Error general en sincronizarProveedoresPendientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarProveedoresPendientes_fallo');
      rethrow;
    }
  }

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

        final idIsar = _toInt(data['id_isar']);
        ProveedorEntity? local = localesPorSupabaseId[supabaseId];
        if (local == null && idIsar > 0) {
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
    } catch (e, stack) {
      debugPrint('❌ Error descargando proveedores: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarProveedoresDesdeSupabase_fallo');
      rethrow;
    }
  }

  Future<bool> eliminarProveedorEnSupabase(String supabaseId) async {
    try {
      final response = await _supabase
          .from('proveedores')
          .delete()
          .eq('id', supabaseId)
          .select();
      return response.isNotEmpty;
    } catch (e, stack) {
      debugPrint('❌ Error eliminando proveedor en Supabase: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarProveedorEnSupabase_fallo',
          extras: {'supabaseId': supabaseId});
      return false;
    }
  }

  // ============================================================
  // PRODUCTOS
  // ============================================================

  double _limpiarNumero(double? valor, [double valorPorDefecto = 0.0]) {
    if (valor == null || valor.isNaN || valor.isInfinite) {
      return valorPorDefecto;
    }
    return valor;
  }

  Future<bool> sincronizarProductosASupabase() async {
    // ✅ Sin sesión activa no hay tenant_id → RLS bloqueará
    if (!_tieneSesionSupabase()) {
      debugPrint(
          '⚠️ [SyncService] Sin sesión activa. sincronizarProductosASupabase omitido.');
      return false;
    }

    try {
      final productosLocales = await _isarService.obtenerProductos();
      if (productosLocales.isEmpty) return true;

      int insertados = 0;
      int actualizados = 0;

      for (final p in productosLocales) {
        final existente = await _supabase
            .from('productos')
            .select('uuid')
            .eq('codigo_barras', p.codigoBarras)
            .maybeSingle();

        if (existente != null) {
          final payloadUpdate = <String, dynamic>{
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
            'proveedor_id': p.proveedorSupabaseId,
            'version': p.version,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': p.updatedBy,
            'updated_by_name': p.updatedByName ?? '',
            'permite_venta_mayor': p.permiteVentaMayor,
            'precio_mayor': p.precioMayor,
            'cantidad_minima_mayor': p.cantidadMinimaMayor,
            'precio_medio_mayor': p.precioMedioMayor,
            'cantidad_minima_medio_mayor': p.cantidadMinimaMedioMayor,
            'unidades_por_bulto': p.unidadesPorBulto,
            'costo_unitario_promedio': p.costoUnitarioPromedio,
          };
          if (p.imagenUrl != null && p.imagenUrl!.isNotEmpty) {
            payloadUpdate['imagen_url'] = p.imagenUrl;
          }
          try {
            final uuid = existente['uuid'] as String;
            await _supabase
                .from('productos')
                .update(payloadUpdate)
                .eq('uuid', uuid);
            p.supabaseId = uuid;
            p.sincronizado = true;
            p.fechaSincronizacion = DateTime.now();
            await _isarService.guardarProducto(p);
            actualizados++;
          } catch (e) {
            debugPrint('⚠️ Error actualizando producto ${p.nombre}: $e');
          }
          continue;
        }

        final nuevoUuid = const Uuid().v4();
        final payloadInsert = <String, dynamic>{
          'uuid': nuevoUuid,
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
          'proveedor_id': p.proveedorSupabaseId,
          'version': p.version,
          'created_at': p.createdAt?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'created_by': p.createdBy,
          'updated_by': p.updatedBy,
          'created_by_name': p.createdByName ?? '',
          'updated_by_name': p.updatedByName ?? '',
          'permite_venta_mayor': p.permiteVentaMayor,
          'precio_mayor': p.precioMayor,
          'cantidad_minima_mayor': p.cantidadMinimaMayor,
          'precio_medio_mayor': p.precioMedioMayor,
          'cantidad_minima_medio_mayor': p.cantidadMinimaMedioMayor,
          'unidades_por_bulto': p.unidadesPorBulto,
          'costo_unitario_promedio': p.costoUnitarioPromedio,
        };
        if (p.imagenUrl != null && p.imagenUrl!.isNotEmpty) {
          payloadInsert['imagen_url'] = p.imagenUrl;
        }

        try {
          await _supabase.from('productos').insert(payloadInsert);
          p.supabaseId = nuevoUuid;
          p.sincronizado = true;
          p.fechaSincronizacion = DateTime.now();
          await _isarService.guardarProducto(p);
          insertados++;
        } catch (e) {
          final esColisionIsar =
              e.toString().contains('productos_id_isar_unique');
          if (esColisionIsar) {
            debugPrint(
                '⚠️ Colisión id_isar=${p.id} para "${p.nombre}", reasignando...');
            final maxRow = await _supabase
                .from('productos')
                .select('id_isar')
                .order('id_isar', ascending: false)
                .limit(1)
                .maybeSingle();
            final newIdIsar = _toInt(maxRow?['id_isar']) + 1;
            payloadInsert['id_isar'] = newIdIsar;

            try {
              await _supabase.from('productos').insert(payloadInsert);
              p.supabaseId = nuevoUuid;
              p.sincronizado = true;
              p.fechaSincronizacion = DateTime.now();
              await _isarService.guardarProducto(p);
              insertados++;
              debugPrint(
                  '✅ "${p.nombre}" subido con id_isar reasignado: $newIdIsar');
            } catch (e2) {
              debugPrint(
                  '❌ Error insertando "${p.nombre}" tras reasignar: $e2');
            }
          } else {
            debugPrint('⚠️ Error insertando producto ${p.nombre}: $e');
          }
        }
      }

      debugPrint(
          '✅ Productos: $insertados insertados, $actualizados actualizados');
      return true;
    } catch (e, stack) {
      debugPrint('🚫 Error sincronizando productos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarProductosASupabase_fallo');
      return false;
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
          ..precioUnidad = _toDouble(data['precio_unidad'])
          ..stock = _toDouble(data['stock'])
          ..stockMinimo = _toDouble(data['stock_minimo'], 5.0)
          ..esPesado = data['es_pesado'] ?? false
          ..activo = data['activo'] ?? true
          ..categoria = data['categoria'] ?? ''
          ..proveedorNombre = data['proveedor_nombre'] ?? ''
          ..proveedorTelefono = data['proveedor_telefono'] ?? ''
          ..proveedorEmail = data['proveedor_email'] ?? ''
          ..proveedorDireccion = data['proveedor_direccion'] ?? ''
          ..proveedorSupabaseId = data['proveedor_id'] as String?
          ..version = data['version'] ?? 0
          ..createdAt = data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null
          ..updatedAt = data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null
          ..createdBy =
              data['created_by'] == null ? null : _toInt(data['created_by'])
          ..updatedBy =
              data['updated_by'] == null ? null : _toInt(data['updated_by'])
          ..createdByName = data['created_by_name'] ?? ''
          ..updatedByName = data['updated_by_name'] ?? ''
          ..imagenUrl = imagenUrlFinal.isEmpty ? null : imagenUrlFinal
          ..supabaseId = data['uuid']?.toString()
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now()
          // ✅ NUEVO: Ventas al mayor
          ..permiteVentaMayor = data['permite_venta_mayor'] as bool? ?? false
          ..precioMayor = data['precio_mayor'] == null
              ? null
              : _toDouble(data['precio_mayor'])
          ..cantidadMinimaMayor = data['cantidad_minima_mayor'] == null
              ? null
              : _toInt(data['cantidad_minima_mayor'])
          ..precioMedioMayor = data['precio_medio_mayor'] == null
              ? null
              : _toDouble(data['precio_medio_mayor'])
          ..cantidadMinimaMedioMayor =
              data['cantidad_minima_medio_mayor'] == null
                  ? null
                  : _toInt(data['cantidad_minima_medio_mayor'])
          ..unidadesPorBulto = _toInt(data['unidades_por_bulto'], 1)
          ..costoUnitarioPromedio = data['costo_unitario_promedio'] == null
              ? null
              : _toDouble(data['costo_unitario_promedio']);

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
    } catch (e, stack) {
      debugPrint('❌ Error descargando productos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarProductosDesdeSupabase_fallo');
      rethrow;
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
          .select('uuid')
          .eq('codigo_barras', codigoLimpio)
          .maybeSingle();

      if (existing == null) {
        debugPrint(
            'ℹ️ Producto con código exacto "$codigoLimpio" no encontrado, intentando búsqueda flexible...');
        final resultados = await _supabase
            .from('productos')
            .select('uuid')
            .ilike('codigo_barras', codigoLimpio)
            .limit(1);
        if (resultados.isNotEmpty) {
          existing = resultados.first;
          debugPrint(
              '🔍 Producto encontrado con búsqueda flexible: ${existing['uuid']}');
        }
      }

      if (existing == null) {
        debugPrint(
            'ℹ️ Producto con código "$codigoLimpio" no existe en Supabase.');
        return false;
      }

      final response = await _supabase
          .from('productos')
          .delete()
          .eq('uuid', existing['uuid']);
      final int affected = response != null ? response.length : 0;
      debugPrint('📦 Filas afectadas en Supabase: $affected');

      if (affected > 0) {
        debugPrint(
            '✅ Producto eliminado de Supabase (uuid: ${existing['uuid']})');
        return true;
      } else {
        debugPrint('⚠️ No se eliminó ninguna fila (código: $codigoLimpio)');
        return false;
      }
    } catch (e, stack) {
      debugPrint('❌ Error eliminando producto de Supabase: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarProductoEnSupabase_fallo',
          extras: {'codigoBarras': codigoBarras});
      rethrow;
    }
  }

  // ============================================================
  // VENTAS
  // ============================================================

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
        try {
          final exito = await _enviarVentaAlServidor(venta);
          if (exito) {
            await _isarService.actualizarSyncStatusVenta(venta.id, 'synced');
            ventasSincronizadas++;
          } else {
            await _isarService.actualizarSyncStatusVenta(venta.id, 'failed');
            debugPrint('⚠️ Venta ${venta.idSupabase} marcada como failed');
          }
        } catch (e, stack) {
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarVenta_individual_fallo',
              extras: {
                'ventaId': venta.id,
                'ventaSupabaseId': venta.idSupabase
              });
          await _isarService.actualizarSyncStatusVenta(venta.id, 'failed');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ [SyncService] Error general durante la sincronización: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarVentasPendientes_fallo');
    } finally {
      _isSyncing = false;
    }
    return ventasSincronizadas;
  }

  Future<bool> _enviarVentaAlServidor(VentaEntity venta) async {
    await _loadConfig();

    try {
      // 🔥 Asegurar que la venta tenga un UUID válido antes de sincronizar
      if (venta.idSupabase == null || venta.idSupabase!.isEmpty) {
        venta.idSupabase = const Uuid().v4();
        await _isarService.guardarVenta(venta);
        debugPrint('🔄 UUID generado para venta local: ${venta.idSupabase}');
      }

      final payload = _ventaToJson(venta);
      payload['sync_status'] = 'synced';

      // 🔥 Obtener los detalles de la venta desde la base de datos usando el UUID
      final detalles =
          await _isarService.obtenerDetallesPorVenta(venta.idSupabase!);
      debugPrint(
          '📦 Detalles encontrados para venta ${venta.idSupabase}: ${detalles.length}');

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
                '✅ Venta ${venta.idSupabase} sincronizada vía microservicio');
            return true;
          }
        } catch (e) {
          debugPrint(
              '⚠️ Microservicio falló, intentando con Supabase directo: $e');
        }
      } else {
        debugPrint('ℹ️ No hay configuración válida; se usa Supabase directo.');
      }

      // 🔥 Insertar venta en Supabase
      await _supabase.from('ventas').insert(payload);

      // 🔥 Insertar detalles con el UUID de la venta
      if (detalles.isNotEmpty) {
        final List<Map<String, dynamic>> itemsPayload = detalles.map((item) {
          // Asegurar que cada detalle tenga el ventaIdFk correcto (local)
          if (item.ventaIdFk == null || item.ventaIdFk!.isEmpty) {
            item.ventaIdFk = venta.idSupabase;
          }
          return _detalleToJson(item);
        }).toList();
        await _supabase.from('detalle_ventas').insert(itemsPayload);
        debugPrint(
            '✅ ${itemsPayload.length} detalles insertados para venta ${venta.idSupabase}');
      } else {
        debugPrint('⚠️ No hay detalles para la venta ${venta.idSupabase}');
      }

      debugPrint(
          '✅ Venta ${venta.idSupabase} sincronizada vía Supabase directo');
      return true;
    } catch (e, stack) {
      debugPrint(
          '🚫 [Supabase] Error al insertar venta ${venta.idSupabase}: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: '_enviarVentaAlServidor_fallo',
          extras: {'ventaId': venta.id, 'ventaSupabaseId': venta.idSupabase});
      return false;
    }
  }

  Map<String, dynamic> _ventaToJson(VentaEntity venta) {
    return {
      'id': venta.idSupabase,
      'fecha': venta.fecha?.toIso8601String(),
      'subtotal': venta.subtotal,
      'impuesto': venta.impuesto,
      'total': venta.total,
      'tasa_bcv': venta.tasaBcv,
      'total_bolivares': venta.totalBolivares,
      'metodo_pago': venta.metodoPago,
      'documento': venta.documento,
      'empleado_nombre': venta.empleado,
      'sync_status': venta.syncStatus,
      'tiene_descuento_especial': venta.tieneDescuentoEspecial,
      'monto_descuento_total': venta.montoDescuentoTotal,

      // ── Cliente snapshot ──
      'cliente_nombre': venta.clienteNombre,
      'cliente_documento': venta.clienteDocumento,

      // ✅ NUEVO: contexto Venta al Mayor
      'tipo_venta': venta.tipoVenta,
      'tipo_documento': venta.tipoDocumento,
      'monto_descuento_porcentaje': venta.montoDescuentoPorcentaje,
      'es_multipago': venta.esMultipago,
      'cliente_rif': venta.clienteRif,
      'cliente_razon_social': venta.clienteRazonSocial,
      'requiere_autorizacion': venta.requiereAutorizacion,
      'autorizado_por_nombre': venta.autorizadoPorNombre,
      'autorizado_por_rol': venta.autorizadoPorRol,
      'fecha_autorizacion': venta.fechaAutorizacion?.toIso8601String(),
    };
  }

  /// Convierte un detalle de venta local al formato esperado por Supabase.
  /// AHORA usa 'venta_id_tk' (renombrado) y 'producto_id'.
  Map<String, dynamic> _detalleToJson(DetalleVentaEntity detalle) {
    return {
      'venta_id_tk': detalle.ventaIdFk,
      'producto_id': detalle.productoId,
      'nombre_producto': detalle.nombreProducto,
      'precio_unidad': detalle.precioUnidad,
      'cantidad': detalle.cantidad,
      'subtotal': detalle.subtotal,
      'precio_original': detalle.precioOriginal,
      'es_descuento_especial': detalle.esDescuentoEspecial,

      // ✅ NUEVO: contexto Venta al Mayor
      'tipo_precio': detalle.tipoPrecio,
      'precio_detal_original': detalle.precioDetalOriginal,
      'precio_mayor_aplicado': detalle.precioMayorAplicado,
      'descuento_porcentaje_linea': detalle.descuentoPorcentajeLinea,
      'unidad_empaque': detalle.unidadEmpaque,
      'unidades_por_empaque': detalle.unidadesPorEmpaque,
      'autorizado_por_linea': detalle.autorizadoPorLinea,
      'costo_unitario_snapshot': detalle.costoUnitarioSnapshot,
      'lote_id_isar': detalle.loteIdIsar,
      'sync_status': 'synced', // ✅ NUEVO
    };
  }

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
        final String ventaIdString = data['id'] as String? ?? '';
        if (ventaIdString.isEmpty) continue;

        // 🔥 Consulta con 'venta_id_tk' (columna renombrada)
        final detallesResponse = await _supabase
            .from('detalle_ventas')
            .select()
            .eq('venta_id_tk', ventaIdString);

        // 🔥 Leer los campos de descuento desde Supabase
        final detalles = detallesResponse.map<DetalleVentaEntity>((d) {
          final detalle = DetalleVentaEntity()
            ..ventaIdFk = ventaIdString
            ..productoId = _toInt(d['producto_id']) // 🔥 Leer producto_id
            ..nombreProducto = d['nombre_producto'] ?? ''
            ..precioUnidad = _toDouble(d['precio_unidad'])
            ..cantidad = _toDouble(d['cantidad'])
            ..subtotal = _toDouble(d['subtotal'])
            ..precioOriginal = d['precio_original'] == null
                ? null
                : _toDouble(d['precio_original'])
            ..esDescuentoEspecial = d['es_descuento_especial'] ?? false;
          return detalle;
        }).toList();

        final existing =
            await _isarService.obtenerVentaPorIdString(ventaIdString);
        final venta = VentaEntity()
          ..idSupabase = ventaIdString
          ..fecha = DateTime.parse(data['fecha']).toLocal()
          ..subtotal = _toDouble(data['subtotal'])
          ..impuesto = _toDouble(data['impuesto'])
          ..total = _toDouble(data['total'])
          ..tasaBcv = _toDouble(data['tasa_bcv'])
          ..totalBolivares = _toDouble(data['total_bolivares'])
          ..metodoPago = data['metodo_pago'] ?? ''
          ..documento = _toInt(data['documento'])
          ..empleado = data['empleado_nombre'] ?? data['empleado'] ?? ''
          ..syncStatus = 'synced'
          ..tieneDescuentoEspecial = data['tiene_descuento_especial'] ?? false
          ..montoDescuentoTotal = _toDouble(data['monto_descuento_total']);

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
            await _isarService.guardarDetallesVenta(ventaIdString, detalles);
            debugPrint(
                '📦 ${detalles.length} detalles guardados para venta $ventaIdString');
          }
        }
      }
      debugPrint('✅ $insertadas ventas insertadas, $actualizadas actualizadas');
    } catch (e, stack) {
      debugPrint('❌ Error descargando ventas: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarVentasDesdeSupabase_fallo');
    }
  }

  /// Sincroniza los pagos de venta pendientes con Supabase.
  ///
  /// Los pagos se suben DESPUÉS de que la venta esté sincronizada,
  /// porque `pagos_ventas.venta_id` es FK a `ventas.id`.
  Future<int> sincronizarPagosVenta() async {
    if (!_tieneSesionSupabase()) {
      debugPrint(
          '⚠️ [SyncService] Sin sesión activa. sincronizarPagosVenta omitido.');
      return 0;
    }

    try {
      final pendientes = await _isarService.obtenerPagosVentaPendientesSync();
      if (pendientes.isEmpty) return 0;

      debugPrint(
          '🔄 [SyncService] Sincronizando ${pendientes.length} pagos de venta...');
      int sincronizados = 0;

      for (final pago in pendientes) {
        try {
          // Validación: el pago necesita ventaSupabaseId
          if (pago.ventaSupabaseId == null || pago.ventaSupabaseId!.isEmpty) {
            debugPrint('⚠️ Pago ${pago.id} sin ventaSupabaseId. Saltando.');
            await _isarService.actualizarSyncStatusPagoVenta(pago.id, 'failed');
            continue;
          }

          // Validación: la venta debe existir en Supabase
          final ventaExistente = await _supabase
              .from('ventas')
              .select('id')
              .eq('id', pago.ventaSupabaseId!)
              .maybeSingle();

          if (ventaExistente == null) {
            debugPrint(
                '⚠️ Pago ${pago.id}: venta ${pago.ventaSupabaseId} no existe en Supabase. Saltando.');
            await _isarService.actualizarSyncStatusPagoVenta(pago.id, 'failed');
            continue;
          }

          final payload = pago.toSupabaseJson();
          payload['venta_id'] = pago.ventaSupabaseId;
          payload['sync_status'] = 'synced';

          // ✅ Si tenant_id es null, quitarlo para que la DB use su default
          if (payload['tenant_id'] == null) {
            payload.remove('tenant_id');
          }

          await _supabase
              .from('pagos_ventas')
              .upsert(payload, onConflict: 'id')
              .select('id')
              .maybeSingle();

          await _isarService.actualizarSyncStatusPagoVenta(pago.id, 'synced');
          sincronizados++;
        } catch (e, stack) {
          debugPrint('❌ Error sincronizando pago ${pago.id}: $e');
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarPagoVenta_individual_fallo',
              extras: {'pagoId': pago.id});
          await _isarService.actualizarSyncStatusPagoVenta(pago.id, 'failed');
        }
      }

      debugPrint('✅ [SyncService] $sincronizados pagos sincronizados.');
      return sincronizados;
    } catch (e, stack) {
      debugPrint('❌ Error general sincronizando pagos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarPagosVenta_fallo');
      return 0;
    }
  }

  /// Sincroniza las autorizaciones de descuento pendientes con Supabase.
  ///
  /// Se suben después de las ventas para satisfacer el FK
  /// `autorizaciones_descuento.venta_id`.
  Future<int> sincronizarAutorizaciones() async {
    if (!_tieneSesionSupabase()) {
      debugPrint(
          '⚠️ [SyncService] Sin sesión activa. sincronizarAutorizaciones omitido.');
      return 0;
    }

    try {
      final pendientes =
          await _isarService.obtenerAutorizacionesPendientesSync();
      if (pendientes.isEmpty) return 0;

      debugPrint(
          '🔄 [SyncService] Sincronizando ${pendientes.length} autorizaciones...');
      int sincronizadas = 0;

      for (final autz in pendientes) {
        try {
          // Si tiene ventaSupabaseId, validar que exista; si no, subir con null
          if (autz.ventaSupabaseId != null &&
              autz.ventaSupabaseId!.isNotEmpty) {
            final ventaExiste = await _supabase
                .from('ventas')
                .select('id')
                .eq('id', autz.ventaSupabaseId!)
                .maybeSingle();

            if (ventaExiste == null) {
              debugPrint(
                  '⚠️ Autorización ${autz.id}: venta ${autz.ventaSupabaseId} no existe. Se sube con venta_id=null.');
            }
          }

          final payload = autz.toSupabaseJson();
          if (autz.ventaSupabaseId == null || autz.ventaSupabaseId!.isEmpty) {
            payload['venta_id'] = null;
          }
          // ❌ FIX Bug I: autorizaciones_descuento NO tiene columna sync_status en Supabase
          payload.remove('sync_status');
          // ✅ Si tenant_id es null, quitarlo para que la DB use su default
          if (payload['tenant_id'] == null) {
            payload.remove('tenant_id');
          }

          await _supabase
              .from('autorizaciones_descuento')
              .upsert(payload, onConflict: 'id')
              .select('id')
              .maybeSingle();

          await _isarService.actualizarSyncStatusAutorizacion(
              autz.id, 'synced');
          sincronizadas++;
        } catch (e, stack) {
          debugPrint('❌ Error sincronizando autorización ${autz.id}: $e');
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarAutorizacion_individual_fallo',
              extras: {'autzId': autz.id});
          await _isarService.actualizarSyncStatusAutorizacion(
              autz.id, 'failed');
        }
      }

      debugPrint(
          '✅ [SyncService] $sincronizadas autorizaciones sincronizadas.');
      return sincronizadas;
    } catch (e, stack) {
      debugPrint('❌ Error general sincronizando autorizaciones: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarAutorizaciones_fallo');
      return 0;
    }
  }

  // ============================================================
  // MOVIMIENTOS DE INVENTARIO
  // ============================================================

  Future<int> sincronizarMovimientosInventario() async {
    try {
      final pendientes = await _isarService.obtenerMovimientosPendientesSync();
      if (pendientes.isEmpty) return 0;

      int sincronizados = 0;
      for (var mov in pendientes) {
        try {
          final exito = await _enviarMovimientoAlServidor(mov);
          if (exito) {
            await _isarService.actualizarSyncStatusMovimiento(mov.id, 'synced');
            sincronizados++;
          } else {
            await _isarService.actualizarSyncStatusMovimiento(mov.id, 'failed');
            debugPrint('⚠️ Movimiento ${mov.id} marcado como failed');
          }
        } catch (e, stack) {
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarMovimiento_individual_fallo',
              extras: {'movimientoId': mov.id});
          await _isarService.actualizarSyncStatusMovimiento(mov.id, 'failed');
        }
      }
      debugPrint('✅ $sincronizados movimientos sincronizados.');
      return sincronizados;
    } catch (e, stack) {
      debugPrint('🚫 [Supabase] Error al sincronizar movimientos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarMovimientosInventario_fallo');
      return 0;
    }
  }

  Future<bool> _enviarMovimientoAlServidor(
      MovimientoInventarioEntity mov) async {
    await _loadConfig();
    try {
      // ✅ Resolver UUIDs ANTES de tocar Supabase
      final producto = await _isarService.obtenerProductoPorId(mov.productoId);
      final productoUuid = producto?.supabaseId;

      if (productoUuid == null || productoUuid.isEmpty) {
        debugPrint(
            '⚠️ Movimiento ${mov.id} sin productoUuid. No se puede sincronizar.');
        return false;
      }

      // Requiere que exista en Supabase:
      // ajustar_stock(p_producto_id bigint, p_cantidad integer, p_tipo_movimiento text)
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
          await _insertarMovimientoDirecto(mov);
          debugPrint('✅ Movimiento ${mov.id} sincronizado vía RPC');
          return true;
        }
        debugPrint('⚠️ RPC ajustar_stock devolvió false, cayendo a directo');
      } catch (rpcError) {
        debugPrint('⚠️ RPC falló, intentando directo: $rpcError');
      }

      // ── Fallback: update producto + insert movimiento ──
      await _supabase
          .from('productos')
          .update({'stock': mov.stockResultante}).eq('uuid', productoUuid);

      await _insertarMovimientoDirecto(mov);
      debugPrint('✅ Movimiento ${mov.id} sincronizado vía directa');
      return true;
    } catch (e, stack) {
      debugPrint('🚫 Error enviando movimiento ${mov.id}: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: '_enviarMovimientoAlServidor_fallo',
          extras: {'movimientoId': mov.id});
      return false;
    }
  }

  /// Inserta el movimiento en `movimientos_inventarios` con UUIDs válidos.
  /// Si el usuario no tiene UUID resoluble, envía `null` (la columna debe
  /// aceptar null o tendrá un default).
  Future<void> _insertarMovimientoDirecto(
      MovimientoInventarioEntity mov) async {
    final payload = <String, dynamic>{
      'producto_id': mov.productoId, // int local (id_isar) — columna es bigint
      'nombre_producto': mov.nombreProducto,
      'tipo_movimiento': mov.tipoMovimiento,
      'cantidad': mov.cantidad,
      'stock_resultante': mov.stockResultante,
      'fecha': mov.fecha.toIso8601String(),
      'sync_status': 'synced',
    };
    if (mov.usuarioId > 0) {
      payload['usuario_id'] = mov.usuarioId; // int local — columna es bigint
    }
    await _supabase.from('movimientos_inventarios').insert(payload);
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

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
    } catch (e, stack) {
      debugPrint('❌ Error general sincronizando categorías: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarCategorias_fallo');
    }
  }

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
    } catch (e, stack) {
      debugPrint('❌ Error descargando categorías: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarCategoriasDesdeSupabase_fallo');
    }
  }

  // ============================================================
  // MARCAS
  // ============================================================

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
        try {
          final exito = await _enviarMarcaAlServidor(marca);
          if (exito) {
            await _isarService.actualizarSyncStatusMarca(marca.id, 'synced');
            sincronizadas++;
            debugPrint('✅ Marca ${marca.nombre} sincronizada');
          } else {
            await _isarService.actualizarSyncStatusMarca(marca.id, 'failed');
            debugPrint('⚠️ Marca ${marca.nombre} marcada como failed');
          }
        } catch (e, stack) {
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarMarca_individual_fallo',
              extras: {'marcaId': marca.id});
        }
      }
      debugPrint('✅ $sincronizadas marcas sincronizadas con Supabase');
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando marcas: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarMarcasPendientes_fallo');
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
    } catch (e, stack) {
      debugPrint('🚫 Error enviando marca ${marca.nombre}: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: '_enviarMarcaAlServidor_fallo',
          extras: {'marcaId': marca.id});
      return false;
    }
  }

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
    } catch (e, stack) {
      debugPrint('❌ Error descargando marcas: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarMarcasDesdeSupabase_fallo');
      rethrow;
    }
  }

  // ============================================================
  // GASTOS
  // ============================================================

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

        final idIsar = _toInt(data['id_isar']);
        GastoEntity? gastoLocal;

        if (idIsar > 0 && porIdIsar.containsKey(idIsar)) {
          gastoLocal = porIdIsar[idIsar];
        } else if (supabaseId.isNotEmpty &&
            porSupabaseId.containsKey(supabaseId)) {
          gastoLocal = porSupabaseId[supabaseId];
        }

        final String? usuarioUuid = data['usuario_id']?.toString();
        final int usuarioIsarId = usuarioUuid != null && usuarioUuid.isNotEmpty
            ? await _obtenerIsarIdUsuario(usuarioUuid)
            : 0;

        final gastoNube = GastoEntity()
          ..supabaseId = supabaseId
          ..descripcion = data['descripcion'] ?? ''
          ..monto = _toDouble(data['monto'])
          ..moneda = data['moneda'] ?? 'USD'
          ..tasaBcv =
              data['tasa_bcv'] == null ? null : _toDouble(data['tasa_bcv'])
          ..categoria = data['categoria'] ?? 'General'
          ..usuarioId = usuarioIsarId
          ..usuarioNombre = data['usuario_nombre'] ?? ''
          ..fecha = DateTime.parse(data['fecha']).toLocal()
          ..syncStatus = 'synced';

        if (gastoLocal != null) {
          gastoNube.id = gastoLocal.id;
          await _isarService.guardarGasto(gastoNube);
          actualizados++;
          debugPrint('🔄 Gasto actualizado: ${gastoNube.descripcion}');
        } else {
          if (idIsar > 0) {
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
    } catch (e, stack) {
      debugPrint('❌ Error descargando gastos desde Supabase: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarGastosDesdeSupabase_fallo');
      rethrow;
    }
  }

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
        try {
          final exito = await _enviarGastoAlServidor(gasto);
          if (exito) {
            await _isarService.actualizarSyncStatusGasto(gasto.id, 'synced');
            sincronizados++;
            debugPrint('✅ Gasto ${gasto.id} sincronizado');
          } else {
            await _isarService.actualizarSyncStatusGasto(gasto.id, 'failed');
            debugPrint('⚠️ Gasto ${gasto.id} marcado como failed');
          }
        } catch (e, stack) {
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarGasto_individual_fallo',
              extras: {'gastoId': gasto.id});
          await _isarService.actualizarSyncStatusGasto(gasto.id, 'failed');
        }
      }
      debugPrint('✅ $sincronizados gastos sincronizados');
      return sincronizados;
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando gastos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarGastosPendientes_fallo');
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
    } catch (e, stack) {
      debugPrint('🚫 Error al enviar gasto: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: '_enviarGastoAlServidor_fallo',
          extras: {'gastoId': gasto.id});
      return false;
    }
  }

  // ============================================================
  // TURNOS
  // ============================================================

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
        try {
          final exito = await _enviarTurnoAlServidor(turno);
          if (exito) {
            await _isarService.marcarTurnoComoSincronizado(turno.id);
            sincronizados++;
            debugPrint('✅ Turno ${turno.id} sincronizado');
          } else {
            debugPrint('⚠️ Turno ${turno.id} falló, se reintentará después');
          }
        } catch (e, stack) {
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarTurno_individual_fallo',
              extras: {'turnoId': turno.id});
        }
      }
      debugPrint('✅ $sincronizados turnos sincronizados');
      return sincronizados;
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando turnos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarTurnos_fallo');
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _enviarTurnoAlServidor(TurnoEntity turno) async {
    try {
      // ✅ Resolver UUID del usuario (columna usuario_id en Supabase)
      final usuarioUuid = await _obtenerSupabaseIdUsuario(turno.usuarioId);
      if (usuarioUuid == null || usuarioUuid.isEmpty) {
        debugPrint(
            '⚠️ Turno ${turno.id}: usuario local ${turno.usuarioId} sin UUID. No se puede sincronizar.');
        return false;
      }

      // ⚠️ NO enviamos `tenant_id`:
      //    La columna tiene DEFAULT current_tenant_id() que lee el JWT.
      //    Enviarlo explícitamente puede chocar con RLS si no coincide.
      // ⚠️ NO enviamos `caja_id`:
      //    Es nullable y TurnoEntity no lo maneja aún.
      final Map<String, dynamic> payload = {
        'id_isar': turno.id,
        'usuario_id': usuarioUuid, // ← UUID real
        'usuario_id_int': turno.usuarioId, // ← mantener para compatibilidad
        'usuario_nombre': turno.usuarioNombre,
        'monto_inicial': turno.montoInicial,
        'monto_final': turno.montoFinal ?? 0.0,
        'fecha_apertura': turno.fechaApertura.toIso8601String(),
        'estado': turno.estado,
        'sync_status': 'synced', // ← corregido (antes 'pending')
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
    } catch (e, stack) {
      debugPrint('🚫 Error al enviar turno: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: '_enviarTurnoAlServidor_fallo',
          extras: {'turnoId': turno.id});
      return false;
    }
  }

  // ============================================================
  // LOCALES
  // ============================================================

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
    } catch (e, stack) {
      debugPrint('❌ Error general en sincronizarLocalesPendientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarLocalesPendientes_fallo');
      rethrow;
    }
  }

  Future<bool> eliminarLocalEnSupabase(String supabaseId) async {
    try {
      final response = await _supabase
          .from('locales')
          .delete()
          .eq('id', supabaseId)
          .select();
      return response.isNotEmpty;
    } catch (e, stack) {
      debugPrint('❌ Error eliminando local en Supabase: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarLocalEnSupabase_fallo',
          extras: {'supabaseId': supabaseId});
      return false;
    }
  }

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

        final idIsar = _toInt(data['id_isar']);
        LocalEntity? local = localesPorSupabaseId[supabaseId];
        if (local == null && idIsar > 0) {
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
    } catch (e, stack) {
      debugPrint('❌ Error descargando locales: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarLocalesDesdeSupabase_fallo');
      rethrow;
    }
  }

  // ============================================================
  // DEPARTAMENTOS
  // ============================================================

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

        final tenantActual = localUuid;
        if (tenantActual == null || tenantActual.isEmpty) {
          debugPrint(
              '⚠️ Departamento ${departamento.nombre} sin tenant. Saltando.');
          continue;
        }

        final data = <String, dynamic>{
          'id_isar': departamento.id,
          'nombre': departamento.nombre,
          'descripcion': departamento.descripcion,
          'tenant_id': tenantActual,
          'usuario_id': usuarioUuid,
          'activo': departamento.activo,
          'sync_status': 'synced',
          'updated_at': DateTime.now().toIso8601String(),
        };

        try {
          final response = await _supabase
              .from('departamentos')
              .upsert(data, onConflict: 'id_isar,tenant_id')
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
    } catch (e, stack) {
      debugPrint('❌ Error general en sincronizarDepartamentosPendientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarDepartamentosPendientes_fallo');
      rethrow;
    }
  }

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

        final idIsar = _toInt(data['id_isar']);
        DepartamentoEntity? depto = localesPorSupabaseId[supabaseId];
        if (depto == null && idIsar > 0) {
          depto = localesPorId[idIsar];
        }

        final localUuid = data['tenant_id'] as String?;
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
    } catch (e, stack) {
      debugPrint('❌ Error descargando departamentos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarDepartamentosDesdeSupabase_fallo');
      rethrow;
    }
  }

  // ==================== CLIENTES ====================

  Future<void> sincronizarClientesPendientes() async {
    try {
      final pendientes = await _isarService.obtenerClientesPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay clientes pendientes para sincronizar');
        return;
      }

      debugPrint('🔄 Sincronizando ${pendientes.length} clientes...');

      final localActivo = await _isarService.obtenerLocalActivo();
      if (localActivo == null) {
        debugPrint('⚠️ No hay local activo. Cancelando sincronización.');
        return;
      }

      String? localSupabaseId = localActivo.supabaseId;
      if (localSupabaseId == null || localSupabaseId.isEmpty) {
        debugPrint(
            '⚠️ Local activo sin supabaseId. Intentando obtenerlo de Supabase...');
        final response = await _supabase
            .from('locales')
            .select('id')
            .eq('id_isar', localActivo.id)
            .maybeSingle();

        if (response != null) {
          localSupabaseId = response['id'] as String;
          localActivo.supabaseId = localSupabaseId;
          await _isarService.guardarLocal(localActivo);
          debugPrint('✅ Local actualizado con supabaseId: $localSupabaseId');
        } else {
          // ✅ Los locales NO se crean desde aquí. Se crean vía RPC
          // 'crear_nuevo_local_para_usuario' desde el LocalSelectorDialog.
          debugPrint('⚠️ Local "${localActivo.nombre}" no existe en Supabase. '
              'No se puede sincronizar clientes sin un tenant válido. '
              'Créalo desde el diálogo "Cambiar local".');
          return;
        }
      }

      if (localSupabaseId.isEmpty) {
        debugPrint('⚠️ No se pudo obtener un supabaseId válido. Cancelando.');
        return;
      }

      for (var cliente in pendientes) {
        cliente.localSupabaseId = localSupabaseId;
        cliente.localId = localActivo.id;

        final payload = {
          'id': cliente.supabaseId ?? const Uuid().v4(),
          'tenant_id': localSupabaseId,
          'nombre': cliente.nombre,
          'documento': cliente.documento,
          'tipo_documento': cliente.tipoDocumento,
          'telefono': cliente.telefono,
          'email': cliente.email,
          'direccion': cliente.direccion,
          'fecha_registro': cliente.fechaRegistro.toIso8601String(),
          'frecuente': cliente.frecuente,
          'total_compras': cliente.totalCompras,
          'ultima_compra': cliente.ultimaCompra?.toIso8601String(),
          'cantidad_compras': cliente.cantidadCompras,
          'activo': cliente.activo,
          'preferencias_marketing': cliente.preferenciasMarketing,
          'fecha_nacimiento':
              cliente.fechaNacimiento?.toIso8601String().split('T')[0],
          'notas': cliente.notas,
          // ✅ NUEVOS: Ventas al mayor
          'rif': cliente.rif,
          'razon_social': cliente.razonSocial,
          'es_mayorista': cliente.esMayorista,
          'limite_credito': cliente.limiteCredito,
          'dias_credito': cliente.diasCredito,
          'descuento_preferencial': cliente.descuentoPreferencial,
          'updated_at': DateTime.now().toIso8601String(),
        };

        try {
          final response = await _supabase
              .from('clientes')
              .upsert(payload, onConflict: 'id')
              .select()
              .maybeSingle();

          if (response != null) {
            final supabaseId = response['id'] as String;
            cliente.supabaseId = supabaseId;
            cliente.syncStatus = 'synced';
            cliente.updatedAt = DateTime.now();
            await _isarService.guardarCliente(cliente);
            debugPrint(
                '✅ Cliente ${cliente.nombre} sincronizado (ID: $supabaseId)');
          }
        } catch (e) {
          debugPrint('❌ Error sincronizando cliente ${cliente.nombre}: $e');
          cliente.syncStatus = 'failed';
          await _isarService.guardarCliente(cliente);
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error general en sincronizarClientesPendientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarClientesPendientes_fallo');
    }
  }

  Future<void> descargarClientesDesdeSupabase() async {
    try {
      final localActivo = await _isarService.obtenerLocalActivo();
      final localSupabaseId = localActivo?.supabaseId;
      if (localSupabaseId == null || localSupabaseId.isEmpty) {
        debugPrint(
            '⚠️ No se encontró local activo. No se descargarán clientes.');
        return;
      }

      final response = await _supabase
          .from('clientes')
          .select()
          .eq('tenant_id', localSupabaseId)
          .order('nombre', ascending: true);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay clientes en Supabase para descargar');
        return;
      }

      debugPrint(
          '🔄 Descargando ${response.length} clientes desde Supabase...');

      final locales = await _isarService.obtenerClientes(soloActivos: false);
      final Map<String, ClienteEntity> localesPorSupabaseId = {};
      for (var c in locales) {
        if (c.supabaseId != null) localesPorSupabaseId[c.supabaseId!] = c;
      }

      int creados = 0, actualizados = 0;
      for (var data in response) {
        final supabaseId = data['id'] as String;
        final clienteLocal = localesPorSupabaseId[supabaseId];

        final clienteNube = ClienteEntity()
          ..supabaseId = supabaseId
          ..localSupabaseId = localSupabaseId
          ..localId = localActivo?.id
          ..nombre = data['nombre'] ?? ''
          ..tipoDocumento = data['tipo_documento'] as String?
          ..documento = data['documento']
          ..telefono = data['telefono']
          ..email = data['email']
          ..direccion = data['direccion']
          ..fechaRegistro = data['fecha_registro'] != null
              ? DateTime.parse(data['fecha_registro'])
              : DateTime.now()
          ..frecuente = data['frecuente'] ?? false
          ..totalCompras = _toDouble(data['total_compras'])
          ..ultimaCompra = data['ultima_compra'] != null
              ? DateTime.parse(data['ultima_compra'])
              : null
          ..cantidadCompras = data['cantidad_compras'] ?? 0
          ..activo = data['activo'] ?? true
          ..preferenciasMarketing = data['preferencias_marketing'] ?? true
          ..fechaNacimiento = data['fecha_nacimiento'] != null
              ? DateTime.parse(data['fecha_nacimiento'])
              : null
          ..notas = data['notas']
          // ✅ NUEVOS: Ventas al mayor
          ..rif = data['rif'] as String?
          ..razonSocial = data['razon_social'] as String?
          ..esMayorista = data['es_mayorista'] as bool? ?? false
          ..limiteCredito = data['limite_credito'] == null
              ? null
              : _toDouble(data['limite_credito'])
          ..diasCredito =
              data['dias_credito'] == null ? null : _toInt(data['dias_credito'])
          ..descuentoPreferencial = data['descuento_preferencial'] == null
              ? null
              : _toDouble(data['descuento_preferencial'])
          ..syncStatus = 'synced'
          ..createdAt = data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null
          ..updatedAt = data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null;

        if (clienteLocal != null) {
          if (clienteLocal.syncStatus == 'pending') {
            continue;
          }
          clienteNube.id = clienteLocal.id;
          await _isarService.guardarCliente(clienteNube);
          actualizados++;
        } else {
          await _isarService.guardarCliente(clienteNube);
          creados++;
        }
      }

      debugPrint(
          '✅ $creados clientes creados, $actualizados actualizados localmente.');
    } catch (e, stack) {
      debugPrint('❌ Error descargando clientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarClientesDesdeSupabase_fallo');
    }
  }

  Future<bool> eliminarClienteEnSupabase(String supabaseId) async {
    try {
      final response = await _supabase
          .from('clientes')
          .delete()
          .eq('id', supabaseId)
          .select();
      return response.isNotEmpty;
    } catch (e, stack) {
      debugPrint('❌ Error eliminando cliente en Supabase: $e');
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarClienteEnSupabase_fallo',
          extras: {'supabaseId': supabaseId});
      return false;
    }
  }

  // ============================================================
  // CÓDIGOS DE BARRAS ALIAS
  // ============================================================

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
          'producto_id_fk':
              alias.productoId, // int local (id_isar) — columna es bigint
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
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando alias: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarAliasPendientes_fallo');
    }
  }

  // ============================================================
  // LOTES
  // ============================================================

  Future<void> sincronizarLotesPendientes() async {
    try {
      final pendientes = await _isarService.obtenerLotesPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay lotes pendientes para sincronizar');
        return;
      }

      debugPrint('🔄 Sincronizando ${pendientes.length} lotes con Supabase...');

      final productosSupabase =
          await _supabase.from('productos').select('id_isar, uuid');
      final Set<int> idsProductosEnSupabase = {};
      for (var p in productosSupabase) {
        idsProductosEnSupabase.add(_toInt(p['id_isar']));
      }

      for (var lote in pendientes) {
        final producto =
            await _isarService.obtenerProductoPorId(lote.productoId);
        if (producto == null) {
          debugPrint(
              '⚠️ Lote ${lote.id} omitido: producto ${lote.productoId} no existe en Isar');
          continue;
        }

        if (!idsProductosEnSupabase.contains(lote.productoId)) {
          debugPrint(
              '🔄 Producto ${producto.nombre} (ID ${lote.productoId}) no existe en Supabase, creándolo...');
          await _supabase.from('productos').insert({
            'id_isar': lote.productoId,
            'codigo_barras': producto.codigoBarras,
            'nombre': producto.nombre,
            'precio_unidad': producto.precioUnidad,
            'stock': producto.stock,
            'stock_minimo': producto.stockMinimo,
            'es_pesado': producto.esPesado,
            'categoria': producto.categoria,
            'uuid': producto.supabaseId ?? const Uuid().v4(),
          });
          idsProductosEnSupabase.add(lote.productoId);
          debugPrint('✅ Producto ${producto.nombre} creado en Supabase');
        }

        final localUuid = lote.localId == null
            ? null
            : await _obtenerSupabaseIdLocal(lote.localId!);

        final data = {
          'id_isar': lote.id,
          'producto_id_fk': lote.productoId,
          'tenant_id': localUuid,
          'codigo_lote_proveedor': lote.codigoLoteProveedor,
          'cantidad_inicial': lote.cantidadInicial,
          'cantidad_restante': lote.cantidadRestante,
          'fecha_ingreso': lote.fechaIngreso.toIso8601String(),
          'fecha_vencimiento': lote.fechaVencimiento?.toIso8601String(),
          'estado': lote.estado,
          'costo_unitario': lote.costoUnitario,
          'proveedor_id': lote.proveedorId,
          'proveedor_nombre': lote.proveedorNombre,
          'sincronizado': true,
          'fecha_sincronizacion': DateTime.now().toIso8601String(),
        };

        try {
          await _supabase.from('lotes').insert(data);
          debugPrint('✅ Lote ${lote.id} insertado correctamente');
        } catch (e) {
          if (e.toString().contains('duplicate key') ||
              e.toString().contains('unique constraint')) {
            debugPrint('🔄 Lote ${lote.id} ya existe, actualizando...');
            await _supabase.from('lotes').update(data).eq('id_isar', lote.id);
            debugPrint('✅ Lote ${lote.id} actualizado correctamente');
          } else {
            debugPrint('❌ Error sincronizando lote ${lote.id}: $e');
            continue;
          }
        }

        lote.sincronizado = true;
        lote.fechaSincronizacion = DateTime.now();
        await _isarService.guardarLote(lote);
      }
      debugPrint('✅ ${pendientes.length} lotes sincronizados correctamente');
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando lotes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarLotesPendientes_fallo');
      rethrow;
    }
  }

  // ============================================================
  // MOVIMIENTOS DE LOTE
  // ============================================================

  Future<void> descargarLotesDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('lotes')
          .select()
          .order('fecha_ingreso', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay lotes en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} lotes desde Supabase...');

      int creados = 0, actualizados = 0;

      for (var data in response) {
        final idIsar = _toInt(data['id_isar']);
        if (idIsar == 0) continue;

        final String? tenantUuid = data['tenant_id']?.toString();
        int? localIdResuelto;
        if (tenantUuid != null && tenantUuid.isNotEmpty) {
          localIdResuelto = await _obtenerIsarIdLocal(tenantUuid);
          if (localIdResuelto == 0) localIdResuelto = null;
        }

        final loteNube = LoteEntity.fromSupabase(
          data,
          localIdResuelto: localIdResuelto,
        );
        final existente = await _isarService.obtenerLotePorId(idIsar);

        if (existente != null) {
          bool cambios = false;

          if (loteNube.localId != null &&
              existente.localId != loteNube.localId) {
            existente.localId = loteNube.localId;
            cambios = true;
          }

          if (existente.cantidadRestante != loteNube.cantidadRestante) {
            existente.cantidadRestante = loteNube.cantidadRestante;
            cambios = true;
          }
          if (existente.estado != loteNube.estado) {
            existente.estado = loteNube.estado;
            cambios = true;
          }
          if (existente.proveedorId != loteNube.proveedorId) {
            existente.proveedorId = loteNube.proveedorId;
            cambios = true;
          }
          if (existente.proveedorNombre != loteNube.proveedorNombre) {
            existente.proveedorNombre = loteNube.proveedorNombre;
            cambios = true;
          }

          if (cambios) {
            existente.sincronizado = true;
            existente.fechaSincronizacion = DateTime.now();
            await _isarService.guardarLote(existente);
            actualizados++;
          }
        } else {
          await _isarService.guardarLote(loteNube);
          creados++;
        }
      }

      debugPrint(
          '✅ Lotes sincronizados: $creados creados, $actualizados actualizados');
    } catch (e, stack) {
      debugPrint('❌ Error descargando lotes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarLotesDesdeSupabase_fallo');
    }
  }

  Future<void> descargarMovimientosLoteDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('movimientos_lotes')
          .select()
          .order('fecha', ascending: false);
      if (response.isEmpty) return;

      debugPrint('🔄 Descargando ${response.length} movimientos de lote...');

      final locales = await _isarService.obtenerTodosMovimientosLote();
      final Map<int, MovimientoLoteEntity> localesPorId = {
        for (var m in locales) m.id: m
      };

      for (var data in response) {
        final idIsar = _toInt(data['id_isar']);
        if (idIsar == 0) continue;

        final movNube = MovimientoLoteEntity()
          ..id = idIsar
          ..loteId = _toInt(data['lote_id'], _toInt(data['lote_id_fk']))
          ..tipo = (data['tipo'] as String?) ??
              (data['tipo_movimiento'] as String?) ??
              ''
          ..cantidad = _toDouble(data['cantidad'])
          ..observaciones = (data['observaciones'] as String?) ??
              (data['origen_destino'] as String?)
          ..fecha = data['fecha'] != null
              ? DateTime.parse(data['fecha']).toLocal()
              : DateTime.now()
          ..usuarioId = _toInt(data['usuario_id'])
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        final local = localesPorId[idIsar];
        if (local == null) {
          await _isarService.guardarMovimientoLote(movNube);
        }
      }
      onDataChanged?.call();
    } catch (e, stack) {
      debugPrint('❌ Error descargando movimientos de lote: $e');
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'descargarMovimientosLoteDesdeSupabase_fallo',
      );
    }
  }

  // ============================================================
  // TELEGRAM CONFIG
  // ============================================================

  Future<void> sincronizarTelegramConfigPendientes() async {
    try {
      final pendientes =
          await _isarService.obtenerTelegramConfigsPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay configs de Telegram pendientes');
        return;
      }

      // Resolver el tenant una sola vez (no por cada config).
      final localActivo = await _isarService.obtenerLocalActivo();
      final String? tenantUuid = localActivo?.supabaseId ??
          (localActivo != null
              ? await _obtenerSupabaseIdLocal(localActivo.id)
              : null);

      if (tenantUuid == null) {
        debugPrint('⚠️ No hay local activo con UUID. Abortando sync Telegram.');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} configs de Telegram...');

      for (var config in pendientes) {
        // ✅ Persistir tenantId en el entity antes de enviar.
        config.tenantId = tenantUuid;

        final data = config.toSupabaseJson();
        // Aseguramos tenant_id en el payload.
        data['tenant_id'] = tenantUuid;
        data['sync_status'] = 'synced';
        data['sincronizado'] = true;

        try {
          final response = await _supabase
              .from('telegram_config')
              .upsert(data, onConflict: 'tenant_id,usuario_id')
              .select('id')
              .maybeSingle();

          final supabaseId = response?['id'] as String?;
          if (supabaseId != null) {
            config.supabaseId = supabaseId;
            config.sincronizado = true;
            config.syncStatus = 'synced';
            config.fechaSincronizacion = DateTime.now();
            await _isarService.guardarTelegramConfig(config);
            debugPrint(
                '✅ Config Telegram (usuario ${config.usuarioId}) sincronizada: $supabaseId');
          } else {
            debugPrint(
                '⚠️ No se obtuvo ID de Supabase para usuario ${config.usuarioId}');
          }
        } catch (e) {
          config.syncStatus = 'failed';
          await _isarService.guardarTelegramConfig(config);
          debugPrint('❌ Error sync config (usuario ${config.usuarioId}): $e');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error general en sincronizarTelegramConfigPendientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarTelegramConfigPendientes_fallo');
    }
  }

  Future<void> descargarTelegramConfigDesdeSupabase() async {
    try {
      // ✅ SELECT explícito: NO incluimos bot_token.
      final response = await _supabase
          .from('telegram_config')
          .select(
            'id, id_isar, usuario_id, tenant_id, chat_id, nombre_chat, '
            'enabled, notificar_stock_bajo, notificar_ventas, '
            'notificar_pedidos, comandos_permitidos, sincronizado, '
            'sync_status, fecha_sincronizacion, created_at, updated_at',
          )
          .order('id_isar', ascending: true);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay configs de Telegram en Supabase');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} configs de Telegram...');

      final locales = await _isarService.obtenerTodasTelegramConfigs();
      final Map<int, TelegramConfigEntity> localesPorUsuario = {
        for (var c in locales) c.usuarioId: c
      };

      for (final data in response) {
        final idIsar = _toInt(data['id_isar']);
        final usuarioId = _toInt(data['usuario_id']);

        if (idIsar == 0 || usuarioId == 0) {
          debugPrint('⚠️ Config sin id_isar o usuario_id, omitiendo');
          continue;
        }

        final local = localesPorUsuario[usuarioId];

        if (local != null) {
          // ✅ Preservamos SIEMPRE el botToken local — la nube no lo tiene.
          final localUpdated = local.updatedAt ?? DateTime(1970);
          final nubeUpdated = data['updated_at'] != null
              ? DateTime.parse(data['updated_at'] as String)
              : DateTime(1970);

          if (nubeUpdated.isAfter(localUpdated)) {
            // Actualizamos metadata pero NO el token.
            local
              ..supabaseId = data['id'] as String?
              ..tenantId = data['tenant_id'] as String?
              ..chatId = data['chat_id'] as String? ?? local.chatId
              ..nombreChat = data['nombre_chat'] as String? ?? local.nombreChat
              ..enabled = data['enabled'] as bool? ?? local.enabled
              ..notificarStockBajo = data['notificar_stock_bajo'] as bool? ??
                  local.notificarStockBajo
              ..notificarVentas =
                  data['notificar_ventas'] as bool? ?? local.notificarVentas
              ..notificarPedidos =
                  data['notificar_pedidos'] as bool? ?? local.notificarPedidos
              ..comandosPermitidos = data['comandos_permitidos'] is List
                  ? List<String>.from(data['comandos_permitidos'])
                  : local.comandosPermitidos
              ..sincronizado = true
              ..syncStatus = 'synced'
              ..updatedAt = nubeUpdated;

            await _isarService.guardarTelegramConfig(local);
            debugPrint('🔄 Config Telegram actualizada (usuario $usuarioId)');
          }
        } else {
          // ✅ Config nueva en la nube pero sin token local → no la importamos
          //    porque no podríamos activar el bot. Solo la registramos si
          //    viene SIN token (para que el usuario lo complete después).
          final nueva = TelegramConfigEntity()
            ..id = idIsar
            ..usuarioId = usuarioId
            ..supabaseId = data['id'] as String?
            ..tenantId = data['tenant_id'] as String?
            ..chatId = data['chat_id'] as String? ?? ''
            ..nombreChat = data['nombre_chat'] as String?
            ..enabled =
                false // ❌ Deshabilitado hasta que se re-ingrese el token
            ..notificarStockBajo = data['notificar_stock_bajo'] as bool? ?? true
            ..notificarVentas = data['notificar_ventas'] as bool? ?? false
            ..notificarPedidos = data['notificar_pedidos'] as bool? ?? false
            ..comandosPermitidos = data['comandos_permitidos'] is List
                ? List<String>.from(data['comandos_permitidos'])
                : const ['/ventas', '/stock', '/ayuda']
            ..sincronizado = true
            ..syncStatus = 'synced'
            ..botToken = ''; // ← Sin token, el usuario debe reconfigurarlo

          await _isarService.guardarTelegramConfig(nueva);
          debugPrint(
              '📥 Config Telegram importada sin token (usuario $usuarioId) '
              '— requiere reconfiguración');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error descargando configs de Telegram: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarTelegramConfigDesdeSupabase_fallo');
    }
  }

  // ============================================================
  // PEDIDOS
  // ============================================================

  Future<void> sincronizarPedidosPendientes() async {
    try {
      final pedidosPendientes =
          await _isarService.obtenerPedidosPendientesSync();
      if (pedidosPendientes.isEmpty) {
        debugPrint('ℹ️ No hay pedidos pendientes para sincronizar');
        return;
      }

      debugPrint('📦 Sincronizando ${pedidosPendientes.length} pedidos...');

      final localesEnSupabase =
          await _supabase.from('locales').select('id, id_isar');
      final Map<int, String> idIsarAUuid = {};
      for (var row in localesEnSupabase) {
        final idIsar = row['id_isar'];
        final id = row['id'];
        if (idIsar == null || id == null) continue; // ✅ skip nulls
        idIsarAUuid[_toInt(idIsar)] = id as String;
      }

      final localActivo = await _isarService.obtenerLocalActivo();
      if (localActivo == null) {
        debugPrint('⚠️ No hay local activo. No se sincronizarán pedidos.');
        return;
      }
      final int localActualId = localActivo.id;
      final String? localActualUuid =
          localActivo.supabaseId ?? idIsarAUuid[localActualId];

      if (localActualUuid == null) {
        debugPrint('⚠️ El local activo (ID $localActualId) no tiene UUID.');
        return;
      }

      debugPrint('🏢 Local activo: ID=$localActualId, UUID=$localActualUuid');

      for (var pedido in pedidosPendientes) {
        bool pedidoModificado = false;

        if (!idIsarAUuid.containsKey(pedido.localOrigenId)) {
          debugPrint(
              '⚠️ Pedido ${pedido.id}: localOrigenId ${pedido.localOrigenId} NO existe en Supabase. Reasignando a $localActualId.');
          pedido.localOrigenId = localActualId;
          pedidoModificado = true;
        }

        if (pedidoModificado) {
          await _isarService.guardarPedido(pedido);
        }

        final String? usuarioUuid =
            await _obtenerSupabaseIdUsuario(pedido.usuarioId);
        if (usuarioUuid == null) {
          debugPrint('⚠️ Pedido ${pedido.id} omitido: usuario sin UUID');
          continue;
        }

        final localOrigenUuid =
            await _obtenerSupabaseIdLocal(pedido.localOrigenId);

        final pedidoData = {
          'id_isar': pedido.id,
          'tenant_id': localOrigenUuid,
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

        String? supabasePedidoId;
        try {
          final response = await _supabase
              .from('pedidos')
              .insert(pedidoData)
              .select()
              .maybeSingle();
          if (response != null) {
            supabasePedidoId = response['id'] as String;
            debugPrint('✅ Pedido ${pedido.id} insertado correctamente');
          }
        } catch (e) {
          if (e.toString().contains('duplicate key') ||
              e.toString().contains('unique constraint')) {
            debugPrint('🔄 Pedido ${pedido.id} ya existe, actualizando...');
            final response = await _supabase
                .from('pedidos')
                .update(pedidoData)
                .eq('id_isar', pedido.id)
                .select()
                .maybeSingle();
            if (response != null) {
              supabasePedidoId = response['id'] as String;
              debugPrint('✅ Pedido ${pedido.id} actualizado correctamente');
            }
          } else {
            debugPrint('❌ Error insertando pedido ${pedido.id}: $e');
            continue;
          }
        }

        if (supabasePedidoId == null) {
          debugPrint('⚠️ Pedido ${pedido.id} no se pudo sincronizar');
          continue;
        }

        final detalles = await _isarService.obtenerDetallesPorPedido(pedido.id);
        for (var detalle in detalles) {
          await _supabase.from('detalles_pedido').insert({
            'pedido_id': supabasePedidoId,
            'producto_id_isar': detalle.productoId,
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
      }

      debugPrint('✅ Pedidos sincronizados correctamente.');
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando pedidos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarPedidosPendientes_fallo');
      rethrow;
    }
  }

  // ============================================================
  // descargarPedidosDesdeSupabase
  // ============================================================

  Future<void> descargarPedidosDesdeSupabase() async {
    try {
      final response = await _supabase
          .from('pedidos')
          .select('*, detalles_pedido(*), recepciones(*)')
          .order('fecha_pedido', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay pedidos en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} pedidos desde Supabase...');

      final isar = await _isarService.db;
      int guardados = 0;

      for (var pedidoJson in response) {
        final existing = await isar.pedidoEntitys
            .filter()
            .supabaseIdEqualTo(pedidoJson['id'])
            .findFirst();
        if (existing != null) continue;

        final String? localOrigenUuid = pedidoJson['tenant_id']?.toString();
        final String? usuarioUuid = pedidoJson['usuario_id']?.toString();

        if (localOrigenUuid == null || usuarioUuid == null) {
          debugPrint('⚠️ Pedido ${pedidoJson['id']} omitido: campos faltantes');
          continue;
        }

        final int localOrigenId = await _obtenerIsarIdLocal(localOrigenUuid);
        final int usuarioId = await _obtenerIsarIdUsuario(usuarioUuid);

        if (localOrigenId == 0 || usuarioId == 0) {
          debugPrint(
              '⚠️ Pedido ${pedidoJson['id']} omitido: IDs no encontrados (origen=$localOrigenId, usuario=$usuarioId)');
          continue;
        }

        final pedido = PedidoEntity()
          ..supabaseId = pedidoJson['id']
          ..localOrigenId = localOrigenId
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
          ..total = _toDouble(pedidoJson['total'])
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        await isar.writeTxn(() async {
          final pedidoId = await isar.pedidoEntitys.put(pedido);

          for (var detalleJson in pedidoJson['detalles_pedido'] ?? []) {
            int productoId = 0;

            final rawIdIsar = detalleJson['producto_id_isar'];
            if (rawIdIsar != null) {
              final idStr = rawIdIsar.toString();
              if (idStr.contains(RegExp(r'^\d+$'))) {
                productoId = int.tryParse(idStr) ?? 0;
              }
            }

            if (productoId == 0) {
              final rawId = detalleJson['producto_id'];
              if (rawId != null) {
                final idStr = rawId.toString();
                if (idStr.contains('-')) {
                  productoId = await _obtenerIsarIdProducto(idStr);
                } else {
                  productoId = int.tryParse(idStr) ?? 0;
                }
              }
            }

            if (productoId == 0) {
              final nombre = detalleJson['nombre_producto'] as String?;
              if (nombre != null) {
                final productos = await _isarService.obtenerProductos();
                final encontrado = productos.firstWhere(
                  (p) => p.nombre == nombre,
                  orElse: () => ProductoEntity(),
                );
                if (encontrado.id != 0) {
                  productoId = encontrado.id;
                }
              }
            }

            final detalle = DetallePedidoEntity()
              ..supabaseId = detalleJson['id']
              ..pedidoId = pedidoId
              ..productoId = productoId
              ..nombreProducto = detalleJson['nombre_producto'] ?? ''
              ..cantidad = _toDouble(detalleJson['cantidad'])
              ..precioUnidad = _toDouble(detalleJson['precio_unidad'])
              ..subtotal = _toDouble(detalleJson['subtotal']);
            await isar.detallePedidoEntitys.put(detalle);
          }

          final recepcionJson = pedidoJson['recepciones'];
          if (recepcionJson != null && recepcionJson.isNotEmpty) {
            final recepcionData = recepcionJson[0];
            final usuarioRecepcionId = _toInt(recepcionData['usuario_id']);
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

        guardados++;
      }

      debugPrint('✅ $guardados pedidos descargados y guardados correctamente.');
    } catch (e, stack) {
      debugPrint('❌ Error descargando pedidos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarPedidosDesdeSupabase_fallo');
      rethrow;
    }
  }

  // ============================================================
  // MÉTODOS AUXILIARES (UUID ↔ ID de Isar)
  // ============================================================

  Future<String?> _obtenerSupabaseIdLocal(int isarId) async {
    if (isarId <= 0) return null;

    final isar = await _isarService.db;
    LocalEntity? local = await isar.localEntitys.get(isarId);

    if (local != null &&
        local.supabaseId != null &&
        local.supabaseId!.isNotEmpty) {
      return local.supabaseId;
    }

    try {
      final data = await _supabase
          .from('locales')
          .select('id')
          .eq('id_isar', isarId)
          .maybeSingle();

      if (data != null) {
        final supabaseId = data['id'] as String?;
        if (supabaseId != null && supabaseId.isNotEmpty) {
          if (local != null) {
            local.supabaseId = supabaseId;
            await isar.writeTxn(() async {
              await isar.localEntitys.put(local);
            });
          }
          return supabaseId;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error obteniendo UUID del local $isarId: $e');
    }

    return null;
  }

  Future<String?> _obtenerSupabaseIdUsuario(int isarId) async {
    final usuario = await _isarService.obtenerUsuarioPorId(isarId);
    return usuario?.supabaseId;
  }

  Future<int> _obtenerIsarIdLocal(String supabaseId) async {
    if (supabaseId.isEmpty) return 0;

    final numericId = int.tryParse(supabaseId);
    if (numericId != null) {
      debugPrint(
          '⚠️ Se recibió id_isar numérico en lugar de UUID: $numericId. Buscando local...');
      final local = await _isarService.obtenerLocalPorId(numericId);
      if (local != null) {
        debugPrint(
            '✅ Local encontrado por id_isar: ${local.nombre} (ID: ${local.id})');
        return local.id;
      }
      return 0;
    }

    final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false);
    if (!uuidRegex.hasMatch(supabaseId)) {
      debugPrint('⚠️ UUID inválido: $supabaseId');
      return 0;
    }

    final local = await _isarService.obtenerLocalPorSupabaseId(supabaseId);
    if (local != null) return local.id;

    try {
      final data = await _supabase
          .from('locales')
          .select()
          .eq('id', supabaseId)
          .maybeSingle();
      if (data != null) {
        final nuevoLocal = LocalEntity()
          ..supabaseId = supabaseId
          ..nombre = data['nombre'] ?? 'Local Sincronizado'
          ..activo = data['activo'] ?? true
          ..sincronizado = true;
        await _isarService.guardarLocal(nuevoLocal);
        return nuevoLocal.id;
      }
    } catch (e) {
      debugPrint('⚠️ Error obteniendo local desde Supabase: $e');
    }
    return 0;
  }

  Future<int> _obtenerIsarIdUsuario(String supabaseId) async {
    if (supabaseId.isEmpty) return 0;

    final usuario = await _isarService.obtenerUsuarioPorSupabaseId(supabaseId);
    if (usuario != null) return usuario.id;

    try {
      final response = await _supabase
          .from('usuarios')
          .select('id_isar, nombre, pin, rol, email, estado, tenant_id')
          .eq('id', supabaseId)
          .maybeSingle();
      if (response != null) {
        final estadoNube = response['estado'] as String? ?? 'inactivo';
        // ✅ PinHasher va a hashear si viene plano, pero verificamos antes
        //    para evitar doble hash si ya venía hasheado desde Supabase.
        final pinRaw = response['pin'] as String? ?? '1234';
        final pinFinal = PinHasher.isHashed(pinRaw)
            ? pinRaw
            : PinHasher.hashWithNewSalt(pinRaw);

        final nuevoUsuario = UsuarioEntity()
          ..supabaseId = supabaseId
          ..id = _toInt(response['id_isar'], Isar.autoIncrement)
          ..nombre = response['nombre'] ?? 'Usuario Sincronizado'
          ..pin = pinFinal
          ..rol = response['rol'] ?? 'cajero'
          ..email = response['email'] as String?
          ..tenantId = response['tenant_id'] as String?
          // activo se deriva de estado
          ..activo = estadoNube != 'inactivo' && estadoNube != 'desconectado'
          ..estado = estadoNube
          ..cajaAsignada = ''
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        await _isarService.guardarUsuario(nuevoUsuario);
        debugPrint(
            '✅ Usuario creado automáticamente: ${nuevoUsuario.nombre} (ID: ${nuevoUsuario.id})');
        return nuevoUsuario.id;
      }
    } catch (e) {
      debugPrint('⚠️ Error creando usuario desde Supabase: $e');
    }

    return 0;
  }

  Future<int> _obtenerIsarIdProducto(String supabaseId) async {
    if (supabaseId.isEmpty) return 0;

    final producto =
        await _isarService.obtenerProductoPorSupabaseId(supabaseId);
    if (producto != null) return producto.id;

    try {
      final response = await _supabase
          .from('productos')
          .select(
              'id_isar, codigo_barras, nombre, precio_unidad, stock, categoria')
          .eq('uuid', supabaseId)
          .maybeSingle();

      if (response != null) {
        final nuevoProducto = ProductoEntity()
          ..supabaseId = supabaseId
          ..id = _toInt(response['id_isar'], Isar.autoIncrement)
          ..codigoBarras = response['codigo_barras'] ?? ''
          ..nombre = response['nombre'] ?? 'Producto Sincronizado'
          ..precioUnidad = _toDouble(response['precio_unidad'])
          ..stock = _toDouble(response['stock'])
          ..categoria = response['categoria'] ?? 'General'
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        await _isarService.guardarProducto(nuevoProducto);
        debugPrint(
            '✅ Producto creado automáticamente desde Supabase: ${nuevoProducto.nombre} (ID: ${nuevoProducto.id})');
        return nuevoProducto.id;
      }
    } catch (e) {
      debugPrint('⚠️ Error creando producto desde Supabase: $e');
    }

    return 0;
  }

  // ============================================================
  // REPARACIÓN DE IMÁGENES
  // ============================================================

  Future<int> repararImagenesFaltantes() async {
    try {
      debugPrint('🔍 [SyncService] Iniciando reparación de imágenes...');

      // ✅ Obtener tenant activo
      final tenantId = getTenantIdFromJWT();
      if (tenantId == null || tenantId.isEmpty) {
        debugPrint('⚠️ [repararImagenes] Sin tenant_id activo. Abortando.');
        return 0;
      }

      final productos = await _isarService.obtenerProductos();
      final supabase = Supabase.instance.client;
      int reparados = 0;

      // ✅ Listar SOLO los archivos del tenant actual
      final tenantPath = '$tenantId/productos';
      final allFiles =
          await supabase.storage.from('productos').list(path: tenantPath);

      debugPrint(
          '📁 [SyncService] Archivos en Storage ($tenantPath): ${allFiles.length}');

      // ✅ Mapear archivos por código de barras
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
          // ✅ Path completo: {tenant_id}/productos/{fileName}
          final fullPath = '$tenantPath/$fileName';
          final publicUrl =
              supabase.storage.from('productos').getPublicUrl(fullPath);
          p.imagenUrl = publicUrl;
          await _isarService.guardarProducto(p);
          reparados++;
          debugPrint('🖼️ Imagen reparada para ${p.nombre}: $fullPath');
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
    } catch (e, stack) {
      debugPrint('❌ Error reparando imágenes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'repararImagenesFaltantes_fallo');
      return 0;
    }
  }

  Future<bool> _tieneSesionSupabaseValida() async {
    final client = Supabase.instance.client;
    var session = client.auth.currentSession;

    if (session == null) return false;

    if (session.isExpired) {
      try {
        final response = await client.auth.refreshSession();
        session = response.session;
      } catch (e) {
        debugPrint(
            '⚠️ SyncService: No se pudo refrescar el token de sesión: $e');
        return false;
      }
    }

    return session != null;
  }

  Future<void> subirUsuariosPendientes() async {
    if (!await _tieneSesionSupabaseValida()) return;

    final usuariosPendientes =
        await _isarService.obtenerUsuariosNoSincronizados();

    for (final user in usuariosPendientes) {
      // ✅ Sin supabaseId no podemos hacer update — lo saltamos.
      final uuid = user.supabaseId;
      if (uuid == null || uuid.isEmpty) {
        debugPrint(
            '⚠️ Usuario "${user.nombre}" sin supabaseId. No se puede subir PIN.');
        continue;
      }

      try {
        await Supabase.instance.client
            .from('usuarios')
            .update({'pin': user.pin}).eq('id', uuid);

        user.sincronizado = true;
        user.fechaSincronizacion = DateTime.now();
        await _isarService.guardarUsuario(user);

        debugPrint('✅ PIN/Usuario sincronizado diferido: ${user.email}');
      } catch (e) {
        debugPrint('❌ Fallo al subir cambio diferido de usuario: $e');
      }
    }
  }

  // ============================================================
  // SINCRONIZACIÓN COMPLETA
  // ============================================================

  /// Ejecuta un paso del sync sin abortar el resto si falla.
  /// Cada módulo es independiente: si uno falla, los demás continúan.
  Future<void> _safe(String nombre, Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e, stack) {
      debugPrint('⚠️ [$nombre] falló, sync continúa: $e');
      ErrorService.captureError(e, stack: stack, hint: '${nombre}_fallo');
    }
  }

  Future<void> sincronizarTodo() async {
    if (!_tieneSesionSupabase()) {
      debugPrint(
          '⚠️ [SyncService] Sin sesión activa. sincronizarTodo omitido.');
      return;
    }
    if (_syncEnCurso) {
      debugPrint('⚠️ [SyncService] Sync ya en curso, saltando.');
      return;
    }
    _syncEnCurso = true;
    try {
      debugPrint('🔄 [SyncService] Iniciando sincronización completa...');

      await _safe('descargarCategorias', descargarCategoriasDesdeSupabase);
      await _safe('sincronizarCategorias', sincronizarCategorias);
      await _safe('descargarMarcas', descargarMarcasDesdeSupabase);
      await _safe('sincronizarMarcas', sincronizarMarcasPendientes);
      await _safe('descargarProductos', descargarProductosDesdeSupabase);
      await _safe('sincronizarProductos', sincronizarProductosASupabase);

      await _safe('sincronizarVentas', sincronizarVentasPendientes);
      await _safe('sincronizarPagos', sincronizarPagosVenta);
      await _safe('sincronizarAutorizaciones', sincronizarAutorizaciones);
      await _safe('descargarVentas', descargarVentasDesdeSupabase);

      await _safe('sincronizarMovimientos', sincronizarMovimientosInventario);
      await _safe('sincronizarTurnos', sincronizarTurnos);

      await _safe(
          'limpiarUsuariosHuerfanos', limpiarUsuariosHuerfanosEnSupabase);
      await _safe('sincronizarUsuariosASupabase', sincronizarUsuariosASupabase);
      await _safe(
          'sincronizarUsuariosDesdeSupabase', sincronizarUsuariosDesdeSupabase);

      await _safe('sincronizarGastos', sincronizarGastosPendientes);
      await _safe('descargarGastos', descargarGastosDesdeSupabase);

      await _safe('sincronizarPedidos', sincronizarPedidosPendientes);
      await _safe('descargarPedidos', descargarPedidosDesdeSupabase);

      await _safe('sincronizarProveedores', sincronizarProveedoresPendientes);
      await _safe('descargarProveedores', descargarProveedoresDesdeSupabase);

      await _safe('sincronizarAlias', sincronizarAliasPendientes);
      await _safe('sincronizarLotes', sincronizarLotesPendientes);
      await _safe('descargarLotes', descargarLotesDesdeSupabase);

      await _safe('descargarLocales', descargarLocalesDesdeSupabase);
      await _safe(
          'sincronizarDepartamentos', sincronizarDepartamentosPendientes);
      await _safe(
          'descargarDepartamentos', descargarDepartamentosDesdeSupabase);

      await _safe('sincronizarTelegram', sincronizarTelegramConfigPendientes);
      await _safe('descargarTelegram', descargarTelegramConfigDesdeSupabase);

      debugPrint('✅ Sincronización completa finalizada.');
      onDataChanged?.call();
    } catch (e, stack) {
      debugPrint('❌ Error en sincronización completa: $e');
      ErrorService.captureError(e, stack: stack, hint: 'sincronizarTodo_fallo');
    } finally {
      _syncEnCurso = false;
    }
  }

  Future<Map<String, int>> sincronizarTodoConResumen() async {
    int ventas = 0, productos = 0, proveedores = 0, gastos = 0;
    int pedidos = 0, lotes = 0, marcas = 0, locales = 0;
    int departamentos = 0, telegram = 0;

    try {
      await descargarCategoriasDesdeSupabase();
      await sincronizarCategorias();

      await descargarMarcasDesdeSupabase();
      final marcasPend = await _isarService.obtenerMarcasPendientesSync();
      if (marcasPend.isNotEmpty) {
        await sincronizarMarcasPendientes();
        marcas = marcasPend.length;
      }

      final ventasPend = await _isarService.obtenerVentasPendientesSync();
      if (ventasPend.isNotEmpty) {
        await sincronizarVentasPendientes();
        // ✅ NUEVO: pagos y autorizaciones en el mismo ciclo
        await sincronizarPagosVenta();
        await sincronizarAutorizaciones();
        ventas = ventasPend.length;
      }

      final productosPend = await _isarService.obtenerProductosPendientesSync();
      if (productosPend.isNotEmpty) {
        await sincronizarProductosASupabase();
        productos = productosPend.length;
      }

      final proveedoresPend =
          await _isarService.obtenerProveedoresPendientesSync();
      if (proveedoresPend.isNotEmpty) {
        await sincronizarProveedoresPendientes();
        proveedores = proveedoresPend.length;
      }

      final gastosPend = await _isarService.obtenerGastosPendientesSync();
      if (gastosPend.isNotEmpty) {
        await sincronizarGastosPendientes();
        await descargarGastosDesdeSupabase();
        gastos = gastosPend.length;
      }

      final pedidosPend = await _isarService.obtenerPedidosPendientesSync();
      if (pedidosPend.isNotEmpty) {
        await sincronizarPedidosPendientes();
        pedidos = pedidosPend.length;
      }

      final lotesPend = await _isarService.obtenerLotesPendientesSync();
      if (lotesPend.isNotEmpty) {
        await sincronizarLotesPendientes();
        lotes = lotesPend.length;
      }

      /*   final localesPend = await _isarService.obtenerLocalesPendientesSync();
      if (localesPend.isNotEmpty) {
        await sincronizarLocalesPendientes();
        locales = localesPend.length;
      } */

      final deptosPend =
          await _isarService.obtenerDepartamentosPendientesSync();
      if (deptosPend.isNotEmpty) {
        await sincronizarDepartamentosPendientes();
        departamentos = deptosPend.length;
      }

      final telegramPend =
          await _isarService.obtenerTelegramConfigsPendientesSync();
      if (telegramPend.isNotEmpty) {
        await sincronizarTelegramConfigPendientes();
        telegram = telegramPend.length;
      }

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
    } catch (e, stack) {
      debugPrint('❌ Error en sincronización completa con resumen: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarTodoConResumen_fallo');
      rethrow;
    }
  }
}
