// lib/features/pos/presentation/providers/lock_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

class LockStateNotifier extends StateNotifier<bool> {
  final Ref ref;

  LockStateNotifier(this.ref) : super(false);

  Future<void> _lockScreen({required String reason}) async {
    // Si ya está bloqueado o no hay usuario logueado, no hacer nada
    if (state) return;
    final authState = ref.read(authProvider);
    if (authState.currentUser == null) return;

    state = true;

    // Registrar en Supabase (opcional)
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

  // Bloqueo por inactividad
  void lock() {
    _lockScreen(reason: 'inactivity');
  }

  // Bloqueo manual (botón)
  void manualRest() {
    _lockScreen(reason: 'manual');
  }

  // Desbloqueo
  Future<void> unlock() async {
    // Registrar en Supabase
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
  return LockStateNotifier(ref);
});