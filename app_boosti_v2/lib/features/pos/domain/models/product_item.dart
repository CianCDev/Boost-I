class ProductItem {
  final String id;
  final String codigoBarras;
  final String nombre;
  final double precioUnidad;
  final bool esPesado; // true si requiere balanza (kg), false si es por unidad
  final String categoria;

  const ProductItem({
    required this.id,
    required this.codigoBarras,
    required this.nombre,
    required this.precioUnidad,
    required this.esPesado,
    required this.categoria,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as String,
      codigoBarras: json['codigoBarras'] as String,
      nombre: json['nombre'] as String,
      precioUnidad: (json['precioUnidad'] as num).toDouble(),
      esPesado: json['esPesado'] as bool? ?? false,
      categoria: json['categoria'] as String? ?? 'General',
    );
  }

  ProductItem copyWith({
    String? id,
    String? codigoBarras,
    String? nombre,
    double? precioUnidad,
    bool? esPesado,
    String? categoria,
  }) {
    return ProductItem(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombre: nombre ?? this.nombre,
      precioUnidad: precioUnidad ?? this.precioUnidad,
      esPesado: esPesado ?? this.esPesado,
      categoria: categoria ?? this.categoria,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigoBarras': codigoBarras,
      'nombre': nombre,
      'precioUnidad': precioUnidad,
      'esPesado': esPesado,
      'categoria': categoria,
    };
  }
}