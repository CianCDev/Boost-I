// lib/features/pos/presentation/providers/auth_provider.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/services/jwt_service.dart';
import '../services/device_info.dart';
import '../services/sync_service.dart';
import '../services/error_service.dart'; // ✅ NUEVO
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

  Future<void> loadUsuarios() async {
    try {
      final usuarios = await _isarService.obtenerUsuariosActivos();
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
      // 2️⃣ Login local exitoso. NO se hace login en Supabase aquí.
      //
      // El JWT con tenant_id se obtiene en loginWithEmail (admin configura
      // el dispositivo). El login por PIN es para uso diario offline.
      //
      // Si se intentara signInWithPassword con el PIN hasheado, fallaría
      // siempre con invalid_credentials (ya que el PIN real no está en Supabase).
      // 3️⃣ Actualizar estado local y en Supabase (device_id, estado)
      await _isarService.guardarLog(
        LogEntity()
          ..accion = 'INICIO_SESION'
          ..usuarioNombre = usuarioValido.nombre
          ..usuarioRol = usuarioValido.rol
          ..detalles = 'Inicio de sesión exitoso'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );

      // Actualizar estado a activo en Supabase
      final successNube = await _syncService.actualizarEstadoUsuarioEnSupabase(
        usuarioValido.id,
        'activo',
      );
      if (successNube) {
        debugPrint(
            '✅ Estado actualizado en Supabase a activo para ${usuarioValido.nombre}');
      } else {
        debugPrint('⚠️ No se pudo actualizar estado en Supabase (continuamos)');
      }

      // Actualizar localmente
      await _isarService.actualizarEstadoUsuario(usuarioValido.id, 'activo');
      debugPrint(
          '✅ Estado local actualizado a activo para ${usuarioValido.nombre}');

      // Guardar device_id (si tiene supabaseUid)
      final deviceId = await DeviceInfoService().getDeviceId();
      if (usuarioValido.supabaseUid != null &&
          usuarioValido.supabaseUid!.isNotEmpty) {
        await Supabase.instance.client.from('usuarios').update(
            {'device_id': deviceId}).eq('id', usuarioValido.supabaseUid!);
      }

      state = state.copyWith(
        isLoading: false,
        currentUser: usuarioValido,
        errorMessage: null,
      );
      _ref.read(usuarioActualProvider.notifier).setUsuario(usuarioValido);

      // ✅ REGISTRAR USUARIO EN EL MONITOREO
      ErrorService.setUser(
        usuarioValido.id.toString(),
        usuarioValido.email,
        usuarioValido.nombre,
      );

      // Cargar lista de usuarios para el diálogo de cambio
      await loadUsuarios();
      return true;
    } catch (e, stack) {
      // ✅ REPORTAR ERROR
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'loginWithPin_fallo',
        extras: {
          'usuario': usuarioSeleccionado.nombre,
          'pinLength': pin.length,
        },
      );
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

      // 1. Validar que hay sesión (usuario + JWT)
      if (response.user == null || response.session == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Credenciales inválidas.',
        );
        return false;
      }

      // 2. Extraer tenant_id y rol del JWT
      final jwt = response.session!.accessToken;
      final tenantId = JwtService.extraerTenantId(jwt);
      final rolJwt = JwtService.extraerRol(jwt);

      if (tenantId == null || tenantId.isEmpty) {
        debugPrint('⚠️ JWT sin tenant_id. El hook no está configurado.');
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Tu cuenta no tiene un local asignado. Contacta al administrador.',
        );
        // Cerrar sesión en Supabase para no dejar sesión huérfana
        await supabase.auth.signOut();
        return false;
      }

      // 3. Guardar el tenant en el provider global
      await _ref
          .read(tenantActualProvider.notifier)
          .setTenant(tenantId, rol: rolJwt);
      debugPrint('✅ tenant_id guardado: $tenantId (rol: $rolJwt)');

      // 4. Cargar datos del usuario desde Supabase
      final data = await supabase
          .from('usuarios')
          .select()
          .eq('id', response.user!.id)
          .single();

      final usuario = UsuarioEntity()
        ..id = 0
        ..supabaseUid = response.user!.id
        ..nombre = data['nombre'] ?? 'Sin Nombre'
        ..rol = rolJwt ?? data['rol'] ?? 'cajero'
        ..pin = ''
        ..email = email
        ..activo = true;

      // 5. Actualizar device_id en Supabase
      final deviceId = await DeviceInfoService().getDeviceId();
      await supabase
          .from('usuarios')
          .update({'device_id': deviceId}).eq('id', response.user!.id);

      // 6. Actualizar estado
      // 6. Actualizar estado
      state = state.copyWith(
        isLoading: false,
        currentUser: usuario,
        errorMessage: null,
      );
      _ref.read(usuarioActualProvider.notifier).setUsuario(usuario);

      // ✅ REGISTRAR USUARIO EN EL MONITOREO
      ErrorService.setUser(
        usuario.id.toString(),
        usuario.email,
        usuario.nombre,
      );

      // 7. Cargar usuarios locales
      await loadUsuarios();

      // 8. Disparar sincronización inicial en segundo plano
      //    (ahora hay JWT con tenant_id → RLS permite el push)
      try {
        await _syncService.sincronizarTodo();
      } catch (e) {
        debugPrint('⚠️ Error en sync post-login: $e');
      }
      return true;
    } catch (e, stack) {
      // ✅ REPORTAR ERROR
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

  // En tu AuthProvider o un nuevo LocalProvider
Future<String?> crearNuevoLocal(String nombre, String direccion) async {
  try {
    // Llamamos a la función SQL 'crear_nuevo_local_para_usuario'
    final dynamic response = await Supabase.instance.client.rpc(
      'crear_nuevo_local_para_usuario',
      params: {
        'p_nombre': nombre,
        'p_direccion': direccion,
      },
    ).select().single(); // .select().single() espera un único valor de retorno (el UUID)

    if (response != null) {
      debugPrint('✅ Local creado con tenant_id: $response');
      
      // Refrescamos la sesión para que el JWT incluya los nuevos datos si es necesario
      await Supabase.instance.client.auth.refreshSession();
      
      // Notificamos a la app que la lista de locales ha cambiado
      // Aquí podrías recargar tus providers de locales.
      
      return response as String;
    }
    return null;
  } catch (e) {
    debugPrint('❌ Error al crear nuevo local: $e');
    // Aquí puedes manejar el error y mostrar un mensaje al usuario.
    rethrow;
  }
}

  /// Registra una nueva empresa (tenant) llamando a la Edge Function
  /// `create-tenant`, y luego hace login con las credenciales para obtener
  /// el JWT con el `tenant_id` correcto.
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

      // 1. Llamar a Edge Function create-tenant
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

      // 2. Ahora hacer login con las mismas credenciales
      //    para obtener el JWT con tenant_id
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
        errorMessage:
            'No se pudo crear la cuenta. Verifica tus datos o inicia sesión si ya tienes una cuenta.',
      );
      return false;
    }
  }

    /// Obtiene la lista de locales a los que el usuario actual tiene acceso.
  ///
  /// Retorna una lista de mapas con: tenant_id, nombre, direccion, rol,
  /// es_default. Lista vacía si falla o no hay sesión.
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

  /// Cambia el local (tenant) activo del usuario.
  ///
  /// Flujo:
  /// 1. Actualiza es_default en `usuarios_locales` vía RPC.
  /// 2. Refresca el JWT de Supabase (el hook inyectará el nuevo tenant_id).
  /// 3. Extrae el nuevo tenant_id del JWT.
  /// 4. Actualiza el tenantActualProvider.
  /// 5. Dispara sync para recargar datos del nuevo tenant.
  ///
  /// Retorna `true` si el cambio fue exitoso.
  Future<bool> cambiarLocal(String nuevoTenantId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabase = Supabase.instance.client;

      // 1. Actualizar es_default en Supabase
      final rpcOk = await supabase.rpc(
        'set_active_tenant',
        params: {'p_tenant_id': nuevoTenantId},
      );

      if (rpcOk != true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudo cambiar el local',
        );
        return false;
      }

      // 2. Refrescar el JWT para que el hook inyecte el nuevo tenant_id
      await supabase.auth.refreshSession();

      final session = supabase.auth.currentSession;
      if (session == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sesión expirada. Inicia sesión de nuevo.',
        );
        return false;
      }

      // 3. Extraer el nuevo tenant_id del JWT
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

      // 4. Actualizar el provider global
      await _ref
          .read(tenantActualProvider.notifier)
          .setTenant(tenantId, rol: rolJwt);

      // 5. Recargar datos del nuevo tenant
      try {
        await _syncService.sincronizarTodo();
      } catch (e) {
        debugPrint('⚠️ Error en sync post-cambio: $e');
      }

      // 6. Recargar usuarios locales
      await loadUsuarios();

      state = state.copyWith(isLoading: false, errorMessage: null);
      return true;
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'cambiarLocal_fallo',
        extras: {'nuevoTenantId': nuevoTenantId},
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error cambiando de local: $e',
      );
      return false;
    }
  }

  // 🔥 NUEVO MÉTODO: Cambiar cajero sin cerrar sesión
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

    // 3. Marcar usuario actual como inactivo (local y remoto)
    await _isarService.actualizarEstadoUsuario(usuarioActual.id, 'inactivo');
    await _syncService.actualizarEstadoUsuarioEnSupabase(
        usuarioActual.id, 'inactivo');

    // 4. Marcar nuevo usuario como activo
    await _isarService.actualizarEstadoUsuario(nuevoCajero.id, 'activo');
    await _syncService.actualizarEstadoUsuarioEnSupabase(
        nuevoCajero.id, 'activo');

    // 5. (Opcional) Sincronizar usuarios desde Supabase para actualizar otros dispositivos
    try {
      await _syncService.sincronizarUsuariosDesdeSupabase();
    } catch (e) {
      debugPrint('⚠️ Error sincronizando usuarios después del cambio: $e');
    }

    // 6. Registrar log
    await _isarService.guardarLog(LogEntity()
      ..accion = 'CAMBIO_CAJERO'
      ..usuarioNombre = usuarioActual.nombre
      ..usuarioRol = usuarioActual.rol
      ..detalles =
          'Cambio de cajero de ${usuarioActual.nombre} a ${nuevoCajero.nombre}'
      ..fecha = DateTime.now()
      ..sincronizado = false);

    // 7. Actualizar estado global
    state = state.copyWith(
      currentUser: nuevoCajero,
      errorMessage: null,
    );
    _ref.read(usuarioActualProvider.notifier).setUsuario(nuevoCajero);

    // ✅ ACTUALIZAR USUARIO EN MONITOREO
    ErrorService.setUser(
      nuevoCajero.id.toString(),
      nuevoCajero.email,
      nuevoCajero.nombre,
    );

    // 8. Recargar lista de usuarios
    await loadUsuarios();

    return true;
  }

  Future<void> logout() async {
    try {
      if (state.currentUser != null) {
        final userId = state.currentUser!.id;
        final userName = state.currentUser!.nombre;
        debugPrint('🚪 Cerrando sesión de $userName (ID: $userId)');

        // 1. Actualizar estado en Supabase
        final successNube = await _syncService
            .actualizarEstadoUsuarioEnSupabase(userId, 'inactivo');
        if (successNube) {
          debugPrint(
              '✅ Estado actualizado en Supabase a inactivo para $userName');
        } else {
          debugPrint('⚠️ No se pudo actualizar estado en Supabase');
        }

        // 2. Actualizar estado local
        await _isarService.actualizarEstadoUsuario(userId, 'inactivo');
        debugPrint('✅ Estado local actualizado a inactivo para $userName');

        // 3. 🔥 FORZAR sincronización desde Supabase para actualizar el monitor
        try {
          await _syncService.sincronizarUsuariosDesdeSupabase();
          debugPrint('✅ Sincronización post-logout completada');
        } catch (e) {
          debugPrint('⚠️ Error en sincronización post-logout: $e');
        }
      }
      await _isarService.guardarLog(
        LogEntity()
          ..accion = 'CIERRE_SESION'
          ..usuarioNombre = state.currentUser?.nombre ?? 'Desconocido'
          ..usuarioRol = state.currentUser?.rol ?? ''
          ..detalles = 'Cierre de sesión'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );

      // 4. Cerrar sesión en Supabase
      await Supabase.instance.client.auth.signOut();

      // 5. Limpiar el tenant activo
      await _ref.read(tenantActualProvider.notifier).limpiar();

      // 6. Limpiar el estado del usuario actual
      state = AuthState(usuarios: state.usuarios);
      _ref.read(usuarioActualProvider.notifier).clearUsuario();

      debugPrint('✅ Logout completado correctamente');
    } catch (e, stack) {
      debugPrint('❌ Error en logout: $e');
      ErrorService.captureError(e, stack: stack, hint: 'logout_fallo');
      // Aún si falla, intentamos limpiar el estado
      await _ref.read(tenantActualProvider.notifier).limpiar();
      state = AuthState(usuarios: state.usuarios);
      _ref.read(usuarioActualProvider.notifier).clearUsuario();
    }
  }
}