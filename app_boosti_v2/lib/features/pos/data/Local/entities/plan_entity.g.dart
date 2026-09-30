// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlanEntityCollection on Isar {
  IsarCollection<PlanEntity> get planEntitys => this.collection();
}

const PlanEntitySchema = CollectionSchema(
  name: r'PlanEntity',
  id: 2142100841580792703,
  properties: {
    r'descripcion': PropertySchema(
      id: 0,
      name: r'descripcion',
      type: IsarType.string,
    ),
    r'featuresJson': PropertySchema(
      id: 1,
      name: r'featuresJson',
      type: IsarType.string,
    ),
    r'modosHabilitados': PropertySchema(
      id: 2,
      name: r'modosHabilitados',
      type: IsarType.stringList,
    ),
    r'nombre': PropertySchema(
      id: 3,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'orden': PropertySchema(
      id: 4,
      name: r'orden',
      type: IsarType.long,
    ),
    r'planId': PropertySchema(
      id: 5,
      name: r'planId',
      type: IsarType.string,
    ),
    r'precioAnual': PropertySchema(
      id: 6,
      name: r'precioAnual',
      type: IsarType.double,
    ),
    r'precioMensual': PropertySchema(
      id: 7,
      name: r'precioMensual',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _planEntityEstimateSize,
  serialize: _planEntitySerialize,
  deserialize: _planEntityDeserialize,
  deserializeProp: _planEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'planId': IndexSchema(
      id: 7282644713036731817,
      name: r'planId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'planId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _planEntityGetId,
  getLinks: _planEntityGetLinks,
  attach: _planEntityAttach,
  version: '3.1.0+1',
);

int _planEntityEstimateSize(
  PlanEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.descripcion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.featuresJson.length * 3;
  bytesCount += 3 + object.modosHabilitados.length * 3;
  {
    for (var i = 0; i < object.modosHabilitados.length; i++) {
      final value = object.modosHabilitados[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  bytesCount += 3 + object.planId.length * 3;
  return bytesCount;
}

void _planEntitySerialize(
  PlanEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.descripcion);
  writer.writeString(offsets[1], object.featuresJson);
  writer.writeStringList(offsets[2], object.modosHabilitados);
  writer.writeString(offsets[3], object.nombre);
  writer.writeLong(offsets[4], object.orden);
  writer.writeString(offsets[5], object.planId);
  writer.writeDouble(offsets[6], object.precioAnual);
  writer.writeDouble(offsets[7], object.precioMensual);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

PlanEntity _planEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanEntity();
  object.descripcion = reader.readStringOrNull(offsets[0]);
  object.featuresJson = reader.readString(offsets[1]);
  object.id = id;
  object.modosHabilitados = reader.readStringList(offsets[2]) ?? [];
  object.nombre = reader.readString(offsets[3]);
  object.orden = reader.readLong(offsets[4]);
  object.planId = reader.readString(offsets[5]);
  object.precioAnual = reader.readDoubleOrNull(offsets[6]);
  object.precioMensual = reader.readDouble(offsets[7]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[8]);
  return object;
}

P _planEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _planEntityGetId(PlanEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _planEntityGetLinks(PlanEntity object) {
  return [];
}

void _planEntityAttach(IsarCollection<dynamic> col, Id id, PlanEntity object) {
  object.id = id;
}

extension PlanEntityByIndex on IsarCollection<PlanEntity> {
  Future<PlanEntity?> getByPlanId(String planId) {
    return getByIndex(r'planId', [planId]);
  }

  PlanEntity? getByPlanIdSync(String planId) {
    return getByIndexSync(r'planId', [planId]);
  }

  Future<bool> deleteByPlanId(String planId) {
    return deleteByIndex(r'planId', [planId]);
  }

  bool deleteByPlanIdSync(String planId) {
    return deleteByIndexSync(r'planId', [planId]);
  }

  Future<List<PlanEntity?>> getAllByPlanId(List<String> planIdValues) {
    final values = planIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'planId', values);
  }

  List<PlanEntity?> getAllByPlanIdSync(List<String> planIdValues) {
    final values = planIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'planId', values);
  }

  Future<int> deleteAllByPlanId(List<String> planIdValues) {
    final values = planIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'planId', values);
  }

  int deleteAllByPlanIdSync(List<String> planIdValues) {
    final values = planIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'planId', values);
  }

  Future<Id> putByPlanId(PlanEntity object) {
    return putByIndex(r'planId', object);
  }

  Id putByPlanIdSync(PlanEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'planId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPlanId(List<PlanEntity> objects) {
    return putAllByIndex(r'planId', objects);
  }

  List<Id> putAllByPlanIdSync(List<PlanEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'planId', objects, saveLinks: saveLinks);
  }
}

extension PlanEntityQueryWhereSort
    on QueryBuilder<PlanEntity, PlanEntity, QWhere> {
  QueryBuilder<PlanEntity, PlanEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlanEntityQueryWhere
    on QueryBuilder<PlanEntity, PlanEntity, QWhereClause> {
  QueryBuilder<PlanEntity, PlanEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterWhereClause> planIdEqualTo(
      String planId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'planId',
        value: [planId],
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterWhereClause> planIdNotEqualTo(
      String planId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'planId',
              lower: [],
              upper: [planId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'planId',
              lower: [planId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'planId',
              lower: [planId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'planId',
              lower: [],
              upper: [planId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlanEntityQueryFilter
    on QueryBuilder<PlanEntity, PlanEntity, QFilterCondition> {
  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'descripcion',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'descripcion',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descripcion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descripcion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      descripcionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'featuresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'featuresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'featuresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'featuresJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'featuresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'featuresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'featuresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'featuresJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'featuresJson',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      featuresJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'featuresJson',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modosHabilitados',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modosHabilitados',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modosHabilitados',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modosHabilitados',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modosHabilitados',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modosHabilitados',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modosHabilitados',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modosHabilitados',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modosHabilitados',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modosHabilitados',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modosHabilitados',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modosHabilitados',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modosHabilitados',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modosHabilitados',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modosHabilitados',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      modosHabilitadosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modosHabilitados',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreEqualTo(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreGreaterThan(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreLessThan(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreBetween(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreStartsWith(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreEndsWith(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> ordenEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orden',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> ordenGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orden',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> ordenLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orden',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> ordenBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orden',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdEqualTo(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdGreaterThan(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdLessThan(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdBetween(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdStartsWith(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdEndsWith(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'planId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> planIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      planIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioAnualIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'precioAnual',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioAnualIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'precioAnual',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioAnualEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioAnual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioAnualGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioAnual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioAnualLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioAnual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioAnualBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioAnual',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioMensualEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioMensual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioMensualGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioMensual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioMensualLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioMensual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      precioMensualBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioMensual',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition>
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<PlanEntity, PlanEntity, QAfterFilterCondition> updatedAtBetween(
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
}

extension PlanEntityQueryObject
    on QueryBuilder<PlanEntity, PlanEntity, QFilterCondition> {}

extension PlanEntityQueryLinks
    on QueryBuilder<PlanEntity, PlanEntity, QFilterCondition> {}

extension PlanEntityQuerySortBy
    on QueryBuilder<PlanEntity, PlanEntity, QSortBy> {
  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByFeaturesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featuresJson', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByFeaturesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featuresJson', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByOrden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orden', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByOrdenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orden', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByPrecioAnual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioAnual', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByPrecioAnualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioAnual', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByPrecioMensual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMensual', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByPrecioMensualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMensual', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PlanEntityQuerySortThenBy
    on QueryBuilder<PlanEntity, PlanEntity, QSortThenBy> {
  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByFeaturesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featuresJson', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByFeaturesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featuresJson', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByOrden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orden', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByOrdenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orden', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByPrecioAnual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioAnual', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByPrecioAnualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioAnual', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByPrecioMensual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMensual', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByPrecioMensualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMensual', Sort.desc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PlanEntityQueryWhereDistinct
    on QueryBuilder<PlanEntity, PlanEntity, QDistinct> {
  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByDescripcion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descripcion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByFeaturesJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'featuresJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByModosHabilitados() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modosHabilitados');
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByOrden() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orden');
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByPlanId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByPrecioAnual() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioAnual');
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByPrecioMensual() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioMensual');
    });
  }

  QueryBuilder<PlanEntity, PlanEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PlanEntityQueryProperty
    on QueryBuilder<PlanEntity, PlanEntity, QQueryProperty> {
  QueryBuilder<PlanEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlanEntity, String?, QQueryOperations> descripcionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descripcion');
    });
  }

  QueryBuilder<PlanEntity, String, QQueryOperations> featuresJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'featuresJson');
    });
  }

  QueryBuilder<PlanEntity, List<String>, QQueryOperations>
      modosHabilitadosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modosHabilitados');
    });
  }

  QueryBuilder<PlanEntity, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<PlanEntity, int, QQueryOperations> ordenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orden');
    });
  }

  QueryBuilder<PlanEntity, String, QQueryOperations> planIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planId');
    });
  }

  QueryBuilder<PlanEntity, double?, QQueryOperations> precioAnualProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioAnual');
    });
  }

  QueryBuilder<PlanEntity, double, QQueryOperations> precioMensualProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioMensual');
    });
  }

  QueryBuilder<PlanEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
