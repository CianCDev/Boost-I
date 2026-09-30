import 'package:flutter/material.dart';

class KeyboardVisibilityBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isKeyboardVisible) builder;

  const KeyboardVisibilityBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<KeyboardVisibilityBuilder> createState() => _KeyboardVisibilityBuilderState();
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    final isVisible = bottomInset > 0;

    if (isVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isKeyboardVisible);
  }
}