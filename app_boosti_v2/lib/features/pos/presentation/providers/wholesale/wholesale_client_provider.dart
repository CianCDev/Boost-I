// lib/features/pos/presentation/providers/wholesale/wholesale_client_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../data/Local/entities/cliente_entity.dart';
import '../../providers/isar_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════

@immutable
class WholesaleClientState {
  /// Cliente actualmente seleccionado (obligatorio para cobrar).
  final ClienteEntity? cliente;

  /// Texto del buscador.
  final String searchQuery;

  /// Resultados de la búsqueda (live).
  final List<ClienteEntity> resultados;

  /// `true` mientras se busca.
  final bool isSearching;

  /// `true` si el cliente está apto para venta al mayor.
  /// Requiere: RIF + razón social (o nombre como fallback).
  final bool clienteEsValidoParaMayor;

  const WholesaleClientState({
    this.cliente,
    this.searchQuery = '',
    this.resultados = const [],
    this.isSearching = false,
    this.clienteEsValidoParaMayor = false,
  });

  bool get tieneCliente => cliente != null;

  WholesaleClientState copyWith({
    ClienteEntity? cliente,
    bool clearCliente = false,
    String? searchQuery,
    List<ClienteEntity>? resultados,
    bool? isSearching,
    bool? clienteEsValidoParaMayor,
  }) {
    return WholesaleClientState(
      cliente: clearCliente ? null : (cliente ?? this.cliente),
      searchQuery: searchQuery ?? this.searchQuery,
      resultados: resultados ?? this.resultados,
      isSearching: isSearching ?? this.isSearching,
      clienteEsValidoParaMayor:
          clienteEsValidoParaMayor ?? this.clienteEsValidoParaMayor,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════

class WholesaleClientNotifier extends StateNotifier<WholesaleClientState> {
  final Ref _ref;

  WholesaleClientNotifier(this._ref) : super(const WholesaleClientState());

  // ──────────────── Selección ────────────────

  /// Selecciona un cliente. Valida RIF/razón social para venta al mayor.
  void seleccionar(ClienteEntity cliente) {
    final valido = _validarClienteMayor(cliente);
    state = state.copyWith(
      cliente: cliente,
      clienteEsValidoParaMayor: valido,
      resultados: const [],
      searchQuery: '',
    );
  }

  void limpiarSeleccion() {
    state = state.copyWith(
      clearCliente: true,
      clienteEsValidoParaMayor: false,
    );
  }

  // ──────────────── Búsqueda ────────────────

  /// Busca clientes por nombre, RIF o teléfono.
  Future<void> buscar(String query) async {
    final q = query.trim();
    state = state.copyWith(searchQuery: query);

    if (q.isEmpty) {
      state = state.copyWith(resultados: const [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);

    try {
      final isar = _ref.read(isarServiceProvider);
      // Preferimos buscar por RIF si parece un RIF, si no por nombre/tel
      final resultados = await isar.buscarClientes(q);

      // Si no hay resultados por nombre, intentar por RIF directo
      if (resultados.isEmpty) {
        final porRif = await _buscarPorRif(q);
        state = state.copyWith(
          resultados: porRif,
          isSearching: false,
        );
        return;
      }

      state = state.copyWith(
        resultados: resultados.take(20).toList(),
        isSearching: false,
      );
    } catch (e) {
      debugPrint('⚠️ Error buscando clientes: $e');
      state = state.copyWith(resultados: const [], isSearching: false);
    }
  }

  Future<List<ClienteEntity>> _buscarPorRif(String rif) async {
    try {
      final isar = _ref.read(isarServiceProvider);
      final db = await isar.db;
      // Búsqueda case-insensitive sobre el campo rif
      final todos = await db.clienteEntitys.where().findAll();
      final q = rif.toLowerCase();
      return todos
          .where((c) => (c.rif ?? '').toLowerCase().contains(q))
          .take(20)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ──────────────── Validación ────────────────

  /// Un cliente es válido para venta al mayor si tiene RIF **y**
  /// (razón social o nombre). Sin RIF no se permite.
  static bool _validarClienteMayor(ClienteEntity c) {
    final rif = (c.rif ?? '').trim();
    if (rif.isEmpty) return false;
    return true;
  }

  /// Valida un cliente y devuelve el motivo de rechazo (si aplica).
  /// Útil para mostrar en UI al intentar cobrar.
  static String? motivoRechazo(ClienteEntity? c) {
    if (c == null) return 'Selecciona un cliente';
    if ((c.rif ?? '').trim().isEmpty) {
      return 'El cliente no tiene RIF registrado. Edítalo antes de continuar.';
    }
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════

final wholesaleClientProvider =
    StateNotifierProvider<WholesaleClientNotifier, WholesaleClientState>((ref) {
  return WholesaleClientNotifier(ref);
});

// ──────────────── Derivados ────────────────

/// `true` si hay cliente seleccionado y es válido para mayor.
final wholesaleClientReadyProvider = Provider<bool>((ref) {
  final s = ref.watch(wholesaleClientProvider);
  return s.tieneCliente && s.clienteEsValidoParaMayor;
});

/// Motivo de rechazo (null si todo bien).
final wholesaleClientRechazoProvider = Provider<String?>((ref) {
  final s = ref.watch(wholesaleClientProvider);
  return WholesaleClientNotifier.motivoRechazo(s.cliente);
});