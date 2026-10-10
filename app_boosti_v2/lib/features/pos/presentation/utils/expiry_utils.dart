// lib/features/pos/presentation/utils/expiry_utils.dart
import 'package:flutter/material.dart';

/// Umbrales y colores para el badge de vencimiento.
///
/// Adoptamos la escala de `lotes_group_card.dart:386-397`, la más rica del
/// repo. `lotes_card.dart:213` usaba solo el umbral de 7 días; unificar
/// aquí evita que las dos escalas sigan divergiendo.
///
/// ## Por qué el vencido es rojo y no violeta
/// `lotes_group_card.dart:392` usaba `_colorVencido` = violeta `#8B5CF6`,
/// el mismo color que "Próximo a vencer" en `lotes_card.dart:154`. En una
/// card de catálogo, donde conviven badges de stock y de vencimiento, el
/// violeta no se lee como urgencia. Acá el vencido es rojo `#DC2626`.
class ExpiryUtils {
  /// Días restantes hasta el vencimiento. Negativo si ya venció.
  ///
  /// Ojo con el borde: `difference().inDays` trunca hacia cero, así que un
  /// vencimiento dentro de 23 horas da `0` (no `1`), y uno de 25 horas
  /// atrás también da `0`. Por eso `clasificar` trata `0` aparte como
  /// "Vence hoy" y no como "≤3 días".
  static int diasRestantes(DateTime fecha, {DateTime? desde}) {
    final ahora = desde ?? DateTime.now();
    return fecha.difference(ahora).inDays;
  }

  /// Clasificación visual.
  ///
  /// - `null` fecha → no se muestra badge.
  /// - Vencido (<0 días) → rojo, `urgente`.
  /// - 0 días → "Vence hoy", rojo, `urgente`.
  /// - ≤3 días → rojo, `urgente`.
  /// - ≤7 días → ámbar.
  /// - ≤15 días → ámbar atenuado.
  /// - >15 días → `null` (sin badge, evita ruido).
  static ExpiryBadgeInfo? clasificar(DateTime? fecha, {DateTime? desde}) {
    if (fecha == null) return null;
    final dias = diasRestantes(fecha, desde: desde);

    if (dias < 0) {
      return const ExpiryBadgeInfo(
        label: 'VENCIDO',
        color: Color(0xFFDC2626),
        urgente: true,
      );
    }
    if (dias == 0) {
      return const ExpiryBadgeInfo(
        label: 'Vence hoy',
        color: Color(0xFFDC2626),
        urgente: true,
      );
    }
    if (dias <= 3) {
      return ExpiryBadgeInfo(
        label: 'Vence ${dias}d',
        color: _rojo,
        urgente: true,
      );
    }
    if (dias <= 7) {
      return ExpiryBadgeInfo(
        label: 'Vence ${dias}d',
        color: _ambar,
        urgente: false,
      );
    }
    if (dias <= 15) {
      return ExpiryBadgeInfo(
        label: 'Vence ${dias}d',
        color: _ambarApagado,
        urgente: false,
      );
    }
    return null;
  }

  /// Versión corta del label para móvil, cuando el badge de vencimiento
  /// compite con "¡Stock bajo!" por el ancho de la card.
  ///
  /// Sin esto los dos badges se solapan: en móvil la card ronda los 150px
  /// y "¡Stock bajo!" mide ~70px. Con "2d" entran los dos.
  static ExpiryBadgeInfo? clasificarCompacto(
    DateTime? fecha, {
    DateTime? desde,
  }) {
    final full = clasificar(fecha, desde: desde);
    if (full == null) return null;

    // `clasificar` devuelve null cuando `fecha` es null, así que acá ya
    // no puede serlo; el `!` es para el analizador, no para runtime.
    final dias = diasRestantes(fecha!, desde: desde);
    final shortLabel = switch (dias) {
      < 0 => 'VENC.',
      0 => 'HOY',
      _ => '${dias}d',
    };
    return ExpiryBadgeInfo(
      label: shortLabel,
      color: full.color,
      urgente: full.urgente,
    );
  }

  static const Color _rojo = Color(0xFFDC2626);
  static const Color _ambar = Color(0xFFF59E0B);
  static const Color _ambarApagado = Color(0xFFB45309);
}

/// Resultado de [ExpiryUtils.clasificar].
class ExpiryBadgeInfo {
  final String label;
  final Color color;
  final bool urgente;

  const ExpiryBadgeInfo({
    required this.label,
    required this.color,
    required this.urgente,
  });
}
