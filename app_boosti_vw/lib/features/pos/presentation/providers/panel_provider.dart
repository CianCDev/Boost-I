import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/panel_controller.dart';

final panelControllerProvider = Provider<PanelController>((ref) {
  // 🔥 Cambio: Quitamos 'ref' porque tu controlador no lo usa en su constructor
  return PanelController();
});