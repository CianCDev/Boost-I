// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entrega_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEntregaEntityCollection on Isar {
  IsarCollection<EntregaEntity> get entregaEntitys => this.collection();
}

const EntregaEntitySchema = CollectionSchema(
  name: r'EntregaEntity',
  id: 2952494993552337747,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'estadoEntrega': PropertySchema(
      id: 1,
      name: r'estadoEntrega',
      type: IsarType.string,
    ),
    r'fechaEntrega': PropertySchema(
      id: 2,
      name: r'fechaEntrega',
      type: IsarType.dateTime,
    ),
    r'observaciones': PropertySchema(
      id: 3,
      name: r'observaciones',
      type: IsarType.string,
    ),
    r'pedidoId': PropertySchema(
      id: 4,
      name: r'pedidoId',
      type: IsarType.long,
    ),
    r'supabaseId': PropertySchema(
      id: 5,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'usuarioId': PropertySchema(
      id: 6,
      name: r'usuarioId',
      type: IsarType.long,
    )
  },
  estimateSize: _entregaEntityEstimateSize,
  serialize: _entregaEntitySerialize,
  deserialize: _entregaEntityDeserialize,
  deserializeProp: _entregaEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _entregaEntityGetId,
  getLinks: _entregaEntityGetLinks,
  attach: _entregaEntityAttach,
  version: '3.1.0+1',
);

int _entregaEntityEstimateSize(
  EntregaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.estadoEntrega.length * 3;
  {
    final value = object.observaciones;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.supabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _entregaEntitySerialize(
  EntregaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.estadoEntrega);
  writer.writeDateTime(offsets[2], object.fechaEntrega);
  writer.writeString(offsets[3], object.observaciones);
  writer.writeLong(offsets[4], object.pedidoId);
  writer.writeString(offsets[5], object.supabaseId);
  writer.writeLong(offsets[6], object.usuarioId);
}

EntregaEntity _entregaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EntregaEntity();
  object.createdAt = reader.readDateTimeOrNull(offsets[0]);
  object.estadoEntrega = reader.readString(offsets[1]);
  object.fechaEntrega = reader.readDateTime(offsets[2]);
  object.id = id;
  object.observaciones = reader.readStringOrNull(offsets[3]);
  object.pedidoId = reader.readLong(offsets[4]);
  object.supabaseId = reader.readStringOrNull(offsets[5]);
  object.usuarioId = reader.readLong(offsets[6]);
  return object;
}

P _entregaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _entregaEntityGetId(EntregaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _entregaEntityGetLinks(EntregaEntity object) {
  return [];
}

void _entregaEntityAttach(
    IsarCollection<dynamic> col, Id id, EntregaEntity object) {
  object.id = id;
}

extension EntregaEntityQueryWhereSort
    on QueryBuilder<EntregaEntity, EntregaEntity, QWhere> {
  QueryBuilder<EntregaEntity, EntregaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EntregaEntityQueryWhere
    on QueryBuilder<EntregaEntity, EntregaEntity, QWhereClause> {
  QueryBuilder<EntregaEntity, EntregaEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterWhereClause> idBetween(
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

extension EntregaEntityQueryFilter
    on QueryBuilder<EntregaEntity, EntregaEntity, QFilterCondition> {
  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estadoEntrega',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estadoEntrega',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estadoEntrega',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estadoEntrega',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'estadoEntrega',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'estadoEntrega',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estadoEntrega',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estadoEntrega',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estadoEntrega',
        value: '',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      estadoEntregaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estadoEntrega',
        value: '',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      fechaEntregaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEntrega',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      fechaEntregaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaEntrega',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      fechaEntregaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaEntrega',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      fechaEntregaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaEntrega',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesEqualTo(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesGreaterThan(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesLessThan(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesBetween(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesStartsWith(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesEndsWith(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'observaciones',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      observacionesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      pedidoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pedidoId',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      pedidoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pedidoId',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      pedidoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pedidoId',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      pedidoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pedidoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      usuarioIdGreaterThan(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      usuarioIdLessThan(
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

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterFilterCondition>
      usuarioIdBetween(
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

extension EntregaEntityQueryObject
    on QueryBuilder<EntregaEntity, EntregaEntity, QFilterCondition> {}

extension EntregaEntityQueryLinks
    on QueryBuilder<EntregaEntity, EntregaEntity, QFilterCondition> {}

extension EntregaEntityQuerySortBy
    on QueryBuilder<EntregaEntity, EntregaEntity, QSortBy> {
  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByEstadoEntrega() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEntrega', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByEstadoEntregaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEntrega', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByFechaEntrega() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEntrega', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByFechaEntregaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEntrega', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> sortByPedidoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByPedidoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension EntregaEntityQuerySortThenBy
    on QueryBuilder<EntregaEntity, EntregaEntity, QSortThenBy> {
  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByEstadoEntrega() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEntrega', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByEstadoEntregaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEntrega', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByFechaEntrega() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEntrega', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByFechaEntregaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEntrega', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> thenByPedidoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByPedidoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pedidoId', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy> thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension EntregaEntityQueryWhereDistinct
    on QueryBuilder<EntregaEntity, EntregaEntity, QDistinct> {
  QueryBuilder<EntregaEntity, EntregaEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QDistinct> distinctByEstadoEntrega(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estadoEntrega',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QDistinct>
      distinctByFechaEntrega() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEntrega');
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QDistinct> distinctByObservaciones(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observaciones',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QDistinct> distinctByPedidoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pedidoId');
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QDistinct> distinctBySupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EntregaEntity, EntregaEntity, QDistinct> distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }
}

extension EntregaEntityQueryProperty
    on QueryBuilder<EntregaEntity, EntregaEntity, QQueryProperty> {
  QueryBuilder<EntregaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EntregaEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EntregaEntity, String, QQueryOperations>
      estadoEntregaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estadoEntrega');
    });
  }

  QueryBuilder<EntregaEntity, DateTime, QQueryOperations>
      fechaEntregaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEntrega');
    });
  }

  QueryBuilder<EntregaEntity, String?, QQueryOperations>
      observacionesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observaciones');
    });
  }

  QueryBuilder<EntregaEntity, int, QQueryOperations> pedidoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pedidoId');
    });
  }

  QueryBuilder<EntregaEntity, String?, QQueryOperations> supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<EntregaEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }
}
