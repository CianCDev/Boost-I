import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

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

  Future<void> _lockScreen({required String reason}) async {
    state = true;
    _idleTimer?.cancel();

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
    _startTimer();
  }

  Future<void> unlockScreen(String pin) async {
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
        // Error silencioso
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