// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empleado_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmpleadoInfoEntityCollection on Isar {
  IsarCollection<EmpleadoInfoEntity> get empleadoInfoEntitys =>
      this.collection();
}

const EmpleadoInfoEntitySchema = CollectionSchema(
  name: r'EmpleadoInfoEntity',
  id: 4117932414702442310,
  properties: {
    r'bonoFijo': PropertySchema(
      id: 0,
      name: r'bonoFijo',
      type: IsarType.double,
    ),
    r'cargo': PropertySchema(
      id: 1,
      name: r'cargo',
      type: IsarType.string,
    ),
    r'comisionPorcentaje': PropertySchema(
      id: 2,
      name: r'comisionPorcentaje',
      type: IsarType.double,
    ),
    r'contactoEmergenciaNombre': PropertySchema(
      id: 3,
      name: r'contactoEmergenciaNombre',
      type: IsarType.string,
    ),
    r'contactoEmergenciaTelefono': PropertySchema(
      id: 4,
      name: r'contactoEmergenciaTelefono',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'diasLibres': PropertySchema(
      id: 6,
      name: r'diasLibres',
      type: IsarType.longList,
    ),
    r'fechaIngreso': PropertySchema(
      id: 7,
      name: r'fechaIngreso',
      type: IsarType.dateTime,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 8,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'frecuenciaPago': PropertySchema(
      id: 9,
      name: r'frecuenciaPago',
      type: IsarType.string,
    ),
    r'horarioId': PropertySchema(
      id: 10,
      name: r'horarioId',
      type: IsarType.long,
    ),
    r'monedaSalario': PropertySchema(
      id: 11,
      name: r'monedaSalario',
      type: IsarType.string,
    ),
    r'numeroEmpleado': PropertySchema(
      id: 12,
      name: r'numeroEmpleado',
      type: IsarType.long,
    ),
    r'recibePropinas': PropertySchema(
      id: 13,
      name: r'recibePropinas',
      type: IsarType.bool,
    ),
    r'salarioBase': PropertySchema(
      id: 14,
      name: r'salarioBase',
      type: IsarType.double,
    ),
    r'supabaseId': PropertySchema(
      id: 15,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'supervisorId': PropertySchema(
      id: 16,
      name: r'supervisorId',
      type: IsarType.long,
    ),
    r'syncStatus': PropertySchema(
      id: 17,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tipoContrato': PropertySchema(
      id: 18,
      name: r'tipoContrato',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 19,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'usuarioId': PropertySchema(
      id: 20,
      name: r'usuarioId',
      type: IsarType.long,
    )
  },
  estimateSize: _empleadoInfoEntityEstimateSize,
  serialize: _empleadoInfoEntitySerialize,
  deserialize: _empleadoInfoEntityDeserialize,
  deserializeProp: _empleadoInfoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'usuarioId': IndexSchema(
      id: -6806307564427522310,
      name: r'usuarioId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'usuarioId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _empleadoInfoEntityGetId,
  getLinks: _empleadoInfoEntityGetLinks,
  attach: _empleadoInfoEntityAttach,
  version: '3.1.0+1',
);

int _empleadoInfoEntityEstimateSize(
  EmpleadoInfoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cargo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactoEmergenciaNombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactoEmergenciaTelefono;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.diasLibres.length * 8;
  {
    final value = object.frecuenciaPago;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.monedaSalario;
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
  {
    final value = object.tipoContrato;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _empleadoInfoEntitySerialize(
  EmpleadoInfoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bonoFijo);
  writer.writeString(offsets[1], object.cargo);
  writer.writeDouble(offsets[2], object.comisionPorcentaje);
  writer.writeString(offsets[3], object.contactoEmergenciaNombre);
  writer.writeString(offsets[4], object.contactoEmergenciaTelefono);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeLongList(offsets[6], object.diasLibres);
  writer.writeDateTime(offsets[7], object.fechaIngreso);
  writer.writeDateTime(offsets[8], object.fechaSincronizacion);
  writer.writeString(offsets[9], object.frecuenciaPago);
  writer.writeLong(offsets[10], object.horarioId);
  writer.writeString(offsets[11], object.monedaSalario);
  writer.writeLong(offsets[12], object.numeroEmpleado);
  writer.writeBool(offsets[13], object.recibePropinas);
  writer.writeDouble(offsets[14], object.salarioBase);
  writer.writeString(offsets[15], object.supabaseId);
  writer.writeLong(offsets[16], object.supervisorId);
  writer.writeString(offsets[17], object.syncStatus);
  writer.writeString(offsets[18], object.tipoContrato);
  writer.writeDateTime(offsets[19], object.updatedAt);
  writer.writeLong(offsets[20], object.usuarioId);
}

EmpleadoInfoEntity _empleadoInfoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmpleadoInfoEntity();
  object.bonoFijo = reader.readDoubleOrNull(offsets[0]);
  object.cargo = reader.readStringOrNull(offsets[1]);
  object.comisionPorcentaje = reader.readDoubleOrNull(offsets[2]);
  object.contactoEmergenciaNombre = reader.readStringOrNull(offsets[3]);
  object.contactoEmergenciaTelefono = reader.readStringOrNull(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.diasLibres = reader.readLongList(offsets[6]) ?? [];
  object.fechaIngreso = reader.readDateTimeOrNull(offsets[7]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[8]);
  object.frecuenciaPago = reader.readStringOrNull(offsets[9]);
  object.horarioId = reader.readLongOrNull(offsets[10]);
  object.id = id;
  object.monedaSalario = reader.readStringOrNull(offsets[11]);
  object.numeroEmpleado = reader.readLongOrNull(offsets[12]);
  object.recibePropinas = reader.readBool(offsets[13]);
  object.salarioBase = reader.readDoubleOrNull(offsets[14]);
  object.supabaseId = reader.readStringOrNull(offsets[15]);
  object.supervisorId = reader.readLongOrNull(offsets[16]);
  object.syncStatus = reader.readString(offsets[17]);
  object.tipoContrato = reader.readStringOrNull(offsets[18]);
  object.updatedAt = reader.readDateTime(offsets[19]);
  object.usuarioId = reader.readLong(offsets[20]);
  return object;
}

P _empleadoInfoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLongList(offset) ?? []) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _empleadoInfoEntityGetId(EmpleadoInfoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _empleadoInfoEntityGetLinks(
    EmpleadoInfoEntity object) {
  return [];
}

void _empleadoInfoEntityAttach(
    IsarCollection<dynamic> col, Id id, EmpleadoInfoEntity object) {
  object.id = id;
}

extension EmpleadoInfoEntityByIndex on IsarCollection<EmpleadoInfoEntity> {
  Future<EmpleadoInfoEntity?> getByUsuarioId(int usuarioId) {
    return getByIndex(r'usuarioId', [usuarioId]);
  }

  EmpleadoInfoEntity? getByUsuarioIdSync(int usuarioId) {
    return getByIndexSync(r'usuarioId', [usuarioId]);
  }

  Future<bool> deleteByUsuarioId(int usuarioId) {
    return deleteByIndex(r'usuarioId', [usuarioId]);
  }

  bool deleteByUsuarioIdSync(int usuarioId) {
    return deleteByIndexSync(r'usuarioId', [usuarioId]);
  }

  Future<List<EmpleadoInfoEntity?>> getAllByUsuarioId(
      List<int> usuarioIdValues) {
    final values = usuarioIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'usuarioId', values);
  }

  List<EmpleadoInfoEntity?> getAllByUsuarioIdSync(List<int> usuarioIdValues) {
    final values = usuarioIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'usuarioId', values);
  }

  Future<int> deleteAllByUsuarioId(List<int> usuarioIdValues) {
    final values = usuarioIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'usuarioId', values);
  }

  int deleteAllByUsuarioIdSync(List<int> usuarioIdValues) {
    final values = usuarioIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'usuarioId', values);
  }

  Future<Id> putByUsuarioId(EmpleadoInfoEntity object) {
    return putByIndex(r'usuarioId', object);
  }

  Id putByUsuarioIdSync(EmpleadoInfoEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'usuarioId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUsuarioId(List<EmpleadoInfoEntity> objects) {
    return putAllByIndex(r'usuarioId', objects);
  }

  List<Id> putAllByUsuarioIdSync(List<EmpleadoInfoEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'usuarioId', objects, saveLinks: saveLinks);
  }
}

extension EmpleadoInfoEntityQueryWhereSort
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QWhere> {
  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhere>
      anyUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'usuarioId'),
      );
    });
  }
}

extension EmpleadoInfoEntityQueryWhere
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QWhereClause> {
  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
      usuarioIdEqualTo(int usuarioId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'usuarioId',
        value: [usuarioId],
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterWhereClause>
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
}

extension EmpleadoInfoEntityQueryFilter
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QFilterCondition> {
  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      bonoFijoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bonoFijo',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      bonoFijoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bonoFijo',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      bonoFijoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bonoFijo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      bonoFijoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bonoFijo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      bonoFijoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bonoFijo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      bonoFijoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bonoFijo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cargo',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cargo',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cargo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cargo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cargo',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      cargoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cargo',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      comisionPorcentajeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'comisionPorcentaje',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      comisionPorcentajeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'comisionPorcentaje',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      comisionPorcentajeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comisionPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      comisionPorcentajeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'comisionPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      comisionPorcentajeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'comisionPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      comisionPorcentajeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'comisionPorcentaje',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactoEmergenciaNombre',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactoEmergenciaNombre',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactoEmergenciaNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactoEmergenciaNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactoEmergenciaNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactoEmergenciaNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactoEmergenciaNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactoEmergenciaNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactoEmergenciaNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactoEmergenciaNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactoEmergenciaNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactoEmergenciaNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactoEmergenciaTelefono',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactoEmergenciaTelefono',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactoEmergenciaTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactoEmergenciaTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactoEmergenciaTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactoEmergenciaTelefono',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactoEmergenciaTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactoEmergenciaTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactoEmergenciaTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactoEmergenciaTelefono',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactoEmergenciaTelefono',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      contactoEmergenciaTelefonoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactoEmergenciaTelefono',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diasLibres',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diasLibres',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diasLibres',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diasLibres',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diasLibres',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diasLibres',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diasLibres',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diasLibres',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diasLibres',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      diasLibresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diasLibres',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaIngresoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaIngreso',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaIngresoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaIngreso',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaIngresoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaIngreso',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaIngresoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaIngreso',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaIngresoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaIngreso',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaIngresoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaIngreso',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'frecuenciaPago',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'frecuenciaPago',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frecuenciaPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frecuenciaPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frecuenciaPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frecuenciaPago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frecuenciaPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frecuenciaPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frecuenciaPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frecuenciaPago',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frecuenciaPago',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      frecuenciaPagoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frecuenciaPago',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      horarioIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'horarioId',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      horarioIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'horarioId',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      horarioIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'horarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      horarioIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'horarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      horarioIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'horarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      horarioIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'horarioId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'monedaSalario',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'monedaSalario',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monedaSalario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monedaSalario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monedaSalario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monedaSalario',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monedaSalario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monedaSalario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monedaSalario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monedaSalario',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monedaSalario',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      monedaSalarioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monedaSalario',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      numeroEmpleadoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'numeroEmpleado',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      numeroEmpleadoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'numeroEmpleado',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      numeroEmpleadoEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroEmpleado',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      numeroEmpleadoGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numeroEmpleado',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      numeroEmpleadoLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numeroEmpleado',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      numeroEmpleadoBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numeroEmpleado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      recibePropinasEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recibePropinas',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      salarioBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'salarioBase',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      salarioBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'salarioBase',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      salarioBaseEqualTo(
    double? value, {
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      salarioBaseGreaterThan(
    double? value, {
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      salarioBaseLessThan(
    double? value, {
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      salarioBaseBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supervisorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supervisorId',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supervisorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supervisorId',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supervisorIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supervisorIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supervisorId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supervisorIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supervisorId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      supervisorIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supervisorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tipoContrato',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tipoContrato',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoContrato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoContrato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoContrato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoContrato',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoContrato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoContrato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoContrato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoContrato',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoContrato',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      tipoContratoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoContrato',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterFilterCondition>
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

extension EmpleadoInfoEntityQueryObject
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QFilterCondition> {}

extension EmpleadoInfoEntityQueryLinks
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QFilterCondition> {}

extension EmpleadoInfoEntityQuerySortBy
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QSortBy> {
  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByBonoFijo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonoFijo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByBonoFijoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonoFijo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByCargo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByCargoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByComisionPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisionPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByComisionPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisionPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByContactoEmergenciaNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaNombre', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByContactoEmergenciaNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaNombre', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByContactoEmergenciaTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaTelefono', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByContactoEmergenciaTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaTelefono', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByFechaIngreso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByFechaIngresoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByFrecuenciaPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuenciaPago', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByFrecuenciaPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuenciaPago', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByHorarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horarioId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByHorarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horarioId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByMonedaSalario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monedaSalario', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByMonedaSalarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monedaSalario', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByNumeroEmpleado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroEmpleado', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByNumeroEmpleadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroEmpleado', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByRecibePropinas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recibePropinas', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByRecibePropinasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recibePropinas', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySalarioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySalarioBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByTipoContrato() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoContrato', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByTipoContratoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoContrato', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension EmpleadoInfoEntityQuerySortThenBy
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QSortThenBy> {
  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByBonoFijo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonoFijo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByBonoFijoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonoFijo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByCargo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByCargoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByComisionPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisionPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByComisionPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comisionPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByContactoEmergenciaNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaNombre', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByContactoEmergenciaNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaNombre', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByContactoEmergenciaTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaTelefono', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByContactoEmergenciaTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactoEmergenciaTelefono', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByFechaIngreso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByFechaIngresoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByFrecuenciaPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuenciaPago', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByFrecuenciaPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuenciaPago', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByHorarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horarioId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByHorarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horarioId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByMonedaSalario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monedaSalario', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByMonedaSalarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monedaSalario', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByNumeroEmpleado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroEmpleado', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByNumeroEmpleadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroEmpleado', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByRecibePropinas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recibePropinas', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByRecibePropinasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recibePropinas', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySalarioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySalarioBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarioBase', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByTipoContrato() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoContrato', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByTipoContratoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoContrato', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension EmpleadoInfoEntityQueryWhereDistinct
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct> {
  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByBonoFijo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bonoFijo');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByCargo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cargo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByComisionPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'comisionPorcentaje');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByContactoEmergenciaNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactoEmergenciaNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByContactoEmergenciaTelefono({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactoEmergenciaTelefono',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByDiasLibres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diasLibres');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByFechaIngreso() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaIngreso');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByFrecuenciaPago({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frecuenciaPago',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByHorarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'horarioId');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByMonedaSalario({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monedaSalario',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByNumeroEmpleado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroEmpleado');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByRecibePropinas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recibePropinas');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctBySalarioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salarioBase');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctBySupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisorId');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByTipoContrato({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoContrato', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QDistinct>
      distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }
}

extension EmpleadoInfoEntityQueryProperty
    on QueryBuilder<EmpleadoInfoEntity, EmpleadoInfoEntity, QQueryProperty> {
  QueryBuilder<EmpleadoInfoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, double?, QQueryOperations>
      bonoFijoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bonoFijo');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String?, QQueryOperations> cargoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cargo');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, double?, QQueryOperations>
      comisionPorcentajeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comisionPorcentaje');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String?, QQueryOperations>
      contactoEmergenciaNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactoEmergenciaNombre');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String?, QQueryOperations>
      contactoEmergenciaTelefonoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactoEmergenciaTelefono');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, List<int>, QQueryOperations>
      diasLibresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diasLibres');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, DateTime?, QQueryOperations>
      fechaIngresoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaIngreso');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String?, QQueryOperations>
      frecuenciaPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frecuenciaPago');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, int?, QQueryOperations> horarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'horarioId');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String?, QQueryOperations>
      monedaSalarioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monedaSalario');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, int?, QQueryOperations>
      numeroEmpleadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroEmpleado');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, bool, QQueryOperations>
      recibePropinasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recibePropinas');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, double?, QQueryOperations>
      salarioBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salarioBase');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String?, QQueryOperations>
      supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, int?, QQueryOperations>
      supervisorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisorId');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, String?, QQueryOperations>
      tipoContratoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoContrato');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<EmpleadoInfoEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }
}
