import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/bcv_controller.dart'; // Ajusta la ruta según tu estructura

final bcvProvider = ChangeNotifierProvider<BcvController>((ref) {
  return BcvController();
});