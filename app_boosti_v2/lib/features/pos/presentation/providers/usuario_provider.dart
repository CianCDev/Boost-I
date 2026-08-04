import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/usuario_entity.dart';

// lib/presentation/providers/usuario_provider.dart

class UsuarioNotifier extends StateNotifier<UsuarioEntity?> {
  UsuarioNotifier() : super(null);

  void setUsuario(UsuarioEntity? usuario) {
    state = usuario;
  }

  void clearUsuario() {
    state = null;
  }
}

final usuarioActualProvider = StateNotifierProvider<UsuarioNotifier, UsuarioEntity?>((ref) {
  return UsuarioNotifier();
});