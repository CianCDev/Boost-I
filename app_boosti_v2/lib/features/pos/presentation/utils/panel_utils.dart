import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/panel/panel_provider.dart';
import '../widgets/panel/side_panel.dart';

void showSidePanel(BuildContext context) {
  final provider = Provider.of<PanelProvider>(context, listen: false);
  if (provider.isOpen) return; // Evitar múltiples aperturas

  provider.openPanel();

  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (ctx) => SidePanel(
      screenContext: context,
      onClose: () {
        provider.closePanel();
        entry?.remove();
        entry = null;
      },
    ),
  );
  Overlay.of(context).insert(entry!);
}