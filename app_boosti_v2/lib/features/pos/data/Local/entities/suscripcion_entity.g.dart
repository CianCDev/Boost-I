// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suscripcion_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSuscripcionEntityCollection on Isar {
  IsarCollection<SuscripcionEntity> get suscripcionEntitys => this.collection();
}

const SuscripcionEntitySchema = CollectionSchema(
  name: r'SuscripcionEntity',
  id: -8403407307889046277,
  properties: {
    r'activa': PropertySchema(
      id: 0,
      name: r'activa',
      type: IsarType.bool,
    ),
    r'addonsActivosJson': PropertySchema(
      id: 1,
      name: r'addonsActivosJson',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 2,
      name: r'estado',
      type: IsarType.string,
    ),
    r'periodoFin': PropertySchema(
      id: 3,
      name: r'periodoFin',
      type: IsarType.dateTime,
    ),
    r'periodoInicio': PropertySchema(
      id: 4,
      name: r'periodoInicio',
      type: IsarType.dateTime,
    ),
    r'planId': PropertySchema(
      id: 5,
      name: r'planId',
      type: IsarType.string,
    ),
    r'tenantId': PropertySchema(
      id: 6,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'trialHasta': PropertySchema(
      id: 7,
      name: r'trialHasta',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'verificadoEn': PropertySchema(
      id: 9,
      name: r'verificadoEn',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _suscripcionEntityEstimateSize,
  serialize: _suscripcionEntitySerialize,
  deserialize: _suscripcionEntityDeserialize,
  deserializeProp: _suscripcionEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'tenantId': IndexSchema(
      id: -1042425927805315167,
      name: r'tenantId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'tenantId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _suscripcionEntityGetId,
  getLinks: _suscripcionEntityGetLinks,
  attach: _suscripcionEntityAttach,
  version: '3.1.0+1',
);

int _suscripcionEntityEstimateSize(
  SuscripcionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.addonsActivosJson.length * 3;
  bytesCount += 3 + object.estado.length * 3;
  bytesCount += 3 + object.planId.length * 3;
  bytesCount += 3 + object.tenantId.length * 3;
  return bytesCount;
}

void _suscripcionEntitySerialize(
  SuscripcionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activa);
  writer.writeString(offsets[1], object.addonsActivosJson);
  writer.writeString(offsets[2], object.estado);
  writer.writeDateTime(offsets[3], object.periodoFin);
  writer.writeDateTime(offsets[4], object.periodoInicio);
  writer.writeString(offsets[5], object.planId);
  writer.writeString(offsets[6], object.tenantId);
  writer.writeDateTime(offsets[7], object.trialHasta);
  writer.writeDateTime(offsets[8], object.updatedAt);
  writer.writeDateTime(offsets[9], object.verificadoEn);
}

SuscripcionEntity _suscripcionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SuscripcionEntity();
  object.addonsActivosJson = reader.readString(offsets[1]);
  object.estado = reader.readString(offsets[2]);
  object.id = id;
  object.periodoFin = reader.readDateTimeOrNull(offsets[3]);
  object.periodoInicio = reader.readDateTimeOrNull(offsets[4]);
  object.planId = reader.readString(offsets[5]);
  object.tenantId = reader.readString(offsets[6]);
  object.trialHasta = reader.readDateTimeOrNull(offsets[7]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[8]);
  object.verificadoEn = reader.readDateTimeOrNull(offsets[9]);
  return object;
}

P _suscripcionEntityDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _suscripcionEntityGetId(SuscripcionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _suscripcionEntityGetLinks(
    SuscripcionEntity object) {
  return [];
}

void _suscripcionEntityAttach(
    IsarCollection<dynamic> col, Id id, SuscripcionEntity object) {
  object.id = id;
}

extension SuscripcionEntityByIndex on IsarCollection<SuscripcionEntity> {
  Future<SuscripcionEntity?> getByTenantId(String tenantId) {
    return getByIndex(r'tenantId', [tenantId]);
  }

  SuscripcionEntity? getByTenantIdSync(String tenantId) {
    return getByIndexSync(r'tenantId', [tenantId]);
  }

  Future<bool> deleteByTenantId(String tenantId) {
    return deleteByIndex(r'tenantId', [tenantId]);
  }

  bool deleteByTenantIdSync(String tenantId) {
    return deleteByIndexSync(r'tenantId', [tenantId]);
  }

  Future<List<SuscripcionEntity?>> getAllByTenantId(
      List<String> tenantIdValues) {
    final values = tenantIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'tenantId', values);
  }

  List<SuscripcionEntity?> getAllByTenantIdSync(List<String> tenantIdValues) {
    final values = tenantIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'tenantId', values);
  }

  Future<int> deleteAllByTenantId(List<String> tenantIdValues) {
    final values = tenantIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'tenantId', values);
  }

  int deleteAllByTenantIdSync(List<String> tenantIdValues) {
    final values = tenantIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'tenantId', values);
  }

  Future<Id> putByTenantId(SuscripcionEntity object) {
    return putByIndex(r'tenantId', object);
  }

  Id putByTenantIdSync(SuscripcionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'tenantId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTenantId(List<SuscripcionEntity> objects) {
    return putAllByIndex(r'tenantId', objects);
  }

  List<Id> putAllByTenantIdSync(List<SuscripcionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'tenantId', objects, saveLinks: saveLinks);
  }
}

extension SuscripcionEntityQueryWhereSort
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QWhere> {
  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SuscripcionEntityQueryWhere
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QWhereClause> {
  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhereClause>
      tenantIdEqualTo(String tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [tenantId],
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterWhereClause>
      tenantIdNotEqualTo(String tenantId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [],
              upper: [tenantId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [tenantId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [tenantId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [],
              upper: [tenantId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SuscripcionEntityQueryFilter
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QFilterCondition> {
  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      activaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activa',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addonsActivosJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addonsActivosJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addonsActivosJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addonsActivosJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addonsActivosJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addonsActivosJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addonsActivosJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addonsActivosJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addonsActivosJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      addonsActivosJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addonsActivosJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoFinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'periodoFin',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoFinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'periodoFin',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoFinEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodoFin',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoFinGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodoFin',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoFinLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodoFin',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoFinBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodoFin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoInicioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'periodoInicio',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoInicioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'periodoInicio',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoInicioEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodoInicio',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoInicioGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodoInicio',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoInicioLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodoInicio',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      periodoInicioBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodoInicio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'planId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      planIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tenantId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tenantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      trialHastaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trialHasta',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      trialHastaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trialHasta',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      trialHastaEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trialHasta',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      trialHastaGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trialHasta',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      trialHastaLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trialHasta',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      trialHastaBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trialHasta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
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

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      verificadoEnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'verificadoEn',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      verificadoEnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'verificadoEn',
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      verificadoEnEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificadoEn',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      verificadoEnGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verificadoEn',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      verificadoEnLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verificadoEn',
        value: value,
      ));
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterFilterCondition>
      verificadoEnBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verificadoEn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SuscripcionEntityQueryObject
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QFilterCondition> {}

extension SuscripcionEntityQueryLinks
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QFilterCondition> {}

extension SuscripcionEntityQuerySortBy
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QSortBy> {
  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByActiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activa', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByActivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activa', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByAddonsActivosJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addonsActivosJson', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByAddonsActivosJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addonsActivosJson', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByPeriodoFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByPeriodoFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByPeriodoInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByPeriodoInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByTrialHasta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHasta', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByTrialHastaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHasta', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByVerificadoEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificadoEn', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      sortByVerificadoEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificadoEn', Sort.desc);
    });
  }
}

extension SuscripcionEntityQuerySortThenBy
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QSortThenBy> {
  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByActiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activa', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByActivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activa', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByAddonsActivosJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addonsActivosJson', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByAddonsActivosJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addonsActivosJson', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByPeriodoFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByPeriodoFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByPeriodoInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByPeriodoInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByTrialHasta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHasta', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByTrialHastaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialHasta', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByVerificadoEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificadoEn', Sort.asc);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QAfterSortBy>
      thenByVerificadoEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificadoEn', Sort.desc);
    });
  }
}

extension SuscripcionEntityQueryWhereDistinct
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct> {
  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByActiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activa');
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByAddonsActivosJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addonsActivosJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByEstado({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByPeriodoFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodoFin');
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByPeriodoInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodoInicio');
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByPlanId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByTrialHasta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialHasta');
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SuscripcionEntity, SuscripcionEntity, QDistinct>
      distinctByVerificadoEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificadoEn');
    });
  }
}

extension SuscripcionEntityQueryProperty
    on QueryBuilder<SuscripcionEntity, SuscripcionEntity, QQueryProperty> {
  QueryBuilder<SuscripcionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SuscripcionEntity, bool, QQueryOperations> activaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activa');
    });
  }

  QueryBuilder<SuscripcionEntity, String, QQueryOperations>
      addonsActivosJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addonsActivosJson');
    });
  }

  QueryBuilder<SuscripcionEntity, String, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<SuscripcionEntity, DateTime?, QQueryOperations>
      periodoFinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodoFin');
    });
  }

  QueryBuilder<SuscripcionEntity, DateTime?, QQueryOperations>
      periodoInicioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodoInicio');
    });
  }

  QueryBuilder<SuscripcionEntity, String, QQueryOperations> planIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planId');
    });
  }

  QueryBuilder<SuscripcionEntity, String, QQueryOperations> tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<SuscripcionEntity, DateTime?, QQueryOperations>
      trialHastaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialHasta');
    });
  }

  QueryBuilder<SuscripcionEntity, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SuscripcionEntity, DateTime?, QQueryOperations>
      verificadoEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificadoEn');
    });
  }
}
