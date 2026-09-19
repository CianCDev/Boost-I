// lib/features/pos/presentation/providers/local_actual_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/auth_provider.dart';

class LocalActualNotifier extends StateNotifier<int?> {
  final Ref _ref;
  LocalActualNotifier(this._ref) : super(null);

  /// Carga el local actual desde SharedPreferences.
  /// Si no hay, elige el primer local activo y lo guarda.
  Future<void> cargarLocalActual() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('localActualId');

    if (id != null) {
      final isar = IsarService();
      final local = await isar.obtenerLocalPorId(id);
      if (local != null && local.activo) {
        state = id;
        return;
      }
    }

    // No hay local guardado o no existe → buscar el primero activo
    final isar = IsarService();
    final locales = await isar.obtenerLocales(soloActivos: true);
    if (locales.isNotEmpty) {
      state = locales.first.id;
      await prefs.setInt('localActualId', state!);
      debugPrint(
          '✅ Local actual guardado automáticamente: ${locales.first.nombre} (ID: $state)');
    } else {
      state = null;
    }
  }

  /// Cambia el local activo.
  ///
  /// IMPORTANTE: este método hace el cambio REAL del tenant en Supabase
  /// (JWT + es_default + hook) y luego reinicia la app de forma nativa.
  /// Es la única forma segura de cambiar de local, porque Isar abre una
  /// base por tenant.
  ///
  /// Los callers NO necesitan hacer nada más: este método maneja todo.
  Future<void> setLocalActual(int id) async {
    final isar = IsarService();
    final local = await isar.obtenerLocalPorId(id);

    if (local == null || !local.activo) {
      debugPrint('⚠️ No se puede seleccionar un local inactivo o inexistente.');
      return;
    }

    final supabaseId = local.supabaseId;
    if (supabaseId == null || supabaseId.isEmpty) {
      debugPrint(
          '⚠️ El local "${local.nombre}" no tiene supabaseId. No se puede cambiar.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('localActualId', id);

    try {
      final ok =
          await _ref.read(authProvider.notifier).cambiarLocal(supabaseId);

      if (!ok) {
        debugPrint('❌ No se pudo cambiar el tenant en Supabase.');
        return;
      }
    } catch (e) {
      debugPrint('❌ Error al cambiar de local: $e');
      return;
    }

    await prefs.reload();
    if (prefs.getString('tenantId') != supabaseId) {
      debugPrint('⚠️ Forzando persistencia de tenant...');
      await prefs.setString('tenantId', supabaseId);
      await prefs.reload();
      if (prefs.getString('tenantId') != supabaseId) {
        debugPrint(
            '❌ CRÍTICO: no se pudo persistir tenant. Abortando reinicio.');
        return;
      }
    }

    debugPrint('✅ Tenant verificado en disco: ${prefs.getString('tenantId')}');
    debugPrint(
        '✅ Tenant cambiado a "${local.nombre}" ($supabaseId). Reiniciando app...');

    await Future.delayed(const Duration(milliseconds: 800));

    final result = await Restart.restartApp(forceKill: true);
    if (!result.success) {
      debugPrint('❌ Falló reinicio: [${result.code}] ${result.message}');
    } else {
      debugPrint('🔁 Reinicio lanzado (mode: ${result.mode}).');
    }
  }
}

final localActualProvider =
    StateNotifierProvider<LocalActualNotifier, int?>((ref) {
  final notifier = LocalActualNotifier(ref);
  notifier.cargarLocalActual();
  return notifier;
});
