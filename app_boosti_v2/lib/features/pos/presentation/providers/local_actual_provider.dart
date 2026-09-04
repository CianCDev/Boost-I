// lib/features/pos/presentation/providers/local_actual_provider.dart
import 'package:flutter/foundation.dart'; // ✅ Import necesario para debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';

class LocalActualNotifier extends StateNotifier<int?> {
  LocalActualNotifier() : super(null);

  /// Carga el local actual desde SharedPreferences.
  /// Si no hay, elige el primer local activo y lo guarda.
  Future<void> cargarLocalActual() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('localActualId');

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
      debugPrint('✅ Local actual guardado automáticamente: ${locales.first.nombre} (ID: ${state})');
    } else {
      state = null;
    }
  }

  /// Cambia el local actual y lo guarda en SharedPreferences.
  Future<void> setLocalActual(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final isar = IsarService();
    final local = await isar.obtenerLocalPorId(id);
    if (local != null && local.activo) {
      state = id;
      await prefs.setInt('localActualId', id);
      debugPrint('✅ Local actual cambiado a: ${local.nombre} (ID: $id)');
    } else {
      debugPrint('⚠️ No se puede seleccionar un local inactivo o inexistente.');
    }
  }
}

final localActualProvider = StateNotifierProvider<LocalActualNotifier, int?>((ref) {
  final notifier = LocalActualNotifier();
  notifier.cargarLocalActual();
  return notifier;
});