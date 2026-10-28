// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'package:app_boosti_v2/core/security/telegram_crypto.dart';
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
import '../../data/Local/entities/receta_entity.dart';
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
import '../../data/Local/entities/mesa_entity.dart';
import '../../data/Local/entities/zona_entity.dart';
import '../../data/Local/entities/telegram_config_entity.dart';
import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/movimiento_lote_entity.dart';
import '../../data/Local/entities/cliente_entity.dart';
import 'error_service.dart'; // ✅ NUEVO: Para monitoreo

// 🛠️ FIX: Constantes centralizadas para evitar strings mágicos
class _SyncConstants {
  static const String synced = 'synced';
  static const String failed = 'failed';
  static const String activo = 'activo';
  static const String inactivo = 'inactivo';
  static const String desconectado = 'desconectado';
}

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
  bool _escribiendoUsuarios = false;
  // 🎯 Anti-eco: evita procesar eventos de `locales` que provienen de
  //    nuestra propia escritura. Se activa en `sincronizarLocalesPendientes()`
  //    y se desactiva en su `finally`.
  bool _escribiendoLocales = false;
  bool _timestampsDifieren(DateTime? a, DateTime? b) {
  if (a == null && b == null) return false;
  if (a == null || b == null) return true;
  return a.difference(b).abs().inSeconds > 5;
}

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

  /// Retorna `true` si [s] es un UUID válido (hex con guiones).
  ///
  /// 🎯 FIX Bug 6: usado por `_enviarMarcaAlServidor` para detectar
  /// IDs corruptos generados con `DateTime.now().millisecondsSinceEpoch`
  /// (por ejemplo "1790482577151") que PostgREST rechaza con 22P02.
  bool _esUuid(String s) {
    final re = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return re.hasMatch(s);
  }

  /// Normaliza el valor de `business_mode` que viene de Supabase.
  ///
  /// Si es null, vacío o un valor desconocido → devuelve 'retail'
  /// (retrocompatible con locales existentes que no tienen el campo).
  ///
  /// Acepta el valor legacy `'mercado'` y lo devuelve como `'retail'`.
  /// `locales.business_mode` en Supabase ya guarda `'retail'` en los
  /// 4 planes; sin esta traducción, un local descargado de la nube
  /// caería al `orElse` y se guardaría en Isar como `'mercado'`.
  String _parseBusinessMode(dynamic value) {
    if (value == null) return 'retail';
    final s = value.toString().trim().toLowerCase();
    if (s == 'mercado') return 'retail';
    const validos = {'retail', 'restaurante', 'servicios'};
    if (validos.contains(s)) return s;
    return 'retail';
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

  /// Callback opcional que se dispara cuando un local cambió desde
  /// OTRO dispositivo (vía Realtime de Supabase).
  ///
  /// El consumidor (`syncServiceProvider`) lo usa para recargar el
  /// `businessModeProvider` y refrescar la UI sin reiniciar.
  final VoidCallback? onLocalCambiado;

  SyncService({
    this.onDataChanged,
    this.onLocalCambiado,
    SupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient;

  void iniciarSuscripcionesRealtime() {
    // 🛠️ FIX: Prevenir memory leaks por listeners duplicados
    detenerSuscripcionesRealtime();
    try {
      _suscribirATabla('productos', () => descargarProductosDesdeSupabase());
      _suscribirATabla('categorias', () => descargarCategoriasDesdeSupabase());
      _suscribirATabla('marcas', () => descargarMarcasDesdeSupabase());
      _suscribirATabla('locales', _onLocalesCambiaronDesdeNube);
      _suscribirATabla( 'departamentos', () => descargarDepartamentosDesdeSupabase());
      _suscribirATabla('usuarios', () => sincronizarUsuariosDesdeSupabase());
      _suscribirATabla('gastos', () => descargarGastosDesdeSupabase());
      _suscribirATabla('clientes', () => descargarClientesDesdeSupabase());
      // R.1b · Salón multi-dispositivo. Las mesas dependen de las zonas,
      // así que el pull de zonas se refresca primero.
      _suscribirATabla('zonas', () async {
        await descargarZonasDesdeSupabase();
        await descargarMesasDesdeSupabase();
      });
      _suscribirATabla('mesas', () => descargarMesasDesdeSupabase());

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

            // ═══════════════════════════════════════════════════════
            // 🎯 FIX ANTI-ECO
            //
            //   Cuando `sincronizarUsuariosASupabase` sube cambios, el
            //   Realtime de Supabase nos avisa de esos mismos cambios
            //   y dispara un download inmediato → write → eco → download…
            //
            //   Ignoramos los eventos de `usuarios` mientras estamos
            //   escribiendo nosotros mismos. Los cambios reales de otros
            //   dispositivos siguen llegando cuando `_escribiendoUsuarios`
            //   vuelve a `false`.
            // ═══════════════════════════════════════════════════════
            if (tabla == 'usuarios' && _escribiendoUsuarios) {
              return;
            }

            // 🎯 Anti-eco para locales
            if (tabla == 'locales' && _escribiendoLocales) {
              return;
            }

            // Debounce: evita ráfagas de cambios seguidos
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

/// Handler ejecutado cuando Realtime detecta cambios en `locales`
/// desde OTRO dispositivo.
///
/// Estrategia:
///   1. Descarga los locales actualizados desde Supabase → Isar.
///   2. Notifica al consumidor vía `onLocalCambiado` para que recargue
///      el `businessModeProvider` y refresque la UI.
Future<void> _onLocalesCambiaronDesdeNube() async {
  try {
    debugPrint('🔄 [Realtime] Locales cambiaron, re-descargando...');
    await descargarLocalesDesdeSupabase();

    onLocalCambiado?.call();
    debugPrint('✅ [Realtime] Locales actualizados + callback disparado');
  } catch (e, stack) {
    ErrorService.captureError(
      e,
      stack: stack,
      hint: 'onLocalesCambiaronDesdeNube_fallo',
    );
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

 // ============================================================
// ACTUALIZAR ESTADO DE USUARIO → SUPABASE
// ============================================================
//
// Canal EXCLUSIVO para propagar cambios de `estado` a Supabase.
//
// Uso esperado desde la UI:
//   - Botón "Descanso"           → 'en_descanso'
//   - Botón "Volver de descanso" → 'activo'
//   - Botón "Conectar"           → 'activo'
//   - Al hacer logout            → 'desconectado'
//   - Al deshabilitar un usuario → 'inactivo'
//
// Devuelve `true` si la fila se actualizó (response no vacío).
// Si el `supabaseId` no existe en la BD, el update devuelve 0 filas
// y retorna `false` — pero NO lanza excepción.
//
// Notas:
//   - Prioriza `supabaseId` si viene. Fallback a `id_isar`.
//   - Actualiza también `updated_at` para que el LWW del sync
//     detecte el cambio como "nube más reciente" y no lo pise.
//
Future<void> sincronizarUsuariosASupabase() async {
  // ── Guard: sin sesión activa no hay tenant_id → RLS bloqueará ──
  if (!_tieneSesionSupabase()) {
    debugPrint(
        '⚠️ [SyncService] Sin sesión activa. sincronizarUsuariosASupabase omitido.');
    return;
  }

   // 🎯 FIX: activar guard anti-eco.
  _escribiendoUsuarios = true;

  try {
    final usuarios = await _isarService.obtenerUsuarios();
    if (usuarios.isEmpty) {
      debugPrint('ℹ️ No hay usuarios locales para sincronizar');
      return;
    }

    debugPrint('🔄 Sincronizando ${usuarios.length} usuarios con Supabase...');

    // ── Contadores para el log final ──
    int sincronizados = 0;
    int recuperados = 0;
    int omitidos = 0;
    int errores = 0;

    final currentUserId = _supabase.auth.currentUser?.id;

    for (var usuario in usuarios) {
      try {
        // ══════════════════════════════════════════════════════════
        // CASO 1: Ya tiene supabaseId → actualizar
        // ══════════════════════════════════════════════════════════
        if (usuario.supabaseId != null && usuario.supabaseId!.isNotEmpty) {
          final esUsuarioActual = usuario.supabaseId == currentUserId;

          // ── Lectura del estado actual en la nube ──
          Map<String, dynamic>? existing;
          try {
            existing = await _supabase
                .from('usuarios')
                .select('id, pin, updated_at, nombre, estado')
                .eq('id', usuario.supabaseId!)
                .maybeSingle();
          } catch (e) {
            debugPrint('⚠️ Error consultando usuario por ID: $e');
          }

          // ── Sub-caso: UUID no visible ──
          if (existing == null) {
            debugPrint(
                '⚠️ Usuario "${usuario.nombre}" no visible por ID '
                '(${usuario.supabaseId}). Intentando recovery por email...');

            if (usuario.email != null && usuario.email!.isNotEmpty) {
              try {
                final byEmail = await _supabase
                    .from('usuarios')
                    .select('id, pin, nombre, updated_at')
                    .eq('email', usuario.email!)
                    .maybeSingle();

                if (byEmail != null) {
                  final realUuid = byEmail['id'] as String;
                  final nombreNube =
                      (byEmail['nombre'] as String? ?? '').trim();

                  final yaEnUso = await _isarService
                      .obtenerUsuarioPorSupabaseId(realUuid);
                  final colisionaConOtro =
                      yaEnUso != null && yaEnUso.id != usuario.id;
                  final nombreCoincide = nombreNube.toLowerCase() ==
                      usuario.nombre.trim().toLowerCase();

                  if (colisionaConOtro || !nombreCoincide) {
                    debugPrint(
                        '⚠️ COLISIÓN para "${usuario.nombre}": el email '
                        '"${usuario.email}" pertenece a otro usuario. Skip.');
                    omitidos++;
                    continue;
                  }

                  usuario.supabaseId = realUuid;
                  await _isarService.guardarUsuario(usuario);

                  try {
                    await _supabase.from('usuarios').update({
                      'estado': usuario.estado,
                      'device_id': usuario.deviceId ?? '',
                    }).eq('id', realUuid);
                  } catch (_) {}

                  recuperados++;
                  sincronizados++;
                  continue;
                }
              } catch (e) {
                debugPrint('⚠️ Error buscando por email: $e');
              }
            }

            debugPrint(
                '🛡️ UUID de "${usuario.nombre}" preservado. Se intentará update directo.');
          }

          // ── Guard: last-write-wins por updated_at ──
          if (existing != null) {
            final remoteUpdatedAt = existing['updated_at'] != null
                ? DateTime.tryParse(existing['updated_at'].toString())
                : null;
            final localUpdatedAt = usuario.updatedAt;

            if (!esUsuarioActual &&
                remoteUpdatedAt != null &&
                localUpdatedAt != null &&
                localUpdatedAt.isBefore(remoteUpdatedAt) &&
                usuario.sincronizado) {
              debugPrint(
                  'ℹ️ "${usuario.nombre}" ya está al día (nube más reciente). Skip.');
              omitidos++;
              continue;
            }
          }

          // ── Resolver tenant del usuario ──
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
            debugPrint('⚠️ "${usuario.nombre}" sin tenant asignado. Skip.');
            omitidos++;
            continue;
          }

          // ══════════════════════════════════════════════════════════
          // PAYLOAD DE ACTUALIZACIÓN
          // ══════════════════════════════════════════════════════════
          // ⚠️ El campo `estado` NO se incluye aquí (se maneja aparte).
         final Map<String, dynamic> payload = {
            'nombre': usuario.nombre,
            'rol': usuario.rol,
            'email': usuario.email ?? '',
            'device_id': usuario.deviceId ?? '',
            'caja_asignada': usuario.cajaAsignada,
            'departamento': usuario.departamento,
            'tenant_id': tenantUuid,
            // 🎯 FIX Bug 10: NO enviamos `updated_at`.
            //    El trigger `update_updated_at_column` en Supabase lo
            //    setea con hora de servidor. Si lo mandamos desde el
            //    cliente, un reloj desincronizado rompe el LWW.
            // ⚠️ CONGELADO 2026-10-10: oto_url deja de subirse al
            // congelar la feature de fotos de empleados.
            //
            // Las fotos EXISTENTES siguen leyéndose con normalidad en
            // sincronizarUsuariosDesdeSupabase y en el mapeo de
            // fromSupabase. El objetivo es no crear fotos nuevas, no
            // borrar las viejas.
            //
            // 'foto_url': usuario.fotoUrl,
            //
            // Para reactivar: descomentar la línea de arriba. El comentario
            // del LWW se mantenía junto al campo.
          };

          // ── PIN ──
          final pinLocal = usuario.pin;
          final pinNube = existing != null ? existing['pin'] as String? : null;

          if (!usuario.sincronizado &&
              pinLocal.isNotEmpty &&
              pinLocal != pinNube) {
            payload['pin'] = pinLocal;
            debugPrint('📤 PIN actualizado para "${usuario.nombre}"');
          }

          // ── Update ──
          try {
            await _supabase
                .from('usuarios')
                .update(payload)
                .eq('id', usuario.supabaseId!);

            usuario.sincronizado = true;
            usuario.fechaSincronizacion = DateTime.now();
            usuario.updatedAt = DateTime.now();
            await _isarService.guardarUsuario(usuario);

            debugPrint('✅ "${usuario.nombre}" actualizado en Supabase');
            sincronizados++;
          } on AuthApiException catch (e) {
            debugPrint(
                '⚠️ Auth error al actualizar "${usuario.nombre}": ${e.message}');
            errores++;
          } on PostgrestException catch (e) {
            if (e.code == '42501') {
              debugPrint(
                  '⚠️ RLS bloqueó update de "${usuario.nombre}". UUID preservado.');
              omitidos++;
            } else {
              debugPrint(
                  '❌ PostgREST error para "${usuario.nombre}": ${e.message}');
              errores++;
            }
          }
          continue;
        }

        // ══════════════════════════════════════════════════════════
        // CASO 2: Sin supabaseId → crear (cajero: INSERT / admin: signUp)
        // ══════════════════════════════════════════════════════════

        // Sin email no podemos crear.
        if (usuario.email == null || usuario.email!.isEmpty) {
          debugPrint('⚠️ "${usuario.nombre}" sin email. Skip.');
          omitidos++;
          continue;
        }

        // 2a. ¿Existe ya en public.usuarios por email?
        final existingByEmail = await _supabase
            .from('usuarios')
            .select('id')
            .eq('email', usuario.email!)
            .maybeSingle();

        if (existingByEmail != null) {
          usuario.supabaseId = existingByEmail['id'] as String;
          usuario.sincronizado = true;
          usuario.fechaSincronizacion = DateTime.now();
          await _isarService.guardarUsuario(usuario);
          debugPrint(
              '✅ UUID recuperado para "${usuario.nombre}": ${usuario.supabaseId}');
          recuperados++;
          sincronizados++;
          continue;
        }

        // ── Resolver tenant para creación ──
        // (aquí es donde antes faltaba declarar `tenantId`)
        String? tenantId = usuario.tenantId;
        if (tenantId == null || tenantId.isEmpty) {
          final localActivo = await _isarService.obtenerLocalActivo();
          if (localActivo != null) {
            tenantId = localActivo.supabaseId;
            if (tenantId == null || tenantId.isEmpty) {
              tenantId = await _obtenerSupabaseIdLocal(localActivo.id);
            }
          }
        }
        if (tenantId == null || tenantId.isEmpty) {
          tenantId = getTenantIdFromJWT();
        }

        if (tenantId == null || tenantId.isEmpty) {
          debugPrint('⚠️ "${usuario.nombre}" sin tenant_id. Skip.');
          omitidos++;
          continue;
        }

        // ══════════════════════════════════════════════════════════
        // 🎯 Modelo A: solo los ADMIN van a auth.users.
        //    Los cajeros se insertan directamente en public.usuarios.
        // ══════════════════════════════════════════════════════════
        final esAdmin = usuario.rol == 'admin';

        if (esAdmin) {
          // ── ADMIN: signUp en auth.users ──
          if (usuario.password == null || usuario.password!.isEmpty) {
            debugPrint(
                '⚠️ Admin "${usuario.nombre}" sin password. No se puede crear en Auth. Skip.');
            omitidos++;
            continue;
          }

          try {
            final response = await _supabase.auth.signUp(
              email: usuario.email!,
              password: usuario.password!,
              data: {
                'nombre': usuario.nombre,
                'rol': usuario.rol,
                'pin': usuario.pin,
                'tenant_id': tenantId,
                'id_isar': usuario.id, // ← el trigger lo usará
              },
            );

            if (response.user != null) {
              usuario.supabaseId = response.user!.id;
              usuario.sincronizado = true;
              usuario.fechaSincronizacion = DateTime.now();
              await _isarService.guardarUsuario(usuario);
              debugPrint(
                  '✅ Admin "${usuario.nombre}" creado en auth.users (${usuario.supabaseId})');
              sincronizados++;
            } else {
              debugPrint(
                  '⚠️ Admin "${usuario.nombre}" response.user = null. Skip.');
              omitidos++;
            }
          } on AuthApiException catch (e) {
            final yaExiste = e.code == 'user_already_exists' ||
                e.statusCode == '422' ||
                e.message.toLowerCase().contains('already registered');

            if (yaExiste) {
              await Future.delayed(const Duration(milliseconds: 500));
              final retry = await _supabase
                  .from('usuarios')
                  .select('id')
                  .eq('email', usuario.email!)
                  .maybeSingle();
              if (retry != null) {
                usuario.supabaseId = retry['id'] as String;
                usuario.sincronizado = true;
                usuario.fechaSincronizacion = DateTime.now();
                await _isarService.guardarUsuario(usuario);
                debugPrint(
                    '✅ UUID recuperado tras 422 para "${usuario.nombre}"');
                recuperados++;
                sincronizados++;
              } else {
                debugPrint(
                    '❌ Admin "${usuario.nombre}" existe en auth pero no en public. Revisar trigger.');
                errores++;
              }
            } else {
              debugPrint(
                  '❌ Auth error para "${usuario.nombre}": ${e.message}');
              errores++;
            }
          } catch (e) {
            debugPrint(
                '❌ Error inesperado creando admin "${usuario.nombre}": $e');
            errores++;
          }
        } else {
          // ── CAJERO: INSERT directo en public.usuarios ──
          try {
            final payload = <String, dynamic>{
              'id_isar': usuario.id,
              'nombre': usuario.nombre,
              'rol': usuario.rol,
              'email': usuario.email,
              'pin': usuario.pin,
              'tenant_id': tenantId,
              'estado': _SyncConstants.desconectado,
              'caja_asignada': usuario.cajaAsignada,
              'device_id': usuario.deviceId ?? '',
              'updated_at': DateTime.now().toIso8601String(),
            };

            final response = await _supabase
                .from('usuarios')
                .insert(payload)
                .select('id')
                .single();

            usuario.supabaseId = response['id'] as String;
            usuario.sincronizado = true;
            usuario.fechaSincronizacion = DateTime.now();
            await _isarService.guardarUsuario(usuario);
            debugPrint(
                '✅ Cajero "${usuario.nombre}" insertado en public.usuarios (${usuario.supabaseId})');
            sincronizados++;
          } on PostgrestException catch (e) {
            // 23505 = unique_violation → recuperar
            if (e.code == '23505') {
              final retry = await _supabase
                  .from('usuarios')
                  .select('id')
                  .eq('email', usuario.email!)
                  .maybeSingle();
              if (retry != null) {
                usuario.supabaseId = retry['id'] as String;
                usuario.sincronizado = true;
                usuario.fechaSincronizacion = DateTime.now();
                await _isarService.guardarUsuario(usuario);
                debugPrint(
                    '✅ Cajero "${usuario.nombre}" recuperado tras 23505');
                recuperados++;
                sincronizados++;
              } else {
                debugPrint(
                    '❌ Conflicto no resuelto para cajero "${usuario.nombre}": ${e.message}');
                errores++;
              }
            } else {
              debugPrint(
                  '❌ Error insertando cajero "${usuario.nombre}": ${e.message} (${e.code})');
              errores++;
            }
          } catch (e) {
            debugPrint(
                '❌ Error inesperado creando cajero "${usuario.nombre}": $e');
            errores++;
          }
        }
      } catch (e, stack) {
        // Catch externo: un fallo en un usuario NO debe detener el loop.
        debugPrint('⚠️ Error procesando "${usuario.nombre}": $e');
        errores++;
        ErrorService.captureError(e,
            stack: stack, hint: 'sincronizarUsuario_individual_fallo');
      }
    }

    debugPrint(
        '✅ Usuarios: $sincronizados sync · $recuperados UUIDs · $omitidos omitidos · $errores errores');
    onDataChanged?.call();
  } catch (e, stack) {
    debugPrint('❌ Error general sincronizando usuarios: $e');
    ErrorService.captureError(e,
        stack: stack, hint: 'sincronizarUsuariosASupabase_fallo');
        } finally {
    // 🎯 FIX: siempre desactivar el guard.
    _escribiendoUsuarios = false;
  }
}
  /// Limpia SOLO los huérfanos verdaderos de `public.usuarios`:
///   - Sin `id_isar` (o id_isar = 0)
///   - NO es el usuario autenticado actual
///   - NO tiene contraparte válida en auth.users
///
/// Antes se borraba cualquier row con id_isar null, lo cual podía
/// eliminar usuarios creados desde el Supabase Dashboard (que aún no
/// se han vinculado a un Isar local).
Future<int> limpiarUsuariosHuerfanosEnSupabase() async {
  try {
    final currentUuid = _supabase.auth.currentUser?.id;

    final huerfanos = await _supabase
        .from('usuarios')
        .select('id, nombre, email')
        .or('id_isar.is.null,id_isar.eq.0');

    if (huerfanos.isEmpty) {
      debugPrint('✅ No hay usuarios huérfanos en Supabase');
      return 0;
    }

    debugPrint(
        '🧹 Analizando ${huerfanos.length} candidatos a huérfanos...');

    int eliminados = 0;
    int conservados = 0;

    for (final huerfano in huerfanos) {
      final uuid = huerfano['id'] as String?;
      final nombre = huerfano['nombre'] ?? 'sin nombre';

      if (uuid == null) continue;

      // ✅ Nunca borrar el usuario autenticado actual
      if (uuid == currentUuid) {
        debugPrint('🛡️ Conservando usuario actual: "$nombre" ($uuid)');
        conservados++;
        continue;
      }

      // ✅ Verificar si existe en auth.users
      bool existeEnAuth = false;
      try {
        final authUser =
            await _supabase.auth.admin.getUserById(uuid);
        existeEnAuth = authUser.user != null;
      } catch (_) {
        // Si el admin API falla, asumimos que NO existe para no borrar de más
        existeEnAuth = false;
      }

      if (existeEnAuth) {
        debugPrint('🛡️ Conservando "$nombre" (existe en auth.users)');
        conservados++;
        continue;
      }

      // ✅ Es un huérfano verdadero → borrar
      try {
        await _supabase.from('usuarios').delete().eq('id', uuid);
        eliminados++;
        debugPrint('🗑️ Huérfano eliminado: "$nombre" ($uuid)');
      } catch (e) {
        debugPrint('⚠️ No se pudo eliminar "$nombre": $e');
      }
    }

    debugPrint(
        '✅ Limpieza: $eliminados eliminados · $conservados conservados');
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
    // ⚠️ Filtro por tenant OBLIGATORIO (patrón de lotes, :3882). A secas,
    // si el JWT es de super admin las policies se ORean y el dispositivo
    // baja usuarios de TODOS los tenants (incidente AGENTS §7.4).
    final localActivo = await _isarService.obtenerLocalActivo();
    final tenantUuid = localActivo?.supabaseId;
    if (tenantUuid == null || tenantUuid.isEmpty) {
      debugPrint('⚠️ [SyncService] Sin local activo. '
          'Descarga de usuarios omitida (no se puede filtrar por tenant).');
      return;
    }

    final response = await _supabase
        .from('usuarios')
        .select()
        .eq('tenant_id', tenantUuid)
        .order('nombre', ascending: true);

    if (response.isEmpty) {
      debugPrint('ℹ️ No hay usuarios en Supabase para descargar');
      return;
    }

    debugPrint('🔄 Descargando ${response.length} usuarios desde Supabase...');

    final currentUid = _supabase.auth.currentUser?.id;

    final locales = await _isarService.obtenerUsuarios();
    final Map<int, UsuarioEntity> localesMap = {
      for (var u in locales) u.id: u,
    };

    int usuariosActualizados = 0;
    int usuariosCreados = 0;
    int usuariosSinCambios = 0;

    for (var data in response) {
      final idIsar = _toInt(data['id_isar']);
      if (idIsar == 0) {
        debugPrint('⚠️ Usuario sin id_isar, omitiendo: ${data['nombre']}');
        continue;
      }

      final String? tenantUuid = data['tenant_id'] as String?;
      int? localIdResuelto;
      if (tenantUuid != null && tenantUuid.isNotEmpty) {
        localIdResuelto = await _obtenerIsarIdLocal(tenantUuid);
      }

      final local = localesMap[idIsar];

      // ═══════════════════════════════════════════════════════════════
      // USUARIO EXISTENTE → actualizar campos con dirty tracking
      // ═══════════════════════════════════════════════════════════════
      if (local != null) {
        bool dirty = false;

        // ── Campos básicos ──
        final nuevoSupabaseId = data['id'] as String?;
        if (nuevoSupabaseId != null &&
            nuevoSupabaseId.isNotEmpty &&
            nuevoSupabaseId != local.supabaseId) {
          local.supabaseId = nuevoSupabaseId;
          dirty = true;
        }

        final nuevoEmail = data['email'] as String?;
        if (nuevoEmail != null && nuevoEmail != local.email) {
          local.email = nuevoEmail;
          dirty = true;
        }

        // 🎯 is_superadmin es SERVER-AUTHORITATIVE.
        // Regla: si Supabase dice true, aplicamos true.
        // NUNCA lo bajamos a false desde el sync, NUNCA lo subimos al servidor.
        // Si el registro local queda actualizado, persistirlo SIN marcar dirty.
        if (data['is_superadmin'] == true && local.isSuperadmin != true) {
          local.isSuperadmin = true;
          // Persistir SOLO este cambio sin disparar push.
          final isar = await _isarService.db;
          await isar.writeTxn(() => isar.usuarioEntitys.put(local));
        }

        final nuevoNombre = data['nombre'] as String?;
        if (nuevoNombre != null &&
            nuevoNombre.isNotEmpty &&
            nuevoNombre != local.nombre) {
          local.nombre = nuevoNombre;
          dirty = true;
        }

        final nuevoDeviceId = data['device_id'] as String?;
        if (nuevoDeviceId != null && nuevoDeviceId != local.deviceId) {
          local.deviceId = nuevoDeviceId;
          dirty = true;
        }

        final nuevaCaja = data['caja_asignada'] as String?;
        if (nuevaCaja != null && nuevaCaja != local.cajaAsignada) {
          local.cajaAsignada = nuevaCaja;
          dirty = true;
        }

        final nuevoDepto = data['departamento'] as String?;
        if (nuevoDepto != local.departamento) {
          local.departamento = nuevoDepto;
          dirty = true;
        }

        final nuevoRol = data['rol'] as String?;
        if (nuevoRol != null && nuevoRol != local.rol) {
          local.rol = nuevoRol;
          dirty = true;
        }

        // ── Foto URL ──
        // 🎯 FIX: solo actualizar y loggear si la URL cambió realmente.
        //    Sin este check, el log se spamea en cada ciclo del monitor
        //    (cada 8-15s) aunque nada haya cambiado.
        final fotoUrlNube = data['foto_url'] as String?;
        if (fotoUrlNube != null &&
            fotoUrlNube.isNotEmpty &&
            fotoUrlNube != local.fotoUrl) {
          local.fotoUrl = fotoUrlNube;
          dirty = true;
          debugPrint('🖼️ fotoUrl actualizada desde nube: $fotoUrlNube');
        }

        // ── PIN protegido si hay cambios pendientes ──
        final pinNube = data['pin'] as String?;
        if (pinNube != null &&
            pinNube.isNotEmpty &&
            pinNube != local.pin) {
          if (local.sincronizado) {
            local.pin = pinNube;
            dirty = true;
          } else {
            debugPrint(
                '🛡️ PIN local de "${local.nombre}" protegido '
                '(pendiente de sync a la nube)');
          }
        }

        // ── Tenant / Local ──
        if (tenantUuid != null &&
            tenantUuid.isNotEmpty &&
            tenantUuid != local.tenantId) {
          local.tenantId = tenantUuid;
          dirty = true;
        }
        if (localIdResuelto != null && localIdResuelto != local.localId) {
          local.localId = localIdResuelto;
          dirty = true;
        }

        // ── Descanso ──
        final nuevoInicioDescanso = data['inicio_descanso'] != null
          ? DateTime.tryParse(data['inicio_descanso'].toString())
          : null;
      if (_timestampsDifieren(nuevoInicioDescanso, local.inicioDescanso)) {
        local.inicioDescanso = nuevoInicioDescanso;
        dirty = true;
      }

        final nuevosMinutosDescanso =
            _toInt(data['minutos_descanso'], local.minutosDescanso ?? 0);
        if (nuevosMinutosDescanso != local.minutosDescanso) {
          local.minutosDescanso = nuevosMinutosDescanso;
          dirty = true;
        }

        // ── Actividad ──
       

        // ultima_actividad
        if (data['ultima_actividad'] != null) {
          final nuevaUltima = DateTime.tryParse(data['ultima_actividad'].toString());
          if (_timestampsDifieren(nuevaUltima, local.ultimaActividad)) {
            local.ultimaActividad = nuevaUltima;
            dirty = true;
          }
        }

        // ultimaActualizacion
        if (data['ultimaActualizacion'] != null) {
          final nuevaUltima =
              DateTime.tryParse(data['ultimaActualizacion'].toString());
          if (_timestampsDifieren(nuevaUltima, local.ultimaActualizacion)) {
            local.ultimaActualizacion = nuevaUltima;
            dirty = true;
          }
        }

        // ── Estado ──
        final estadoNube = data['estado'] as String?;
        if (estadoNube != null &&
            estadoNube.isNotEmpty &&
            estadoNube != local.estado) {
          local.estado = estadoNube;
          local.activo =
              estadoNube != _SyncConstants.inactivo && estadoNube != _SyncConstants.desconectado;
          dirty = true;
        }

        // ═══════════════════════════════════════════════════════════════
        // 🧹 AUTO-CLEANUP: usuarios fantasma activos
        //
        // Si un usuario que NO es el actual sigue marcado como `activo`
        // en la nube pero su `ultimaActividad` es vieja (> 4h), lo
        // forzamos a inactivo. Esto limpia el residuo de crashes sin
        // logout y evita que el monitor muestre activos a usuarios
        // que llevan horas sin tocar la caja.
        // ═══════════════════════════════════════════════════════════════
        if (estadoNube == _SyncConstants.activo &&
            local.supabaseId != null &&
            local.supabaseId != currentUid) {
          final ultima = local.ultimaActividad ?? local.updatedAt;
          final esViejo = ultima == null ||
              DateTime.now().difference(ultima).inHours >= 4;

          if (esViejo) {
            try {
              await _supabase
                  .from('usuarios')
                  .update({'estado': _SyncConstants.inactivo})
                  .eq('id', local.supabaseId!);
              local.estado = _SyncConstants.inactivo;
              local.activo = false;
              local.sincronizado = false; // forzar resync
              dirty = true;
              debugPrint(
                  '🧹 "${local.nombre}" llevaba activo desde '
                  '${ultima?.toIso8601String() ?? "?"} → forzado a inactivo');
            } catch (e) {
              debugPrint(
                  '⚠️ No se pudo limpiar usuario fantasma "${local.nombre}": $e');
            }
          }
        }

        // ── Timestamps ──
        final creadoRaw = data['creado_en'] ?? data['created_at'];
        if (creadoRaw != null) {
        final nuevoCreatedAt = DateTime.tryParse(creadoRaw.toString());
        if (_timestampsDifieren(nuevoCreatedAt, local.createdAt)) {
          local.createdAt = nuevoCreatedAt;
          dirty = true;
        }}
        if (data['updated_at'] != null) {
        final nuevoUpdatedAt =
            DateTime.tryParse(data['updated_at'].toString());
        if (_timestampsDifieren(nuevoUpdatedAt, local.updatedAt)) {
          local.updatedAt = nuevoUpdatedAt;
          dirty = true;
        }
      }

        // ── Persistir SOLO si algo cambió ──
        if (dirty) {
         local.fechaSincronizacion = DateTime.now();
        await _isarService.guardarUsuario(local);
        usuariosActualizados++;
        }
      } else {
        // ═══════════════════════════════════════════════════════════════
        // USUARIO NUEVO → crear desde Supabase
        // ═══════════════════════════════════════════════════════════════
        final nuevoUsuario = UsuarioEntity()
          ..id = idIsar
          ..nombre = data['nombre'] as String? ?? ''
          ..pin = data['pin'] as String? ?? ''
          ..rol = data['rol'] as String? ?? 'cajero'
          ..activo = true
          ..estado = data['estado'] as String? ?? _SyncConstants.inactivo
          ..cajaAsignada =
              data['caja_asignada'] as String? ?? 'Caja Principal'
          ..email = data['email'] as String?
          ..deviceId = data['device_id'] as String? ?? ''
          ..departamento = data['departamento'] as String?
          ..supabaseId = data['id'] as String?
          ..fotoUrl = data['foto_url'] as String?
          // 🎯 FIX: mapear is_superadmin para el Control Center.
          ..isSuperadmin = data['is_superadmin'] as bool? ?? false
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
        usuariosCreados++;
      }
    }

    // 🎯 Log resumido: solo mostrar cuántos cambiaron realmente.
    debugPrint(
        '✅ Usuarios: $usuariosCreados nuevos · '
        '$usuariosActualizados actualizados · '
        '$usuariosSinCambios sin cambios');

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
      // Filtro por tenant obligatorio (ver :884).
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Lectura de usuarios omitida (no se puede filtrar por tenant).');
        return [];
      }
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('tenant_id', tenantUuid)
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
  int userIdIsar,
  String nuevoEstado, {
  String? supabaseId,
}) async {
  try {
    final payload = {
      'estado': nuevoEstado,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final List<dynamic> response;

    if (supabaseId != null && supabaseId.isNotEmpty) {
      response = await _supabase
          .from('usuarios')
          .update(payload)
          .eq('id', supabaseId)
          .select();
    } else {
      response = await _supabase
          .from('usuarios')
          .update(payload)
          .eq('id_isar', userIdIsar)
          .select();
    }

    return response.isNotEmpty;
  } catch (e, stack) {
    debugPrint('❌ Error actualizando estado usuario: $e');
    ErrorService.captureError(e,
        stack: stack,
        hint: 'actualizarEstadoUsuarioEnSupabase_fallo',
        extras: {'userIdIsar': userIdIsar, 'nuevoEstado': nuevoEstado});
    return false;
  }
}

/// Elimina un usuario en Supabase.
///
/// Si se pasa `supabaseId`, prioriza UUID. Si no, fallback a `id_isar`.
Future<bool> eliminarUsuarioEnSupabase(
  int userIdIsar, {
  String? supabaseId,
}) async {
  try {
    // 🛠️ FIX: Null safety - proteger evaluación de respuesta
    final List<dynamic> response;

    if (supabaseId != null && supabaseId.isNotEmpty) {
      response = await _supabase
          .from('usuarios')
          .delete()
          .eq('id', supabaseId)
          .select();
    } else {
      response = await _supabase
          .from('usuarios')
          .delete()
          .eq('id_isar', userIdIsar)
          .select();
    }

    // 🛠️ FIX: Verificar que response no sea null y tenga elementos
    return response.isNotEmpty;
  } on PostgrestException catch (e) {
    // 🛠️ FIX: Manejar errores RLS específicamente
    if (e.code == '42501') {
      debugPrint('⚠️ RLS bloqueó eliminación de usuario (políticas de seguridad)');
    } else {
      debugPrint('❌ Error PostgREST eliminando usuario: ${e.message}');
    }
    return false;
  } catch (e, stack) {
    debugPrint('❌ Error eliminando usuario en Supabase: $e');
    ErrorService.captureError(e,
        stack: stack,
        hint: 'eliminarUsuarioEnSupabase_fallo',
        extras: {'userIdIsar': userIdIsar});
    return false;
  }

}
/// Sube los usuarios marcados como NO sincronizados.
///
/// Ahora reusa el flujo completo (`sincronizarUsuariosASupabase`),
/// en vez de solo actualizar `pin`. Así también sube nombre, rol,
/// caja, estado, etc.
Future<void> subirUsuariosPendientes() async {
  if (!await _tieneSesionSupabaseValida()) {
    debugPrint('⚠️ Sin sesión válida. subirUsuariosPendientes omitido.');
    return;
  }

  final pendientes = await _isarService.obtenerUsuariosNoSincronizados();
  if (pendientes.isEmpty) {
    debugPrint('ℹ️ No hay usuarios pendientes de subir');
    return;
  }

  debugPrint('🔄 Subiendo ${pendientes.length} usuarios pendientes...');
  await sincronizarUsuariosASupabase();
}

 Stream<List<UsuarioEntity>> streamUsuariosEnTiempoReal() {
  return _supabase.from('usuarios').stream(primaryKey: ['id']).map((data) {
    return data.map<UsuarioEntity>((row) {
      return UsuarioEntity()
        ..id = _toInt(row['id_isar']) // ✅ ya no castea directo
        ..nombre = row['nombre'] as String? ?? ''
        ..rol = row['rol'] as String? ?? 'cajero'
        ..estado = row['estado'] as String? ?? _SyncConstants.inactivo
        ..deviceId = row['device_id'] as String? ?? ''
        ..supabaseId = row['id'] as String?;
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
          'sync_status': _SyncConstants.synced,
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
      // Filtro por tenant obligatorio (ver :3882 patrón lotes).
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de proveedores omitida (no se puede filtrar por tenant).');
        return;
      }
      final response = await _supabase
          .from('proveedores')
          .select()
          .eq('tenant_id', tenantUuid)
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

      // 🛠️ FIX: Batching - construir lista para upsert masivo
      final List<Map<String, dynamic>> payloads = [];
      final List<ProductoEntity> productosParaActualizar = [];

      for (final p in productosLocales) {
        final nuevoUuid = p.supabaseId ?? const Uuid().v4();

        // ⚠️ Barcode único para productos sin código.
        // `productos.codigo_barras` es NOT NULL y hay UNIQUE
        // (tenant_id, codigo_barras). Si 2+ productos del mismo tenant
        // tienen barcode vacío, el insert falla con 23505. Generamos un
        // código estable derivado del UUID (o del id local si aún no
        // tiene UUID), con el mismo patrón que el guard local de
        // `isar_service.dart` (`AUTO-...` / `SB-...`).
        final codigoParaSupabase = p.codigoBarras.trim().isEmpty
            ? (p.supabaseId != null && p.supabaseId!.isNotEmpty
                ? 'SB-$nuevoUuid'
                : 'AUTO-${p.id}')
            : p.codigoBarras;
        final payload = <String, dynamic>{
          'uuid': nuevoUuid,
          'id_isar': p.id,
          'codigo_barras': codigoParaSupabase,
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
          payload['imagen_url'] = p.imagenUrl;
        }
        payloads.add(payload);
        productosParaActualizar.add(p);
      }

      // ── Separar por lotes: nuevos (INSERT) vs existentes (UPDATE) ──
      // El upsert masivo con `onConflict: 'uuid'` intentaba escribir
      // `id_isar` como parte del `DO UPDATE SET`. Eso violaba la FK
      // `fk_detalles_pedido_producto_id_isar` (ON DELETE NO ACTION) en
      // cuanto un producto ya referenciado cambiaba su `id_isar`.
      //
      // Además, productos ya existentes en Supabase (con `supabaseId`)
      // nunca deben tocar `id_isar`: ese campo es inmutable una vez
      // asignado, porque `detalles_pedido.producto_id_isar` lo referencia.
      //
      // Estrategia: los que ya tienen `supabaseId` van por UPDATE
      // (excluyendo `id_isar`). Los nuevos van por INSERT con `id_isar`.
      final nuevos = <Map<String, dynamic>>[];
      final existentes = <Map<String, dynamic>>[];

      for (final payload in payloads) {
        if (payload['uuid'] != null &&
            productosLocales
                .any((p) => p.supabaseId == payload['uuid'])) {
          // Excluir id_isar del payload de update.
          final sinIdIsar = Map<String, dynamic>.from(payload)
            ..remove('id_isar');
          existentes.add(sinIdIsar);
        } else {
          nuevos.add(payload);
        }
      }

      // Inserts masivos (productos nuevos, sin uuid en Supabase).
      if (nuevos.isNotEmpty) {
        try {
          await _supabase.from('productos').insert(nuevos);
          debugPrint('✅ ${nuevos.length} productos insertados');
        } catch (e) {
          debugPrint('⚠️ Error insertando nuevos: $e');
        }
      }

      // Updates masivos en 1 request.
      // ⚠️ Estos payloads NO llevan `id_isar` (fue excluido arriba),
      // así que `ON CONFLICT (uuid) DO UPDATE` no puede violar la FK
      // `fk_detalles_pedido_producto_id_isar`.
      //
      // El `BEFORE INSERT` trigger `productos_autoreasignar_id_isar()`
      // cubre el `id_isar` ausente durante el intento de INSERT (evita
      // el NOT NULL). En la ruta `DO UPDATE` ese trigger no se dispara,
      // y como `id_isar` no está en el SET, la columna queda intacta.
      if (existentes.isNotEmpty) {
        try {
          await _supabase
              .from('productos')
              .upsert(existentes, onConflict: 'uuid');
          debugPrint('✅ ${existentes.length} productos actualizados');
        } catch (e) {
          debugPrint('⚠️ Error en batch update: $e');
        }
      }

      // 🛠️ FIX: Batching - actualizar Isar en transacción masiva
      final isar = await _isarService.db;
      final ahora = DateTime.now();
      await isar.writeTxn(() async {
        for (var p in productosParaActualizar) {
          p.supabaseId = p.supabaseId ?? const Uuid().v4();
          p.sincronizado = true;
          p.fechaSincronizacion = ahora;
          await isar.productoEntitys.put(p);
        }
      });
      debugPrint('✅ ${productosParaActualizar.length} productos actualizados en Isar');
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
      // Filtro por tenant obligatorio (ver :3882 patrón lotes).
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de productos omitida (no se puede filtrar por tenant).');
        return;
      }
      final response = await _supabase
          .from('productos')
          .select()
          .eq('tenant_id', tenantUuid)
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

      // 🛠️ FIX: Batching - acumular registros para transacción masiva
      final List<ProductoEntity> productosParaGuardar = [];
      final List<int> idsParaEliminar = [];

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
          // ⚠️ NO se toma `stock` de la nube. Con el modelo "lotes = fuente
          // única de verdad", `producto.stock` es un cache derivado que se
          // recalcula con `IsarService.recalcularStockDe` DESPUÉS de
          // descargar los lotes. Tomarlo de la nube reintroducía el
          // conflicto de las dos verdades.
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
          // Se preserva el stock local: no viene de la nube (ver arriba).
          // Un producto nuevo de la nube queda en 0 hasta que se
          // descarguen sus lotes y corra el recálculo.
          productoNube.stock = productoLocal.stock;
        }
        productosParaGuardar.add(productoNube);
      }

      // 🛠️ FIX: Transacción masiva para guardar productos
      final isar = await _isarService.db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.putAll(productosParaGuardar);
      });
      debugPrint('✅ ${productosParaGuardar.length} productos guardados en lote');

      // 🛠️ Transacción masiva para eliminar productos.
      //
      // ⚠️ NO borrar productos cuyo `codigoBarras` fue GENERADO por el guard de
      // `isar_service.dart:887-893`. Ese guard deriva una clave única
      // (`SB-<supabaseId>` o `AUTO-<epoch>-<hash>`) cuando el producto llega
      // con el código vacío. Ese código es local por definición: nunca se sube
      // a la nube, así que NUNCA estará en `codigosEnNube`, y el filtro "no está
      // en la nube" lo destruía en CADA pasada de sync. Con esos productos en
      // la base, cualquier producto real que se borrara de la nube tarde o
      // temprano se traía de vuelta con todos sus ajustes de stock.
      //
      // Son códigos legítimos; se conservan.
      int eliminados = 0;
      int preservadosPorCodigoGenerado = 0;
      for (var producto in productosLocales) {
        final cb = producto.codigoBarras;
        final esCodigoGenerado =
            cb.startsWith('AUTO-') || cb.startsWith('SB-');
        if (esCodigoGenerado) {
          preservadosPorCodigoGenerado++;
          continue;
        }
        if (!codigosEnNube.contains(cb)) {
          idsParaEliminar.add(producto.id);
          eliminados++;
        }
      }
      if (preservadosPorCodigoGenerado > 0) {
        debugPrint(
            '🔒 $preservadosPorCodigoGenerado productos preservados '
            '(código generado localmente)');
      }
      if (idsParaEliminar.isNotEmpty) {
        await isar.writeTxn(() async {
          await isar.productoEntitys.deleteAll(idsParaEliminar);
        });
        debugPrint('🗑️ $eliminados productos eliminados en lote');
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
    // ⚠️ Este método NO toca `_isSyncing`. Es un paso interno de
    // `sincronizarTodo()`, que es el único dueño del lock. Antes tenía
    // su propia guarda + set/finally, lo que causaba 2 bugs:
    //   1. Como `sincronizarTodo` ya ponía `_isSyncing = true`, la
    //      guarda convertía este método en un no-op silencioso
    //      (ventas/gastos/turnos nunca se sincronizaban).
    //   2. Al liberar el flag en su propio `finally`, dejaba al padre
    //      sin lock durante los módulos restantes → despertaba los
    //      guards anti-eco de Realtime (:204/:230).
    int ventasSincronizadas = 0;

    try {
      final pendientes = await _isarService.obtenerVentasPendientesSync();
      if (pendientes.isEmpty) {
        return 0;
      }

      debugPrint(
          '🔄 [SyncService] Sincronizando ${pendientes.length} ventas...');

      for (var venta in pendientes) {
        try {
          final exito = await _enviarVentaAlServidor(venta);
          if (exito) {
            await _isarService.actualizarSyncStatusVenta(venta.id, _SyncConstants.synced);
            ventasSincronizadas++;
          } else {
            await _isarService.actualizarSyncStatusVenta(venta.id, _SyncConstants.failed);
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
          await _isarService.actualizarSyncStatusVenta(venta.id, _SyncConstants.failed);
        }
      }
    } catch (e, stack) {
      debugPrint('❌ [SyncService] Error general durante la sincronización: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarVentasPendientes_fallo');
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

      // INVARIANTE: tras el `if` de arriba, `idSupabase` es no-null y no vacío.
      // Se materializa en una variable local para no repetir el `!` en cada
      // uso; antes el `!` de `obtenerDetallesPorVenta` dependía de que nadie
      // tocara `idSupabase` entre el `if` y esa línea.
      final uuidVenta = venta.idSupabase!;

      final payload = _ventaToJson(venta);
      payload['sync_status'] = _SyncConstants.synced;

      // 🔥 Obtener los detalles de la venta desde la base de datos usando el UUID
      final detalles =
          await _isarService.obtenerDetallesPorVenta(uuidVenta);
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

      // 🔥 Insertar venta + detalles en 1 RPC atómico.
      // Antes eran 2 round-trips separados (insert ventas + insert
      // detalle_ventas) sin transacción: si el 2º fallaba, quedaba una
      // venta huérfana.
      // El RPC hace UPSERT + DELETE-then-INSERT + INSERT en una sola
      // transacción PL/pgSQL. Ver migración
      // `supabase/migrations/20261009000000_sync_venta_completa.sql`.
      final itemsPayload = detalles.map((item) {
        if (item.ventaIdFk == null || item.ventaIdFk!.isEmpty) {
          item.ventaIdFk = venta.idSupabase;
        }
        return _detalleToJson(item);
      }).toList();

      await _supabase.rpc('sync_venta_completa', params: {
        'p_venta': payload,
        'p_detalles': itemsPayload,
      });

      debugPrint(
          '✅ Venta ${venta.idSupabase} sincronizada vía RPC '
          '(${itemsPayload.length} detalles)');
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
    'numero_factura': venta.numeroFactura,
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
      'sync_status': _SyncConstants.synced, // ✅ NUEVO
    };
  }

  Future<void> descargarVentasDesdeSupabase() async {
    try {
      // Filtro por tenant obligatorio (ver :3882 patrón lotes). Las ventas
      // son el dato más sensible del tenant: a secas, un JWT de super
      // admin bajaba las de TODOS los comercios al dispositivo.
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de ventas omitida (no se puede filtrar por tenant).');
        return;
      }
      final response = await _supabase
          .from('ventas')
          .select()
          .eq('tenant_id', tenantUuid)
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

        // 🔥 Consulta con 'venta_id_tk' (columna renombrada). El filtro
        // de tenant es defensivo: la venta ya venía filtrada, pero la
        // columna existe y cuesta nada.
        final detallesResponse = await _supabase
            .from('detalle_ventas')
            .select()
            .eq('tenant_id', tenantUuid)
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
      // `documento` es el doc del cliente; la numeración fiscal va en su
      // propio campo (`numero_factura`, texto). Nullable: las ventas
      // anteriores a la migración 20261012000003 llegan sin él.
      ..numeroFactura = data['numero_factura'] as String?
          ..empleado = data['empleado_nombre'] ?? data['empleado'] ?? ''
          ..syncStatus = _SyncConstants.synced
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
            await _isarService.actualizarSyncStatusPagoVenta(pago.id, _SyncConstants.failed);
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
            await _isarService.actualizarSyncStatusPagoVenta(pago.id, _SyncConstants.failed);
            continue;
          }

          final payload = pago.toSupabaseJson();
          payload['venta_id'] = pago.ventaSupabaseId;
          payload['sync_status'] = _SyncConstants.synced;

          // ✅ Si tenant_id es null, quitarlo para que la DB use su default
          if (payload['tenant_id'] == null) {
            payload.remove('tenant_id');
          }

          await _supabase
              .from('pagos_ventas')
              .upsert(payload, onConflict: 'id')
              .select('id')
              .maybeSingle();

          await _isarService.actualizarSyncStatusPagoVenta(pago.id, _SyncConstants.synced);
          sincronizados++;
        } catch (e, stack) {
          debugPrint('❌ Error sincronizando pago ${pago.id}: $e');
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarPagoVenta_individual_fallo',
              extras: {'pagoId': pago.id});
          await _isarService.actualizarSyncStatusPagoVenta(pago.id, _SyncConstants.failed);
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
              autz.id, _SyncConstants.synced);
          sincronizadas++;
        } catch (e, stack) {
          debugPrint('❌ Error sincronizando autorización ${autz.id}: $e');
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarAutorizacion_individual_fallo',
              extras: {'autzId': autz.id});
          await _isarService.actualizarSyncStatusAutorizacion(
              autz.id, _SyncConstants.failed);
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
            await _isarService.actualizarSyncStatusMovimiento(mov.id, _SyncConstants.synced);
            sincronizados++;
          } else {
            await _isarService.actualizarSyncStatusMovimiento(mov.id, _SyncConstants.failed);
            debugPrint('⚠️ Movimiento ${mov.id} marcado como failed');
          }
        } catch (e, stack) {
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarMovimiento_individual_fallo',
              extras: {'movimientoId': mov.id});
          await _isarService.actualizarSyncStatusMovimiento(mov.id, _SyncConstants.failed);
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
      // ajustar_stock(p_producto_uuid uuid, p_cantidad numeric, p_tipo_movimiento text)
      try {
        final rpcResponse = await _supabase.rpc(
          // ⚠️ Nombre único (no `ajustar_stock`) porque había 2 overloads con
          // el mismo nombre y misma aridad. PostgREST elegía la bigint primero
          // y devolvía FALSE sin encontrar producto. La firma renombrada deja
          // la resolución sin ambigüedad.
          'ajustar_stock_uuid',
          params: {
            // ⚠️ Pasar el UUID, no el ID de Isar. La firma antigua
            // `(bigint, integer, text)` recibía `mov.productoId` (isar),
            // que no coincide con `productos.id` de Supabase (secuencia
            // propia). El RPC devolvía false siempre y, si los IDs
            // coincidían por accidente, ajustaba el producto equivocado.
            // La firma nueva usa `productos.uuid`, estable cross-machine.
            'p_producto_uuid': productoUuid,
            // ⚠️ Sin `.toInt()`: la firma es `numeric`. Truncar aquí
            // mandaba 0.5 kg como 0 y el RPC no descontaba nada pero
            // devolvía TRUE. Ver migración
            // `20261009000004_ajustar_stock_numeric.sql`.
            'p_cantidad': mov.cantidad,
            'p_tipo_movimiento': mov.tipoMovimiento,
          },
        );
        if (rpcResponse == true) {
          await _insertarMovimientoDirecto(mov);
          debugPrint('✅ Movimiento ${mov.id} sincronizado vía RPC');
          return true;
        }
        debugPrint('⚠️ RPC ajustar_stock_uuid devolvió false, cayendo a directo');
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
      'sync_status': _SyncConstants.synced,
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
          categoria.syncStatus = _SyncConstants.synced;
          await _isarService.guardarCategoria(categoria);
          sincronizadas++;
        } catch (e) {
          categoria.syncStatus = _SyncConstants.failed;
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
            existente.syncStatus = _SyncConstants.synced;
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
            await _isarService.actualizarSyncStatusMarca(marca.id, _SyncConstants.synced);
            sincronizadas++;
            debugPrint('✅ Marca ${marca.nombre} sincronizada');
          } else {
            await _isarService.actualizarSyncStatusMarca(marca.id, _SyncConstants.failed);
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
      // 🎯 FIX Bug 6: validar que sea un UUID REAL, no solo no-vacío.
      //    Antes, si `supabaseId` ya contenía un timestamp tipo
      //    "1790482577151", `isEmpty` daba false, no se regeneraba y
      //    PostgREST respondía 22P02 (invalid input syntax for type uuid).
      final String? actual = marca.supabaseId;
      if (actual == null || actual.isEmpty || !_esUuid(actual)) {
        debugPrint(
            '🔧 Marca "${marca.nombre}" con UUID inválido ($actual). '
            'Regenerando...');
        marca.supabaseId = const Uuid().v4();

        // Persistir el UUID corregido en Isar para que no se regenere
        // en cada ciclo de sync.
        final isar = await _isarService.db;
        await isar.writeTxn(() async {
          await isar.marcaEntitys.put(marca);
        });
      }

      final data = {
        'id': marca.supabaseId,
        'nombre': marca.nombre,
        'descripcion': marca.descripcion,
        'logo_url': marca.logoPath,
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
      // Filtro por tenant obligatorio (ver :3882 patrón lotes).
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de marcas omitida (no se puede filtrar por tenant).');
        return;
      }
      final response = await _supabase
          .from('marcas')
          .select()
          .eq('tenant_id', tenantUuid)
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
              local.logoPath != marcaNube.logoPath ||
              local.proveedorId != marcaNube.proveedorId ||
              local.activo != marcaNube.activo) {
            local.nombre = marcaNube.nombre;
            local.descripcion = marcaNube.descripcion;
            local.logoPath = marcaNube.logoPath;
            local.proveedorId = marcaNube.proveedorId;
            local.activo = marcaNube.activo;
            local.updatedAt = DateTime.now();
            local.syncStatus = _SyncConstants.synced;
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
      // Filtro por tenant obligatorio (ver :3882 patrón lotes).
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de gastos omitida (no se puede filtrar por tenant).');
        return;
      }
      final response = await _supabase
          .from('gastos')
          .select()
          .eq('tenant_id', tenantUuid)
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
          ..syncStatus = _SyncConstants.synced;

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
    // ⚠️ Este método NO toca `_isSyncing`. Es un paso interno de
    // `sincronizarTodo()`, que es el único dueño del lock. Antes tenía
    // su propia guarda + set/finally, lo que causaba 2 bugs:
    //   1. Como `sincronizarTodo` ya ponía `_isSyncing = true`, la
    //      guarda convertía este método en un no-op silencioso
    //      (ventas/gastos/turnos nunca se sincronizaban).
    //   2. Al liberar el flag en su propio `finally`, dejaba al padre
    //      sin lock durante los módulos restantes → despertaba los
    //      guards anti-eco de Realtime (:204/:230).
    int sincronizados = 0;

    try {
      final pendientes = await _isarService.obtenerGastosPendientesSync();
      if (pendientes.isEmpty) {
        return 0;
      }

      debugPrint(
          '🔄 [SyncService] Sincronizando ${pendientes.length} gastos...');

      for (var gasto in pendientes) {
        try {
          final exito = await _enviarGastoAlServidor(gasto);
          if (exito) {
            await _isarService.actualizarSyncStatusGasto(gasto.id, _SyncConstants.synced);
            sincronizados++;
            debugPrint('✅ Gasto ${gasto.id} sincronizado');
          } else {
            await _isarService.actualizarSyncStatusGasto(gasto.id, _SyncConstants.failed);
            debugPrint('⚠️ Gasto ${gasto.id} marcado como failed');
          }
        } catch (e, stack) {
          ErrorService.captureError(e,
              stack: stack,
              hint: 'sincronizarGasto_individual_fallo',
              extras: {'gastoId': gasto.id});
          await _isarService.actualizarSyncStatusGasto(gasto.id, _SyncConstants.failed);
        }
      }
      debugPrint('✅ $sincronizados gastos sincronizados');
      return sincronizados;
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando gastos: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarGastosPendientes_fallo');
      return 0;
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
        'sync_status': _SyncConstants.synced,
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
    // ⚠️ Este método NO toca `_isSyncing`. Es un paso interno de
    // `sincronizarTodo()`, que es el único dueño del lock. Antes tenía
    // su propia guarda + set/finally, lo que causaba 2 bugs:
    //   1. Como `sincronizarTodo` ya ponía `_isSyncing = true`, la
    //      guarda convertía este método en un no-op silencioso
    //      (ventas/gastos/turnos nunca se sincronizaban).
    //   2. Al liberar el flag en su propio `finally`, dejaba al padre
    //      sin lock durante los módulos restantes → despertaba los
    //      guards anti-eco de Realtime (:204/:230).
    int sincronizados = 0;

    try {
      final pendientes = await _isarService.obtenerTurnosPendientes();
      if (pendientes.isEmpty) {
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
    }
  }

  Future<bool> _enviarTurnoAlServidor(TurnoEntity turno) async {
    try {
      // ✅ Resolver UUID del usuario (columna usuario_id en Supabase)
      final usuarioUuid = await _obtenerSupabaseIdUsuario(turno.usuarioId);
      if (usuarioUuid == null || usuarioUuid.isEmpty) {
        debugPrint(
            '⚠️ Turno ${turno.id}: usuario local ${turno.usuarioId} sin UUID. '
            'Queda pendiente para el próximo ciclo.');
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
        'sync_status': _SyncConstants.synced, // ← corregido (antes 'pending')
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
    _escribiendoLocales = true;
    try {
      final pendientes = await _isarService.obtenerLocalesPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay locales pendientes para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} locales con Supabase...');

      final tenantJwt = getTenantIdFromJWT();
      for (var local in pendientes) {
        if (tenantJwt == null ||
            tenantJwt.isEmpty ||
            local.supabaseId != tenantJwt) {
          debugPrint(
            '⏭️ Local "${local.nombre}" no pertenece al tenant actual '
            '($tenantJwt). Skip.',
          );
          continue;
        }

        try {
          // 🎯 FIX: usar `update()` en vez de `upsert()`.
          //    Los locales del sync NUNCA son nuevos — se crean vía el RPC
          //    `crear_nuevo_local_para_usuario`. Solo necesitamos actualizar
          //    campos (business_mode, nombre, etc.). `upsert` intentaba INSERT
          //    y fallaba en RLS porque no hay policy INSERT.
          final response = await _supabase
              .from('locales')
              .update({
                'nombre': local.nombre,
                'rif': local.rif,
                'direccion': local.direccion,
                'telefono': local.telefono,
                'email': local.email,
                'logo_path': local.logoPath,
                'razon_social': local.razonSocial,
                'activo': local.activo,
                'business_mode': local.businessMode,
                'sync_status': _SyncConstants.synced,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', local.supabaseId!)
              .select('id')
              .maybeSingle();

          String? supabaseId = response?['id'] as String?;

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
    } finally {
      _escribiendoLocales = false;
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

      // 🔴 DEFENSA EN PROFUNDIDAD (2026-10-15)
      //
      // `locales.id` ES el `tenant_id`. El RLS debería devolver solo la
      // fila del claim, pero con `SET role authenticated` + el JWT real
      // la tabla devuelve las 5 filas de los 5 tenants: el RLS está
      // habilitado (`relrowsecurity = true`) y aun así no filtra.
      //
      // Antes de arreglar el backend, la app deja de confiar en que él
      // filtre. Es el mismo criterio que ya usan el resto de las tablas
      // (`tenant_id = current_tenant_id()`), y no depende de que alguien
      // vuelva a tocar la policy desde el dashboard — que es lo que pasó
      // dos veces hoy.
      //
      // ⚠️ Si el claim no se puede leer NO se filtra: deny-by-default
      // dejaría al usuario sin su local y sin forma de recuperar.
      final tenantJwt = getTenantIdFromJWT();
      final visibles = (tenantJwt == null || tenantJwt.isEmpty)
          ? response
          : response
              .where((l) => l['id'] == tenantJwt)
              .toList(growable: false);

      if (visibles.length != response.length) {
        debugPrint(
          '🔒 [locales] RLS devolvió ${response.length} filas; '
          'filtradas a ${visibles.length} por tenantId=$tenantJwt',
        );
      }
      debugPrint(
          '🔄 Descargando ${visibles.length} locales desde Supabase...');

      final localesLocales =
          await _isarService.obtenerLocales(soloActivos: false);
      final Map<String, LocalEntity> localesPorSupabaseId = {
        for (var l in localesLocales)
          if (l.supabaseId != null) l.supabaseId!: l
      };
      final Map<int, LocalEntity> localesPorId = {
        for (var l in localesLocales) l.id: l
      };

      for (var data in visibles) {
        final supabaseId = data['id'] as String?;
        if (supabaseId == null) continue;

        final idIsar = _toInt(data['id_isar']);
        LocalEntity? local = localesPorSupabaseId[supabaseId];
        if (local == null && idIsar > 0) {
          local = localesPorId[idIsar];
        }

        // 🎯 FIX: campos comunes que SÍ vienen de Supabase
        final nombreNube = data['nombre'] as String? ?? '';
        final direccionNube = data['direccion'] as String?;
        final telefonoNube = data['telefono'] as String?;
        final emailNube = data['email'] as String?;
        final activoNube = data['activo'] as bool? ?? true;
        final businessModeNube = _parseBusinessMode(data['business_mode']);
        final rifNube = data['rif'] as String?;

        final logoPathNube = data['logo_path'] as String?;
        final razonSocialNube = data['razon_social'] as String?;
        if (local != null) {
          // 🎯 FIX: si el local tiene cambios pendientes de subir (por ejemplo,
          //    `businessMode` cambiado por el usuario pero no sincronizado aún),
          //    NO sobreescribir con el valor stale de la nube. Preservar el
          //    `businessMode` local hasta que se suba.
          final tienePendientes = local.sincronizado == false;

          local
            ..supabaseId = supabaseId
            ..nombre = nombreNube.isNotEmpty ? nombreNube : local.nombre
            ..direccion = direccionNube ?? local.direccion
            ..telefono = telefonoNube ?? local.telefono
            ..email = emailNube ?? local.email
            ..activo = activoNube
            ..rif = rifNube ?? local.rif
            ..logoPath = logoPathNube ?? local.logoPath
            ..razonSocial = razonSocialNube ?? local.razonSocial
            ..fechaSincronizacion = DateTime.now();

          // 🎯 Solo sobreescribir `businessMode` si el local NO tiene cambios
          //    pendientes. Si los tiene, se preserva el valor local.
          if (!tienePendientes) {
            local.businessMode = businessModeNube;
            local.sincronizado = true;
          } else {
            debugPrint(
              '🛡️ Local ${local.nombre}: businessMode local '
              '"${local.businessMode}" preservado (pendiente de sync)',
            );
          }

          debugPrint('🔍 ANTES: modoConfiguradoEn=${local.modoConfiguradoEn}');
          await _isarService.guardarLocal(local);
          debugPrint('🔍 DESPUÉS: modoConfiguradoEn=${local.modoConfiguradoEn}');
          debugPrint(
            '🔄 Local ${local.nombre} actualizado (merge preservando config local)',
          );
        } else {
          // Crear nuevo (no hay datos previos que preservar)
          final localNube = LocalEntity()
            ..supabaseId = supabaseId
            ..nombre = nombreNube
            ..direccion = direccionNube
            ..telefono = telefonoNube
            ..email = emailNube
            ..activo = activoNube
            ..businessMode = businessModeNube
            ..sincronizado = true
            ..fechaSincronizacion = DateTime.now()
            ..rif = rifNube
            ..logoPath = logoPathNube
            ..razonSocial = razonSocialNube;

          await _isarService.guardarLocal(localNube);
          debugPrint('📥 Local ${localNube.nombre} creado');
        }
      }

      await _purgarLocalesResiduo();
      onDataChanged?.call();
    } catch (e, stack) {
      debugPrint('❌ Error descargando locales: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarLocalesDesdeSupabase_fallo');
      rethrow;
    }
  }

  /// 🧹 Purga los locales de Isar que este usuario no puede usar.
  ///
  /// La lista blanca sale de `mis_locales()` (RPC `SECURITY DEFINER`),
  /// el mismo origen que alimenta el selector de local. Nunca borra un
  /// local asignado al usuario, y sí borra el residuo que dejaron otras
  /// cuentas con las que se usó este dispositivo — que es lo que pasó con
  /// el brazo abierto de la policy `locales` (ver AGENTS.MD §7.4.1).
  ///
  /// ⚠️ Si la RPC falla o vuelve vacía, NO purga. Una caída de red no
  /// puede convertirse en un borrado masivo.
  Future<void> _purgarLocalesResiduo() async {
    try {
      final rpc = await _supabase.rpc('mis_locales').timeout(
            const Duration(seconds: 8),
          );

      if (rpc is! List || rpc.isEmpty) {
        debugPrint(
          '🧹 [locales] mis_locales() vacío o no-list: se omite la purga.',
        );
        return;
      }

      final permitidos = <String>{};
      for (final row in rpc) {
        if (row is Map && row['id'] is String) permitidos.add(row['id'] as String);
      }

      if (permitidos.isEmpty) return;

      await _isarService.purgarLocalesFueraDe(permitidos);
    } catch (e) {
      debugPrint('🧹 [locales] Purga omitida por error: $e');
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

        final tenantActual = localUuid;
        if (tenantActual == null || tenantActual.isEmpty) {
          debugPrint(
              '⚠️ Departamento ${departamento.nombre} sin tenant. Saltando.');
          continue;
        }

        // 🎯 FIX Bug 7: `departamento.usuarioId` YA es el id_isar (bigint).
        //    NO convertirlo a UUID — la columna `usuario_id` es bigint.
        final int? usuarioIdInt = departamento.usuarioId;

        final data = <String, dynamic>{
          'id_isar': departamento.id,
          'nombre': departamento.nombre,
          'descripcion': departamento.descripcion,
          'tenant_id': tenantActual,
          'usuario_id': usuarioIdInt, // ← bigint, no UUID
          'activo': departamento.activo,
          'sync_status': _SyncConstants.synced,
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
      // Filtro por tenant obligatorio (ver :3882 patrón lotes). Aquí son
      // las estaciones de cocina de TODOS los restaurantes si se omite.
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de departamentos omitida (no se puede filtrar por tenant).');
        return;
      }
      final response = await _supabase
          .from('departamentos')
          .select()
          .eq('tenant_id', tenantUuid)
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
        final rawUsuarioId = data['usuario_id'];
        if (rawUsuarioId != null) {
          final idIsar = _toInt(rawUsuarioId);
          if (idIsar > 0) usuarioIsarId = idIsar;
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

  // ==================== ZONAS Y MESAS (R.1b) ====================

  /// Sube las zonas pendientes del local.
  ///
  /// Se llama DESPUÉS de `descargarZonasDesdeSupabase`: el pull adopta por
  /// nombre las zonas que este dispositivo sembró y todavía no tenían
  /// `supabaseId`. Sin ese orden, el push chocaría con el índice único
  /// `(tenant_id, nombre)` de una zona que ya existe en la nube.
  Future<void> sincronizarZonasPendientes() async {
    try {
      final pendientes = await _isarService.obtenerZonasPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay zonas pendientes para sincronizar');
        return;
      }

      debugPrint('🔄 Sincronizando ${pendientes.length} zonas...');

      for (final zona in pendientes) {
        if (zona.localId <= 0) continue;
        final tenantUuid = await _obtenerSupabaseIdLocal(zona.localId);
        if (tenantUuid == null || tenantUuid.isEmpty) {
          debugPrint('⚠️ Zona ${zona.nombre} sin tenant. Saltando.');
          continue;
        }

        final data = <String, dynamic>{
          'id_isar': zona.id,
          'tenant_id': tenantUuid,
          'nombre': zona.nombre,
          'orden': zona.orden,
          'activo': zona.activo,
          'eliminado': zona.eliminado,
          'sync_status': _SyncConstants.synced,
          'updated_at': DateTime.now().toIso8601String(),
        };

        try {
          final response = await _supabase
              .from('zonas')
              .upsert(data, onConflict: 'tenant_id,id_isar')
              .select('id')
              .maybeSingle();

          final supabaseId = response?['id'] as String?;
          if (supabaseId != null) {
            zona
              ..supabaseId = supabaseId
              ..sincronizado = true
              ..fechaSincronizacion = DateTime.now();
            await _isarService.guardarZona(zona, marcarPendiente: false);
            debugPrint('✅ Zona ${zona.nombre} sincronizada ($supabaseId)');
          }
        } catch (e) {
          // Un choque de nombre contra otra zona de la nube se resuelve en
          // el próximo pull (que adopta por nombre). No abortamos el resto.
          debugPrint('❌ Error al sincronizar zona ${zona.nombre}: $e');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error general en sincronizarZonasPendientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarZonasPendientes_fallo');
      rethrow;
    }
  }

  /// Baja las zonas del tenant activo.
  ///
  /// Estrategia de adopción:
  ///   1. Por `supabaseId` (camino normal).
  ///   2. Por nombre dentro del local (una zona sembrada acá que ya existe
  ///      en la nube). Se le asigna el UUID y deja de estar pendiente.
  ///   3. Si no existe, se crea.
  ///
  /// LWW: si la copia local está pendiente y es más nueva que la nube, no
  /// se pisa; se conserva pendiente para que el push la suba.
  Future<void> descargarZonasDesdeSupabase() async {
    try {
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de zonas omitida.');
        return;
      }

      final response = await _supabase
          .from('zonas')
          .select()
          .eq('tenant_id', tenantUuid)
          .order('orden', ascending: true);

      if (response.isEmpty) return;
      debugPrint('🔄 Descargando ${response.length} zonas desde Supabase...');

      final locales = await _isarService.obtenerLocales(soloActivos: false);
      final Map<String, int> uuidToIsarId = {};
      for (final local in locales) {
        if (local.supabaseId != null) uuidToIsarId[local.supabaseId!] = local.id;
      }

      for (final data in response) {
        final supabaseId = data['id'] as String?;
        final tenantId = data['tenant_id'] as String?;
        final nombre = (data['nombre'] as String? ?? '').trim();
        if (supabaseId == null || nombre.isEmpty) continue;

        final localId = tenantId != null ? uuidToIsarId[tenantId] : null;
        if (localId == null) continue;

        var zona = await _isarService.obtenerZonaPorSupabaseId(supabaseId);
        zona ??= await _isarService.obtenerZonaPorNombre(localId, nombre);
        final existia = zona != null;
        zona ??= ZonaEntity()..localId = localId;

        final cloudUpdated =
            DateTime.tryParse(data['updated_at'] as String? ?? '');
        final localGana = existia &&
            !zona.sincronizado &&
            zona.updatedAt != null &&
            cloudUpdated != null &&
            zona.updatedAt!.isAfter(cloudUpdated);

        if (localGana) {
          zona.supabaseId ??= supabaseId;
          zona.localId = localId;
          await _isarService.guardarZona(zona, marcarPendiente: true);
          continue;
        }

        zona
          ..supabaseId = supabaseId
          ..localId = localId
          ..nombre = nombre
          ..orden = _toInt(data['orden'])
          ..activo = data['activo'] as bool? ?? true
          ..eliminado = data['eliminado'] as bool? ?? false
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        await _isarService.guardarZona(zona, marcarPendiente: false);
      }
    } catch (e, stack) {
      debugPrint('❌ Error descargando zonas: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarZonasDesdeSupabase_fallo');
      rethrow;
    }
  }

  /// Sube las mesas pendientes del local.
  ///
  /// La zona se referencia por UUID (`zona_id`) y además se guarda el
  /// nombre como snapshot (`zona_nombre`), para que un dispositivo que
  /// todavía no bajó la zona pueda mostrar algo coherente.
  Future<void> sincronizarMesasPendientes() async {
    try {
      final pendientes = await _isarService.obtenerMesasPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay mesas pendientes para sincronizar');
        return;
      }

      debugPrint('🔄 Sincronizando ${pendientes.length} mesas...');

      for (final mesa in pendientes) {
        if (mesa.localId <= 0) continue;
        final tenantUuid = await _obtenerSupabaseIdLocal(mesa.localId);
        if (tenantUuid == null || tenantUuid.isEmpty) {
          debugPrint('⚠️ Mesa ${mesa.nombre} sin tenant. Saltando.');
          continue;
        }

        ZonaEntity? zona;
        final zonaNombre = mesa.zonaEfectiva;
        if (zonaNombre.isNotEmpty) {
          zona = await _isarService.obtenerZonaPorNombre(
              mesa.localId, zonaNombre);
        }

        String? unidaSid = mesa.unidaConMesaSupabaseId;
        if (unidaSid == null && mesa.unidaConMesaId != null) {
          final principal =
              await _isarService.obtenerMesaPorId(mesa.unidaConMesaId!);
          unidaSid = principal?.supabaseId;
          mesa.unidaConMesaSupabaseId = unidaSid;
        }

        final data = <String, dynamic>{
          'id_isar': mesa.id,
          'tenant_id': tenantUuid,
          'nombre': mesa.nombre,
          'zona_id': zona?.supabaseId,
          'zona_nombre': zonaNombre,
          'capacidad': mesa.capacidad,
          'orden_grid': mesa.ordenGrid,
          'unida_con_mesa_id': unidaSid,
          'eliminado': mesa.eliminado,
          'sync_status': _SyncConstants.synced,
          'updated_at': DateTime.now().toIso8601String(),
        };

        try {
          final response = await _supabase
              .from('mesas')
              .upsert(data, onConflict: 'tenant_id,id_isar')
              .select('id')
              .maybeSingle();

          final supabaseId = response?['id'] as String?;
          if (supabaseId != null) {
            mesa
              ..supabaseId = supabaseId
              ..sincronizado = true
              ..fechaSincronizacion = DateTime.now();
            await _isarService.guardarMesa(mesa, marcarPendiente: false);
            debugPrint('✅ Mesa ${mesa.nombre} sincronizada ($supabaseId)');
          }
        } catch (e) {
          debugPrint('❌ Error al sincronizar mesa ${mesa.nombre}: $e');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error general en sincronizarMesasPendientes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarMesasPendientes_fallo');
      rethrow;
    }
  }

  /// Baja las mesas del tenant activo.
  ///
  /// Misma adopción que las zonas (UUID → nombre). La unión de mesas se
  /// resuelve en una segunda pasada: el UUID de la mesa principal puede
  /// venir después en la misma respuesta.
  Future<void> descargarMesasDesdeSupabase() async {
    try {
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de mesas omitida.');
        return;
      }

      final response = await _supabase
          .from('mesas')
          .select()
          .eq('tenant_id', tenantUuid)
          .order('orden_grid', ascending: true);

      if (response.isEmpty) return;
      debugPrint('🔄 Descargando ${response.length} mesas desde Supabase...');

      final locales = await _isarService.obtenerLocales(soloActivos: false);
      final Map<String, int> uuidToIsarId = {};
      for (final local in locales) {
        if (local.supabaseId != null) uuidToIsarId[local.supabaseId!] = local.id;
      }

      for (final data in response) {
        final supabaseId = data['id'] as String?;
        final tenantId = data['tenant_id'] as String?;
        final nombre = (data['nombre'] as String? ?? '').trim();
        if (supabaseId == null || nombre.isEmpty) continue;

        final localId = tenantId != null ? uuidToIsarId[tenantId] : null;
        if (localId == null) continue;

        var mesa = await _isarService.obtenerMesaPorSupabaseId(supabaseId);
        mesa ??= await _isarService.obtenerMesaPorNombre(localId, nombre);
        final existia = mesa != null;
        mesa ??= MesaEntity()..localId = localId;

        final cloudUpdated =
            DateTime.tryParse(data['updated_at'] as String? ?? '');
        final localGana = existia &&
            !mesa.sincronizado &&
            mesa.updatedAt != null &&
            cloudUpdated != null &&
            mesa.updatedAt!.isAfter(cloudUpdated);

        if (localGana) {
          mesa.supabaseId ??= supabaseId;
          mesa.localId = localId;
          await _isarService.guardarMesa(mesa, marcarPendiente: true);
          continue;
        }

        final zonaId = data['zona_id'] as String?;
        var zonaNombre = (data['zona_nombre'] as String? ?? '').trim();
        if (zonaNombre.isEmpty && zonaId != null) {
          final zona = await _isarService.obtenerZonaPorSupabaseId(zonaId);
          zonaNombre = zona?.nombre ?? '';
        }

        mesa
          ..supabaseId = supabaseId
          ..localId = localId
          ..nombre = nombre
          ..zonaSupabaseId = zonaId
          ..zonaNombre = zonaNombre.isEmpty ? null : zonaNombre
          ..zona = zonaNombre.isEmpty
              ? mesa.zona
              : mesaZonaDesdeNombre(zonaNombre)
          ..capacidad = _toInt(data['capacidad'], 4)
          ..ordenGrid = _toInt(data['orden_grid'])
          ..unidaConMesaId = null
          ..unidaConMesaSupabaseId = data['unida_con_mesa_id'] as String?
          ..eliminado = data['eliminado'] as bool? ?? false
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        await _isarService.guardarMesa(mesa, marcarPendiente: false);
      }

      // Segunda pasada: resolver la mesa principal de cada unión.
      for (final data in response) {
        final supabaseId = data['id'] as String?;
        final unidaSid = data['unida_con_mesa_id'] as String?;
        if (supabaseId == null || unidaSid == null) continue;

        final mesa = await _isarService.obtenerMesaPorSupabaseId(supabaseId);
        if (mesa == null) continue;
        final principal =
            await _isarService.obtenerMesaPorSupabaseId(unidaSid);
        if (principal == null) continue;
        if (mesa.unidaConMesaId == principal.id) continue;

        mesa
          ..unidaConMesaId = principal.id
          ..unidaConMesaSupabaseId = unidaSid;
        await _isarService.guardarMesa(mesa, marcarPendiente: false);
      }
    } catch (e, stack) {
      debugPrint('❌ Error descargando mesas: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarMesasDesdeSupabase_fallo');
      rethrow;
    }
  }

  // ==================== CLIENTES ====================

  Future<void> sincronizarClientesPendientes() async {    try {
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
            cliente.syncStatus = _SyncConstants.synced;
            cliente.updatedAt = DateTime.now();
            await _isarService.guardarCliente(cliente);
            debugPrint(
                '✅ Cliente ${cliente.nombre} sincronizado (ID: $supabaseId)');
          }
        } catch (e) {
          debugPrint('❌ Error sincronizando cliente ${cliente.nombre}: $e');
          cliente.syncStatus = _SyncConstants.failed;
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
          ..syncStatus = _SyncConstants.synced
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

      // `upsertados` cubre insert y update por igual: ya no podemos
      // distinguirlos desde el cliente (PostgREST reporta `upserted`
      // como una sola operación). Antes `actualizados` solo contaba la
      // rama del catch "duplicate key", que con la constraint nueva
      // nunca se ejecuta.
      int upsertados = 0, fallidos = 0;

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
          fallidos++;
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

        // ⚠️ `tenant_id` NO se manda: lo llena `current_tenant_id()` del
        //    server (la columna tiene DEFAULT, baseline.sql:630).
        //
        // Antes se mandaba `localUuid`, resuelto de Isar. El problema: en
        // la ventana del hot-switch, el local activo de Isar y el tenant
        // del JWT no coinciden, así que el lote se subía a un tenant y el
        // movimiento de ese mismo lote (que NO manda tenant) al otro. El
        // movimiento quedaba referenciando un `lote_id_isar` que no
        // existía en su tenant.
        //
        // Mismo principio que `movimientos_lotes`: una sola fuente de
        // verdad para el tenant, y es la sesión.
        final data = {
          'id_isar': lote.id,
          'producto_id_fk': lote.productoId,
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
          // Upsert con ON CONFLICT (tenant_id, id_isar).
          //
          // Antes era `insert` + catch de "duplicate key" para caer al
          // update. Sin constraint UNIQUE en la nube ese insert NUNCA
          // fallaba, así que cada sync creaba una fila nueva del mismo
          // lote: en producción había 2 filas con `id_isar = 1`, ambas
          // con `restante > inicial` (100→200 y 100→150), lo que
          // inflaba `SUM(lotes)` y rompía el stock.
          //
          // La constraint `lotes_id_isar_tenant_uk` (migración 00006) es
          // la que hace que `onConflict` tenga un target real.
          await _supabase
              .from('lotes')
              .upsert(data, onConflict: 'tenant_id,id_isar');
          upsertados++;
          debugPrint('✅ Lote ${lote.id} upserted');
        } catch (e) {
          debugPrint('❌ Error sincronizando lote ${lote.id}: $e');
          fallidos++;
          continue;
        }

        lote.sincronizado = true;
        lote.fechaSincronizacion = DateTime.now();
        await _isarService.guardarLote(lote);
      }

      // Contadores honestos. Antes el log decía
      // "${pendientes.length} lotes sincronizados" sin importar cuántos
      // se habían omitido por producto inexistente, sin tenant o por
      // error: un 0% de éxito se reportaba como éxito total.
      if (fallidos > 0) {
        debugPrint('⚠️ Lotes: $upsertados sincronizados, '
            '$fallidos fallidos (ver errores arriba)');
      } else {
        debugPrint('✅ Lotes sincronizados: $upsertados');
      }
    } catch (e, stack) {
      debugPrint('❌ Error sincronizando lotes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarLotesPendientes_fallo');
      rethrow;
    }
  }

  /// Sube los movimientos de lote pendientes a Supabase.
///
/// El payload sale de `MovimientoLoteEntity.toSupabaseJson()`. Antes este
/// metodo armaba el Map a mano, en paralelo a la entity, y el mapeo podia
/// divergir sin que nada lo detectara: agregar una columna obligaba a
/// acordarse de editar DOS lugares y el sync no valida el payload contra el
/// schema. Ahora hay una sola fuente.
///
/// La entity NO manda `tenant_id`: lo resuelve el default
/// `current_tenant_id()` del server (migracion 20261010000002). Mandarlo
/// desde el cliente mandaria el tenant equivocado si el usuario hot-cambia
/// de local a mitad del sync.
Future<void> subirMovimientosLotePendientes() async {
  try {
    final todos = await _isarService.obtenerTodosMovimientosLote();
    final pendientes = todos.where((m) => !m.sincronizado).toList();

    if (pendientes.isEmpty) {
      debugPrint('No hay movimientos de lote pendientes');
      return;
    }

    debugPrint(
        'Sincronizando ${pendientes.length} movimientos de lote...');

    int fallidos = 0;
    final subidos = <MovimientoLoteEntity>[];

    for (final mov in pendientes) {
      try {
        await _supabase
            .from('movimientos_lotes')
            .upsert(mov.toSupabaseJson(), onConflict: 'tenant_id,id_isar');
        subidos.add(mov);
      } catch (e) {
        // No se marca como sincronizado: queda pendiente y se reintenta en
        // el proximo ciclo, que es el comportamiento de las demas
        // entidades.
        debugPrint('Error subiendo movimiento ${mov.id}: $e');
        ErrorService.captureError(e,
            hint: 'subirMovimientosLote_individual_fallo',
            extras: {'movimientoId': mov.id, 'tipo': mov.tipo});
        fallidos++;
      }
    }

    // Solo se marcan los que SUBIERON. Marcar todos dejaria los fallidos
    // como sincronizados para siempre y el movimiento se perderia sin
    // reintento.
    for (final mov in subidos) {
      mov.sincronizado = true;
      mov.fechaSincronizacion = DateTime.now();
      await _isarService.guardarMovimientoLote(mov);
    }

    debugPrint('Movimientos de lote: ${subidos.length} sincronizados, '
        '$fallidos fallidos');
  } catch (e, stack) {
    debugPrint('Error sincronizando movimientos de lote: $e');
    ErrorService.captureError(e,
        stack: stack, hint: 'subirMovimientosLotePendientes_fallo');
    rethrow;
  }
}

  Future<void> descargarLotesDesdeSupabase() async {
    try {
      // ⚠️ Filtro por tenant OBLIGATORIO. Antes hacía `select()` a secas
      // y depended por completo de que RLS aislara. Con 2 locales
      // (JAHTLABS y centro) un fallo de RLS o un rol mal autenticado
      // descargaba los lotes de ambas empresas en un mismo dispositivo.
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de lotes omitida (no se puede filtrar por tenant).');
        return;
      }

      final response = await _supabase
          .from('lotes')
          .select()
          .eq('tenant_id', tenantUuid)
          .order('fecha_ingreso', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay lotes en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} lotes desde Supabase...');

      int creados = 0, actualizados = 0, omitidos = 0;

      for (var data in response) {
        final idIsar = _toInt(data['id_isar']);
        if (idIsar == 0) {
          omitidos++;
          continue;
        }

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
          // `cantidadInicial` y `fechaVencimiento` no se comparaban, así
          // que un cambio local de cualquiera de los dos se perdía en la
          // siguiente descarga. `fechaVencimiento` es además la base
          // del FEFO: si la nube lo corrige, el orden de consumo cambia.
          if (existente.cantidadInicial != loteNube.cantidadInicial) {
            existente.cantidadInicial = loteNube.cantidadInicial;
            cambios = true;
          }
          if (existente.fechaVencimiento != loteNube.fechaVencimiento) {
            existente.fechaVencimiento = loteNube.fechaVencimiento;
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

      // Log honesto: antes no contaba los omitidos, así que una descarga
      // 100% fallida se reportaba como éxito.
      if (omitidos > 0) {
        debugPrint('⚠️ Lotes descargados: $creados creados, '
            '$actualizados actualizados, $omitidos omitidos (sin id_isar)');
      } else {
        debugPrint('✅ Lotes descargados: $creados creados, '
            '$actualizados actualizados');
      }
    } catch (e, stack) {
      debugPrint('❌ Error descargando lotes: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarLotesDesdeSupabase_fallo');
    }
  }

  Future<void> descargarMovimientosLoteDesdeSupabase() async {
    try {
      // Filtro por tenant obligatorio (ver :3882 patrón lotes). Esta es la
      // tabla del incidente del 2026-10-10: se creó a mano sin RLS y el
      // select() a secas traía movimientos de todos los tenants.
      final localActivo = await _isarService.obtenerLocalActivo();
      final tenantUuid = localActivo?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin local activo. '
            'Descarga de movimientos de lote omitida (no se puede filtrar '
            'por tenant).');
        return;
      }
      final response = await _supabase
          .from('movimientos_lotes')
          .select()
          .eq('tenant_id', tenantUuid)
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

        // El mapeo vive en la entity: `fromSupabase` es el unico lugar que sabe
        // como se llama cada columna. Antes el sync armaba la entity a mano
        // en un segundo sitio que podia divergir del primero sin avisar.
        final movNube = MovimientoLoteEntity.fromSupabase(data)
          ..id = idIsar
          // Lo que viene de la nube esta sincronizado por definicion, sin
          // importar lo que diga la columna: el proposito de este metodo es
          // dejar el movimiento local marcado para no volver a subirlo.
          ..sincronizado = true
          ..fechaSincronizacion = DateTime.now();

        final local = localesPorId[idIsar];
        if (local == null) {
          await _isarService.guardarMovimientoLote(movNube);
        }
      }
      onDataChanged?.call();
    } catch (e, stack) {
      debugPrint('❌ Error en movimientos_lotes: $e');
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'descargarMovimientosLoteDesdeSupabase_fallo',
        // Sin `extras`, este error era indistinguible de un timeout de red
        // o de un rechazo de RLS: los tres llegaban al mismo hint sin
        // decir contra que tabla ni contra que operacion.
        extras: {'tabla': 'movimientos_lotes', 'origen': 'descarga'},
      );
    }
  }

  // ============================================================
  // RECETAS
  // ============================================================

  /// `true` si el error es "esa tabla/función no existe todavía".
  ///
  /// Sirve para que un entorno sin la migración `20261027000001_recetas`
  /// avise UNA vez y no una por receta, todos los ciclos, además de no
  /// mandar el ruido a Sentry. Códigos: `42P01` (tabla), `PGRST205`
  /// (tabla fuera del schema cache) y `PGRST202` (función inexistente).
  bool _esquemaRecetasAusente(Object error) {
    final texto = error.toString().toLowerCase();
    return texto.contains('42p01') ||
        texto.contains('pgrst205') ||
        texto.contains('pgrst202') ||
        texto.contains('does not exist') ||
        texto.contains('schema cache');
  }

  /// Sube las recetas pendientes con la RPC `guardar_receta`.
  ///
  /// La receta viaja como UN payload (fila + ingredientes) y el reemplazo de
  /// ingredientes ocurre dentro de la transacción de la RPC. Hacerlo desde
  /// el cliente (upsert + delete + insert) dejaría recetas sin ingredientes
  /// si se corta la red en medio, y esa versión vacía se propagaría al resto
  /// de dispositivos.
  ///
  /// ⚠️ No se manda `tenant_id`: lo pone `current_tenant_id()` en el server.
  Future<void> sincronizarRecetasPendientes() async {
    try {
      final pendientes = await _isarService.obtenerRecetasPendientesSync();
      if (pendientes.isEmpty) {
        debugPrint('ℹ️ No hay recetas pendientes para sincronizar');
        return;
      }

      debugPrint(
          '🔄 Sincronizando ${pendientes.length} recetas con Supabase...');

      int upsertadas = 0, fallidas = 0, omitidas = 0;

      for (final receta in pendientes) {
        if (receta.productoId <= 0) {
          debugPrint('⚠️ Receta ${receta.id} omitida: sin productoId.');
          omitidas++;
          continue;
        }

        // La receta apunta al plato por id local. Si el producto no existe
        // en Isar tampoco puede existir en la nube, y la FK de `recetas`
        // rechazaría el insert.
        final producto =
            await _isarService.obtenerProductoPorId(receta.productoId);
        if (producto == null) {
          debugPrint('⚠️ Receta ${receta.id} omitida: el producto '
              '${receta.productoId} no existe en Isar.');
          omitidas++;
          continue;
        }

        try {
          final respuesta = await _supabase.rpc(
            'guardar_receta',
            params: {
              'p_receta': receta.toSupabaseJson(),
              'p_ingredientes': receta.ingredientesToSupabaseJson(),
            },
          );

          await _isarService.marcarRecetaSincronizada(
            receta.id,
            supabaseId: respuesta is String ? respuesta : respuesta?.toString(),
          );
          upsertadas++;
          debugPrint('✅ Receta de "${receta.nombrePlato}" '
              '(${receta.items.length} ingredientes) sincronizada');
        } catch (e) {
          if (_esquemaRecetasAusente(e)) {
            debugPrint('⚠️ Recetas: las tablas `recetas` / '
                '`receta_ingredientes` no existen todavía en Supabase. '
                'Aplicá supabase/migrations/20261027000001_recetas.sql. '
                'Push omitido.');
            return;
          }
          debugPrint('❌ Error sincronizando receta ${receta.id}: $e');
          fallidas++;
        }
      }

      if (fallidas > 0 || omitidas > 0) {
        debugPrint('⚠️ Recetas: $upsertadas sincronizadas, '
            '$fallidas fallidas, $omitidas omitidas.');
      } else {
        debugPrint('✅ Recetas sincronizadas: $upsertadas');
      }
    } catch (e, stack) {
      if (_esquemaRecetasAusente(e)) {
        debugPrint('⚠️ Recetas: tablas ausentes en Supabase. Push omitido.');
        return;
      }
      debugPrint('❌ Error sincronizando recetas: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarRecetasPendientes_fallo');
      rethrow;
    }
  }

  /// Baja las recetas con sus ingredientes embebidos.
  ///
  /// Reglas de cruce:
  ///   · `id_isar` de la nube es el id de Isar del dispositivo que la creó,
  ///     así que se busca por id local (mismo criterio que los lotes).
  ///   · Si el id ya existe pero apunta a OTRO plato, se descarta la fila:
  ///     son dos dispositivos que crearon recetas en paralelo y el
  ///     autoincrement de Isar chocó. Pisar la receta local del plato B con
  ///     la del plato A sería peor que no sincronizar.
  ///   · Si no hay fila con ese id pero el local YA tiene una receta para ese
  ///     plato, también se descarta: si no, quedarían dos recetas del mismo
  ///     plato en el mismo dispositivo.
  Future<void> descargarRecetasDesdeSupabase() async {
    try {
      final tenantUuid = getTenantIdFromJWT() ??
          (await _isarService.obtenerLocalActivo())?.supabaseId;
      if (tenantUuid == null || tenantUuid.isEmpty) {
        debugPrint('⚠️ [SyncService] Sin tenant. '
            'Descarga de recetas omitida.');
        return;
      }

      // `*, receta_ingredientes(*)` usa la FK `receta_ingredientes_receta_fk`.
      final response = await _supabase
          .from('recetas')
          .select('*, receta_ingredientes(*)')
          .eq('tenant_id', tenantUuid)
          .order('updated_at', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️ No hay recetas en Supabase para descargar');
        return;
      }

      debugPrint('🔄 Descargando ${response.length} recetas desde Supabase...');

      int creadas = 0, actualizadas = 0, omitidas = 0, conflictos = 0;

      for (final data in response) {
        final idIsar = _toInt(data['id_isar']);
        if (idIsar <= 0) {
          omitidas++;
          continue;
        }

        final tenantFila = data['tenant_id']?.toString();
        final localId = tenantFila == null || tenantFila.isEmpty
            ? 0
            : await _obtenerIsarIdLocal(tenantFila);
        if (localId <= 0) {
          continue;
        }

        final recetaNube =
            RecetaEntity.fromSupabase(data, localIdResuelto: localId);

        final existente = await _isarService.obtenerRecetaPorId(idIsar);
        if (existente != null) {
          if (existente.productoId != recetaNube.productoId) {
            conflictos++;
            continue;
          }
          // `marcarPendiente: false`: esta receta acaba de venir de la nube.
          // Marcarla pendiente la haría empujarse sola en cada ciclo.
          await _isarService.guardarReceta(recetaNube, marcarPendiente: false);
          actualizadas++;
        } else {
          final yaHayParaElPlato = await _isarService.obtenerRecetaPorProducto(
            localId,
            recetaNube.productoId,
          );
          if (yaHayParaElPlato != null) {
            conflictos++;
            continue;
          }
          await _isarService.guardarReceta(recetaNube, marcarPendiente: false);
          creadas++;
        }
      }

      onDataChanged?.call();

      if (conflictos > 0 || omitidas > 0) {
        debugPrint('⚠️ Recetas descargadas: $creadas creadas, '
            '$actualizadas actualizadas, $omitidas omitidas, '
            '$conflictos en conflicto (id_isar de otro dispositivo).');
      } else {
        debugPrint('✅ Recetas descargadas: $creadas creadas, '
            '$actualizadas actualizadas');
      }
    } catch (e, stack) {
      if (_esquemaRecetasAusente(e)) {
        debugPrint('⚠️ Recetas: tablas ausentes en Supabase. '
            'Descarga omitida.');
        return;
      }
      debugPrint('❌ Error descargando recetas: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'descargarRecetasDesdeSupabase_fallo');
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


    // ═══════════════════════════════════════════════════════════════════
    // ✅ FIX 42501: usar el MISMO tenant_id que lee la RLS.
    //
    // La política `tenant_isolation` compara contra `current_tenant_id()`,
    // que lee del JWT. Si enviamos un UUID distinto (por ejemplo, el del
    // local guardado offline), la inserción es rechazada.
    //
    // `getTenantIdFromJWT()` decodifica el mismo campo del JWT, así que
    // garantizamos que el valor coincida con lo que la política espera.
    // ═══════════════════════════════════════════════════════════════════
    final tenantJwt = getTenantIdFromJWT();
    if (tenantJwt == null || tenantJwt.isEmpty) {
      debugPrint(
          '⚠️ JWT sin tenant_id. No se puede sincronizar Telegram '
          '(RLS rechazará el insert).');
      return;
    }

    debugPrint(
        '🔄 Sincronizando ${pendientes.length} configs de Telegram '
        '(tenant JWT: $tenantJwt)...');

    for (var config in pendientes) {
      // Persistimos el tenant JWT en el entity antes de enviar.
      config.tenantId = tenantJwt;

      final data = config.toSupabaseJson();
      data['tenant_id'] = tenantJwt; // ← viene del JWT, no de la BD local
      data['sync_status'] = _SyncConstants.synced;
      data['sincronizado'] = true;

      // ✅ Encriptar el token ANTES de enviar a Supabase (AES-256-CBC)
      if (config.botToken.isNotEmpty) {
        final encrypted = await TelegramCrypto.encryptToken(config.botToken);
        data['bot_token'] = encrypted;
      }

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
          config.syncStatus = _SyncConstants.synced;
          config.fechaSincronizacion = DateTime.now();
          await _isarService.guardarTelegramConfig(config);
          debugPrint(
              '✅ Config Telegram (usuario ${config.usuarioId}) sincronizada: $supabaseId');
        } else {
          debugPrint(
              '⚠️ No se obtuvo ID de Supabase para usuario ${config.usuarioId}');
        }
      } catch (e) {
        config.syncStatus = _SyncConstants.failed;
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
      // ✅ SELECT incluye bot_token (encriptado con AES-256-CBC del lado de la app)
      final response = await _supabase
          .from('telegram_config')
          .select(
            'id, id_isar, usuario_id, tenant_id, chat_id, nombre_chat, '
            'bot_token, enabled, notificar_stock_bajo, notificar_ventas, '
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
              ..syncStatus = _SyncConstants.synced
              ..updatedAt = nubeUpdated;

            // ✅ Desencriptar el token de Supabase si existe
            final encryptedToken = data['bot_token'] as String?;
            if (encryptedToken != null && encryptedToken.isNotEmpty) {
              final decrypted = await TelegramCrypto.decryptToken(encryptedToken);
              if (decrypted != null && decrypted.isNotEmpty) {
                local.botToken = decrypted;
              }
            }

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
            ..syncStatus = _SyncConstants.synced
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

      // Mapa local→uuid desde ISAR (no desde Supabase).
      //
      // Antes se construía desde la tabla `locales` de Supabase, así que
      // un local que aún no estaba subido era indistinguible de uno
      // inexistente, y cualquier pedido suyo caía en la rama de
      // "reasignar al local activo", que es destructiva.
      //
      // `soloActivos: false` porque el pedido puede haber nacido en un
      // local que luego quedó inactivo por un hot-switch: sigue siendo
      // un local válido con UUID.
      final localesLocales =
          await _isarService.obtenerLocales(soloActivos: false);
      final Map<int, String> idIsarAUuid = {};
      for (final local in localesLocales) {
        final uuid = local.supabaseId;
        if (uuid != null && uuid.isNotEmpty) {
          idIsarAUuid[local.id] = uuid;
        }
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
        // ⚠️ NO reasignar `localOrigenId` al local activo.
        //
        // El código anterior hacía `pedido.localOrigenId = localActualId`
        // + `guardarPedido`, es decir una reescritura DESTRUCTIVA e
        // irreversible del origen. Con más de un local activo eso movía
        // pedidos de un local a otro cada vez que sincronizabas desde el
        // segundo. El pedido nació en un local real; mentir sobre eso
        // corrompe el dato de negocio.
        //
        // Si el local no tiene UUID todavía, el pedido se omite este
        // ciclo y se reintenta en el siguiente: queda `pendiente` y
        // vuelve a aparecer cuando el local se suba.
        if (!idIsarAUuid.containsKey(pedido.localOrigenId)) {
          debugPrint(
            '⚠️ Pedido ${pedido.id}: localOrigenId ${pedido.localOrigenId} '
            'sin UUID en Isar. Omitido este ciclo (no se reasigna).',
          );
          continue;
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
          'sync_status': _SyncConstants.synced,
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
        int usuarioId = await _obtenerIsarIdUsuario(usuarioUuid);

        // 🎯 FIX Bug 9: si el usuario no existe ni local ni en Supabase
        //    (fue borrado), crear un placeholder para no perder el pedido.
        //    El pedido es dato histórico: la FK rota no debe descartarlo.
        if (usuarioId == 0 && usuarioUuid.isNotEmpty) {
          final placeholder = UsuarioEntity()
            ..supabaseId = usuarioUuid
            ..nombre = 'Usuario eliminado'
            ..pin = '' // sin PIN — no puede iniciar sesión
            ..rol = 'cajero'
            ..activo = false
            ..estado = _SyncConstants.desconectado
            ..cajaAsignada = ''
            ..sincronizado = true
            ..fechaSincronizacion = DateTime.now();

          await _isarService.guardarUsuario(placeholder);
          usuarioId = placeholder.id;
          debugPrint(
              '🔧 Placeholder creado para usuario $usuarioUuid → id=$usuarioId');
        }

        if (localOrigenId == 0 || usuarioId == 0) {
          debugPrint(
              '⚠️ Pedido ${pedidoJson['id']} omitido: IDs no encontrados '
              '(origen=$localOrigenId, usuario=$usuarioId)');
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
          .select('id_isar, nombre, pin, rol, email, estado, tenant_id, is_superadmin')
          .eq('id', supabaseId)
          .maybeSingle();
      if (response != null) {
        final estadoNube = response['estado'] as String? ?? _SyncConstants.inactivo;
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
          // 🎯 FIX: mapear is_superadmin para el Control Center.
          ..isSuperadmin = response['is_superadmin'] as bool? ?? false
          // activo se deriva de estado
          ..activo = estadoNube != _SyncConstants.inactivo && estadoNube != _SyncConstants.desconectado
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
          // ⚠️ NO se toma `stock` de la nube: los lotes son la fuente
          // única de verdad (ver `descargarProductosDesdeSupabase`).
          ..stock = 0.0
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
      // ✅ Obtener tenant activo
      final tenantId = getTenantIdFromJWT();
      if (tenantId == null || tenantId.isEmpty) {
        debugPrint('⚠️ [repararImagenes] Sin tenant_id activo. Abortando.');
        return 0;
      }

      final productos = await _isarService.obtenerProductos();
      // Usa el getter `_supabase` (no `Supabase.instance.client` directo) para
      // respetar el `SupabaseClient` inyectado por constructor
      // (`sync_service.dart:171`). Antes esta línea saltaba la inyección y
      // obligaba a los tests a inicializar el singleton global.
      final supabase = _supabase;
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
    // Ver `repararImagenesFaltantes`: el getter respeta el cliente inyectado.
    final client = _supabase;
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
    // 🛠️ FIX: Unificación de banderas - usar _isSyncing en lugar de _syncEnCurso
    if (_isSyncing) {
      debugPrint('⚠️ [SyncService] Sync ya en curso, saltando.');
      return;
    }
    _isSyncing = true;
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

      await _safe(
          'limpiarUsuariosHuerfanos', limpiarUsuariosHuerfanosEnSupabase);
      await _safe('sincronizarUsuariosASupabase', sincronizarUsuariosASupabase);
      await _safe(
          'sincronizarUsuariosDesdeSupabase', sincronizarUsuariosDesdeSupabase);

      await _safe('sincronizarMovimientos', sincronizarMovimientosInventario);
      await _safe('sincronizarTurnos', sincronizarTurnos);

      await _safe('sincronizarGastos', sincronizarGastosPendientes);

      await _safe('sincronizarPedidos', sincronizarPedidosPendientes);
      await _safe('descargarPedidos', descargarPedidosDesdeSupabase);

      await _safe('sincronizarProveedores', sincronizarProveedoresPendientes);
      await _safe('descargarProveedores', descargarProveedoresDesdeSupabase);

      await _safe('sincronizarAlias', sincronizarAliasPendientes);
      await _safe('sincronizarLotes', sincronizarLotesPendientes);
      await _safe('descargarLotes', descargarLotesDesdeSupabase);

      // Movimientos de lote: DESPUES de lotes en ambos sentidos.
      //
      // Un movimiento referencia su lote por `lote_id_isar`. Si el lote se
      // creo en este mismo dispositivo y todavia no subio, el movimiento no
      // puede ir antes o el insert falla por FK. El orden lotes ->
      // movimientos lo evita.
      await _safe('subirMovimientosLote', subirMovimientosLotePendientes);
      await _safe(
          'descargarMovimientosLote', descargarMovimientosLoteDesdeSupabase);

      // ⚠️ Los lotes se descargan DESPUÉS que los productos, así que el
      // recálculo va aquí y no antes: hasta este punto los lotes locales
      // son los previos, no los de la nube.
      //
      // Con el modelo "lotes = fuente única de verdad",
      // `producto.stock` es un cache derivado. Esta llamada es la que
      // hace que la UI muestre el stock correcto tras el sync.
      try {
        final productosSincronizados =
            await _isarService.obtenerProductos();
        final ids = productosSincronizados.map((p) => p.id).toList();
        await _isarService.recalcularStockDe(ids);
        debugPrint(
            '🔄 Stock recalculado desde lotes para ${ids.length} productos');
      } catch (e, stack) {
        debugPrint('⚠️ [SyncService] Error recalculando stock: $e');
        ErrorService.captureError(e,
            stack: stack, hint: 'sincronizarTodo_recalcularStock_fallo');
      }

      // 🎯 FIX: subir locales pendientes ANTES de descargar para no perder
      //    cambios locales (por ejemplo, `businessMode` modificado por el
      //    usuario pero aún no sincronizado).
      await _safe('sincronizarLocales', sincronizarLocalesPendientes);
      await _safe('descargarLocales', descargarLocalesDesdeSupabase);

      // Recetas DESPUÉS de productos y de locales:
      //   · el plato y los ingredientes ya existen en la nube (la RPC
      //     valida la FK contra productos.id_isar),
      //   · el pull necesita resolver el `tenant_id` a un local de Isar.
      await _safe('sincronizarRecetas', sincronizarRecetasPendientes);
      await _safe('descargarRecetas', descargarRecetasDesdeSupabase);

      await _safe(
          'sincronizarDepartamentos', sincronizarDepartamentosPendientes);
      await _safe(
          'descargarDepartamentos', descargarDepartamentosDesdeSupabase);

      // R.1b · Zonas y mesas del salón.
      //
      // Orden obligatorio:
      //   1. Pull de zonas: adopta por nombre las zonas sembradas en este
      //      dispositivo que ya existen en la nube (las deja con UUID).
      //   2. Push de zonas: sin el pull previo chocaría con el índice
      //      único `(tenant_id, nombre)`.
      //   3. Pull de mesas: adopta por nombre y resuelve `zona_id`.
      //   4. Push de mesas: ya puede referenciar la zona por UUID.
      await _safe('descargarZonas', descargarZonasDesdeSupabase);
      await _safe('sincronizarZonas', sincronizarZonasPendientes);
      await _safe('descargarMesas', descargarMesasDesdeSupabase);
      await _safe('sincronizarMesas', sincronizarMesasPendientes);

      await _safe('sincronizarTelegram', sincronizarTelegramConfigPendientes);
      await _safe('descargarTelegram', descargarTelegramConfigDesdeSupabase);

      debugPrint('✅ Sincronización completa finalizada.');
      onDataChanged?.call();
    } catch (e, stack) {
      debugPrint('❌ Error en sincronización completa: $e');
      ErrorService.captureError(e, stack: stack, hint: 'sincronizarTodo_fallo');
    } finally {
      // 🛠️ FIX: Unificación de banderas - liberar _isSyncing
      _isSyncing = false;
    }
  }

  Future<Map<String, int>> sincronizarTodoConResumen() async {
    int ventas = 0, productos = 0, proveedores = 0, gastos = 0;
    int pedidos = 0, lotes = 0, marcas = 0, locales = 0;
    int departamentos = 0, telegram = 0, recetas = 0;
    int zonas = 0, mesas = 0;

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

      // Recetas: DESPUÉS de productos (la RPC valida la FK del plato).
      final recetasPend = await _isarService.obtenerRecetasPendientesSync();
      if (recetasPend.isNotEmpty) {
        await sincronizarRecetasPendientes();
        recetas = recetasPend.length;
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

      final localesPend = await _isarService.obtenerLocalesPendientesSync();
      if (localesPend.isNotEmpty) {
        await sincronizarLocalesPendientes();
        locales = localesPend.length;
      }

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

      // R.1b · Zonas y mesas (mismo orden que `sincronizarTodo`).
      await descargarZonasDesdeSupabase();
      final zonasPend = await _isarService.obtenerZonasPendientesSync();
      if (zonasPend.isNotEmpty) {
        await sincronizarZonasPendientes();
        zonas = zonasPend.length;
      }

      final mesasPend = await _isarService.obtenerMesasPendientesSync();
      if (mesasPend.isNotEmpty) {
        await sincronizarMesasPendientes();
        mesas = mesasPend.length;
      }

      await descargarVentasDesdeSupabase();
      await descargarProductosDesdeSupabase();
      await descargarProveedoresDesdeSupabase();
      await descargarLocalesDesdeSupabase();
      await descargarRecetasDesdeSupabase();
      await descargarDepartamentosDesdeSupabase();
      await descargarTelegramConfigDesdeSupabase();
      await descargarMarcasDesdeSupabase();
      await descargarCategoriasDesdeSupabase();
      await descargarZonasDesdeSupabase();
      await descargarMesasDesdeSupabase();

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
        'recetas': recetas,
        'zonas': zonas,
        'mesas': mesas,
      };
    } catch (e, stack) {
      debugPrint('❌ Error en sincronización completa con resumen: $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'sincronizarTodoConResumen_fallo');
      rethrow;
    }
  }
}
