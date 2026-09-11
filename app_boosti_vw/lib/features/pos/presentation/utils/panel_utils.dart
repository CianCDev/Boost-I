import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/panel_provider.dart';
import '../widgets/panel/side_panel.dart';

void showSidePanel(BuildContext context, WidgetRef ref) {
  // Ya no necesitamos leer el provider aquí porque SidePanel usará su propio ref
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => SidePanel(
      screenContext: context,
      onClose: () => Navigator.pop(context),
    ),
  );
}