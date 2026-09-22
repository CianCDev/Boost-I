// lib/features/pos/presentation/providers/auth_provider.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/services/jwt_service.dart';
import '../services/device_info.dart';
import '../services/sync_service.dart';
import '../services/error_service.dart';
import 'usuario_provider.dart';
import 'tenant_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UsuarioEntity? currentUser;
  final List<UsuarioEntity> usuarios;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
    this.usuarios = const [],
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UsuarioEntity? currentUser,
    List<UsuarioEntity>? usuarios,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,
      usuarios: usuarios ?? this.usuarios,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState());

  /// Carga la lista de usuarios desde Isar.
  /// 
  /// ✅ CAMBIO IMPORTANTE: Ahora trae a TODOS los usuarios (activos e inactivos).
  /// Esto permite que el selector de login muestre a todos los usuarios registrados
  /// en el dispositivo, sin importar si cerraron sesión previamente.
  Future<void> loadUsuarios() async {
    try {
      // Llamada corregida sin argumentos posicionales obligatorios
      final usuarios = await _isarService.obtenerTodosLosUsuarios();
      state = state.copyWith(usuarios: usuarios);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error cargando usuarios: $e');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  Future<bool> loginWithPin(
      UsuarioEntity usuarioSeleccionado, String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1️⃣ Validar localmente (primero, siempre)
      final usuarioValido = await _isarService.validarLogin(
        usuarioSeleccionado.nombre,
        pin,
      );

      if (usuarioValido == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'PIN incorrecto. Inténtalo de nuevo.',
        );
        return false;
      }

      // 2️⃣ Intentar login silencioso en Supabase
      if (usuarioValido.email != null &&
          usuarioValido.email!.isNotEmpty &&
          usuarioValido.password != null &&
          usuarioValido.password!.isNotEmpty) {
        try {
          final response =
              await Supabase.instance.client.auth.signInWithPassword(
            email: usuarioValido.email!,
            password: usuarioValido.password!,
          );

          if (response.session != null) {
            final tenantId =
                JwtService.extraerTenantId(response.session!.accessToken);
            final rolJwt =
                JwtService.extraerRol(response.session!.accessToken);

            if (tenantId != null && tenantId.isNotEmpty) {
              await _ref.read(tenantActualProvider.notifier).setTenant(
                    tenantId,
                    rol: rolJwt,
                  );
              debugPrint('✅ Sesión Supabase + tenant activado: $tenantId');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Login silencioso en Supabase omitido: $e');
        }
      }

      // 3️⃣ Registrar log local
      await _isarService.guardarLog(
        LogEntity()
          ..accion = 'INICIO_SESION'
          ..usuarioNombre = usuarioValido.nombre
          ..usuarioRol = usuarioValido.rol
          ..detalles = 'Inicio de sesión exitoso'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );

      // 4️⃣ Actualizar device_id en Supabase (para monitoreo)
      final deviceId = await DeviceInfoService().getDeviceId();
      if (usuarioValido.supabaseId != null &&
          usuarioValido.supabaseId!.isNotEmpty) {
        try {
          await Supabase.instance.client.from('usuarios').update({
            'device_id': deviceId,
            // Si tienes una columna ultima_actividad, descomenta esto:
            // 'ultima_actividad': DateTime.now().toIso8601String(),
          }).eq('id', usuarioValido.supabaseId!);
        } catch (e) {
          debugPrint('⚠️ No se pudo actualizar device_id: $e');
        }
      }

      // 5️⃣ Fallback del Tenant para logins por PIN (offline)
      if (!_ref.read(tenantActualProvider).tieneTenant) {
        final tId = usuarioValido.tenantId;
        if (tId != null && tId.isNotEmpty) {
          await _ref.read(tenantActualProvider.notifier).setTenant(tId, rol: usuarioValido.rol);
          debugPrint('✅ Tenant local restaurado para uso offline: $tId');
        }
      }

      // 6️⃣ Actualizar estado global
      state = state.copyWith(
        isLoading: false,
        currentUser: usuarioValido,
        errorMessage: null,
      );
      _ref.read(usuarioActualProvider.notifier).setUsuario(usuarioValido);

      ErrorService.setUser(
        usuarioValido.id.toString(),
        usuarioValido.email,
        usuarioValido.nombre,
      );

      await loadUsuarios();
      return true;
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'loginWithPin_fallo');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al iniciar sesión: $e',
      );
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Credenciales inválidas.',
        );
        return false;
      }

      final jwt = response.session!.accessToken;
      final tenantId = JwtService.extraerTenantId(jwt);
      final rolJwt = JwtService.extraerRol(jwt);

      if (tenantId == null || tenantId.isEmpty) {
        debugPrint('⚠️ JWT sin tenant_id. El hook no está configurado.');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Tu cuenta no tiene un local asignado. Contacta al administrador.',
        );
        await supabase.auth.signOut();
        return false;
      }

      await _ref
          .read(tenantActualProvider.notifier)
          .setTenant(tenantId, rol: rolJwt);
      debugPrint('✅ tenant_id guardado: $tenantId (rol: $rolJwt)');

      final data = await supabase
          .from('usuarios')
          .select()
          .eq('id', response.user!.id)
          .single();
      
      final usuario = UsuarioEntity()
        ..id = 0
        ..supabaseId = response.user!.id
        ..nombre = data['nombre'] ?? 'Sin Nombre'
        ..rol = rolJwt ?? data['rol'] ?? 'cajero'
        ..pin = ''
        ..email = email
        ..activo = true;

      final deviceId = await DeviceInfoService().getDeviceId();
      await supabase
          .from('usuarios')
          .update({'device_id': deviceId}).eq('id', response.user!.id);

      state = state.copyWith(
        isLoading: false,
        currentUser: usuario,
        errorMessage: null,
      );
      _ref.read(usuarioActualProvider.notifier).setUsuario(usuario);

      ErrorService.setUser(
        usuario.id.toString(),
        usuario.email,
        usuario.nombre,
      );

      await loadUsuarios();

      try {
        await _syncService.sincronizarTodo();
      } catch (e) {
        debugPrint('⚠️ Error en sync post-login: $e');
      }
      return true;
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'loginWithEmail_fallo',
        extras: {'email': email},
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error en login: $e',
      );
      return false;
    }
  }

  /// Crea un nuevo local (tenant) para el usuario autenticado actual.
  Future<String?> crearNuevoLocal({
    required String nombre,
    String? direccion,
    String? telefono,
    String? email,
    String? rif,
  }) async {
    try {
      final dynamic response = await Supabase.instance.client.rpc(
        'crear_nuevo_local_para_usuario',
        params: {
          'p_nombre': nombre,
          'p_direccion': direccion,
          'p_telefono': telefono,
          'p_email': email,
          'p_rif': rif,
        },
      );

      if (response != null) {
        debugPrint('✅ Local creado con tenant_id: $response');
        return response as String;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error al crear nuevo local: $e');
      rethrow;
    }
  }

  /// Registra una nueva empresa (tenant) llamando a la Edge Function
  Future<bool> registerCompany({
    required String empresa,
    required String adminNombre,
    required String email,
    required String password,
    String? telefono,
    String? rif,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.functions.invoke(
        'create-tenant',
        body: {
          'empresa': empresa,
          'admin_nombre': adminNombre,
          'email': email,
          'password': password,
          if (telefono != null) 'telefono': telefono,
          if (rif != null) 'rif': rif,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: data?['error'] ??
              'No se pudo crear la cuenta. Verifica tus datos o inicia sesión si ya tienes una cuenta.',
        );
        return false;
      }

      debugPrint('✅ Tenant creado: ${data['tenant_id']}');

      final success = await loginWithEmail(email, password);
      return success;
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'registerCompany_fallo',
        extras: {'email': email, 'empresa': empresa},
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo crear la cuenta. Verifica tus datos o inicia sesión si ya tienes una cuenta.',
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerMisLocales() async {
    try {
      final supabase = Supabase.instance.client;
      if (supabase.auth.currentSession == null) {
        return [];
      }

      final response = await supabase.rpc('mis_locales');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'obtenerMisLocales_fallo',
      );
      return [];
    }
  }

  Future<bool> cambiarLocal(String supabaseId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabase = Supabase.instance.client;

      final rpcOk = await supabase.rpc(
        'set_active_tenant',
        params: {'p_tenant_id': supabaseId},
      );

      if (rpcOk != true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudo cambiar el local',
        );
        return false;
      }

      await supabase.auth.refreshSession();

      final session = supabase.auth.currentSession;
      if (session == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sesión expirada. Inicia sesión de nuevo.',
        );
        return false;
      }

      final jwt = session.accessToken;
      final tenantId = JwtService.extraerTenantId(jwt);
      final rolJwt = JwtService.extraerRol(jwt);

      if (tenantId == null || tenantId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'JWT sin tenant_id tras el cambio',
        );
        return false;
      }

      debugPrint('✅ Tenant cambiado a: $tenantId (rol: $rolJwt)');

      await _ref
          .read(tenantActualProvider.notifier)
          .setTenant(tenantId, rol: rolJwt);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tenantId', supabaseId);
      await prefs.reload();
      final verificado = prefs.getString('tenantId');
      if (verificado != supabaseId) {
        debugPrint('❌ auth.cambiarLocal: no se pudo persistir tenantId.');
        return false;
      }
      debugPrint('✅ auth.cambiarLocal: tenant persistido → $verificado');

      state = state.copyWith(isLoading: false, errorMessage: null);
      return true;
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'cambiarLocal_fallo',
        extras: {'nuevoTenantId': supabaseId},
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error cambiando de local: $e',
      );
      return false;
    }
  }

  /// 🔥 Cambiar cajero sin cerrar sesión completa.
  /// 
  /// ✅ CAMBIO IMPORTANTE: Ya NO marca al usuario anterior como 'inactivo' en Supabase.
  /// El estado 'activo/inactivo' ahora representa si la cuenta está habilitada por
  /// el administrador, no si el usuario está logueado en este momento.
  Future<bool> cambiarCajero(UsuarioEntity nuevoCajero, String pin) async {
    // 1. Validar PIN del nuevo cajero
    final validado = await _isarService.validarLogin(nuevoCajero.nombre, pin);
    if (validado == null) {
      state = state.copyWith(
          errorMessage: 'PIN incorrecto para ${nuevoCajero.nombre}');
      return false;
    }

    // 2. Obtener usuario actual
    final usuarioActual = state.currentUser;
    if (usuarioActual == null) {
      state = state.copyWith(errorMessage: 'No hay usuario actual');
      return false;
    }

    // 3. Registrar log de cambio
    await _isarService.guardarLog(LogEntity()
      ..accion = 'CAMBIO_CAJERO'
      ..usuarioNombre = usuarioActual.nombre
      ..usuarioRol = usuarioActual.rol
      ..detalles = 'Cambio de cajero de ${usuarioActual.nombre} a ${nuevoCajero.nombre}'
      ..fecha = DateTime.now()
      ..sincronizado = false);

    // 4. Actualizar estado global localmente (Riverpod)
    state = state.copyWith(
      currentUser: nuevoCajero,
      errorMessage: null,
    );
    _ref.read(usuarioActualProvider.notifier).setUsuario(nuevoCajero);

    // 5. Actualizar monitoreo de errores
    ErrorService.setUser(
      nuevoCajero.id.toString(),
      nuevoCajero.email,
      nuevoCajero.nombre,
    );

    // 6. Recargar lista de usuarios
    await loadUsuarios();

    return true;
  }

 // Cierra la sesión del usuario actual localmente.
/// 
/// ⚠️ IMPORTANTE: Este método NO desconecta el dispositivo de Supabase.
/// 
/// La sesión de nube se mantiene activa aunque no haya usuario logueado,
/// permitiendo que el dispositivo siga sincronizando en segundo plano
/// (productos, pedidos, ventas, etc.). Esto es crítico para POS reales
/// donde múltiples cajeros usan la misma tablet sin reconectar cada vez.
/// 
/// Para desconectar de la nube, el usuario debe usar explícitamente el
/// botón "Desconectar de la nube" en el _CloudStatusBanner del login.
Future<void> logout() async {
  try {
    final userName = state.currentUser?.nombre;
    
    if (state.currentUser != null) {
      debugPrint('🚪 Cerrando sesión local de $userName');

      // 1. Registrar log de cierre de sesión (local, para auditoría)
      await _isarService.guardarLog(
        LogEntity()
          ..accion = 'CIERRE_SESION'
          ..usuarioNombre = userName ?? 'Desconocido'
          ..usuarioRol = state.currentUser!.rol
          ..detalles = 'Cierre de sesión local (nube sigue conectada)'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );

      // ❌ NO llamar a Supabase.instance.client.auth.signOut() aquí.
      //    La sesión de nube se preserva intencionalmente.
      //    Ver comentario del método.
    }

    // 2. Limpiar el estado del usuario actual en Riverpod
    //    (mantenemos la lista de usuarios para el selector)
    state = AuthState(usuarios: state.usuarios);
    _ref.read(usuarioActualProvider.notifier).clearUsuario();

    debugPrint('✅ Logout local completado (dispositivo sigue en la nube)');
  } catch (e, stack) {
    debugPrint('❌ Error en logout: $e');
    ErrorService.captureError(e, stack: stack, hint: 'logout_fallo');

    // Aún si falla, limpiamos el estado local (pero NO el tenant ni la nube)
    state = AuthState(usuarios: state.usuarios);
    _ref.read(usuarioActualProvider.notifier).clearUsuario();
  }
}
}