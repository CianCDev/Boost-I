// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProductoEntityCollection on Isar {
  IsarCollection<ProductoEntity> get productoEntitys => this.collection();
}

const ProductoEntitySchema = CollectionSchema(
  name: r'ProductoEntity',
  id: -4188886869986827648,
  properties: {
    r'activo': PropertySchema(
      id: 0,
      name: r'activo',
      type: IsarType.bool,
    ),
    r'categoria': PropertySchema(
      id: 1,
      name: r'categoria',
      type: IsarType.string,
    ),
    r'categoriaId': PropertySchema(
      id: 2,
      name: r'categoriaId',
      type: IsarType.long,
    ),
    r'codigoBarras': PropertySchema(
      id: 3,
      name: r'codigoBarras',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdBy': PropertySchema(
      id: 5,
      name: r'createdBy',
      type: IsarType.long,
    ),
    r'createdByName': PropertySchema(
      id: 6,
      name: r'createdByName',
      type: IsarType.string,
    ),
    r'esPesado': PropertySchema(
      id: 7,
      name: r'esPesado',
      type: IsarType.bool,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 8,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'imagenUrl': PropertySchema(
      id: 9,
      name: r'imagenUrl',
      type: IsarType.string,
    ),
    r'marca': PropertySchema(
      id: 10,
      name: r'marca',
      type: IsarType.string,
    ),
    r'marcaSupabaseId': PropertySchema(
      id: 11,
      name: r'marcaSupabaseId',
      type: IsarType.string,
    ),
    r'nombre': PropertySchema(
      id: 12,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'precioUnidad': PropertySchema(
      id: 13,
      name: r'precioUnidad',
      type: IsarType.double,
    ),
    r'proveedorDireccion': PropertySchema(
      id: 14,
      name: r'proveedorDireccion',
      type: IsarType.string,
    ),
    r'proveedorEmail': PropertySchema(
      id: 15,
      name: r'proveedorEmail',
      type: IsarType.string,
    ),
    r'proveedorId': PropertySchema(
      id: 16,
      name: r'proveedorId',
      type: IsarType.long,
    ),
    r'proveedorNombre': PropertySchema(
      id: 17,
      name: r'proveedorNombre',
      type: IsarType.string,
    ),
    r'proveedorTelefono': PropertySchema(
      id: 18,
      name: r'proveedorTelefono',
      type: IsarType.string,
    ),
    r'sincronizado': PropertySchema(
      id: 19,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'stock': PropertySchema(
      id: 20,
      name: r'stock',
      type: IsarType.double,
    ),
    r'stockMinimo': PropertySchema(
      id: 21,
      name: r'stockMinimo',
      type: IsarType.double,
    ),
    r'supabaseId': PropertySchema(
      id: 22,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 23,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'updatedBy': PropertySchema(
      id: 24,
      name: r'updatedBy',
      type: IsarType.long,
    ),
    r'updatedByName': PropertySchema(
      id: 25,
      name: r'updatedByName',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 26,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _productoEntityEstimateSize,
  serialize: _productoEntitySerialize,
  deserialize: _productoEntityDeserialize,
  deserializeProp: _productoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'codigoBarras': IndexSchema(
      id: -3747644888679166614,
      name: r'codigoBarras',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'codigoBarras',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'marcaSupabaseId': IndexSchema(
      id: 539952858267124708,
      name: r'marcaSupabaseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'marcaSupabaseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _productoEntityGetId,
  getLinks: _productoEntityGetLinks,
  attach: _productoEntityAttach,
  version: '3.1.0+1',
);

int _productoEntityEstimateSize(
  ProductoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categoria.length * 3;
  bytesCount += 3 + object.codigoBarras.length * 3;
  {
    final value = object.createdByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imagenUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.marca.length * 3;
  {
    final value = object.marcaSupabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  bytesCount += 3 + object.proveedorDireccion.length * 3;
  bytesCount += 3 + object.proveedorEmail.length * 3;
  bytesCount += 3 + object.proveedorNombre.length * 3;
  bytesCount += 3 + object.proveedorTelefono.length * 3;
  {
    final value = object.supabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.updatedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _productoEntitySerialize(
  ProductoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeString(offsets[1], object.categoria);
  writer.writeLong(offsets[2], object.categoriaId);
  writer.writeString(offsets[3], object.codigoBarras);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeLong(offsets[5], object.createdBy);
  writer.writeString(offsets[6], object.createdByName);
  writer.writeBool(offsets[7], object.esPesado);
  writer.writeDateTime(offsets[8], object.fechaSincronizacion);
  writer.writeString(offsets[9], object.imagenUrl);
  writer.writeString(offsets[10], object.marca);
  writer.writeString(offsets[11], object.marcaSupabaseId);
  writer.writeString(offsets[12], object.nombre);
  writer.writeDouble(offsets[13], object.precioUnidad);
  writer.writeString(offsets[14], object.proveedorDireccion);
  writer.writeString(offsets[15], object.proveedorEmail);
  writer.writeLong(offsets[16], object.proveedorId);
  writer.writeString(offsets[17], object.proveedorNombre);
  writer.writeString(offsets[18], object.proveedorTelefono);
  writer.writeBool(offsets[19], object.sincronizado);
  writer.writeDouble(offsets[20], object.stock);
  writer.writeDouble(offsets[21], object.stockMinimo);
  writer.writeString(offsets[22], object.supabaseId);
  writer.writeDateTime(offsets[23], object.updatedAt);
  writer.writeLong(offsets[24], object.updatedBy);
  writer.writeString(offsets[25], object.updatedByName);
  writer.writeLong(offsets[26], object.version);
}

ProductoEntity _productoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductoEntity(
    activo: reader.readBoolOrNull(offsets[0]) ?? true,
    categoria: reader.readStringOrNull(offsets[1]) ?? 'General',
    categoriaId: reader.readLongOrNull(offsets[2]),
    codigoBarras: reader.readStringOrNull(offsets[3]) ?? '',
    createdAt: reader.readDateTimeOrNull(offsets[4]),
    createdBy: reader.readLongOrNull(offsets[5]),
    createdByName: reader.readStringOrNull(offsets[6]),
    esPesado: reader.readBoolOrNull(offsets[7]) ?? false,
    fechaSincronizacion: reader.readDateTimeOrNull(offsets[8]),
    id: id,
    imagenUrl: reader.readStringOrNull(offsets[9]),
    marca: reader.readStringOrNull(offsets[10]) ?? '',
    marcaSupabaseId: reader.readStringOrNull(offsets[11]),
    nombre: reader.readStringOrNull(offsets[12]) ?? '',
    precioUnidad: reader.readDoubleOrNull(offsets[13]) ?? 0.0,
    proveedorDireccion: reader.readStringOrNull(offsets[14]) ?? '',
    proveedorEmail: reader.readStringOrNull(offsets[15]) ?? '',
    proveedorId: reader.readLongOrNull(offsets[16]),
    proveedorNombre: reader.readStringOrNull(offsets[17]) ?? '',
    proveedorTelefono: reader.readStringOrNull(offsets[18]) ?? '',
    sincronizado: reader.readBoolOrNull(offsets[19]) ?? false,
    stock: reader.readDoubleOrNull(offsets[20]) ?? 0.0,
    stockMinimo: reader.readDoubleOrNull(offsets[21]) ?? 5.0,
    supabaseId: reader.readStringOrNull(offsets[22]),
    updatedAt: reader.readDateTimeOrNull(offsets[23]),
    updatedBy: reader.readLongOrNull(offsets[24]),
    updatedByName: reader.readStringOrNull(offsets[25]),
    version: reader.readLongOrNull(offsets[26]) ?? 0,
  );
  return object;
}

P _productoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? 'General') as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 13:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 14:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 15:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 18:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 19:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 20:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 21:
      return (reader.readDoubleOrNull(offset) ?? 5.0) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _productoEntityGetId(ProductoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _productoEntityGetLinks(ProductoEntity object) {
  return [];
}

void _productoEntityAttach(
    IsarCollection<dynamic> col, Id id, ProductoEntity object) {
  object.id = id;
}

extension ProductoEntityByIndex on IsarCollection<ProductoEntity> {
  Future<ProductoEntity?> getByCodigoBarras(String codigoBarras) {
    return getByIndex(r'codigoBarras', [codigoBarras]);
  }

  ProductoEntity? getByCodigoBarrasSync(String codigoBarras) {
    return getByIndexSync(r'codigoBarras', [codigoBarras]);
  }

  Future<bool> deleteByCodigoBarras(String codigoBarras) {
    return deleteByIndex(r'codigoBarras', [codigoBarras]);
  }

  bool deleteByCodigoBarrasSync(String codigoBarras) {
    return deleteByIndexSync(r'codigoBarras', [codigoBarras]);
  }

  Future<List<ProductoEntity?>> getAllByCodigoBarras(
      List<String> codigoBarrasValues) {
    final values = codigoBarrasValues.map((e) => [e]).toList();
    return getAllByIndex(r'codigoBarras', values);
  }

  List<ProductoEntity?> getAllByCodigoBarrasSync(
      List<String> codigoBarrasValues) {
    final values = codigoBarrasValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'codigoBarras', values);
  }

  Future<int> deleteAllByCodigoBarras(List<String> codigoBarrasValues) {
    final values = codigoBarrasValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'codigoBarras', values);
  }

  int deleteAllByCodigoBarrasSync(List<String> codigoBarrasValues) {
    final values = codigoBarrasValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'codigoBarras', values);
  }

  Future<Id> putByCodigoBarras(ProductoEntity object) {
    return putByIndex(r'codigoBarras', object);
  }

  Id putByCodigoBarrasSync(ProductoEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'codigoBarras', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCodigoBarras(List<ProductoEntity> objects) {
    return putAllByIndex(r'codigoBarras', objects);
  }

  List<Id> putAllByCodigoBarrasSync(List<ProductoEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'codigoBarras', objects, saveLinks: saveLinks);
  }
}

extension ProductoEntityQueryWhereSort
    on QueryBuilder<ProductoEntity, ProductoEntity, QWhere> {
  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProductoEntityQueryWhere
    on QueryBuilder<ProductoEntity, ProductoEntity, QWhereClause> {
  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause>
      codigoBarrasEqualTo(String codigoBarras) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigoBarras',
        value: [codigoBarras],
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause>
      codigoBarrasNotEqualTo(String codigoBarras) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoBarras',
              lower: [],
              upper: [codigoBarras],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoBarras',
              lower: [codigoBarras],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoBarras',
              lower: [codigoBarras],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoBarras',
              lower: [],
              upper: [codigoBarras],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause>
      marcaSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'marcaSupabaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause>
      marcaSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'marcaSupabaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause>
      marcaSupabaseIdEqualTo(String? marcaSupabaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'marcaSupabaseId',
        value: [marcaSupabaseId],
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterWhereClause>
      marcaSupabaseIdNotEqualTo(String? marcaSupabaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'marcaSupabaseId',
              lower: [],
              upper: [marcaSupabaseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'marcaSupabaseId',
              lower: [marcaSupabaseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'marcaSupabaseId',
              lower: [marcaSupabaseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'marcaSupabaseId',
              lower: [],
              upper: [marcaSupabaseId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProductoEntityQueryFilter
    on QueryBuilder<ProductoEntity, ProductoEntity, QFilterCondition> {
  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      activoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoria',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoria',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoria',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoria',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoriaId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoriaId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoriaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoriaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoriaId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      categoriaIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoriaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoBarras',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoBarras',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoBarras',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      codigoBarrasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoBarras',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdByName',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdByName',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      createdByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdByName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      esPesadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esPesado',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      fechaSincronizacionGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      fechaSincronizacionLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      fechaSincronizacionBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaSincronizacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagenUrl',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagenUrl',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagenUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagenUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      imagenUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagenUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marca',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'marca',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'marca',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'marca',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'marca',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'marca',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'marca',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'marca',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marca',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'marca',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'marcaSupabaseId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'marcaSupabaseId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marcaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'marcaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'marcaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'marcaSupabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'marcaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'marcaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'marcaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'marcaSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marcaSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      marcaSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'marcaSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      precioUnidadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioUnidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      precioUnidadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioUnidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      precioUnidadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioUnidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      precioUnidadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioUnidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorDireccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorDireccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorDireccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorDireccion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorDireccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorDireccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorDireccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorDireccion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorDireccion',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorDireccionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorDireccion',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorEmail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorEmail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proveedorId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proveedorId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorTelefono',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorTelefono',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorTelefono',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      proveedorTelefonoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorTelefono',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stock',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stock',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stock',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stock',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockMinimoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stockMinimo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockMinimoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stockMinimo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockMinimoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stockMinimo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      stockMinimoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stockMinimo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedBy',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedBy',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedByName',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedByName',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'updatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'updatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updatedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      updatedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updatedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterFilterCondition>
      versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProductoEntityQueryObject
    on QueryBuilder<ProductoEntity, ProductoEntity, QFilterCondition> {}

extension ProductoEntityQueryLinks
    on QueryBuilder<ProductoEntity, ProductoEntity, QFilterCondition> {}

extension ProductoEntityQuerySortBy
    on QueryBuilder<ProductoEntity, ProductoEntity, QSortBy> {
  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByCategoria() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCategoriaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCategoriaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCategoriaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCodigoBarras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoBarras', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCodigoBarrasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoBarras', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByEsPesado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPesado', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByEsPesadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPesado', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByImagenUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByImagenUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByMarca() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marca', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByMarcaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marca', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByMarcaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marcaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByMarcaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marcaSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByPrecioUnidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByPrecioUnidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorDireccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorDireccion', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorDireccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorDireccion', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmail', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmail', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByProveedorTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stock', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stock', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByStockMinimo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByStockMinimoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByUpdatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedByName', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByUpdatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedByName', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ProductoEntityQuerySortThenBy
    on QueryBuilder<ProductoEntity, ProductoEntity, QSortThenBy> {
  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByCategoria() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCategoriaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCategoriaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCategoriaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCodigoBarras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoBarras', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCodigoBarrasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoBarras', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByEsPesado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPesado', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByEsPesadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPesado', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByImagenUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByImagenUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByMarca() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marca', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByMarcaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marca', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByMarcaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marcaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByMarcaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marcaSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByPrecioUnidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByPrecioUnidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorDireccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorDireccion', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorDireccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorDireccion', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmail', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmail', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByProveedorTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stock', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stock', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByStockMinimo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByStockMinimoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockMinimo', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByUpdatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedByName', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByUpdatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedByName', Sort.desc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ProductoEntityQueryWhereDistinct
    on QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> {
  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByCategoria(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoria', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByCategoriaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoriaId');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByCodigoBarras({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoBarras', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByCreatedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByEsPesado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esPesado');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByImagenUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagenUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByMarca(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'marca', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByMarcaSupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'marcaSupabaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByPrecioUnidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioUnidad');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByProveedorDireccion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorDireccion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByProveedorEmail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorEmail',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByProveedorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorId');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByProveedorNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByProveedorTelefono({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorTelefono',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stock');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByStockMinimo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stockMinimo');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctBySupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedBy');
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByUpdatedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension ProductoEntityQueryProperty
    on QueryBuilder<ProductoEntity, ProductoEntity, QQueryProperty> {
  QueryBuilder<ProductoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProductoEntity, bool, QQueryOperations> activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations> categoriaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoria');
    });
  }

  QueryBuilder<ProductoEntity, int?, QQueryOperations> categoriaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoriaId');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations>
      codigoBarrasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoBarras');
    });
  }

  QueryBuilder<ProductoEntity, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProductoEntity, int?, QQueryOperations> createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<ProductoEntity, String?, QQueryOperations>
      createdByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByName');
    });
  }

  QueryBuilder<ProductoEntity, bool, QQueryOperations> esPesadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esPesado');
    });
  }

  QueryBuilder<ProductoEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<ProductoEntity, String?, QQueryOperations> imagenUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagenUrl');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations> marcaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'marca');
    });
  }

  QueryBuilder<ProductoEntity, String?, QQueryOperations>
      marcaSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'marcaSupabaseId');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<ProductoEntity, double, QQueryOperations>
      precioUnidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioUnidad');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations>
      proveedorDireccionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorDireccion');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations>
      proveedorEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorEmail');
    });
  }

  QueryBuilder<ProductoEntity, int?, QQueryOperations> proveedorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorId');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations>
      proveedorNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorNombre');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations>
      proveedorTelefonoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorTelefono');
    });
  }

  QueryBuilder<ProductoEntity, bool, QQueryOperations> sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<ProductoEntity, double, QQueryOperations> stockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stock');
    });
  }

  QueryBuilder<ProductoEntity, double, QQueryOperations> stockMinimoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stockMinimo');
    });
  }

  QueryBuilder<ProductoEntity, String?, QQueryOperations> supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<ProductoEntity, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ProductoEntity, int?, QQueryOperations> updatedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedBy');
    });
  }

  QueryBuilder<ProductoEntity, String?, QQueryOperations>
      updatedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedByName');
    });
  }

  QueryBuilder<ProductoEntity, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
