// lib/features/pos/presentation/services/conversion_unidades.dart
//
// Conversión de unidades de medida entre la RECETA y el INVENTARIO.
//
// ⚠️ POR QUÉ EXISTE
//
// `RecetaItemEntity.unidad` dice en qué unidad está escrita la cantidad del
// ingrediente y `ProductoEntity.unidad` dice en qué unidad está el stock. Son
// dos campos independientes: si la receta pide "150 g de queso" y el stock
// está en kilos, restar 150 tal cual descuenta 150 kg. Este helper es el
// único sitio donde ese factor debe vivir.
//
// ⚠️ SIN DEPENDENCIAS
//
// No importa Flutter ni Isar: se prueba con `test()` plano. La usan
// `ComandasNotifier._descontarRecetaDeItem` y, si algún día hace falta, la
// UI de recetas para mostrar equivalencias.
class ConversionUnidades {
  ConversionUnidades._();

  /// Unidades que entiende el sistema, agrupadas por dimensión.
  ///
  /// La clave es la unidad canónica; los valores son sinónimos aceptados.
  /// `unidad` es la dimensión de conteo: 1 docena NO se convierte, porque en
  /// este modelo `unidad` significa "piezas contables", no "unidad de
  /// empaque" (eso es `DetalleVentaEntity.unidadEmpaque`).
  static const Map<String, List<String>> _sinonimos = {
    'kg': ['kg', 'kgs', 'kilo', 'kilos', 'kilogramo', 'kilogramos'],
    'g': ['g', 'gr', 'grs', 'gramo', 'gramos'],
    'lt': ['lt', 'l', 'lts', 'litro', 'litros'],
    'ml': ['ml', 'mililitro', 'mililitros'],
    'unidad': ['unidad', 'unidades', 'und', 'uds', 'u', 'pza', 'pzas'],
  };

  /// Dimensión de cada unidad canónica. Solo se convierte dentro de una
  /// misma dimensión: 1 kg son 1000 g, pero 1 kg no son "N unidades".
  static const Map<String, String> _dimension = {
    'kg': 'masa',
    'g': 'masa',
    'lt': 'volumen',
    'ml': 'volumen',
    'unidad': 'conteo',
  };

  /// Cuántas unidades canónicas hay en 1 de cada unidad (base de su
  /// dimensión): gramo, mililitro y pieza.
  static const Map<String, double> _aBase = {
    'kg': 1000,
    'g': 1,
    'lt': 1000,
    'ml': 1,
    'unidad': 1,
  };

  /// Lleva una unidad escrita a mano a su forma canónica.
  ///
  /// Vacío, con espacios o desconocida → `'unidad'`, que es el default de
  /// `ProductoEntity.unidad` y de `RecetaItemEntity.unidad`. Un dato raro no
  /// debe romper el descuento de stock de un plato ya entregado.
  static String normalizar(String? unidad) {
    final limpio = (unidad ?? '').trim().toLowerCase();
    if (limpio.isEmpty) return 'unidad';

    for (final entrada in _sinonimos.entries) {
      if (entrada.value.contains(limpio)) return entrada.key;
    }
    return 'unidad';
  }

  /// Factor para pasar una cantidad de [desde] a [hasta].
  ///
  /// Devuelve `1.0` si son la misma unidad y `null` si pertenecen a
  /// dimensiones distintas (masa ↔ volumen ↔ conteo). `null` NO es un error
  /// silencioso: el caller decide qué hacer, y en el descuento de recetas la
  /// decisión es caer al 1:1 de antes y avisar en el log, porque bloquear la
  /// entrega de un plato ya cocinado está descartado.
  ///
  /// Ejemplos:
  ///   factor('g', 'kg')   → 0.001
  ///   factor('kg', 'g')   → 1000.0
  ///   factor('ml', 'lt')  → 0.001
  ///   factor('kg', 'unidad') → null
  static double? factor(String? desde, String? hasta) {
    final d = normalizar(desde);
    final h = normalizar(hasta);
    if (d == h) return 1.0;
    if (_dimension[d] != _dimension[h]) return null;
    return _aBase[d]! / _aBase[h]!;
  }

  /// Convierte [cantidad] de [desde] a [hasta], o `null` si no se puede.
  static double? convertir(
    double cantidad, {
    String? desde,
    String? hasta,
  }) {
    final f = factor(desde, hasta);
    if (f == null) return null;
    return cantidad * f;
  }
}
