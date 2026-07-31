import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/usuario_entity.dart';

class UsuarioActualNotifier extends Notifier<UsuarioEntity?> {
  @override
  UsuarioEntity? build() {
    // El estado inicia nulo hasta que se inicie sesión
    return null;
  }

  /// Establece el usuario actual y notifica inmediatamente a todos los widgets que escuchan
  void setUsuario(UsuarioEntity usuario) {
    state = usuario;
  }

  /// Limpia la sesión del usuario
  void cerrarSesion() {
    state = null;
  }
}

/// Provider global reactivo para el usuario activo
final usuarioActualProvider =
    NotifierProvider<UsuarioActualNotifier, UsuarioEntity?>(() {
  return UsuarioActualNotifier();
});