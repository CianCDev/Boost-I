import 'package:isar/isar.dart';

part 'producto_entity.g.dart';

@Collection()
class ProductoEntity {
  // ──────────────── ID y claves ────────────────
  Id id = Isar.autoIncrement; // ID local (auto incremental)

  /// Código de barras del producto.
  ///
  /// ⚠️ `replace: false` (Capa 2 de 2, antes `true`): con `replace: true`, un
  /// valor duplicado no daba error, BORRABA el producto anterior sin dejar
  /// rastro — y `''` era un valor muy fácil de duplicar porque lo generaba
  /// el constructor, `fromJson` y el `sync_service`. Ahora el conflicto salta
  /// como `IsarUniqueViolationError`. El hueco de `''` lo cubre el guard de
  /// `IsarService.guardarProducto`, que deriva una clave única antes de
  /// escribir. Dejar `unique: true` mantiene el aviso de "código repetido".
  @Index(unique: true, replace: false)
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

  // ──────────────── KDS · Departamento destino (R.3) ────────────────

  /// Departamento (estación) donde se prepara este producto: Cocina, Barra,
  /// Postres, etc. Relación con `DepartamentoEntity` (id local de Isar).
  ///
  /// `null` significa que el producto NO requiere preparación: se cobra
  /// directo, sin pasar por el KDS. Es el caso normal en retail.
  ///
  /// ⚠️ LOCAL-ONLY por decisión D2a: este campo NO está en `toJson()` ni en
  /// `fromJson()`, así que no viaja a Supabase. Cuando exista la columna
  /// `departamento_id` en `productos` (R.1b), se añade al par. Until then,
  /// tocar el sync de productos escribiría una clave inexistente y
  /// rompería el push.
  ///
  /// OJO: la relación producto-departamento es por id; el hack de
  /// `IsarService.contarProductosPorDepartamento()` que compara
  /// `categoria` contra `departamento.nombre` como texto sigue siendo la
  /// vía que usa la UI de departamentos. Ver `docs/TODO.md`.
  int? departamentoId;

  /// UUID del departamento en Supabase.
  ///
  /// Paired con [departamentoId] (que es el id LOCAL de Isar). Ambos
  /// viajan en sync:
  ///  · Push: se manda `departamentoSupabaseId` (UUID); si está null,
  ///    `sincronizarProductosASupabase` lo resuelve desde `departamentoId`.
  ///  · Pull: `descargarProductosDesdeSupabase` lee `departamento_id` (UUID)
  ///    y lo guarda aquí; el `departamentoId` local se resuelve después
  ///    (en el mismo pull si el departamento ya está en Isar, o al bajar
  ///    los departamentos, vía reconcile).
  ///
  /// Es el mismo patrón que `marcaSupabaseId` y `proveedorSupabaseId`: un
  /// UUID estable cross-device convive con el id autoincremental local.
  String? departamentoSupabaseId;


  // ──────────────── R.4 · Recetas ────────────────
  //
 /// Viaja a Supabase como `departamento_id` (UUID). El par es
  /// `(departamentoId, departamentoSupabaseId)`: el id local es un
  /// autoincremental de Isar (no cruza dispositivos), el UUID sí.

  /// Marca el producto como ingrediente de recetas.
  ///
  /// `null` → comportamiento actual: el producto es vendible y no forma
  /// parte de ninguna receta. `true` → es ingrediente. `false` →
  /// explícitamente NO es ingrediente.
  ///
  /// Es `bool?` y no `bool` a propósito: con `bool` el default `false`
  /// sería indistinguible de un "lo marcaron como no-ingrediente", y no
  /// habría forma de distinguir "nunca lo miraron" de "lo miraron y no
  /// es". Hoy esa diferencia no importa, pero en G.2 la UI va a querer
  /// offercer el filtro "ver solo ingredientes" y un default implícito
  /// contaminationaría ese filtro con los ~500 productos de retail.
  ///
  /// Un producto PUEDE ser las dos cosas: el queso se vende en el mostrador
  /// y además es ingrediente de la pizza.
  bool? esIngrediente;

  /// Unidad de medida base: `'kg'`, `'g'`, `'lt'`, `'ml'`, `'unidad'`.
  ///
  /// Default `'unidad'` porque es lo que asume hoy todo el sistema: la
  /// venta por cantidad (`CartSessionItem.cantidad`) no tiene unidad, así
  /// que un producto sin esto significa "contable en unidades".
  ///
  /// Unidad base para medir ingredientes en recetas.
  ///
  /// NO reemplaza a [esPesado]:
  ///   - `esPesado`: "se vende a granel al cliente final" (precio, ticket).
  ///   - `unidad`:   "unidad de medida en recetas" (stock interno).
  /// Coexisten por diseño. Un producto puede ser pesado Y medirse en
  /// gramos dentro de una receta; los dos datos se usan en sitios
  /// distintos y no se derivan uno del otro.
  String unidad = 'unidad';

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



   // ──────────────── Ventas al Mayor (NUEVO) ────────────────
  /// Si `true`, el producto aparece en la pantalla de ventas al mayor.
  bool permiteVentaMayor = false;

  /// Precio unitario para ventas al por mayor.
  double? precioMayor;

  /// Cantidad mínima de unidades para aplicar `precioMayor`.
  int? cantidadMinimaMayor;

  /// Precio unitario para el nivel intermedio (medio mayor).
  double? precioMedioMayor;

  /// Cantidad mínima de unidades para aplicar `precioMedioMayor`.
  int? cantidadMinimaMedioMayor;

  /// Unidades contenidas en un bulto/caja (para ventas por empaque).
  int unidadesPorBulto = 1;

  /// Costo promedio del producto (para validar margen mínimo).
  double? costoUnitarioPromedio;

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
    this.departamentoId,
    this.departamentoSupabaseId,
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
    this.permiteVentaMayor = false,
    this.precioMayor,
    this.cantidadMinimaMayor,
    this.precioMedioMayor,
    this.cantidadMinimaMedioMayor,
    this.unidadesPorBulto = 1,
    this.costoUnitarioPromedio,
    this.esIngrediente,
    this.unidad = 'unidad',
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
      // `departamento_id` es UUID (o null). El `departamentoId` local se
      // resuelve aparte — ver `descargarProductosDesdeSupabase` y el
      // reconcile en `descargarDepartamentosDesdeSupabase`.
      departamentoSupabaseId: json['departamento_id'] as String?,
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
      permiteVentaMayor: json['permite_venta_mayor'] as bool? ?? false,
      precioMayor: _asDouble(json['precio_mayor']),
      cantidadMinimaMayor: _asInt(json['cantidad_minima_mayor']),
      precioMedioMayor: _asDouble(json['precio_medio_mayor']),
      cantidadMinimaMedioMayor: _asInt(json['cantidad_minima_medio_mayor']),
      unidadesPorBulto: _asInt(json['unidades_por_bulto']) ?? 1,
      costoUnitarioPromedio: _asDouble(json['costo_unitario_promedio']),
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
      // UUID del departamento; null si no aplica. La migración
      // `20261031000001` crea la columna con `ON DELETE SET NULL`, así
      // que enviar `null` es legítimo.
      'departamento_id': departamentoSupabaseId,
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
      'permite_venta_mayor': permiteVentaMayor,
      'precio_mayor': precioMayor,
      'cantidad_minima_mayor': cantidadMinimaMayor,
      'precio_medio_mayor': precioMedioMayor,
      'cantidad_minima_medio_mayor': cantidadMinimaMedioMayor,
      'unidades_por_bulto': unidadesPorBulto,
      'costo_unitario_promedio': costoUnitarioPromedio,
    };
  }
}