// lib/features/pos/presentation/providers/usuario_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/services/jwt_service.dart';
import '../controllers/cart_sessions_controller.dart';
import 'tenant_provider.dart';
import '../utils/pin_hasher.dart';

class UsuariosNotifier extends StateNotifier<UsuarioEntity?> {
  final Ref _ref;

  UsuariosNotifier(this._ref) : super(null);

  void setUsuario(UsuarioEntity? usuario) {
    state = usuario;
  }

  void clearUsuario() {
    state = null;
  }

  /// Cerrar sesión completa:
  /// 1. Elimina los carritos en espera del usuario
  /// 2. Limpia el usuario actual
  Future<void> logout() async {
    try {
      await _ref.read(cartSessionsProvider.notifier).limpiarAlCerrarSesion();
    } catch (_) {
      // Silencioso: aunque falle la limpieza, cerramos sesión
    }
    state = null;
  }

  /// FIX #1: Login con PIN + Sesión Silenciosa en Supabase con validación de Tenant
  Future<bool> loginWithPin(String pin) async {
    final isar = IsarService();
    
    // 1️⃣ Validación local contra Isar
    final usuarioValido = await isar.validarPin(pin);
    if (usuarioValido == null) return false;

    // Asignar al estado de Riverpod
    state = usuarioValido;

    // 2️⃣ Intentar sesión silenciosa en Supabase si hay credenciales
    final email = usuarioValido.email;
    final password = usuarioValido.password;

    if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
      try {
        final sessionActual = Supabase.instance.client.auth.currentSession;

        // Solo autenticar si no hay sesión activa o está expirada
        if (sessionActual == null || sessionActual.isExpired) {
          final response = await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.session != null) {
            final token = response.session!.accessToken;
            final tenantId = JwtService.extraerTenantId(token);
            final rolJwt = JwtService.extraerRol(token);

            if (tenantId != null && tenantId.isNotEmpty) {
              await _ref.read(tenantActualProvider.notifier).setTenant(
                    tenantId,
                    rol: rolJwt,
                  );
              debugPrint('✅ Sesión Supabase reestablecida. Tenant: $tenantId');
            }
          }
        } else {
          // Sesión activa: verificar que el tenant coincide
          final tokenTenant = JwtService.extraerTenantId(sessionActual.accessToken);
          final tenantActual = _ref.read(tenantActualProvider).tenantId;

          if (tokenTenant != null && tokenTenant != tenantActual) {
            debugPrint(
                '⚠️ Sesión actual tiene tenant $tokenTenant pero esperábamos $tenantActual. '
                'Forzando signOut para re-login.');
            await Supabase.instance.client.auth.signOut();
            
            // Opcional: Podrías forzar un nuevo signInWithPassword aquí si lo deseas
          } else if (tokenTenant != null) {
            // Si coincide, refrescamos el provider por si la app recién inicia
            final rolJwt = JwtService.extraerRol(sessionActual.accessToken);
            await _ref.read(tenantActualProvider.notifier).setTenant(
                  tokenTenant,
                  rol: rolJwt,
                );
          }
        }
      } catch (e) {
        debugPrint('⚠️ Login silencioso Supabase falló (Modo Offline): $e');
      }
    } else {
      // ✅ Sin credenciales: cerrar cualquier sesión huérfana
      try {
        final sesion = Supabase.instance.client.auth.currentSession;
        if (sesion != null) {
          debugPrint(
              '🚪 Usuario sin password pero había sesión activa. Cerrando sesión huérfana.');
          await Supabase.instance.client.auth.signOut();
        }
      } catch (e) {
        debugPrint('⚠️ Error cerrando sesión huérfana: $e');
      }
    }

    return true;
  }

  /// FIX #4: Cambio de PIN resiliente (Offline-First)
  Future<({bool exito, String mensaje})> cambiarPin(String nuevoPin) async {
    if (state == null) {
      return (exito: false, mensaje: 'No hay usuario autenticado.');
    }

    // Utiliza la utilidad real del proyecto para hashear el PIN
    final pinHash = PinHasher.hashWithNewSalt(nuevoPin);
    final isar = IsarService();

    // 1️⃣ Guardar inmediatamente en Isar local y marcar como no sincronizado
    state!.pin = pinHash;
    state!.sincronizado = false;
    await isar.guardarUsuario(state!);

    // 2️⃣ Verificar si hay sesión activa para propagar a la nube
    final session = Supabase.instance.client.auth.currentSession;
    final hayConexion = session != null && !session.isExpired;

    if (!hayConexion) {
      // Forzamos actualización del estado visual
      state = state;
      return (
        exito: true,
        mensaje: 'PIN guardado localmente. Se sincronizará con la nube al reconectar.',
      );
    }

    // 3️⃣ Subir a Supabase
    try {
      await Supabase.instance.client
          .from('usuarios')
          .update({'pin': pinHash})
          .eq('id', state!.supabaseId!); // Modificado a supabaseId basado en UsuarioEntity

      // Si sube correctamente, marcamos sincronizado en local
      state!.sincronizado = true;
      await isar.guardarUsuario(state!);

      state = state; // Refrescar Riverpod
      return (exito: true, mensaje: 'PIN actualizado y sincronizado en la nube.');
    } catch (e) {
      debugPrint('⚠️ Error subiendo PIN a Supabase: $e');
      return (
        exito: true,
        mensaje: 'PIN guardado en el dispositivo. Pendiente de sincronización diferida.',
      );
    }
  }
}

final usuarioActualProvider =
    StateNotifierProvider<UsuariosNotifier, UsuarioEntity?>((ref) {
  return UsuariosNotifier(ref);
});

final empleadosPorLocalProvider =
    FutureProvider.family<List<UsuarioEntity>, int>((ref, localId) async {
  final isar = IsarService();
  final usuarios = await isar.obtenerUsuariosActivos();
  return usuarios.where((u) => u.localId == localId).toList();
});

final usuariosProvider = FutureProvider<List<UsuarioEntity>>((ref) async {
  final isar = IsarService();
  return await isar.obtenerUsuariosActivos();
});

final usuarioPorIdProvider =
    FutureProvider.family<UsuarioEntity?, int>((ref, id) async {
  final isar = IsarService();
  return await isar.obtenerUsuarioPorId(id);
});