// lib/features/pos/presentation/providers/catalog/view_mode_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ViewMode { grid, list }

final viewModeProvider = StateNotifierProvider<ViewModeNotifier, ViewMode>((ref) {
  return ViewModeNotifier();
});

class ViewModeNotifier extends StateNotifier<ViewMode> {
  static const String _key = 'view_mode_preference';

  ViewModeNotifier() : super(ViewMode.grid) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value == 'list') {
        state = ViewMode.list;
      } else {
        state = ViewMode.grid;
      }
    } catch (_) {
      state = ViewMode.grid;
    }
  }

  Future<void> _savePreference(ViewMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode == ViewMode.list ? 'list' : 'grid');
    } catch (_) {}
  }

  void toggle() {
    final newMode = state == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    state = newMode;
    _savePreference(newMode);
  }

  void setMode(ViewMode mode) {
    if (state != mode) {
      state = mode;
      _savePreference(mode);
    }
  }
}