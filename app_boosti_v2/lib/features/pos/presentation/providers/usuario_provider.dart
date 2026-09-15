// lib/features/pos/presentation/providers/usuario_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../controllers/cart_sessions_controller.dart';

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