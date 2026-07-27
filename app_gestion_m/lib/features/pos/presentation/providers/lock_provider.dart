import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LockStateNotifier extends StateNotifier<bool> {
  Timer? _idleTimer;
  final int timeoutMinutes = 3;

  LockStateNotifier() : super(false) {
    _startTimer();
  }

  void _startTimer() {
    _idleTimer?.cancel();
    if (!state) {
      _idleTimer = Timer(Duration(minutes: timeoutMinutes), () => _lockScreen(reason: 'inactivity'));
    }
  }

  void resetTimer() {
    if (!state) {
      _startTimer();
    }
  }

  // 📌 Bloqueo por inactividad o manual con registro en Supabase
  Future<void> _lockScreen({required String reason}) async {
    state = true;
    _idleTimer?.cancel();

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        // Opcional: Registra el evento de descanso/bloqueo en tu base de datos de Supabase
        await supabase.from('cashier_logs').insert({
          'user_id': userId,
          'event_type': 'rest_start',
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Manejo silencioso si estás offline con Isar o sin internet
      print('No se pudo registrar el descanso en Supabase: $e');
    }
  }

  // 📌 Método público para que el cajero active el descanso manualmente desde un botón
  void manualRest() {
    _lockScreen(reason: 'manual');
  }

  Future<void> unlockScreen(String pin) async {
    // Reemplaza esto con tu validación real de PIN (puede ser contra Supabase o Isar)
    if (pin == "1234") { 
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
        print('Error al registrar el fin de descanso: $e');
      }

      state = false;
      _startTimer();
    } else {
      throw Exception("PIN Incorrecto");
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }
}

final lockProvider = StateNotifierProvider<LockStateNotifier, bool>((ref) {
  return LockStateNotifier();
});