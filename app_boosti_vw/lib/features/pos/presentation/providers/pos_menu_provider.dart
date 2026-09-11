// lib/features/pos/presentation/providers/pos_menu_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../services/sync_service.dart';

class PosMenuState {
  final int ventasPendientesSync;
  final bool sincronizando;
  final TurnoEntity? turnoAbierto;

  PosMenuState({
    this.ventasPendientesSync = 0,
    this.sincronizando = false,
    this.turnoAbierto,
  });

  PosMenuState copyWith({
    int? ventasPendientesSync,
    bool? sincronizando,
    TurnoEntity? turnoAbierto,
  }) {
    return PosMenuState(
      ventasPendientesSync: ventasPendientesSync ?? this.ventasPendientesSync,
      sincronizando: sincronizando ?? this.sincronizando,
      turnoAbierto: turnoAbierto ?? this.turnoAbierto,
    );
  }
}

class PosMenuNotifier extends StateNotifier<PosMenuState> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  PosMenuNotifier() : super(PosMenuState()) {
    cargarEstadoInicial();
  }

  Future<void> cargarEstadoInicial() async {
    await cargarEstadoSync();
    await cargarEstadoTurno();
  }

  Future<void> cargarEstadoSync() async {
    final pendientes = await _isarService.obtenerVentasPendientesSync();
    state = state.copyWith(ventasPendientesSync: pendientes.length);
  }

  Future<void> cargarEstadoTurno() async {
    // Aquí necesitamos el usuario actual; podemos pasarlo como parámetro o leerlo de otro provider.
    // Lo haremos desde el screen, pero también podemos exponer un método que reciba el usuarioId.
  }

  // Métodos que reciben usuarioId y contexto para mostrar mensajes
  Future<void> sincronizarTodo() async {
    if (state.sincronizando) return;
    state = state.copyWith(sincronizando: true);
    try {
      await _syncService.sincronizarTodo();
      await cargarEstadoSync();
    } finally {
      state = state.copyWith(sincronizando: false);
    }
  }

  // Abrir turno (requiere usuario)
  Future<bool> abrirTurno(int usuarioId, String usuarioNombre, String cajaAsignada) async {
    final turnoExistente = await _isarService.obtenerTurnoAbiertoPorUsuario(usuarioId);
    if (turnoExistente != null) return false;

    final nuevoTurno = TurnoEntity()
      ..usuarioId = usuarioId
      ..usuarioNombre = usuarioNombre
      ..cajaId = ''
      ..cajaNombre = cajaAsignada
      ..montoInicial = 0.0
      ..fechaApertura = DateTime.now()
      ..estado = 'abierto'
      ..syncStatus = 'pending';

    await _isarService.guardarTurno(nuevoTurno);
    await _isarService.actualizarEstadoUsuario(usuarioId, 'activo');
    await _syncService.actualizarEstadoUsuarioEnSupabase(usuarioId, 'activo');
    await cargarEstadoTurno(); // recargar turno
    return true;
  }

  // Cerrar turno
  Future<bool> cerrarTurno(int usuarioId) async {
    final turnoAbierto = await _isarService.obtenerTurnoAbiertoPorUsuario(usuarioId);
    if (turnoAbierto == null) return false;

    // Descargar ventas para tener total actualizado
    try {
      await _syncService.descargarVentasDesdeSupabase();
    } catch (e) {
      debugPrint('Error descargando ventas: $e');
    }

    final double montoFinal = await _isarService.obtenerTotalVentasPorEmpleadoYRango(
      turnoAbierto.usuarioNombre,
      turnoAbierto.fechaApertura,
      DateTime.now(),
    );

    turnoAbierto.montoFinal = montoFinal;
    turnoAbierto.fechaCierre = DateTime.now();
    turnoAbierto.estado = 'cerrado';
    turnoAbierto.syncStatus = 'pending';

    await _isarService.guardarTurno(turnoAbierto);
    await _isarService.actualizarEstadoUsuario(usuarioId, 'inactivo');
    await _syncService.sincronizarTurnos();
    await cargarEstadoTurno();
    return true;
  }

  // Cargar turno específico para un usuario
  Future<void> cargarTurnoUsuario(int usuarioId) async {
    final turno = await _isarService.obtenerTurnoAbiertoPorUsuario(usuarioId);
    state = state.copyWith(turnoAbierto: turno);
  }

  // Obtener texto del botón de turno
  String getTurnoButtonText() {
    return state.turnoAbierto != null ? 'Cerrar Turno' : 'Abrir Turno';
  }

  // Obtener color del botón de turno
  Color getTurnoButtonColor() {
    return state.turnoAbierto != null ? const Color(0xFFEF4444) : const Color(0xFF10B981);
  }

  // Obtener icono del botón de turno
  IconData getTurnoIcon() {
    return state.turnoAbierto != null ? Icons.stop_rounded : Icons.play_arrow_rounded;
  }
}

final posMenuProvider = StateNotifierProvider<PosMenuNotifier, PosMenuState>((ref) {
  return PosMenuNotifier();
});