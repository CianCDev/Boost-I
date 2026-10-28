// lib/features/pos/presentation/services/seed_estaciones_service.dart
//
// PASO E · Sembrado de estaciones de cocina de fábrica.
//
// Cubre los DOS caminos con los que un local termina en `restaurante`:
// el onboarding (`seleccionar_modo_negocio_screen.dart`) y Settings
// (`configuracion_modo_negocio_screen.dart`). Ambos llegan a
// `BusinessModeNotifier.cambiarModo`, que es quien invoca este servicio:
// el seed vive en UN lugar y aplica a los dos. (La primera versión del
// seed vivía solo en la pantalla de Settings: un tenant nuevo que elegía
// restaurante en el onboarding quedaba sin estaciones, justo el caso
// más importante.)
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/departamento_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../providers/departamentos_provider.dart';
import '../providers/usuario_provider.dart';

/// Siembra las estaciones de fábrica del modo restaurante (PASO E).
///
/// Solo siembra si el local NO llega a tener UNA sola estación: si ya
/// tiene —aunque sea una— es un local que se configuró a su manera;
/// sembrar encima sería escribir de más.
///
/// Va contra `IsarService.guardarDepartamento` directo y NO por
/// `guardarDepartamentoProvider`: la familia `family` es una
/// `FutureProvider` pensada para un guardado explícito desde la pantalla;
/// para el seed basta el `put`. La protección contra nombres duplicados
/// la da el propio skip ("sin NINGUNA estación no hay colisión posible").
///
/// Best-effort a propósito: si el seed falla, el modo ya quedó registrado
/// y el local puede crear las estaciones a mano; se anota y se sigue.
class SeedEstacionesRestaurante {
  const SeedEstacionesRestaurante();

  Future<void> sembrar(Ref ref, {required int? localId}) async {
    try {
      final isar = IsarService();
      final existentes = await isar.obtenerDepartamentos(localId: localId);
      if (existentes.isNotEmpty) return;

      final usuarioId = ref.read(usuarioActualProvider)?.id ?? 0;
      final estaciones = <(String nombre, int orden)>[
        ('Cocina', 0),
        ('Barra', 1),
        ('Postres', 2),
      ];
      for (final (nombre, orden) in estaciones) {
        await isar.guardarDepartamento(DepartamentoEntity()
          ..nombre = nombre
          ..descripcion = 'Estación de fábrica (seed)'
          ..orden = orden
          ..localId = localId
          ..usuarioId = usuarioId
          ..activo = true
          ..sincronizado = false);
      }

      // Los providers de departamentos pudieron cargarse antes del seed
      // (Settings los lee): re-disparar para que el KDS, el bulk y el
      // formulario de producto vean el seed sin reiniciar la app.
      ref.invalidate(departamentosProvider);
      ref.invalidate(departamentosConFiltroProvider);
      ref.invalidate(departamentosActivosProvider);
      ref.invalidate(productosPorDepartamentoProvider);

      debugPrint(
        '🍳 [estaciones] seed aplicado '
        '(${estaciones.length} estaciones, local $localId)',
      );
    } catch (e) {
      debugPrint('⚠️ [estaciones] seed falló (best-effort): $e');
    }
  }
}
