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
    r'nombre': PropertySchema(
      id: 3,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'precioUnidad': PropertySchema(
      id: 4,
      name: r'precioUnidad',
      type: IsarType.double,
    ),
    r'proveedorNombre': PropertySchema(
      id: 5,
      name: r'proveedorNombre',
      type: IsarType.string,
    ),
    r'proveedorTelefono': PropertySchema(
      id: 6,
      name: r'proveedorTelefono',
      type: IsarType.string,
    ),
    r'stock': PropertySchema(
      id: 7,
      name: r'stock',
      type: IsarType.double,
    ),
    r'stockMinimo': PropertySchema(
      id: 8,
      name: r'stockMinimo',
      type: IsarType.double,
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
  bytesCount += 3 + object.nombre.length * 3;
  bytesCount += 3 + object.proveedorNombre.length * 3;
  bytesCount += 3 + object.proveedorTelefono.length * 3;
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
  writer.writeString(offsets[3], object.nombre);
  writer.writeDouble(offsets[4], object.precioUnidad);
  writer.writeString(offsets[5], object.proveedorNombre);
  writer.writeString(offsets[6], object.proveedorTelefono);
  writer.writeDouble(offsets[7], object.stock);
  writer.writeDouble(offsets[8], object.stockMinimo);
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
  object.id = id;
  object.nombre = reader.readString(offsets[3]);
  object.precioUnidad = reader.readDouble(offsets[4]);
  object.proveedorNombre = reader.readString(offsets[5]);
  object.proveedorTelefono = reader.readString(offsets[6]);
  object.stock = reader.readDouble(offsets[7]);
  object.stockMinimo = reader.readDouble(offsets[8]);
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
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
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
}
