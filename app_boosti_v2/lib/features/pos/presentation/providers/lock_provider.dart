import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LockStateNotifier extends StateNotifier<bool> {
  LockStateNotifier() : super(false);

  Future<void> _lockScreen({required String reason}) async {
    if (state) return; // Si ya está bloqueado, evitamos múltiples registros
    state = true;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        await supabase.from('cashier_logs').insert({
          'user_id': userId,
          'event_type': 'rest_start',
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Error silencioso
    }
  }

  // Se activa por inactividad desde el UserActivityDetector
  void lock() {
    _lockScreen(reason: 'inactivity');
  }

  // Se activa manualmente desde el botón de la UI
  void manualRest() {
    _lockScreen(reason: 'manual');
  }

  Future<void> unlock() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('cashier_logs').insert({
          'user_id': userId,
          'event_type': 'rest_end',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Error silencioso
    }
    state = false;
  }
}

final lockProvider = StateNotifierProvider<LockStateNotifier, bool>((ref) {
  return LockStateNotifier();
});