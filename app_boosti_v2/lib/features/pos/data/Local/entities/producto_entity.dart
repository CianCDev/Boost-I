import 'package:isar/isar.dart';

part 'producto_entity.g.dart';

@Collection()
class ProductoEntity {
  // ──────────────── ID y claves ────────────────
  Id id = Isar.autoIncrement; // ID local (auto incremental)

  @Index(unique: true, replace: true)
  String codigoBarras;

  // ──────────────── Datos del producto ────────────────
  String nombre = '';
  double precioUnidad = 0.0;
  double stock = 0.0;
  bool esPesado = false;
  bool activo = true;

  // ──────────────── Categoría ────────────────
  String categoria = 'General';
  int? categoriaId; // Relación con CategoriaEntity (local, int)

  // ──────────────── Marca ────────────────
  String marca = ''; // Legacy (texto libre)
  @Index()
  String? marcaSupabaseId; // UUID de la marca en Supabase

  // ──────────────── Proveedor ────────────────
  int? proveedorId; // ID local del proveedor (Isar)
  String proveedorNombre = '';
  String proveedorTelefono = '';
  String proveedorEmail = '';
  String proveedorDireccion = '';

  /// UUID del proveedor en Supabase (para la relación)
  @Index()
  String? proveedorSupabaseId;

  // ──────────────── Supabase ────────────────
  String? supabaseId; // UUID del producto en Supabase

  // ──────────────── Stock y configuración ────────────────
  double stockMinimo = 5.0;

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

  // ──────────────── Helpers privados ────────────────

  /// Convierte un valor dinámico a `int?` sin reventar.
  /// Útil cuando Supabase envía ints como String por temas de JSONB.
  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Convierte un valor dinámico a `double?` sin reventar.
  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ──────────────── Factory desde Supabase ────────────────
  factory ProductoEntity.fromJson(Map<String, dynamic> json) {
    // ───── supabaseId: aceptar 'uuid' (nuevo) o 'id' (legacy) ─────
    final rawSupabaseId = json['uuid'] ?? json['id'];
    final supabaseIdParsed =
        rawSupabaseId is String && rawSupabaseId.isNotEmpty
            ? rawSupabaseId
            : null;

    // ───── proveedor_id: puede ser UUID (String) o int legacy ─────
    final rawProveedorId = json['proveedor_id'];
    int? proveedorIdLocal;
    String? proveedorSupabaseIdParsed;

    if (rawProveedorId is String && rawProveedorId.isNotEmpty) {
      // Es un UUID de Supabase (caso normal actual)
      proveedorSupabaseIdParsed = rawProveedorId;
    } else if (rawProveedorId is int) {
      // Es un ID local legacy
      proveedorIdLocal = rawProveedorId;
    } else if (rawProveedorId is num) {
      proveedorIdLocal = rawProveedorId.toInt();
    }

    return ProductoEntity(
      supabaseId: supabaseIdParsed,
      codigoBarras: json['codigo_barras'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      marca: json['marca'] as String? ?? '',
      marcaSupabaseId: json['marca_supabase_id'] as String?,
      precioUnidad: _asDouble(json['precio_unidad']) ?? 0.0,
      stock: _asDouble(json['stock']) ?? 0.0,
      esPesado: json['es_pesado'] as bool? ?? false,
      categoria: json['categoria'] as String? ?? 'General',
      categoriaId: _asInt(json['categoria_id']),
      proveedorId: proveedorIdLocal,
      proveedorSupabaseId: proveedorSupabaseIdParsed,
      proveedorNombre: json['proveedor_nombre'] as String? ?? '',
      proveedorTelefono: json['proveedor_telefono'] as String? ?? '',
      proveedorEmail: json['proveedor_email'] as String? ?? '',
      proveedorDireccion: json['proveedor_direccion'] as String? ?? '',
      stockMinimo: _asDouble(json['stock_minimo']) ?? 5.0,
      activo: json['activo'] as bool? ?? true,
      imagenUrl: json['imagen_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      createdBy: _asInt(json['created_by']),
      updatedBy: _asInt(json['updated_by']),
      createdByName: json['created_by_name'] as String?,
      updatedByName: json['updated_by_name'] as String?,
      version: _asInt(json['version']) ?? 0,
    );
  }

  // ──────────────── Convertir a JSON para Supabase ────────────────
  Map<String, dynamic> toJson() {
    return {
      // ✅ Clave 'uuid' para coincidir con Supabase y sync_service
      'uuid': supabaseId,
      'codigo_barras': codigoBarras,
      'nombre': nombre,
      'marca': marca,
      'marca_supabase_id': marcaSupabaseId,
      'precio_unidad': precioUnidad,
      'stock': stock,
      'es_pesado': esPesado,
      'categoria': categoria,
      'categoria_id': categoriaId,
      // ✅ Preferir UUID; fallback al int local legacy como String
      'proveedor_id': proveedorSupabaseId ??
          (proveedorId?.toString()),
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