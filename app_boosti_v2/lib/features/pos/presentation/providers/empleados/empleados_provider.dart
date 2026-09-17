// lib/features/pos/presentation/providers/empleados/empleados_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../data/Local/entities/empleado_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/models/empleado_view_model.dart';

/// Provider que devuelve todos los empleados con su info extendida.
///
/// Combina `UsuarioEntity` + `EmpleadoInfoEntity` en `EmpleadoViewModel`.
/// Excluye los usuarios marcados como eliminados (si aplica) pero
/// incluye inactivos para que el admin pueda verlos en el filtro.
final empleadosProvider = FutureProvider.autoDispose<List<EmpleadoViewModel>>(
  (ref) async {
    final isar = await IsarService().db;

    final usuarios = await isar.usuarioEntitys.where().findAll();
    final infos = await isar.empleadoInfoEntitys.where().findAll();

    // Indexar infos por usuarioId para lookup O(1)
    final infoMap = <int, EmpleadoInfoEntity>{
      for (final info in infos) info.usuarioId: info,
    };

    return usuarios
        .map((u) => EmpleadoViewModel(
              usuario: u,
              info: infoMap[u.id],
            ))
        .toList();
  },
);