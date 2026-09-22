// lib/features/pos/presentation/providers/bcv_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/bcv_controller.dart';

final bcvProvider = ChangeNotifierProvider<BcvController>((ref) {
  final controller = BcvController();
  
  // FIX 1: Llamar al método init() al crear la instancia del Provider.
  // Sin esto, la app nunca lee el SharedPreferences al arrancar.
  // Como el controller gestiona su bandera _initialized internamente, es seguro hacerlo aquí.
  controller.init();
  
  return controller;
});

/// Tasas disponibles para el diálogo de cobro.
/// Solo incluye tasas válidas (> 0) y permitidas por el país.
final tasasDisponiblesProvider = Provider<Map<String, double>>((ref) {
  final bcv = ref.watch(bcvProvider);

  final tasas = <String, double>{};

  // USD: solo si es válido. Nada de fallback a 1.0.
  if (bcv.tieneTasa) {
    tasas['USD'] = bcv.tasa;
  }

  // FIX 2: Validar también que el país actual admita Euros.
  // Previene que se muestre una tasa EUR fantasma en la UI.
  if (bcv.manejaEuro && bcv.tasaEuro > 0) {
    tasas['EUR'] = bcv.tasaEuro;
  }

  return tasas;
});

/// `true` si la tasa actual requiere que la UI muestre una advertencia.
final tasaRequiereAtencionProvider = Provider<bool>((ref) {
  final bcv = ref.watch(bcvProvider);
  
  // FIX 3: Usar la fuente de verdad del propio controller. 
  // Si hay un mensaje de advertencia (sin tasa, manual, obsoleta, etc.), requiere atención.
  return bcv.mensajeAdvertencia != null;
});

/// `true` si la app puede convertir montos (hay alguna tasa usable).
final puedeConvertirProvider = Provider<bool>((ref) {
  return ref.watch(bcvProvider).puedeOperar;
});