import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// CLAVES DE SHAREDPREFERENCES
// ============================================================
const String kPrefsTenantId = 'tenant_id';
const String kPrefsUserRol = 'user_rol';

// ============================================================
// ESTADO DEL TENANT
// ============================================================

/// Estado inmutable del tenant actual.
///
/// Contiene el `tenant_id` (uuid del local/empresa) y el rol del usuario
/// autenticado. Se obtiene del JWT tras el login con email/password.
class TenantState {
  final String? tenantId;
  final String? rol;

  const TenantState({this.tenantId, this.rol});

  /// Indica si hay un tenant activo.
  bool get tieneTenant => tenantId != null && tenantId!.isNotEmpty;

  /// Indica si el usuario es admin del tenant.
  bool get esAdmin => rol?.toLowerCase() == 'admin';

  TenantState copyWith({
    String? tenantId,
    String? rol,
  }) {
    return TenantState(
      tenantId: tenantId ?? this.tenantId,
      rol: rol ?? this.rol,
    );
  }

  @override
  String toString() => 'TenantState(tenantId: $tenantId, rol: $rol)';
}

// ============================================================
// NOTIFIER
// ============================================================

/// Notifier que gestiona el tenant activo de la sesión.
///
/// Al construirse, carga el `tenant_id` y `user_rol` desde
/// SharedPreferences (persistidos por el login anterior).
///
/// Tras un login exitoso, se debe llamar a [setTenant] con los valores
/// extraídos del JWT. Al hacer logout, se llama a [limpiar].
class TenantNotifier extends StateNotifier<TenantState> {
  TenantNotifier() : super(const TenantState()) {
    _cargarDePrefs();
  }

  /// Carga los valores persistidos de SharedPreferences al arrancar.
  Future<void> _cargarDePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tenantId = prefs.getString(kPrefsTenantId);
      final rol = prefs.getString(kPrefsUserRol);

      if (tenantId != null || rol != null) {
        state = TenantState(tenantId: tenantId, rol: rol);
        debugPrint('✅ Tenant cargado de prefs: $state');
      } else {
        debugPrint('ℹ️ No hay tenant persistido');
      }
    } catch (e) {
      debugPrint('⚠️ Error cargando tenant de prefs: $e');
    }
  }

  /// Guarda el tenant y el rol tras un login exitoso.
  ///
  /// Persiste en SharedPreferences y actualiza el estado.
  Future<void> setTenant(String tenantId, {String? rol}) async {
    if (tenantId.isEmpty) {
      debugPrint('⚠️ Intentando guardar tenant vacío. Ignorado.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPrefsTenantId, tenantId);
      if (rol != null && rol.isNotEmpty) {
        await prefs.setString(kPrefsUserRol, rol);
      }

      state = TenantState(
        tenantId: tenantId,
        rol: rol ?? state.rol,
      );
      debugPrint('✅ Tenant guardado: $state');
    } catch (e) {
      debugPrint('⚠️ Error guardando tenant: $e');
    }
  }

  /// Limpia el tenant actual (usar en logout).
  Future<void> limpiar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kPrefsTenantId);
      await prefs.remove(kPrefsUserRol);
      state = const TenantState();
      debugPrint('✅ Tenant limpiado');
    } catch (e) {
      debugPrint('⚠️ Error limpiando tenant: $e');
    }
  }
}

// ============================================================
// PROVIDER
// ============================================================

/// Provider global del tenant activo.
///
/// Uso:
/// ```dart
/// final tenant = ref.watch(tenantActualProvider);
/// if (tenant.tieneTenant) { ... }
/// ```
final tenantActualProvider =
    StateNotifierProvider<TenantNotifier, TenantState>((ref) {
  return TenantNotifier();
});