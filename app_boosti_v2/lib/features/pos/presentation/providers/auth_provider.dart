// lib/features/pos/presentation/providers/auth_provider.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../services/device_info.dart';
import '../services/sync_service.dart';
import '../services/error_service.dart'; // ✅ NUEVO
import 'usuario_provider.dart';

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

  Future<void> inicializarAdminPorDefecto() async {
    await _isarService.inicializarUsuarioAdminPorDefecto();
    await loadUsuarios();
  }

  Future<bool> loginWithPin(UsuarioEntity usuarioSeleccionado, String pin) async {
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

      // 2️⃣ Login exitoso localmente → intentar sincronizar con Supabase
      if (usuarioValido.email != null && usuarioValido.email!.isNotEmpty) {
        final password = usuarioValido.password ?? pin;
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: usuarioValido.email!,
            password: password,
          );
          debugPrint('✅ Login en Supabase exitoso para ${usuarioValido.nombre}');
        } catch (e) {
          debugPrint('⚠️ Login en Supabase falló (modo offline): $e');
        }
      }

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
        debugPrint('✅ Estado actualizado en Supabase a activo para ${usuarioValido.nombre}');
      } else {
        debugPrint('⚠️ No se pudo actualizar estado en Supabase (continuamos)');
      }

      // Actualizar localmente
      await _isarService.actualizarEstadoUsuario(usuarioValido.id, 'activo');
      debugPrint('✅ Estado local actualizado a activo para ${usuarioValido.nombre}');

      // Guardar device_id (si tiene supabaseUid)
      final deviceId = await DeviceInfoService().getDeviceId();
      if (usuarioValido.supabaseUid != null && usuarioValido.supabaseUid!.isNotEmpty) {
        await Supabase.instance.client
            .from('usuarios')
            .update({'device_id': deviceId})
            .eq('id', usuarioValido.supabaseUid!);
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
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      if (response.user == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Credenciales inválidas.');
        return false;
      }
      final data = await supabase.from('usuarios').select().eq('id', response.user!.id).single();
      final usuario = UsuarioEntity()
        ..id = 0
        ..supabaseUid = response.user!.id
        ..nombre = data['nombre'] ?? 'Sin Nombre'
        ..rol = data['rol'] ?? 'cajero'
        ..pin = ''
        ..email = email
        ..activo = true;

      final deviceId = await DeviceInfoService().getDeviceId();
      await supabase.from('usuarios').update({'device_id': deviceId}).eq('id', response.user!.id);

      state = state.copyWith(isLoading: false, currentUser: usuario, errorMessage: null);
      _ref.read(usuarioActualProvider.notifier).setUsuario(usuario);
      
      // ✅ REGISTRAR USUARIO EN EL MONITOREO
      ErrorService.setUser(
        usuario.id.toString(),
        usuario.email,
        usuario.nombre,
      );
      
      await loadUsuarios();
      return true;
    } catch (e, stack) {
      // ✅ REPORTAR ERROR
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'loginWithEmail_fallo',
        extras: {'email': email},
      );
      state = state.copyWith(isLoading: false, errorMessage: 'Error en login: $e');
      return false;
    }
  }

  // 🔥 NUEVO MÉTODO: Cambiar cajero sin cerrar sesión
  Future<bool> cambiarCajero(UsuarioEntity nuevoCajero, String pin) async {
    // 1. Validar PIN del nuevo cajero
    final validado = await _isarService.validarLogin(nuevoCajero.nombre, pin);
    if (validado == null) {
      state = state.copyWith(errorMessage: 'PIN incorrecto para ${nuevoCajero.nombre}');
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
    await _syncService.actualizarEstadoUsuarioEnSupabase(usuarioActual.id, 'inactivo');

    // 4. Marcar nuevo usuario como activo
    await _isarService.actualizarEstadoUsuario(nuevoCajero.id, 'activo');
    await _syncService.actualizarEstadoUsuarioEnSupabase(nuevoCajero.id, 'activo');

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
      ..detalles = 'Cambio de cajero de ${usuarioActual.nombre} a ${nuevoCajero.nombre}'
      ..fecha = DateTime.now()
      ..sincronizado = false
    );

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
        final successNube = await _syncService.actualizarEstadoUsuarioEnSupabase(userId, 'inactivo');
        if (successNube) {
          debugPrint('✅ Estado actualizado en Supabase a inactivo para $userName');
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

      // 5. Limpiar el estado del usuario actual
      state = AuthState(usuarios: state.usuarios);
      _ref.read(usuarioActualProvider.notifier).clearUsuario();

      debugPrint('✅ Logout completado correctamente');
    } catch (e, stack) {
      debugPrint('❌ Error en logout: $e');
      ErrorService.captureError(e, stack: stack, hint: 'logout_fallo');
      // Aún si falla, intentamos limpiar el estado
      state = AuthState(usuarios: state.usuarios);
      _ref.read(usuarioActualProvider.notifier).clearUsuario();
    }
  }
}