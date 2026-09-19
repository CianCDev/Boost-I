// lib/features/pos/presentation/providers/empleados/monitor_empleados_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/json_utils.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../services/sync_service.dart';
import '../isar_provider.dart';
import '../sync_provider.dart';

class MonitorEmpleadosState {
  final List<UsuarioEntity> usuarios;
  final bool isLoading;
  final String? error;
  final DateTime? lastSync;

  const MonitorEmpleadosState({
    this.usuarios = const [],
    this.isLoading = true,
    this.error,
    this.lastSync,
  });

  MonitorEmpleadosState copyWith({
    List<UsuarioEntity>? usuarios,
    bool? isLoading,
    String? error,
    DateTime? lastSync,
    bool clearError = false,
  }) {
    return MonitorEmpleadosState(
      usuarios: usuarios ?? this.usuarios,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastSync: lastSync ?? this.lastSync,
    );
  }

  /// Departamentos únicos detectados en la lista.
  List<String> get departamentos {
    final set = usuarios
        .map((u) => u.departamento ?? '')
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }
}

class MonitorEmpleadosNotifier extends StateNotifier<MonitorEmpleadosState> {
  final Ref _ref;
  late final IsarService _isarService;
  late final SyncService _syncService;
  Timer? _timer;
  bool _syncing = false;

  MonitorEmpleadosNotifier(this._ref) : super(const MonitorEmpleadosState()) {
    _isarService = _ref.read(isarServiceProvider);
    _syncService = _ref.read(syncServiceProvider);
    _iniciar();
  }

  void _iniciar() {
    sincronizar();
    // Auto-refresh cada 8 s (equivalente al monitor)
    _timer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => sincronizar(silencioso: true),
    );
  }

  /// Sincroniza usuarios desde Supabase y refresca el estado.
  ///
  /// [silencioso] → no marca `isLoading` (para el timer periódico).
  Future<void> sincronizar({bool silencioso = false}) async {
    if (_syncing) return;
    _syncing = true;

    if (!silencioso) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      // 1. Bajar usuarios desde Supabase (pobla/actualiza Isar).
      await _syncService.sincronizarUsuariosDesdeSupabase();

      // 2. Traer la lista cruda con su `estado` real y aplicarlo.
      await _actualizarEstadosDesdeNube();

      // 3. Leer usuarios frescos de Isar.
      final usuarios = await _isarService.obtenerUsuarios();

      state = state.copyWith(
        usuarios: usuarios,
        isLoading: false,
        lastSync: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    } finally {
      _syncing = false;
    }
  }

  /// Igual que el monitor original: compara `estado` nube ↔ local y aplica.
  Future<void> _actualizarEstadosDesdeNube() async {
    final nube = await _syncService.obtenerUsuariosDesdeSupabase();
    if (nube.isEmpty) return;

    final Map<int, String> estadosNube = {};
    for (final row in nube) {
      final id = safeInt(row['id_isar']);
      if (id != null) {
        final raw = (row['estado'] as String?)?.toLowerCase().trim();
        if (raw != null && raw.isNotEmpty) {
          estadosNube[id] = raw;
        }
      }
    }
    if (estadosNube.isEmpty) return;

    final locales = await _isarService.obtenerUsuarios();
    for (final local in locales) {
      final estadoNube = estadosNube[local.id];
      if (estadoNube == null) continue;
      if (local.estado == estadoNube) continue;

      await _isarService.actualizarEstadoUsuario(local.id, estadoNube);
      // ignore: avoid_print
      print('🔄 Empleados: ${local.nombre} → $estadoNube');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider autoDispose: el timer vive mientras haya al menos
/// un listener (pantalla o diálogo). Al cerrar todo, se limpia solo.
final monitorEmpleadosProvider = StateNotifierProvider.autoDispose<
    MonitorEmpleadosNotifier, MonitorEmpleadosState>(
  (ref) => MonitorEmpleadosNotifier(ref),
);
