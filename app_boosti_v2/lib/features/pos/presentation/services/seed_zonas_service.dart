// lib/features/pos/presentation/services/seed_zonas_service.dart
//
// R.1b · Sembrado de zonas de fábrica.
//
// Cubre dos casos:
//
//   1. Un local que acaba de pasar a `restaurante` y no tiene ninguna
//      zona: crea las 5 históricas (Salón, Terraza, Bar, Privado, VIP)
//      para que el salón y la caja tengan filtros desde el primer día.
//
//   2. Un local que YA tenía mesas de antes de R.1b: no crea nada, pero
//      completa `MesaEntity.zonaNombre` desde el enum legacy. Sin esto,
//      la mesa seguiría mostrando la etiqueta del enum y el sync no
//      sabría a qué zona apuntar.
//
// A diferencia de `SeedEstacionesRestaurante`, este servicio NO invalida
// providers: lo llama `MesasNotifier.cargar()` y el notifier es quien
// recarga su propio estado. Invalidar desde dentro crearía el ciclo de
// Riverpod que documenta `local_actual_provider.dart:268-280`.
import 'package:flutter/foundation.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/mesa_entity.dart';
import '../../data/Local/entities/zona_entity.dart';

class SeedZonasRestaurante {
  const SeedZonasRestaurante();

  /// Zonas de fábrica, en el orden histórico del enum.
  static const List<(String, int)> _zonasFabrica = [
    ('Salón', 0),
    ('Terraza', 1),
    ('Bar', 2),
    ('Privado', 3),
    ('VIP', 4),
  ];

  /// Siembra zonas y migra las mesas antiguas.
  ///
  /// Devuelve `true` si escribió algo (el caller debe recargar).
  /// Best-effort: un fallo no debe romper la carga del salón.
  Future<bool> sembrar({
    required int localId,
    IsarService? isarService,
  }) async {
    if (localId <= 0) return false;
    final isar = isarService ?? IsarService();

    try {
      final zonas = await isar.obtenerZonasDelLocal(localId, soloActivas: false);
      final mesas = await isar.obtenerMesasDelLocal(localId);
      var escribio = false;

      if (zonas.isEmpty) {
        for (final (nombre, orden) in _zonasFabrica) {
          await isar.guardarZona(ZonaEntity()
            ..localId = localId
            ..nombre = nombre
            ..orden = orden
            ..activo = true
            ..sincronizado = false);
        }
        escribio = true;
        debugPrint('🪑 [zonas] seed aplicado (${_zonasFabrica.length} zonas, '
            'local $localId)');
      }

      // Migración de mesas anteriores a R.1b: el nombre de la zona pasa
      // del enum al campo editable.
      for (final mesa in mesas) {
        if ((mesa.zonaNombre ?? '').trim().isNotEmpty) continue;
        mesa.zonaNombre = etiquetaZonaLegacy(mesa.zona);
        await isar.guardarMesa(mesa);
        escribio = true;
      }

      return escribio;
    } catch (e) {
      debugPrint('⚠️ [zonas] seed falló (best-effort): $e');
      return false;
    }
  }
}
