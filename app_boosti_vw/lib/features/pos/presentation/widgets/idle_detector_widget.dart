import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lock_provider.dart';

class UserActivityDetector extends ConsumerStatefulWidget {
  final Widget child;
  final Duration timeout;

  const UserActivityDetector({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 3),
  });

  @override
  ConsumerState<UserActivityDetector> createState() => _UserActivityDetectorState();
}

class _UserActivityDetectorState extends ConsumerState<UserActivityDetector> {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(widget.timeout, _lockScreen);
  }

  void _resetTimer() {
    // Evita reiniciar el temporizador si la caja ya está bloqueada
    final isLocked = ref.read(lockProvider); 
    if (!isLocked) {
      _startTimer();
    }
  }

  void _lockScreen() {
    ref.read(lockProvider.notifier).lock();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      // Detecta movimiento del mouse en escritorio/web
      child: MouseRegion(
        onHover: (_) => _resetTimer(),
        child: widget.child,
      ),
    );
  }
}