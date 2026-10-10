// lib/features/pos/presentation/utils/duracion_utils.dart
//
// R.3.2 · Formato de duraciones y antigüedades.
//
// ⚠️ POR QUÉ EXISTE ESTE ARCHIVO
//
// El proyecto tiene SEIS implementaciones de "hace X min", todas
// `static` privadas dentro de su widget (`comanda_screen._duracion`,
// `mesa_card._duracion`, `asignar_mesa_dialog._duracion`,
// `parked_carts_dialog`, `cash_closing_screen._calcularTiempo`,
// `empleado_card`), con formatos ligeramente distintos entre sí. Al ser
// privadas, ningún componente externo puede reusarlas.
//
// Este archivo NO las sustituye (eso sería tocar pantallas de otros
// módulos, fuera de R.3.2). Solo ofrece una versión canónica para los
// componentes nuevos, para que el KDS no añada un séptimo duplicado.
//
// La migración de las 6 existentes queda en `docs/TODO.md`.

/// Formateo de duraciones. No instanciable.
class DuracionUtils {
  DuracionUtils._();

  /// Qué se devuelve cuando la fecha es nula o está en el futuro.
  static const _nulo = '—';

  /// Antigüedad legible: "hace 45 seg", "hace 3 min", "hace 2 h",
  /// "hace 2 h 15 min", "hace 3 d".
  ///
  /// [ahora] se recibe como parámetro, y no se pide dentro, a propósito:
  /// el KDS tiene un `Timer.periodic` que re-pinta la pantalla, así que la
  /// misma instancia del badge tiene que poder recalcular su edad contra
  /// el mismo `ahora` que le pasó el padre. Si esta función llamara a
  /// `DateTime.now()` por su cuenta, dos widgets hermanos del mismo
  /// frame podrían discrepar en un minuto.
  ///
  /// Devuelve "—" si [desde] es nulo. Un [desde] en el futuro (desajuste
  /// de reloj entre dispositivos) se trata como 0 segundos en vez de
  /// devolver un negativo como "-3 min".
  static String hace(DateTime? desde, {DateTime? ahora}) {
    if (desde == null) return _nulo;
    final d = _diferencia(desde, ahora);
    if (d.inSeconds < 60) return 'hace ${d.inSeconds} seg';

    if (d.inMinutes < 60) return 'hace ${d.inMinutes} min';

    if (d.inHours < 24) {
      final horas = d.inHours;
      final min = d.inMinutes % 60;
      return min == 0 ? 'hace $horas h' : 'hace $horas h $min min';
    }

    return 'hace ${d.inDays} d';
  }

  /// Minutos transcurridos, sin prefijo. Base del badge de urgencia.
  ///
  /// Redondea hacia arriba: un plato que lleva 30 segundos ya tiene que
  /// verse en el tramo de "recién llegado" y no quedar pegado al minuto
  /// anterior del reloj.
  static int minutosDesde(DateTime? desde, {DateTime? ahora}) {
    if (desde == null) return 0;
    final d = _diferencia(desde, ahora);
    if (d.inSeconds < 60) return 0;
    return d.inMinutes;
  }

  /// Minutos exactos, sin redondear. Para comparaciones y tests.
  static int minutosExactosDesde(DateTime? desde, {DateTime? ahora}) {
    if (desde == null) return 0;
    return _diferencia(desde, ahora).inMinutes;
  }

  /// Un reloj en el futuro no produce negativos.
  static Duration _diferencia(DateTime desde, DateTime? ahora) {
    final referencia = ahora ?? DateTime.now();
    final d = referencia.difference(desde);
    return d.isNegative ? Duration.zero : d;
  }
}

/// Umbrales de urgencia del KDS, en minutos.
///
/// R.3.2 UX-2. Centralizados aquí porque el badge (color) y la pantalla
/// (orden/urgencia) tienen que usar los MISMOS números; si cada uno lleva
/// su propia constante, un cambio se aplicaría a uno y no al otro.
class UmbralesUrgencia {
  UmbralesUrgencia._();

  /// Hasta aquí, color verde: acaba de llegar.
  static const verdeHastaMin = 5;

  /// Hasta aquí, ámbar: empieza a tardar.
  static const ambarHastaMin = 10;

  /// Hasta aquí, naranja: hay que apurarse.
  static const naranjaHastaMin = 15;

  /// Por encima, rojo: se pasó de tiempo.
  static const rojoDesdeMin = naranjaHastaMin;
}
