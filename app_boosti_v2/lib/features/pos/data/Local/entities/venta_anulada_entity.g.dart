// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venta_anulada_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVentaAnuladaEntityCollection on Isar {
  IsarCollection<VentaAnuladaEntity> get ventaAnuladaEntitys =>
      this.collection();
}

const VentaAnuladaEntitySchema = CollectionSchema(
  name: r'VentaAnuladaEntity',
  id: 2766358350711842893,
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
    r'montoOriginal': PropertySchema(
      id: 2,
      name: r'montoOriginal',
      type: IsarType.double,
    ),
    r'motivo': PropertySchema(
      id: 3,
      name: r'motivo',
      type: IsarType.string,
    ),
    r'sincronizado': PropertySchema(
      id: 4,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'tenantId': PropertySchema(
      id: 5,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'usuarioId': PropertySchema(
      id: 6,
      name: r'usuarioId',
      type: IsarType.long,
    ),
    r'usuarioNombre': PropertySchema(
      id: 7,
      name: r'usuarioNombre',
      type: IsarType.string,
    ),
    r'usuarioRol': PropertySchema(
      id: 8,
      name: r'usuarioRol',
      type: IsarType.string,
    ),
    r'ventaIdOriginal': PropertySchema(
      id: 9,
      name: r'ventaIdOriginal',
      type: IsarType.string,
    )
  },
  estimateSize: _ventaAnuladaEntityEstimateSize,
  serialize: _ventaAnuladaEntitySerialize,
  deserialize: _ventaAnuladaEntityDeserialize,
  deserializeProp: _ventaAnuladaEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'ventaIdOriginal': IndexSchema(
      id: 1373738928624088554,
      name: r'ventaIdOriginal',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ventaIdOriginal',
          type: IndexType.hash,
          caseSensitive: true,
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
  getId: _ventaAnuladaEntityGetId,
  getLinks: _ventaAnuladaEntityGetLinks,
  attach: _ventaAnuladaEntityAttach,
  version: '3.1.0+1',
);

int _ventaAnuladaEntityEstimateSize(
  VentaAnuladaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.motivo.length * 3;
  bytesCount += 3 + object.tenantId.length * 3;
  bytesCount += 3 + object.usuarioNombre.length * 3;
  bytesCount += 3 + object.usuarioRol.length * 3;
  bytesCount += 3 + object.ventaIdOriginal.length * 3;
  return bytesCount;
}

void _ventaAnuladaEntitySerialize(
  VentaAnuladaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.fechaAnulacion);
  writer.writeDateTime(offsets[1], object.fechaSincronizacion);
  writer.writeDouble(offsets[2], object.montoOriginal);
  writer.writeString(offsets[3], object.motivo);
  writer.writeBool(offsets[4], object.sincronizado);
  writer.writeString(offsets[5], object.tenantId);
  writer.writeLong(offsets[6], object.usuarioId);
  writer.writeString(offsets[7], object.usuarioNombre);
  writer.writeString(offsets[8], object.usuarioRol);
  writer.writeString(offsets[9], object.ventaIdOriginal);
}

VentaAnuladaEntity _ventaAnuladaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VentaAnuladaEntity();
  object.fechaAnulacion = reader.readDateTime(offsets[0]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.montoOriginal = reader.readDouble(offsets[2]);
  object.motivo = reader.readString(offsets[3]);
  object.sincronizado = reader.readBool(offsets[4]);
  object.tenantId = reader.readString(offsets[5]);
  object.usuarioId = reader.readLong(offsets[6]);
  object.usuarioNombre = reader.readString(offsets[7]);
  object.usuarioRol = reader.readString(offsets[8]);
  object.ventaIdOriginal = reader.readString(offsets[9]);
  return object;
}

P _ventaAnuladaEntityDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ventaAnuladaEntityGetId(VentaAnuladaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ventaAnuladaEntityGetLinks(
    VentaAnuladaEntity object) {
  return [];
}

void _ventaAnuladaEntityAttach(
    IsarCollection<dynamic> col, Id id, VentaAnuladaEntity object) {
  object.id = id;
}

extension VentaAnuladaEntityQueryWhereSort
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QWhere> {
  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VentaAnuladaEntityQueryWhere
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QWhereClause> {
  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
      ventaIdOriginalEqualTo(String ventaIdOriginal) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaIdOriginal',
        value: [ventaIdOriginal],
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
      ventaIdOriginalNotEqualTo(String ventaIdOriginal) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdOriginal',
              lower: [],
              upper: [ventaIdOriginal],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdOriginal',
              lower: [ventaIdOriginal],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdOriginal',
              lower: [ventaIdOriginal],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdOriginal',
              lower: [],
              upper: [ventaIdOriginal],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
      tenantIdEqualTo(String tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [tenantId],
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterWhereClause>
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

extension VentaAnuladaEntityQueryFilter
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QFilterCondition> {
  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      fechaAnulacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaAnulacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      motivoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      motivoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motivo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      motivoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      motivoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      tenantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      tenantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tenantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioRol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRol',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      usuarioRolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRol',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdOriginal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaIdOriginal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaIdOriginal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaIdOriginal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ventaIdOriginal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ventaIdOriginal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ventaIdOriginal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ventaIdOriginal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdOriginal',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterFilterCondition>
      ventaIdOriginalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaIdOriginal',
        value: '',
      ));
    });
  }
}

extension VentaAnuladaEntityQueryObject
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QFilterCondition> {}

extension VentaAnuladaEntityQueryLinks
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QFilterCondition> {}

extension VentaAnuladaEntityQuerySortBy
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QSortBy> {
  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByFechaAnulacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByFechaAnulacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByMontoOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByMontoOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByUsuarioRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByUsuarioRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByVentaIdOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdOriginal', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      sortByVentaIdOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdOriginal', Sort.desc);
    });
  }
}

extension VentaAnuladaEntityQuerySortThenBy
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QSortThenBy> {
  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByFechaAnulacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByFechaAnulacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAnulacion', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByMontoOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByMontoOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoOriginal', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByUsuarioRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByUsuarioRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.desc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByVentaIdOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdOriginal', Sort.asc);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QAfterSortBy>
      thenByVentaIdOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdOriginal', Sort.desc);
    });
  }
}

extension VentaAnuladaEntityQueryWhereDistinct
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct> {
  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByFechaAnulacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaAnulacion');
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByMontoOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoOriginal');
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByMotivo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motivo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByUsuarioNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByUsuarioRol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QDistinct>
      distinctByVentaIdOriginal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaIdOriginal',
          caseSensitive: caseSensitive);
    });
  }
}

extension VentaAnuladaEntityQueryProperty
    on QueryBuilder<VentaAnuladaEntity, VentaAnuladaEntity, QQueryProperty> {
  QueryBuilder<VentaAnuladaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VentaAnuladaEntity, DateTime, QQueryOperations>
      fechaAnulacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaAnulacion');
    });
  }

  QueryBuilder<VentaAnuladaEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<VentaAnuladaEntity, double, QQueryOperations>
      montoOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoOriginal');
    });
  }

  QueryBuilder<VentaAnuladaEntity, String, QQueryOperations> motivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motivo');
    });
  }

  QueryBuilder<VentaAnuladaEntity, bool, QQueryOperations>
      sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<VentaAnuladaEntity, String, QQueryOperations>
      tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<VentaAnuladaEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }

  QueryBuilder<VentaAnuladaEntity, String, QQueryOperations>
      usuarioNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioNombre');
    });
  }

  QueryBuilder<VentaAnuladaEntity, String, QQueryOperations>
      usuarioRolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRol');
    });
  }

  QueryBuilder<VentaAnuladaEntity, String, QQueryOperations>
      ventaIdOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaIdOriginal');
    });
  }
}
