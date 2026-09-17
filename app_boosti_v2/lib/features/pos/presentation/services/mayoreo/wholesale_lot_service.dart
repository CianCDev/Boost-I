// lib/features/pos/domain/services/wholesale_lot_service.dart
import 'package:flutter/foundation.dart';

import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/lote_entity.dart';
import '../../../data/Local/entities/movimiento_lote_entity.dart';


/// Representa cuánto tomar de un lote específico.
class AsignacionLote {
  final int loteId;
  final double cantidad;
  final double? costoUnitario;
  final DateTime? fechaVencimiento;

  const AsignacionLote({
    required this.loteId,
    required this.cantidad,
    this.costoUnitario,
    this.fechaVencimiento,
  });
}

/// Excepción lanzada cuando no hay stock suficiente.
class StockInsuficienteException implements Exception {
  final String productoNombre;
  final double solicitado;
  final double disponible;

  StockInsuficienteException({
    required this.productoNombre,
    required this.solicitado,
    required this.disponible,
  });

  @override
  String toString() =>
      'Stock insuficiente para "$productoNombre": '
      'solicitado ${solicitado.toStringAsFixed(2)}, '
      'disponible ${disponible.toStringAsFixed(2)}';
}

/// Servicio de gestión de lotes con FEFO (First Expired, First Out).
///
/// Ordena por fecha de vencimiento ASC (nulos al final), desempatando por
/// fecha de ingreso ASC (FIFO).
class WholesaleLotService {
  final IsarService _isarService;

  WholesaleLotService({IsarService? isarService})
      : _isarService = isarService ?? IsarService();

  // ──────────────── Ordenamiento puro ────────────────

  /// Ordena lotes según FEFO. **Método puro, testeable sin Isar.**
  static List<LoteEntity> ordenarFEFO(List<LoteEntity> lotes) {
    final copia = List<LoteEntity>.from(lotes);
    copia.sort((a, b) {
      // 1. Lotes con vencimiento primero, por fecha ASC
      final aVence = a.fechaVencimiento;
      final bVence = b.fechaVencimiento;

      if (aVence != null && bVence != null) {
        final cmp = aVence.compareTo(bVence);
        if (cmp != 0) return cmp;
      } else if (aVence != null && bVence == null) {
        return -1; // a primero
      } else if (aVence == null && bVence != null) {
        return 1; // b primero
      }

      // 2. Desempate: fecha de ingreso ASC (FIFO)
      return a.fechaIngreso.compareTo(b.fechaIngreso);
    });
    return copia;
  }

  // ──────────────── Planificación ────────────────

  /// Calcula qué lotes usar y cuánto tomar de cada uno.
  ///
  /// **No modifica la BD.** Solo devuelve el plan.
  ///
  /// Lanza [StockInsuficienteException] si no hay suficiente stock.
  Future<List<AsignacionLote>> planificar({
    required int productoId,
    required double cantidad,
    required String productoNombre,
  }) async {
    if (cantidad <= 0) return [];

    // 1. Obtener lotes con stock > 0
    final todosLosLotes = await _isarService.obtenerLotesPorProducto(productoId);
    final lotes = todosLosLotes
        .where((l) => l.cantidadRestante > 0.001)
        .toList();

    // 2. Ordenar FEFO
    final ordenados = ordenarFEFO(lotes);

    // 3. Recorrer y calcular asignaciones
    final plan = <AsignacionLote>[];
    double restante = cantidad;

    for (final lote in ordenados) {
      if (restante <= 0.001) break;

      final tomar = restante < lote.cantidadRestante
          ? restante
          : lote.cantidadRestante;

      plan.add(AsignacionLote(
        loteId: lote.id,
        cantidad: tomar,
        costoUnitario: lote.costoUnitario,
        fechaVencimiento: lote.fechaVencimiento,
      ));

      restante -= tomar;
    }

    // 4. Verificar stock
    if (restante > 0.001) {
      final totalDisponible = ordenados.fold<double>(
        0,
        (sum, l) => sum + l.cantidadRestante,
      );
      throw StockInsuficienteException(
        productoNombre: productoNombre,
        solicitado: cantidad,
        disponible: totalDisponible,
      );
    }

    return plan;
  }

  /// Calcula el costo total del plan (costo promedio ponderado).
  static double calcularCostoTotal(List<AsignacionLote> plan) {
    return plan.fold<double>(0, (sum, a) {
      final costo = a.costoUnitario ?? 0.0;
      return sum + (costo * a.cantidad);
    });
  }

  /// Devuelve el **costo unitario promedio ponderado** del plan.
  static double calcularCostoPromedio(List<AsignacionLote> plan) {
    final total = plan.fold<double>(0, (sum, a) => sum + a.cantidad);
    if (total <= 0) return 0.0;
    return calcularCostoTotal(plan) / total;
  }

  // ──────────────── Aplicación ────────────────

  /// Aplica el plan a la BD: descuenta lotes y crea movimientos.
  ///
  /// Si algo falla, hace rollback (restaura cantidades anteriores).
  ///
  /// Devuelve el número de movimientos creados.
  Future<int> aplicar({
    required List<AsignacionLote> plan,
    required int usuarioId,
    required String motivo,
    String? ventaSupabaseId,
  }) async {
    if (plan.isEmpty) return 0;

    final movimientos = <MovimientoLoteEntity>[];
    final snapshots = <int, double>{};

    try {
      for (final asign in plan) {
        final lote = await _isarService.obtenerLotePorId(asign.loteId);
        if (lote == null) {
          throw Exception('Lote ${asign.loteId} no encontrado');
        }

        // Snapshot para rollback
        snapshots[lote.id] = lote.cantidadRestante;

        // Descontar
        lote.cantidadRestante -= asign.cantidad;
        if (lote.cantidadRestante <= 0.001) {
          lote.cantidadRestante = 0;
          lote.estado = 'agotado';
        }
        await _isarService.guardarLote(lote);

        // Movimiento
        movimientos.add(MovimientoLoteEntity()
          ..loteId = lote.id
          ..tipo = 'salida_venta_mayor'
          ..cantidad = -asign.cantidad
          ..usuarioId = usuarioId
          ..observaciones = motivo
          ..fecha = DateTime.now()
          ..sincronizado = false);
      }

      // Persistir movimientos
      for (final mov in movimientos) {
        await _isarService.guardarMovimientoLote(mov);
      }

      return movimientos.length;
    } catch (e) {
      // Rollback
      debugPrint('❌ Error aplicando plan de lotes: $e. Rollback...');
      for (final entry in snapshots.entries) {
        try {
          final lote = await _isarService.obtenerLotePorId(entry.key);
          if (lote != null) {
            lote.cantidadRestante = entry.value;
            if (lote.estado == 'agotado' && entry.value > 0) {
              lote.estado = 'activo';
            }
            await _isarService.guardarLote(lote);
          }
        } catch (rollbackError) {
          debugPrint('❌ Error en rollback de lote ${entry.key}: $rollbackError');
        }
      }
      rethrow;
    }
  }
}