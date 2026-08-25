// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: experimental_member_use

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
    r'categoria': PropertySchema(
      id: 0,
      name: r'categoria',
      type: IsarType.string,
    ),
    r'codigoBarras': PropertySchema(
      id: 1,
      name: r'codigoBarras',
      type: IsarType.string,
    ),
    r'esPesado': PropertySchema(
      id: 2,
      name: r'esPesado',
      type: IsarType.bool,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 3,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'imagenUrl': PropertySchema(
      id: 4,
      name: r'imagenUrl',
      type: IsarType.string,
    ),
    r'nombre': PropertySchema(
      id: 5,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'precioUnidad': PropertySchema(
      id: 6,
      name: r'precioUnidad',
      type: IsarType.double,
    ),
    r'proveedorId': PropertySchema(
      id: 7,
      name: r'proveedorId',
      type: IsarType.long,
    ),
    r'proveedorNombre': PropertySchema(
      id: 8,
      name: r'proveedorNombre',
      type: IsarType.string,
    ),
    r'proveedorTelefono': PropertySchema(
      id: 9,
      name: r'proveedorTelefono',
      type: IsarType.string,
    ),
    r'sincronizado': PropertySchema(
      id: 10,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'stock': PropertySchema(
      id: 11,
      name: r'stock',
      type: IsarType.double,
    ),
    r'stockMinimo': PropertySchema(
      id: 12,
      name: r'stockMinimo',
      type: IsarType.double,
    ),
    r'supabaseId': PropertySchema(
      id: 13,
      name: r'supabaseId',
      type: IsarType.string,
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
  bytesCount += 3 + object.imagenUrl.length * 3;
  bytesCount += 3 + object.nombre.length * 3;
  bytesCount += 3 + object.proveedorNombre.length * 3;
  bytesCount += 3 + object.proveedorTelefono.length * 3;
  {
    final value = object.supabaseId;
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
  writer.writeString(offsets[0], object.categoria);
  writer.writeString(offsets[1], object.codigoBarras);
  writer.writeBool(offsets[2], object.esPesado);
  writer.writeDateTime(offsets[3], object.fechaSincronizacion);
  writer.writeString(offsets[4], object.imagenUrl);
  writer.writeString(offsets[5], object.nombre);
  writer.writeDouble(offsets[6], object.precioUnidad);
  writer.writeLong(offsets[7], object.proveedorId);
  writer.writeString(offsets[8], object.proveedorNombre);
  writer.writeString(offsets[9], object.proveedorTelefono);
  writer.writeBool(offsets[10], object.sincronizado);
  writer.writeDouble(offsets[11], object.stock);
  writer.writeDouble(offsets[12], object.stockMinimo);
  writer.writeString(offsets[13], object.supabaseId);
}

ProductoEntity _productoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductoEntity();
  object.categoria = reader.readString(offsets[0]);
  object.codigoBarras = reader.readString(offsets[1]);
  object.esPesado = reader.readBool(offsets[2]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.imagenUrl = reader.readString(offsets[4]);
  object.nombre = reader.readString(offsets[5]);
  object.precioUnidad = reader.readDouble(offsets[6]);
  object.proveedorId = reader.readLongOrNull(offsets[7]);
  object.proveedorNombre = reader.readString(offsets[8]);
  object.proveedorTelefono = reader.readString(offsets[9]);
  object.sincronizado = reader.readBool(offsets[10]);
  object.stock = reader.readDouble(offsets[11]);
  object.stockMinimo = reader.readDouble(offsets[12]);
  object.supabaseId = reader.readStringOrNull(offsets[13]);
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
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
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
}

extension ProductoEntityQueryFilter
    on QueryBuilder<ProductoEntity, ProductoEntity, QFilterCondition> {
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
      imagenUrlEqualTo(
    String value, {
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
    String value, {
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
    String value, {
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
    String lower,
    String upper, {
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
}

extension ProductoEntityQueryObject
    on QueryBuilder<ProductoEntity, ProductoEntity, QFilterCondition> {}

extension ProductoEntityQueryLinks
    on QueryBuilder<ProductoEntity, ProductoEntity, QFilterCondition> {}

extension ProductoEntityQuerySortBy
    on QueryBuilder<ProductoEntity, ProductoEntity, QSortBy> {
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
}

extension ProductoEntityQuerySortThenBy
    on QueryBuilder<ProductoEntity, ProductoEntity, QSortThenBy> {
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
}

extension ProductoEntityQueryWhereDistinct
    on QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> {
  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct> distinctByCategoria(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoria', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoEntity, ProductoEntity, QDistinct>
      distinctByCodigoBarras({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoBarras', caseSensitive: caseSensitive);
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
}

extension ProductoEntityQueryProperty
    on QueryBuilder<ProductoEntity, ProductoEntity, QQueryProperty> {
  QueryBuilder<ProductoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations> categoriaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoria');
    });
  }

  QueryBuilder<ProductoEntity, String, QQueryOperations>
      codigoBarrasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoBarras');
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

  QueryBuilder<ProductoEntity, String, QQueryOperations> imagenUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagenUrl');
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
}
