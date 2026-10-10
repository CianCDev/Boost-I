// lib/features/pos/presentation/widgets/common/time_badge.dart
import 'package:flutter/material.dart';

import '../../utils/duracion_utils.dart';

/// Badge de antigüedad, coloreado por urgencia (R.3.2 UX-2).
///
/// | Minutos  | Color   |
/// |----------|---------|
/// | 0 - 5    | verde   |
/// | 5 - 10   | ámbar   |
/// | 10 - 15  | naranja |
/// | > 15     | rojo    |
///
/// ⚠️ `ahora` es OBLIGATORIO y lo pasa el padre, no se pide dentro.
///
/// El KDS tiene un `Timer.periodic` de 30 s que hace `setState` para
/// repintar. Si este badge llamara a `DateTime.now()` por su cuenta, dos
/// badges hermanos del mismo frame podrían caer en minutos distintos
/// (el primero calcula a las 14:59:59.99 y el segundo a las 15:00:00.01),
/// y verías dos Urgencias incompatibles en pantalla. Al recibir `ahora`,
/// todos los badges del frame comparten el mismo reloj.
///
/// No reutiliza `StatusBadge` porque ese componente tiene el alfa fijos
/// en 0.15 (`status_badge.dart:35`), y aquí cada rango necesita el suyo
/// (0.20 / 0.25 / 0.30) para que la urgencia se lea de un vistazo.
class TimeBadge extends StatelessWidget {
  /// Instante de referencia. `null` → badge neutro "—".
  final DateTime? desde;

  /// Reloj del frame, inyectado por el padre.
  final DateTime ahora;

  /// Versión corta: "3 min" en vez de "hace 3 min".
  final bool compact;

  /// Fuerza un color en vez de calcularlo por antigüedad.
  ///
  /// Para cuando el color lo decide otra cosa (por ejemplo, un plato
  /// pausado, que va en rojo intenso pase lo que pase).
  final Color? colorForzado;

  const TimeBadge({
    super.key,
    required this.ahora,
    this.desde,
    this.compact = false,
    this.colorForzado,
  });

  /// Minutos que lleva [desde]. 0 si es nulo o está en el futuro.
  int get minutos => DuracionUtils.minutosDesde(desde, ahora: ahora);

  /// Color de la urgencia para estos minutos.
  static Color colorPorMinutos(int minutos) {
    if (minutos < UmbralesUrgencia.verdeHastaMin) {
      return const Color(0xFF10B981);
    }
    if (minutos < UmbralesUrgencia.ambarHastaMin) {
      return const Color(0xFFF59E0B);
    }
    if (minutos < UmbralesUrgencia.naranjaHastaMin) {
      return const Color(0xFFF97316);
    }
    return const Color(0xFFEF4444);
  }

  /// Opacidad del fondo. Sube con la urgencia para que el rojo además de
  /// cambiar de tono se note en el peso visual.
  static double opacidadPorMinutos(int minutos) {
    if (minutos < UmbralesUrgencia.verdeHastaMin) return 0.20;
    if (minutos < UmbralesUrgencia.ambarHastaMin) return 0.25;
    if (minutos < UmbralesUrgencia.naranjaHastaMin) return 0.30;
    return 0.30;
  }

  @override
  Widget build(BuildContext context) {
    final m = minutos;
    final color = colorForzado ?? colorPorMinutos(m);
    final alpha = colorForzado != null ? 0.30 : opacidadPorMinutos(m);

    final texto = desde == null
        ? '—'
        : (compact
            ? '${DuracionUtils.minutosExactosDesde(desde, ahora: ahora)} min'
            : DuracionUtils.hace(desde, ahora: ahora));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: alpha + 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: compact ? 10 : 12, color: color),
          SizedBox(width: compact ? 3 : 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
