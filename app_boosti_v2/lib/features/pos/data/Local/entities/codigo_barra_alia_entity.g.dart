// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: experimental_member_use

part of 'codigo_barra_alia_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCodigoBarrasAliasEntityCollection on Isar {
  IsarCollection<CodigoBarrasAliasEntity> get codigoBarrasAliasEntitys =>
      this.collection();
}

const CodigoBarrasAliasEntitySchema = CollectionSchema(
  name: r'CodigoBarrasAliasEntity',
  id: -5807756221582701631,
  properties: {
    r'activo': PropertySchema(
      id: 0,
      name: r'activo',
      type: IsarType.bool,
    ),
    r'codigo': PropertySchema(
      id: 1,
      name: r'codigo',
      type: IsarType.string,
    ),
    r'factor': PropertySchema(
      id: 2,
      name: r'factor',
      type: IsarType.double,
    ),
    r'fechaAsignacion': PropertySchema(
      id: 3,
      name: r'fechaAsignacion',
      type: IsarType.dateTime,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 4,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'observaciones': PropertySchema(
      id: 5,
      name: r'observaciones',
      type: IsarType.string,
    ),
    r'productoId': PropertySchema(
      id: 6,
      name: r'productoId',
      type: IsarType.long,
    ),
    r'sincronizado': PropertySchema(
      id: 7,
      name: r'sincronizado',
      type: IsarType.bool,
    )
  },
  estimateSize: _codigoBarrasAliasEntityEstimateSize,
  serialize: _codigoBarrasAliasEntitySerialize,
  deserialize: _codigoBarrasAliasEntityDeserialize,
  deserializeProp: _codigoBarrasAliasEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'codigo': IndexSchema(
      id: 2475659939796141935,
      name: r'codigo',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'codigo',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _codigoBarrasAliasEntityGetId,
  getLinks: _codigoBarrasAliasEntityGetLinks,
  attach: _codigoBarrasAliasEntityAttach,
  version: '3.1.0+1',
);

int _codigoBarrasAliasEntityEstimateSize(
  CodigoBarrasAliasEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigo.length * 3;
  {
    final value = object.observaciones;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _codigoBarrasAliasEntitySerialize(
  CodigoBarrasAliasEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeString(offsets[1], object.codigo);
  writer.writeDouble(offsets[2], object.factor);
  writer.writeDateTime(offsets[3], object.fechaAsignacion);
  writer.writeDateTime(offsets[4], object.fechaSincronizacion);
  writer.writeString(offsets[5], object.observaciones);
  writer.writeLong(offsets[6], object.productoId);
  writer.writeBool(offsets[7], object.sincronizado);
}

CodigoBarrasAliasEntity _codigoBarrasAliasEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CodigoBarrasAliasEntity();
  object.activo = reader.readBool(offsets[0]);
  object.codigo = reader.readString(offsets[1]);
  object.factor = reader.readDouble(offsets[2]);
  object.fechaAsignacion = reader.readDateTime(offsets[3]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.observaciones = reader.readStringOrNull(offsets[5]);
  object.productoId = reader.readLong(offsets[6]);
  object.sincronizado = reader.readBool(offsets[7]);
  return object;
}

P _codigoBarrasAliasEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _codigoBarrasAliasEntityGetId(CodigoBarrasAliasEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _codigoBarrasAliasEntityGetLinks(
    CodigoBarrasAliasEntity object) {
  return [];
}

void _codigoBarrasAliasEntityAttach(
    IsarCollection<dynamic> col, Id id, CodigoBarrasAliasEntity object) {
  object.id = id;
}

extension CodigoBarrasAliasEntityByIndex
    on IsarCollection<CodigoBarrasAliasEntity> {
  Future<CodigoBarrasAliasEntity?> getByCodigo(String codigo) {
    return getByIndex(r'codigo', [codigo]);
  }

  CodigoBarrasAliasEntity? getByCodigoSync(String codigo) {
    return getByIndexSync(r'codigo', [codigo]);
  }

  Future<bool> deleteByCodigo(String codigo) {
    return deleteByIndex(r'codigo', [codigo]);
  }

  bool deleteByCodigoSync(String codigo) {
    return deleteByIndexSync(r'codigo', [codigo]);
  }

  Future<List<CodigoBarrasAliasEntity?>> getAllByCodigo(
      List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return getAllByIndex(r'codigo', values);
  }

  List<CodigoBarrasAliasEntity?> getAllByCodigoSync(List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'codigo', values);
  }

  Future<int> deleteAllByCodigo(List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'codigo', values);
  }

  int deleteAllByCodigoSync(List<String> codigoValues) {
    final values = codigoValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'codigo', values);
  }

  Future<Id> putByCodigo(CodigoBarrasAliasEntity object) {
    return putByIndex(r'codigo', object);
  }

  Id putByCodigoSync(CodigoBarrasAliasEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'codigo', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCodigo(List<CodigoBarrasAliasEntity> objects) {
    return putAllByIndex(r'codigo', objects);
  }

  List<Id> putAllByCodigoSync(List<CodigoBarrasAliasEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'codigo', objects, saveLinks: saveLinks);
  }
}

extension CodigoBarrasAliasEntityQueryWhereSort
    on QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QWhere> {
  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CodigoBarrasAliasEntityQueryWhere on QueryBuilder<
    CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QWhereClause> {
  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterWhereClause> codigoEqualTo(String codigo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigo',
        value: [codigo],
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterWhereClause> codigoNotEqualTo(String codigo) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [],
              upper: [codigo],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [codigo],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [codigo],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigo',
              lower: [],
              upper: [codigo],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CodigoBarrasAliasEntityQueryFilter on QueryBuilder<
    CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QFilterCondition> {
  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> activoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
          QAfterFilterCondition>
      codigoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
          QAfterFilterCondition>
      codigoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> codigoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigo',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> factorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'factor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> factorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'factor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> factorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'factor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> factorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'factor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaAsignacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaAsignacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaAsignacionGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaAsignacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaAsignacionLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaAsignacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaAsignacionBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaAsignacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaSincronizacionGreaterThan(
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaSincronizacionLessThan(
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> fechaSincronizacionBetween(
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'observaciones',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
          QAfterFilterCondition>
      observacionesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
          QAfterFilterCondition>
      observacionesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'observaciones',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> observacionesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> productoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
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

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity,
      QAfterFilterCondition> sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }
}

extension CodigoBarrasAliasEntityQueryObject on QueryBuilder<
    CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QFilterCondition> {}

extension CodigoBarrasAliasEntityQueryLinks on QueryBuilder<
    CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QFilterCondition> {}

extension CodigoBarrasAliasEntityQuerySortBy
    on QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QSortBy> {
  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'factor', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'factor', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByFechaAsignacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAsignacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByFechaAsignacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAsignacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }
}

extension CodigoBarrasAliasEntityQuerySortThenBy on QueryBuilder<
    CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QSortThenBy> {
  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByCodigo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByCodigoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigo', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'factor', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'factor', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByFechaAsignacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAsignacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByFechaAsignacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAsignacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }
}

extension CodigoBarrasAliasEntityQueryWhereDistinct on QueryBuilder<
    CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct> {
  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctByCodigo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctByFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'factor');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctByFechaAsignacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaAsignacion');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctByObservaciones({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observaciones',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QDistinct>
      distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }
}

extension CodigoBarrasAliasEntityQueryProperty on QueryBuilder<
    CodigoBarrasAliasEntity, CodigoBarrasAliasEntity, QQueryProperty> {
  QueryBuilder<CodigoBarrasAliasEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, bool, QQueryOperations>
      activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, String, QQueryOperations>
      codigoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigo');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, double, QQueryOperations>
      factorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'factor');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, DateTime, QQueryOperations>
      fechaAsignacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaAsignacion');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, String?, QQueryOperations>
      observacionesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observaciones');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, int, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<CodigoBarrasAliasEntity, bool, QQueryOperations>
      sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }
}
