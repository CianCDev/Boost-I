// lib/features/pos/domain/enums/tipo_documento.dart

/// Tipo de documento de identidad.
///
/// - V = Venezolano
/// - E = Extranjero
/// - J = Jurídico (empresas — no aplica a usuarios, sí a proveedores)
/// - P = Pasaporte (futuro)
/// - G = Gobierno (futuro)
enum TipoDocumento {
  v('V', 'Venezolano'),
  e('E', 'Extranjero'),
  j('J', 'Jurídico'),
  p('P', 'Pasaporte');

  final String codigo;
  final String descripcion;
  const TipoDocumento(this.codigo, this.descripcion);

  /// Tipos válidos para un empleado / usuario del sistema.
  /// Solo V y E según requisito.
  static const List<TipoDocumento> paraUsuarios = [v, e];

  /// Tipos válidos para proveedores / empresas.
  static const List<TipoDocumento> paraProveedores = [j, v, e];

  /// Parser robusto: si viene un string desconocido, cae a `v`.
  static TipoDocumento fromString(String? raw) {
    if (raw == null || raw.isEmpty) return TipoDocumento.v;
    final upper = raw.trim().toUpperCase();
    return TipoDocumento.values.firstWhere(
      (t) => t.codigo == upper,
      orElse: () => TipoDocumento.v,
    );
  }

  /// Prefijo visual para mostrar junto al número: "V-", "E-", "J-".
  String get prefijo => '$codigo-';

  /// Formato completo dado un número: "V-12345678".
  String formatear(String? numero) {
    if (numero == null || numero.isEmpty) return 'Sin documento';
    return '$codigo-$numero';
  }
}