// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto_anulado_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGastoAnuladoEntityCollection on Isar {
  IsarCollection<GastoAnuladoEntity> get gastoAnuladoEntitys =>
      this.collection();
}

const GastoAnuladoEntitySchema = CollectionSchema(
  name: r'GastoAnuladoEntity',
  id: -3017978489064296758,
  properties: {
    r'fechaAnulacion': PropertySchema(
      id: 0,
      name: r'fechaAnulacion',
      type: IsarType.dateTime,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 1,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'gastoIdOriginal': PropertySchema(
      id: 2,
      name: r'gastoIdOriginal',
      type: IsarType.long,
    ),
    r'montoOriginal': PropertySchema(
      id: 3,
      name: r'montoOriginal',
      type: IsarType.double,
    ),
    r'motivo': PropertySchema(
      id: 4,
      name: r'motivo',
      type: IsarType.string,
    ),
    r'sincronizado': PropertySchema(
      id: 5,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'tenantId': PropertySchema(
      id: 6,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'usuarioId': PropertySchema(
      id: 7,
      name: r'usuarioId',
      type: IsarType.long,
    ),
    r'usuarioNombre': PropertySchema(
      id: 8,
      name: r'usuarioNombre',
      type: IsarType.string,
    )
  },
  estimateSize: _gastoAnuladoEntityEstimateSize,
  serialize: _gastoAnuladoEntitySerialize,
  deserialize: _gastoAnuladoEntityDeserialize,
  deserializeProp: _gastoAnuladoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'gastoIdOriginal': IndexSchema(
      id: 5356655204962221809,
      name: r'gastoIdOriginal',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'gastoIdOriginal',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'tenantId': IndexSchema(
      id: -1042425927805315167,
      name: r'tenantId',
      unique: false,
      replace: false,
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
  getId: _gastoAnuladoEntityGetId,
  getLinks: _gastoAnuladoEntityGetLinks,
  attach: _gastoAnuladoEntityAttach,
  version: '3.1.0+1',
);

int _gastoAnuladoEntityEstimateSize(
  GastoAnuladoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.motivo.length * 3;
  bytesCount += 3 + object.tenantId.length * 3;
  bytesCount += 3 + object.usuarioNombre.length * 3;
  return bytesCount;
}

void _gastoAnuladoEntitySerialize(
  GastoAnuladoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.fechaAnulacion);
  writer.writeDateTime(offsets[1], object.fechaSincronizacion);
  writer.writeLong(offsets[2], object.gastoIdOriginal);
  writer.writeDouble(offsets[3], object.montoOriginal);
  writer.writeString(offsets[4], object.motivo);
  writer.writeBool(offsets[5], object.sincronizado);
  writer.writeString(offsets[6], object.tenantId);
  writer.writeLong(offsets[7], object.usuarioId);
  writer.writeString(offsets[8], object.usuarioNombre);
}

GastoAnuladoEntity _gastoAnuladoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GastoAnuladoEntity();
  object.fechaAnulacion = reader.readDateTime(offsets[0]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[1]);
  object.gastoIdOriginal = reader.readLong(offsets[2]);
  object.id = id;
  object.montoOriginal = reader.readDouble(offsets[3]);
  object.motivo = reader.readString(offsets[4]);
  object.sincronizado = reader.readBool(offsets[5]);
  object.tenantId = reader.readString(offsets[6]);
  object.usuarioId = reader.readLong(offsets[7]);
  object.usuarioNombre = reader.readString(offsets[8]);
  return object;
}

P _gastoAnuladoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gastoAnuladoEntityGetId(GastoAnuladoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gastoAnuladoEntityGetLinks(
    GastoAnuladoEntity object) {
  return [];
}

void _gastoAnuladoEntityAttach(
    IsarCollection<dynamic> col, Id id, GastoAnuladoEntity object) {
  object.id = id;
}

extension GastoAnuladoEntityQueryWhereSort
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QWhere> {
  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhere>
      anyGastoIdOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'gastoIdOriginal'),
      );
    });
  }
}

extension GastoAnuladoEntityQueryWhere
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QWhereClause> {
  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      gastoIdOriginalEqualTo(int gastoIdOriginal) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'gastoIdOriginal',
        value: [gastoIdOriginal],
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      gastoIdOriginalNotEqualTo(int gastoIdOriginal) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gastoIdOriginal',
              lower: [],
              upper: [gastoIdOriginal],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gastoIdOriginal',
              lower: [gastoIdOriginal],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gastoIdOriginal',
              lower: [gastoIdOriginal],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gastoIdOriginal',
              lower: [],
              upper: [gastoIdOriginal],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      gastoIdOriginalGreaterThan(
    int gastoIdOriginal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'gastoIdOriginal',
        lower: [gastoIdOriginal],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      gastoIdOriginalLessThan(
    int gastoIdOriginal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'gastoIdOriginal',
        lower: [],
        upper: [gastoIdOriginal],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      gastoIdOriginalBetween(
    int lowerGastoIdOriginal,
    int upperGastoIdOriginal, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'gastoIdOriginal',
        lower: [lowerGastoIdOriginal],
        includeLower: includeLower,
        upper: [upperGastoIdOriginal],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
      tenantIdEqualTo(String tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [tenantId],
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterWhereClause>
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

extension GastoAnuladoEntityQueryFilter
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QFilterCondition> {
  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      fechaAnulacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaAnulacion',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      fechaAnulacionGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaAnulacion',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      fechaAnulacionLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaAnulacion',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      fechaAnulacionBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaAnulacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      gastoIdOriginalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gastoIdOriginal',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      gastoIdOriginalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gastoIdOriginal',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      gastoIdOriginalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gastoIdOriginal',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      gastoIdOriginalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gastoIdOriginal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      montoOriginalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      montoOriginalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      montoOriginalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      montoOriginalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoOriginal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motivo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motivo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      motivoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      tenantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      tenantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tenantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
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

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterFilterCondition>
      usuarioNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }
}

extension GastoAnuladoEntityQueryObject
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QFilterCondition> {}

extension GastoAnuladoEntityQueryLinks
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QFilterCondition> {}

extension GastoAnuladoEntityQuerySortBy
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QSortBy> {
  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByFechaAnulacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByFechaAnulacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByGastoIdOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gastoIdOriginal', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByGastoIdOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gastoIdOriginal', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByMontoOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByMontoOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      sortByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }
}

extension GastoAnuladoEntityQuerySortThenBy
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QSortThenBy> {
  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByFechaAnulacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByFechaAnulacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByGastoIdOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gastoIdOriginal', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByGastoIdOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gastoIdOriginal', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByMontoOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByMontoOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QAfterSortBy>
      thenByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }
}

extension GastoAnuladoEntityQueryWhereDistinct
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct> {
  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByFechaAnulacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaAnulacion');
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByGastoIdOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gastoIdOriginal');
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByMontoOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoOriginal');
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByMotivo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motivo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }

  QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QDistinct>
      distinctByUsuarioNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioNombre',
          caseSensitive: caseSensitive);
    });
  }
}

extension GastoAnuladoEntityQueryProperty
    on QueryBuilder<GastoAnuladoEntity, GastoAnuladoEntity, QQueryProperty> {
  QueryBuilder<GastoAnuladoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GastoAnuladoEntity, DateTime, QQueryOperations>
      fechaAnulacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaAnulacion');
    });
  }

  QueryBuilder<GastoAnuladoEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<GastoAnuladoEntity, int, QQueryOperations>
      gastoIdOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gastoIdOriginal');
    });
  }

  QueryBuilder<GastoAnuladoEntity, double, QQueryOperations>
      montoOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoOriginal');
    });
  }

  QueryBuilder<GastoAnuladoEntity, String, QQueryOperations> motivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motivo');
    });
  }

  QueryBuilder<GastoAnuladoEntity, bool, QQueryOperations>
      sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<GastoAnuladoEntity, String, QQueryOperations>
      tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<GastoAnuladoEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }

  QueryBuilder<GastoAnuladoEntity, String, QQueryOperations>
      usuarioNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioNombre');
    });
  }
}
