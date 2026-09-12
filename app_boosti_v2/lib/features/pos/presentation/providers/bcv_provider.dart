// lib/features/pos/presentation/providers/bcv_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/bcv_controller.dart';

final bcvProvider = ChangeNotifierProvider<BcvController>((ref) {
  return BcvController();
});

/// Tasas disponibles para el diálogo de cobro.
///
/// Se reconstruye automáticamente cada vez que `BcvController`
/// llama a `notifyListeners()` (por ejemplo, al actualizar tasas).
///
/// Solo incluye tasas > 0 para que el selector del diálogo no muestre
/// opciones inválidas (ej: EUR cuando el país no maneja euro o aún no
/// se ha cargado la tasa).
final tasasDisponiblesProvider = Provider<Map<String, double>>((ref) {
  final bcv = ref.watch(bcvProvider);

  final tasas = <String, double>{};

  // USD: siempre debe estar, con fallback a 1.0 si aún no hay tasa.
  final usd = (bcv.tasa.isNaN || bcv.tasa <= 0) ? 1.0 : bcv.tasa;
  tasas['USD'] = usd;

  // EUR: solo si es válido (> 0).
  if (!bcv.tasaEuro.isNaN && bcv.tasaEuro > 0) {
    tasas['EUR'] = bcv.tasaEuro;
  }

  return tasas;
});