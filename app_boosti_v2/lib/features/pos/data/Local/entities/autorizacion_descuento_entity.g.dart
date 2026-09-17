// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autorizacion_descuento_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAutorizacionDescuentoEntityCollection on Isar {
  IsarCollection<AutorizacionDescuentoEntity>
      get autorizacionDescuentoEntitys => this.collection();
}

const AutorizacionDescuentoEntitySchema = CollectionSchema(
  name: r'AutorizacionDescuentoEntity',
  id: -7976731291569765160,
  properties: {
    r'aprobado': PropertySchema(
      id: 0,
      name: r'aprobado',
      type: IsarType.bool,
    ),
    r'autorizadoPorId': PropertySchema(
      id: 1,
      name: r'autorizadoPorId',
      type: IsarType.long,
    ),
    r'autorizadoPorNombre': PropertySchema(
      id: 2,
      name: r'autorizadoPorNombre',
      type: IsarType.string,
    ),
    r'autorizadoPorRol': PropertySchema(
      id: 3,
      name: r'autorizadoPorRol',
      type: IsarType.string,
    ),
    r'descuentoSolicitado': PropertySchema(
      id: 4,
      name: r'descuentoSolicitado',
      type: IsarType.double,
    ),
    r'esGlobal': PropertySchema(
      id: 5,
      name: r'esGlobal',
      type: IsarType.bool,
    ),
    r'fecha': PropertySchema(
      id: 6,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'motivoRechazo': PropertySchema(
      id: 7,
      name: r'motivoRechazo',
      type: IsarType.string,
    ),
    r'productoId': PropertySchema(
      id: 8,
      name: r'productoId',
      type: IsarType.long,
    ),
    r'productoNombre': PropertySchema(
      id: 9,
      name: r'productoNombre',
      type: IsarType.string,
    ),
    r'solicitadoPorId': PropertySchema(
      id: 10,
      name: r'solicitadoPorId',
      type: IsarType.long,
    ),
    r'solicitadoPorNombre': PropertySchema(
      id: 11,
      name: r'solicitadoPorNombre',
      type: IsarType.string,
    ),
    r'solicitadoPorRol': PropertySchema(
      id: 12,
      name: r'solicitadoPorRol',
      type: IsarType.string,
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
    r'tenantId': PropertySchema(
      id: 15,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'topeRolSolicitante': PropertySchema(
      id: 16,
      name: r'topeRolSolicitante',
      type: IsarType.double,
    ),
    r'ventaIdFk': PropertySchema(
      id: 17,
      name: r'ventaIdFk',
      type: IsarType.long,
    ),
    r'ventaSupabaseId': PropertySchema(
      id: 18,
      name: r'ventaSupabaseId',
      type: IsarType.string,
    )
  },
  estimateSize: _autorizacionDescuentoEntityEstimateSize,
  serialize: _autorizacionDescuentoEntitySerialize,
  deserialize: _autorizacionDescuentoEntityDeserialize,
  deserializeProp: _autorizacionDescuentoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'supabaseId': IndexSchema(
      id: 2753382765909358918,
      name: r'supabaseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'supabaseId',
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
    ),
    r'ventaIdFk': IndexSchema(
      id: -8955582939714860263,
      name: r'ventaIdFk',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ventaIdFk',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _autorizacionDescuentoEntityGetId,
  getLinks: _autorizacionDescuentoEntityGetLinks,
  attach: _autorizacionDescuentoEntityAttach,
  version: '3.1.0+1',
);

int _autorizacionDescuentoEntityEstimateSize(
  AutorizacionDescuentoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.autorizadoPorNombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.autorizadoPorRol;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.motivoRechazo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.productoNombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.solicitadoPorNombre.length * 3;
  bytesCount += 3 + object.solicitadoPorRol.length * 3;
  {
    final value = object.supabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncStatus.length * 3;
  {
    final value = object.tenantId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ventaSupabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _autorizacionDescuentoEntitySerialize(
  AutorizacionDescuentoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.aprobado);
  writer.writeLong(offsets[1], object.autorizadoPorId);
  writer.writeString(offsets[2], object.autorizadoPorNombre);
  writer.writeString(offsets[3], object.autorizadoPorRol);
  writer.writeDouble(offsets[4], object.descuentoSolicitado);
  writer.writeBool(offsets[5], object.esGlobal);
  writer.writeDateTime(offsets[6], object.fecha);
  writer.writeString(offsets[7], object.motivoRechazo);
  writer.writeLong(offsets[8], object.productoId);
  writer.writeString(offsets[9], object.productoNombre);
  writer.writeLong(offsets[10], object.solicitadoPorId);
  writer.writeString(offsets[11], object.solicitadoPorNombre);
  writer.writeString(offsets[12], object.solicitadoPorRol);
  writer.writeString(offsets[13], object.supabaseId);
  writer.writeString(offsets[14], object.syncStatus);
  writer.writeString(offsets[15], object.tenantId);
  writer.writeDouble(offsets[16], object.topeRolSolicitante);
  writer.writeLong(offsets[17], object.ventaIdFk);
  writer.writeString(offsets[18], object.ventaSupabaseId);
}

AutorizacionDescuentoEntity _autorizacionDescuentoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AutorizacionDescuentoEntity();
  object.aprobado = reader.readBool(offsets[0]);
  object.autorizadoPorId = reader.readLongOrNull(offsets[1]);
  object.autorizadoPorNombre = reader.readStringOrNull(offsets[2]);
  object.autorizadoPorRol = reader.readStringOrNull(offsets[3]);
  object.descuentoSolicitado = reader.readDouble(offsets[4]);
  object.esGlobal = reader.readBool(offsets[5]);
  object.fecha = reader.readDateTime(offsets[6]);
  object.id = id;
  object.motivoRechazo = reader.readStringOrNull(offsets[7]);
  object.productoId = reader.readLongOrNull(offsets[8]);
  object.productoNombre = reader.readStringOrNull(offsets[9]);
  object.solicitadoPorId = reader.readLongOrNull(offsets[10]);
  object.solicitadoPorNombre = reader.readString(offsets[11]);
  object.solicitadoPorRol = reader.readString(offsets[12]);
  object.supabaseId = reader.readStringOrNull(offsets[13]);
  object.syncStatus = reader.readString(offsets[14]);
  object.tenantId = reader.readStringOrNull(offsets[15]);
  object.topeRolSolicitante = reader.readDouble(offsets[16]);
  object.ventaIdFk = reader.readLongOrNull(offsets[17]);
  object.ventaSupabaseId = reader.readStringOrNull(offsets[18]);
  return object;
}

P _autorizacionDescuentoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _autorizacionDescuentoEntityGetId(AutorizacionDescuentoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _autorizacionDescuentoEntityGetLinks(
    AutorizacionDescuentoEntity object) {
  return [];
}

void _autorizacionDescuentoEntityAttach(
    IsarCollection<dynamic> col, Id id, AutorizacionDescuentoEntity object) {
  object.id = id;
}

extension AutorizacionDescuentoEntityQueryWhereSort on QueryBuilder<
    AutorizacionDescuentoEntity, AutorizacionDescuentoEntity, QWhere> {
  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhere> anyVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ventaIdFk'),
      );
    });
  }
}

extension AutorizacionDescuentoEntityQueryWhere on QueryBuilder<
    AutorizacionDescuentoEntity, AutorizacionDescuentoEntity, QWhereClause> {
  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'supabaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> supabaseIdEqualTo(String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [supabaseId],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> supabaseIdNotEqualTo(String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [],
              upper: [supabaseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [supabaseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [supabaseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [],
              upper: [supabaseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [null],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> tenantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tenantId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> tenantIdEqualTo(String? tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [tenantId],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> tenantIdNotEqualTo(String? tenantId) {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> ventaIdFkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaIdFk',
        value: [null],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> ventaIdFkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> ventaIdFkEqualTo(int? ventaIdFk) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaIdFk',
        value: [ventaIdFk],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> ventaIdFkNotEqualTo(int? ventaIdFk) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [],
              upper: [ventaIdFk],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [ventaIdFk],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [ventaIdFk],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [],
              upper: [ventaIdFk],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> ventaIdFkGreaterThan(
    int? ventaIdFk, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [ventaIdFk],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> ventaIdFkLessThan(
    int? ventaIdFk, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [],
        upper: [ventaIdFk],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterWhereClause> ventaIdFkBetween(
    int? lowerVentaIdFk,
    int? upperVentaIdFk, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [lowerVentaIdFk],
        includeLower: includeLower,
        upper: [upperVentaIdFk],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AutorizacionDescuentoEntityQueryFilter on QueryBuilder<
    AutorizacionDescuentoEntity,
    AutorizacionDescuentoEntity,
    QFilterCondition> {
  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> aprobadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aprobado',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autorizadoPorId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autorizadoPorId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorId',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autorizadoPorId',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autorizadoPorId',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autorizadoPorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autorizadoPorNombre',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autorizadoPorNombre',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autorizadoPorNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      autorizadoPorNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      autorizadoPorNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'autorizadoPorNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'autorizadoPorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autorizadoPorRol',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autorizadoPorRol',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autorizadoPorRol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      autorizadoPorRolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      autorizadoPorRolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'autorizadoPorRol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorRol',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> autorizadoPorRolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'autorizadoPorRol',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> descuentoSolicitadoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descuentoSolicitado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> descuentoSolicitadoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descuentoSolicitado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> descuentoSolicitadoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descuentoSolicitado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> descuentoSolicitadoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descuentoSolicitado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> esGlobalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esGlobal',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> fechaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'motivoRechazo',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'motivoRechazo',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivoRechazo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motivoRechazo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motivoRechazo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motivoRechazo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motivoRechazo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motivoRechazo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      motivoRechazoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motivoRechazo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      motivoRechazoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motivoRechazo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivoRechazo',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> motivoRechazoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motivoRechazo',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productoId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productoId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoIdGreaterThan(
    int? value, {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoIdLessThan(
    int? value, {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoIdBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productoNombre',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productoNombre',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      productoNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      productoNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> productoNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'solicitadoPorId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'solicitadoPorId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solicitadoPorId',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'solicitadoPorId',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'solicitadoPorId',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'solicitadoPorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solicitadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'solicitadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'solicitadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'solicitadoPorNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'solicitadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'solicitadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      solicitadoPorNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'solicitadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      solicitadoPorNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'solicitadoPorNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solicitadoPorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'solicitadoPorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solicitadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'solicitadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'solicitadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'solicitadoPorRol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'solicitadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'solicitadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      solicitadoPorRolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'solicitadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      solicitadoPorRolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'solicitadoPorRol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solicitadoPorRol',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> solicitadoPorRolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'solicitadoPorRol',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdEqualTo(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdGreaterThan(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdLessThan(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdBetween(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdStartsWith(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdEndsWith(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdEqualTo(
    String? value, {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdGreaterThan(
    String? value, {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdLessThan(
    String? value, {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdStartsWith(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdEndsWith(
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

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      tenantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      tenantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tenantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> topeRolSolicitanteEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topeRolSolicitante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> topeRolSolicitanteGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topeRolSolicitante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> topeRolSolicitanteLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topeRolSolicitante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> topeRolSolicitanteBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topeRolSolicitante',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaIdFkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ventaIdFk',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaIdFkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ventaIdFk',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaIdFkEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdFk',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaIdFkGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaIdFk',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaIdFkLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaIdFk',
        value: value,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaIdFkBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaIdFk',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ventaSupabaseId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ventaSupabaseId',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaSupabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      ventaSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
          QAfterFilterCondition>
      ventaSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ventaSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterFilterCondition> ventaSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaSupabaseId',
        value: '',
      ));
    });
  }
}

extension AutorizacionDescuentoEntityQueryObject on QueryBuilder<
    AutorizacionDescuentoEntity,
    AutorizacionDescuentoEntity,
    QFilterCondition> {}

extension AutorizacionDescuentoEntityQueryLinks on QueryBuilder<
    AutorizacionDescuentoEntity,
    AutorizacionDescuentoEntity,
    QFilterCondition> {}

extension AutorizacionDescuentoEntityQuerySortBy on QueryBuilder<
    AutorizacionDescuentoEntity, AutorizacionDescuentoEntity, QSortBy> {
  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAprobado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aprobado', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAprobadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aprobado', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAutorizadoPorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAutorizadoPorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAutorizadoPorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAutorizadoPorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAutorizadoPorRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByAutorizadoPorRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByDescuentoSolicitado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoSolicitado', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByDescuentoSolicitadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoSolicitado', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByEsGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esGlobal', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByEsGlobalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esGlobal', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByMotivoRechazo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivoRechazo', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByMotivoRechazoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivoRechazo', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByProductoNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoNombre', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByProductoNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoNombre', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySolicitadoPorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySolicitadoPorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySolicitadoPorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorNombre', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySolicitadoPorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorNombre', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySolicitadoPorRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorRol', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySolicitadoPorRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorRol', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByTopeRolSolicitante() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topeRolSolicitante', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByTopeRolSolicitanteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topeRolSolicitante', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByVentaIdFkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByVentaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> sortByVentaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.desc);
    });
  }
}

extension AutorizacionDescuentoEntityQuerySortThenBy on QueryBuilder<
    AutorizacionDescuentoEntity, AutorizacionDescuentoEntity, QSortThenBy> {
  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAprobado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aprobado', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAprobadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aprobado', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAutorizadoPorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAutorizadoPorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAutorizadoPorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAutorizadoPorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAutorizadoPorRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByAutorizadoPorRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByDescuentoSolicitado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoSolicitado', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByDescuentoSolicitadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoSolicitado', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByEsGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esGlobal', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByEsGlobalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esGlobal', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByMotivoRechazo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivoRechazo', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByMotivoRechazoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivoRechazo', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByProductoNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoNombre', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByProductoNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoNombre', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySolicitadoPorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySolicitadoPorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySolicitadoPorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorNombre', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySolicitadoPorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorNombre', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySolicitadoPorRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorRol', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySolicitadoPorRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solicitadoPorRol', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByTopeRolSolicitante() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topeRolSolicitante', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByTopeRolSolicitanteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topeRolSolicitante', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByVentaIdFkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.desc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByVentaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QAfterSortBy> thenByVentaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.desc);
    });
  }
}

extension AutorizacionDescuentoEntityQueryWhereDistinct on QueryBuilder<
    AutorizacionDescuentoEntity, AutorizacionDescuentoEntity, QDistinct> {
  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByAprobado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aprobado');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByAutorizadoPorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autorizadoPorId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByAutorizadoPorNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autorizadoPorNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByAutorizadoPorRol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autorizadoPorRol',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByDescuentoSolicitado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descuentoSolicitado');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByEsGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esGlobal');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByMotivoRechazo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motivoRechazo',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByProductoNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctBySolicitadoPorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'solicitadoPorId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctBySolicitadoPorNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'solicitadoPorNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctBySolicitadoPorRol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'solicitadoPorRol',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctBySupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByTopeRolSolicitante() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topeRolSolicitante');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaIdFk');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, AutorizacionDescuentoEntity,
      QDistinct> distinctByVentaSupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaSupabaseId',
          caseSensitive: caseSensitive);
    });
  }
}

extension AutorizacionDescuentoEntityQueryProperty on QueryBuilder<
    AutorizacionDescuentoEntity, AutorizacionDescuentoEntity, QQueryProperty> {
  QueryBuilder<AutorizacionDescuentoEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, bool, QQueryOperations>
      aprobadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aprobado');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, int?, QQueryOperations>
      autorizadoPorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autorizadoPorId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String?, QQueryOperations>
      autorizadoPorNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autorizadoPorNombre');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String?, QQueryOperations>
      autorizadoPorRolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autorizadoPorRol');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, double, QQueryOperations>
      descuentoSolicitadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descuentoSolicitado');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, bool, QQueryOperations>
      esGlobalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esGlobal');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, DateTime, QQueryOperations>
      fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String?, QQueryOperations>
      motivoRechazoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motivoRechazo');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, int?, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String?, QQueryOperations>
      productoNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoNombre');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, int?, QQueryOperations>
      solicitadoPorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'solicitadoPorId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String, QQueryOperations>
      solicitadoPorNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'solicitadoPorNombre');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String, QQueryOperations>
      solicitadoPorRolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'solicitadoPorRol');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String?, QQueryOperations>
      supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String?, QQueryOperations>
      tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, double, QQueryOperations>
      topeRolSolicitanteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topeRolSolicitante');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, int?, QQueryOperations>
      ventaIdFkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaIdFk');
    });
  }

  QueryBuilder<AutorizacionDescuentoEntity, String?, QQueryOperations>
      ventaSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaSupabaseId');
    });
  }
}
