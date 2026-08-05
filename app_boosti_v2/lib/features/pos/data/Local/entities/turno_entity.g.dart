// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turno_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTurnoEntityCollection on Isar {
  IsarCollection<TurnoEntity> get turnoEntitys => this.collection();
}

const TurnoEntitySchema = CollectionSchema(
  name: r'TurnoEntity',
  id: -1837668074078403129,
  properties: {
    r'estado': PropertySchema(
      id: 0,
      name: r'estado',
      type: IsarType.string,
    ),
    r'fechaApertura': PropertySchema(
      id: 1,
      name: r'fechaApertura',
      type: IsarType.dateTime,
    ),
    r'fechaCierre': PropertySchema(
      id: 2,
      name: r'fechaCierre',
      type: IsarType.dateTime,
    ),
    r'montoFinal': PropertySchema(
      id: 3,
      name: r'montoFinal',
      type: IsarType.double,
    ),
    r'montoInicial': PropertySchema(
      id: 4,
      name: r'montoInicial',
      type: IsarType.double,
    ),
    r'syncStatus': PropertySchema(
      id: 5,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'totalVentas': PropertySchema(
      id: 6,
      name: r'totalVentas',
      type: IsarType.double,
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
    ),
    r'ventasCount': PropertySchema(
      id: 9,
      name: r'ventasCount',
      type: IsarType.long,
    )
  },
  estimateSize: _turnoEntityEstimateSize,
  serialize: _turnoEntitySerialize,
  deserialize: _turnoEntityDeserialize,
  deserializeProp: _turnoEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _turnoEntityGetId,
  getLinks: _turnoEntityGetLinks,
  attach: _turnoEntityAttach,
  version: '3.1.0+1',
);

int _turnoEntityEstimateSize(
  TurnoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.estado.length * 3;
  bytesCount += 3 + object.syncStatus.length * 3;
  bytesCount += 3 + object.usuarioNombre.length * 3;
  return bytesCount;
}

void _turnoEntitySerialize(
  TurnoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.estado);
  writer.writeDateTime(offsets[1], object.fechaApertura);
  writer.writeDateTime(offsets[2], object.fechaCierre);
  writer.writeDouble(offsets[3], object.montoFinal);
  writer.writeDouble(offsets[4], object.montoInicial);
  writer.writeString(offsets[5], object.syncStatus);
  writer.writeDouble(offsets[6], object.totalVentas);
  writer.writeLong(offsets[7], object.usuarioId);
  writer.writeString(offsets[8], object.usuarioNombre);
  writer.writeLong(offsets[9], object.ventasCount);
}

TurnoEntity _turnoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TurnoEntity();
  object.estado = reader.readString(offsets[0]);
  object.fechaApertura = reader.readDateTime(offsets[1]);
  object.fechaCierre = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.montoFinal = reader.readDoubleOrNull(offsets[3]);
  object.montoInicial = reader.readDouble(offsets[4]);
  object.syncStatus = reader.readString(offsets[5]);
  object.totalVentas = reader.readDoubleOrNull(offsets[6]);
  object.usuarioId = reader.readLong(offsets[7]);
  object.usuarioNombre = reader.readString(offsets[8]);
  object.ventasCount = reader.readLongOrNull(offsets[9]);
  return object;
}

P _turnoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _turnoEntityGetId(TurnoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _turnoEntityGetLinks(TurnoEntity object) {
  return [];
}

void _turnoEntityAttach(
    IsarCollection<dynamic> col, Id id, TurnoEntity object) {
  object.id = id;
}

extension TurnoEntityQueryWhereSort
    on QueryBuilder<TurnoEntity, TurnoEntity, QWhere> {
  QueryBuilder<TurnoEntity, TurnoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TurnoEntityQueryWhere
    on QueryBuilder<TurnoEntity, TurnoEntity, QWhereClause> {
  QueryBuilder<TurnoEntity, TurnoEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterWhereClause> idBetween(
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

extension TurnoEntityQueryFilter
    on QueryBuilder<TurnoEntity, TurnoEntity, QFilterCondition> {
  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> estadoEqualTo(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> estadoLessThan(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> estadoBetween(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> estadoEndsWith(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> estadoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> estadoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaAperturaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaApertura',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaAperturaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaApertura',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaAperturaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaApertura',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaAperturaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaApertura',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaCierreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaCierre',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaCierreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaCierre',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaCierreEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaCierre',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaCierreGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaCierre',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaCierreLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaCierre',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      fechaCierreBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaCierre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoFinalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'montoFinal',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoFinalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'montoFinal',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoFinalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoFinal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoFinalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoFinal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoFinalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoFinal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoFinalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoFinal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoInicialEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoInicialGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoInicialLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      montoInicialBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoInicial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      totalVentasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalVentas',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      totalVentasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalVentas',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      totalVentasEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalVentas',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      totalVentasGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalVentas',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      totalVentasLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalVentas',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      totalVentasBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalVentas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
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

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      usuarioNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      usuarioNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      usuarioNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      usuarioNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      ventasCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ventasCount',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      ventasCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ventasCount',
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      ventasCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventasCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      ventasCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventasCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      ventasCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventasCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterFilterCondition>
      ventasCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventasCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TurnoEntityQueryObject
    on QueryBuilder<TurnoEntity, TurnoEntity, QFilterCondition> {}

extension TurnoEntityQueryLinks
    on QueryBuilder<TurnoEntity, TurnoEntity, QFilterCondition> {}

extension TurnoEntityQuerySortBy
    on QueryBuilder<TurnoEntity, TurnoEntity, QSortBy> {
  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByFechaApertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy>
      sortByFechaAperturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByFechaCierre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByFechaCierreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByMontoFinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoFinal', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByMontoFinalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoFinal', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByMontoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy>
      sortByMontoInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByTotalVentas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentas', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByTotalVentasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentas', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy>
      sortByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByVentasCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventasCount', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> sortByVentasCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventasCount', Sort.desc);
    });
  }
}

extension TurnoEntityQuerySortThenBy
    on QueryBuilder<TurnoEntity, TurnoEntity, QSortThenBy> {
  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByFechaApertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy>
      thenByFechaAperturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByFechaCierre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByFechaCierreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByMontoFinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoFinal', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByMontoFinalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoFinal', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByMontoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy>
      thenByMontoInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByTotalVentas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentas', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByTotalVentasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentas', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy>
      thenByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByVentasCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventasCount', Sort.asc);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QAfterSortBy> thenByVentasCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventasCount', Sort.desc);
    });
  }
}

extension TurnoEntityQueryWhereDistinct
    on QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> {
  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByEstado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByFechaApertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaApertura');
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByFechaCierre() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaCierre');
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByMontoFinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoFinal');
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByMontoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoInicial');
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctBySyncStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByTotalVentas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalVentas');
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByUsuarioNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TurnoEntity, TurnoEntity, QDistinct> distinctByVentasCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventasCount');
    });
  }
}

extension TurnoEntityQueryProperty
    on QueryBuilder<TurnoEntity, TurnoEntity, QQueryProperty> {
  QueryBuilder<TurnoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TurnoEntity, String, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<TurnoEntity, DateTime, QQueryOperations>
      fechaAperturaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaApertura');
    });
  }

  QueryBuilder<TurnoEntity, DateTime?, QQueryOperations> fechaCierreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaCierre');
    });
  }

  QueryBuilder<TurnoEntity, double?, QQueryOperations> montoFinalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoFinal');
    });
  }

  QueryBuilder<TurnoEntity, double, QQueryOperations> montoInicialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoInicial');
    });
  }

  QueryBuilder<TurnoEntity, String, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<TurnoEntity, double?, QQueryOperations> totalVentasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalVentas');
    });
  }

  QueryBuilder<TurnoEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }

  QueryBuilder<TurnoEntity, String, QQueryOperations> usuarioNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioNombre');
    });
  }

  QueryBuilder<TurnoEntity, int?, QQueryOperations> ventasCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventasCount');
    });
  }
}
