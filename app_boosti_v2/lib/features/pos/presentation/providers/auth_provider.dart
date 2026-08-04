// lib/features/pos/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../services/device_info.dart';
import '../services/sync_service.dart';

// Provider para el estado de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Estado de autenticación
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UsuarioEntity? currentUser;
  final List<UsuarioEntity> usuarios; // Lista de usuarios activos para selección en PIN

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

  AuthNotifier() : super(AuthState());

  // Cargar usuarios activos desde Isar
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

/// Establece un mensaje de error
void setError(String message) {
  state = state.copyWith(errorMessage: message);
}

/// Actualiza el usuario seleccionado (opcional)
void selectUser(UsuarioEntity user) {
  // Si necesitas guardar el usuario seleccionado, puedes agregar un campo en AuthState
  // Por ahora no lo necesitamos, lo obtenemos del dropdown en el momento del login.
}

  // Inicializar admin por defecto (si no existe)
  Future<void> inicializarAdminPorDefecto() async {
    await _isarService.inicializarUsuarioAdminPorDefecto();
    await loadUsuarios();
  }

  // Login con PIN
  Future<bool> loginWithPin(UsuarioEntity usuarioSeleccionado, String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
  if (usuarioSeleccionado.email != null && usuarioSeleccionado.email!.isNotEmpty) {
      // Si el usuario tiene email, intentar login con Supabase
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: usuarioSeleccionado.email!,
          password: pin,
        );

        if (response.user == null) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Credenciales inválidas.',
          );
          return false;
        }
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Error en login con Supabase: $e',
        );
        return false;
      }
    }
    try {
      // Primero validar localmente
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

      // Si tiene email, intentar autenticar en Supabase (opcional)
      if (usuarioSeleccionado.email != null && usuarioSeleccionado.email!.isNotEmpty) {
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: usuarioSeleccionado.email!,
            password: pin,
          );
        } catch (e) {
          // Si falla, solo log, pero no impedimos el login local
          debugPrint('Supabase login falló (continuamos offline): $e');
        }
      }

      // Actualizar estado en Supabase (activo)
      await _syncService.actualizarEstadoUsuarioEnSupabase(
        usuarioValido.id,
        'activo',
      );

      // Actualizar localmente
      await _isarService.actualizarEstadoUsuario(usuarioValido.id, 'activo');

      // Guardar device_id en Supabase
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
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al iniciar sesión: $e',
      );
      return false;
    }
  }

  // Login con email/contraseña
  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Credenciales inválidas.',
        );
        return false;
      }

      // Obtener datos del usuario desde la tabla 'usuarios'
      final data = await supabase
          .from('usuarios')
          .select()
          .eq('id', response.user!.id)
          .single();

      final usuario = UsuarioEntity()
        ..id = 0
        ..supabaseUid = response.user!.id
        ..nombre = data['nombre'] ?? 'Sin Nombre'
        ..rol = data['rol'] ?? 'cajero'
        ..pin = ''
        ..email = email
        ..activo = true;

      // Guardar device_id
      final deviceId = await DeviceInfoService().getDeviceId();
      await supabase
          .from('usuarios')
          .update({'device_id': deviceId})
          .eq('id', response.user!.id);

      // Actualizar estado local (opcional: guardar en Isar si quieres persistir)
      // Aquí no lo guardamos porque en este flujo el usuario ya existe en Supabase
      // y lo recuperamos cada login.

      state = state.copyWith(
        isLoading: false,
        currentUser: usuario,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error en login: $e',
      );
      return false;
    }
  }

  // Cerrar sesión (opcional)
  Future<void> logout() async {
    try {
      if (state.currentUser != null) {
        await _syncService.actualizarEstadoUsuarioEnSupabase(
          state.currentUser!.id,
          'inactivo',
        );
        await _isarService.actualizarEstadoUsuario(
          state.currentUser!.id,
          'inactivo',
        );
      }
      await Supabase.instance.client.auth.signOut();
      state = AuthState(usuarios: state.usuarios); // Mantener lista de usuarios
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
  }
}