import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_mode.dart';
import '../../pos/presentation/providers/usuario_provider.dart';

/// Provider que indica si el usuario actual tiene acceso al Control Center.
///
/// Requisitos:
///   1. La app debe estar en modo admin ([AppMode.admin]).
///   2. El usuario debe estar autenticado.
///   3. El usuario debe tener `isSuperadmin = true` en Supabase.
final hasAdminAccessProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  final user = ref.watch(usuarioActualProvider);
  
  debugPrint('🔍 [AdminAccess] mode=$mode | isAdmin=${mode.isAdmin}');
  debugPrint('🔍 [AdminAccess] user=${user?.nombre} | isSuperadmin=${user?.isSuperadmin}');
  
  if (!mode.isAdmin) return false;
  return user?.isSuperadmin ?? false;
});