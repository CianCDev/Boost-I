// lib/features/pos/data/Local/entities/producto_entity.dart

class ProductoEntity {
  int id = 0; // 0 = nuevo
  String codigoBarras = '';
  String nombre = '';
  double precioUnidad = 0.0;
  double stock = 0.0;
  bool esPesado = false;
  bool activo = true;

  String categoria = 'General';
  int? categoriaId;

  String marca = '';
  String? marcaSupabaseId;

  int? proveedorId;
  String proveedorNombre = '';
  String proveedorTelefono = '';
  String proveedorEmail = '';
  String proveedorDireccion = '';
  String? proveedorSupabaseId;

  String? supabaseId;

  double stockMinimo = 5.0;
  String? imagenUrl;

  DateTime? createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? updatedBy;
  String? createdByName;
  String? updatedByName;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
  int version = 0;

  ProductoEntity({
    this.id = 0,
    this.codigoBarras = '',
    this.nombre = '',
    this.precioUnidad = 0.0,
    this.stock = 0.0,
    this.esPesado = false,
    this.categoria = 'General',
    this.categoriaId,
    this.marca = '',
    this.marcaSupabaseId,
    this.proveedorId,
    this.proveedorNombre = '',
    this.proveedorTelefono = '',
    this.proveedorEmail = '',
    this.proveedorDireccion = '',
    this.proveedorSupabaseId,
    this.supabaseId,
    this.stockMinimo = 5.0,
    this.activo = true,
    this.imagenUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.createdByName,
    this.updatedByName,
    this.sincronizado = false,
    this.fechaSincronizacion,
    this.version = 0,
  });

  // ✅ Para Sembast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigoBarras': codigoBarras,
      'nombre': nombre,
      'precioUnidad': precioUnidad,
      'stock': stock,
      'esPesado': esPesado,
      'activo': activo,
      'categoria': categoria,
      'categoriaId': categoriaId,
      'marca': marca,
      'marcaSupabaseId': marcaSupabaseId,
      'proveedorId': proveedorId,
      'proveedorNombre': proveedorNombre,
      'proveedorTelefono': proveedorTelefono,
      'proveedorEmail': proveedorEmail,
      'proveedorDireccion': proveedorDireccion,
      'proveedorSupabaseId': proveedorSupabaseId,
      'supabaseId': supabaseId,
      'stockMinimo': stockMinimo,
      'imagenUrl': imagenUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdByName': createdByName,
      'updatedByName': updatedByName,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
      'version': version,
    };
  }

  // ✅ Desde Sembast
  factory ProductoEntity.fromMap(Map<String, dynamic> map) {
    return ProductoEntity(
      id: (map['id'] as int?) ?? 0,
      codigoBarras: (map['codigoBarras'] as String?) ?? '',
      nombre: (map['nombre'] as String?) ?? '',
      precioUnidad: (map['precioUnidad'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toDouble() ?? 0.0,
      esPesado: (map['esPesado'] as bool?) ?? false,
      activo: (map['activo'] as bool?) ?? true,
      categoria: (map['categoria'] as String?) ?? 'General',
      categoriaId: map['categoriaId'] as int?,
      marca: (map['marca'] as String?) ?? '',
      marcaSupabaseId: map['marcaSupabaseId'] as String?,
      proveedorId: map['proveedorId'] as int?,
      proveedorNombre: (map['proveedorNombre'] as String?) ?? '',
      proveedorTelefono: (map['proveedorTelefono'] as String?) ?? '',
      proveedorEmail: (map['proveedorEmail'] as String?) ?? '',
      proveedorDireccion: (map['proveedorDireccion'] as String?) ?? '',
      proveedorSupabaseId: map['proveedorSupabaseId'] as String?,
      supabaseId: map['supabaseId'] as String?,
      stockMinimo: (map['stockMinimo'] as num?)?.toDouble() ?? 5.0,
      imagenUrl: map['imagenUrl'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null,
      createdBy: map['createdBy'] as int?,
      updatedBy: map['updatedBy'] as int?,
      createdByName: map['createdByName'] as String?,
      updatedByName: map['updatedByName'] as String?,
      sincronizado: (map['sincronizado'] as bool?) ?? false,
      fechaSincronizacion: map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null,
      version: (map['version'] as int?) ?? 0,
    );
  }

  // Métodos originales de Supabase (los conservamos)
  factory ProductoEntity.fromJson(Map<String, dynamic> json) {
    return ProductoEntity(
      supabaseId: json['id'] as String?,
      codigoBarras: json['codigo_barras'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      marca: json['marca'] as String? ?? '',
      marcaSupabaseId: json['marca_supabase_id'] as String?,
      precioUnidad: (json['precio_unidad'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
      esPesado: json['es_pesado'] as bool? ?? false,
      categoria: json['categoria'] as String? ?? 'General',
      categoriaId: json['categoria_id'] as int?,
      proveedorId: json['proveedor_id'] as int?,
      proveedorNombre: json['proveedor_nombre'] as String? ?? '',
      proveedorTelefono: json['proveedor_telefono'] as String? ?? '',
      proveedorEmail: json['proveedor_email'] as String? ?? '',
      proveedorDireccion: json['proveedor_direccion'] as String? ?? '',
      proveedorSupabaseId: json['proveedor_id'] as String?,
      stockMinimo: (json['stock_minimo'] as num?)?.toDouble() ?? 5.0,
      activo: json['activo'] as bool? ?? true,
      imagenUrl: json['imagen_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      createdByName: json['created_by_name'] as String?,
      updatedByName: json['updated_by_name'] as String?,
      version: json['version'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': supabaseId,
      'codigo_barras': codigoBarras,
      'nombre': nombre,
      'marca': marca,
      'marca_supabase_id': marcaSupabaseId,
      'precio_unidad': precioUnidad,
      'stock': stock,
      'es_pesado': esPesado,
      'categoria': categoria,
      'categoria_id': categoriaId,
      'proveedor_id': proveedorSupabaseId,
      'proveedor_nombre': proveedorNombre,
      'proveedor_telefono': proveedorTelefono,
      'proveedor_email': proveedorEmail,
      'proveedor_direccion': proveedorDireccion,
      'stock_minimo': stockMinimo,
      'activo': activo,
      'imagen_url': imagenUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_by_name': createdByName,
      'updated_by_name': updatedByName,
      'version': version,
    };
  }
}