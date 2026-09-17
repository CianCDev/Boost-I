// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nomina_pago_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNominaPagoEntityCollection on Isar {
  IsarCollection<NominaPagoEntity> get nominaPagoEntitys => this.collection();
}

const NominaPagoEntitySchema = CollectionSchema(
  name: r'NominaPagoEntity',
  id: -6173044901260706485,
  properties: {
    r'bonos': PropertySchema(
      id: 0,
      name: r'bonos',
      type: IsarType.double,
    ),
    r'comisiones': PropertySchema(
      id: 1,
      name: r'comisiones',
      type: IsarType.double,
    ),
    r'comprobanteUrl': PropertySchema(
      id: 2,
      name: r'comprobanteUrl',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deducciones': PropertySchema(
      id: 4,
      name: r'deducciones',
      type: IsarType.double,
    ),
    r'fechaPago': PropertySchema(
      id: 5,
      name: r'fechaPago',
      type: IsarType.dateTime,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 6,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'moneda': PropertySchema(
      id: 7,
      name: r'moneda',
      type: IsarType.string,
    ),
    r'observaciones': PropertySchema(
      id: 8,
      name: r'observaciones',
      type: IsarType.string,
    ),
    r'periodoFin': PropertySchema(
      id: 9,
      name: r'periodoFin',
      type: IsarType.dateTime,
    ),
    r'periodoInicio': PropertySchema(
      id: 10,
      name: r'periodoInicio',
      type: IsarType.dateTime,
    ),
    r'propinas': PropertySchema(
      id: 11,
      name: r'propinas',
      type: IsarType.double,
    ),
    r'salarioBase': PropertySchema(
      id: 12,
      name: r'salarioBase',
      type: IsarType.double,
    ),
    r'supabaseId': PropertySchema(
      id: 13,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 14,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tasaBcv': PropertySchema(
      id: 15,
      name: r'tasaBcv',
      type: IsarType.double,
    ),
    r'totalNeto': PropertySchema(
      id: 16,
      name: r'totalNeto',
      type: IsarType.double,
    ),
    r'usuarioId': PropertySchema(
      id: 17,
      name: r'usuarioId',
      type: IsarType.long,
    )
  },
  estimateSize: _nominaPagoEntityEstimateSize,
  serialize: _nominaPagoEntitySerialize,
  deserialize: _nominaPagoEntityDeserialize,
  deserializeProp: _nominaPagoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'usuarioId': IndexSchema(
      id: -6806307564427522310,
      name: r'usuarioId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'usuarioId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'fechaPago': IndexSchema(
      id: -7959928756205428717,
      name: r'fechaPago',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fechaPago',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _nominaPagoEntityGetId,
  getLinks: _nominaPagoEntityGetLinks,
  attach: _nominaPagoEntityAttach,
  version: '3.1.0+1',
);

int _nominaPagoEntityEstimateSize(
  NominaPagoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.comprobanteUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.moneda.length * 3;
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
  bytesCount += 3 + object.syncStatus.length * 3;
  return bytesCount;
}

void _nominaPagoEntitySerialize(
  NominaPagoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bonos);
  writer.writeDouble(offsets[1], object.comisiones);
  writer.writeString(offsets[2], object.comprobanteUrl);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDouble(offsets[4], object.deducciones);
  writer.writeDateTime(offsets[5], object.fechaPago);
  writer.writeDateTime(offsets[6], object.fechaSincronizacion);
  writer.writeString(offsets[7], object.moneda);
  writer.writeString(offsets[8], object.observaciones);
  writer.writeDateTime(offsets[9], object.periodoFin);
  writer.writeDateTime(offsets[10], object.periodoInicio);
  writer.writeDouble(offsets[11], object.propinas);
  writer.writeDouble(offsets[12], object.salarioBase);
  writer.writeString(offsets[13], object.supabaseId);
  writer.writeString(offsets[14], object.syncStatus);
  writer.writeDouble(offsets[15], object.tasaBcv);
  writer.writeDouble(offsets[16], object.totalNeto);
  writer.writeLong(offsets[17], object.usuarioId);
}

NominaPagoEntity _nominaPagoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NominaPagoEntity();
  object.bonos = reader.readDouble(offsets[0]);
  object.comisiones = reader.readDouble(offsets[1]);
  object.comprobanteUrl = reader.readStringOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.deducciones = reader.readDouble(offsets[4]);
  object.fechaPago = reader.readDateTime(offsets[5]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[6]);
  object.id = id;
  object.moneda = reader.readString(offsets[7]);
  object.observaciones = reader.readStringOrNull(offsets[8]);
  object.periodoFin = reader.readDateTime(offsets[9]);
  object.periodoInicio = reader.readDateTime(offsets[10]);
  object.propinas = reader.readDouble(offsets[11]);
  object.salarioBase = reader.readDouble(offsets[12]);
  object.supabaseId = reader.readStringOrNull(offsets[13]);
  object.syncStatus = reader.readString(offsets[14]);
  object.tasaBcv = reader.readDoubleOrNull(offsets[15]);
  object.totalNeto = reader.readDouble(offsets[16]);
  object.usuarioId = reader.readLong(offsets[17]);
  return object;
}

P _nominaPagoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _nominaPagoEntityGetId(NominaPagoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _nominaPagoEntityGetLinks(NominaPagoEntity object) {
  return [];
}

void _nominaPagoEntityAttach(
    IsarCollection<dynamic> col, Id id, NominaPagoEntity object) {
  object.id = id;
}

extension NominaPagoEntityQueryWhereSort
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QWhere> {
  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhere> anyUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'usuarioId'),
      );
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhere> anyFechaPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'fechaPago'),
      );
    });
  }
}

extension NominaPagoEntityQueryWhere
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QWhereClause> {
  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      usuarioIdEqualTo(int usuarioId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'usuarioId',
        value: [usuarioId],
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      usuarioIdNotEqualTo(int usuarioId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      usuarioIdGreaterThan(
    int usuarioId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [usuarioId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      usuarioIdLessThan(
    int usuarioId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [],
        upper: [usuarioId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      usuarioIdBetween(
    int lowerUsuarioId,
    int upperUsuarioId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [lowerUsuarioId],
        includeLower: includeLower,
        upper: [upperUsuarioId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      fechaPagoEqualTo(DateTime fechaPago) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'fechaPago',
        value: [fechaPago],
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      fechaPagoNotEqualTo(DateTime fechaPago) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fechaPago',
              lower: [],
              upper: [fechaPago],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fechaPago',
              lower: [fechaPago],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fechaPago',
              lower: [fechaPago],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fechaPago',
              lower: [],
              upper: [fechaPago],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      fechaPagoGreaterThan(
    DateTime fechaPago, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fechaPago',
        lower: [fechaPago],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      fechaPagoLessThan(
    DateTime fechaPago, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fechaPago',
        lower: [],
        upper: [fechaPago],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterWhereClause>
      fechaPagoBetween(
    DateTime lowerFechaPago,
    DateTime upperFechaPago, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fechaPago',
        lower: [lowerFechaPago],
        includeLower: includeLower,
        upper: [upperFechaPago],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NominaPagoEntityQueryFilter
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QFilterCondition> {
  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      bonosEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bonos',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      bonosGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bonos',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      bonosLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bonos',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      bonosBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bonos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comisionesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comisiones',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comisionesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'comisiones',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comisionesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'comisiones',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comisionesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'comisiones',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'comprobanteUrl',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'comprobanteUrl',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comprobanteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'comprobanteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'comprobanteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'comprobanteUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'comprobanteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'comprobanteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'comprobanteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'comprobanteUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comprobanteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      comprobanteUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'comprobanteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      deduccionesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deducciones',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      deduccionesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deducciones',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      deduccionesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deducciones',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      deduccionesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deducciones',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      fechaPagoEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaPago',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      fechaPagoGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaPago',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      fechaPagoLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaPago',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      fechaPagoBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaPago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moneda',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moneda',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moneda',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      monedaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moneda',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      observacionesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      observacionesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      observacionesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      observacionesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'observaciones',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      observacionesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      observacionesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoFinEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodoFin',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoFinGreaterThan(
    DateTime value, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoFinLessThan(
    DateTime value, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoFinBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoInicioEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodoInicio',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoInicioGreaterThan(
    DateTime value, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoInicioLessThan(
    DateTime value, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      periodoInicioBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      propinasEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'propinas',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      propinasGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'propinas',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      propinasLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'propinas',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      propinasBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'propinas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      salarioBaseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salarioBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      salarioBaseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'salarioBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      salarioBaseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'salarioBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      salarioBaseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'salarioBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusEqualTo(
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusGreaterThan(
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusLessThan(
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusBetween(
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusStartsWith(
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusEndsWith(
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      tasaBcvIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tasaBcv',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      tasaBcvIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tasaBcv',
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      tasaBcvEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tasaBcv',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      tasaBcvGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tasaBcv',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      tasaBcvLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tasaBcv',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      tasaBcvBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tasaBcv',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      totalNetoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalNeto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      totalNetoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalNeto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      totalNetoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalNeto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      totalNetoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalNeto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterFilterCondition>
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

extension NominaPagoEntityQueryObject
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QFilterCondition> {}

extension NominaPagoEntityQueryLinks
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QFilterCondition> {}

extension NominaPagoEntityQuerySortBy
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QSortBy> {
  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy> sortByBonos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonos', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByBonosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonos', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByComisiones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisiones', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByComisionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisiones', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByComprobanteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprobanteUrl', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByComprobanteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprobanteUrl', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByDeducciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deducciones', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByDeduccionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deducciones', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByFechaPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPago', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByFechaPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPago', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByMoneda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByMonedaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByPeriodoFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByPeriodoFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByPeriodoInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByPeriodoInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByPropinas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propinas', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByPropinasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propinas', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortBySalarioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortBySalarioBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByTotalNeto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNeto', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByTotalNetoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNeto', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension NominaPagoEntityQuerySortThenBy
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QSortThenBy> {
  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy> thenByBonos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonos', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByBonosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonos', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByComisiones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisiones', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByComisionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisiones', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByComprobanteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprobanteUrl', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByComprobanteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprobanteUrl', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByDeducciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deducciones', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByDeduccionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deducciones', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByFechaPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPago', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByFechaPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPago', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByMoneda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByMonedaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByPeriodoFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByPeriodoFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoFin', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByPeriodoInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByPeriodoInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodoInicio', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByPropinas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propinas', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByPropinasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propinas', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenBySalarioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenBySalarioBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByTotalNeto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNeto', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByTotalNetoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNeto', Sort.desc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension NominaPagoEntityQueryWhereDistinct
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct> {
  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByBonos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bonos');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByComisiones() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'comisiones');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByComprobanteUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'comprobanteUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByDeducciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deducciones');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByFechaPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaPago');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct> distinctByMoneda(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moneda', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByObservaciones({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observaciones',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByPeriodoFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodoFin');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByPeriodoInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodoInicio');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByPropinas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'propinas');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctBySalarioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salarioBase');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctBySupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasaBcv');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByTotalNeto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalNeto');
    });
  }

  QueryBuilder<NominaPagoEntity, NominaPagoEntity, QDistinct>
      distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }
}

extension NominaPagoEntityQueryProperty
    on QueryBuilder<NominaPagoEntity, NominaPagoEntity, QQueryProperty> {
  QueryBuilder<NominaPagoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NominaPagoEntity, double, QQueryOperations> bonosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bonos');
    });
  }

  QueryBuilder<NominaPagoEntity, double, QQueryOperations>
      comisionesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comisiones');
    });
  }

  QueryBuilder<NominaPagoEntity, String?, QQueryOperations>
      comprobanteUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comprobanteUrl');
    });
  }

  QueryBuilder<NominaPagoEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<NominaPagoEntity, double, QQueryOperations>
      deduccionesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deducciones');
    });
  }

  QueryBuilder<NominaPagoEntity, DateTime, QQueryOperations>
      fechaPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaPago');
    });
  }

  QueryBuilder<NominaPagoEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<NominaPagoEntity, String, QQueryOperations> monedaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moneda');
    });
  }

  QueryBuilder<NominaPagoEntity, String?, QQueryOperations>
      observacionesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observaciones');
    });
  }

  QueryBuilder<NominaPagoEntity, DateTime, QQueryOperations>
      periodoFinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodoFin');
    });
  }

  QueryBuilder<NominaPagoEntity, DateTime, QQueryOperations>
      periodoInicioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodoInicio');
    });
  }

  QueryBuilder<NominaPagoEntity, double, QQueryOperations> propinasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'propinas');
    });
  }

  QueryBuilder<NominaPagoEntity, double, QQueryOperations>
      salarioBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salarioBase');
    });
  }

  QueryBuilder<NominaPagoEntity, String?, QQueryOperations>
      supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<NominaPagoEntity, String, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<NominaPagoEntity, double?, QQueryOperations> tasaBcvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasaBcv');
    });
  }

  QueryBuilder<NominaPagoEntity, double, QQueryOperations> totalNetoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalNeto');
    });
  }

  QueryBuilder<NominaPagoEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }
}
