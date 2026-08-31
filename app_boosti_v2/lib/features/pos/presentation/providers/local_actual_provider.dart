import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

class LocalActualNotifier extends StateNotifier<int?> {
  LocalActualNotifier() : super(null);

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
    // Si no hay, elegir el primero activo
    final isar = IsarService();
    final locales = await isar.obtenerLocales(soloActivos: true);
    if (locales.isNotEmpty) {
      state = locales.first.id;
      await prefs.setInt('localActualId', state!);
    } else {
      state = null;
    }
  }

  Future<void> setLocalActual(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final isar = IsarService();
    final local = await isar.obtenerLocalPorId(id);
    if (local != null && local.activo) {
      state = id;
      await prefs.setInt('localActualId', id);
    }
  }
}

final localActualProvider = StateNotifierProvider<LocalActualNotifier, int?>((ref) {
  final notifier = LocalActualNotifier();
  notifier.cargarLocalActual();
  return notifier;
});