// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movimiento_inventario_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMovimientoInventarioEntityCollection on Isar {
  IsarCollection<MovimientoInventarioEntity> get movimientoInventarioEntitys =>
      this.collection();
}

const MovimientoInventarioEntitySchema = CollectionSchema(
  name: r'MovimientoInventarioEntity',
  id: 4105252479473095640,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.double,
    ),
    r'fecha': PropertySchema(
      id: 1,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'nombreProducto': PropertySchema(
      id: 2,
      name: r'nombreProducto',
      type: IsarType.string,
    ),
    r'productoId': PropertySchema(
      id: 3,
      name: r'productoId',
      type: IsarType.long,
    ),
    r'stockResultante': PropertySchema(
      id: 4,
      name: r'stockResultante',
      type: IsarType.double,
    ),
    r'syncStatus': PropertySchema(
      id: 5,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tipoMovimiento': PropertySchema(
      id: 6,
      name: r'tipoMovimiento',
      type: IsarType.string,
    ),
    r'usuarioId': PropertySchema(
      id: 7,
      name: r'usuarioId',
      type: IsarType.long,
    )
  },
  estimateSize: _movimientoInventarioEntityEstimateSize,
  serialize: _movimientoInventarioEntitySerialize,
  deserialize: _movimientoInventarioEntityDeserialize,
  deserializeProp: _movimientoInventarioEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _movimientoInventarioEntityGetId,
  getLinks: _movimientoInventarioEntityGetLinks,
  attach: _movimientoInventarioEntityAttach,
  version: '3.1.0+1',
);

int _movimientoInventarioEntityEstimateSize(
  MovimientoInventarioEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nombreProducto.length * 3;
  bytesCount += 3 + object.syncStatus.length * 3;
  bytesCount += 3 + object.tipoMovimiento.length * 3;
  return bytesCount;
}

void _movimientoInventarioEntitySerialize(
  MovimientoInventarioEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cantidad);
  writer.writeDateTime(offsets[1], object.fecha);
  writer.writeString(offsets[2], object.nombreProducto);
  writer.writeLong(offsets[3], object.productoId);
  writer.writeDouble(offsets[4], object.stockResultante);
  writer.writeString(offsets[5], object.syncStatus);
  writer.writeString(offsets[6], object.tipoMovimiento);
  writer.writeLong(offsets[7], object.usuarioId);
}

MovimientoInventarioEntity _movimientoInventarioEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MovimientoInventarioEntity();
  object.cantidad = reader.readDouble(offsets[0]);
  object.fecha = reader.readDateTime(offsets[1]);
  object.id = id;
  object.nombreProducto = reader.readString(offsets[2]);
  object.productoId = reader.readLong(offsets[3]);
  object.stockResultante = reader.readDouble(offsets[4]);
  object.syncStatus = reader.readString(offsets[5]);
  object.tipoMovimiento = reader.readString(offsets[6]);
  object.usuarioId = reader.readLong(offsets[7]);
  return object;
}

P _movimientoInventarioEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _movimientoInventarioEntityGetId(MovimientoInventarioEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _movimientoInventarioEntityGetLinks(
    MovimientoInventarioEntity object) {
  return [];
}

void _movimientoInventarioEntityAttach(
    IsarCollection<dynamic> col, Id id, MovimientoInventarioEntity object) {
  object.id = id;
}

extension MovimientoInventarioEntityQueryWhereSort on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QWhere> {
  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MovimientoInventarioEntityQueryWhere on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QWhereClause> {
  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterWhereClause> idBetween(
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
}

extension MovimientoInventarioEntityQueryFilter on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QFilterCondition> {
  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> cantidadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> cantidadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> cantidadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> cantidadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> fechaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> fechaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> fechaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> fechaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fecha',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombreProducto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
          QAfterFilterCondition>
      nombreProductoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
          QAfterFilterCondition>
      nombreProductoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombreProducto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreProducto',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> nombreProductoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombreProducto',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> productoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> productoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> productoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> productoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> stockResultanteEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stockResultante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> stockResultanteGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stockResultante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> stockResultanteLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stockResultante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> stockResultanteBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stockResultante',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
          QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
          QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoMovimiento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
          QAfterFilterCondition>
      tipoMovimientoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoMovimiento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
          QAfterFilterCondition>
      tipoMovimientoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoMovimiento',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoMovimiento',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> tipoMovimientoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoMovimiento',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> usuarioIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> usuarioIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterFilterCondition> usuarioIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MovimientoInventarioEntityQueryObject on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QFilterCondition> {}

extension MovimientoInventarioEntityQueryLinks on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QFilterCondition> {}

extension MovimientoInventarioEntityQuerySortBy on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QSortBy> {
  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByNombreProducto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByNombreProductoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByStockResultante() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockResultante', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByStockResultanteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockResultante', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByTipoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByTipoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension MovimientoInventarioEntityQuerySortThenBy on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QSortThenBy> {
  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByNombreProducto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByNombreProductoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByStockResultante() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockResultante', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByStockResultanteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockResultante', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByTipoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByTipoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.desc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QAfterSortBy> thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension MovimientoInventarioEntityQueryWhereDistinct on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QDistinct> {
  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctByNombreProducto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombreProducto',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctByStockResultante() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stockResultante');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctByTipoMovimiento({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoMovimiento',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoInventarioEntity, MovimientoInventarioEntity,
      QDistinct> distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }
}

extension MovimientoInventarioEntityQueryProperty on QueryBuilder<
    MovimientoInventarioEntity, MovimientoInventarioEntity, QQueryProperty> {
  QueryBuilder<MovimientoInventarioEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, double, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, DateTime, QQueryOperations>
      fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, String, QQueryOperations>
      nombreProductoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombreProducto');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, int, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, double, QQueryOperations>
      stockResultanteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stockResultante');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, String, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, String, QQueryOperations>
      tipoMovimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoMovimiento');
    });
  }

  QueryBuilder<MovimientoInventarioEntity, int, QQueryOperations>
      usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }
}
