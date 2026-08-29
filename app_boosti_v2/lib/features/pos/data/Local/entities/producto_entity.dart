import 'package:isar/isar.dart';

part 'producto_entity.g.dart';

@Collection()
class ProductoEntity {
  // ──────────────── ID y claves ────────────────
  Id id = Isar.autoIncrement; // ID local (auto incremental)

  @Index(unique: true, replace: true)
  late String codigoBarras;

  String nombre = '';
  double precioUnidad = 0.0;
  double stock = 0.0;
  bool esPesado = false;

  // ──────────────── Categoría ────────────────
  // Campo legacy (se mantiene por compatibilidad)
  String categoria = 'General';
  // Relación con CategoriaEntity (local, int)
  int? categoriaId;

  // ──────────────── Marca ────────────────
  // Campo legacy (texto libre, se mantiene por compatibilidad)
  String marca = '';
  // 🔥 NUEVO: Relación con MarcaEntity usando el UUID de Supabase
  @Index()
  String? marcaSupabaseId;

  // ──────────────── Proveedor ────────────────
  int? proveedorId;
  String proveedorNombre = '';
  String proveedorTelefono = '';
  String proveedorEmail = '';
  String proveedorDireccion = '';

  // ──────────────── Supabase ────────────────
  String? supabaseId;

  // ──────────────── Stock y configuración ────────────────
  double stockMinimo = 5.0;
  bool activo = true;

  // ──────────────── Imagen ────────────────
  String? imagenUrl;

  // ──────────────── Auditoría ────────────────
  DateTime? createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? updatedBy;
  String? createdByName;
  String? updatedByName;

  // ──────────────── Sincronización ────────────────
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // ──────────────── Versión ────────────────
  int version = 0;

  // ──────────────── Constructor ────────────────
  ProductoEntity({
    this.id = Isar.autoIncrement,
    this.codigoBarras = '',
    this.nombre = '',
    this.marca = '',
    this.marcaSupabaseId,
    this.precioUnidad = 0.0,
    this.stock = 0.0,
    this.esPesado = false,
    this.categoria = 'General',
    this.categoriaId,
    this.proveedorId,
    this.proveedorNombre = '',
    this.proveedorTelefono = '',
    this.proveedorEmail = '',
    this.proveedorDireccion = '',
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

  // ──────────────── Factory desde Supabase ────────────────
  factory ProductoEntity.fromJson(Map<String, dynamic> json) {
    return ProductoEntity(
      supabaseId: json['id'] as String?,
      codigoBarras: json['codigo_barras'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      marca: json['marca'] as String? ?? '', // legacy
      marcaSupabaseId: json['marca_supabase_id'] as String?, // 🔥 NUEVO
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
      stockMinimo: (json['stock_minimo'] as num?)?.toDouble() ?? 5.0,
      activo: json['activo'] as bool? ?? true,
      imagenUrl: json['imagen_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      createdByName: json['created_by_name'] as String?,
      updatedByName: json['updated_by_name'] as String?,
      version: json['version'] as int? ?? 0,
    );
  }

  // ──────────────── Convertir a JSON para Supabase ────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': supabaseId,
      'codigo_barras': codigoBarras,
      'nombre': nombre,
      'marca': marca, // legacy
      'marca_supabase_id': marcaSupabaseId, // 🔥 NUEVO
      'precio_unidad': precioUnidad,
      'stock': stock,
      'es_pesado': esPesado,
      'categoria': categoria,
      'categoria_id': categoriaId,
      'proveedor_id': proveedorId,
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