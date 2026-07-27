import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lock_provider.dart';

class IdleDetector extends ConsumerWidget {
  final Widget child;

  const IdleDetector({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      // Detecta clics del mouse o toques en la pantalla
      onPointerDown: (_) => ref.read(lockProvider.notifier).resetTimer(),
      onPointerMove: (_) => ref.read(lockProvider.notifier).resetTimer(),
      child: Focus(
        autofocus: true,
        // Detecta cualquier tecla presionada en el teclado de la caja
        onKeyEvent: (node, event) {
          ref.read(lockProvider.notifier).resetTimer();
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}
