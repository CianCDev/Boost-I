// lib/features/pos/presentation/providers/lock_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
import '../services/error_service.dart';

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
    } catch (e, stack) {
      // Antes esto era `catch (e) { // Error silencioso }`: la tabla no
      // existía, el insert fallaba, el catch se comía el error y nadie
      // sabía que los eventos de caja no se estaban registrando.
      ErrorService.captureError(e,
          stack: stack,
          hint: 'cashier_logs_insert_fallo',
          extras: {'event_type': 'rest_start', 'motivo': reason});
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
    } catch (e, stack) {
      // Mismo catch mudo que en `_lockScreen`.
      ErrorService.captureError(e,
          stack: stack,
          hint: 'cashier_logs_insert_fallo',
          extras: {'event_type': 'rest_end'});
    }
    state = false;
  }
}

final lockProvider = StateNotifierProvider<LockStateNotifier, bool>((ref) {
  return LockStateNotifier(ref);
});