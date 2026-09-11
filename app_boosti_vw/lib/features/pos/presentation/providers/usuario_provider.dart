import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';

// lib/presentation/providers/usuario_provider.dart

class UsuariosNotifier extends StateNotifier<UsuarioEntity?> {
  UsuariosNotifier() : super(null);

  void setUsuario(UsuarioEntity? usuario) {
    state = usuario;
  }

  void clearUsuario() {
    state = null;
  }
}

final usuarioActualProvider = StateNotifierProvider<UsuariosNotifier, UsuarioEntity?>((ref) {
  return UsuariosNotifier();
});

final empleadosPorLocalProvider = FutureProvider.family<List<UsuarioEntity>, int>((ref, localId) async {
  final isar = IsarService();
  final usuarios = await isar.obtenerUsuariosActivos();
  return usuarios.where((u) => u.localId == localId).toList();
});

final usuariosProvider = FutureProvider<List<UsuarioEntity>>((ref) async {
  final isar = IsarService();
  return await isar.obtenerUsuariosActivos();
});

final usuarioPorIdProvider = FutureProvider.family<UsuarioEntity?, int>((ref, id) async {
  final isar = IsarService();
  return await isar.obtenerUsuarioPorId(id);
});