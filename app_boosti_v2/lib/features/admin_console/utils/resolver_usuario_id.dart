import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../pos/presentation/providers/usuario_provider.dart';

/// Resuelve el UUID del usuario actual para auditar escrituras.
///
/// Cascada:
///   1. El usuario de la app (POS, con Isar cargado).
///   2. La sesión de Supabase Auth (Control Center).
///   3. `null`, que las columnas nullable aceptan.
///
/// Antes se usaban los centinelas `'sistema'` y `'desconocido'`, que
/// **no son UUID válidos** y hacían fallar el `INSERT`/`UPDATE` con
/// «invalid input syntax for type uuid». Las columnas afectadas son
/// `notas_cliente.autor_id`, `pagos.registrado_por` y
/// `suscripcion_historial.cambiado_por`.
String? resolverUsuarioId(Ref ref) {
  final deProvider = ref.read(usuarioActualProvider)?.supabaseId;
  if (deProvider != null && deProvider.isNotEmpty) return deProvider;

  final deAuth = Supabase.instance.client.auth.currentUser?.id;
  if (deAuth != null && deAuth.isNotEmpty) return deAuth;

  return null;
}