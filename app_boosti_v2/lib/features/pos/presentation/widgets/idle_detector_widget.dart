import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lock_provider.dart';

class IdleDetector extends ConsumerWidget {
  final Widget child;

  const IdleDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      onPointerDown: (_) => ref.read(lockProvider.notifier).resetTimer(),
      onPointerMove: (_) => ref.read(lockProvider.notifier).resetTimer(),
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          ref.read(lockProvider.notifier).resetTimer();
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}